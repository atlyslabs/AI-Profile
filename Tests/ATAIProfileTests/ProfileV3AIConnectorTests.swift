import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("AI connectors")
struct ProfileV3AIConnectorTests {
    @Test func theOverviewRendersEveryConnectorItIsSent() throws {
        let dto = try JSONDecoder().decode(ProfileV3ConnectorsScreenDTO.self, from: Data(#"""
        {"type":"connectors","title":"Information access","blurb":"Your travel data stays secure.",
         "connectors":[
          {"key":"gmail","label":"Email","connected":true,"account_email":"r***ag@gmail.com"},
          {"key":"itr","label":"IT Returns","connected":false},
          {"key":"claude","label":"Claude","connected":false,"image_url":"https://media.atlys.com/claude.png",
           "connect_label":"Connect","next":{"go":"ai_connector","connector":"claude"}},
          {"key":"ChatGPT","label":"ChatGPT","connected":true,"synced_at":"2026-10-29T16:11:00.123Z",
           "status_label":"Synced on {date}","next":{"go":"ai_connector","connector":"chatgpt"}},
          {"key":"grok","label":"Grok","connected":true,"status_label":"Synced on {date}",
           "next":{"go":"ai_connector","connector":"grok"}},
          {"key":"notion","label":"Notion","connected":false},
          {"label":"No key"}
         ]}
        """#.utf8))
        let screen = ProfileV3ConnectorsMapper.screen(dto)
        #expect(screen.title == "Information access")
        #expect(screen.connectors.map(\.id) == ["gmail", "itr", "claude", "chatgpt", "grok", "notion"])

        let claude = try #require(screen.connectors.first { $0.id == "claude" })
        #expect(claude.aiConnector == "claude")
        #expect(claude.connectLabel == "Connect")
        #expect(claude.status == .needsAttention)
        #expect(claude.icon == .remote(URL(string: "https://media.atlys.com/claude.png")))

        let chatgpt = try #require(screen.connectors.first { $0.id == "chatgpt" })
        #expect(chatgpt.status == .connected)
        #expect(abs((chatgpt.syncedAt?.timeIntervalSince1970 ?? 0) - 1_793_290_260.123) < 0.001)
        #expect(chatgpt.statusLabel?.hasPrefix("Synced on ") == true)
        #expect(chatgpt.statusLabel?.contains("{date}") == false)

        #expect(screen.connectors.first { $0.id == "grok" }?.statusLabel == nil)
        #expect(screen.connectors.first { $0.id == "notion" }?.aiConnector == nil)
        #expect(screen.connectors.first { $0.id == "itr" }?.captureStep != nil)
    }

    @Test func theSyncedDateIsWrittenInThePhonesTimeZone() throws {
        let synced = try #require(ProfileV3AIConnectorMapper.syncedAt("2026-10-29T16:11:00Z"))
        let kolkata = try #require(TimeZone(identifier: "Asia/Kolkata"))
        #expect(ProfileV3AIConnectorMapper.statusLabel("Synced on {date}", syncedAt: synced, timeZone: kolkata)
            == "Synced on 29 Oct, 9:41 pm")
        let utc = try #require(TimeZone(identifier: "UTC"))
        #expect(ProfileV3AIConnectorMapper.statusLabel("Synced on {date}", syncedAt: synced, timeZone: utc)
            == "Synced on 29 Oct, 4:11 pm")
        #expect(ProfileV3AIConnectorMapper.statusLabel("Connected", syncedAt: nil) == "Connected")
        #expect(ProfileV3AIConnectorMapper.statusLabel("Synced on {date}", syncedAt: nil) == nil)
        #expect(ProfileV3AIConnectorMapper.syncedAt("yesterday") == nil)
    }

    @Test func aiConnectorDirectivesRouteToTheirSheets() {
        #expect(ProfileV3Directive(go: "ai_connector", connector: " Claude ").route() == .aiConnector("claude"))
        #expect(ProfileV3Directive(go: "ai_connector_connect", connector: "grok").route() == .aiConnectorConnect("grok"))
        #expect(ProfileV3Directive(go: "ai_connector").route() == .unsupported("ai_connector"))
        #expect(ProfileV3API.aiConnector(connector: "claude").path
            == "/api/gmail-connector/kyc/v2/board/settings/connectors/ai/claude")
        #expect(ProfileV3API.aiConnectorConnect(connector: "claude").path
            == "/api/gmail-connector/kyc/v2/board/settings/connectors/ai/claude/connect")
        #expect(ProfileV3API.aiConnector(connector: "claude").method == .get)
    }

    @Test func theDetailScreenKeepsItsBenefitsDisclaimersAndLinks() throws {
        let dto = try JSONDecoder().decode(ProfileV3AIConnectorScreenDTO.self, from: Data(#"""
        {"type":"ai_connector","connector":"claude","eyebrow":"CONNECTORS","title":"Claude",
         "image_url":"https://media.atlys.com/claude.png","subtitle":"Bring what Claude knows about your travel into Atlys.",
         "benefits":[{"title":"Your travel history, in one go","body":"Trips you’ve taken."},{"body":"No title"},
                     {"title":"Skip the questions"}],
         "disclaimers":[{"text":"What you paste is saved to your Atlys profile."},
                        {"text":"Your chats in Claude follow Claude’s own Terms and Privacy Policy.",
                         "links":[{"label":"Terms","url":"https://www.anthropic.com/legal/consumer-terms"},
                                  {"label":"Privacy Policy","url":"https://www.anthropic.com/legal/privacy"},
                                  {"label":"Cookies","url":"https://www.anthropic.com/legal/cookies"},
                                  {"label":"Terms","url":"/relative"}]},
                        {"text":"  "}],
         "cta":{"label":"Get started","next":{"go":"ai_connector_connect","connector":"claude"}}}
        """#.utf8))
        let detail = ProfileV3AIConnectorMapper.detail(dto, fallback: "claude")
        #expect(detail.eyebrow == "CONNECTORS")
        #expect(detail.title == "Claude")
        #expect(detail.benefits.map(\.title) == ["Your travel history, in one go", "Skip the questions"])
        #expect(detail.benefits.map(\.body) == ["Trips you’ve taken.", ""])
        #expect(detail.disclaimers.count == 2)
        #expect(detail.disclaimers[1].links.map(\.label) == ["Terms", "Privacy Policy"])
        #expect(detail.ctaLabel == "Get started")
        #expect(detail.next?.route() == .aiConnectorConnect("claude"))
    }

    @Test func theConnectScreenKeepsThePromptsLineBreaksAndItsSubmit() throws {
        let dto = try JSONDecoder().decode(ProfileV3AIConnectorConnectScreenDTO.self, from: Data(#"""
        {"type":"ai_connector_connect","connector":"claude","eyebrow":"CONNECTORS","title":"Bring in your Claude history",
         "steps":[
          {"label":"STEP 1","title":"Copy this prompt into Claude",
           "prompt":{"text":"List what you know.\n\nTRIPS: places\nFOOD: diet\n","copy_label":"Copy prompt","copied_label":"Copied"}},
          {"label":"STEP 2","title":"Paste Claude’s answer here","body":"Read it first.",
           "input":{"key":"text","placeholder":"Paste the answer"},
           "submit":{"label":"Save","action":"connect_ai_connector","connector":"claude"}}
         ]}
        """#.utf8))
        let connect = ProfileV3AIConnectorMapper.connect(dto, fallback: "claude")
        #expect(connect.title == "Bring in your Claude history")
        #expect(connect.steps.map(\.label) == ["STEP 1", "STEP 2"])
        #expect(connect.prompt == ProfileV3AIConnectorConnect.Prompt(
            text: "List what you know.\n\nTRIPS: places\nFOOD: diet",
            copyLabel: "Copy prompt",
            copiedLabel: "Copied"
        ))
        #expect(connect.steps[1].input == ProfileV3AIConnectorConnect.Input(key: "text", placeholder: "Paste the answer"))
        #expect(connect.submit == ProfileV3AIConnectorConnect.Submit(
            label: "Save",
            action: "connect_ai_connector",
            connector: "claude"
        ))
        let body = try JSONSerialization.jsonObject(with: JSONEncoder().encode(
            ProfileV3ConnectAIConnectorRequest(action: "connect_ai_connector", connector: "claude", text: "TRIPS: Goa")
        )) as? [String: String]
        #expect(body == ["action": "connect_ai_connector", "connector": "claude", "text": "TRIPS: Goa"])
    }

    @Test(.timeLimit(.minutes(1)))
    func connectingCopiesThePromptSavesTheAnswerAndRefreshesTheRow() async throws {
        let settings = ProfileV3ConnectorsSettingsModel(repository: ProfileV3MockRepository(delay: .zero))
        settings.load()
        try await Self.waitUntil { settings.phase == .loaded }
        let claude = try #require(settings.connectors.first { $0.id == "claude" })
        #expect(claude.status == .needsAttention)

        settings.tapConnect(claude)
        let sheet = try #require(settings.aiConnector)
        #expect(sheet.id == "claude")
        sheet.start()
        try await Self.waitUntil { sheet.detailPhase == .loaded }
        #expect(sheet.detail?.ctaLabel == "Get started")

        sheet.getStarted()
        #expect(sheet.step == .connect)
        try await Self.waitUntil { sheet.connectPhase == .loaded }
        #expect(sheet.copyTitle == "Copy prompt")
        #expect(!sheet.canSave)

        sheet.answer = "   "
        #expect(!sheet.canSave)
        sheet.answer = "TRIPS: Goa, March 2025"
        #expect(sheet.canSave)
        sheet.save()
        try await Self.waitUntil { settings.aiConnector == nil }
        try await Self.waitUntil { settings.connectors.first { $0.id == "claude" }?.status == .connected }
        let synced = try #require(settings.connectors.first { $0.id == "claude" })
        #expect(synced.statusLabel?.hasPrefix("Synced on ") == true)
    }

    @Test(.timeLimit(.minutes(1)))
    func copyingShowsTheCopiedLabelAndARefusedSaveShowsTheServersMessage() async throws {
        var copied: [String] = []
        var closed = 0
        var connected = 0
        let message = "Paste Claude’s answer before you save."
        let sheet = ProfileV3AIConnectorModel(
            connector: "claude",
            repository: RefusingStub(message: message),
            copyText: { copied.append($0) },
            onConnected: { connected += 1 },
            onClose: { closed += 1 }
        )
        sheet.start()
        try await Self.waitUntil { sheet.detailPhase == .loaded }
        sheet.getStarted()
        try await Self.waitUntil { sheet.connectPhase == .loaded }

        sheet.copyPrompt()
        #expect(copied == [ProfileV3AIConnectorFixtures.connect("claude").prompt?.text])
        #expect(sheet.copyTitle == "Copied")
        #expect(sheet.copies == 1)

        sheet.answer = "TRIPS: Goa"
        sheet.save()
        try await Self.waitUntil { sheet.errorMessage != nil }
        #expect(sheet.errorMessage == message)
        #expect(!sheet.isSaving)
        #expect(connected == 0 && closed == 0)

        sheet.answer = "TRIPS: Goa, Kerala"
        #expect(sheet.errorMessage == nil)
        sheet.close()
        #expect(closed == 1)
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 200 where !condition() {
            try await Task.sleep(for: .milliseconds(20))
        }
        #expect(condition())
    }
}

private struct RefusingStub: ProfileV3AIConnectorRepository {
    let message: String

    func loadAIConnector(_ connector: String) async throws -> ProfileV3AIConnector {
        ProfileV3AIConnectorFixtures.detail(connector)
    }

    func loadAIConnectorConnect(_ connector: String) async throws -> ProfileV3AIConnectorConnect {
        ProfileV3AIConnectorFixtures.connect(connector)
    }

    func connectAIConnector(_: ProfileV3AIConnectorConnect.Submit, text _: String) async throws {
        throw ProfileV3Error.invalidRequest(message: message)
    }
}
