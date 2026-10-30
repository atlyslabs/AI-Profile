import Combine
import Foundation

@MainActor
final class ProfileV3ConnectorsSettingsModel: ObservableObject {
    @Published private(set) var connectors: [ProfileV3Connector] = []
    @Published private(set) var screen: ProfileV3ConnectorsScreen?
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var disconnectConfirm: ProfileV3DisconnectConfirm?
    @Published private(set) var controlPanel: ProfileV3ConnectorControlPanel?
    @Published private(set) var controlPanelPhase: ProfileV3LoadPhase = .loading
    @Published private(set) var deckResetToken = 0
    @Published private(set) var isDisconnecting = false
    @Published private(set) var disconnectCompletions = 0
    @Published private(set) var pendingDisconnect: ProfileV3ConnectorKey?
    @Published var aiConnector: ProfileV3AIConnectorModel?

    weak var navigator: ProfileV3SettingsNavigating?
    weak var router: (any ProfileV3ConnectorsRouting & ProfileV3SettingsFeedbackRouting)?

    private let repository: any ProfileV3SettingsRepository
    private let travellerID: String?
    private var loadTask: Task<Void, Never>?
    private var controlPanelTask: Task<Void, Never>?
    private var confirmTask: Task<Void, Never>?
    private var disconnectTask: Task<Void, Never>?
    private var syncTask: Task<Void, Never>?
    private var disconnectedKeys: Set<ProfileV3ConnectorKey> = []

    init(repository: any ProfileV3SettingsRepository, travellerID: String? = nil) {
        self.repository = repository
        self.travellerID = travellerID
    }

    var connectedConnectors: [ProfileV3Connector] {
        connectors.filter { $0.status == .connected }
    }

    var canOpenControlPanel: Bool {
        screen?.controlPanel != nil
            && connectedConnectors.contains { ProfileV3ConnectorKey(rawValue: $0.id)?.canDisconnect == true }
    }

    var pendingConfirm: ProfileV3DisconnectConfirm? {
        guard let disconnectConfirm, disconnectConfirm.connector == pendingDisconnect else { return nil }
        return disconnectConfirm
    }

    var deckEntries: [ProfileV3ConnectorDeckEntry] {
        (controlPanel?.cards ?? []).filter(isDisconnectable).map { card in
            let connector = connectors.first { $0.id == card.key.rawValue }
            return ProfileV3ConnectorDeckEntry(
                id: card.id,
                headline: card.headline,
                account: card.accountEmail ?? connector?.accountEmail ?? connector?.name ?? "",
                blurb: card.body,
                hint: card.disconnectHint,
                icon: card.iconURL.map { ProfileV3ConnectorIcon.remote($0) }
                    ?? connector?.icon
                    ?? ProfileV3ConnectorsMapper.icon(for: card.key)
            )
        }
    }

    func open() {
        ProfileV3Analytics.screen(.connectors, travellerId: travellerID)
        navigator?.push(.connectors)
        load()
    }

