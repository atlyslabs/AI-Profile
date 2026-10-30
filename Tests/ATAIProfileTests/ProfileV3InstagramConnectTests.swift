import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Instagram connect")
struct ProfileV3InstagramConnectTests {
    @Test(.timeLimit(.minutes(1)))
    func instagramLinksAUsernameThenWaitsForAMessageToAylChat() async throws {
        let store = ProfileV3AppAccessStore()
        let repository = ProfileV3MockRepository(delay: .zero, appAccess: store)
        var opened: [URL] = []
        let model = Self.appAccess(repository, openURL: { opened.append($0) })
        model.load()
        try await Self.waitUntil { model.phase == .loaded }
        let pendingInstagram = model.pendingApps.first(where: \.isInstagram)
        let instagram = try #require(pendingInstagram)
        #expect(instagram.asksForUsernameOnly)
        #expect(!instagram.isAwaitingMessage)

        model.tapAddCredentials(instagram)
        #expect(model.editor == nil)
        let flow = try #require(model.instagram)
        #expect(flow.step == .explainer)

        flow.continueFromExplainer()
        #expect(flow.step == .username)
        #expect(!flow.canSubmit)
        flow.username = " @Grukhs "
        #expect(flow.normalisedUsername == "grukhs")
        #expect(flow.canSubmit)

        flow.submit()
        #expect(flow.phase == .saving)
        try await Self.waitUntil { flow.phase == .saved }
        #expect(flow.linkedUsername == "grukhs")
        try await Self.waitUntil { flow.step == .redirect }
        try await Self.waitUntil { model.instagram == nil }
        #expect(opened == [ProfileV3InstagramUsername.messageURL])

        try await Self.waitUntil { model.pendingApps.first(where: \.isInstagram)?.isAwaitingMessage == true }
        let waitingInstagram = model.pendingApps.first(where: \.isInstagram)
        let waiting = try #require(waitingInstagram)
        #expect(waiting.username == "grukhs")
        #expect(model.connectedApps.isEmpty)

        model.tapAddCredentials(waiting)
        #expect(model.instagram == nil)
        #expect(opened == [ProfileV3InstagramUsername.messageURL, ProfileV3InstagramUsername.messageURL])

        store.messageInstagram()
        model.refreshIfAwaitingMessage()
        try await Self.waitUntil { model.connectedApps.map(\.id) == [ProfileV3LinkedApp.instagramID] }
        let entry = try #require(model.deckEntries.first)
        #expect(!entry.canDisconnect)
        #expect(entry.hint.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func editingAConnectedInstagramRelinksTheUsernameOnly() async throws {
        let store = ProfileV3AppAccessStore()
        try store.connect("instagram", credentials: ProfileV3AppCredentials(username: "grukhs"))
        try store.connect("grab", credentials: ProfileV3AppCredentials(username: "rahul", password: "secret"))
        let repository = ProfileV3MockRepository(delay: .zero, appAccess: store)
        let model = Self.appAccess(repository)
        model.load()
        try await Self.waitUntil { model.phase == .loaded }

        model.tapEdit("instagram")
        let editor = try #require(model.editor(from: .panel))
        #expect(!editor.asksForPassword)
        #expect(editor.title == ProfileV3Strings.appUsernameTitle)
        #expect(editor.usernameLabel == ProfileV3Strings.appUsernameLabel)
        #expect(editor.credentials.username == "grukhs")
        #expect(!editor.canSubmit)
        editor.credentials.username = "@GRUKHS"
        #expect(!editor.canSubmit)
        editor.credentials.username = "grukhs travels"
        editor.submit()
        #expect(editor.inlineError == ProfileV3Strings.instagramUsernameInvalid)
        #expect(store.instagramAccount().username == "grukhs")

        editor.credentials.username = "grukhs.travels"
        #expect(editor.canSubmit)
        editor.submit()
        try await Self.waitUntil { model.editor == nil }
        try await Self.waitUntil { model.pendingApps.first(where: \.isInstagram)?.username == "grukhs.travels" }
        #expect(model.pendingApps.first(where: \.isInstagram)?.isAwaitingMessage == true)
        #expect(model.connectedApps.map(\.id) == ["grab"])
        #expect(model.deckEntries.first?.canDisconnect == true)

        model.tapEdit("grab")
        let grab = try #require(model.editor(from: .panel))
        #expect(grab.asksForPassword)
        #expect(grab.usernameLabel == ProfileV3Strings.appCredentialsUsername)
    }

    @Test(.timeLimit(.minutes(1)))
    func theExplainerMovesOnByItselfAndTheRedirectOpensTheChat() async throws {
        var opened: [URL] = []
        var finished = 0
        let flow = ProfileV3InstagramConnectModel(
            app: .instagram,
            repository: ProfileV3MockRepository(delay: .zero),
            explainerSeconds: 0.1,
            openURL: { opened.append($0) },
            onFinish: { finished += 1 }
        )
        #expect(ProfileV3Theme.Motion.instagramExplainerSeconds == 15)
        #expect(ProfileV3Strings.instagramSampleHandle == "ayl")
        flow.start()
        try await Self.waitUntil { flow.step == .username }

        flow.username = "grukhs"
        flow.submit()
        try await Self.waitUntil { finished == 1 }
        #expect(opened == [ProfileV3InstagramUsername.messageURL])
        #expect(ProfileV3InstagramUsername.messageURL.absoluteString == "https://ig.me/m/ayl.chat")
        #expect(flow.step == .redirect)
    }

