import Foundation
import Moya
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Loyalty market")
struct ProfileV3LoyaltyMarketTests {
    @Test func theCatalogueCarriesItsMarketToggle() throws {
        let picker = try Self.picker(#"""
        {"type":"loyalty_pick","filters":["All","Credit cards","Hotels"],"programs":[],
         "market":{"options":[{"value":"in","label":"IN"},{"value":"world","label":"World"}],
                   "selected":"world","chips":["All","Credit cards"]}}
        """#)
        let market = try #require(picker.market)
        #expect(market == ProfileV3ProgrammeMarket(
            options: [
                ProfileV3ProgrammeMarket.Option(value: "in", label: "IN"),
                ProfileV3ProgrammeMarket.Option(value: "world", label: "World")
            ],
            selected: "world",
            chips: ["All", "Credit cards"]
        ))
        #expect(market.appliesTo(chip: "credit cards"))
        #expect(!market.appliesTo(chip: "Hotels"))
        #expect(market.options.map(\.countryCode) == ["IN", nil])
    }

    @Test func anIncompleteMarketIsDroppedOrFallsBackToTheFirstOption() throws {
        let missing = try Self.picker(#"{"filters":["All"],"programs":[]}"#)
        #expect(missing.market == nil)
        let single = try Self.picker(#"{"programs":[],"market":{"options":[{"value":"in","label":"IN"}],"selected":"in"}}"#)
        #expect(single.market == nil)
        let unlabelled = try Self.picker(#"""
        {"programs":[],"market":{"options":[{"value":"in"},{"value":"world","label":"World"},{"value":"us","label":"US"}],
         "selected":"mars","chips":"All"}}
        """#)
        #expect(unlabelled.market?.options.map(\.value) == ["world", "us"])
        #expect(unlabelled.market?.selected == "world")
        #expect(unlabelled.market?.chips == [])
    }

    @Test func theMarketIsAQueryParameterOnlyWhenSet() {
        #expect(Self.parameters(.loyaltyCatalogue(query: nil, kind: nil, market: nil)).isEmpty)
        let parameters = Self.parameters(.loyaltyCatalogue(query: "air", kind: "Credit cards", market: "world"))
        #expect(parameters["market"] as? String == "world")
        #expect(parameters["q"] as? String == "air")
        #expect(parameters["kind"] as? String == "Credit cards")
    }

    @Test(.timeLimit(.minutes(1)))
    func thePickerPreselectsTheServersMarketThenSendsItOnEveryRequest() async throws {
        let repository = MarketStub()
        let viewModel = ProfileV3AddProgrammeViewModel(requiresKYC: false, repository: repository)

        await viewModel.start()
        try await Self.waitUntil { !viewModel.isLoadingCatalogue }
        #expect(await repository.markets == [nil])
        #expect(viewModel.selectedMarket == "in")
        #expect(viewModel.selectedMarketOption?.label == "IN")
        #expect(viewModel.showsMarketToggle)

        let cards = try #require(viewModel.filters.first { $0.category == .creditCards })
        viewModel.selectFilter(cards)
        try await Self.waitUntil { !viewModel.isLoadingCatalogue }
        #expect(await repository.markets == [nil, "in"])
        #expect(viewModel.showsMarketToggle)

        let hotels = try #require(viewModel.filters.first { $0.category == .hotels })
        viewModel.selectFilter(hotels)
        try await Self.waitUntil { !viewModel.isLoadingCatalogue }
        #expect(await repository.markets == [nil, "in", "in"])
        #expect(!viewModel.showsMarketToggle)

        let allFilter = viewModel.filters.first { $0.isAll }
        let all = try #require(allFilter)
        viewModel.selectFilter(all)
        try await Self.waitUntil { !viewModel.isLoadingCatalogue }
        viewModel.selectMarket("world")
        try await Self.waitUntil { !viewModel.isLoadingCatalogue }
        #expect(await repository.markets == [nil, "in", "in", "in", "world"])
        #expect(viewModel.selectedMarketOption?.label == "World")

        viewModel.selectMarket("mars")
        viewModel.query = "air"
        try await Self.waitUntil { await repository.markets.count == 6 }
        #expect(await repository.markets.last == "world")
        #expect(await repository.queries.last == "air")
    }

    private static func picker(_ json: String) throws -> ProfileV3ProgrammePicker {
        let dto = try JSONDecoder().decode(ProfileV3LoyaltyPickScreenDTO.self, from: Data(json.utf8))
        return ProfileV3LoyaltyMapper.picker(dto)
    }

    private static func parameters(_ endpoint: ProfileV3API) -> [String: Any] {
        guard case .requestParameters(let parameters, _) = endpoint.task else { return [:] }
        return parameters
    }

    private static func waitUntil(_ condition: () async -> Bool) async throws {
        for _ in 0 ..< 200 where !(await condition()) {
            try await Swift.Task.sleep(for: .milliseconds(25))
        }
        #expect(await condition())
    }
}

private actor MarketStub: ProfileV3LoyaltyRepository {
    private let mock = ProfileV3MockRepository(delay: .zero)
    private(set) var markets: [String?] = []
    private(set) var queries: [String?] = []

    nonisolated func scanProgrammes() -> AsyncThrowingStream<ProfileV3ProgrammeScanEvent, Error> {
        mock.scanProgrammes()
    }

    func loadProgrammeCatalogue(query: String?, kind: String?, market: String?) async throws -> ProfileV3ProgrammePicker {
        markets.append(market)
        queries.append(query)
        return try await mock.loadProgrammeCatalogue(query: query, kind: kind, market: market)
    }

    func loadLoyaltyEntry(programID: String, programName: String?, kind: String?) async throws -> ProfileV3LoyaltyEntryForm {
        try await mock.loadLoyaltyEntry(programID: programID, programName: programName, kind: kind)
    }

    func loadProgrammeInsight(programID: String, profileID: String?) async throws -> ProfileV3ProgrammeInsight {
        try await mock.loadProgrammeInsight(programID: programID, profileID: profileID)
    }

    func loadProgrammeSources(programID: String, profileID: String?) async throws -> ProfileV3PreferenceSources {
        try await mock.loadProgrammeSources(programID: programID, profileID: profileID)
    }

    func addProgramme(_ submission: ProfileV3ProgrammeSubmission, profileID: String?) async throws {}

    func loadProgrammes(passID: String) async throws -> ProfileV3ProgrammeOverview {
        try await mock.loadProgrammes(passID: passID)
    }

    func removeProgramme(id: String, name: String, profileID: String) async throws {}

    func reorderProgrammes(_: [String], profileID _: String, action _: String) async throws {}
}
