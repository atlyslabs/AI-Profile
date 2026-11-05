import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("City profile")
struct ProfileV3CityProfileTests {

    // MARK: - Entry

    @Test func theCityProfileRouteStaysClosedWhileTheFlagIsOff() {
        let directive = ProfileV3Directive(go: "city_profile")
        #expect(directive.opensCityProfile)
        #expect(ProfileV3FeatureFlags.isCityProfileEnabled == false)
        #expect(directive.route(fallbackProfileID: "main") == .unsupported("city_profile"))
    }

    @Test func aServedCityProfileTileIsHiddenWhileTheFlagIsOff() throws {
        let json = #"""
        {"profiles":[{"profile_id":"main","sections":[{"kind":"agent_grid","tiles":[
          {"agent_type":"flight","name":"flight","updated_label":"updated","next":{"go":"agent","agent_type":"flight"}},
          {"agent_type":"city_profile","name":"City profile","next":{"go":"city_profile"}}
        ]}]}]}
        """#
        let board = ProfileV3BoardMapper.board(try JSONDecoder().decode(ProfileV3BoardDTO.self, from: Data(json.utf8)))
        let agents = try #require(board.mainProfile?.home.agents)
        #expect(agents.map(\.id) == ["flight"])
    }

    // MARK: - Tags

    @Test func aSharedTagCountsTheCitiesThatShareIt() throws {
        var profile = ProfileV3CityProfileFixtures.profile
        let mumbai = try #require(profile.cities.first)
        #expect(profile.tagLabel(for: mumbai) == "Home")

        profile.cities.append(ProfileV3CityProfileFixtures.makeCity(
            ProfileV3CityProfileFixtures.catalogue[3],
            tag: ProfileV3CityTag(id: "home"),
            filled: false
        ))
        #expect(profile.tagLabel(for: mumbai) == "Home (2)")
    }

    @Test func aPurposeReplacesTheTagLabel() throws {
        var mumbai = try #require(ProfileV3CityProfileFixtures.profile.cities.first)
        mumbai.tag = ProfileV3CityTag(id: "other", purpose: "  Parent\u{2019}s home ")
        #expect(ProfileV3CityProfileFixtures.profile.tagLabel(for: mumbai) == "Parent\u{2019}s home")
    }

    @Test func searchResultsReadAsNameCodeAndCountry() {
        let option = ProfileV3CityProfileFixtures.catalogue[4].option
        #expect(option.title == "Bangkok (BKK)")
        #expect(option.subtitle == "Thailand")
    }

    // MARK: - Editor

    @Test func theEditorCountsTheCityItIsTagging() throws {
        let editor = Self.editor(.add(ProfileV3CityProfileFixtures.catalogue[3]))
        let home = try #require(editor.profile.tag(id: "home"))
        #expect(!editor.canContinue)
        #expect(editor.label(for: home) == "Home")

        editor.select(home)
        #expect(editor.label(for: home) == "Home (2)")
        #expect(editor.canContinue)
        #expect(editor.step == .tag)
    }

    @Test func otherAsksForAPurposeBeforeItSaves() throws {
        let editor = Self.editor(.add(ProfileV3CityProfileFixtures.catalogue[3]))
        let other = try #require(editor.profile.tags.first { $0.asksPurpose })

        editor.select(other)
        #expect(editor.step == .purpose)
        #expect(!editor.canSavePurpose)

        editor.back()
        #expect(editor.step == .tag)
        #expect(editor.tagID == nil)
    }

    @Test func anUnchangedEditFinishesWithoutSaving() throws {
        var outcomes: [String] = []
        let mumbai = try #require(ProfileV3CityProfileFixtures.profile.cities.first)
        let editor = Self.editor(.edit(mumbai)) { outcome in
            if case .saved(_, let cityID) = outcome { outcomes.append(cityID) }
        }
        editor.commit()
        #expect(outcomes == ["BOM"])
        #expect(editor.phase == .idle)
    }

    // MARK: - Screen

    @Test func theScreenOpensOnTheFirstCityWithItsPreferences() async throws {
        let viewModel = Self.viewModel()
        viewModel.load()
        try await Self.waitUntil { viewModel.phase == .loaded }

        let city = try #require(viewModel.selectedCity)
        #expect(viewModel.selection == "BOM")
        #expect(viewModel.form?.form.sections.first?.id == "preferred_airlines")
        #expect(viewModel.tagLabel(for: city) == "Home")
    }

    @Test func aProfileWithNoCitiesOpensOnAdd() async throws {
        let viewModel = Self.viewModel(store: ProfileV3CityProfileStore(profile: ProfileV3CityProfileFixtures.empty))
        viewModel.load()
        try await Self.waitUntil { viewModel.phase == .loaded }

        #expect(viewModel.isOnAddSlot)
        #expect(viewModel.form == nil)
    }

    @Test func choosingACityAlreadyAddedJumpsToIt() async throws {
        let viewModel = Self.viewModel()
        viewModel.load()
        try await Self.waitUntil { viewModel.phase == .loaded }

        viewModel.startAdding()
        let bangkok = try #require(ProfileV3CityProfileFixtures.catalogue.first { $0.id == "BKK" })
        viewModel.choose(bangkok)
        viewModel.searchDidDismiss()

        #expect(viewModel.selection == "BKK")
        #expect(viewModel.search == nil)
        #expect(viewModel.editor == nil)
    }

    @Test func addingACityTagsItAndSelectsItWhileItUpdates() async throws {
        let store = ProfileV3CityProfileStore()
        let viewModel = Self.viewModel(store: store)
        viewModel.load()
        try await Self.waitUntil { viewModel.phase == .loaded }

        viewModel.startAdding()
        viewModel.choose(ProfileV3CityProfileFixtures.catalogue[3])
        viewModel.searchDidDismiss()
        let editor = try #require(viewModel.editor)
        editor.select(try #require(editor.profile.tag(id: "work")))
        editor.commit()
        try await Self.waitUntil { viewModel.editor == nil }

        let dubai = try #require(viewModel.selectedCity)
        #expect(dubai.id == "DXB")
        #expect(dubai.tag == ProfileV3CityTag(id: "work"))
        #expect(dubai.isUpdating)
        #expect(store.snapshot().cities.map(\.id) == ["BOM", "BKK", "DXB"])
    }

    @Test func deletingACitySelectsTheNextOne() async throws {
        let viewModel = Self.viewModel()
        viewModel.load()
        try await Self.waitUntil { viewModel.phase == .loaded }

        viewModel.editSelectedCity()
        let editor = try #require(viewModel.editor)
        editor.requestDelete()
        #expect(editor.confirmsDelete)
        editor.confirmDelete()
        try await Self.waitUntil { viewModel.editor == nil }

        #expect(viewModel.content?.cities.map(\.id) == ["BKK"])
        #expect(viewModel.selection == "BKK")
    }

    @Test func aTabScrollsToItsSection() async throws {
        let viewModel = Self.viewModel()
        viewModel.load()
        try await Self.waitUntil { viewModel.phase == .loaded }

        let tabs = try #require(viewModel.selectedCity?.tabs)
        #expect(tabs.first?.id == "preferred_airlines")
        viewModel.selectTab("airport_pickup")
        #expect(viewModel.selectedTab == "airport_pickup")
        let request = try #require(viewModel.scrollRequest)
        #expect(request.sectionID == "airport_pickup")
        #expect(request.anchorID == ProfileV3CityProfileViewModel.sectionAnchorID("airport_pickup"))
        let chipIDs = Set(tabs.map(\.id))
        #expect(!chipIDs.contains(request.anchorID))
    }

    @Test func theHighlightedTabFollowsTheSectionUnderTheStrip() async throws {
        let viewModel = Self.viewModel()
        viewModel.load()
        try await Self.waitUntil { viewModel.phase == .loaded }
        let tabs = try #require(viewModel.selectedCity?.tabs.map(\.sectionID))
        try #require(tabs.count >= 3)

        viewModel.sectionReached(tabs[0], isReached: true)
        viewModel.sectionReached(tabs[1], isReached: true)
        #expect(viewModel.selectedTab == tabs[1])
        viewModel.sectionReached(tabs[1], isReached: false)
        #expect(viewModel.selectedTab == tabs[0])
        viewModel.sectionReached(tabs[0], isReached: false)
        #expect(viewModel.selectedTab == nil)

        viewModel.selectTab(tabs[2])
        viewModel.sectionReached(tabs[0], isReached: true)
        #expect(viewModel.selectedTab == tabs[2])
        try await Task.sleep(for: .seconds(ProfileV3Theme.Motion.cityTabFollowPauseSeconds + 0.1))
        viewModel.sectionReached(tabs[1], isReached: true)
        #expect(viewModel.selectedTab == tabs[1])

        viewModel.select(ProfileV3CityProfileViewModel.addSlotID)
        #expect(viewModel.selectedTab == nil)
    }

    // MARK: - Preferences

    @Test func skippingAStayIsAnEditThatSavesToTheCity() async throws {
        let store = ProfileV3CityProfileStore()
        let viewModel = Self.viewModel(store: store)
        viewModel.load()
        try await Self.waitUntil { viewModel.phase == .loaded }
        let form = try #require(viewModel.form)

        form.setOptOut(true, in: "preferred_hotels")
        #expect(form.showsSaveBar)
        form.save()
        try await Self.waitUntil { form.saveState == .saved }

        let saved = try #require(store.snapshot().city(id: "BOM")?.form.sections.first { $0.id == "preferred_hotels" })
        guard case .chips(let field) = saved.control else {
            Issue.record("Preferred hotels should stay a chips section")
            return
        }
        #expect(field.optOut?.isOn == true)
    }

    @Test func savingANewCityEndsItsUpdatingState() throws {
        let store = ProfileV3CityProfileStore()
        _ = try store.add("SIN", tag: ProfileV3CityTag(id: "leisure"))
        let singapore = try #require(store.snapshot().city(id: "SIN"))
        #expect(singapore.isUpdating)

        try store.save(singapore.form, cityID: "SIN")
        #expect(store.snapshot().city(id: "SIN")?.isUpdating == false)
        #expect(throws: ProfileV3Error.self) { try store.add("SIN", tag: ProfileV3CityTag(id: "home")) }
    }

    // MARK: - Intro deck

    @Test func theDeckHandsEachCardToTheNextSlotWithoutAJump() {
        let end = ProfileV3Theme.Motion.cityDeckStepSeconds - 0.0001
        let pairs = [(from: 0, to: 2), (from: 1, to: 0), (from: 2, to: 1)]
        for pair in pairs {
            let leaving = ProfileV3CityDeckPose(slot: pair.from, local: end)
            let arriving = ProfileV3CityDeckPose(slot: pair.to, local: 0)
            #expect(abs(leaving.rotation - arriving.rotation) < 0.01)
            #expect(abs(leaving.opacity - arriving.opacity) < 0.01)
            #expect(leaving.offset == .zero && arriving.offset == .zero)
        }
    }

    // MARK: - Helpers

    private static func viewModel(store: ProfileV3CityProfileStore = ProfileV3CityProfileStore()) -> ProfileV3CityProfileViewModel {
        ProfileV3CityProfileViewModel(
            profileID: nil,
            repository: ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore(), cities: store)
        )
    }

    private static func editor(
        _ mode: ProfileV3CityEditorModel.Mode,
        onFinish: @escaping (ProfileV3CityEditorModel.Outcome) -> Void = { _ in }
    ) -> ProfileV3CityEditorModel {
        ProfileV3CityEditorModel(
            mode: mode,
            profile: ProfileV3CityProfileFixtures.profile,
            profileID: nil,
            repository: ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore()),
            onFinish: onFinish
        )
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Swift.Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}
