import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Traveller relationship editor")
struct ProfileV3TravellerRelationshipTests {
    @Test func coTravellersCarryTheRelationshipEditor() throws {
        let screen = try editTravellers(#"""
        {"type":"edit_traveler","title":"Edit travellers","travellers":[
          {"profile_id":"p1","name":"Ada Lovelace","pass_number":"ATL 0001","is_main":true,
           "relationship":"self",
           "edit_relationship":{"label":"Relationship","next":{"go":"edit_field","field":"relationship","profile_id":"p1"}}},
          {"profile_id":"p2","name":"Byron Lovelace","pass_number":"ATL 0002","is_main":false,"relationship":"daughter",
           "edit_relationship":{"label":"Relationship","next":{"go":"edit_field","field":"relationship","profile_id":"p2"}}},
          {"profile_id":"p3","name":"Charles Babbage","pass_number":"ATL 0003","is_main":false,
           "edit_relationship":{"label":"Citizenship","next":{"go":"edit_field","field":"citizenship","profile_id":"p3"}}}
        ]}
        """#)
        let rows = screen.travellers
        #expect(rows.map(\.id) == ["p1", "p2", "p3"])
        #expect(rows[0].relationship == nil)
        #expect(rows[0].relationshipEntry == nil)
        #expect(rows[1].relationship == "daughter")
        #expect(rows[1].relationshipEntry == ProfileV3RelationshipEntry(label: "Relationship", profileID: "p2"))
        #expect(rows[2].relationshipEntry == nil)
    }

    @Test func relationshipEditorDecodesOptionsAndSubmitTarget() throws {
        let field = try editField(#"""
        {"type":"edit_field","field":"relationship","title":"Relationship","input":"single_select",
         "options":[{"value":"son","title":"Son"},{"value":"daughter","title":"Daughter","selected":true},
                    {"value":"father_in_law"},{"title":"No value"}],
         "current":"daughter",
         "submit":{"label":"Save","action":"edit_profile_field","field":"relationship","profile_id":"p2"}}
        """#)
        #expect(field.input == .singleSelect)
        #expect(field.options.map(\.value) == ["son", "daughter"])
        #expect(field.options.map(\.title) == ["Son", "Daughter"])
        #expect(field.selectedValue == "daughter")
        #expect(field.submitLabel == "Save")
        #expect(field.submitProfileID == "p2")
    }

    @Test func selectionFallsBackToCurrentOnlyWhenItIsAnOption() throws {
        let known = try editField(#"""
        {"field":"relationship","input":"single_select",
         "options":[{"value":"son","title":"Son"},{"value":"daughter","title":"Daughter"}],"current":"son"}
        """#)
        #expect(known.selectedValue == "son")
        let unknown = try editField(#"""
        {"field":"relationship","input":"single_select","options":[{"value":"son","title":"Son"}],"current":"cousin"}
        """#)
        #expect(unknown.selectedValue == nil)
    }

    @Test func currentMatchesAnOptionWhateverItsCaseOrSeparators() throws {
        let field = try editField(#"""
        {"field":"relationship","input":"single_select",
         "options":[{"value":"father_in_law","title":"Father-in-law"},{"value":"daughter","title":"Daughter"}],
         "current":"Father-In-Law"}
        """#)
        #expect(field.selectedValue == "father_in_law")
    }

    @Test func theTravellersRelationshipIsSelectedWhenTheEditorMarksNone() throws {
        let field = try editField(#"""
        {"field":"relationship","input":"single_select",
         "options":[{"value":"spouse","title":"Spouse"},{"value":"father_in_law","title":"Father-in-law"}]}
        """#)
        #expect(field.selectedValue == nil)
        #expect(field.selectedValue(fallingBackTo: "spouse") == "spouse")
        #expect(field.selectedValue(fallingBackTo: "FATHER_IN_LAW") == "father_in_law")
        #expect(field.selectedValue(fallingBackTo: "Father-in-law") == "father_in_law")
        #expect(field.selectedValue(fallingBackTo: "cousin") == nil)
        #expect(field.selectedValue(fallingBackTo: nil) == nil)

        let marked = try editField(#"""
        {"field":"relationship","options":[{"value":"spouse","title":"Spouse","selected":true},{"value":"son","title":"Son"}]}
        """#)
        #expect(marked.selectedValue(fallingBackTo: "son") == "spouse")
    }

    @Test(.timeLimit(.minutes(1)))
    func theEditorOpensOnTheTravellersRelationshipAndSavesOnlyAChange() async throws {
        let session = ProfileV3SessionStore()
        let model = ProfileV3TravellersSettingsModel(
            deps: .preview(),
            repository: ProfileV3MockRepository(delay: .zero, session: session),
            currentContact: { ProfileV3Fixtures.contactDetails }
        )
        model.load()
        try await Self.waitUntil { model.screen != nil }
        let row = try #require(model.rows.first { $0.relationshipEntry != nil })
        session.relationships[row.id] = "Sibling"
        model.load()
        try await Self.waitUntil { model.rows.first { $0.id == row.id }?.relationship == "Sibling" }
        model.select(try #require(model.rows.first { $0.id == row.id }))
        #expect(model.editingRelationshipTitle == "Sibling")

        model.tapRelationship()
        try await Self.waitUntil { model.relationshipField != nil }
        #expect(model.relationshipSelection == "sibling")
        #expect(!model.canSaveRelationship)

        model.selectRelationship("friend")
        #expect(model.canSaveRelationship)
        model.selectRelationship("sibling")
        #expect(!model.canSaveRelationship)
    }

    @Test func relationshipFieldWithoutInputIsSingleSelect() throws {
        let field = try editField(#"{"field":"relationship","options":[{"value":"son"}]}"#)
        #expect(field.input == .singleSelect)
    }

    @Test func editorRequestCarriesTheProfileOnlyWhenGiven() {
        let scoped = ProfileV3API.editField("relationship", profileID: "p2")
        #expect(scoped.path == "/api/gmail-connector/kyc/v2/board/settings/edit/relationship")
        guard case .requestParameters(let parameters, _) = scoped.task else {
            Issue.record("Expected a profile_id query")
            return
        }
        #expect(parameters["profile_id"] as? String == "p2")
        guard case .requestPlain = ProfileV3API.editField("residence", profileID: nil).task else {
            Issue.record("Expected no query without a profile")
            return
        }
    }

    @Test func saveSendsTheRelationshipForTheTraveller() throws {
        let request = ProfileV3EditProfileFieldRequest(
            field: ProfileV3AddTravellerField.relationshipKey,
            value: .code("son"),
            profileID: "p2"
        )
        let object = try #require(
            try JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as? [String: String]
        )
        #expect(object == [
            "action": "edit_profile_field",
            "field": "relationship",
            "value": "son",
            "profile_id": "p2",
        ])
    }

    private func editTravellers(_ json: String) throws -> ProfileV3EditTravellersScreen {
        let dto = try JSONDecoder().decode(ProfileV3EditTravellersScreenDTO.self, from: Data(json.utf8))
        return ProfileV3TravellersMapper.editTravellers(dto)
    }

    private func editField(_ json: String) throws -> ProfileV3EditField {
        let dto = try JSONDecoder().decode(ProfileV3EditFieldScreenDTO.self, from: Data(json.utf8))
        return try #require(ProfileV3EditFieldMapper.field(dto))
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 200 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}
