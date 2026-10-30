import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Instagram connect")
struct ProfileV3InstagramConnectTests {
    @Test(.timeLimit(.minutes(1)))
    func instagramAsksForAUsernameThenSendsTheUserToInstagram() async throws {
        let store = ProfileV3AppAccessStore()
        let repository = ProfileV3MockRepository(delay: .zero, appAccess: store)
        let defaults = UserDefaults(suiteName: "profileV3.instagram.\(UUID().uuidString)") ?? .standard
        let model = ProfileV3AppAccessModel(
            repository: repository,
            connectors: ProfileV3ConnectorsSettingsModel(repository: repository),
            hints: ProfileV3HubHints(defaults: defaults)
        )
        model.load()
        try await Self.waitUntil { model.phase == .loaded }
        let pendingInstagram = model.pendingApps.first { $0.id == "instagram" }
        let instagram = try #require(pendingInstagram)
        #expect(instagram.asksForUsernameOnly)

        model.tapAddCredentials(instagram)
        #expect(model.editor == nil)
        let flow = try #require(model.instagram)
        #expect(flow.step == .explainer)

        flow.continueFromExplainer()
        #expect(flow.step == .username)
        #expect(!flow.canSubmit)
        flow.username = " @grukhs "
        #expect(flow.trimmedUsername == "grukhs")
        #expect(flow.canSubmit)

        flow.submit()
        #expect(flow.phase == .saving)
        try await Self.waitUntil { flow.phase == .saved }
        try await Self.waitUntil { flow.step == .redirect }
        try await Self.waitUntil { model.instagram == nil }
        try await Self.waitUntil { model.connectedApps.map(\.id) == ["instagram"] }
        #expect(model.connectedApps.first?.username == "grukhs")
    }

    @Test(.timeLimit(.minutes(1)))
    func editingAConnectedInstagramAsksOnlyForTheUsername() async throws {
        let store = ProfileV3AppAccessStore()
        try store.connect("instagram", credentials: ProfileV3AppCredentials(username: "grukhs"))
        try store.connect("grab", credentials: ProfileV3AppCredentials(username: "rahul", password: "secret"))
        let repository = ProfileV3MockRepository(delay: .zero, appAccess: store)
        let defaults = UserDefaults(suiteName: "profileV3.instagram.\(UUID().uuidString)") ?? .standard
        let model = ProfileV3AppAccessModel(
            repository: repository,
            connectors: ProfileV3ConnectorsSettingsModel(repository: repository),
            hints: ProfileV3HubHints(defaults: defaults)
        )
        model.load()
        try await Self.waitUntil { model.phase == .loaded }

        model.tapEdit("instagram")
        let editor = try #require(model.editor(from: .panel))
        #expect(!editor.asksForPassword)
        #expect(editor.title == ProfileV3Strings.appUsernameTitle)
        #expect(editor.usernameLabel == ProfileV3Strings.appUsernameLabel)
        #expect(editor.credentials.username == "grukhs")
        #expect(!editor.canSubmit)
        editor.credentials.username = "grukhs.travels"
        #expect(editor.canSubmit)
        editor.submit()
        try await Self.waitUntil { model.editor == nil }
        try await Self.waitUntil { model.connectedApps.first { $0.id == "instagram" }?.username == "grukhs.travels" }

        model.tapEdit("grab")
        let grab = try #require(model.editor(from: .panel))
        #expect(grab.asksForPassword)
        #expect(grab.usernameLabel == ProfileV3Strings.appCredentialsUsername)
    }

    @Test(.timeLimit(.minutes(1)))
    func theExplainerMovesOnByItselfAndTheRedirectOpensInstagram() async throws {
        var opened: [URL] = []
        var finished = 0
        let flow = ProfileV3InstagramConnectModel(
            app: ProfileV3AppAccessFixtures.content.apps[0],
            repository: ProfileV3MockRepository(delay: .zero),
            openURL: { opened.append($0) },
            onFinish: { finished += 1 }
        )
        flow.start()
        try await Self.waitUntil { flow.step == .username }

        flow.username = "grukhs"
        flow.submit()
        try await Self.waitUntil { finished == 1 }
        #expect(opened == [ProfileV3InstagramConnectModel.instagramURL])
        #expect(flow.step == .redirect)
    }

    @Test(.timeLimit(.minutes(1)))
    func aRefusedUsernameStaysOnTheFormWithTheReason() async throws {
        var finished = 0
        let flow = ProfileV3InstagramConnectModel(
            app: ProfileV3AppAccessFixtures.content.apps[0],
            repository: ProfileV3FailingRepository(),
            openURL: { _ in },
            onFinish: { finished += 1 }
        )
        flow.continueFromExplainer()
        flow.username = "grukhs"
        flow.submit()
        try await Self.waitUntil { flow.errorMessage != nil }
        #expect(flow.phase == .idle)
        #expect(flow.step == .username)
        #expect(finished == 0)

        flow.username = "grukhs_"
        #expect(flow.errorMessage == nil)
        flow.close()
        #expect(finished == 1)
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Task.sleep(for: .milliseconds(20))
        }
        #expect(condition())
    }
}
