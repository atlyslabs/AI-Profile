import Foundation
import LocalAuthentication
import os
import SwiftUI
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
@Suite("Vault login")
struct ProfileV3VaultLoginTests {
    private static let saved = ProfileV3VaultCredential(
        id: "fd2c2c21-abdf-4f43-ba4a-3a1b9a374af1",
        displayName: "Singapore Airlines KrisFlyer",
        url: "https://www.singaporeair.com/en_UK/ppsclub-krisflyer/",
        status: .live,
        usernameHint: "so*****@gmail.com",
        username: "someone@gmail.com"
    )

    private static let krisFlyer = ProfileV3VaultSite(
        slug: "singapore_airlines",
        displayName: "Singapore Airlines KrisFlyer",
        loginURL: "https://www.singaporeair.com/en_UK/ppsclub-krisflyer/"
    )

    private static let hdfc = ProfileV3VaultSite(
        slug: "hdfc_bank",
        displayName: "HDFC Bank",
        loginURL: "https://netbanking.hdfcbank.com/netbanking/"
    )

    @Test func openingUnlocksFirstThenShowsAndLoadsTheVault() async throws {
        let vault = VaultStub(entries: [Self.saved])
        let asks = UnlockCounter()
        let model = ProfileV3CredentialStoreModel(repository: vault) {
            await asks.ask()
            try? await Task.sleep(for: .milliseconds(100))
            return .unlocked
        }

        model.open()
        model.open()
        #expect(model.isUnlocking)
        #expect(!model.isPresented)
        #expect(await vault.listCalls == 0)

        try await waitUntil { model.isPresented }
        #expect(!model.isUnlocking)
        try await waitUntil { model.phase == .loaded }
        #expect(model.rows.map(\.id) == [Self.saved.id])
        #expect(await vault.listCalls == 1)
        #expect(await asks.count == 1)
    }

    @Test func cancellingTheUnlockKeepsTheVaultClosed() async throws {
        let vault = VaultStub(entries: [Self.saved])
        let model = ProfileV3CredentialStoreModel(repository: vault, unlock: { .cancelled })

        model.open()
        try await waitUntil { !model.isUnlocking }

        #expect(!model.isPresented)
        #expect(model.entries == nil)
        #expect(await vault.listCalls == 0)

        model.open()
        #expect(model.isUnlocking)
    }

    @Test func closingTheVaultOrLeavingTheAppEndsItsFaceIDSession() async throws {
        let vault = VaultStub(entries: [Self.saved])
        let locks = LockCounter()
        let model = ProfileV3CredentialStoreModel(repository: vault, unlock: { .unlocked }, lock: { locks.lock() })
        model.open()
        try await waitUntil { model.isPresented }
        #expect(locks.count == 0)

        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        #expect(locks.count == 1)

        model.cancelReads()
        #expect(locks.count == 2)
    }

    @Test func storeListsSavedLoginsAndOpensOneWithItsFullUsername() async throws {
        let vault = VaultStub(entries: [Self.saved])
        let model = ProfileV3CredentialStoreModel(repository: vault, unlock: { .unlocked })
        model.open()
        try await waitUntil { model.isPresented }
        try await waitUntil { model.phase == .loaded }
        let row = try #require(model.rows.first)
        #expect(row.displayName == "Singapore Airlines KrisFlyer")
        #expect(row.username == nil)

        model.open(row)
        #expect(model.openingID == row.id)
        try await waitUntil { model.editor != nil }
        let editor = try #require(model.editor)

        #expect(model.openingID == nil)
        #expect(await vault.reads == [.init(id: Self.saved.id, includeUsername: true)])
        #expect(!editor.showsHeader)
        #expect(editor.showsWebsite)
        #expect(!editor.asksForWebsite)
        #expect(editor.credentials.website == "singaporeair.com/en_UK/ppsclub-krisflyer")
        #expect(editor.credentials.websiteURL?.absoluteString == "https://singaporeair.com/en_UK/ppsclub-krisflyer")
        #expect(editor.credentials.username == "someone@gmail.com")
        #expect(editor.credentials.password.isEmpty)
        #expect(editor.passwordPrompt == ProfileV3VaultStrings.passwordHidden)
        #expect(editor.canDelete)
        #expect(!editor.canSubmit)
        #expect(!editor.showsSaveButton)
    }

