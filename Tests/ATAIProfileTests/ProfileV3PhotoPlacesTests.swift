import Foundation
import Testing
@testable import ATAIProfile

@Suite("Photo places: country lookup")
struct ProfileV3CountryLocatorTests {
    @Test func findsTheCountryContainingAPoint() throws {
        let locator = try Self.squares()

        #expect(locator.countryCode(latitude: 2, longitude: 2) == "AA")
        #expect(locator.countryCode(latitude: 25, longitude: 25) == "BB")
        #expect(locator.countryCode(latitude: 5, longitude: 5) == nil)
        #expect(locator.countryCode(latitude: 15, longitude: 15) == nil)
    }

    @Test func snapsCoastalPointsToTheNearestCountryWithinReach() throws {
        let locator = try Self.squares()

        #expect(locator.countryCode(latitude: 5, longitude: 10.1) == "AA")
        #expect(locator.countryCode(latitude: 5, longitude: 10.4) == nil)
    }

    @Test func rejectsOutOfRangeCoordinates() throws {
        let locator = try Self.squares()

        #expect(locator.countryCode(latitude: 91, longitude: 2) == nil)
        #expect(locator.countryCode(latitude: 2, longitude: 181) == nil)
    }

    @Test func bundledShapesResolveTravelDestinations() throws {
        let locator = try #require(ProfileV3CountryLocator.bundled)
        let places: [(Double, Double, String?)] = [
            (48.8566, 2.3522, "FR"),
            (35.6762, 139.6503, "JP"),
            (28.6139, 77.2090, "IN"),
            (40.7128, -74.0060, "US"),
            (-33.8568, 151.2153, "AU"),
            (1.2834, 103.8607, "SG"),
            (25.2048, 55.2708, "AE"),
            (4.1755, 73.5093, "MV"),
            (43.7384, 7.4246, "MC"),
            (22.3193, 114.1694, "HK"),
            (47.5596, 7.5886, "CH"),
            (48.5734, 7.7521, "FR"),
            (-8.7180, 115.1686, "ID"),
            (-18.1248, 178.4501, "FJ"),
            (35.1856, 33.3823, "CY"),
            (34.1526, 77.5771, "IN"),
            (30.0, -40.0, nil),
        ]

        #expect(locator.countryCount > 230)
        for (latitude, longitude, code) in places {
            #expect(locator.countryCode(latitude: latitude, longitude: longitude) == code, "\(latitude), \(longitude)")
        }
    }

