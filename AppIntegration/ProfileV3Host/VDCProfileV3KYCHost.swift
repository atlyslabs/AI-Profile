import AIProfile
import SwiftUI
import UIKit

@MainActor
final class VDCProfileV3KYCHost: ProfileV3KYCHost {
    private var onboarding: KYCOnboardingCoordinator?

    func startOnboarding(
        on navigationController: UINavigationController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) {
        guard let navigationController = navigationController as? AVNavigationViewController else {
            assertionFailure("KYC onboarding pushes onto the app's AVNavigationViewController")
            completion(.cancelled)
            return
        }
        let coordinator = KYCOnboardingCoordinator(navigationController: navigationController)
        onboarding = coordinator
        coordinator.startOnboarding(
            onExit: { [weak self] _ in
                self?.release(coordinator)
                completion(.cancelled)
            },
            onComplete: { [weak self] _ in
                self?.release(coordinator)
                completion(.completed)
            }
        )
    }

    func presentMinimalCapture(
        from presenter: UIViewController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) {
        KYCFactory.presentMinimal(
            from: presenter,
            onCancel: { completion(.cancelled) },
            onComplete: { _ in completion(.completed) }
        )
    }

    func gmailConnectView(
        _ screen: ProfileV3KYC.GmailConnectScreen,
        actions: ProfileV3KYC.GmailConnectActions
    ) -> AnyView {
        AnyView(KYCGmailConnectView(
            step: KYCGmailConnectStep(screen),
            progress: screen.progress,
            isBusy: screen.isConnecting,
            nextStepReady: screen.nextStepReady,
            onConnect: { actions.connect() },
            onSwitchToManual: { actions.switchToManual() },
            onConvergenceFinished: { actions.convergenceFinished() },
            onBack: { actions.back() }
        ))
    }

    func itrConnectView(_ screen: ProfileV3KYC.ITRConnectScreen, actions: ProfileV3KYC.ITRConnectActions) -> AnyView {
        AnyView(KYCITRConnectView(
            step: KYCITRStep(screen),
            progress: screen.progress,
            isBusy: screen.isBusy,
            onUploadPDF: { actions.uploadPDF($0) },
            onConnect: { actions.connect($0, $1) },
            onSkip: { actions.skip() },
            onDone: { actions.done() },
            onBack: { actions.back() }
        ))
    }

    func passportCaptureView(
        _ screen: ProfileV3KYC.PassportCaptureScreen,
        actions: ProfileV3KYC.PassportCaptureActions
    ) -> AnyView {
        var copy: [KYCPassportPage: KYCCaptureCopy] = [:]
        if let front = screen.front { copy[.front] = KYCCaptureCopy(title: front.title, subtitle: front.subtitle) }
        if let back = screen.back { copy[.back] = KYCCaptureCopy(title: back.title, subtitle: back.subtitle) }
        return AnyView(KYCPassportFlowView(
            step: KYCPassportStep(pages: [.front, .back], copy: copy, existingImages: [:], skippable: false),
            stepId: screen.stepID,
            uploadService: VDCProfileV3PassportUploader(actions.upload),
            progress: screen.progress,
            onCompleted: { actions.completed() },
            onSkipped: { actions.cancel() },
            showsBack: true,
            onCancel: { actions.cancel() },
            travellerId: screen.travellerID
        ))
    }

    func selfieCaptureView(
        _ screen: ProfileV3KYC.SelfieCaptureScreen,
        actions: ProfileV3KYC.SelfieCaptureActions
    ) -> AnyView {
        AnyView(KYCSelfieCaptureView(
            copy: KYCCaptureCopy(title: screen.copy?.title, subtitle: screen.copy?.subtitle),
            progress: screen.progress,
            showsBack: true,
            travellerId: screen.travellerID,
            upload: { await actions.upload($0) },
            onCompleted: { actions.completed() },
            onCancel: { actions.cancel() }
        ))
    }

    func authorizeGmail() async -> String? {
        await KYCGmailOAuth.obtainServerAuthCode()
    }

    func track(_ event: ProfileV3KYC.Event) {
        switch event {
        case .captureStarted(let actionSource):
            KYCOnboardingAnalytics.actionSourceOverride = actionSource
        case .captureEnded:
            KYCOnboardingAnalytics.actionSourceOverride = nil
        case .itrConnectionDecision(let decision):
            KYCOnboardingAnalytics.itrConnectionDecision(decision == .continued ? .continued : .skipped)
        case .itrConnectionResponse(let decision, let apiResponse, let itrAmount, let itr):
            KYCOnboardingAnalytics.itrConnectionResponse(
                decision: decision,
                apiResponse: apiResponse,
                itrAmount: itrAmount,
                itr: itr
            )
        }
    }

    private func release(_ coordinator: KYCOnboardingCoordinator) {
        if onboarding === coordinator { onboarding = nil }
    }
}

private final class VDCProfileV3PassportUploader: KYCPassportUploadServiceProtocol {
    private let send: @MainActor (ProfileV3PassportSide, Data, String?) async -> ProfileV3KYC.PassportUploadResult

    init(_ send: @escaping @MainActor (ProfileV3PassportSide, Data, String?) async -> ProfileV3KYC.PassportUploadResult) {
        self.send = send
    }

    func upload(
        imageData: Data,
        page: KYCPassportPage,
        residenceCountryCode: String?,
        stepId _: String
    ) async -> KYCPassportPageUploadResult {
        switch await send(page == .front ? .front : .back, imageData, residenceCountryCode) {
        case .accepted: return .accepted
        case .rejected(let message): return .rejected(message: message)
        case .failed(let message): return .failed(message: message)
        }
    }
}

private extension KYCConnectorState {
    init(_ state: ProfileV3ConnectorState) {
        self = KYCConnectorState(rawValue: state.rawValue) ?? .idle
    }
}

private extension KYCGmailConnectStep {
    init(_ screen: ProfileV3KYC.GmailConnectScreen) {
        let content = screen.content
        self.init(
            state: KYCConnectorState(content.state),
            pollAfterMs: content.pollAfterMilliseconds,
            error: content.errorMessage.map { KYCStepError(code: nil, message: $0) },
            title: content.title,
            cardTitle: content.cardTitle,
            cardSubtitle: content.cardSubtitle,
            lookingFor: content.lookingFor.map { KYCLookingForItem(icon: $0.icon, title: $0.title, body: $0.body) },
            connectCTA: screen.connectCTA,
            securityScreen: nil,
            userImageURL: screen.userImageURL,
            icons: screen.brandIcons.map { KYCConnectorBrandIcon(icon: $0.icon, label: $0.label) },
            skippable: false,
            skipCTA: nil,
            skipAfterSeconds: nil,
            findings: nil
        )
    }
}

private extension KYCITRStep {
    init(_ screen: ProfileV3KYC.ITRConnectScreen) {
        let content = screen.content
        self.init(
            state: KYCConnectorState(content.state),
            pollAfterMs: content.pollAfterMilliseconds,
            error: content.errorMessage.map { KYCStepError(code: nil, message: $0) },
            title: content.title,
            cardTitle: content.cardTitle,
            cardSubtitle: content.cardSubtitle,
            lookingFor: content.lookingFor.map { KYCLookingForItem(icon: $0.icon, title: $0.title, body: $0.body) },
            skippable: screen.skippable,
            skipCTA: screen.skipCTA,
            findings: screen.findings.map { findings in
                KYCFindings(title: findings.title, stats: findings.stats.map { KYCStat(label: $0.label, value: $0.value) })
            }
        )
    }
}
