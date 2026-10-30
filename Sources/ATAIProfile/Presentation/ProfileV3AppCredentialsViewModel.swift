import Combine
import Foundation
import LocalAuthentication
import UIKit

@MainActor
final class ProfileV3AppCredentialsViewModel: ObservableObject, Identifiable {
    enum Mode: Equatable {
        case add(ProfileV3LinkedApp)
        case newPassword
        case edit(ProfileV3LinkedApp)
        case vaultNew(site: ProfileV3VaultSite? = nil, website: String = "")
        case vaultEdit(ProfileV3VaultCredential)
    }

    enum Origin: Equatable {
        case page
        case panel
    }

    let id = UUID()
    let mode: Mode
    let origin: Origin
    @Published var credentials: ProfileV3AppCredentials {
        didSet { if inlineError != nil { inlineError = nil } }
    }
    @Published var isPasswordRevealed = false
    @Published private(set) var isRevealingPassword = false
    @Published private(set) var inlineError: String?
    @Published private(set) var phase: ProfileV3SavePhase = .idle
    @Published private(set) var isConfirmingDelete = false {
        didSet {
            guard isConfirmingDelete != oldValue else { return }
            onConfirmingDeleteChange?(isConfirmingDelete)
        }
    }
    @Published private(set) var isDeleting = false

    var onFinish: (() -> Void)?
    var onFailure: ((String) -> Void)?
    var onAlreadySaved: ((String) -> Void)?
    var onDeleted: (() -> Void)?
    var onConfirmingDeleteChange: ((Bool) -> Void)?
    private(set) var savedID: String?

    private let repository: any ProfileV3AppAccessRepository
    private var storedPassword: String?
    private var submitTask: Task<Void, Never>?
    private var revealTask: Task<Void, Never>?
    private var hideTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?

    init(mode: Mode, origin: Origin, repository: any ProfileV3AppAccessRepository) {
        self.mode = mode
        self.origin = origin
        self.repository = repository
        switch mode {
        case .edit(let app):
            credentials = ProfileV3AppCredentials(username: app.username ?? "")
        case .vaultEdit(let entry):
            credentials = ProfileV3AppCredentials(website: entry.displayURL ?? "", username: entry.username ?? "")
        case .vaultNew(let site, let website):
            let link = site?.loginURL.flatMap(ProfileV3VaultSite.displayAddress)
            credentials = ProfileV3AppCredentials(website: link ?? website.trimmingCharacters(in: .whitespacesAndNewlines))
        case .add, .newPassword:
            credentials = ProfileV3AppCredentials()
        }
    }

    var app: ProfileV3LinkedApp? {
        switch mode {
        case .add(let app), .edit(let app): return app
        case .newPassword, .vaultNew, .vaultEdit: return nil
        }
    }

    var asksForWebsite: Bool {
        switch mode {
        case .newPassword, .vaultNew: return true
        case .add, .edit, .vaultEdit: return false
        }
    }

    var showsWebsite: Bool {
        asksForWebsite || (canDelete && !credentials.website.isEmpty)
    }

    var asksForPassword: Bool {
        app?.asksForUsernameOnly != true
    }

    var usernameLabel: String {
        asksForPassword ? ProfileV3Strings.appCredentialsUsername : ProfileV3Strings.appUsernameLabel
    }

    var showsHeader: Bool {
        !canDelete
    }

    var canDelete: Bool {
        if case .vaultEdit = mode { return true }
        return false
    }

    var showsSaveButton: Bool {
        !canDelete || canSubmit || phase != .idle
    }

    var passwordPrompt: String? {
        isEditing ? ProfileV3VaultStrings.passwordHidden : nil
    }

    var deleteSubject: String? {
        if case .vaultEdit(let entry) = mode { return entry.displayURL ?? entry.displayName }
        return nil
    }

    var isEditing: Bool {
        switch mode {
        case .edit, .vaultEdit: return true
        case .add, .newPassword, .vaultNew: return false
        }
    }

    private var isVault: Bool {
        switch mode {
        case .vaultNew, .vaultEdit: return true
        case .add, .newPassword, .edit: return false
        }
    }

    var title: String {
        guard asksForPassword else { return ProfileV3Strings.appUsernameTitle }
        switch mode {
        case .newPassword, .vaultNew: return ProfileV3Strings.appPasswordTitle
        case .add, .edit, .vaultEdit: return ProfileV3Strings.appCredentialsTitle
        }
    }

    var submitTitle: String {
        switch mode {
        case .add: return ProfileV3Strings.appCredentialsAdd
        case .newPassword, .vaultNew: return ProfileV3Strings.continueTitle
        case .edit, .vaultEdit: return ProfileV3Strings.saveChanges
        }
    }

    var successMessage: String {
        isEditing ? ProfileV3Strings.appCredentialsUpdated : ProfileV3Strings.appPasswordAdded
    }

    var canSubmit: Bool {
        let value = credentials.trimmed
        guard phase == .idle, !value.username.isEmpty else { return false }
        if asksForWebsite, value.websiteURL == nil { return false }
        if case .vaultEdit(let entry) = mode, newPassword.isEmpty {
            return value.username != (entry.username ?? "")
        }
        guard asksForPassword else {
            let username = app?.isInstagram == true ? ProfileV3InstagramUsername.normalised(value.username) : value.username
            if case .edit(let app) = mode { return username != (app.username ?? "") }
            return true
        }
        return !value.password.isEmpty
    }

    private var newPassword: String {
        credentials.password == storedPassword ? "" : credentials.password
    }

