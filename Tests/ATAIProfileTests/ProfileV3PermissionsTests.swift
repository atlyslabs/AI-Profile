import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Permissions")
struct ProfileV3PermissionsTests {
    private static let harness = #"""
    {"permissions":[
      {"key":"email","label":"Email","description":"Ayl will email hotels, airlines and others for you",
       "kind":"permission","parent_key":"","options":["on","ask"],"default":"ask","value":"ask","updated_at":null},
      {"key":"email_cc","label":"CC me","description":"Copy you on the emails Ayl sends",
       "kind":"setting","parent_key":"email","options":["always","when_needed"],
       "default":"when_needed","value":"always","updated_at":"2026-10-29T09:12:00Z"},
      {"key":"call","label":"Call","description":"Ayl will call hotels, airlines and others for you",
       "kind":"permission","parent_key":"","options":["on","ask"],"default":"ask","value":"ask","updated_at":null}
    ]}
    """#

    @Test func settingsSitInTheirPermissionsCard() throws {
        let permissions = try #require(try Self.permissions(Self.harness))
        #expect(permissions.sections.map(\.id) == ["email", "call"])
        #expect(permissions.sections.map(\.title) == ["Email", "Call"])
        let email = permissions.sections[0].rows
        #expect(email.map(\.id) == ["email", "email_cc"])
        #expect(email.map(\.title) == ["Ayl will email hotels, airlines and others for you", "Copy you on the emails Ayl sends"])
        #expect(email[0].options.map(\.id) == ["on", "ask"])
        #expect(email[0].options.map(\.title) == [ProfileV3Strings.yes, ProfileV3Strings.alwaysAsk])
        #expect(email[1].options.map(\.title) == [ProfileV3Strings.permissionAlways, ProfileV3Strings.permissionWhenNeeded])
        #expect(email.map(\.selectedOptionID) == ["ask", "always"])
        #expect(permissions.sections[1].rows.map(\.id) == ["call"])
        #expect(permissions == ProfileV3PermissionFixtures.permissions)
    }

    @Test func aValueOutsideTheOptionsFallsBackToTheDefault() throws {
        let permissions = try #require(try Self.permissions(#"""
        {"permissions":[
          {"key":"email","label":"Email","options":["on","ask"],"default":"ask","value":"sometimes"},
          {"key":"call","label":"Call","options":["on","ask"],"default":"ask","value":null},
          {"key":"sms","label":"SMS","options":["on","never_ask"],"default":"maybe","value":"maybe"}
        ]}
        """#))
        #expect(permissions.sections.flatMap(\.rows).map(\.selectedOptionID) == ["ask", "ask", nil])
        #expect(permissions.sections[2].rows[0].options.map(\.title) == [ProfileV3Strings.yes, "Never ask"])
    }

    @Test func onlyUsableEntriesAreShown() throws {
        let permissions = try #require(try Self.permissions(#"""
        {"permissions":[
          {"key":"email","label":"Email","description":"Ayl will email for you","options":["on","ask"],"value":"on"},
          {"key":"email","label":"Email again","options":["on"]},
          {"label":"No key","options":["on"]},
          {"key":"fax","label":"Fax","options":[]},
          {"key":"email_cc","label":"CC me","parent_key":"email","options":["always","when_needed"]},
          {"key":"sms_cc","label":"CC me on texts","description":"Copy you on texts","parent_key":"sms","options":["always"]},
          "not an entry"
        ]}
        """#))
        #expect(permissions.sections.map(\.id) == ["email", "sms_cc"])
        #expect(permissions.sections[0].rows.map(\.title) == ["Ayl will email for you", "CC me"])
        #expect(permissions.sections[1].title == "CC me on texts")
        #expect(permissions.sections[1].rows.map(\.title) == ["Copy you on texts"])
        #expect(try Self.permissions(#"{"permissions":[]}"#) == nil)
    }

    @Test func theScreenReadsAndWritesTheHarnessPermissions() throws {
        #expect(ProfileV3API.permissions.path == "/api/harness/v1/permissions")
        #expect(ProfileV3API.permissions.method == .get)
        let body = try JSONEncoder().encode(ProfileV3UpdatePermissionRequest(value: "always"))
        let update = ProfileV3API.updatePermission(key: "email_cc", body: body)
        #expect(update.path == "/api/harness/v1/permissions/email_cc")
        #expect(update.method == .put)
        guard case .requestData(let sent) = update.task else {
            Issue.record("Expected a JSON body")
            return
        }
        #expect(try JSONSerialization.jsonObject(with: sent) as? [String: String] == ["value": "always"])
    }

    @Test(.timeLimit(.minutes(1)))
    func choosingAnOptionSavesItUnderItsKey() async throws {
        let repository = PermissionsStub()
        let model = ProfileV3PermissionsSettingsModel(repository: repository)
        model.load()
        while model.permissions == nil { try await Task.sleep(for: .milliseconds(10)) }

        model.select("when_needed", in: "email_cc")
        #expect(model.permissions?.selectedOptionID(in: "email_cc") == "when_needed")
        #expect(model.permissions?.selectedOptionID(in: "email") == "ask")
        while repository.saves.isEmpty { try await Task.sleep(for: .milliseconds(10)) }
        #expect(repository.saves == ["email_cc=when_needed"])

        model.select("when_needed", in: "email_cc")
        try await Task.sleep(for: .milliseconds(50))
        #expect(repository.saves == ["email_cc=when_needed"])
    }

    @Test(.timeLimit(.minutes(1)))
    func aRefusedSaveRestoresThePreviousChoice() async throws {
        let repository = PermissionsStub(failsSaving: true)
        let model = ProfileV3PermissionsSettingsModel(repository: repository)
        model.load()
        while model.permissions == nil { try await Task.sleep(for: .milliseconds(10)) }

        model.select("on", in: "call")
        #expect(model.permissions?.selectedOptionID(in: "call") == "on")
        while model.permissions?.selectedOptionID(in: "call") != "ask" { try await Task.sleep(for: .milliseconds(10)) }
        #expect(repository.saves == ["call=on"])
    }

    private static func permissions(_ json: String) throws -> ProfileV3Permissions? {
        ProfileV3PermissionsMapper.permissions(try JSONDecoder().decode(ProfileV3PermissionsDTO.self, from: Data(json.utf8)))
    }
}

private final class PermissionsStub: ProfileV3PermissionsRepository, @unchecked Sendable {
    private let lock = NSLock()
    private let failsSaving: Bool
    private var recorded: [String] = []

    init(failsSaving: Bool = false) {
        self.failsSaving = failsSaving
    }

    var saves: [String] { lock.withLock { recorded } }

    func loadPermissions() async throws -> ProfileV3Permissions {
        ProfileV3PermissionFixtures.permissions
    }

    func savePermission(_ value: String, for key: String) async throws {
        lock.withLock { recorded.append("\(key)=\(value)") }
        if failsSaving { throw ProfileV3RepositoryError.unavailable }
    }
}
