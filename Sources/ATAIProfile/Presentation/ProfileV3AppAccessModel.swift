import Combine
import Foundation
import UIKit

@MainActor
final class ProfileV3AppAccessModel: ObservableObject {
    @Published private(set) var content: ProfileV3AppAccess?
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var editor: ProfileV3AppCredentialsViewModel?
    @Published private(set) var hasSeenHint: Bool
    @Published private(set) var deckResetToken = 0
    @Published private(set) var saveCompletions = 0
    @Published private(set) var disconnectCompletions = 0
    @Published private(set) var disconnectingID: String?
    @Published var isPickingSite = false
    @Published private(set) var sites: [ProfileV3VaultSite] = []
    @Published var detail: ProfileV3VaultCredential?
    @Published var revealedPassword: String?
    @Published private(set) var isRevealing = false
    @Published private(set) var timedOutIDs: Set<String> = []

    weak var navigator: ProfileV3SettingsNavigating?
    weak var router: (any ProfileV3SettingsFeedbackRouting)?

    let connectors: ProfileV3ConnectorsSettingsModel
    private let repository: any ProfileV3AppAccessRepository
    private let hints: ProfileV3HubHints
    private var loadTask: Task<Void, Never>?
    private var disconnectTask: Task<Void, Never>?
    private var pollTask: Task<Void, Never>?
    private var revealTask: Task<Void, Never>?
    private var hidePasswordTask: Task<Void, Never>?

    init(
        repository: any ProfileV3AppAccessRepository,
        connectors: ProfileV3ConnectorsSettingsModel,
        hints: ProfileV3HubHints = ProfileV3HubHints()
    ) {
        self.repository = repository
        self.connectors = connectors
        self.hints = hints
        hasSeenHint = hints.hasSeenConnectedAppsHint
    }

    var autoConnected: [ProfileV3AutoConnectedApp] { content?.autoConnected ?? [] }
    var pendingApps: [ProfileV3LinkedApp] { content?.pending ?? [] }
    var connectedApps: [ProfileV3LinkedApp] { content?.connected ?? [] }

    var usesVault: Bool { content?.usesVault == true }
    var vaultEntries: [ProfileV3VaultCredential] { content?.vault ?? [] }

    var canOpenConnected: Bool {
        !connectedApps.isEmpty || connectors.canOpenControlPanel
    }

    var showsConnectedHint: Bool {
        canOpenConnected && !hasSeenHint
    }

    var deckEntries: [ProfileV3ConnectorDeckEntry] {
        connectedApps.map { app in
            ProfileV3ConnectorDeckEntry(
                id: app.id,
                headline: app.name,
                account: "",
                blurb: app.blurb,
                hint: ProfileV3Strings.connectorDeckHint,
                icon: .remote(app.iconURL),
                isApp: true
            )
        }
    }

    func editor(from origin: ProfileV3AppCredentialsViewModel.Origin) -> ProfileV3AppCredentialsViewModel? {
        editor?.origin == origin ? editor : nil
    }

    func open() {
        navigator?.push(.appAccess)
        load()
        connectors.load()
    }

