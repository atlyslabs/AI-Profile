import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Loyalty programme rows")
struct ProfileV3LoyaltyRowTests {
    @Test func pageRowsCarryTierExpiryAndUpdatedLine() throws {
        let dto = try JSONDecoder().decode(ProfileV3ProgrammesPageScreenDTO.self, from: Data(#"""
        {"programs":[
          {"id":"maharaja","name":"Maharaja Club","tier":"SILVER","expiry":"Expiring in Dec 2027",
           "updated_line":"Updated last email dated 24 Jun, 2:30 pm","last_updated_at":"2026-06-24T09:00:00Z"},
          {"id":"ihg","name":"IHG","updated_line":"Updated 24 Jun, 2:30 pm"},
          {"id":"aeroplan","name":"Aeroplan","tier":"  ","expiry":"","updated_line":" "}
        ]}
        """#.utf8))
        let programmes = ProfileV3LoyaltyMapper.overview(dto, profileID: "p1").programmes
        #expect(programmes.map(\.tier) == ["SILVER", nil, nil])
        #expect(programmes.map(\.expiryLabel) == ["Expiring in Dec 2027", nil, nil])
        #expect(programmes.map(\.updatedLine) == [
            "Updated last email dated 24 Jun, 2:30 pm", "Updated 24 Jun, 2:30 pm", nil
        ])
    }

    @Test func homeBoardRowsCarryTheSameKeys() throws {
        let dto = try JSONDecoder().decode(ProfileV3BoardDTO.self, from: Data(#"""
        {"profiles":[{"profile_id":"p1","loyalty_card":{"programs":[
          {"id":"maharaja","name":"Maharaja Club","tier":"GOLD","expiry":"Expiring in Dec 2027",
           "updated_line":"Updated last email dated 24 Jun"}
        ]}}]}
        """#.utf8))
        let programme = try #require(ProfileV3BoardMapper.board(dto).mainProfile?.pass.programmes.first)
        #expect(programme.tier == "GOLD")
        #expect(programme.expiryLabel == "Expiring in Dec 2027")
        #expect(programme.updatedLine == "Updated last email dated 24 Jun")
    }

    @Test func rowsShowTheFullMembershipNumber() throws {
        let dto = try JSONDecoder().decode(ProfileV3ProgrammesPageScreenDTO.self, from: Data(#"""
        {"programs":[
          {"id":"maharaja","name":"Maharaja Club","membership_number":"7391546551","last4":"6551"},
          {"id":"ihg","name":"IHG","last4":"1234"}
        ]}
        """#.utf8))
        let programmes = ProfileV3LoyaltyMapper.overview(dto, profileID: "p1").programmes
        #expect(programmes.map(\.displayNumber) == ["7391546551", ProfileV3Strings.maskedNumber("1234")])
    }

    @Test func cardRowsWithoutANumberShowNone() throws {
        let dto = try JSONDecoder().decode(ProfileV3ProgrammesPageScreenDTO.self, from: Data(#"""
        {"programs":[{"id":"hdfc_infinia","name":"HDFC Infinia","points":"12000"}]}
        """#.utf8))
        let programme = try #require(ProfileV3LoyaltyMapper.overview(dto, profileID: "p1").programmes.first)
        #expect(programme.displayNumber == nil)
    }

    @Test func catalogueKeepsTheServerOrderAndPlaceholderArt() throws {
        let dto = try JSONDecoder().decode(ProfileV3LoyaltyPickScreenDTO.self, from: Data(#"""
        {"programs":[
          {"id":"hdfc_infinia","name":"HDFC Infinia","kind":"credit_cards",
           "art":"https://media.atlys.com/cards/_fallback.png?v=20261018","art_placeholder":true,"text_overlay":"dark"},
          {"id":"maharaja","name":"Maharaja Club","kind":"flights",
           "art":"https://media.atlys.com/cards/maharaja.png?v=20261018","text_overlay":"light"}
        ]}
        """#.utf8))
        let items = ProfileV3LoyaltyMapper.picker(dto).items
        #expect(items.map(\.id) == ["hdfc_infinia", "maharaja"])
        #expect(items.map(\.isArtPlaceholder) == [true, false])
        #expect(items.map(\.textOverlay) == [.dark, .light])
        #expect(items.first?.cardImageURL?.query == "v=20261018")
    }

    @Test func creditCardFormAsksOnlyForPointsAndSendsNoMembershipNumber() throws {
        let dto = try JSONDecoder().decode(ProfileV3LoyaltyEnterScreenDTO.self, from: Data(#"""
        {"title":"Enter details","fields":[{"key":"points","label":"POINTS","required":false,"input":"number"}],
         "submit":{"label":"Add","action":"add_loyalty_program","program_id":"hdfc_infinia","kind":"credit_cards"}}
        """#.utf8))
        let form = ProfileV3LoyaltyMapper.entryForm(dto, programID: "hdfc_infinia", programName: nil, kind: nil)
        #expect(form.fields.map(\.key) == ["points"])

        let item = ProfileV3ProgrammeCatalogueItem(id: "hdfc_infinia", name: "HDFC Infinia", category: .creditCards)
        let submission = ProfileV3ProgrammeSubmission(item: item, membershipNumber: nil, points: 12000)
        let request = ProfileV3LoyaltyMapper.addProgrammeRequest(submission, profileID: "p1")
        let body = try JSONEncoder().encode(request)
        let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
        #expect(json["membership_number"] == nil)
        #expect(json["points"] as? String == "12000")
        #expect(json["kind"] as? String == "credit_cards")
    }

    @Test func flightMultiSelectKeepsALegacySingleValueAndSavesAList() throws {
        let dto = try JSONDecoder().decode(ProfileV3AgentScreenDTO.self, from: Data(#"""
        {"agent_type":"flight","fields":[
          {"key":"seat","label":"SEAT","input":"multi_select","value":"Window",
           "options":[{"value":"Window","label":"Window","selected":true},{"value":"Aisle","label":"Aisle"}]},
          {"key":"class","label":"CLASS","input":"multi_select","value":["Economy","Business"],
           "options":[{"value":"Economy","label":"Economy","selected":true},
                      {"value":"Business","label":"Business","selected":true},{"value":"First","label":"First"}]}
        ]}
        """#.utf8))
        let mapped = ProfileV3AgentMapper.flow(from: dto)
        guard case .preferences(let form) = mapped.flow else {
            Issue.record("expected a preferences form")
            return
        }
        guard case .chips(let seat) = form.sections[0].control, case .chips(let travelClass) = form.sections[1].control else {
            Issue.record("expected chips")
            return
        }
        #expect(seat.allowsMultiple)
        #expect(seat.selection == ["Window"])
        #expect(travelClass.selection == ["Economy", "Business"])

        let body = try ProfileV3AgentSubmission.body(for: form, profileID: "p1", residuals: mapped.residuals)
        let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
        let values = try #require(json["values"] as? [String: Any])
        #expect(values["seat"] as? [String] == ["Window"])
        #expect(values["class"] as? [String] == ["Economy", "Business"])
    }
}
