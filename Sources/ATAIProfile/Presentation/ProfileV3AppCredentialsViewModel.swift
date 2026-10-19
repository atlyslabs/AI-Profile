import Combine
import Foundation
import UIKit

@MainActor
final class ProfileV3AppCredentialsViewModel: ObservableObject, Identifiable {
    enum Mode: Equatable {
        case add(ProfileV3LinkedApp)
        case newPassword
        case edit(ProfileV3LinkedApp)
        case vaultSite(ProfileV3VaultSite)
        case vaultCustom
        case vaultEdit(ProfileV3VaultCredential)
    }

    enum Origin: Equatable {
        case page
        case panel
    }

    enum Phase: Equatable {
        case editing
        case submitting
        case succeeded
    }

    let id = UUID()
    let mode: Mode
    let origin: Origin
    @Published var credentials: ProfileV3AppCredentials
    @Published var label = ""
    @Published var isPasswordRevealed = false
    @Published private(set) var isRevealingPassword = false
    @Published private(set) var phase: Phase = .editing

    var onFinish: (() -> Void)?
    var onFailure: ((String) -> Void)?
    var onAlreadySaved: ((String) -> Void)?
    private(set) var savedID: String?

    private let repository: any ProfileV3AppAccessRepository
    private var submitTask: Task<Void, Never>?
    private var revealTask: Task<Void, Never>?
    private var hideTask: Task<Void, Never>?

    init(mode: Mode, origin: Origin, repository: any ProfileV3AppAccessRepository) {
        self.mode = mode
        self.origin = origin
        self.repository = repository
        switch mode {
        case .edit(let app):
            credentials = ProfileV3AppCredentials(username: app.username ?? "")
        case .vaultEdit(let entry):
            credentials = ProfileV3AppCredentials(username: entry.username ?? "")
        case .vaultCustom:
            credentials = ProfileV3AppCredentials()
        default:
            credentials = ProfileV3AppCredentials()
        }
    }

    var app: ProfileV3LinkedApp? {
        switch mode {
        case .add(let app), .edit(let app): return app
        case .newPassword, .vaultSite, .vaultCustom, .vaultEdit: return nil
        }
    }

    var asksForWebsite: Bool {
        if case .newPassword = mode { return true }
        if case .vaultCustom = mode { return true }
        return false
    }

    var asksForLabel: Bool {
        if case .vaultCustom = mode { return true }
        return false
    }

    var isEditing: Bool {
        switch mode {
        case .edit, .vaultEdit: return true
        case .add, .newPassword, .vaultSite, .vaultCustom: return false
        }
    }

    var title: String {
        switch mode {
        case .vaultSite(let site): return site.displayName
        case .vaultCustom: return ProfileV3VaultStrings.addLogin
        case .vaultEdit: return ProfileV3Strings.appCredentialsTitle
        case .newPassword: return ProfileV3Strings.appPasswordTitle
        case .add, .edit: return ProfileV3Strings.appCredentialsTitle
        }
    }

    var submitTitle: String {
        switch mode {
        case .add, .vaultSite, .vaultCustom: return ProfileV3Strings.appCredentialsAdd
        case .newPassword: return ProfileV3Strings.continueTitle
        case .edit, .vaultEdit: return ProfileV3Strings.saveChanges
        }
    }

    var successMessage: String {
        isEditing ? ProfileV3Strings.appCredentialsUpdated : ProfileV3Strings.appPasswordAdded
    }

    var canSubmit: Bool {
        let value = credentials.trimmed
        guard phase == .editing, !value.username.isEmpty else { return false }
        if asksForLabel, label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        if asksForWebsite, value.websiteURL == nil { return false }
        if case .vaultEdit(let entry) = mode, value.password.isEmpty {
            return value.username != (entry.username ?? "")
        }
        return !value.password.isEmpty
    }

    var savePhase: ProfileV3SavePhase {
        switch phase {
        case .editing: return .idle
        case .submitting: return .saving
        case .succeeded: return .saved
        }
    }

    func togglePasswordVisibility() {
        if case .vaultEdit(let entry) = mode, credentials.password.isEmpty {
            revealStoredPassword(entry.id)
            return
        }
        isPasswordRevealed.toggle()
    }

    func hideStoredPassword() {
        guard case .vaultEdit = mode else { return }
        hideTask?.cancel()
        credentials.password = ""
        isPasswordRevealed = false
    }

    func submit() {
        guard canSubmit else { return }
        phase = .submitting
        let credentials = credentials.trimmed
        let label = label.trimmingCharacters(in: .whitespacesAndNewlines)
        let mode = mode
        let repository = repository
        submitTask = Task { [weak self] in
            do {
                let saved: String?
                switch mode {
                case .add(let app), .edit(let app):
                    try await repository.saveAppCredentials(credentials, appID: app.id)
                    saved = nil
                case .newPassword:
                    try await repository.addAppPassword(credentials)
                    saved = nil
                case .vaultSite(let site):
                    let result = try await repository.saveVault(ProfileV3VaultDraft(
                        siteSlug: site.slug,
                        username: credentials.username,
                        password: credentials.password
                    ))
                    saved = result.id
                case .vaultCustom:
                    let result = try await repository.saveVault(ProfileV3VaultDraft(
                        label: label,
                        url: credentials.websiteURL?.absoluteString,
                        username: credentials.username,
                        password: credentials.password
                    ))
                    saved = result.id
                case .vaultEdit(let entry):
                    let draft = ProfileV3VaultDraft(
                        siteSlug: nil,
                        label: nil,
                        url: nil,
                        username: credentials.username == entry.username ? nil : credentials.username,
                        password: credentials.password.isEmpty ? nil : credentials.password
                    )
                    let result = try await repository.updateVault(id: entry.id, draft: draft)
                    saved = result.id
                }
                guard let self, !Task.isCancelled else { return }
                savedID = saved
                phase = .succeeded
                try await Task.sleep(for: .seconds(ProfileV3Theme.Motion.appCredentialsSuccessSeconds))
                guard !Task.isCancelled else { return }
                onFinish?()
            } catch let saved as ProfileV3VaultAlreadySaved {
                guard let self, !Task.isCancelled else { return }
                phase = .editing
                onAlreadySaved?(saved.id)
                onFailure?(saved.message)
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                phase = .editing
                onFailure?(ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed))
            }
        }
    }

    func cancel() {
        submitTask?.cancel()
        revealTask?.cancel()
        hideTask?.cancel()
    }

    private func revealStoredPassword(_ id: String) {
        guard !isRevealingPassword, phase == .editing else { return }
        isRevealingPassword = true
        let repository = repository
        revealTask = Task { [weak self] in
            do {
                let password = try await repository.revealVaultPassword(id: id, deviceName: UIDevice.current.name)
                guard let self, !Task.isCancelled else { return }
                credentials.password = password
                isPasswordRevealed = true
                isRevealingPassword = false
                scheduleHide()
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                isRevealingPassword = false
                onFailure?(ProfileV3Error.message(for: error))
            }
        }
    }

    private func scheduleHide() {
        hideTask?.cancel()
        hideTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(30))
            guard !Task.isCancelled else { return }
            self?.hideStoredPassword()
        }
    }
}
