import Combine
import Foundation
import UIKit

@MainActor
final class ProfileV3CredentialStoreModel: ObservableObject {
    enum Sheet: Identifiable {
        case picker
        case editor(ProfileV3AppCredentialsViewModel)
        case deleteConfirm(ProfileV3AppCredentialsViewModel)

        var id: String {
            switch self {
            case .picker: return "picker"
            case .editor(let editor): return editor.id.uuidString
            case .deleteConfirm(let editor): return "delete-\(editor.id.uuidString)"
            }
        }
    }

    @Published private(set) var entries: [ProfileV3VaultCredential]?
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published var isPresented = false
    @Published private(set) var isUnlocking = false
    @Published private(set) var sheet: Sheet?
    @Published private(set) var sites: [ProfileV3VaultSite]?
    @Published private(set) var sitesPhase: ProfileV3LoadPhase = .loading
    @Published private(set) var openingID: String?
    @Published private(set) var saveCompletions = 0
    @Published private(set) var deleteCompletions = 0

    private let repository: any ProfileV3AppAccessRepository
    private let unlock: @Sendable () async -> ProfileV3VaultUnlock
    private let lock: @Sendable () -> Void
    private var unlockTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?
    private var sitesTask: Task<Void, Never>?
    private var openTask: Task<Void, Never>?
    private var backgroundObserver: AnyCancellable?

    init(
        repository: any ProfileV3AppAccessRepository,
        unlock: @escaping @Sendable () async -> ProfileV3VaultUnlock = { await ProfileV3VaultDevice.unlockVault() },
        lock: @escaping @Sendable () -> Void = { ProfileV3VaultDevice.lockVault() }
    ) {
        self.repository = repository
        self.unlock = unlock
        self.lock = lock
        backgroundObserver = NotificationCenter.default
            .publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in lock() }
    }

    var rows: [ProfileV3VaultCredential] { entries ?? [] }

    var editor: ProfileV3AppCredentialsViewModel? {
        switch sheet {
        case .editor(let editor), .deleteConfirm(let editor): return editor
        case .picker, nil: return nil
        }
    }

    var isConfirmingDelete: Bool {
        if case .deleteConfirm = sheet { return true }
        return false
    }

    var isPickingSite: Bool {
        if case .picker = sheet { return true }
        return false
    }

    func open() {
        guard !isPresented, !isUnlocking else { return }
        isUnlocking = true
        let unlock = unlock
        unlockTask = Task { [weak self] in
            let result = await unlock()
            guard let self, !Task.isCancelled else { return }
            isUnlocking = false
            guard result == .unlocked else { return }
            isPresented = true
            load()
        }
    }

    func load() {
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.entries,
            fetch: { try await repository.loadVaultCredentials() },
            apply: { $0.entries = $1 }
        )
    }

    func tapAdd() {
        sheet = .picker
        loadSites()
    }

    func loadSites() {
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.sitesTask,
            phase: \.sitesPhase,
            content: \.sites,
            fetch: {
                try await repository.loadVaultSites()
                    .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
            },
            apply: { $0.sites = $1 }
        )
    }

    func sites(matching query: String) -> [ProfileV3VaultSite] {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return sites ?? [] }
        return (sites ?? []).filter { site in
            site.displayName.localizedCaseInsensitiveContains(text)
                || site.loginURL.flatMap(ProfileV3VaultSite.displayAddress)?.localizedCaseInsensitiveContains(text) == true
        }
    }

    func pick(_ site: ProfileV3VaultSite) {
        present(.vaultNew(site: site))
    }

    func pickOtherWebsite(_ query: String) {
        present(.vaultNew(website: query))
    }

    func open(_ entry: ProfileV3VaultCredential) {
        guard openingID == nil else { return }
        openingID = entry.id
        let repository = repository
        openTask = Task { [weak self] in
            let credential = (try? await repository.vaultCredential(id: entry.id, includeUsername: true)) ?? entry
            guard let self, !Task.isCancelled else { return }
            openingID = nil
            present(.vaultEdit(credential))
        }
    }

    func closeSheet() {
        guard let sheet else { return }
        self.sheet = nil
        switch sheet {
        case .editor(let editor), .deleteConfirm(let editor):
            editor.cancel()
            load()
        case .picker:
            break
        }
    }

    func cancelReads() {
        lock()
        unlockTask?.cancel()
        isUnlocking = false
        loadTask?.cancel()
        sitesTask?.cancel()
        openTask?.cancel()
        openingID = nil
    }

    private func present(_ mode: ProfileV3AppCredentialsViewModel.Mode) {
        editor?.cancel()
        let editor = ProfileV3AppCredentialsViewModel(mode: mode, origin: .page, repository: repository)
        editor.onFinish = { [weak self] in self?.finishEditing() }
        editor.onDeleted = { [weak self] in self?.finishDeleting() }
        editor.onAlreadySaved = { [weak self] id in self?.openExisting(id) }
        editor.onConfirmingDeleteChange = { [weak self, weak editor] confirming in
            guard let self, let editor else { return }
            routeDelete(editor, confirming: confirming)
        }
        sheet = .editor(editor)
    }

    private func routeDelete(_ editor: ProfileV3AppCredentialsViewModel, confirming: Bool) {
        guard self.editor === editor else { return }
        sheet = confirming ? .deleteConfirm(editor) : .editor(editor)
    }

    private func finishEditing() {
        sheet = nil
        saveCompletions += 1
        load()
    }

    private func finishDeleting() {
        sheet = nil
        deleteCompletions += 1
        load()
    }

    private func openExisting(_ id: String) {
        guard let entry = rows.first(where: { $0.id == id }) else {
            load()
            return
        }
        open(entry)
    }
}