    static func squares() throws -> ProfileV3CountryLocator {
        let json = #"""
        {"type":"FeatureCollection","features":[
          {"type":"Feature","properties":{"iso":"aa"},"geometry":{"type":"MultiPolygon","coordinates":[
            [[[0,0],[10,0],[10,10],[0,10],[0,0]],[[4,4],[6,4],[6,6],[4,6],[4,4]]]
          ]}},
          {"type":"Feature","properties":{"iso":"BB"},"geometry":{"type":"MultiPolygon","coordinates":[
            [[[20,20],[30,20],[30,30],[20,30],[20,20]]]
          ]}}
        ]}
        """#
        return try ProfileV3CountryLocator(geoJSON: Data(json.utf8))
    }
}

@Suite("Photo places: aggregation")
struct ProfileV3PhotoPlacesAggregationTests {
    @Test func nearbyPhotosShareOneLookupAndKeepTheirDates() throws {
        var tally = ProfileV3PhotoPlaceTally()
        tally.record(latitude: 2.0001, longitude: 2.0001, takenAt: Self.day(3))
        tally.record(latitude: 2.0002, longitude: 2.0002, takenAt: Self.day(1))
        tally.record(latitude: 2.0003, longitude: 1.9999, takenAt: Self.day(7))
        tally.record(latitude: 25, longitude: 25, takenAt: Self.day(5))

        #expect(tally.spots.count == 2)
        let countries = tally.countries(using: try ProfileV3CountryLocatorTests.squares())
        #expect(countries == [
            ProfileV3PhotoCountry(countryCode: "AA", photoCount: 3, firstSeen: Self.day(1), lastSeen: Self.day(7)),
            ProfileV3PhotoCountry(countryCode: "BB", photoCount: 1, firstSeen: Self.day(5), lastSeen: Self.day(5)),
        ])
    }

    @Test func ignoresInvalidCoordinatesAndPhotosOutsideEveryCountry() throws {
        var tally = ProfileV3PhotoPlaceTally()
        tally.record(latitude: 0, longitude: 0, takenAt: Self.day(1))
        tally.record(latitude: 120, longitude: 2, takenAt: Self.day(1))
        tally.record(latitude: 15, longitude: 15, takenAt: Self.day(1))

        #expect(tally.spots.count == 1)
        #expect(tally.countries(using: try ProfileV3CountryLocatorTests.squares()).isEmpty)
    }

    @Test func remembersTheNewestPhotoEvenWithoutALocation() {
        var tally = ProfileV3PhotoPlaceTally()
        tally.noteScanned(takenAt: Self.day(2))
        tally.noteScanned(takenAt: Self.day(9))
        tally.noteScanned(takenAt: nil)

        #expect(tally.latestTakenAt == Self.day(9))
    }

    @Test func mergingAddsCountsAndWidensTheDateRange() {
        let existing = [ProfileV3PhotoCountry(countryCode: "JP", photoCount: 10, firstSeen: Self.day(3), lastSeen: Self.day(4))]
        let new = [
            ProfileV3PhotoCountry(countryCode: "JP", photoCount: 2, firstSeen: Self.day(8), lastSeen: Self.day(9)),
            ProfileV3PhotoCountry(countryCode: "FR", photoCount: 1, firstSeen: Self.day(6), lastSeen: Self.day(6)),
        ]

        #expect(existing.merging(new) == [
            ProfileV3PhotoCountry(countryCode: "JP", photoCount: 12, firstSeen: Self.day(3), lastSeen: Self.day(9)),
            ProfileV3PhotoCountry(countryCode: "FR", photoCount: 1, firstSeen: Self.day(6), lastSeen: Self.day(6)),
        ])
    }

    @Test func uploadCarriesOnlyCountryTotals() throws {
        let upload = ProfileV3PhotoPlacesUpload(
            countries: [ProfileV3PhotoCountry(countryCode: "JP", photoCount: 12, firstSeen: Self.day(3), lastSeen: Self.day(9))],
            scannedThrough: Self.day(9),
            access: .limited
        )
        let body = try ProfileV3SyncPhotoPlacesRequest.body(for: upload)

        #expect(String(decoding: body, as: UTF8.self) == #"""
        {"access":"limited","action":"sync_photo_places","countries":[{"country_code":"JP","first_seen":"2024-01-03T00:00:00Z","last_seen":"2024-01-09T00:00:00Z","photo_count":12}],"scanned_through":"2024-01-09T00:00:00Z"}
        """#)
    }

    static func day(_ day: Int) -> Date {
        var components = DateComponents(year: 2024, month: 1, day: day)
        components.timeZone = TimeZone(identifier: "UTC")
        return Calendar(identifier: .gregorian).date(from: components)!
    }
}

@MainActor
@Suite("Photo places: sync")
struct ProfileV3PhotoPlacesSyncTests {
    @Test func connectingScansEverythingAndUploadsTheCountries() async throws {
        let harness = try Harness(access: .full)
        harness.library.tallies = [Self.tally((2, 2, 3))]

        #expect(await harness.sync.connect() == .connected)
        await harness.sync.settle()

        #expect(harness.library.requests == [nil])
        #expect(harness.uploads.value.map(\.countries.count) == [1])
        #expect(harness.sync.isConnected)
        #expect(harness.sync.countryCodes == ["AA"])
    }

    @Test func laterSyncsScanOnlyNewPhotosAndMergeThem() async throws {
        let harness = try Harness(access: .full)
        harness.library.tallies = [Self.tally((2, 2, 3)), Self.tally((25, 25, 8), (2, 2, 9))]
        _ = await harness.sync.connect()
        await harness.sync.settle()

        harness.sync.syncIfConnected()
        await harness.sync.settle()

        let day3 = ProfileV3PhotoPlacesAggregationTests.day(3)
        #expect(harness.library.requests == [nil, day3])
        let last = try #require(harness.uploads.value.last)
        #expect(last.scannedThrough == ProfileV3PhotoPlacesAggregationTests.day(9))
        #expect(last.countries.map(\.countryCode) == ["AA", "BB"])
        #expect(last.countries.first?.photoCount == 2)
    }

    @Test func nothingNewMeansNoUpload() async throws {
        let harness = try Harness(access: .full)
        harness.library.tallies = [Self.tally((2, 2, 3)), ProfileV3PhotoPlaceTally()]
        _ = await harness.sync.connect()
        await harness.sync.settle()

        harness.sync.syncIfConnected()
        await harness.sync.settle()

        #expect(harness.uploads.value.count == 1)
    }

    @Test func limitedAccessRescansTheSelectionEveryTime() async throws {
        let harness = try Harness(access: .limited)
        harness.library.tallies = [Self.tally((2, 2, 3)), Self.tally((25, 25, 4))]
        _ = await harness.sync.connect()
        await harness.sync.settle()

        harness.sync.syncIfConnected()
        await harness.sync.settle()

        #expect(harness.library.requests == [nil, nil])
        #expect(harness.sync.countryCodes == ["BB"])
        #expect(harness.uploads.value.last?.scannedThrough == nil)
    }

    @Test func declinedAccessDoesNotConnect() async throws {
        let harness = try Harness(access: .denied)

        #expect(await harness.sync.connect() == .denied)
        #expect(!harness.sync.isConnected)
        #expect(harness.library.requests.isEmpty)
        #expect(harness.uploads.value.isEmpty)
    }

    @Test func disconnectingStopsSyncingAndForgetsTheCountries() async throws {
        let harness = try Harness(access: .full)
        harness.library.tallies = [Self.tally((2, 2, 3)), Self.tally((25, 25, 8))]
        _ = await harness.sync.connect()
        await harness.sync.settle()

        harness.sync.disconnect()
        harness.sync.syncIfConnected()
        await harness.sync.settle()

        #expect(!harness.sync.isConnected)
        #expect(harness.sync.countryCodes.isEmpty)
        #expect(harness.library.requests.count == 1)
        #expect(harness.store.load() == ProfileV3PhotoPlacesState())
    }

    @Test func revokedAccessStopsSyncing() async throws {
        let harness = try Harness(access: .full)
        harness.library.tallies = [Self.tally((2, 2, 3))]
        _ = await harness.sync.connect()
        await harness.sync.settle()

        harness.library.currentAccess = .denied
        harness.sync.syncIfConnected()
        await harness.sync.settle()

        #expect(!harness.sync.isConnected)
        #expect(harness.library.requests.count == 1)
    }

    @Test func aFailedUploadIsRetriedOnTheNextSync() async throws {
        let harness = try Harness(access: .full)
        harness.library.tallies = [Self.tally((2, 2, 3)), ProfileV3PhotoPlaceTally()]
        harness.uploads.failNext = true
        _ = await harness.sync.connect()
        await harness.sync.settle()

        harness.sync.syncIfConnected()
        await harness.sync.settle()

        #expect(harness.uploads.value.count == 1)
        #expect(!harness.store.load().needsUpload)
    }

    @Test func serverPhotosRowIsKeptAndConnectsOnTheDevice() throws {
        let json = #"""
        {"title":"Connectors","connectors":[
          {"key":"gmail","label":"Gmail","connected":true},
          {"key":"photos","label":"Photos","connected":false}
        ]}
        """#
        let dto = try JSONDecoder().decode(ProfileV3ConnectorsScreenDTO.self, from: Data(json.utf8))
        let photos = try #require(ProfileV3ConnectorsMapper.screen(dto).connectors.first { $0.id == "photos" })

        #expect(photos.captureStep == nil)
        #expect(photos.canConnect)
        #expect(!ProfileV3Connector(id: "photos", name: "Photos", icon: .remote(nil), status: .connected).canConnect)
    }

    static func tally(_ photos: (Double, Double, Int)...) -> ProfileV3PhotoPlaceTally {
        var tally = ProfileV3PhotoPlaceTally()
        for (latitude, longitude, day) in photos {
            let date = ProfileV3PhotoPlacesAggregationTests.day(day)
            tally.noteScanned(takenAt: date)
            tally.record(latitude: latitude, longitude: longitude, takenAt: date)
        }
        return tally
    }

    @MainActor
    final class Harness {
        let library: FakePhotoLibrary
        let uploads: UploadRecorder
        let store: ProfileV3PhotoPlacesStore
        let sync: ProfileV3PhotoPlacesSync

        init(access: ProfileV3PhotoAccess) throws {
            let defaults = try #require(UserDefaults(suiteName: "ProfileV3PhotoPlacesTests.\(UUID().uuidString)"))
            let library = FakePhotoLibrary()
            library.currentAccess = access
            let uploads = UploadRecorder()
            let store = ProfileV3PhotoPlacesStore(defaults: defaults, userID: { "user-1" })
            let locator = try ProfileV3CountryLocatorTests.squares()
            self.library = library
            self.uploads = uploads
            self.store = store
            sync = ProfileV3PhotoPlacesSync(
                library: library,
                store: store,
                upload: { try await uploads.record($0) },
                locate: { locator }
            )
        }
    }
}

final class FakePhotoLibrary: ProfileV3PhotoLibraryReading, @unchecked Sendable {
    private let lock = NSLock()
    private var _access = ProfileV3PhotoAccess.notDetermined
    private var _tallies: [ProfileV3PhotoPlaceTally] = []
    private var _requests: [Date?] = []

    var currentAccess: ProfileV3PhotoAccess {
        get { lock.withLock { _access } }
        set { lock.withLock { _access = newValue } }
    }

    var tallies: [ProfileV3PhotoPlaceTally] {
        get { lock.withLock { _tallies } }
        set { lock.withLock { _tallies = newValue } }
    }

    var requests: [Date?] { lock.withLock { _requests } }

    var access: ProfileV3PhotoAccess { currentAccess }

    func requestAccess() async -> ProfileV3PhotoAccess { currentAccess }

    func tally(takenAfter date: Date?) async throws -> ProfileV3PhotoPlaceTally {
        lock.withLock {
            _requests.append(date)
            return _tallies.isEmpty ? ProfileV3PhotoPlaceTally() : _tallies.removeFirst()
        }
    }
}

final class UploadRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: [ProfileV3PhotoPlacesUpload] = []
    private var _failNext = false

    var value: [ProfileV3PhotoPlacesUpload] { lock.withLock { _value } }

    var failNext: Bool {
        get { lock.withLock { _failNext } }
        set { lock.withLock { _failNext = newValue } }
    }

    func record(_ upload: ProfileV3PhotoPlacesUpload) async throws {
        try lock.withLock {
            if _failNext {
                _failNext = false
                throw ProfileV3RepositoryError.unavailable
            }
            _value.append(upload)
        }
    }
}
