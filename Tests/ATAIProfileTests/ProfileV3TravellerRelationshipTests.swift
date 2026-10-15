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
        #expect(field.options.map(\.value) == ["son", "daughter", "father_in_law"])
        #expect(field.options.map(\.title) == ["Son", "Daughter", "Father in law"])
        #expect(field.selectedValue == "daughter")
        #expect(field.submitLabel == "Save")
        #expect(field.submitProfileID == "p2")
    }

    @Test func selectionFallsBackToCurrentOnlyWhenItIsAnOption() throws {
        let known = try editField(#"""
        {"field":"relationship","input":"single_select","options":[{"value":"son"},{"value":"daughter"}],"current":"son"}
        """#)
        #expect(known.selectedValue == "son")
        let unknown = try editField(#"""
        {"field":"relationship","input":"single_select","options":[{"value":"son"}],"current":"cousin"}
        """#)
        #expect(unknown.selectedValue == nil)
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

    @Test func displayTitleHumanisesTheValue() {
        #expect(ProfileV3RelationshipEntry.title(for: "daughter") == "Daughter")
        #expect(ProfileV3RelationshipEntry.title(for: "father_in_law") == "Father in law")
        #expect(ProfileV3RelationshipEntry.title(for: "step-son") == "Step son")
    }

    private func editTravellers(_ json: String) throws -> ProfileV3EditTravellersScreen {
        let dto = try JSONDecoder().decode(ProfileV3EditTravellersScreenDTO.self, from: Data(json.utf8))
        return ProfileV3TravellersMapper.editTravellers(dto)
    }

    private func editField(_ json: String) throws -> ProfileV3EditField {
        let dto = try JSONDecoder().decode(ProfileV3EditFieldScreenDTO.self, from: Data(json.utf8))
        return try #require(ProfileV3EditFieldMapper.field(dto))
    }
}
