import Combine
import Foundation
import UIKit

@MainActor
final class ProfileV3InstagramConnectModel: ObservableObject, Identifiable {
    enum Step: Equatable {
        case explainer
        case username
        case redirect
    }

    static let instagramURL = URL(string: "https://www.instagram.com/")!

    @Published private(set) var step: Step = .explainer
    @Published var username = "" {
        didSet {
            guard username != oldValue, errorMessage != nil else { return }
            errorMessage = nil
        }
    }
    @Published private(set) var phase: ProfileV3SavePhase = .idle
    @Published private(set) var errorMessage: String?

    let id = UUID()
    let app: ProfileV3LinkedApp

    private let repository: any ProfileV3AppAccessRepository
    private let openURL: @MainActor (URL) -> Void
    private let onFinish: () -> Void
    private var explainerTask: Task<Void, Never>?
    private var submitTask: Task<Void, Never>?
    private var redirectTask: Task<Void, Never>?

    init(
        app: ProfileV3LinkedApp,
        repository: any ProfileV3AppAccessRepository,
        openURL: @escaping @MainActor (URL) -> Void = { UIApplication.shared.open($0) },
        onFinish: @escaping () -> Void
    ) {
        self.app = app
        self.repository = repository
        self.openURL = openURL
        self.onFinish = onFinish
    }

    var trimmedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "@"))
    }

    var canSubmit: Bool {
        step == .username && phase == .idle && !trimmedUsername.isEmpty
    }

    func start() {
        guard step == .explainer, explainerTask == nil else { return }
        explainerTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.instagramExplainerSeconds))
            guard let self, !Task.isCancelled else { return }
            continueFromExplainer()
        }
    }

    func continueFromExplainer() {
        explainerTask?.cancel()
        guard step == .explainer else { return }
        step = .username
    }

    func submit() {
        guard canSubmit else { return }
        phase = .saving
        errorMessage = nil
        let credentials = ProfileV3AppCredentials(username: trimmedUsername)
        let appID = app.id
        let repository = repository
        submitTask = Task { [weak self] in
            do {
                try await repository.saveAppCredentials(credentials, appID: appID)
                guard let self, !Task.isCancelled else { return }
                phase = .saved
                try await Task.sleep(for: .seconds(ProfileV3Theme.Motion.appCredentialsSuccessSeconds))
                guard !Task.isCancelled else { return }
                step = .redirect
                redirect()
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                phase = .idle
                errorMessage = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed)
            }
        }
    }

    func close() {
        cancel()
        onFinish()
    }

    func cancel() {
        explainerTask?.cancel()
        submitTask?.cancel()
        redirectTask?.cancel()
    }

    private func redirect() {
        redirectTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.instagramRedirectSeconds))
            guard let self, !Task.isCancelled else { return }
            openURL(Self.instagramURL)
            onFinish()
        }
    }
}
