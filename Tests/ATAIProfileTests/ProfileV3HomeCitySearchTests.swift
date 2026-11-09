import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Home city search")
struct ProfileV3HomeCitySearchTests {
    @Test func onlyATextFieldMarkedForCitySearchSearchesCities() throws {
        let marked = try Self.flow(value: "Bangalore", search: "client_cities")
        guard case .text(let field) = marked.form.sections.first?.control else {
            Issue.record("expected a text field")
            return
        }
        #expect(field.search == .cities)
        #expect(field.value == "Bangalore")
        #expect(field.placeholder == "home city")

        for search in [nil, "", "client_hotels"] {
            let plain = try Self.flow(value: "Bangalore", search: search)
            guard case .text(let field) = plain.form.sections.first?.control else {
                Issue.record("expected a text field")
                return
            }
            #expect(field.search == nil)
        }
    }

    @Test func withoutTheHintOrAPlacesKeyTheFieldStaysTyped() throws {
        let unmarked = try Self.viewModel(search: nil, places: ProfileV3CitySearchStub(results: []))
        #expect(!unmarked.viewModel.canOpenPicker(for: "home_city"))
        unmarked.viewModel.openPicker(for: "home_city")
        #expect(unmarked.viewModel.pickerSectionID == nil)

        let keyless = try Self.viewModel(places: nil)
        #expect(!keyless.viewModel.canOpenPicker(for: "home_city"))
        #expect(!keyless.viewModel.searchesPlaces(in: "home_city"))
        keyless.viewModel.openPicker(for: "home_city")
        #expect(keyless.viewModel.pickerSectionID == nil)
    }

    @Test func theSearchOpensOnTheSavedCityThenListsCitiesRankedByResidence() async throws {
        let places = ProfileV3CitySearchStub(results: [
            ProfileV3PlaceSuggestion(id: "p1", name: "Mumbai", detail: "Maharashtra, India"),
            ProfileV3PlaceSuggestion(id: "p2", name: "mumbai ", detail: "Maharashtra, India"),
            ProfileV3PlaceSuggestion(id: "p3", name: "Mumbra", detail: "Maharashtra, India")
        ])
        let viewModel = try Self.viewModel(places: places, residence: "IN").viewModel
        #expect(viewModel.canOpenPicker(for: "home_city"))
        viewModel.openPicker(for: "home_city")
        #expect(viewModel.pickerSectionID == "home_city")
        #expect(viewModel.pickerOptions.map(\.title) == ["Bangalore"])
        #expect(viewModel.pickerSelection == ["Bangalore"])

        viewModel.searchPlaces("mum")
        #expect(viewModel.isSearchingPlaces)
        try await Self.waitUntil { !viewModel.isSearchingPlaces }
        #expect(places.requests == [ProfileV3CitySearchStub.Request(text: "mum", regionCode: "IN")])
        #expect(viewModel.pickerOptions.map(\.title) == ["Mumbai", "Mumbra"])
        #expect(viewModel.pickerOptions.map(\.subtitle) == ["Maharashtra, India", "Maharashtra, India"])
        #expect(viewModel.pickerOptions.map(\.place) == [.location, .location])
        #expect(viewModel.pickerListLabel == nil)
    }

    @Test func pickingACityFillsTheFieldClosesTheSearchAndSavesOnlyTheName() async throws {
        let places = ProfileV3CitySearchStub(results: [
            ProfileV3PlaceSuggestion(id: "p1", name: "New York", detail: "NY, USA")
        ])
        let (viewModel, residuals) = try Self.viewModel(value: "", places: places)
        #expect(!viewModel.showsSaveBar)
        viewModel.openPicker(for: "home_city")
        #expect(viewModel.pickerOptions.isEmpty)
        #expect(viewModel.pickerSelection.isEmpty)

        viewModel.searchPlaces("new  york")
        try await Self.waitUntil { !viewModel.isSearchingPlaces }
        #expect(places.requests.map(\.text) == ["new york"])
        viewModel.togglePickerOption("New York", in: "home_city")
        #expect(viewModel.pickerSectionID == nil)
        #expect(Self.value(of: viewModel) == "New York")
        #expect(viewModel.showsSaveBar)
        let saved = try Self.savedValues(viewModel.form, residuals: residuals)
        #expect(saved["home_city"] as? String == "New York")
    }

