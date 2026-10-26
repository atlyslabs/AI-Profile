import Combine
import Foundation

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

    weak var navigator: ProfileV3SettingsNavigating?
    weak var router: (any ProfileV3SettingsFeedbackRouting)?

    let connectors: ProfileV3ConnectorsSettingsModel
    private let repository: any ProfileV3AppAccessRepository
    private let hints: ProfileV3HubHints
    private var loadTask: Task<Void, Never>?
    private var disconnectTask: Task<Void, Never>?

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
        present(.newPassword, from: .page)
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
    }

    private func present(_ mode: ProfileV3AppCredentialsViewModel.Mode, from origin: ProfileV3AppCredentialsViewModel.Origin) {
        editor?.cancel()
        let editor = ProfileV3AppCredentialsViewModel(mode: mode, origin: origin, repository: repository)
        editor.onFinish = { [weak self] in self?.finishEditing() }
        editor.onFailure = { [weak self] message in self?.router?.showFlash(message, isSuccess: false) }
        self.editor = editor
    }

    private func finishEditing() {
        editor = nil
        saveCompletions += 1
        load()
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
