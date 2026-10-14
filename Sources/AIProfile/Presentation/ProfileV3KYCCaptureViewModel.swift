import ATCore
import Foundation

@MainActor
final class ProfileV3KYCCaptureViewModel: ObservableObject {

    struct Gmail: Equatable {
        var step: ProfileV3CaptureStep
        var isConnecting = false
        var nextStepReady = false
    }

    struct ITR: Equatable {
        var step: ProfileV3CaptureStep
        var isBusy = false
    }

    enum Phase: Equatable {
        case loading
        case gmail(Gmail)
        case itr(ITR)
        case passport(stepID: String?, front: ProfileV3CaptureCopy?, back: ProfileV3CaptureCopy?)
        case selfie(stepID: String?, copy: ProfileV3CaptureCopy?)
        case failed(String)
        case finished
    }

    @Published private(set) var phase: Phase = .loading

    let capture: ProfileV3KYCCapture
    private let repository: any ProfileV3KYCCaptureRepository
    let kyc: any ProfileV3KYCHost
    private let onFinish: ([String]) -> Void
    private var completedSteps: [String] = []
    private var task: Swift.Task<Void, Never>?
    private var selfieNext: ProfileV3CaptureStep?
    private var gmailNext: ProfileV3CaptureStep?
    private var itrNext: ProfileV3CaptureStep?
    private var selfieUploaded = false
    private var hasStarted = false
    private var didFinish = false

    init(
        capture: ProfileV3KYCCapture,
        repository: any ProfileV3KYCCaptureRepository,
        kyc: any ProfileV3KYCHost,
        onFinish: @escaping ([String]) -> Void
    ) {
        self.capture = capture
        self.repository = repository
        self.kyc = kyc
        self.onFinish = onFinish
    }

    var progress: Double {
        let total = max(capture.steps.count, 1)
        return min(Double(completedSteps.count + 1) / Double(total), 1)
    }

