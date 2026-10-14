import Combine
import Foundation

@MainActor
final class ProfileV3AccountSettingsModel: ObservableObject {
    @Published private(set) var isAccountDeletionRequested: Bool
    @Published private(set) var isSubmittingDeletion = false
    @Published private(set) var deletionError: String?
    @Published private(set) var isLoggingOut = false

    weak var navigator: ProfileV3SettingsNavigating?
    weak var router: (any ProfileV3SettingsSheetRouting & ProfileV3SettingsFeedbackRouting & ProfileV3SessionRouting)?

    private let deps: ProfileV3SettingsDependencies
    private let repository: any ProfileV3SettingsRepository
    private var logoutTask: Task<Void, Never>?
    private var deletionTask: Task<Void, Never>?

    init(deps: ProfileV3SettingsDependencies, repository: any ProfileV3SettingsRepository) {
        self.deps = deps
        self.repository = repository
        isAccountDeletionRequested = deps.accountDeletionRequested()
    }

    func tapLogout() {
        navigator?.push(.logout)
    }

    func tapDeleteAccount() {
        guard !isAccountDeletionRequested else { return }
        navigator?.push(.deleteAccount)
    }

    func tapProceedToDelete() {
        deletionError = nil
        navigator?.push(.deleteReason)
    }

    func confirmLogout() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        ProfileV3Analytics.logout()
        let repository = repository
        let router = router
        logoutTask = Task {
            let acknowledgement = Task { _ = try? await repository.acknowledgeLogout() }
            await ProfileV3WriteQueue.wait(
                for: acknowledgement,
                timeout: .seconds(ProfileV3Theme.Motion.logoutAcknowledgeTimeoutSeconds)
            )
            router?.performLogout()
        }
    }

    func submitDeletion(reason: String) {
        guard !isSubmittingDeletion else { return }
        isSubmittingDeletion = true
        deletionError = nil
        deps.logAccountDeletionReason(reason)
        let repository = repository
        let markRequested = deps.markAccountDeletionRequested
        deletionTask = Task { [weak self] in
            do {
                try await repository.requestAccountDeletion()
                markRequested()
                guard let self else { return }
                isSubmittingDeletion = false
                isAccountDeletionRequested = true
                router?.showFlash(ProfileV3Strings.deleteRequestSubmitted, isSuccess: true)
                router?.dismissSettings()
            } catch {
                guard let self else { return }
                isSubmittingDeletion = false
                deletionError = ProfileV3Strings.deleteRequestFailed
            }
        }
    }

    func clearDeletionError() {
        deletionError = nil
    }
}
