import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Home agent boxes")
struct ProfileV3AgentBoxTests {
    @Test func gmailStateComesFromTheMainProfilesMissingSteps() throws {
        let notConnected = try Self.board(mainKYC: #"{"required":["passport","selfie","gmail_connect"],"missing":["selfie","gmail_connect"]}"#)
        #expect(notConnected.profiles.map(\.home.isGmailConnected) == [false, false])

        let connected = try Self.board(mainKYC: #"{"required":["passport","selfie","gmail_connect"],"missing":["selfie"]}"#)
        #expect(connected.profiles.map(\.home.isGmailConnected) == [true, true])

        let unknown = try Self.board(mainKYC: nil)
        #expect(unknown.profiles.map(\.home.isGmailConnected) == [nil, nil])
    }

    @Test func activateShowsOnlyWithSavedPreferencesAndNoGmail() {
        let withPreferences = Self.agent(hasData: true)
        let withoutPreferences = Self.agent(hasData: false)

        #expect(!withoutPreferences.showsActivatePill(isGmailConnected: false))
        #expect(withPreferences.showsActivatePill(isGmailConnected: false))
        #expect(!withoutPreferences.showsActivatePill(isGmailConnected: true))
        #expect(!withPreferences.showsActivatePill(isGmailConnected: true))
    }

    @Test func unknownGmailFallsBackToTheTilesActivateCTA() {
        var gated = Self.agent(hasData: true)
        gated.activate = ProfileV3Directive(go: "agent")

        #expect(gated.showsActivatePill(isGmailConnected: nil))
        #expect(!Self.agent(hasData: true).showsActivatePill(isGmailConnected: nil))
    }

    @Test func liveBoardWithoutProfileKYCShowsActivateOnlyWhereTheServerSendsIt() throws {
        let board = try Self.board(mainKYC: nil, tiles: #"""
        [{"agent_type":"flight","name":"flight","updated_label":"updated",
          "activate":{"label":"ACTIVATE","next":{"go":"agent","agent_type":"flight"}},
          "next":{"go":"agent","agent_type":"flight"}},
         {"agent_type":"stay","name":"stay","updated_label":"","next":{"go":"agent","agent_type":"stay"}}]
        """#)
        let home = try #require(board.mainProfile?.home)

        #expect(home.isGmailConnected == nil)
        #expect(home.agents.map { $0.showsActivatePill(isGmailConnected: home.isGmailConnected) } == [true, false])
    }

    @Test func tappingAGatedAgentOpensItsPreferences() throws {
        let board = try Self.board(
            mainKYC: #"{"required":["passport","selfie","gmail_connect"],"missing":["gmail_connect"],"complete":false}"#,
            tiles: #"[{"agent_type":"flight","name":"flight","updated_label":"Updated today","next":{"go":"kyc_gate"}}]"#
        )
        let router = AgentRouterSpy()
        let viewModel = ProfileV3HubViewModel(repository: CachedBoardRepository(board: board))
        viewModel.router = router

        viewModel.tapAgent(try #require(viewModel.home?.agents.first))

        #expect(router.openedAgentsRequiringKYC == [false])
    }

    @Test(.timeLimit(.minutes(1)))
    func savingAnAgentFormTellsTheHubBeforeTheSheetCloses() async {
        var events: [String] = []
        let saved = ProfileV3AgentFormViewModel(
            form: ProfileV3AgentFixtures.flight,
            avatarURL: nil,
            repository: ProfileV3MockRepository(delay: .zero),
            onSaved: { events.append("saved") },
            onFinish: { events.append("closed") }
        )
        saved.save()
        while saved.saveState == .saving { await Task.yield() }
        #expect(saved.saveState == .saved)
        #expect(events == ["saved"])
        saved.cancelPendingWork()

        events = []
        let failed = ProfileV3AgentFormViewModel(
            form: ProfileV3AgentFixtures.flight,
            avatarURL: nil,
            repository: ProfileV3FailingRepository(),
            onSaved: { events.append("saved") },
            onFinish: { events.append("closed") }
        )
        failed.save()
        while failed.saveState == .saving { await Task.yield() }
        #expect(failed.saveState == .failed)
        #expect(events.isEmpty)
    }

    private static func agent(hasData: Bool) -> ProfileV3Agent {
        ProfileV3Agent(
            id: ProfileV3AgentID.flight.rawValue,
            name: "flight",
            summary: "",
            avatarURL: nil,
            isActive: hasData,
            hasData: hasData,
            foundCount: 0,
            totalCount: 0
        )
    }

    private static func board(mainKYC: String?, tiles: String = "[]") throws -> ProfileV3Board {
        let kyc = mainKYC.map { #","profile_kyc":\#($0)"# } ?? ""
        let json = #"""
        {"profiles":[
          {"profile_id":"main"\#(kyc),"sections":[{"kind":"agent_grid","tiles":\#(tiles)}]},
          {"profile_id":"co","profile_kyc":{"required":["passport","selfie"],"missing":[]}}
        ]}
        """#
        return ProfileV3BoardMapper.board(try JSONDecoder().decode(ProfileV3BoardDTO.self, from: Data(json.utf8)))
    }
}

private final class AgentRouterSpy: ProfileV3HubRouter {
    private(set) var openedAgentsRequiringKYC: [Bool] = []

    func openAgent(_ agent: ProfileV3Agent, requiresKYC: Bool, profileID: String?) {
        openedAgentsRequiringKYC.append(requiresKYC)
    }

    func goBack() {}
    func openSettings(profileID: String?) {}
    func openKnowMore(_ directive: ProfileV3Directive?) {}
    func openAddProgramme(requiresKYC: Bool, profileID: String?) {}
    func openProgrammes(for pass: ProfileV3WorldPass, passes: [ProfileV3WorldPass]) {}
    func openKYC() {}
    func openBenefitKYC(_ benefit: ProfileV3Benefit) {}
    func openAddTraveller() {}
}

private final class CachedBoardRepository: ProfileV3HubRepository, @unchecked Sendable {
    private let board: ProfileV3Board

    init(board: ProfileV3Board) {
        self.board = board
    }

    @MainActor func cachedBoard() -> ProfileV3Board? { board }
    func loadBoard() async throws -> ProfileV3Board { board }
    func loadLatestBoard() async throws -> ProfileV3Board { board }
    func loadBenefits(profileID: String?) async throws -> ProfileV3BenefitsSheet { throw CancellationError() }
    func loadBenefit(id: String) async throws -> ProfileV3Benefit? { nil }
    func redeemBenefit(id: String) async throws {}
    func loadCoupons() async throws -> ProfileV3CouponsSheet { throw CancellationError() }
    func loadCoupon(id: String) async throws -> ProfileV3CouponDetail? { nil }
    func loadPastTrips(profileID: String) async throws -> [ProfileV3PastTrip] { [] }
    func addPastTrip(_ draft: ProfileV3PastTripDraft, profileID: String) async throws -> ProfileV3PastTrip {
        throw CancellationError()
    }
    func updatePastTrip(id: String, with draft: ProfileV3PastTripDraft, profileID: String) async throws -> ProfileV3PastTrip {
        throw CancellationError()
    }
    func deletePastTrip(id: String, profileID: String) async throws {}
}
