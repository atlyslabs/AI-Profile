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

    @Published private(set) var step: Step = .explainer
    @Published var username = "" {
        didSet {
            guard username != oldValue, errorMessage != nil else { return }
            errorMessage = nil
        }
    }
    @Published private(set) var phase: ProfileV3SavePhase = .idle
    @Published private(set) var errorMessage: String?
    @Published private(set) var linkedUsername: String?

    let id = UUID()
    let app: ProfileV3LinkedApp

    private let repository: any ProfileV3AppAccessRepository
    private let explainerSeconds: Double
    private let openURL: @MainActor (URL) -> Void
    private let onFinish: () -> Void
    private var explainerTask: Task<Void, Never>?
    private var submitTask: Task<Void, Never>?
    private var redirectTask: Task<Void, Never>?

    init(
        app: ProfileV3LinkedApp,
        repository: any ProfileV3AppAccessRepository,
        explainerSeconds: Double = ProfileV3Theme.Motion.instagramExplainerSeconds,
        openURL: @escaping @MainActor (URL) -> Void = { UIApplication.shared.open($0) },
        onFinish: @escaping () -> Void
    ) {
        self.app = app
        self.repository = repository
        self.explainerSeconds = explainerSeconds
        self.openURL = openURL
        self.onFinish = onFinish
    }

    var normalisedUsername: String {
        ProfileV3InstagramUsername.normalised(username)
    }

    var canSubmit: Bool {
        step == .username && phase == .idle && !normalisedUsername.isEmpty
    }

    func start() {
        guard step == .explainer, explainerTask == nil else { return }
        let seconds = explainerSeconds
        explainerTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
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
        let username = normalisedUsername
        guard ProfileV3InstagramUsername.isValid(username) else {
            errorMessage = ProfileV3Strings.instagramUsernameInvalid
            return
        }
        phase = .saving
        errorMessage = nil
        let repository = repository
        submitTask = Task { [weak self] in
            do {
                let linked = try await repository.linkInstagram(username: username)
                guard let self, !Task.isCancelled else { return }
                linkedUsername = linked
                phase = .saved
                try await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.savedDismissMilliseconds))
                guard !Task.isCancelled else { return }
                step = .redirect
                redirect()
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                phase = .idle
                errorMessage = ProfileV3InstagramUsername.errorMessage(for: error)
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
            openURL(ProfileV3InstagramUsername.messageURL)
            onFinish()
        }
    }
}
