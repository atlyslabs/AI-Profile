import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Home agent boxes")
struct ProfileV3AgentBoxTests {
    @Test func anEmptyAgentHeadingKeepsOnlyTheEmphasis() throws {
        let home = try #require(Self.board(
            mainKYC: nil,
            grid: #","heading":"","heading_emphasis":"Travel preferences""#
        ).mainProfile?.home)
        #expect(home.agentsHeading == nil)
        #expect(home.agentsHeadingEmphasis == "Travel preferences")
    }

    @Test func gmailStateComesFromTheMainProfilesMissingSteps() throws {
        let notConnected = try Self.board(mainKYC: #"{"required":["passport","selfie","gmail_connect"],"missing":["selfie","gmail_connect"]}"#)
        #expect(notConnected.profiles.map(\.home.isGmailConnected) == [false, false])

        let connected = try Self.board(mainKYC: #"{"required":["passport","selfie","gmail_connect"],"missing":["selfie"]}"#)
        #expect(connected.profiles.map(\.home.isGmailConnected) == [true, true])

        let unknown = try Self.board(mainKYC: nil)
        #expect(unknown.profiles.map(\.home.isGmailConnected) == [nil, nil])
    }

    @Test func activateShowsOnlyWhenTheServerSendsIt() {
        var shown = Self.agent(hasData: false)
        shown.activate = ProfileV3Directive(go: "agent")

        #expect(shown.showsActivatePill())
        #expect(!Self.agent(hasData: true).showsActivatePill())
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
        #expect(home.agents.map { $0.showsActivatePill() } == [true, false])
    }

    @Test func tappingATileFollowsItsNextDirectiveAndFallsBackToPreferences() throws {
        let board = try Self.board(
            mainKYC: #"{"required":["passport","selfie","gmail_connect"],"missing":["gmail_connect"],"complete":false}"#,
            tiles: #"""
            [{"agent_type":"flight","name":"flight","updated_label":"Updated today",
              "next":{"go":"agent","agent_type":"flight","profile_id":"co"}},
             {"agent_type":"stay","name":"stay","next":{"go":"kyc_gate"}},
             {"agent_type":"food","name":"food"},
             {"agent_type":"mystery","name":"mystery","next":{"go":"somewhere_new"}}]
            """#
        )
        let router = AgentRouterSpy()
        let viewModel = ProfileV3HubViewModel(repository: CachedBoardRepository(board: board))
        viewModel.router = router

        let agents = try #require(viewModel.home?.agents)
        agents.forEach(viewModel.tapAgent)

        #expect(router.openedAgentsRequiringKYC == [false, false, false])
        #expect(router.openedAgentProfileIDs == ["co", "main", "main"])
    }

    @Test func loyaltyCardOpensTheListUnlessTheServerSendsAKYCStep() throws {
        func tap(next: String) throws -> AgentRouterSpy {
            let json = #"""
            {"profiles":[{"profile_id":"main","is_main":true,"worldpass_card":{"kyc_complete":false},
                          "loyalty_card":{"next":\#(next)}}]}
            """#
            let board = ProfileV3BoardMapper.board(try JSONDecoder().decode(ProfileV3BoardDTO.self, from: Data(json.utf8)))
            let pass = try #require(board.mainProfile?.pass)
            #expect(!pass.kycStatus.isComplete)
            let router = AgentRouterSpy()
            let viewModel = ProfileV3HubViewModel(repository: CachedBoardRepository(board: board))
            viewModel.router = router
            viewModel.tapOpenProgrammes(pass)
            return router
        }

        let list = try tap(next: #"{"go":"programs_page","profile_id":"main"}"#)
        #expect(list.openedProgrammeIDs == ["main"])
        #expect(list.openedAddProgrammesRequiringKYC.isEmpty)

        let gated = try tap(next: #"{"go":"kyc_gate"}"#)
        #expect(gated.openedProgrammeIDs.isEmpty)
        #expect(gated.openedAddProgrammesRequiringKYC == [true])
    }

    @Test func carPickupAssistLinkUnderlinesItsRunAndOpensRideRegions() throws {
        let mapped = try Self.flow(agentType: "airport_logistics", fields: #"""
        [{"key":"car_pickup","label":"PICK YOUR RIDE","input":"car_pickup",
          "assist":"Book your ride on the app. Available in selected regions",
          "assist_link":{"text":"selected regions","next":{"go":"ride_regions"}},
          "options":[{"value":"tesla_cybertruck","label":"Tesla Cybertruck"}]},
         {"key":"pickup_type","label":"PICK UP TYPE","input":"single_select",
          "assist":"Public or private","assist_link":{"text":"not in the text","next":{"go":"ride_regions"}},
          "options":[{"value":"public","label":"Public"}]}]
        """#)
        let pickup = try #require(mapped.form.sections.first?.note)
        #expect(pickup.text == "Book your ride on the app. Available in selected regions")
        #expect(pickup.link?.text == "selected regions")
        #expect(pickup.link?.directive.route() == .rideRegions)
        #expect(mapped.form.sections.last?.note?.link == nil)
    }

    @Test func rideRegionsKeepTheServerOrderVersionedURLsAndAspect() throws {
        let dto = try JSONDecoder().decode(ProfileV3RideRegionsScreenDTO.self, from: Data(#"""
        {"type":"ride_regions","title":"Pick your ride","heading":"Skip the queue not the ride",
         "divider_label":"Now available in","regions":[
          {"country":"AE","name":"Dubai","image_url":"https://media.atlys.com/b2c/ai-native/cars/regions/dubai.png?v=20261018","image_aspect":1.819},
          {"country":"AE","name":"Abu Dhabi","image_url":"https://media.atlys.com/b2c/ai-native/cars/regions/abu_dhabi.png"},
          {"country":"QA","name":"Doha"}
        ]}
        """#.utf8))
        let screen = ProfileV3AgentMapper.rideRegions(dto)
        #expect(screen.title == "Pick your ride")
        #expect(screen.heading == "Skip the queue not the ride")
        #expect(screen.dividerLabel == "Now available in")
        #expect(screen.regions.map(\.name) == ["Dubai", "Abu Dhabi"])
        #expect(Set(screen.regions.map(\.id)).count == 2)
        #expect(screen.regions.first?.imageURL?.query == "v=20261018")
        let aspects = screen.regions.map(\.aspectRatio)
        #expect(abs((aspects.first ?? 0) - 1.819) < 0.0001)
        #expect(aspects.last == ProfileV3Theme.Sizes.RideRegions.fallbackAspect)
    }

    @Test func onlyARideRegionsLinkOpensTheRegionsSheet() {
        let viewModel = ProfileV3AgentFormViewModel(
            form: ProfileV3AgentFixtures.airportLogistics,
            avatarURL: nil,
            repository: ProfileV3MockRepository(),
            onFinish: {}
        )
        viewModel.openNoteLink(ProfileV3Directive(go: "settings"))
        #expect(viewModel.rideRegions == nil)
        viewModel.openNoteLink(ProfileV3Directive(go: "ride_regions"))
        let sheet = viewModel.rideRegions
        #expect(sheet != nil)
        viewModel.openNoteLink(ProfileV3Directive(go: "ride_regions"))
        #expect(viewModel.rideRegions === sheet)
        sheet?.close()
        #expect(viewModel.rideRegions == nil)
    }

    @Test func travelPersonaTileIsKeptAndRouted() throws {
        let board = try Self.board(mainKYC: nil, tiles: #"""
        [{"agent_type":"travel_persona","name":"travel persona","title":"TRAVEL PERSONA",
          "icon":"orb_personal","blurb":"","updated_label":"",
          "next":{"go":"travel_persona","profile_id":"main"}}]
        """#)
        let agent = try #require(board.mainProfile?.home.agents.first)
        #expect(agent.id == "travel_persona")
        #expect(agent.avatarURL == ProfileV3PlaceholderArt.agentPersonal.url)
        #expect(agent.showsActivatePill() == false)

        let router = AgentRouterSpy()
        let viewModel = ProfileV3HubViewModel(repository: CachedBoardRepository(board: board))
        viewModel.router = router
        viewModel.tapAgent(agent)

        #expect(router.openedTravelPersonaIDs == ["main"])
        #expect(router.openedAgentsRequiringKYC.isEmpty)
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

    @Test(.timeLimit(.minutes(1)))
    func savingKeepsTheAgentOpenAndClearsTheSaveBar() async throws {
        var events: [String] = []
        let viewModel = ProfileV3AgentFormViewModel(
            form: ProfileV3AgentFixtures.flight,
            avatarURL: nil,
            repository: ProfileV3MockRepository(delay: .zero),
            onSaved: { events.append("saved") },
            onFinish: { events.append("closed") }
        )
        let change = try #require(viewModel.form.sections.lazy.compactMap { section -> (section: String, option: String)? in
            guard case .chips(let field) = section.control,
                  let option = field.allOptions.first(where: { !field.selection.contains($0.id) }) else { return nil }
            return (section.id, option.id)
        }.first)
        viewModel.toggleOption(change.option, in: change.section)
        #expect(viewModel.showsSaveBar)

        viewModel.save()
        while viewModel.saveState == .saving || viewModel.saveState == .idle { await Task.yield() }
        #expect(viewModel.saveState == .saved)
        while viewModel.saveState == .saved { try await Task.sleep(for: .milliseconds(50)) }
        #expect(viewModel.saveState == .idle)
        #expect(!viewModel.showsSaveBar)
        #expect(events == ["saved"])

        viewModel.tapBack()
        #expect(events == ["saved", "closed"])
    }

    @Test(.timeLimit(.minutes(1)))
    func applyingToTheHouseholdClosesOnlyItsSheet() async throws {
        var form = ProfileV3AgentFixtures.flight
        form.household = ProfileV3HouseholdPrompt(
            eyebrow: "",
            iconURL: nil,
            title: "Apply to",
            travellers: [ProfileV3HouseholdPrompt.Traveller(id: "main", name: "Me", passNumber: "", isSelected: true)],
            confirmLabel: "Apply"
        )
        var events: [String] = []
        func makeViewModel() -> ProfileV3AgentFormViewModel {
            ProfileV3AgentFormViewModel(
                form: form,
                avatarURL: nil,
                repository: ProfileV3MockRepository(delay: .zero),
                onSaved: { events.append("saved") },
                onFinish: { events.append("closed") }
            )
        }

        let waited = makeViewModel()
        waited.save()
        waited.confirmHousehold()
        while waited.householdApply?.phase != .saved { await Task.yield() }
        while waited.householdApply != nil { try await Task.sleep(for: .milliseconds(50)) }
        #expect(waited.saveState == .idle)
        #expect(events == ["saved"])

        events = []
        let closed = makeViewModel()
        closed.save()
        closed.confirmHousehold()
        while closed.householdApply?.phase != .saved { await Task.yield() }
        closed.closeHousehold()
        #expect(closed.householdApply == nil)
        #expect(closed.saveState == .idle)
        #expect(events == ["saved"])
    }

    @Test func fieldSourcesCarryTheServerCountLabelAndLogos() throws {
        let mapped = try Self.flow(agentType: "airport_logistics", fields: #"""
        [{"key":"pickup_type","label":"PICK UP TYPE","input":"multi_select","options":[{"value":"public","label":"Public"}],
          "source":{"icon":"https://media.atlys.com/gmail.png","count":3,"label":"sources",
                    "icons":[{"image_url":"https://media.atlys.com/ek.png"},"https://media.atlys.com/ai.png","gmail"],
                    "next":{"go":"preference_sources","field_key":"pickup_type"}}},
         {"key":"bags","label":"BAGS","input":"multi_select","options":[{"value":"cabin","label":"Cabin"}],
          "source":{"icon":"https://media.atlys.com/gmail.png","count":0,"label":" ",
                    "next":{"go":"preference_sources","agent_type":"flight","field_key":"bags"}}}]
        """#)
        let sections = mapped.form.sections
        try #require(sections.count == 2)
        let logo: (String) -> ProfileV3SourceIcon = { ProfileV3SourceIcon(url: URL(string: "https://media.atlys.com/\($0).png")) }

        let counted = try #require(sections[0].source)
        #expect(counted == ProfileV3SectionSource(
            icons: [logo("ek"), logo("ai")],
            count: 3,
            label: "sources",
            agentType: "airport_logistics",
            fieldKey: "pickup_type"
        ))
        #expect(ProfileV3SectionSourcesRow.caption(for: counted) == ProfileV3Strings.sourcesCount(3, label: "sources"))

        let bare = try #require(sections[1].source)
        #expect(bare == ProfileV3SectionSource(icons: [logo("gmail")], agentType: "flight", fieldKey: "bags"))
        #expect(ProfileV3SectionSourcesRow.caption(for: bare) == nil)

        var unlabelled = bare
        unlabelled.count = 2
        #expect(ProfileV3SectionSourcesRow.caption(for: unlabelled) == ProfileV3Strings.sourcesCount(2))
    }

    @Test func imperialHeightReadsAsFeetAndInchesAndSavesTheInchValue() throws {
        let mapped = try Self.flow(fields: #"""
        [{"key":"height_cm","label":"HEIGHT","input":"slider","unit":"in","display":"ft_in","min":47,"max":87,"value":71}]
        """#)
        guard case .slider(let field) = mapped.form.sections.first?.control else {
            Issue.record("expected a slider")
            return
        }
        #expect(field.value == 71)
        #expect(field.readout?.value == "5'11\"")
    }

    @Test func anniversaryKeepsTheDayAndMonthAndSubmitsYear2000() throws {
        let mapped = try Self.flow(fields: #"""
        [{"key":"anniversary","label":"ANNIVERSARY","input":"date","format":"dd_mm","value":"1994-02-14"}]
        """#)
        guard case .date(let field) = mapped.form.sections.first?.control else {
            Issue.record("expected a date")
            return
        }
        #expect(field.hidesYear)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent
        let parts = calendar.dateComponents([.year, .month, .day], from: try #require(field.value))
        #expect(parts.year == 2000)
        #expect(parts.month == 2)
        #expect(parts.day == 14)

        let body = try JSONDecoder().decode(SavedAgent.self, from: ProfileV3AgentSubmission.body(
            for: mapped.form,
            profileID: nil,
            residuals: mapped.residuals
        ))
        #expect(body.values["anniversary"]?.string == "2000-02-14")
    }

    @Test func householdSaveOpensTheSheetAndSubmitsEveryTickedTraveller() throws {
        let mapped = try Self.flow(agentType: "flight", fields: "[]", save: #"""
        "save":{"action":"save_agent_preferences","agent_type":"flight","household":{
          "eyebrow":"Flight agent","title":"Apply preferences\nfor household members",
          "travelers":[
            {"profile_id":"main","name":"mohak n.","pass_number":"6190001","selected":true},
            {"profile_id":"guest","name":"abhishek","pass_number":"6190001","selected":false}
          ],
          "confirm":{"label":"Confirm"}
        }}
        """#)
        let household = try #require(mapped.form.household)
        #expect(household.confirmLabel == "Confirm")
        #expect(household.travellers.map(\.id) == ["main", "guest"])
        #expect(household.travellers.map(\.isSelected) == [true, false])

        let body = try JSONDecoder().decode(SavedAgent.self, from: ProfileV3AgentSubmission.body(
            for: mapped.form,
            profileID: "main",
            residuals: mapped.residuals,
            profileIDs: ["main", "guest"]
        ))
        #expect(body.profileIDs == ["main", "guest"])
        #expect(body.action == "save_agent_preferences")

        let alone = try JSONDecoder().decode(SavedAgent.self, from: ProfileV3AgentSubmission.body(
            for: mapped.form,
            profileID: "main",
            residuals: mapped.residuals
        ))
        #expect(alone.profileIDs == nil)

        let parsed = ProfileV3ErrorEnvelope.parse(Data(#"""
        {"code":"preferences_write_failed","message":"Some travellers were not saved.",
         "details":{"failed_profile_ids":["guest"],"saved_profile_ids":["main"]}}
        """#.utf8))
        #expect(parsed?.failedProfileIDs == ["guest"])
        #expect(parsed?.savedProfileIDs == ["main"])
    }

    @Test func aSaveWithoutHouseholdStaysADirectSave() throws {
        let mapped = try Self.flow(fields: "[]")
        #expect(mapped.form.household == nil)
    }

    @Test func aNinthMealOptionStaysOnTheCardGrid() throws {
        let mapped = try Self.flow(fields: #"""
        [{"key":"airline_meal","label":"PREFERRED AIRLINE MEAL","input":"single_select",
          "options":[
            {"value":"AVML","label":"AVML","sub":"vegetarian (asian)"},
            {"value":"VGML","label":"VGML","sub":"vegan, no animal products"},
            {"value":"VJML","label":"VJML","sub":"jain - no root veggies"},
            {"value":"MOML","label":"MOML","sub":"halal/muslim meal"},
            {"value":"KSML","label":"KSML","sub":"kosher, sealed on board"},
            {"value":"GFML","label":"GFML","sub":"gluten free"},
            {"value":"SFML","label":"SFML","sub":"seafood"},
            {"value":"DBML","label":"DBML","sub":"diabetic-friendly"},
            {"code":"HNML","label":"HNML","sub":"hindu meal"}
          ]}]
        """#)
        guard case .cards(let field) = mapped.form.sections.first?.control else {
            Issue.record("expected meal cards")
            return
        }
        #expect(field.options.map(\.code) == ["AVML", "VGML", "VJML", "MOML", "KSML", "GFML", "SFML", "DBML", "HNML"])
        #expect(field.options.last?.detail == "hindu meal")
    }

    @Test func singleSelectPreselectsAPlainStringValue() throws {
        let mapped = try Self.flow(fields: #"""
        [{"key":"organ_donor","input":"single_select","value":"yes",
          "options":[{"value":"yes","label":"Yes"},{"value":"no","label":"No"}]}]
        """#)
        guard case .chips(let field) = mapped.form.sections.first?.control else {
            Issue.record("expected chips")
            return
        }
        #expect(field.selection == ["yes"])
    }

    @Test func aMissingGlobeStatShowsADashAndDistanceUsesTheServerUnit() throws {
        let miles = try JSONDecoder().decode(ProfileV3GlobeStatDTO.self, from: Data(#"{"key":"distance","label":"Distance","value":128934,"unit":"mi"}"#.utf8))
        let empty = try JSONDecoder().decode(ProfileV3GlobeStatDTO.self, from: Data(#"{"key":"airports","label":"Airports","value":null}"#.utf8))
        let distance = try #require(ProfileV3GlobeMapper.stat(miles))
        #expect(distance.displayValue == "\(128_934.formatted()) mi")
        #expect(ProfileV3GlobeMapper.stat(empty)?.displayValue == "--")
    }

    private static func flow(
        agentType: String = "medical",
        fields: String,
        save: String = ""
    ) throws -> (form: ProfileV3AgentForm, residuals: ProfileV3AgentResiduals) {
        let saveField = save.isEmpty ? "" : ",\(save)"
        let json = #"{"agent_type":"\#(agentType)","fields":\#(fields)\#(saveField)}"#
        let dto = try JSONDecoder().decode(ProfileV3AgentScreenDTO.self, from: Data(json.utf8))
        let mapped = ProfileV3AgentMapper.flow(from: dto)
        guard case .preferences(let form) = mapped.flow else {
            throw ProfileV3RepositoryError.unavailable
        }
        return (form, mapped.residuals)
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

    private static func board(mainKYC: String?, tiles: String = "[]", grid: String = "") throws -> ProfileV3Board {
        let kyc = mainKYC.map { #","profile_kyc":\#($0)"# } ?? ""
        let json = #"""
        {"profiles":[
          {"profile_id":"main"\#(kyc),"sections":[{"kind":"agent_grid","tiles":\#(tiles)\#(grid)}]},
          {"profile_id":"co","profile_kyc":{"required":["passport","selfie"],"missing":[]}}
        ]}
        """#
        return ProfileV3BoardMapper.board(try JSONDecoder().decode(ProfileV3BoardDTO.self, from: Data(json.utf8)))
    }
}

private struct SavedAgent: Decodable {
    struct Value: Decodable {
        let string: String?

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            string = try? container.decode(String.self)
        }
    }

    let action: String?
    let values: [String: Value]
    let profileIDs: [String]?

    enum CodingKeys: String, CodingKey {
        case action
        case values
        case profileIDs = "profile_ids"
    }
}

private final class AgentRouterSpy: ProfileV3HubRouter {
    private(set) var openedAgentsRequiringKYC: [Bool] = []
    private(set) var openedAgentProfileIDs: [String?] = []
    private(set) var openedTravelPersonaIDs: [String?] = []
    private(set) var openedProgrammeIDs: [String] = []
    private(set) var openedAddProgrammesRequiringKYC: [Bool] = []

    func openAgent(_ agent: ProfileV3Agent, requiresKYC: Bool, profileID: String?) {
        openedAgentsRequiringKYC.append(requiresKYC)
        openedAgentProfileIDs.append(profileID)
    }

    func openTravelPersona(profileID: String?) {
        openedTravelPersonaIDs.append(profileID)
    }

    func goBack() {}
    func openSettings(profileID: String?) {}
    func openKnowMore(_ directive: ProfileV3Directive?) {}
    func openAddProgramme(requiresKYC: Bool, profileID: String?) {
        openedAddProgrammesRequiringKYC.append(requiresKYC)
    }

    func openProgrammes(for pass: ProfileV3WorldPass, passes: [ProfileV3WorldPass]) {
        openedProgrammeIDs.append(pass.id)
    }
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
    func loadPastTrips(profileID: String) async throws -> ProfileV3PastTripsScreen { throw CancellationError() }
    func loadAddTrip(profileID: String) async throws -> ProfileV3AddTripScreen { throw CancellationError() }
    func addPastTrip(_ submit: ProfileV3BoardAction, country: String, date: ProfileV3TripYearMonth?) async throws {}
    func editPastTrip(_ submit: ProfileV3BoardAction, year: Int, month: Int) async throws {}
    func deletePastTrip(_ submit: ProfileV3BoardAction) async throws {}
}
