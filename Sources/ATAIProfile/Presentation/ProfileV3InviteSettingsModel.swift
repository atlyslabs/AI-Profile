import Combine
import Foundation

@MainActor
final class ProfileV3InviteSettingsModel: ObservableObject {
    @Published private(set) var invite: ProfileV3InviteCode?
    @Published private(set) var phase: ProfileV3LoadPhase = .loading

    weak var navigator: ProfileV3SettingsNavigating?
    weak var router: (any ProfileV3SettingsRouter)?

    private let host: any ProfileV3InviteHost
    private var loadTask: Task<Void, Never>?

    init(host: any ProfileV3InviteHost) {
        self.host = host
    }

    func open() {
        ProfileV3Analytics.screen(.inviteCode)
        navigator?.push(.inviteCode)
        load()
    }

    func preload() {
        guard invite == nil else { return }
        load()
    }

    func load() {
        let host = host
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.invite,
            fetch: {
                guard let invite = try await host.loadInviteCode() else {
                    throw ProfileV3RepositoryError.unavailable
                }
                return invite
            },
            apply: { $0.invite = $1 }
        )
    }

    func share() {
        guard let invite else { return }
        ProfileV3Analytics.inviteShareClicked(remaining: invite.remainingUses)
        HapticFeedbackGenerator.generateHapticFeedback(type: .medium)
        router?.presentInviteShare(invite)
    }

    func cancelReads() {
        loadTask?.cancel()
    }
}
