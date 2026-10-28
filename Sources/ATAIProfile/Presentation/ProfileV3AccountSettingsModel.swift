import Combine
import Foundation

@MainActor
final class ProfileV3AccountSettingsModel: ObservableObject {
    @Published private(set) var isAccountDeletionRequested: Bool
    @Published private(set) var isSubmittingDeletion = false
    @Published private(set) var isLoggingOut = false
    @Published private(set) var deleteReason: ProfileV3DeleteAccountReason?
    @Published private(set) var deleteReasonPhase: ProfileV3LoadPhase = .loading
    @Published private(set) var deleteConfirm: ProfileV3DeleteAccountConfirm?
    @Published private(set) var deleteConfirmPhase: ProfileV3LoadPhase = .loading

    weak var navigator: ProfileV3SettingsNavigating?
    weak var router: (any ProfileV3SettingsSheetRouting & ProfileV3SettingsFeedbackRouting & ProfileV3SessionRouting)?

    private let deps: ProfileV3SettingsDependencies
    private let repository: any ProfileV3SettingsRepository
    private var logoutTask: Task<Void, Never>?
    private var deletionTask: Task<Void, Never>?
    private var deleteReasonTask: Task<Void, Never>?
    private var deleteConfirmTask: Task<Void, Never>?
    private var deletionReason = ""

    init(deps: ProfileV3SettingsDependencies, repository: any ProfileV3SettingsRepository) {
        self.deps = deps
        self.repository = repository
        isAccountDeletionRequested = deps.accountDeletionRequested()
    }

    func tapLogout() {
        ProfileV3Analytics.logoutClicked()
        navigator?.push(.logout)
    }

    func tapDeleteAccount() {
        guard !isAccountDeletionRequested else { return }
        navigator?.push(.deleteAccount)
        loadDeleteReason()
        loadDeleteConfirm()
    }

    func loadDeleteReason() {
        guard deleteReason == nil else { return }
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.deleteReasonTask,
            phase: \.deleteReasonPhase,
            content: \.deleteReason,
            fetch: { try await repository.loadDeleteAccountReason() },
            apply: { $0.deleteReason = $1 }
        )
    }

    func loadDeleteConfirm() {
        guard deleteConfirm == nil else { return }
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.deleteConfirmTask,
            phase: \.deleteConfirmPhase,
            content: \.deleteConfirm,
            fetch: { try await repository.loadDeleteAccountConfirm() },
            apply: { $0.deleteConfirm = $1 }
        )
    }

    func submitDeletionReason(_ reason: String) {
        deletionReason = reason
        navigator?.push(.deleteAccountConfirm)
        loadDeleteConfirm()
    }

    func confirmLogout() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        let repository = repository
        let router = router
        logoutTask = Task {
            let acknowledgement = Task { _ = try? await repository.acknowledgeLogout() }
            await ProfileV3WriteQueue.wait(
                for: acknowledgement,
                timeout: .seconds(ProfileV3Theme.Motion.logoutAcknowledgeTimeoutSeconds)
            )
            ProfileV3Analytics.loggedOut()
            router?.performLogout()
        }
    }

    func confirmDeletion() {
        guard !isSubmittingDeletion else { return }
        isSubmittingDeletion = true
        deps.logAccountDeletionReason(deletionReason)
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
                router?.showFlash(ProfileV3Strings.deleteRequestFailed, isSuccess: false)
            }
        }
    }
}