    func load() {
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.content,
            fetch: { try await repository.loadAppAccess() },
            apply: { $0.content = $1 }
        )
    }

    func tapAddCredentials(_ app: ProfileV3LinkedApp) {
        present(.add(app), from: .page)
    }

    func tapAddNew() {
        guard usesVault else {
            present(.newPassword, from: .page)
            return
        }
        isPickingSite = true
        let repository = repository
        Task { [weak self] in
            do {
                let sites = try await repository.loadVaultSites()
                self?.sites = sites.sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
            } catch {
                self?.router?.showFlash(ProfileV3Error.message(for: error), isSuccess: false)
            }
        }
    }

    func pick(_ site: ProfileV3VaultSite) {
        isPickingSite = false
        presentAfterSheet { self.present(.vaultSite(site), from: .page) }
    }

    func pickCustomSite() {
        isPickingSite = false
        presentAfterSheet { self.present(.vaultCustom, from: .page) }
    }

    func open(_ entry: ProfileV3VaultCredential) {
        let repository = repository
        Task { [weak self] in
            let credential = (try? await repository.vaultCredential(id: entry.id, includeUsername: true)) ?? entry
            self?.present(.vaultEdit(credential), from: .page)
        }
    }

    func closeDetail() {
        detail = nil
        clearRevealedPassword()
    }

    func revealPassword() {
        guard let id = detail?.id, !isRevealing else { return }
        isRevealing = true
        let repository = repository
        let name = UIDevice.current.name
        revealTask = Task { [weak self] in
            do {
                let password = try await repository.revealVaultPassword(id: id, deviceName: name)
                guard let self, self.detail?.id == id else { return }
                revealedPassword = password
                isRevealing = false
                scheduleHidePassword()
            } catch is CancellationError {
                return
            } catch {
                guard let self else { return }
                isRevealing = false
                router?.showFlash(ProfileV3Error.message(for: error), isSuccess: false)
            }
        }
    }

    func copyRevealedPassword() {
        guard let password = revealedPassword else { return }
        UIPasteboard.general.string = password
        router?.showFlash(ProfileV3VaultStrings.copied, isSuccess: true)
        let copied = password
        Task {
            try? await Task.sleep(for: .seconds(30))
            if UIPasteboard.general.string == copied { UIPasteboard.general.string = "" }
        }
    }

    func hidePasswordForBackground() {
        clearRevealedPassword()
    }

    func retryCheck() {
        guard let id = detail?.id else { return }
        let repository = repository
        Task { [weak self] in
            do {
                _ = try await repository.retestVaultCredential(id: id)
                self?.watch(id)
                self?.load()
            } catch {
                self?.router?.showFlash(ProfileV3Error.message(for: error), isSuccess: false)
            }
        }
    }

    func editDetail() {
        guard let entry = detail else { return }
        detail = nil
        clearRevealedPassword()
        presentAfterSheet { self.present(.vaultEdit(entry), from: .page) }
    }

    func deleteDetail() {
        guard let id = detail?.id else { return }
        let repository = repository
        Task { [weak self] in
            do {
                try await repository.deleteVaultCredential(id: id)
                self?.detail = nil
                self?.clearRevealedPassword()
                self?.load()
            } catch {
                self?.router?.showFlash(ProfileV3Error.message(for: error), isSuccess: false)
            }
        }
    }

    func setPaused(_ paused: Bool) {
        guard let id = detail?.id else { return }
        let repository = repository
        Task { [weak self] in
            do {
                if paused {
                    _ = try await repository.pauseVaultCredential(id: id)
                } else {
                    _ = try await repository.resumeVaultCredential(id: id)
                }
                self?.load()
                if let credential = try? await repository.vaultCredential(id: id, includeUsername: true) {
                    self?.detail = credential
                }
            } catch {
                self?.router?.showFlash(ProfileV3Error.message(for: error), isSuccess: false)
            }
        }
    }

    func badge(for entry: ProfileV3VaultCredential) -> String {
        entry.status.badge(attention: entry.attentionReason, timedOut: timedOutIDs.contains(entry.id))
    }

    func tapEdit(_ appID: String) {
        guard let app = content?.app(appID) else { return }
        present(.edit(app), from: .panel)
    }

    func tapConnected() {
        dismissHint()
        connectors.openControlPanel()
    }

    func dismissHint() {
        guard !hasSeenHint else { return }
        hints.hasSeenConnectedAppsHint = true
        hasSeenHint = true
    }

    func closeEditor() {
        guard let editor else { return }
        editor.cancel()
        self.editor = nil
        load()
    }

    func disconnect(_ appID: String) {
        guard disconnectingID == nil else { return }
        disconnectingID = appID
        let repository = repository
        disconnectTask = Task { [weak self] in
            do {
                try await repository.disconnectApp(appID)
                guard let self else { return }
                finishDisconnect(appID)
            } catch is CancellationError {
                return
            } catch {
                guard let self else { return }
                disconnectingID = nil
                deckResetToken += 1
                router?.showFlash(
                    ProfileV3Error.message(for: error, fallback: ProfileV3Strings.disconnectFailed),
                    isSuccess: false
                )
            }
        }
    }

    func cancelReads() {
        loadTask?.cancel()
        pollTask?.cancel()
        revealTask?.cancel()
    }

    private func present(_ mode: ProfileV3AppCredentialsViewModel.Mode, from origin: ProfileV3AppCredentialsViewModel.Origin) {
        editor?.cancel()
        let editor = ProfileV3AppCredentialsViewModel(mode: mode, origin: origin, repository: repository)
        editor.onFinish = { [weak self] in self?.finishEditing() }
        editor.onFailure = { [weak self] message in self?.router?.showFlash(message, isSuccess: false) }
        editor.onAlreadySaved = { [weak self] id in self?.openExisting(id) }
        self.editor = editor
    }

    private func finishEditing() {
        let savedID = editor?.savedID
        editor = nil
        saveCompletions += 1
        load()
        if let savedID { watch(savedID) }
    }

    private func openExisting(_ id: String) {
        editor = nil
        let repository = repository
        Task { [weak self] in
            guard let credential = try? await repository.vaultCredential(id: id, includeUsername: true) else { return }
            self?.present(.vaultEdit(credential), from: .page)
        }
    }

    private func watch(_ id: String) {
        pollTask?.cancel()
        timedOutIDs.remove(id)
        let repository = repository
        pollTask = Task { [weak self] in
            let deadline = Date().addingTimeInterval(60)
            while !Task.isCancelled, Date() < deadline {
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { return }
                guard let credential = try? await repository.vaultCredential(id: id, includeUsername: false) else { continue }
                self?.replace(credential)
                if self?.detail?.id == id, self?.detail?.username != nil {
                    var shown = credential
                    shown.username = self?.detail?.username
                    self?.detail = shown
                } else if self?.detail?.id == id {
                    self?.detail = credential
                }
                if !credential.status.isChecking { return }
            }
            guard !Task.isCancelled else { return }
            self?.timedOutIDs.insert(id)
        }
    }

    private func replace(_ credential: ProfileV3VaultCredential) {
        guard let index = content?.vault.firstIndex(where: { $0.id == credential.id }) else { return }
        let username = content?.vault[index].username
        content?.vault[index] = credential
        if content?.vault[index].username == nil { content?.vault[index].username = username }
        if !credential.status.isChecking { timedOutIDs.remove(credential.id) }
    }

    private func scheduleHidePassword() {
        hidePasswordTask?.cancel()
        hidePasswordTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(30))
            guard !Task.isCancelled else { return }
            self?.clearRevealedPassword()
        }
    }

    private func presentAfterSheet(_ present: @escaping () -> Void) {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            present()
        }
    }

    private func clearRevealedPassword() {
        hidePasswordTask?.cancel()
        revealedPassword = nil
    }

    private func finishDisconnect(_ appID: String) {
        if let index = content?.apps.firstIndex(where: { $0.id == appID }) {
            content?.apps[index].isConnected = false
            content?.apps[index].username = nil
        }
        disconnectingID = nil
        disconnectCompletions += 1
        deckResetToken += 1
        if let navigator {
            navigator.path = Array(navigator.path.prefix { $0.isPage })
        }
        load()
    }
}