    @Test(.timeLimit(.minutes(1)))
    func aRefusedUsernameStaysOnTheFormWithTheReason() async throws {
        var finished = 0
        let flow = ProfileV3InstagramConnectModel(
            app: .instagram,
            repository: ProfileV3MockRepository(delay: .zero),
            openURL: { _ in },
            onFinish: { finished += 1 }
        )
        flow.continueFromExplainer()
        flow.username = ProfileV3AppAccessStore.takenInstagramUsername
        flow.submit()
        try await Self.waitUntil { flow.errorMessage != nil }
        #expect(flow.errorMessage == "This Instagram account is linked to another Ayl account")
        #expect(flow.phase == .idle)
        #expect(flow.step == .username)
        #expect(finished == 0)

        flow.username = "grukhs_"
        #expect(flow.errorMessage == nil)
        flow.close()
        #expect(finished == 1)
    }

    @Test func anInvalidUsernameIsCaughtBeforeAnyRequest() throws {
        let store = ProfileV3AppAccessStore()
        let flow = ProfileV3InstagramConnectModel(
            app: .instagram,
            repository: ProfileV3MockRepository(delay: .zero, appAccess: store),
            openURL: { _ in },
            onFinish: {}
        )
        flow.continueFromExplainer()
        flow.username = "grukhs!"
        flow.submit()
        #expect(flow.errorMessage == ProfileV3Strings.instagramUsernameInvalid)
        #expect(flow.phase == .idle)
        #expect(store.instagramAccount() == .unlinked)

        #expect(ProfileV3InstagramUsername.normalised("  @@Some.Handle_1 ") == "some.handle_1")
        #expect(ProfileV3InstagramUsername.isValid("some.handle_1"))
        #expect(ProfileV3InstagramUsername.isValid(String(repeating: "a", count: 30)))
        #expect(!ProfileV3InstagramUsername.isValid(String(repeating: "a", count: 31)))
        #expect(!ProfileV3InstagramUsername.isValid(""))
        #expect(!ProfileV3InstagramUsername.isValid("some handle"))
        #expect(
            ProfileV3InstagramUsername.errorMessage(for: ProfileV3Error.invalidRequest(message: nil))
                == ProfileV3Strings.instagramUsernameInvalid
        )
        #expect(
            ProfileV3InstagramUsername.errorMessage(for: ProfileV3Error.conflict(code: nil, message: "Taken"))
                == "Taken"
        )
    }

    @Test func snapmapReadsAndLinksTheAccount() throws {
        let read = ProfileV3API.instagramAccount(userID: "firebase-uid")
        #expect(read.path == "/api/snapmap/instagram/accounts")
        #expect(read.method == .get)
        guard case .requestParameters(let parameters, _) = read.task else {
            Issue.record("Expected a user_id query")
            return
        }
        #expect(parameters as? [String: String] == ["user_id": "firebase-uid"])

        let body = try JSONEncoder().encode(ProfileV3InstagramLinkRequest(username: "some.handle", userID: "firebase-uid"))
        let link = ProfileV3API.linkInstagram(body: body)
        #expect(link.path == "/api/snapmap/instagram/accounts")
        #expect(link.method == .post)
        guard case .requestData(let sent) = link.task else {
            Issue.record("Expected a JSON body")
            return
        }
        #expect(
            try JSONSerialization.jsonObject(with: sent) as? [String: String]
                == ["username": "some.handle", "user_id": "firebase-uid"]
        )

        #expect(
            try Self.account(#"{"username":"Some.Handle","dm_connected":true,"linked_at":"2026-10-30T12:31:59.890793Z"}"#)
                == ProfileV3InstagramAccount(username: "some.handle", hasMessaged: true)
        )
        let waiting = try Self.account(#"{"username":"some.handle","dm_connected":false,"linked_at":"2026-10-30T12:31:59Z"}"#)
        #expect(waiting == ProfileV3InstagramAccount(username: "some.handle", hasMessaged: false))
        #expect(!waiting.isConnected)
        #expect(try Self.account(#"{"username":null,"dm_connected":false,"linked_at":null}"#) == .unlinked)
        #expect(try Self.account(#"{"username":"   ","dm_connected":"yes"}"#) == .unlinked)

        let linked = try JSONDecoder().decode(
            ProfileV3InstagramLinkDTO.self,
            from: Data(#"{"status":"already_added","username":"some.handle"}"#.utf8)
        )
        #expect(ProfileV3InstagramMapper.linkedUsername(linked, requested: "other") == "some.handle")

        let content = ProfileV3AppAccess(autoConnected: [], apps: [.instagram])
        #expect(content.applying(waiting).apps[0].isAwaitingMessage)
        #expect(content.applying(.unlinked).pending.map(\.id) == [ProfileV3LinkedApp.instagramID])
        #expect(!ProfileV3LinkedApp.instagram.canDisconnect)
    }

    private static func account(_ json: String) throws -> ProfileV3InstagramAccount {
        ProfileV3InstagramMapper.account(try JSONDecoder().decode(ProfileV3InstagramAccountDTO.self, from: Data(json.utf8)))
    }

    private static func appAccess(
        _ repository: ProfileV3MockRepository,
        openURL: @escaping @MainActor (URL) -> Void = { _ in }
    ) -> ProfileV3AppAccessModel {
        let defaults = UserDefaults(suiteName: "profileV3.instagram.\(UUID().uuidString)") ?? .standard
        return ProfileV3AppAccessModel(
            repository: repository,
            connectors: ProfileV3ConnectorsSettingsModel(repository: repository),
            hints: ProfileV3HubHints(defaults: defaults),
            openURL: openURL
        )
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Task.sleep(for: .milliseconds(20))
        }
        #expect(condition())
    }
}