    func load() {
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.screen,
            fetch: { try await repository.loadConnectors() },
            apply: { $0.apply($1) }
        )
    }

    func openControlPanel() {
        navigator?.push(.controlPanel)
        loadControlPanel()
    }

    func loadControlPanel() {
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.controlPanelTask,
            phase: \.controlPanelPhase,
            content: \.controlPanel,
            fetch: { try await repository.loadConnectorControlPanel() },
            apply: { $0.controlPanel = $1 }
        )
    }

    func loadDisconnectConfirm(_ connectorID: String) {
        guard let connector = ProfileV3ConnectorKey(rawValue: connectorID), connector.canDisconnect else { return }
        if disconnectConfirm?.connector != connector {
            disconnectConfirm = nil
        }
        confirmTask?.cancel()
        let repository = repository
        confirmTask = Task { [weak self] in
            let screen = try? await repository.loadDisconnectConfirm(connector)
            guard let self, !Task.isCancelled, let screen else { return }
            disconnectConfirm = screen
        }
    }

    func tapDeckDisconnect(_ connectorID: String) {
        guard let connector = ProfileV3ConnectorKey(rawValue: connectorID), connector.canDisconnect else { return }
        ProfileV3Analytics.connectorDisconnectClicked(connectorName: connector.rawValue)
        pendingDisconnect = connector
        router?.presentDisconnectEmail()
    }

    func tapConnectEmails() { router?.presentConnectorOnboarding() }

    func tapConnect(_ connector: ProfileV3Connector) {
        if let key = connector.aiConnector {
            openAIConnector(key)
            return
        }
        guard let step = connector.captureStep else { return }
        router?.startConnectorCapture(step)
    }

    func openAIConnector(_ key: String) {
        guard aiConnector == nil else { return }
        aiConnector = ProfileV3AIConnectorModel(
            connector: key,
            repository: repository,
            onConnected: { [weak self] in self?.load() },
            onClose: { [weak self] in self?.aiConnector = nil }
        )
    }

    func confirmDisconnect() {
        guard let pendingDisconnect, pendingDisconnect.canDisconnect, !isDisconnecting else { return }
        isDisconnecting = true
        router?.presentDisconnectProgress()
        let connector = pendingDisconnect
        let repository = repository
        disconnectTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.disconnectGraceSeconds))
            guard !Task.isCancelled else { return }
            do {
                try await repository.disconnectConnector(connector)
                guard let self else { return }
                finishDisconnect(connector, result: .success(()))
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                finishDisconnect(connector, result: .failure(error))
            }
        }
    }

    func stopDisconnecting() {
        guard isDisconnecting else { return }
        disconnectTask?.cancel()
        isDisconnecting = false
        router?.dismissDisconnectProgress()
        load()
        router?.dismissDisconnectEmail()
        deckResetToken += 1
        guard canOpenControlPanel, navigator?.path.last != .controlPanel else { return }
        navigator?.path = [.connectors, .controlPanel]
        loadControlPanel()
    }

    func cancelReads() {
        aiConnector?.cancel()
        loadTask?.cancel()
        controlPanelTask?.cancel()
        confirmTask?.cancel()
        syncTask?.cancel()
    }

    private func finishDisconnect(_ connector: ProfileV3ConnectorKey, result: Result<Void, Error>) {
        isDisconnecting = false
        router?.dismissDisconnectProgress()
        switch result {
        case .success:
            ProfileV3Analytics.connectorDisconnected(connectorName: connector.rawValue)
            router?.connectorDidDisconnect(connector)
            disconnectedKeys.insert(connector)
            connectors = reconciled(connectors)
            disconnectCompletions += 1
            router?.dismissDisconnectEmail()
            navigator?.path = [.connectors]
            syncDisconnected()
        case .failure(let error):
            ProfileV3Analytics.connectorDisconnectFailed(connectorName: connector.rawValue, error: error)
            router?.showFlash(failureMessage(error), isSuccess: false)
        }
    }

    private func isDisconnectable(_ card: ProfileV3ConnectorCard) -> Bool {
        card.isConnected && card.key.canDisconnect && !disconnectedKeys.contains(card.key)
    }

    private func reconciled(_ connectors: [ProfileV3Connector]) -> [ProfileV3Connector] {
        connectors.map { connector in
            guard let key = ProfileV3ConnectorKey(rawValue: connector.id), disconnectedKeys.contains(key) else {
                return connector
            }
            return ProfileV3Connector(
                id: connector.id,
                name: connector.name,
                icon: connector.icon,
                status: .needsAttention,
                accountEmail: connector.accountEmail
            )
        }
    }

    private func apply(_ screen: ProfileV3ConnectorsScreen) {
        let reportedConnected = screen.connectors
            .filter { $0.status == .connected }
            .compactMap { ProfileV3ConnectorKey(rawValue: $0.id) }
        disconnectedKeys.formIntersection(reportedConnected)
        self.screen = screen
        connectors = reconciled(screen.connectors)
    }

    private func syncDisconnected() {
        syncTask?.cancel()
        let repository = repository
        syncTask = Task { [weak self] in
            await ProfileV3Backoff.poll {
                guard let screen = try? await repository.loadConnectors() else { return false }
                guard let self, !Task.isCancelled else { return true }
                self.apply(screen)
                return self.disconnectedKeys.isEmpty
            }
        }
    }

    private func failureMessage(_ error: Error) -> String {
        if case ProfileV3Error.notImplemented = error { return ProfileV3Strings.disconnectFailed }
        return ProfileV3Error.message(for: error, fallback: ProfileV3Strings.disconnectFailed)
    }
}
