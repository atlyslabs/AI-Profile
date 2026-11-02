import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Agent preference fields")
struct ProfileV3AgentPreferenceFieldsTests {
    @Test func theMoneySliderShowsSymbolCompactAmountAndUnitOnTheFieldsTrack() throws {
        let inr = try Self.slider(#"""
        {"key":"time_value_per_hour","label":"PAY MORE TO SAVE TIME?","input":"slider","low":"Cheapest","high":"Fastest",
         "min":0,"max":20000,"step":500,"unit":"/hour","display":"money","currency":{"code":"INR","symbol":"₹"},"value":10000}
        """#)
        #expect(inr.range == 0 ... 20_000)
        #expect(inr.step == 500)
        #expect(inr.style == .ruler)
        #expect(inr.readout?.value == "₹10K/hour")
        #expect(inr.previewing(1_500).readout?.value == "₹1.5K/hour")
        #expect(inr.previewing(0).readout?.value == "₹0/hour")

        let usd = try Self.slider(#"""
        {"key":"time_value_per_hour","input":"slider","min":0,"max":250,"step":5,"unit":"/hour",
         "display":"money","currency":{"code":"USD","symbol":"$"},"value":120}
        """#)
        #expect(usd.range == 0 ... 250)
        #expect(usd.step == 5)
        #expect(usd.readout?.value == "$120/hour")

        let aed = try Self.slider(#"""
        {"key":"time_value_per_hour","input":"slider","min":0,"max":1000,"step":25,"unit":"/hour",
         "display":"money","currency":{"code":"AED","symbol":"AED"},"value":50}
        """#)
        #expect(aed.readout?.value == "AED 50/hour")
        #expect(ProfileV3SliderField.compactAmount(1_250_000) == "1.3M")
    }

    @Test func anUnsetSliderSavesNullUntilItIsMoved() throws {
        let mapped = try Self.flow(agentType: "flight", fields: #"""
        [{"key":"time_value_per_hour","label":"PAY MORE TO SAVE TIME?","input":"slider","min":0,"max":20000,"step":500,
          "unit":"/hour","display":"money","currency":{"code":"INR","symbol":"₹"},"value":null}]
        """#)
        guard case .slider(let field) = mapped.form.sections.first?.control else {
            Issue.record("expected a slider")
            return
        }
        #expect(!field.isSet)
        #expect(field.value == 10_000)
        let untouched = try Self.savedValues(mapped.form, residuals: mapped.residuals)
        #expect(untouched["time_value_per_hour"] is NSNull)

        let viewModel = ProfileV3AgentFormViewModel(
            form: mapped.form,
            avatarURL: nil,
            repository: ProfileV3MockRepository(delay: .zero),
            onFinish: {}
        )
        viewModel.setSliderValue(12_500, in: "time_value_per_hour")
        let moved = try Self.savedValues(viewModel.form, residuals: mapped.residuals)
        #expect(moved["time_value_per_hour"] as? Double == 12_500)
    }

    @Test func hotelClassShowsTheLabelsAndSavesTheValue() throws {
        let mapped = try Self.flow(agentType: "stay", fields: #"""
        [{"key":"hotel_class","label":"HOTEL CLASS","input":"single_select","assist":"The lowest star rating you'll stay at",
          "options":[{"value":"3 star and above","label":"3★ and above"},{"value":"4 star and above","label":"4★ and above"},
                     {"value":"5 star only","label":"5★ only"}],
          "value":"4 star and above"}]
        """#)
        guard case .chips(let field) = mapped.form.sections.first?.control else {
            Issue.record("expected chips")
            return
        }
        #expect(field.options.map(\.title) == ["3★ and above", "4★ and above", "5★ only"])
        #expect(field.selection == ["4 star and above"])
        #expect(!field.allowsMultiple)
        #expect(field.picker == nil)
        let saved = try Self.savedValues(mapped.form, residuals: mapped.residuals)
        #expect(saved["hotel_class"] as? String == "4 star and above")
    }

    @Test func avoidAirlinesIsAnAddablePickerLikePreferredAirlines() throws {
        let mapped = try Self.flow(agentType: "flight", fields: #"""
        [{"key":"avoid_airlines","label":"AVOID AIRLINES","input":"multi_select_add","assist":"I'll leave these out when I search",
          "options":[{"value":"IndiGo","label":"IndiGo","image_url":"https://media.atlys.com/b2c/ai-native/airlines/6E.png"},
                     {"value":"SpiceJet","label":"SpiceJet","image_url":"https://media.atlys.com/b2c/ai-native/airlines/SG.png"}],
          "value":["IndiGo"]}]
        """#)
        let section = try #require(mapped.form.sections.first)
        guard case .chips(let field) = section.control else {
            Issue.record("expected chips")
            return
        }
        #expect(section.title == "AVOID AIRLINES")
        #expect(section.note?.text == "I'll leave these out when I search")
        #expect(field.allowsMultiple)
        #expect(field.picker?.catalogue.map(\.id) == ["IndiGo", "SpiceJet"])
        #expect(field.options.allSatisfyLogo)
        #expect(field.selection == ["IndiGo"])
        let saved = try Self.savedValues(mapped.form, residuals: mapped.residuals)
        #expect(saved["avoid_airlines"] as? [String] == ["IndiGo"])
    }

    @Test func aHundredHotelGroupsStayInThePickerAndOnlyTheChosenShowInline() throws {
        let options = (1 ... 100).map { #"{"value":"chain-\#($0)","label":"Chain \#($0)","image_url":"https://media.atlys.com/b2c/ai-native/hotels/chain-\#($0).png"}"# }
        let mapped = try Self.flow(agentType: "stay", fields: #"""
        [{"key":"preferred_hotels","label":"PREFERRED HOTELS","input":"multi_select_add","options":[\#(options.joined(separator: ","))],
          "value":["chain-7"]}]
        """#)
        guard case .chips(let field) = mapped.form.sections.first?.control else {
            Issue.record("expected chips")
            return
        }
        #expect(field.picker?.catalogue.count == 100)
        #expect(field.visibleOptions(limit: 8).map(\.id) == ["chain-7"])
        #expect(field.remainingOptions(limit: 8).count == 99)
    }

    private static func slider(_ fieldJSON: String) throws -> ProfileV3SliderField {
        let mapped = try flow(agentType: "flight", fields: "[\(fieldJSON)]")
        guard case .slider(let field) = mapped.form.sections.first?.control else {
            throw ProfileV3RepositoryError.unavailable
        }
        return field
    }

    private static func flow(
        agentType: String,
        fields: String
    ) throws -> (form: ProfileV3AgentForm, residuals: ProfileV3AgentResiduals) {
        let json = #"{"agent_type":"\#(agentType)","fields":\#(fields)}"#
        let dto = try JSONDecoder().decode(ProfileV3AgentScreenDTO.self, from: Data(json.utf8))
        let mapped = ProfileV3AgentMapper.flow(from: dto)
        guard case .preferences(let form) = mapped.flow else {
            throw ProfileV3RepositoryError.unavailable
        }
        return (form, mapped.residuals)
    }

    private static func savedValues(
        _ form: ProfileV3AgentForm,
        residuals: ProfileV3AgentResiduals
    ) throws -> [String: Any] {
        let body = try ProfileV3AgentSubmission.body(for: form, profileID: nil, residuals: residuals)
        let object = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        return object?["values"] as? [String: Any] ?? [:]
    }
}

private extension Array where Element == ProfileV3ChipOption {
    var allSatisfyLogo: Bool { !isEmpty && allSatisfy { $0.logoURL != nil } }
}