    @Test func saveButtonShowsOnlyOnceSomethingChanged() {
        let editor = ProfileV3AppCredentialsViewModel(mode: .vaultEdit(Self.saved), origin: .page, repository: VaultStub(entries: []))
        #expect(!editor.showsSaveButton)
        editor.credentials.username = "new@gmail.com"
        #expect(editor.showsSaveButton)
        editor.credentials.username = "someone@gmail.com"
        #expect(!editor.showsSaveButton)
        editor.credentials.password = "new-password"
        #expect(editor.showsSaveButton)
    }

    @Test func revealedPasswordIsNotAChangeAndHidesWithoutLosingAnEdit() async throws {
        let vault = VaultStub(entries: [Self.saved], password: "hunter2")
        let editor = ProfileV3AppCredentialsViewModel(mode: .vaultEdit(Self.saved), origin: .page, repository: vault)

        editor.togglePasswordVisibility()
        try await waitUntil { editor.isPasswordRevealed }
        #expect(editor.credentials.password == "hunter2")
        #expect(!editor.canSubmit)
        #expect(!editor.showsSaveButton)

        editor.togglePasswordVisibility()
        #expect(editor.credentials.password.isEmpty)
        #expect(!editor.isPasswordRevealed)

        editor.togglePasswordVisibility()
        try await waitUntil { editor.isPasswordRevealed }
        editor.credentials.password = "new-password"
        #expect(editor.canSubmit)
        editor.hidePassword()
        #expect(editor.credentials.password == "new-password")
        #expect(!editor.isPasswordRevealed)

        editor.submit()
        try await waitUntil { editor.phase == .saved }
        #expect(await vault.updates == [.init(id: Self.saved.id, username: nil, password: "new-password")])
    }

    @Test func savingTheRevealedPasswordUnchangedSendsOnlyTheUsername() async throws {
        let vault = VaultStub(entries: [Self.saved], password: "hunter2")
        let editor = ProfileV3AppCredentialsViewModel(mode: .vaultEdit(Self.saved), origin: .page, repository: vault)

        editor.togglePasswordVisibility()
        try await waitUntil { editor.isPasswordRevealed }
        editor.credentials.username = "new@gmail.com"
        editor.submit()
        try await waitUntil { editor.phase == .saved }

        #expect(await vault.updates == [.init(id: Self.saved.id, username: "new@gmail.com", password: nil)])
    }

    @Test func failedRevealSaysWhyInTheSheetAndStaysHidden() async throws {
        let refusal = ProfileV3Error.server(code: "reauth", message: ProfileV3VaultStrings.confirmItsYou)
        let vault = VaultStub(entries: [Self.saved], revealFailure: refusal)
        let editor = ProfileV3AppCredentialsViewModel(mode: .vaultEdit(Self.saved), origin: .page, repository: vault)
        var flashed: String?
        editor.onFailure = { flashed = $0 }

        editor.togglePasswordVisibility()
        #expect(editor.isRevealingPassword)
        try await waitUntil { !editor.isRevealingPassword }

        #expect(editor.inlineError == ProfileV3VaultStrings.confirmItsYou)
        #expect(!editor.isPasswordRevealed)
        #expect(editor.credentials.password.isEmpty)
        #expect(flashed == nil)

        editor.togglePasswordVisibility()
        #expect(editor.inlineError == nil)
        try await waitUntil { editor.inlineError != nil }
    }

    @Test func cancelledFaceIDLeavesNoError() async throws {
        let vault = VaultStub(entries: [Self.saved], revealFailure: LAError(.userCancel))
        let editor = ProfileV3AppCredentialsViewModel(mode: .vaultEdit(Self.saved), origin: .page, repository: vault)

        editor.togglePasswordVisibility()
        try await waitUntil { !editor.isRevealingPassword }

        #expect(editor.inlineError == nil)
        #expect(!editor.isPasswordRevealed)
    }