    @Test func theSavedCityIsTickedAndTappingItKeepsIt() async throws {
        let places = ProfileV3CitySearchStub(results: [
            ProfileV3PlaceSuggestion(id: "p1", name: "Mumbai", detail: "Maharashtra, India")
        ])
        let viewModel = try Self.viewModel(value: "mumbai", places: places).viewModel
        viewModel.openPicker(for: "home_city")
        viewModel.togglePickerOption("mumbai", in: "home_city")
        #expect(viewModel.pickerSectionID == nil)
        #expect(Self.value(of: viewModel) == "mumbai")
        #expect(!viewModel.showsSaveBar)

        viewModel.openPicker(for: "home_city")
        viewModel.searchPlaces("mum")
        try await Self.waitUntil { !viewModel.isSearchingPlaces }
        #expect(viewModel.pickerOptions.map(\.id) == ["mumbai"])
        #expect(viewModel.pickerOptions.map(\.title) == ["Mumbai"])
        #expect(viewModel.pickerSelection == ["mumbai"])
        viewModel.togglePickerOption("mumbai", in: "home_city")
        #expect(Self.value(of: viewModel) == "Mumbai")
        #expect(viewModel.showsSaveBar)
    }

    @Test func aSavedCityGoogleDoesNotSuggestStaysListedWhileItMatches() async throws {
        let places = ProfileV3CitySearchStub(results: [
            ProfileV3PlaceSuggestion(id: "p1", name: "Bengaluru", detail: "Karnataka, India")
        ])
        let viewModel = try Self.viewModel(places: places).viewModel
        viewModel.openPicker(for: "home_city")
        viewModel.searchPlaces("bang")
        try await Self.waitUntil { !viewModel.isSearchingPlaces }
        #expect(viewModel.pickerOptions.map(\.title) == ["Bangalore", "Bengaluru"])

        viewModel.searchPlaces("beng")
        try await Self.waitUntil { !viewModel.isSearchingPlaces }
        #expect(viewModel.pickerOptions.map(\.title) == ["Bengaluru"])
    }

    // MARK: - Helpers

    private static func viewModel(
        value: String = "Bangalore",
        search: String? = "client_cities",
        places: (any ProfileV3PlaceSearching)?,
        residence: String? = nil
    ) throws -> (viewModel: ProfileV3AgentFormViewModel, residuals: ProfileV3AgentResiduals) {
        let mapped = try flow(value: value, search: search)
        let viewModel = ProfileV3AgentFormViewModel(
            form: mapped.form,
            avatarURL: nil,
            repository: ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore()),
            placeSearch: places,
            residenceCode: { residence },
            onFinish: {}
        )
        return (viewModel, mapped.residuals)
    }

    private static func flow(
        value: String,
        search: String?
    ) throws -> (form: ProfileV3AgentForm, residuals: ProfileV3AgentResiduals) {
        let hint = search.map { #","search":"\#($0)""# } ?? ""
        let json = #"""
        {"agent_type":"personal","fields":[{"key":"home_city","label":"HOME CITY","input":"text",
         "assist":"Where you usually start your trips","derived":true,"value":"\#(value)"\#(hint)}]}
        """#
        let dto = try JSONDecoder().decode(ProfileV3AgentScreenDTO.self, from: Data(json.utf8))
        let mapped = ProfileV3AgentMapper.flow(from: dto)
        guard case .preferences(let form) = mapped.flow else {
            throw ProfileV3RepositoryError.unavailable
        }
        return (form, mapped.residuals)
    }

    private static func value(of viewModel: ProfileV3AgentFormViewModel) -> String? {
        guard case .text(let field)? = viewModel.form.sections.first?.control else { return nil }
        return field.value
    }

    private static func savedValues(
        _ form: ProfileV3AgentForm,
        residuals: ProfileV3AgentResiduals
    ) throws -> [String: Any] {
        let body = try ProfileV3AgentSubmission.body(for: form, profileID: nil, residuals: residuals)
        let object = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        return object?["values"] as? [String: Any] ?? [:]
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Swift.Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

@MainActor
private final class ProfileV3CitySearchStub: ProfileV3PlaceSearching {
    struct Request: Equatable {
        let text: String
        let regionCode: String?
    }

    let results: [ProfileV3PlaceSuggestion]
    private(set) var requests: [Request] = []

    init(results: [ProfileV3PlaceSuggestion]) {
        self.results = results
    }

    func cities(matching text: String, near regionCode: String?) async -> [ProfileV3PlaceSuggestion] {
        requests.append(Request(text: text, regionCode: regionCode))
        return results
    }

    func lodging(matching text: String, in scope: ProfileV3PlaceSearchScope) async -> [ProfileV3PlaceSuggestion] {
        []
    }

    func popularLodging(in scope: ProfileV3PlaceSearchScope, pageToken: String?) async -> ProfileV3PlacePage {
        ProfileV3PlacePage(places: [])
    }
}
