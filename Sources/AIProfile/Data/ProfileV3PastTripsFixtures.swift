import Foundation

#if DEBUG
enum ProfileV3PastTripsFixtures {
    static let trips = [
        ProfileV3PastTrip(id: "trip-mu-2026", countryCode: "MU", year: 2026, month: 3),
        ProfileV3PastTrip(id: "trip-jp-2025", countryCode: "JP", year: 2025, month: 3)
    ]

    static let byProfile = [ProfileV3Fixtures.worldPass.id: trips]
}
#endif