    @Test func deleteAsksFirstThenRemovesTheLogin() async throws {
        let vault = VaultStub(entries: [Self.saved])
        let model = ProfileV3CredentialStoreModel(repository: vault, unlock: { .unlocked })
        model.open()
        try await waitUntil { model.phase == .loaded }
        model.open(try #require(model.rows.first))
        try await waitUntil { model.editor != nil }
        let editor = try #require(model.editor)
        #expect(editor.deleteSubject == "singaporeair.com/en_UK/ppsclub-krisflyer")

        editor.askToDelete()
        #expect(editor.isConfirmingDelete)
        #expect(model.isConfirmingDelete)
        #expect(model.editor === editor)
        editor.cancelDelete()
        #expect(!editor.isConfirmingDelete)
        #expect(!model.isConfirmingDelete)
        #expect(model.editor === editor)
        #expect(await vault.deleted.isEmpty)

        editor.askToDelete()
        #expect(model.isConfirmingDelete)
        editor.confirmDelete()
        #expect(editor.isDeleting)
        try await waitUntil { model.sheet == nil }
        try await waitUntil { model.rows.isEmpty }

        #expect(await vault.deleted == [Self.saved.id])
        #expect(model.deleteCompletions == 1)
    }

    @Test func aRefusedDeleteReturnsToTheLoginAndClosingTheConfirmClosesBoth() async throws {
        let vault = VaultStub(entries: [Self.saved], refusesDelete: true)
        let model = ProfileV3CredentialStoreModel(repository: vault, unlock: { .unlocked })
        model.open()
        try await waitUntil { model.phase == .loaded }
        model.open(try #require(model.rows.first))
        try await waitUntil { model.editor != nil }
        let editor = try #require(model.editor)

        editor.askToDelete()
        editor.confirmDelete()
        try await waitUntil { editor.inlineError != nil }
        #expect(!model.isConfirmingDelete)
        #expect(model.editor === editor)
        #expect(model.deleteCompletions == 0)

        editor.askToDelete()
        #expect(model.isConfirmingDelete)
        model.closeSheet()
        #expect(model.sheet == nil)
        #expect(await vault.deleted.isEmpty)
    }

    @Test func refusedDeleteKeepsTheLoginAndSaysWhy() async throws {
        let vault = VaultStub(entries: [Self.saved], refusesDelete: true)
        let editor = ProfileV3AppCredentialsViewModel(mode: .vaultEdit(Self.saved), origin: .page, repository: vault)
        var deleted = false
        editor.onDeleted = { deleted = true }

        editor.askToDelete()
        editor.confirmDelete()
        try await waitUntil { editor.inlineError != nil }

        #expect(editor.inlineError == "vault unavailable")
        #expect(!deleted)
        #expect(!editor.isDeleting)
        #expect(!editor.isConfirmingDelete)
    }

    @Test func addOpensThePickerAndAPickedSiteFillsTheWebsite() async throws {
        let vault = VaultStub(entries: [], sites: [Self.krisFlyer, Self.hdfc])
        let model = ProfileV3CredentialStoreModel(repository: vault, unlock: { .unlocked })
        model.open()
        try await waitUntil { model.phase == .loaded }

        model.tapAdd()
        #expect(model.isPickingSite)
        #expect(model.editor == nil)
        try await waitUntil { model.sitesPhase == .loaded }
        #expect(model.sites(matching: "").map(\.slug) == ["hdfc_bank", "singapore_airlines"])
        #expect(model.sites(matching: "kris").map(\.slug) == ["singapore_airlines"])
        #expect(model.sites(matching: "hdfcbank.com").map(\.slug) == ["hdfc_bank"])
        #expect(model.sites(matching: "zzz").isEmpty)

        model.pick(Self.krisFlyer)
        #expect(!model.isPickingSite)
        let editor = try #require(model.editor)
        #expect(editor.showsHeader)
        #expect(editor.asksForWebsite)
        #expect(!editor.canDelete)
        #expect(editor.title == ProfileV3Strings.appPasswordTitle)
        #expect(editor.submitTitle == ProfileV3Strings.continueTitle)
        #expect(editor.successMessage == ProfileV3Strings.appPasswordAdded)
        #expect(editor.credentials.website == "singaporeair.com/en_UK/ppsclub-krisflyer")
        editor.credentials.username = "someone@gmail.com"
        editor.credentials.password = "hunter2"
        #expect(editor.canSubmit)

        editor.submit()
        try await waitUntil { model.editor == nil }

        #expect(await vault.saves == [
            ProfileV3VaultDraft(siteSlug: "singapore_airlines", username: "someone@gmail.com", password: "hunter2"),
        ])
        #expect(model.saveCompletions == 1)
        try await waitUntil { model.rows.map(\.displayName) == ["Singapore Airlines KrisFlyer"] }
    }

    @Test func closingThePickerAddsNothing() async throws {
        let model = ProfileV3CredentialStoreModel(repository: VaultStub(entries: [], sites: [Self.krisFlyer]), unlock: { .unlocked })
        model.tapAdd()
        #expect(model.isPickingSite)
        model.closeSheet()
        #expect(model.sheet == nil)
    }