    // MARK: - Lifecycle

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        kyc.track(.captureStarted(actionSource: ProfileV3Analytics.profileSource))
        begin()
    }

    private func endAnalyticsScope() {
        kyc.track(.captureEnded)
    }

    func retry() {
        guard case .failed = phase else { return }
        begin()
    }

    private func begin() {
        guard !didFinish else { return }
        task?.cancel()
        guard !capture.isSatisfied else {
            finish()
            return
        }
        switch capture.route {
        case .session:
            phase = .loading
            let repository = repository
            let steps = capture.steps
            let profileID: String? = capture.establishesMain ? nil : capture.profileID
            run { try await repository.startKYCCapture(steps: steps, profileID: profileID) }
        case .coTraveller:
            guard let first = firstCoTravellerPhase() else {
                finish()
                return
            }
            trackScreen(title: nil)
            phase = first
        }
    }

    func leave() {
        if case .gmail(let gmail) = phase, gmail.step.connectorState != .completed {
            if capture.isConnector {
                ProfileV3Analytics.gmailLaterClicked()
            } else {
                ProfileV3Analytics.kycGmailDecision(decisionStep: Self.gmailDecisionStep, decision: "skipped")
            }
        }
        task?.cancel()
        finish()
    }

    lazy var passportUploader = ProfileV3CapturePassportUploader { [weak self] image, data, residence in
        guard let self else { throw CancellationError() }
        try await self.uploadPassport(image, data: data, residenceCountryCode: residence)
    }

    // MARK: - Gmail

    func connectGmail() {
        guard case .gmail(let gmail) = phase, !gmail.isConnecting else { return }
        if capture.isConnector {
            ProfileV3Analytics.gmailActivateClicked()
        } else {
            ProfileV3Analytics.kycGmailDecision(decisionStep: Self.gmailDecisionStep, decision: "continued")
        }
        let stepID = gmail.step.id
        let kyc = kyc
        updateGmail { $0.isConnecting = true }
        task?.cancel()
        task = Swift.Task { [weak self] in
            let code = await kyc.authorizeGmail()
            guard let self, !Swift.Task.isCancelled else { return }
            guard let code else {
                updateGmail { $0.isConnecting = false }
                return
            }
            do {
                let next = try await repository.answerKYCCapture(.gmailAuthCode(code), stepID: stepID)
                guard !Swift.Task.isCancelled else { return }
                await settleConnector(next, stepID: stepID)
            } catch is CancellationError {
                return
            } catch {
                gmailFailed(ProfileV3Error.message(for: error), errorKind: ProfileV3Analytics.errorKind(error))
            }
        }
    }

    private func updateGmail(_ change: (inout Gmail) -> Void) {
        guard case .gmail(var gmail) = phase else { return }
        change(&gmail)
        phase = .gmail(gmail)
    }

    private func settleConnector(_ initial: ProfileV3CaptureStep?, stepID: String) async {
        var step = initial
        var pollError: Error?
        holdGmailStep(step, stepID: stepID)
        if step?.connectorState == .processing {
            await ProfileV3Backoff.poll(.connector, suggestedMilliseconds: { step?.pollAfterMilliseconds }) {
                do {
                    step = try await repository.loadKYCCaptureState()
                } catch {
                    pollError = error
                    return true
                }
                holdGmailStep(step, stepID: stepID)
                return step?.connectorState != .processing
            }
        }
        guard !Swift.Task.isCancelled, !(pollError is CancellationError) else { return }
        if let pollError {
            gmailFailed(ProfileV3Error.message(for: pollError), errorKind: ProfileV3Analytics.errorKind(pollError))
            return
        }
        switch step?.connectorState {
        case .processing:
            gmailFailed(ProfileV3Strings.gmailSyncTimedOut, errorKind: "connector_timeout")
        case .failed:
            gmailFailed(step?.errorMessage ?? ProfileV3Strings.somethingWentWrong, errorKind: "connector_failed")
        default:
            if capture.isConnector { ProfileV3Analytics.gmailConnectSuccess() }
            markCompleted(ProfileV3CaptureStepKey.gmailConnect)
            gmailNext = Self.isGmailStep(step, stepID: stepID) ? nil : step
            updateGmail {
                $0.step.connectorState = .completed
                $0.isConnecting = false
                $0.nextStepReady = true
            }
        }
    }

    func gmailConvergenceFinished() {
        guard case .gmail(let gmail) = phase, gmail.nextStepReady else { return }
        let next = gmailNext
        gmailNext = nil
        render(next)
    }

    private func holdGmailStep(_ step: ProfileV3CaptureStep?, stepID: String) {
        guard let step, Self.isGmailStep(step, stepID: stepID) else { return }
        updateGmail { $0.step = step }
    }

    private static func isGmailStep(_ step: ProfileV3CaptureStep?, stepID: String) -> Bool {
        step?.id == stepID && step?.type == ProfileV3CaptureStepKey.gmailConnect
    }

    private func gmailFailed(_ message: String, errorKind: String) {
        if capture.isConnector { ProfileV3Analytics.gmailConnectFailure(errorKind: errorKind) }
        guard case .gmail = phase else {
            phase = .failed(message)
            return
        }
        updateGmail {
            $0.isConnecting = false
            $0.nextStepReady = false
            $0.step.connectorState = .failed
            $0.step.errorMessage = message
        }
    }

    // MARK: - ITR

    func connectITR(pan: String, password: String) {
        kyc.track(.itrConnectionDecision(.continued))
        submitITR { repository, stepID in
            try await repository.answerKYCCapture(.itrCredentials(pan: pan, password: password), stepID: stepID)
        }
    }

    func uploadITR(_ data: Data) {
        kyc.track(.itrConnectionDecision(.continued))
        submitITR { repository, stepID in
            try await repository.uploadKYCCaptureDocument(data, stepID: stepID)
        }
    }

    func skipITR() {
        guard case .itr(let itr) = phase, !itr.isBusy else { return }
        kyc.track(.itrConnectionDecision(.skipped))
        let stepID = itr.step.id
        phase = .loading
        let repository = repository
        run { try await repository.answerKYCCapture(.skipped, stepID: stepID) }
    }

    func finishITR() {
        guard case .itr(let itr) = phase, !itr.isBusy, itr.step.connectorState == .completed else { return }
        if let next = itrNext {
            itrNext = nil
            render(next)
            return
        }
        let stepID = itr.step.id
        phase = .loading
        let repository = repository
        run { try await repository.answerKYCCapture(.connectorAcknowledged, stepID: stepID) }
    }

    private func submitITR(
        _ operation: @escaping (any ProfileV3KYCCaptureRepository, String) async throws -> ProfileV3CaptureStep?
    ) {
        guard case .itr(let itr) = phase, !itr.isBusy else { return }
        let stepID = itr.step.id
        updateITR { $0.isBusy = true }
        task?.cancel()
        task = Swift.Task { [weak self] in
            guard let self else { return }
            do {
                let next = try await operation(repository, stepID)
                guard !Swift.Task.isCancelled else { return }
                await settleITR(next, stepID: stepID)
            } catch is CancellationError {
                return
            } catch {
                itrFailed(ProfileV3Error.message(for: error))
            }
        }
    }

    private func settleITR(_ initial: ProfileV3CaptureStep?, stepID: String) async {
        var step = initial
        var pollError: Error?
        holdITRStep(step, stepID: stepID)
        if step?.connectorState == .processing {
            await ProfileV3Backoff.poll(.connector, suggestedMilliseconds: { step?.pollAfterMilliseconds }) {
                do {
                    step = try await repository.loadKYCCaptureState()
                } catch {
                    pollError = error
                    return true
                }
                holdITRStep(step, stepID: stepID)
                return step?.connectorState != .processing
            }
        }
        guard !Swift.Task.isCancelled, !(pollError is CancellationError) else { return }
        if let pollError {
            itrFailed(ProfileV3Error.message(for: pollError))
            return
        }
        let state = step?.connectorState
        kyc.track(.itrConnectionResponse(
            decision: state?.rawValue ?? "",
            apiResponse: state?.rawValue,
            itrAmount: nil,
            itr: nil
        ))
        switch state {
        case .processing:
            itrFailed(ProfileV3Strings.gmailSyncTimedOut)
        case .failed:
            itrFailed(step?.errorMessage ?? ProfileV3Strings.somethingWentWrong)
        default:
            markCompleted(ProfileV3CaptureStepKey.itr)
            itrNext = Self.isITRStep(step, stepID: stepID) ? nil : step
            updateITR {
                $0.step.connectorState = .completed
                $0.isBusy = false
                if let findings = step?.findings { $0.step.findings = findings }
            }
        }
    }

    private func holdITRStep(_ step: ProfileV3CaptureStep?, stepID: String) {
        guard let step, Self.isITRStep(step, stepID: stepID) else { return }
        updateITR { $0.step = step }
    }

    private static func isITRStep(_ step: ProfileV3CaptureStep?, stepID: String) -> Bool {
        step?.id == stepID && step?.type == ProfileV3CaptureStepKey.itr
    }

    private func itrFailed(_ message: String) {
        guard case .itr = phase else {
            phase = .failed(message)
            return
        }
        updateITR {
            $0.isBusy = false
            $0.step.connectorState = .failed
            $0.step.errorMessage = message
        }
    }

    private func updateITR(_ change: (inout ITR) -> Void) {
        guard case .itr(var itr) = phase else { return }
        change(&itr)
        phase = .itr(itr)
    }

    // MARK: - Passport

    func uploadPassport(_ image: ProfileV3CaptureImage, data: Data, residenceCountryCode: String?) async throws {
        switch capture.route {
        case .session:
            guard case .passport(let stepID?, _, _) = phase else {
                throw ProfileV3Error.underlying(ProfileV3Strings.somethingWentWrong)
            }
            _ = try await repository.uploadKYCCaptureImage(
                image,
                data: data,
                stepID: stepID,
                residenceCountryCode: residenceCountryCode
            )
        case .coTraveller:
            try await repository.uploadCoTravellerImage(image, data: data, profileID: capture.profileID)
        }
    }

    func passportCompleted() {
        guard case .passport(let stepID, _, _) = phase else { return }
        markCompleted(ProfileV3CaptureStepKey.passport)
        switch capture.route {
        case .session:
            guard let stepID else {
                finish()
                return
            }
            phase = .loading
            let repository = repository
            run { try await repository.answerKYCCapture(.passportDone, stepID: stepID) }
        case .coTraveller:
            if capture.steps.contains(ProfileV3CaptureStepKey.selfie) {
                trackScreen(title: nil)
                phase = .selfie(stepID: nil, copy: nil)
            } else {
                finish()
            }
        }
    }

    // MARK: - Selfie

    func uploadSelfie(_ data: Data) async -> String? {
        selfieUploaded = false
        selfieNext = nil
        do {
            switch capture.route {
            case .session:
                guard case .selfie(let stepID?, _) = phase else { return ProfileV3Strings.somethingWentWrong }
                selfieNext = try await repository.uploadKYCCaptureImage(
                    .selfie,
                    data: data,
                    stepID: stepID,
                    residenceCountryCode: nil
                )
            case .coTraveller:
                try await repository.uploadCoTravellerImage(.selfie, data: data, profileID: capture.profileID)
            }
            selfieUploaded = true
            return nil
        } catch {
            return ProfileV3Error.message(for: error)
        }
    }

    func selfieCompleted() {
        guard selfieUploaded else { return }
        selfieUploaded = false
        markCompleted(ProfileV3CaptureStepKey.selfie)
        switch capture.route {
        case .session: render(selfieNext)
        case .coTraveller: finish()
        }
    }

    // MARK: - Routing

    private func render(_ step: ProfileV3CaptureStep?) {
        guard let step else {
            finish()
            return
        }
        trackScreen(title: step.title)
        switch step.type {
        case ProfileV3CaptureStepKey.gmailConnect:
            phase = .gmail(Gmail(step: step))
        case ProfileV3CaptureStepKey.itr:
            phase = .itr(ITR(step: step))
        case ProfileV3CaptureStepKey.passport:
            phase = .passport(stepID: step.id, front: step.passportFront, back: step.passportBack)
        case ProfileV3CaptureStepKey.selfie:
            phase = .selfie(stepID: step.id, copy: ProfileV3CaptureCopy(title: step.title, subtitle: step.subtitle))
        default:
            ATCoreLogger.info("[ProfileV3][flow] capture step unsupported type=\(step.type)")
            finish()
        }
    }

    private func firstCoTravellerPhase() -> Phase? {
        if capture.steps.contains(ProfileV3CaptureStepKey.passport) {
            return .passport(stepID: nil, front: nil, back: nil)
        }
        if capture.steps.contains(ProfileV3CaptureStepKey.selfie) {
            return .selfie(stepID: nil, copy: nil)
        }
        return nil
    }

    private func run(_ operation: @escaping () async throws -> ProfileV3CaptureStep?) {
        task?.cancel()
        task = Swift.Task { [weak self] in
            do {
                let step = try await operation()
                guard let self, !Swift.Task.isCancelled else { return }
                render(step)
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Swift.Task.isCancelled else { return }
                phase = .failed(ProfileV3Error.message(for: error))
            }
        }
    }

    private static let gmailDecisionStep = "initial_display"

    private func trackScreen(title: String?) {
        guard !capture.isConnector else { return }
        ProfileV3Analytics.kycScreenSeen(screenTitle: title, screenNumber: completedSteps.count + 1)
    }

    private func markCompleted(_ step: String) {
        guard !completedSteps.contains(step) else { return }
        completedSteps.append(step)
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        endAnalyticsScope()
        if !capture.isConnector, Set(capture.steps).isSubset(of: completedSteps) {
            ProfileV3Analytics.kycOnboardingCompleted(completedSteps: completedSteps)
        }
        phase = .finished
        onFinish(completedSteps)
    }
}