    func togglePasswordVisibility() {
        inlineError = nil
        if case .vaultEdit(let entry) = mode {
            if credentials.password.isEmpty {
                revealStoredPassword(entry.id)
                return
            }
            if storedPassword != nil, newPassword.isEmpty {
                hidePassword()
                return
            }
        }
        isPasswordRevealed.toggle()
    }

    func hidePassword() {
        hideTask?.cancel()
        if storedPassword != nil, newPassword.isEmpty {
            credentials.password = ""
        }
        storedPassword = nil
        isPasswordRevealed = false
    }

    func pasteboardChanged() {
        guard let storedPassword, newPassword.isEmpty else { return }
        ProfileV3VaultClipboard.expire(storedPassword)
    }

    func openWebsite() -> URL? {
        guard let url = credentials.websiteURL else { return nil }
        switch mode {
        case .vaultNew(let site, _):
            let picked = site.flatMap { ProfileV3VaultSite.matching(url, in: [$0]) }
            ProfileV3Analytics.passVaultWebsiteClicked(url, cardName: picked?.displayName)
        case .vaultEdit(let entry):
            ProfileV3Analytics.passVaultWebsiteClicked(url, cardName: entry.displayName)
        case .add, .newPassword, .edit:
            break
        }
        return url
    }

    func askToDelete() {
        guard canDelete, phase == .idle else { return }
        hidePassword()
        inlineError = nil
        isConfirmingDelete = true
    }

    func cancelDelete() {
        guard !isDeleting else { return }
        isConfirmingDelete = false
    }

    func confirmDelete() {
        guard case .vaultEdit(let entry) = mode, !isDeleting else { return }
        isDeleting = true
        let repository = repository
        deleteTask = Task { [weak self] in
            do {
                try await repository.deleteVaultCredential(id: entry.id)
                guard let self, !Task.isCancelled else { return }
                isDeleting = false
                onDeleted?()
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                isDeleting = false
                isConfirmingDelete = false
                fail(ProfileV3Error.message(for: error, fallback: ProfileV3Strings.disconnectFailed))
            }
        }
    }

    func submit() {
        guard canSubmit else { return }
        let linksInstagram = app?.isInstagram == true
        let instagramUsername = ProfileV3InstagramUsername.normalised(credentials.username)
        if linksInstagram, !ProfileV3InstagramUsername.isValid(instagramUsername) {
            fail(ProfileV3Strings.instagramUsernameInvalid)
            return
        }
        phase = .saving
        inlineError = nil
        let credentials = credentials.trimmed
        let newPassword = newPassword
        let mode = mode
        let repository = repository
        submitTask = Task { [weak self] in
            do {
                let saved: String?
                switch mode {
                case .add(let app), .edit(let app):
                    if linksInstagram {
                        _ = try await repository.linkInstagram(username: instagramUsername)
                    } else {
                        try await repository.saveAppCredentials(credentials, appID: app.id)
                    }
                    saved = nil
                case .newPassword:
                    try await repository.addAppPassword(credentials)
                    saved = nil
                case .vaultNew(let site, _):
                    var sites = site.map { [$0] } ?? []
                    if site == nil {
                        sites = (try? await repository.loadVaultSites()) ?? []
                    }
                    let draft = ProfileV3VaultDraft.new(credentials, sites: sites)
                    saved = try await repository.saveVault(draft).id
                    ProfileV3Analytics.passVaultCredentialsAdded(credentials, sites: sites)
                case .vaultEdit(let entry):
                    let draft = ProfileV3VaultDraft(
                        username: credentials.username == entry.username ? nil : credentials.username,
                        password: newPassword.isEmpty ? nil : newPassword
                    )
                    saved = try await repository.updateVault(id: entry.id, draft: draft).id
                }
                guard let self, !Task.isCancelled else { return }
                savedID = saved
                phase = .saved
                try await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.savedDismissMilliseconds))
                guard !Task.isCancelled else { return }
                onFinish?()
            } catch let saved as ProfileV3VaultAlreadySaved {
                guard let self, !Task.isCancelled else { return }
                phase = .idle
                onAlreadySaved?(saved.id)
                fail(saved.message)
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                phase = .idle
                fail(
                    linksInstagram
                        ? ProfileV3InstagramUsername.errorMessage(for: error)
                        : ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed)
                )
            }
        }
    }

    func cancel() {
        submitTask?.cancel()
        revealTask?.cancel()
        hideTask?.cancel()
        deleteTask?.cancel()
    }

    private func fail(_ message: String) {
        if isVault || app?.isInstagram == true { inlineError = message }
        onFailure?(message)
    }

    private func revealStoredPassword(_ id: String) {
        guard !isRevealingPassword, phase == .idle else { return }
        isRevealingPassword = true
        let repository = repository
        revealTask = Task { [weak self] in
            do {
                let password = try await repository.revealVaultPassword(id: id, deviceName: UIDevice.current.name)
                guard let self, !Task.isCancelled else { return }
                storedPassword = password
                credentials.password = password
                isPasswordRevealed = true
                isRevealingPassword = false
                scheduleHide()
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                isRevealingPassword = false
                inlineError = Self.revealMessage(for: error)
            }
        }
    }

    private static func revealMessage(for error: Error) -> String? {
        if let error = error as? LAError, [.userCancel, .appCancel, .systemCancel].contains(error.code) {
            return nil
        }
        return ProfileV3Error.message(for: error)
    }

    private func scheduleHide() {
        hideTask?.cancel()
        hideTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(ProfileV3VaultClipboard.lifetime))
            guard !Task.isCancelled else { return }
            self?.hidePassword()
        }
    }
}