    @Test func otherWebsiteCarriesTheSearchAndSendsItsHostAndAddress() async throws {
        let vault = VaultStub(entries: [], sites: [Self.krisFlyer])
        let model = ProfileV3CredentialStoreModel(repository: vault, unlock: { .unlocked })
        model.tapAdd()
        model.pickOtherWebsite("  www.HDFCbank.in/ways-to-bank ")
        let editor = try #require(model.editor)
        #expect(editor.credentials.website == "www.HDFCbank.in/ways-to-bank")
        editor.credentials.username = "6FGH43H"
        editor.credentials.password = "secret"

        editor.submit()
        try await waitUntil { editor.phase == .saved }

        #expect(await vault.saves == [
            ProfileV3VaultDraft(
                label: "hdfcbank.in",
                url: "https://www.HDFCbank.in/ways-to-bank",
                username: "6FGH43H",
                password: "secret"
            ),
        ])
    }

    @Test func aLoginSavedBeforeOpensForEditing() async throws {
        let vault = VaultStub(entries: [Self.saved], sites: [Self.krisFlyer])
        let model = ProfileV3CredentialStoreModel(repository: vault, unlock: { .unlocked })
        model.open()
        try await waitUntil { model.phase == .loaded }

        model.tapAdd()
        model.pick(Self.krisFlyer)
        let adding = try #require(model.editor)
        adding.credentials.username = "someone@gmail.com"
        adding.credentials.password = "x"
        adding.submit()
        try await waitUntil { model.editor?.canDelete == true }

        #expect(adding.inlineError?.contains(Self.saved.id) == true)
        if case .vaultEdit(let entry) = model.editor?.mode {
            #expect(entry.id == Self.saved.id)
        } else {
            Issue.record("expected the saved login to open")
        }
    }

    @Test func websitesMatchSitesByHostAndShowWithoutTheScheme() throws {
        let site = Self.krisFlyer
        let url = { (text: String) in try #require(ProfileV3AppCredentials(website: text).websiteURL) }
        #expect(ProfileV3VaultSite.matching(try url("singaporeair.com"), in: [site]) == site)
        #expect(ProfileV3VaultSite.matching(try url("https://www.singaporeair.com/login"), in: [site]) == site)
        #expect(ProfileV3VaultSite.matching(try url("krisflyer.singaporeair.com"), in: [site]) == site)
        #expect(ProfileV3VaultSite.matching(try url("notsingaporeair.com"), in: [site]) == nil)
        #expect(ProfileV3VaultSite.matching(try url("hdfcbank.in"), in: [site]) == nil)
        #expect(ProfileV3VaultSite.displayAddress("https://www.abc.com/") == "abc.com")
        #expect(ProfileV3VaultSite.displayAddress("http://hdfcbank.in/ways") == "hdfcbank.in/ways")
        #expect(ProfileV3VaultSite.displayAddress("  ") == nil)
    }

    @Test func copiedPasswordExpiresAndOtherCopiesAreLeftAlone() async throws {
        let board = UIPasteboard.withUniqueName()
        defer { UIPasteboard.remove(withName: board.name) }

        board.string = "someone@gmail.com"
        ProfileV3VaultClipboard.expire("hunter2", after: 0.2, pasteboard: board)
        #expect(board.string == "someone@gmail.com")

        board.string = "hunter2"
        ProfileV3VaultClipboard.expire("hunter2", after: 0.2, pasteboard: board)
        #expect(board.string == "hunter2")
        try await waitUntil { !board.hasStrings }
    }

    @Test func vaultLoginFieldsAreNotOfferedToTheKeychain() async throws {
        let loginTypes: Set<UITextContentType> = [.username, .password, .newPassword]
        for mode in [ProfileV3AppCredentialsViewModel.Mode.vaultNew(), .vaultEdit(Self.saved)] {
            let editor = ProfileV3AppCredentialsViewModel(mode: mode, origin: .page, repository: VaultStub(entries: []))
            let host = UIHostingController(rootView: ProfileV3AppCredentialsView(viewModel: editor, onClose: {}))
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 440, height: 956))
            window.rootViewController = host
            window.makeKeyAndVisible()
            host.view.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(100))

            let fields = Self.textFields(in: window)
            let tagged = fields.compactMap(\.textContentType).filter(loginTypes.contains)
            let secure = fields.filter(\.isSecureTextEntry)
            #expect(fields.count >= 2)
            #expect(tagged.isEmpty)
            #expect(secure.count == 1)
            #expect(secure.first?.textContentType == .oneTimeCode)
        }
    }

    private static func textFields(in view: UIView) -> [UITextField] {
        ((view as? UITextField).map { [$0] } ?? []) + view.subviews.flatMap { textFields(in: $0) }
    }

    private func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

