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

    @Test func tripsScreenKeepsTheServerOrderActionsDurationAndDeleteCopy() throws {
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
         "duration":{"title":"SELECT DURATION","year_label":"YEAR","month_label":"MONTH","years":[2024,2025,2026],
           "months":[{"value":1,"label":"JAN"},{"value":2,"label":"FEB"},{"value":3,"label":"MAR"}],
           "max":{"year":2026,"month":2},"cta_label":"Save"},
         "delete_confirm":{"title":"Delete this trip?","confirm_label":"Proceed to delete","cancel_label":"Don't delete"}}
        """#))
        #expect(screen.title == "Your past trips")
        #expect(screen.trips.map(\.id) == ["41", "8"])
        let trip = try #require(screen.trips.first)
        #expect(trip.countryCode == "MU")
        #expect(trip.countryName == "Mauritius")
        #expect(trip.monthName == "March")
        #expect(trip.imageURL == nil)
        #expect(trip.edit?.submit.fields["trip_id"] == .int(41))
        #expect(trip.delete?.submit.name == "delete_past_trip")
        #expect(screen.trips[1].edit == nil)
        #expect(screen.addDirective?.route() == .addTrip(profileID: "main"))
        #expect(screen.duration?.ctaLabel == "Save")
        #expect(screen.duration?.max == ProfileV3TripYearMonth(year: 2026, month: 2))
        #expect(screen.deleteConfirm?.cancelLabel == "Don't delete")
    }

    @Test func addTripScreenMapsTheCountriesDurationAndSubmit() throws {
        let screen = ProfileV3PastTripsMapper.addScreen(try decode(ProfileV3AddTripScreenDTO.self, #"""
        {"type":"add_trip",
         "country":{"title":"SEARCH FOR COUNTRY","search_placeholder":"Search","cta_label":"Done",
           "countries":[{"code":"ae","name":"United Arab Emirates"},{"name":"No code"},{"code":"MU","name":"Mauritius"}]},
         "duration":{"title":"SELECT DURATION","year_label":"YEAR","month_label":"MONTH","years":[2025,2026],
           "months":[{"value":1,"label":"JAN"},{"value":2,"label":"FEB"},{"value":3,"label":"MAR"}],
           "max":{"year":2026,"month":2},"default":{"year":2026,"month":1},"cta_label":"Add country"},
         "submit":{"action":"add_past_trip","profile_id":"main"}}
        """#))
        #expect(screen.countryTitle == "SEARCH FOR COUNTRY")
        #expect(screen.countryCTA == "Done")
        #expect(screen.countries.map(\.code) == ["AE", "MU"])
        #expect(screen.duration.ctaLabel == "Add country")
        #expect(screen.duration.defaultValue == ProfileV3TripYearMonth(year: 2026, month: 1))
        #expect(screen.submit?.name == "add_past_trip")
    }

    @Test func durationStopsAtTheMaxMonth() {
        let duration = ProfileV3TripDuration(
            title: "",
            yearLabel: "",
            monthLabel: "",
            years: [2024, 2025, 2026, 2027],
            months: (1...12).map { ProfileV3TripMonth(value: $0, label: "M\($0)") },
            max: ProfileV3TripYearMonth(year: 2026, month: 3),
            defaultValue: nil,
            ctaLabel: ""
        )
        #expect(duration.pickableYears == [2024, 2025, 2026])
        #expect(duration.months(in: 2026).map(\.value) == [1, 2, 3])
        #expect(duration.months(in: 2025).count == 12)
        #expect(duration.label(forMonth: 3) == "M3")
    }

    @Test func writesEchoTheServerActionWithTheTripFields() throws {
        let add = try json(ProfileV3BoardSubmitRequest(
            action: ProfileV3BoardAction(fields: ["action": .string("add_past_trip"), "profile_id": .string("main")]),
            extras: ["country": .string("MU"), "year": .int(2026), "month": .int(3)]
        ))
        #expect(add["action"] as? String == "add_past_trip")
        #expect(add["profile_id"] as? String == "main")
        #expect(add["country"] as? String == "MU")
        #expect(add["year"] as? Int == 2026)
        #expect(add["month"] as? Int == 3)

        let edit = try json(ProfileV3BoardSubmitRequest(
            action: ProfileV3BoardAction(fields: ["action": .string("edit_past_trip"), "trip_id": .int(41)]),
            extras: ["year": .int(2025), "month": .int(11)]
        ))
        #expect(edit["trip_id"] as? Int == 41)
        #expect(edit["month"] as? Int == 11)
        #expect(edit["country"] == nil)
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
    func addingATripSendsTheServerSubmitAndRevealsItAfterTheReload() async throws {
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
        #expect(editor.selectedYear == 2026)
        #expect(editor.selectedMonth == 1)
        editor.select(ProfileV3Country(code: "MU", name: "Mauritius"))
        editor.continueToDuration()
        #expect(editor.submitTitle == "Add country")
        editor.submit()
        try await waitUntil { viewModel.revealingTripID != nil }

        #expect(repository.added.count == 1)
        #expect(repository.added.first?.country == "MU")
        #expect(repository.added.first?.submit.name == "add_past_trip")
        #expect(viewModel.trips.map(\.countryCode).contains("MU"))
        #expect(viewModel.revealingTripID == viewModel.trips.first { $0.countryCode == "MU" }?.id)
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
        #expect(repository.added.isEmpty)
        #expect(changes == 0)

        viewModel.tapAdd()
        #expect(viewModel.sheet == .add)
    }

    @Test(.timeLimit(.minutes(1)))
    func editOpensAtTheDurationAndSendsTheTripsOwnSubmit() async throws {
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
        viewModel.tapEdit()
        let editor = try #require(viewModel.editor)
        #expect(editor.isEditing)
        #expect(editor.step == .duration)
        #expect(editor.stepCount == 1)
        #expect(editor.selectedYear == trip.year)
        editor.selectedMonth = 1
        editor.submit()
        try await waitUntil { !repository.edited.isEmpty }

        #expect(repository.edited.first?.submit == trip.edit?.submit)
        #expect(repository.edited.first?.month == 1)
    }

    @Test(.timeLimit(.minutes(1)))
    func anEditedTripIsScrolledBackIntoViewWhereverItLands() async throws {
        let repository = TripsRepositoryStub(trips: [
            ProfileV3PastTrip(id: "1", countryCode: "JP", year: 2025, month: 9),
            ProfileV3PastTrip(id: "2", countryCode: "FR", year: 2025, month: 3),
            ProfileV3PastTrip(id: "3", countryCode: "IT", year: 2024, month: 6),
            ProfileV3PastTrip(id: "4", countryCode: "CN", year: 2024, month: 2)
        ])
        let viewModel = ProfileV3PastTripsViewModel(
            pass: ProfileV3Fixtures.worldPass,
            repository: repository,
            startsAdding: false,
            onChange: {},
            onClose: {}
        )
        viewModel.start()
        try await waitUntil { viewModel.phase == .loaded }
        #expect(viewModel.trips.map(\.id) == ["1", "2", "3", "4"])
        #expect(viewModel.focus == nil)
        let trip = try #require(viewModel.trips.last)

        viewModel.tapMore(trip)
        viewModel.tapEdit()
        let editor = try #require(viewModel.editor)
        editor.selectedYear = 2026
        editor.selectedMonth = 1
        editor.submit()
        try await waitUntil { viewModel.focus != nil }

        #expect(viewModel.trips.map(\.id) == ["4", "1", "2", "3"])
        #expect(viewModel.focus == ProfileV3PastTripsViewModel.Focus(tripID: "4", request: 1))
        #expect(viewModel.revealingTripID == "4")
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
    struct Added {
        let submit: ProfileV3BoardAction
        let country: String
        let year: Int
        let month: Int
    }

    struct Edited {
        let submit: ProfileV3BoardAction
        let year: Int
        let month: Int
    }

    private let lock = NSLock()
    private var trips: [ProfileV3PastTrip]

    init(trips: [ProfileV3PastTrip] = [ProfileV3PastTrip(id: "41", countryCode: "JP", year: 2025, month: 3)]) {
        self.trips = trips
    }
    private var _added: [Added] = []
    private var _edited: [Edited] = []
    private var _deleted: [ProfileV3BoardAction] = []
    private var unavailableDeletes = 0

    var added: [Added] { lock.withLock { _added } }
    var edited: [Edited] { lock.withLock { _edited } }
    var deleted: [ProfileV3BoardAction] { lock.withLock { _deleted } }

    func failNextDelete() {
        lock.withLock { unavailableDeletes += 1 }
    }

    func loadPastTrips(profileID: String) async throws -> ProfileV3PastTripsScreen {
        let trips = lock.withLock { self.trips }
        return ProfileV3PastTripsScreen(
            title: "Your past trips",
            trips: trips.newestFirst.map { trip in
                var trip = trip
                trip.edit = ProfileV3TripAction(label: "Edit", submit: Self.action("edit_past_trip", trip.id, profileID))
                trip.delete = ProfileV3TripAction(label: "Delete", submit: Self.action("delete_past_trip", trip.id, profileID))
                return trip
            },
            addDirective: ProfileV3Directive(go: "add_trip", profileID: profileID),
            duration: Self.duration(cta: "Save"),
            deleteConfirm: nil
        )
    }

    func loadAddTrip(profileID: String) async throws -> ProfileV3AddTripScreen {
        ProfileV3AddTripScreen(
            countryTitle: "SEARCH FOR COUNTRY",
            searchPlaceholder: "Search",
            countryCTA: "Done",
            countries: [ProfileV3Country(code: "MU", name: "Mauritius")],
            duration: Self.duration(cta: "Add country"),
            submit: ProfileV3BoardAction(fields: ["action": .string("add_past_trip"), "profile_id": .string(profileID)])
        )
    }

    func addPastTrip(_ submit: ProfileV3BoardAction, country: String, year: Int, month: Int) async throws {
        lock.withLock {
            _added.append(Added(submit: submit, country: country, year: year, month: month))
            trips.append(ProfileV3PastTrip(id: "new-\(_added.count)", countryCode: country, year: year, month: month))
        }
    }

    func editPastTrip(_ submit: ProfileV3BoardAction, year: Int, month: Int) async throws {
        lock.withLock {
            _edited.append(Edited(submit: submit, year: year, month: month))
            let id = submit.fields["trip_id"]?.stringValue
            guard let index = trips.firstIndex(where: { $0.id == id }) else { return }
            let trip = trips[index]
            trips[index] = ProfileV3PastTrip(id: trip.id, countryCode: trip.countryCode, year: year, month: month)
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

    private static func duration(cta: String) -> ProfileV3TripDuration {
        ProfileV3TripDuration(
            title: "SELECT DURATION",
            yearLabel: "YEAR",
            monthLabel: "MONTH",
            years: [2024, 2025, 2026],
            months: (1...12).map { ProfileV3TripMonth(value: $0, label: "M\($0)") },
            max: ProfileV3TripYearMonth(year: 2026, month: 2),
            defaultValue: ProfileV3TripYearMonth(year: 2026, month: 1),
            ctaLabel: cta
        )
    }
}
