import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("App access")
struct ProfileV3AppAccessTests {
    @Test func pageListsPendingAppsAndTheAutoConnectedOnes() async throws {
        let model = makeModel()
        model.load()
        try await waitUntil { model.phase == .loaded }

        #expect(model.autoConnected.map(\.name) == ["Splits by Atlys"])
        #expect(model.pendingApps.map(\.id) == ["instagram", "grab", "uber", "stripe", "plaid", "spotify", "strava"])
        #expect(model.pendingApps.first?.asksForUsernameOnly == true)
        #expect(model.connectedApps.isEmpty)
        #expect(model.deckEntries.isEmpty)
        #expect(!model.showsConnectedHint)
    }

    @Test func addingCredentialsConnectsTheAppAndPointsToConnected() async throws {
        let model = makeModel()
        model.load()
        try await waitUntil { model.phase == .loaded }
        let pendingGrab = model.pendingApps.first { $0.id == "grab" }
        let grab = try #require(pendingGrab)

        model.tapAddCredentials(grab)
        let editor = try #require(model.editor(from: .page))
        #expect(model.editor(from: .panel) == nil)
        #expect(editor.title == ProfileV3Strings.appCredentialsTitle)
        #expect(editor.submitTitle == ProfileV3Strings.appCredentialsAdd)
        #expect(!editor.canSubmit)
        editor.credentials.username = "  rahul@atlys.com "
        #expect(!editor.canSubmit)
        editor.credentials.password = "secret"
        #expect(editor.canSubmit)

        editor.submit()
        #expect(editor.phase == .submitting)
        try await waitUntil { editor.phase == .succeeded }
        try await waitUntil { model.editor == nil }
        try await waitUntil { model.connectedApps.map(\.id) == ["grab"] }

        #expect(model.connectedApps.first?.username == "rahul@atlys.com")
        #expect(model.pendingApps.map(\.id) == ["instagram", "uber", "stripe", "plaid", "spotify", "strava"])
        #expect(model.saveCompletions == 1)
        #expect(model.showsConnectedHint)
        let entry = try #require(model.deckEntries.first)
        #expect(entry.isApp)
        #expect(entry.headline == "Grab")
        #expect(entry.account.isEmpty)
        #expect(entry.hint == ProfileV3Strings.connectorDeckHint)

        model.tapConnected()
        #expect(!model.showsConnectedHint)
    }

    @Test func newPasswordNeedsAWebsiteAndAddsAConnectedEntry() async throws {
        let model = makeModel()
        model.load()
        try await waitUntil { model.phase == .loaded }

        model.tapAddNew()
        let editor = try #require(model.editor(from: .page))
        #expect(editor.asksForWebsite)
        #expect(editor.app == nil)
        #expect(editor.title == ProfileV3Strings.appPasswordTitle)
        #expect(editor.submitTitle == ProfileV3Strings.continueTitle)
        editor.credentials.username = "rahul"
        editor.credentials.password = "secret"
        #expect(!editor.canSubmit)
        editor.credentials.website = "hdfcbank.in/ways-to-bank"
        #expect(editor.canSubmit)

        editor.submit()
        try await waitUntil { model.editor == nil }
        try await waitUntil { model.connectedApps.count == 1 }
        #expect(model.connectedApps.first?.name == "hdfcbank.in")
        #expect(model.connectedApps.first?.iconURL == nil)
        #expect(model.pendingApps.count == 7)
    }

    @Test func websiteLinksNeedAHostWithADot() {
        #expect(ProfileV3AppCredentials(website: " atlys.com ").websiteURL?.absoluteString == "https://atlys.com")
        #expect(ProfileV3AppCredentials(website: "http://atlys.com/visa").websiteURL?.absoluteString == "http://atlys.com/visa")
        #expect(ProfileV3AppCredentials(website: "hdfc bank").websiteURL == nil)
        #expect(ProfileV3AppCredentials(website: "localhost").websiteURL == nil)
        #expect(ProfileV3AppCredentials(website: " ").websiteURL == nil)
    }

    @Test func editStartsFromTheSavedUsernameAndSavesFromThePanel() async throws {
        let store = ProfileV3AppAccessStore()
        try store.connect("uber", credentials: ProfileV3AppCredentials(username: "rahul@atlys.com", password: "old"))
        let model = makeModel(store: store)
        model.load()
        try await waitUntil { model.phase == .loaded }

        model.tapEdit("uber")
        let editor = try #require(model.editor(from: .panel))
        #expect(model.editor(from: .page) == nil)
        #expect(editor.isEditing)
        #expect(editor.credentials.username == "rahul@atlys.com")
        #expect(editor.credentials.password.isEmpty)
        #expect(editor.submitTitle == ProfileV3Strings.saveChanges)
        #expect(editor.successMessage == ProfileV3Strings.appCredentialsUpdated)
        #expect(!editor.canSubmit)

        editor.credentials.password = "new"
        editor.submit()
        #expect(editor.savePhase == .saving)
        try await waitUntil { editor.savePhase == .saved }
        try await waitUntil { model.editor == nil }
    }

    @Test func disconnectReturnsTheAppToTheListAndClosesThePanel() async throws {
        let store = ProfileV3AppAccessStore()
        try store.connect("grab", credentials: ProfileV3AppCredentials(username: "rahul", password: "secret"))
        let model = makeModel(store: store)
        let navigator = NavigatorStub(path: [.appAccess, .controlPanel])
        model.navigator = navigator
        model.load()
        try await waitUntil { model.phase == .loaded }
        #expect(model.deckEntries.map(\.id) == ["grab"])

        model.disconnect("grab")
        try await waitUntil { model.disconnectCompletions == 1 }

        #expect(navigator.path == [.appAccess])
        #expect(model.deckEntries.isEmpty)
        #expect(model.pendingApps.map(\.id).prefix(2) == ["instagram", "grab"])
        #expect(model.deckResetToken == 1)
    }

    @Test func failedSaveReturnsToEditingAndReportsTheMessage() async throws {
        let editor = ProfileV3AppCredentialsViewModel(
            mode: .newPassword,
            origin: .page,
            repository: ProfileV3FailingRepository()
        )
        var reported: String?
        editor.onFailure = { reported = $0 }
        editor.credentials = ProfileV3AppCredentials(website: "atlys.com", username: "rahul", password: "secret")

        editor.submit()
        try await waitUntil { reported != nil }

        #expect(editor.phase == .editing)
        #expect(reported == ProfileV3Strings.saveFailed)
    }

    private func makeModel(store: ProfileV3AppAccessStore = ProfileV3AppAccessStore()) -> ProfileV3AppAccessModel {
        let repository = ProfileV3MockRepository(delay: .zero, appAccess: store)
        let defaults = UserDefaults(suiteName: "profileV3.appAccess.\(UUID().uuidString)") ?? .standard
        return ProfileV3AppAccessModel(
            repository: repository,
            connectors: ProfileV3ConnectorsSettingsModel(repository: repository),
            hints: ProfileV3HubHints(defaults: defaults)
        )
    }

    private func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

@MainActor
private final class NavigatorStub: ProfileV3SettingsNavigating {
    var path: [ProfileV3SettingsDestination]

    init(path: [ProfileV3SettingsDestination]) {
        self.path = path
    }
}