private actor UnlockCounter {
    private(set) var count = 0

    func ask() {
        count += 1
    }
}

private final class LockCounter: Sendable {
    private let state = OSAllocatedUnfairLock(initialState: 0)

    var count: Int { state.withLock { $0 } }

    func lock() {
        state.withLock { $0 += 1 }
    }
}

private actor VaultStub: ProfileV3AppAccessRepository {
    struct Read: Equatable {
        let id: String
        let includeUsername: Bool
    }

    struct Update: Equatable {
        let id: String
        let username: String?
        let password: String?
    }

    private var entries: [ProfileV3VaultCredential]
    private let sites: [ProfileV3VaultSite]
    private let password: String
    private let revealFailure: (any Error)?
    private let refusesDelete: Bool
    private(set) var reads: [Read] = []
    private(set) var updates: [Update] = []
    private(set) var saves: [ProfileV3VaultDraft] = []
    private(set) var deleted: [String] = []
    private(set) var listCalls = 0

    init(
        entries: [ProfileV3VaultCredential],
        sites: [ProfileV3VaultSite] = [],
        password: String = "",
        revealFailure: (any Error)? = nil,
        refusesDelete: Bool = false
    ) {
        self.entries = entries
        self.sites = sites
        self.password = password
        self.revealFailure = revealFailure
        self.refusesDelete = refusesDelete
    }

    func loadVaultCredentials() async throws -> [ProfileV3VaultCredential] {
        listCalls += 1
        return entries.map { entry in
            var row = entry
            row.username = nil
            return row
        }
    }

    func loadVaultSites() async throws -> [ProfileV3VaultSite] { sites }

    func vaultCredential(id: String, includeUsername: Bool) async throws -> ProfileV3VaultCredential {
        reads.append(Read(id: id, includeUsername: includeUsername))
        guard var entry = entries.first(where: { $0.id == id }) else { throw ProfileV3RepositoryError.unavailable }
        if !includeUsername { entry.username = nil }
        return entry
    }

    func saveVault(_ draft: ProfileV3VaultDraft) async throws -> ProfileV3VaultWriteResult {
        saves.append(draft)
        if draft.siteSlug != nil, let existing = entries.first {
            throw ProfileV3VaultAlreadySaved(
                id: existing.id,
                message: "already saved for this service; edit or delete credential \(existing.id)"
            )
        }
        let site = sites.first { $0.slug == draft.siteSlug }
        let id = "saved-\(saves.count)"
        entries.append(ProfileV3VaultCredential(
            id: id,
            displayName: site?.displayName ?? draft.label ?? "",
            url: site?.loginURL ?? draft.url,
            status: .added,
            username: draft.username
        ))
        return ProfileV3VaultWriteResult(id: id, status: .added)
    }

    func updateVault(id: String, draft: ProfileV3VaultDraft) async throws -> ProfileV3VaultWriteResult {
        updates.append(Update(id: id, username: draft.username, password: draft.password))
        return ProfileV3VaultWriteResult(id: id, status: .added)
    }

    func deleteVaultCredential(id: String) async throws {
        if refusesDelete { throw ProfileV3Error.server(code: nil, message: "vault unavailable") }
        deleted.append(id)
        entries.removeAll { $0.id == id }
    }

    func revealVaultPassword(id _: String, deviceName _: String) async throws -> String {
        try await Task.sleep(for: .milliseconds(20))
        if let revealFailure { throw revealFailure }
        return password
    }

    func loadAppAccess() async throws -> ProfileV3AppAccess {
        ProfileV3AppAccess(autoConnected: [], apps: [])
    }

    func saveAppCredentials(_: ProfileV3AppCredentials, appID _: String) async throws {}
    func addAppPassword(_: ProfileV3AppCredentials) async throws {}
    func disconnectApp(_: String) async throws {}
    func loadInstagramAccount() async throws -> ProfileV3InstagramAccount { .unlinked }
    func linkInstagram(username: String) async throws -> String { username }

    func retestVaultCredential(id: String) async throws -> ProfileV3VaultWriteResult {
        ProfileV3VaultWriteResult(id: id, status: .added)
    }

    func pauseVaultCredential(id: String) async throws -> ProfileV3VaultWriteResult {
        ProfileV3VaultWriteResult(id: id, status: .paused)
    }

    func resumeVaultCredential(id: String) async throws -> ProfileV3VaultWriteResult {
        ProfileV3VaultWriteResult(id: id, status: .added)
    }
}
