import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Past trips")
struct ProfileV3PastTripsTests {
    @Test func globeMapsTheAddPillAndTheTripsPill() throws {
        let empty = try decode(ProfileV3GlobeDTO.self, #"""
        {"stats":[],"countries":[],
         "add_trips":{"label":"ADD PAST TRIPS","next":{"go":"add_trip","profile_id":"main"}}}
        """#)
        guard case .add(let label, let next)? = ProfileV3PastTripsMapper.entry(empty) else {
            Issue.record("Expected the add pill")
            return
        }
        #expect(label == "ADD PAST TRIPS")
        #expect(next.route() == .addTrip(profileID: "main"))

        let filled = try decode(ProfileV3GlobeDTO.self, #"""
        {"trips_pill":{"flags":["mu","JP",""],"more":4,
          "next":{"go":"past_trips","profile_id":"main"},
          "add":{"next":{"go":"add_trip","profile_id":"main"}}}}
        """#)
        guard case .pill(let flags, let more, let tripsNext, let add)? = ProfileV3PastTripsMapper.entry(filled) else {
            Issue.record("Expected the trips pill")
            return
        }
        #expect(flags == ["MU", "JP"])
        #expect(more == 4)
        #expect(tripsNext?.route() == .pastTrips(profileID: "main"))
        #expect(add?.route() == .addTrip(profileID: "main"))
        #expect(ProfileV3PastTripsMapper.entry(try decode(ProfileV3GlobeDTO.self, #"{"stats":[]}"#)) == nil)
    }

    @Test func tripsScreenKeepsTheServerOrderDatesAndDeleteCopy() throws {
        let screen = ProfileV3PastTripsMapper.screen(try decode(ProfileV3PastTripsScreenDTO.self, #"""
        {"type":"past_trips","title":"Your past trips",
         "trips":[
           {"trip_id":41,"code":"mu","name":"Mauritius","image_url":"","month":3,"year":2026,"month_label":"March",
            "edit":{"label":"Edit","submit":{"action":"edit_past_trip","trip_id":41,"profile_id":"main"}},
            "delete":{"label":"Delete","submit":{"action":"delete_past_trip","trip_id":41,"profile_id":"main"}}},
           {"trip_id":"7","code":"JP","month":13,"year":2025},
           {"trip_id":"8","code":"JP","month":11,"year":2024}
         ],
         "add":{"next":{"go":"add_trip","profile_id":"main"}},
         "duration":{"title":"SELECT DURATION","years":[2024,2025,2026],"cta_label":"Save"},
         "delete_confirm":{"title":"Delete this trip?","confirm_label":"Proceed to delete","cancel_label":"Don't delete"}}
        """#))
        #expect(screen.title == "Your past trips")
        #expect(screen.trips.map(\.id) == ["41", "8"])
        let trip = try #require(screen.trips.first)
        #expect(trip.countryCode == "MU")
        #expect(trip.countryName == "Mauritius")
        #expect(trip.date == ProfileV3TripYearMonth(year: 2026, month: 3))
        #expect(trip.monthName == "March")
        #expect(trip.imageURL == nil)
        #expect(trip.delete?.submit.name == "delete_past_trip")
        #expect(screen.trips[1].delete == nil)
        #expect(screen.addDirective?.route() == .addTrip(profileID: "main"))
        #expect(screen.deleteConfirm?.cancelLabel == "Don't delete")
    }

    @Test func undatedCountriesFollowTheDatedTrips() throws {
        let screen = ProfileV3PastTripsMapper.screen(try decode(ProfileV3PastTripsScreenDTO.self, #"""
        {"type":"past_trips","title":"Your past trips",
         "trips":[
           {"trip_id":41,"code":"mu","name":"Mauritius","month":3,"year":2026,"month_label":"March",
            "delete":{"label":"Delete","submit":{"action":"delete_past_trip","trip_id":41}}},
           {"trip_id":"country:IT","code":"IT","name":"Italy","image_url":"",
            "delete":{"label":"Delete","submit":{"action":"delete_past_trip","trip_id":"country:IT"}}},
           {"trip_id":"country:JP","code":"JP","name":"Japan","year":2025},
           {"trip_id":"country:FR","code":"FR","name":"France","month":4}
         ]}
        """#))
        #expect(screen.trips.map(\.id) == ["41", "country:IT"])
        #expect(screen.trips.first?.monthName == "March")
        let undated = try #require(screen.trips.last)
        #expect(undated.date == nil)
        #expect(undated.monthName == nil)
        #expect(undated.countryName == "Italy")
        #expect(undated.delete?.submit.fields["trip_id"] == .string("country:IT"))
    }

    @Test func severalCountriesGoAsOneListWithNoYearOrMonth() throws {
        let submit = ProfileV3BoardAction(fields: [
            "action": .string("add_past_trip"),
            "profile_id": .string("main"),
            "country": .string("IT")
        ])
        let body = try json(ProfileV3PastTripsMapper.addRequest(submit, countries: ["JP", "FR"]))
        #expect(body["action"] as? String == "add_past_trip")
        #expect(body["profile_id"] as? String == "main")
        #expect(body["countries"] as? [String] == ["JP", "FR"])
        #expect(body["country"] as? String == "IT")
        #expect(body["year"] == nil)
        #expect(body["month"] == nil)
    }

    @Test func addTripScreenMapsTheCountriesAndSubmit() throws {
        let screen = ProfileV3PastTripsMapper.addScreen(try decode(ProfileV3AddTripScreenDTO.self, #"""
        {"type":"add_trip",
         "country":{"title":"SEARCH FOR COUNTRY","search_placeholder":"Search","cta_label":"Done",
           "countries":[{"code":"ae","name":"United Arab Emirates"},{"name":"No code"},{"code":"MU","name":"Mauritius"}]},
         "duration":{"title":"SELECT DURATION","years":[2025,2026],"cta_label":"Add country"},
         "submit":{"action":"add_past_trip","profile_id":"main"}}
        """#))
        #expect(screen.countryTitle == "SEARCH FOR COUNTRY")
        #expect(screen.searchPlaceholder == "Search")
        #expect(screen.countryCTA == "Done")
        #expect(screen.countries.map(\.code) == ["AE", "MU"])
        #expect(screen.submit?.name == "add_past_trip")
    }

    @Test func writesEchoTheServerActionAndReplaceItsSameNamedFields() throws {
        let delete = try json(ProfileV3BoardSubmitRequest(
            action: ProfileV3BoardAction(fields: ["action": .string("delete_past_trip"), "trip_id": .int(41)])
        ))
        #expect(delete["action"] as? String == "delete_past_trip")
        #expect(delete["trip_id"] as? Int == 41)

        let add = try json(ProfileV3BoardSubmitRequest(
            action: ProfileV3BoardAction(fields: ["action": .string("add_past_trip"), "countries": .string("JP")]),
            lists: ["countries": ["FR", "MU"]]
        ))
        #expect(add["action"] as? String == "add_past_trip")
        #expect(add["countries"] as? [String] == ["FR", "MU"])
    }

    @Test func tripRoutesAndEndpoints() {
        #expect(ProfileV3Directive(go: "past_trips", profileID: "p2").route() == .pastTrips(profileID: "p2"))
        #expect(ProfileV3Directive(go: "add_trip").route(fallbackProfileID: "main") == .addTrip(profileID: "main"))
        #expect(ProfileV3API.pastTrips(profileID: "p2").path == "/api/gmail-connector/kyc/v2/board/past_trips")
        #expect(ProfileV3API.addTrip(profileID: "p2").path == "/api/gmail-connector/kyc/v2/board/past_trips/add")
        guard case .requestParameters(let parameters, _) = ProfileV3API.addTrip(profileID: "p2").task else {
            Issue.record("Expected a profile_id query")
            return
        }
        #expect(parameters["profile_id"] as? String == "p2")
    }

    @Test(.timeLimit(.minutes(1)))
    func severalCountriesAreAddedInOneGo() async throws {
        let repository = TripsRepositoryStub()
        var changes = 0
        let viewModel = ProfileV3PastTripsViewModel(
            pass: ProfileV3Fixtures.worldPass,
            repository: repository,
            startsAdding: false,
            onChange: { changes += 1 },
            onClose: {}
        )
        viewModel.start()
        try await waitUntil { viewModel.phase == .loaded }

        viewModel.tapAdd()
        let editor = try #require(viewModel.editor)
        try await waitUntil { editor.screen != nil }
        #expect(editor.title == "SEARCH FOR COUNTRY")
        #expect(editor.countryCTA == "Done")
        #expect(!editor.canSubmit)
        let mauritius = ProfileV3Country(code: "MU", name: "Mauritius")
        let france = ProfileV3Country(code: "FR", name: "France")
        editor.select(mauritius)
        editor.select(france)
        editor.select(mauritius)
        #expect(editor.selectedCountries == [france])
        editor.select(mauritius)
        #expect(editor.selectedCountries == [france, mauritius])
        #expect(editor.canSubmit)
        editor.submit()
        try await waitUntil { viewModel.focus != nil }

        #expect(repository.addedLists.map(\.countries) == [["FR", "MU"]])
        #expect(repository.addedLists.first?.submit.name == "add_past_trip")
        #expect(viewModel.sheet == nil)
        #expect(viewModel.trips.map(\.id) == ["41", "country:FR", "country:MU"])
        #expect(viewModel.revealingTripID == "country:FR")
        #expect(viewModel.focus?.tripID == "country:FR")
        #expect(viewModel.notice == nil)
        #expect(changes == 1)
    }

    @Test(.timeLimit(.minutes(1)))
    func closingTheAddSheetAddsNothing() async throws {
        let repository = TripsRepositoryStub()
        var changes = 0
        let viewModel = ProfileV3PastTripsViewModel(
            pass: ProfileV3Fixtures.worldPass,
            repository: repository,
            startsAdding: false,
            onChange: { changes += 1 },
            onClose: {}
        )
        viewModel.start()
        try await waitUntil { viewModel.phase == .loaded }

        viewModel.tapAdd()
        let editor = try #require(viewModel.editor)
        try await waitUntil { editor.screen != nil }
        editor.select(ProfileV3Country(code: "MU", name: "Mauritius"))
        #expect(viewModel.sheet == .add)

        viewModel.dismissSheet()
        #expect(viewModel.sheet == nil)
        #expect(repository.addedLists.isEmpty)
        #expect(changes == 0)

        viewModel.tapAdd()
        #expect(viewModel.sheet == .add)
    }

    @Test(.timeLimit(.minutes(1)))
    func aCountryAlreadyOnTheListIsNotAddedAgain() async throws {
        let repository = TripsRepositoryStub()
        let viewModel = ProfileV3PastTripsViewModel(
            pass: ProfileV3Fixtures.worldPass,
            repository: repository,
            startsAdding: false,
            onChange: {},
            onClose: {}
        )
        viewModel.start()
        try await waitUntil { viewModel.phase == .loaded }

        viewModel.tapAdd()
        let editor = try #require(viewModel.editor)
        try await waitUntil { editor.screen != nil }
        editor.select(ProfileV3Country(code: "FR", name: "France"))
        editor.select(ProfileV3Country(code: "JP", name: "Japan"))
        editor.submit()

        #expect(editor.errorMessage == ProfileV3Strings.pastTripDuplicate)
        #expect(!editor.isSubmitting)
        #expect(repository.addedLists.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func aRefusedListAddsNothingAndKeepsTheSheetForARetry() async throws {
        let repository = TripsRepositoryStub(failingAdds: ["MU"])
        let viewModel = ProfileV3PastTripsViewModel(
            pass: ProfileV3Fixtures.worldPass,
            repository: repository,
            startsAdding: false,
            onChange: {},
            onClose: {}
        )
        viewModel.start()
        try await waitUntil { viewModel.phase == .loaded }

        viewModel.tapAdd()
        let editor = try #require(viewModel.editor)
        try await waitUntil { editor.screen != nil }
        editor.select(ProfileV3Country(code: "FR", name: "France"))
        editor.select(ProfileV3Country(code: "MU", name: "Mauritius"))
        editor.submit()
        try await waitUntil { editor.errorMessage != nil }

        #expect(editor.errorMessage == "Couldn't add that country.")
        #expect(!editor.isSubmitting)
        #expect(editor.selectedCountries.map(\.code) == ["FR", "MU"])
        #expect(viewModel.sheet == .add)
        #expect(viewModel.notice == nil)
        #expect(repository.addedLists.isEmpty)
        #expect(viewModel.trips.map(\.id) == ["41"])
    }

    @Test(.timeLimit(.minutes(1)))
    func aTripOffersOnlyDeleteAndOnlyWhenTheServerServesIt() async throws {
        let repository = TripsRepositoryStub(
            trips: [
                ProfileV3PastTrip(id: "41", countryCode: "JP", date: .init(year: 2025, month: 3)),
                ProfileV3PastTrip(id: "country:IT", countryCode: "IT", date: nil)
            ],
            undeletable: ["41"]
        )
        let viewModel = ProfileV3PastTripsViewModel(
            pass: ProfileV3Fixtures.worldPass,
            repository: repository,
            startsAdding: false,
            onChange: {},
            onClose: {}
        )
        viewModel.start()
        try await waitUntil { viewModel.phase == .loaded }
        let dated = try #require(viewModel.trips.first)
        let undated = try #require(viewModel.trips.last)

        viewModel.tapMore(dated)
        #expect(viewModel.sheet == nil)
        viewModel.tapMore(undated)
        #expect(viewModel.sheet == .actions("country:IT"))
        #expect(viewModel.actionsTrip?.delete?.label == "Delete")
        viewModel.tapDelete()
        #expect(viewModel.sheet == .confirmDelete("country:IT"))
    }

    @Test(.timeLimit(.minutes(1)))
    func deleteSendsTheTripsDeleteSubmit() async throws {
        let repository = TripsRepositoryStub()
        let viewModel = ProfileV3PastTripsViewModel(
            pass: ProfileV3Fixtures.worldPass,
            repository: repository,
            startsAdding: false,
            onChange: {},
            onClose: {}
        )
        viewModel.start()
        try await waitUntil { viewModel.phase == .loaded }
        let trip = try #require(viewModel.trips.first)

        viewModel.tapMore(trip)
        viewModel.tapDelete()
        #expect(viewModel.sheet == .confirmDelete(trip.id))
        viewModel.confirmDelete()
        try await waitUntil { !repository.deleted.isEmpty && !viewModel.isDeleting }

        #expect(repository.deleted.first == trip.delete?.submit)
        #expect(!viewModel.trips.contains { $0.id == trip.id })
    }

    @Test(.timeLimit(.minutes(1)))
    func aBrieflyUnavailableDeleteOffersRetry() async throws {
        let repository = TripsRepositoryStub()
        repository.failNextDelete()
        let viewModel = ProfileV3PastTripsViewModel(
            pass: ProfileV3Fixtures.worldPass,
            repository: repository,
            startsAdding: false,
            onChange: {},
            onClose: {}
        )
        viewModel.start()
        try await waitUntil { viewModel.phase == .loaded }
        let trip = try #require(viewModel.trips.first)

        viewModel.tapMore(trip)
        viewModel.tapDelete()
        viewModel.confirmDelete()
        try await waitUntil { viewModel.notice != nil }
        #expect(viewModel.notice == "The traveller list is unavailable right now.")
        #expect(viewModel.canRetryNotice)
        #expect(repository.deleted.isEmpty)

        viewModel.retryAfterNotice()
        #expect(viewModel.notice == nil)
        try await waitUntil { !repository.deleted.isEmpty && !viewModel.isDeleting }
        #expect(!viewModel.trips.contains { $0.id == trip.id })
    }

    private func decode<T: Decodable>(_ type: T.Type, _ text: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(text.utf8))
    }

    private func json(_ request: ProfileV3BoardSubmitRequest) throws -> [String: Any] {
        try #require(try JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as? [String: Any])
    }

    private func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

private final class TripsRepositoryStub: ProfileV3PastTripsRepository, @unchecked Sendable {
    struct AddedList {
        let submit: ProfileV3BoardAction
        let countries: [String]
    }

    private let lock = NSLock()
    private var trips: [ProfileV3PastTrip]
    private let failingAdds: Set<String>
    private let undeletable: Set<String>

    init(
        trips: [ProfileV3PastTrip] = [ProfileV3PastTrip(id: "41", countryCode: "JP", date: .init(year: 2025, month: 3))],
        failingAdds: Set<String> = [],
        undeletable: Set<String> = []
    ) {
        self.trips = trips
        self.failingAdds = failingAdds
        self.undeletable = undeletable
    }
    private var _addedLists: [AddedList] = []
    private var _deleted: [ProfileV3BoardAction] = []
    private var unavailableDeletes = 0

    var addedLists: [AddedList] { lock.withLock { _addedLists } }
    var deleted: [ProfileV3BoardAction] { lock.withLock { _deleted } }

    func failNextDelete() {
        lock.withLock { unavailableDeletes += 1 }
    }

    func loadPastTrips(profileID: String) async throws -> ProfileV3PastTripsScreen {
        let trips = lock.withLock { self.trips }
        return ProfileV3PastTripsScreen(
            title: "Your past trips",
            trips: trips.listed.map { trip in
                var trip = trip
                if !undeletable.contains(trip.id) {
                    trip.delete = ProfileV3TripAction(label: "Delete", submit: Self.action("delete_past_trip", trip.id, profileID))
                }
                return trip
            },
            addDirective: ProfileV3Directive(go: "add_trip", profileID: profileID),
            deleteConfirm: nil
        )
    }

    func loadAddTrip(profileID: String) async throws -> ProfileV3AddTripScreen {
        ProfileV3AddTripScreen(
            countryTitle: "SEARCH FOR COUNTRY",
            searchPlaceholder: "Search",
            countryCTA: "Done",
            countries: [
                ProfileV3Country(code: "MU", name: "Mauritius"),
                ProfileV3Country(code: "JP", name: "Japan"),
                ProfileV3Country(code: "FR", name: "France")
            ],
            submit: ProfileV3BoardAction(fields: ["action": .string("add_past_trip"), "profile_id": .string(profileID)])
        )
    }

    func addPastTrips(_ submit: ProfileV3BoardAction, countries: [String]) async throws {
        if countries.contains(where: failingAdds.contains) {
            throw ProfileV3Error.transient(message: "Couldn't add that country.")
        }
        lock.withLock {
            _addedLists.append(AddedList(submit: submit, countries: countries))
            for country in countries where !trips.contains(where: { $0.id == "country:\(country)" }) {
                trips.append(ProfileV3PastTrip(id: "country:\(country)", countryCode: country, date: nil))
            }
        }
    }

    func deletePastTrip(_ submit: ProfileV3BoardAction) async throws {
        let fails = lock.withLock {
            guard unavailableDeletes > 0 else { return false }
            unavailableDeletes -= 1
            return true
        }
        if fails { throw ProfileV3Error.transient(message: "The traveller list is unavailable right now.") }
        lock.withLock {
            _deleted.append(submit)
            let id = submit.fields["trip_id"]?.stringValue
            trips.removeAll { $0.id == id }
        }
    }

    private static func action(_ name: String, _ tripID: String, _ profileID: String) -> ProfileV3BoardAction {
        ProfileV3BoardAction(fields: [
            "action": .string(name),
            "trip_id": .string(tripID),
            "profile_id": .string(profileID)
        ])
    }
}