@MainActor
final class ProfileV3CapturePassportUploader {
    private let send: (ProfileV3CaptureImage, Data, String?) async throws -> Void

    init(upload: @escaping (ProfileV3CaptureImage, Data, String?) async throws -> Void) {
        send = upload
    }

    func upload(
        _ side: ProfileV3PassportSide,
        jpeg: Data,
        residenceCountryCode: String?
    ) async -> ProfileV3KYC.PassportUploadResult {
        let image: ProfileV3CaptureImage = side == .front ? .passportFront : .passportBack
        do {
            let isFrontPending: (Error) -> Bool = { ($0 as? ProfileV3Error) == .passportFrontPending }
            try await ProfileV3Backoff.retry(.passportBack, while: isFrontPending) {
                try await send(image, jpeg, residenceCountryCode)
            }
            return .accepted
        } catch ProfileV3Error.invalidRequest(let message) {
            return .rejected(message: message ?? ProfileV3Strings.passportUploadFailed)
        } catch {
            let message = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.passportUploadFailed)
            return .failed(message: message)
        }
    }
}

#if DEBUG
extension ProfileV3KYCCaptureViewModel {
    static func preview(_ phase: Phase) -> ProfileV3KYCCaptureViewModel {
        let viewModel = ProfileV3KYCCaptureViewModel(
            capture: ProfileV3Fixtures.kycCapture,
            repository: ProfileV3MockRepository(),
            kyc: ProfileV3PlaceholderKYCHost(),
            onFinish: { _ in }
        )
        viewModel.hasStarted = true
        viewModel.phase = phase
        return viewModel
    }
}
#endif
