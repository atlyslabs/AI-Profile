import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("City profile")
struct ProfileV3CityProfileTests {

    // MARK: - Entry

    @Test func theCityProfileRouteOpensTheCityProfile() {
        let directive = ProfileV3Directive(go: "city_profiles", profileID: "p1")
        #expect(directive.opensCityProfile)
        #expect(directive.route(fallbackProfileID: "main") == .cityProfile(profileID: "p1"))
    }

    @Test func everyServedAgentTileShowsAndRoutesWithoutAClientUpdate() throws {
        let json = #"""
        {"profiles":[{"profile_id":"main","sections":[{"kind":"agent_grid","tiles":[
          {"agent_type":"flight","name":"flight","icon":"orb_flight","updated_label":"updated","next":{"go":"agent","agent_type":"flight"}},
          {"agent_type":"airport_logistics","name":"airport logistics","icon":"orb_airport","next":{"go":"agent","agent_type":"airport_logistics"}},
          {"agent_type":"city","name":"city profile","icon":"orb_city","next":{"go":"city_profiles","profile_id":"main"}},
          {"agent_type":"visa","name":"visa","icon":"https://media.atlys.com/visa.png","next":{"go":"agent","agent_type":"visa","profile_id":"main"}}
        ]}]}]}
        """#
        let board = ProfileV3BoardMapper.board(try JSONDecoder().decode(ProfileV3BoardDTO.self, from: Data(json.utf8)))
        let agents = try #require(board.mainProfile?.home.agents)
        #expect(agents.map(\.id) == ["flight", "airport-logistics", "city", "visa"])
        let art = agents.map { $0.avatarURL?.absoluteString }
        #expect(art == [
            ProfileV3RemoteArt.url("agent_flight")?.absoluteString,
            ProfileV3PlaceholderArt.agentAirport.url?.absoluteString,
            ProfileV3RemoteArt.url("agent_city")?.absoluteString,
            "https://media.atlys.com/visa.png"
        ])
        let routes = agents.map { $0.next?.route(fallbackProfileID: "main") }
        #expect(routes == [
            .agent("flight", profileID: "main"),
            .agent("airport-logistics", profileID: "main"),
            .cityProfile(profileID: "main"),
            .agent("visa", profileID: "main")
        ])
        #expect(ProfileV3API.agent(type: "visa", profileID: "main").path.hasSuffix("/board/agent/visa"))
    }

    // MARK: - Mapping

    @Test func theIntroMapsPortholesTheAddSlotAndSamples() throws {
        let dto = try JSONDecoder().decode(ProfileV3CityProfilesDTO.self, from: Data(Self.introJSON.utf8))
        let intro = ProfileV3CityProfileMapper.profile(dto)
        #expect(intro.title == "City profile")
        #expect(intro.headline == "Your travel style, tailored to the city you\u{2019}re in.")
        #expect(intro.cities.map(\.id) == ["c1", "c2"])
        #expect(intro.cities[1].purpose.label == "Dad")
        #expect(intro.cities[0].purpose.iconURL?.lastPathComponent == "purpose-home.png")
        #expect(intro.add == ProfileV3CityAddSlot(label: "ADD", detail: "Frequent destination"))
        #expect(intro.samples.map(\.code) == ["BOM"])
        #expect(intro.samples.first?.lines.count == 2)
    }

    @Test func thePickerKeepsItsPageAndQuery() throws {
        let dto = try JSONDecoder().decode(ProfileV3CityPickerDTO.self, from: Data(#"""
        {"type":"city_picker","title":"+ City profile","search_placeholder":"Search","heading":"",
         "search_empty":{"title":"No city found","subtitle":"Try the city’s name or its 3-letter code."},
         "q":"bang","offset":0,"next_offset":20,
         "results":[{"code":"BKK","name":"Bangkok","country":"Thailand","country_code":"TH",
                     "next":{"go":"city_purpose","code":"BKK","profile_id":"p1"}},{"name":"No code"}]}
        """#.utf8))
        let picker = ProfileV3CityProfileMapper.picker(dto)
        #expect(picker.query == "bang")
        #expect(picker.nextOffset == 20)
        #expect(picker.heading.isEmpty)
        #expect(picker.emptyTitle == "No city found")
        #expect(picker.results == [ProfileV3CitySearchResult(code: "BKK", name: "Bangkok", country: "Thailand", countryCode: "TH")])
        #expect(picker.results.first?.title == "Bangkok (BKK)")
    }

    @Test func thePencilSheetKeepsTheCitysPurposeAndOffersDelete() throws {
        let dto = try JSONDecoder().decode(ProfileV3CityPurposeSheetDTO.self, from: Data(Self.pencilJSON.utf8))
        let sheet = try #require(ProfileV3CityProfileMapper.purposeSheet(dto))
        #expect(sheet.title == "DELHI")
        #expect(sheet.options.map(\.key) == ["home", "work", "leisure", "other"])
        #expect(sheet.options.map(\.isDisabled) == [true, false, false, false])
        let other = try #require(sheet.option(key: "other"))
        #expect(other.isSelected)
        #expect(other.input == .init(label: "Purpose", placeholder: "e.g. Visiting parents", maxChars: 30, value: "Dad"))
        #expect(sheet.isLabelUsed("  mOm "))
        #expect(!sheet.isLabelUsed("Dad"))
        #expect(sheet.submitLabel == "Save")
        #expect(sheet.submit.name == "update_city_purpose")
        #expect(sheet.delete?.confirm.message == "Your preferences for this city will be removed.")
        #expect(sheet.delete?.action.name == "delete_city_profile")

        let body = try JSONEncoder().encode(ProfileV3CitySubmitRequest(action: sheet.submit, purpose: "other", label: "Mom & dad"))
        let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
        #expect(json["action"] as? String == "update_city_purpose")
        #expect(json["city_id"] as? String == "c2")
        #expect(json["purpose"] as? String == "other")
        #expect(json["label"] as? String == "Mom & dad")

        let delete = try #require(sheet.delete)
        let deleteBody = try JSONEncoder().encode(ProfileV3CitySubmitRequest(action: delete.action))
        let deleteJSON = try #require(JSONSerialization.jsonObject(with: deleteBody) as? [String: Any])
        #expect(Set(deleteJSON.keys) == ["action", "city_id"])
    }

    @Test func theCityScreenMapsItsCardsAndSavesTheWholeCity() throws {
        let dto = try JSONDecoder().decode(ProfileV3CityScreenDTO.self, from: Data(Self.cityJSON.utf8))
        let city = try #require(ProfileV3CityProfileMapper.city(dto, cityID: "c1"))
        #expect(city.id == "c1")
        #expect(city.purpose.label == "Home")
        #expect(city.editsPurpose)
        #expect(city.found == ProfileV3CityFound(count: 3, total: 6, label: "Found 3/6 preferences"))
        #expect(city.sources?.label == "1 source")
        #expect(city.sources?.icons.first?.url?.absoluteString == "https://media.atlys.com/b2c/ai-native/icons/kyc/you.png?v=1")
        #expect(city.tabs.map(\.sectionID) == ["airlines", "class", "seat", "timings", "pickup", "hotels"])
        #expect(city.form.sections.map(\.id) == ["airlines", "class", "seat", "timings", "pickup", "hotels", "custom_rules"])

        #expect(city.style(for: "airlines").layout == .logos)
        #expect(city.style(for: "airlines").activeIconURL?.lastPathComponent == "airlines-on.png")
        #expect(city.style(for: "class").layout == .tiles)
        #expect(city.style(for: "timings").layout == .grid)
        #expect(city.style(for: "hotels").layout == .rows)

        let sections = Dictionary(uniqueKeysWithValues: city.form.sections.map { ($0.id, $0) })
        guard case .chips(let airlines)? = sections["airlines"]?.control,
              case .cards(let cabin)? = sections["class"]?.control,
              case .chips(let seat)? = sections["seat"]?.control,
              case .chips(let timings)? = sections["timings"]?.control,
              case .chips(let hotels)? = sections["hotels"]?.control else {
            Issue.record("The city's cards should map to chips and tiles")
            return
        }
        #expect(airlines.selection == ["emirates"])
        #expect(airlines.picker != nil)
        #expect(cabin.selection == ["Business"])
        #expect(cabin.options.map(\.imageURL) == [nil, nil])
        #expect(cabin.options.last?.selectedImageURL?.lastPathComponent == "business-on.png")
        #expect(seat.optOut == ProfileV3OptOut(title: "Always avoid non-reclining seats", isOn: false, key: "avoid_non_reclining"))
        #expect(sections["seat"]?.source?.fieldKey == "seat")
        #expect(sections["seat"]?.source?.agentType == "city")
        #expect(sections["class"]?.source == nil)
        #expect(timings.options.first?.logoURL?.lastPathComponent == "timing-early-morning.png")
        #expect(hotels.options.map(\.title) == ["Taj Lands End"])
        #expect(hotels.selection == ["Taj Lands End"])
        #expect(hotels.optOut?.isOn == true)
        #expect(hotels.picker?.typedEntry == .init(
            maxItems: 20,
            maxChars: 120,
            place: .hotel,
            search: ProfileV3PlaceSearchScope(city: "Mumbai", countryCode: "IN")
        ))
        #expect(city.countryCode == "IN")
        #expect(sections["hotels"]?.note?.text == "Your agent uses these preferences to find the right stay for you.")

        let save = try #require(city.save)
        let body = try JSONEncoder().encode(ProfileV3CitySubmitRequest(action: save, values: ProfileV3CitySubmission.values(for: city.form)))
        let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
        #expect(json["action"] as? String == "save_city_preferences")
        #expect(json["city_id"] as? String == "c1")
        #expect(json["label"] == nil)
        let values = try #require(json["values"] as? [String: Any])
        #expect(values["airlines"] as? [String] == ["emirates"])
        #expect(values["class"] as? [String] == ["Business"])
        #expect(values["seat"] as? [String] == ["Aisle"])
        #expect(values["timings"] as? [String] == [])
        #expect(values["pickup"] as? [String] == [])
        #expect(values["hotels"] as? [String] == ["Taj Lands End"])
        #expect(values["avoid_non_reclining"] as? Bool == false)
        #expect(values["no_pickup"] as? Bool == false)
        #expect(values["no_stay"] as? Bool == true)
        #expect(values["custom_rules"] as? [String] == ["No red-eyes"])
    }

    @Test func aWriteReplyCarriesTheCityID() {
        let data = Data(#"{"ok":true,"action":"create_city_profile","city_id":"c9","next":{"go":"city_profile","city_id":"c9"}}"#.utf8)
        #expect(ProfileV3CityProfileMapper.cityID(fromWrite: data) == "c9")
        #expect(ProfileV3CityProfileMapper.cityID(fromWrite: Data("{}".utf8)) == nil)
    }

    // MARK: - Screen

    @Test func theScreenOpensOnTheFirstCityWithItsPreferences() async throws {
        let viewModel = Self.viewModel()
        viewModel.load()
        try await Self.waitUntil { viewModel.form != nil }

        let city = try #require(viewModel.selectedCity)
        #expect(viewModel.selection == "c1")
        #expect(city.purpose.label == "Home")
        #expect(viewModel.form?.form.sections.first?.id == "airlines")
    }

    @Test func aProfileWithNoCitiesOpensOnAdd() async throws {
        let viewModel = Self.viewModel(store: ProfileV3CityProfileStore(entries: []))
        viewModel.load()
        try await Self.waitUntil { viewModel.phase == .loaded }

        #expect(viewModel.isOnAddSlot)
        #expect(viewModel.form == nil)
    }

    @Test func aCityAlreadyAddedCanBeAddedAgainWithAnotherPurpose() async throws {
        let viewModel = Self.viewModel()
        viewModel.load()
        try await Self.waitUntil { viewModel.phase == .loaded }

        viewModel.startAdding()
        let search = try #require(viewModel.search)
        try await Self.waitUntil { !search.results.isEmpty }
        let mumbai = try #require(search.results.first { $0.code == "BOM" })
        viewModel.choose(mumbai)
        viewModel.searchDidDismiss()

        let editor = try #require(viewModel.editor)
        try await Self.waitUntil { editor.sheet != nil }
        let sheet = try #require(editor.sheet)
        #expect(sheet.options.filter(\.isDisabled).map(\.key) == ["home", "leisure"])
        let home = try #require(sheet.option(key: "home"))
        editor.select(home)
        #expect(editor.purposeKey == nil)
        #expect(!editor.canContinue)
    }

    @Test func addingACityOpensItOnceSaved() async throws {
        let store = ProfileV3CityProfileStore()
        let viewModel = Self.viewModel(store: store)
        viewModel.load()
        try await Self.waitUntil { viewModel.phase == .loaded }

        viewModel.startAdding()
        viewModel.choose(ProfileV3CityProfileFixtures.catalogue[3])
        viewModel.searchDidDismiss()
        let editor = try #require(viewModel.editor)
        try await Self.waitUntil { editor.sheet != nil }
        let sheet = try #require(editor.sheet)
        #expect(sheet.submitLabel == "Continue")
        editor.select(try #require(sheet.option(key: "work")))
        #expect(editor.canContinue)
        editor.commit()
        try await Self.waitUntil { viewModel.editor == nil }
        try await Self.waitUntil { viewModel.selectedCity?.code == "DXB" }

        #expect(viewModel.selectedCity?.purpose.label == "Work")
        #expect(viewModel.content?.cities.first?.code == "DXB")
        #expect(store.snapshot().map(\.code) == ["DXB", "BOM", "BKK"])
    }

    @Test func otherAsksForANameThatNoOtherCityUses() async throws {
        let store = ProfileV3CityProfileStore(entries: [
            .init(id: "c1", code: "DEL", purpose: "other", label: "Dad", form: ProfileV3CityProfileFixtures.form())
        ])
        let editor = Self.editor(.add(ProfileV3CityProfileFixtures.catalogue[0]), store: store)
        editor.load()
        try await Self.waitUntil { editor.sheet != nil }
        let other = try #require(editor.sheet?.option(key: "other"))

        editor.select(other)
        #expect(editor.step == .label)
        #expect(!editor.canContinue)
        editor.label = "  dad "
        #expect(editor.isLabelTaken)
        #expect(!editor.canContinue)
        editor.label = "Parents"
        #expect(editor.canContinue)
        editor.label = String(repeating: "x", count: 40)
        #expect(editor.label.count == 30)

        editor.label = ""
        editor.back()
        #expect(editor.step == .purpose)
        #expect(editor.purposeKey == nil)
    }

    @Test func anUnchangedEditFinishesWithoutSaving() async throws {
        var outcomes: [ProfileV3CityEditorModel.Outcome] = []
        let editor = Self.editor(.edit(cityID: "c1", code: "BOM", name: "Mumbai", imageURL: nil)) { outcomes.append($0) }
        editor.load()
        try await Self.waitUntil { editor.sheet != nil }
        #expect(editor.purposeKey == "home")
        #expect(editor.sheet?.submitLabel == "Save")

        editor.commit()
        #expect(outcomes == [.saved(cityID: "c1")])
        #expect(editor.savePhase == .idle)
    }

    @Test func deletingACitySelectsTheNextOne() async throws {
        let viewModel = Self.viewModel()
        viewModel.load()
        try await Self.waitUntil { viewModel.form != nil }

        viewModel.editSelectedCity()
        let editor = try #require(viewModel.editor)
        try await Self.waitUntil { editor.sheet != nil }
        editor.requestDelete()
        #expect(editor.confirmsDelete)
        editor.confirmDelete()
        try await Self.waitUntil { viewModel.editor == nil }

        #expect(viewModel.content?.cities.map(\.id) == ["c2"])
        #expect(viewModel.selection == "c2")
    }

    @Test func thePickerPagesThroughTheList() async throws {
        let catalogue = (0 ..< 45).map { index in
            ProfileV3CitySearchResult(code: String(format: "C%02d", index), name: "City \(index)", country: "Nowhere", countryCode: "IN")
        }
        let repository = ProfileV3MockRepository(
            delay: .zero,
            session: ProfileV3SessionStore(),
            cities: ProfileV3CityProfileStore(entries: [], catalogue: catalogue)
        )
        let search = ProfileV3CitySearchModel(profileID: nil, repository: repository)
        search.load()
        try await Self.waitUntil { search.results.count == 20 }
        #expect(search.hasMore)
        #expect(search.picker?.heading == "POPULAR CITIES")

        search.loadMore()
        try await Self.waitUntil { search.results.count == 40 }
        search.loadMore()
        try await Self.waitUntil { search.results.count == 45 }
        #expect(!search.hasMore)

        search.setQuery("City 4")
        try await Self.waitUntil { search.results.count == 6 }
        #expect(search.picker?.query == "City 4")
        #expect(search.picker?.heading == "")
    }

    @Test func aTabScrollsToItsSection() async throws {
        let viewModel = Self.viewModel()
        viewModel.load()
        try await Self.waitUntil { viewModel.selectedCity != nil }

        let tabs = try #require(viewModel.selectedCity?.tabs)
        #expect(tabs.first?.id == "airlines")
        viewModel.selectTab("pickup")
        #expect(viewModel.selectedTab == "pickup")
        let request = try #require(viewModel.scrollRequest)
        #expect(request.sectionID == "pickup")
        #expect(request.anchorID == ProfileV3CityProfileViewModel.sectionAnchorID("pickup"))
        let chipIDs = Set(tabs.map(\.id))
        #expect(!chipIDs.contains(request.anchorID))
    }

    @Test func theHighlightedTabFollowsTheSectionUnderTheStrip() async throws {
        let viewModel = Self.viewModel()
        viewModel.load()
        try await Self.waitUntil { viewModel.selectedCity != nil }
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
        try await Self.waitUntil { viewModel.form != nil }
        let form = try #require(viewModel.form)

        form.setOptOut(true, in: "hotels")
        #expect(form.showsSaveBar)
        form.save()
        try await Self.waitUntil { form.saveState == .saved }

        let saved = try #require(store.snapshot().first { $0.id == "c1" }?.form.sections.first { $0.id == "hotels" })
        guard case .chips(let field) = saved.control else {
            Issue.record("Hotels should stay a chips section")
            return
        }
        #expect(field.optOut?.isOn == true)
        #expect(field.selection == ["Taj Lands End", "Trident Nariman Point"])
    }

    @Test func aTypedHotelJoinsTheListOnce() async throws {
        let viewModel = Self.viewModel()
        viewModel.load()
        try await Self.waitUntil { viewModel.form != nil }
        let form = try #require(viewModel.form)

        form.openPicker(for: "hotels")
        form.addTypedOption("  Oberoi   Mumbai ", in: "hotels")
        form.addTypedOption("oberoi mumbai", in: "hotels")
        guard case .chips(let field)? = form.form.sections.first(where: { $0.id == "hotels" })?.control else {
            Issue.record("Hotels should stay a chips section")
            return
        }
        #expect(field.selection.contains("Oberoi Mumbai"))
        #expect(field.options.filter { $0.title.lowercased() == "oberoi mumbai" }.count == 1)
        #expect(field.options.last?.place == .hotel)
        #expect(form.pickerOptions.contains { $0.id == "Oberoi Mumbai" })
        #expect(form.showsSaveBar)
        #expect(!form.searchesPlaces(in: "hotels"))
    }

    // MARK: - Hotel search

    @Test func theHotelSearchLooksForLodgingInTheCity() {
        let scope = ProfileV3PlaceSearchScope(city: "Mumbai", countryCode: "IN")
        #expect(scope.query(for: "  Taj   Lands ") == "Taj Lands Mumbai")
        #expect(scope.query(for: "Oberoi mumbai") == "Oberoi mumbai")
        #expect(scope.query(for: "   ").isEmpty)
        #expect(ProfileV3GooglePlaceSearch(apiKey: nil) == nil)
        #expect(ProfileV3GooglePlaceSearch(apiKey: "  ") == nil)
    }

    @Test func aFoundHotelIsAddedByItsName() async throws {
        let places = ProfileV3StubPlaceSearch(results: [
            ProfileV3PlaceSuggestion(id: "p1", name: "Taj Lands End", detail: "Bandra West, Mumbai"),
            ProfileV3PlaceSuggestion(id: "p2", name: "Taj Mahal Palace", detail: "Colaba, Mumbai"),
            ProfileV3PlaceSuggestion(id: "p3", name: "Taj  Mahal Palace", detail: "Apollo Bandar, Mumbai"),
        ])
        let viewModel = Self.viewModel(placeSearch: places)
        viewModel.load()
        try await Self.waitUntil { viewModel.form != nil }
        let form = try #require(viewModel.form)

        form.openPicker(for: "hotels")
        #expect(form.searchesPlaces(in: "hotels"))
        #expect(!form.searchesPlaces(in: "airlines"))
        #expect(form.pickerOptions.map(\.id) == ["Taj Lands End", "Trident Nariman Point"])

        form.searchPlaces("t")
        form.searchPlaces("taj")
        #expect(form.isSearchingPlaces)
        try await Self.waitUntil { !form.isSearchingPlaces }
        let mumbai = ProfileV3PlaceSearchScope(city: "Mumbai", countryCode: "IN")
        #expect(places.requests == [ProfileV3StubPlaceSearch.Request(text: "taj", scope: mumbai)])
        #expect(form.pickerOptions.map(\.id) == ["Taj Lands End", "Taj Mahal Palace"])
        #expect(form.pickerOptions.map(\.subtitle) == ["Bandra West, Mumbai", "Colaba, Mumbai"])
        let listsHotels = form.pickerOptions.allSatisfy { $0.place == .hotel }
        #expect(listsHotels)

        form.togglePickerOption("Taj Mahal Palace", in: "hotels")
        form.togglePickerOption("Taj Lands End", in: "hotels")
        guard case .chips(let field)? = form.form.sections.first(where: { $0.id == "hotels" })?.control else {
            Issue.record("Hotels should stay a chips section")
            return
        }
        #expect(field.selection == ["Trident Nariman Point", "Taj Mahal Palace"])
        #expect(form.pickerOptions.map(\.id) == ["Taj Lands End", "Taj Mahal Palace"])
        #expect(form.showsSaveBar)

        form.searchPlaces("")
        #expect(form.pickerOptions.map(\.id) == ["Taj Lands End", "Trident Nariman Point", "Taj Mahal Palace"])
        form.closePicker()
        #expect(!form.isSearchingPlaces)
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

    private static func viewModel(
        store: ProfileV3CityProfileStore = ProfileV3CityProfileStore(),
        placeSearch: (any ProfileV3PlaceSearching)? = nil
    ) -> ProfileV3CityProfileViewModel {
        ProfileV3CityProfileViewModel(
            profileID: nil,
            repository: ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore(), cities: store),
            placeSearch: placeSearch
        )
    }

    private static func editor(
        _ mode: ProfileV3CityEditorModel.Mode,
        store: ProfileV3CityProfileStore = ProfileV3CityProfileStore(),
        onFinish: @escaping (ProfileV3CityEditorModel.Outcome) -> Void = { _ in }
    ) -> ProfileV3CityEditorModel {
        ProfileV3CityEditorModel(
            mode: mode,
            profileID: nil,
            repository: ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore(), cities: store),
            onFinish: onFinish
        )
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Swift.Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }

    private static let icons = "https://media.atlys.com/b2c/ai-native/icons/city"

    private static let introJSON = """
    {"type":"city_profiles","profile_id":"p1","title":"City profile",
     "cities":[
       {"id":"c1","code":"BOM","name":"Mumbai","country":"India","country_code":"IN",
        "purpose":{"key":"home","label":"Home","icon_url":"\(icons)/purpose-home.png"},
        "image_url":"https://media.atlys.com/IN.avif?q=60","next":{"go":"city_profile","city_id":"c1","profile_id":"p1"}},
       {"id":"c2","code":"DEL","name":"Delhi","country":"India","country_code":"IN",
        "purpose":{"key":"other","label":"Dad","icon_url":"\(icons)/purpose-other.png"},
        "next":{"go":"city_profile","city_id":"c2","profile_id":"p1"}},
       {"name":"No id"}
     ],
     "add":{"label":"ADD","subtitle":"Frequent destination","next":{"go":"city_picker","profile_id":"p1"}},
     "headline":"Your travel style, tailored to the city you’re in.",
     "samples":[{"code":"BOM","name":"Mumbai","purpose":{"key":"home","label":"Home","icon_url":"\(icons)/purpose-home.png"},
                 "image_url":"https://media.atlys.com/IN.avif?q=60",
                 "lines":["Always book late night flights","No airport pick-up needed"]}]}
    """

    private static let pencilJSON = """
    {"type":"city_purpose","title":"DELHI",
     "city":{"code":"DEL","name":"Delhi","country_code":"IN","image_url":"https://media.atlys.com/IN.avif?q=60"},
     "options":[
       {"key":"home","label":"Home","icon_url":"\(icons)/purpose-home.png","disabled":true},
       {"key":"work","label":"Work","icon_url":"\(icons)/purpose-work.png","disabled":false},
       {"key":"leisure","label":"Leisure","icon_url":"\(icons)/purpose-leisure.png","disabled":false},
       {"key":"other","label":"Other","icon_url":"\(icons)/purpose-other.png","disabled":false,
        "input":{"label":"Purpose","placeholder":"e.g. Visiting parents","max_chars":30,"value":"Dad"},"selected":true}
     ],
     "used_labels":["Mom"],"label_taken":"You already use this for another city.",
     "submit":{"label":"Save","action":"update_city_purpose","city_id":"c2"},
     "delete":{"label":"Delete city profile","action":"delete_city_profile","city_id":"c2",
               "confirm":{"title":"Delete Delhi?","body":"Your preferences for this city will be removed.",
                          "confirm_label":"Delete","cancel_label":"Cancel"}}}
    """

    private static let cityJSON = """
    {"type":"city_profile","city_id":"c1","profile_id":"p1","title":"City profile",
     "city":{"code":"BOM","name":"Mumbai","country":"India","country_code":"IN","image_url":"https://media.atlys.com/IN.avif?q=60"},
     "cities":[{"id":"c1","code":"BOM","name":"Mumbai","country":"India","country_code":"IN",
                "purpose":{"key":"home","label":"Home","icon_url":"\(icons)/purpose-home.png"}}],
     "add":{"label":"ADD","subtitle":"Frequent destination","next":{"go":"city_picker","profile_id":"p1"}},
     "purpose":{"key":"home","label":"Home","icon_url":"\(icons)/purpose-home.png",
                "edit":{"next":{"go":"city_purpose","city_id":"c1","code":"BOM","profile_id":"p1"}}},
     "found":{"count":3,"total":6,"label":"Found 3/6 preferences"},
     "sources":{"count":1,"label":"1 source","icons":["https://media.atlys.com/b2c/ai-native/icons/kyc/you.png?v=1"]},
     "tabs":[{"key":"airlines","label":"Airlines","icon_url":"\(icons)/airlines-off.png"},
             {"key":"class","label":"Class","icon_url":"\(icons)/class-off.png"},
             {"key":"seat","label":"Seat","icon_url":"\(icons)/seat-off.png"},
             {"key":"timings","label":"Timings","icon_url":"\(icons)/timings-off.png"},
             {"key":"pickup","label":"Pick-up","icon_url":"\(icons)/pickup-off.png"},
             {"key":"hotels","label":"Hotels","icon_url":"\(icons)/hotels-off.png"}],
     "fields":[
       {"key":"airlines","label":"Preferred airlines","input":"multi_select_add","assist":"",
        "options":[{"value":"emirates","label":"Emirates","image_url":"https://media.atlys.com/ek.png","selected":true},
                   {"value":"indigo","label":"IndiGo","selected":false}],
        "subtitle":"The airlines you like to fly to this city","footer":"Your agent uses these preferences to prioritize the right flights for you.",
        "icon":{"active_url":"\(icons)/airlines-on.png","inactive_url":"\(icons)/airlines-off.png","active":true},
        "layout":"chips_with_icon","tab":{"label":"Airlines","icon_url":"\(icons)/airlines-off.png"},"found":true,
        "add":{"search":"airlines"},"suggested":["emirates"],"source":{"count":0,"icons":[]}},
       {"key":"class","tab":{"label":"Class","icon_url":"\(icons)/class-off.png"},"label":"Class","input":"multi_select","assist":"",
        "options":[{"value":"Economy","label":"Economy","selected":false,"image_url":"","selected_image_url":""},
                   {"value":"Business","label":"Business","selected":true,"image_url":"","selected_image_url":"https://media.atlys.com/business-on.png"}],
        "icon":{"active_url":"\(icons)/class-on.png","inactive_url":"\(icons)/class-off.png","active":true},
        "layout":"tiles","found":true,"source":{"count":0,"icons":[]}},
       {"key":"seat","tab":{"label":"Seat","icon_url":"\(icons)/seat-off.png"},"label":"Seat selection","input":"multi_select","assist":"",
        "options":[{"value":"Window","label":"Window","selected":false},{"value":"Aisle","label":"Aisle","selected":true}],
        "layout":"chips","found":true,
        "optout":{"key":"avoid_non_reclining","label":"Always avoid non-reclining seats","value":false},
        "source":{"count":1,"icons":["https://media.atlys.com/b2c/ai-native/icons/kyc/you.png?v=1"],
                  "next":{"go":"city_preference_sources","city_id":"c1","field_key":"seat"}}},
       {"key":"timings","tab":{"label":"Timings","icon_url":"\(icons)/timings-off.png"},"label":"Preferred flight timings","input":"multi_select","assist":"",
        "options":[{"value":"Early morning","label":"Early morning","selected":false,"image_url":"\(icons)/timing-early-morning.png"}],
        "layout":"chips_with_icon","source":{"count":0,"icons":[]}},
       {"key":"pickup","tab":{"label":"Pick-up","icon_url":"\(icons)/pickup-off.png"},"label":"Airport pick-up","input":"multi_select","assist":"",
        "options":[{"value":"private","label":"Private","selected":false},{"value":"public","label":"Public","selected":false}],
        "layout":"chips","optout":{"key":"no_pickup","label":"No need to book airport pick-up in this city","value":false}},
       {"key":"hotels","tab":{"label":"Hotels","icon_url":"\(icons)/hotels-off.png"},"label":"Preferred hotels","input":"free_list","assist":"","value":["Taj Lands End"],
        "max_items":20,"max_chars":120,"layout":"rows","add":{"search":"client_hotels"},"found":true,
        "footer":"Your agent uses these preferences to find the right stay for you.",
        "optout":{"key":"no_stay","label":"Do not book stay in this city","value":true}}
     ],
     "custom_rules":{"key":"custom_rules","label":"CUSTOM RULES","input":"custom_rules","assist":"","value":["No red-eyes"],
                     "add_label":"+ Custom","editor":{"add_title":"Add rule","edit_title":"Edit rule","note_label":"Note",
                     "save_label":"Save","saved_toast":"Saved","max_chars":500},
                     "delete_confirm":{"title":"Delete?","confirm_label":"Delete","cancel_label":"Cancel"},"max_rules":10},
     "save":{"label":"save changes","action":"save_city_preferences","city_id":"c1"}}
    """
}

@MainActor
private final class ProfileV3StubPlaceSearch: ProfileV3PlaceSearching {
    struct Request: Equatable {
        let text: String
        let scope: ProfileV3PlaceSearchScope
    }

    let results: [ProfileV3PlaceSuggestion]
    private(set) var requests: [Request] = []

    init(results: [ProfileV3PlaceSuggestion]) {
        self.results = results
    }

    func lodging(matching text: String, in scope: ProfileV3PlaceSearchScope) async -> [ProfileV3PlaceSuggestion] {
        requests.append(Request(text: text, scope: scope))
        return results
    }
}
