import Foundation

actor ProfileV3PastTripsStore {
    static let shared = ProfileV3PastTripsStore()

    private var tripsByProfile: [String: [ProfileV3PastTrip]]

    init(tripsByProfile: [String: [ProfileV3PastTrip]] = [:]) {
        self.tripsByProfile = tripsByProfile
    }

    func trips(profileID: String) -> [ProfileV3PastTrip] {
        (tripsByProfile[profileID] ?? []).newestFirst
    }

    func add(_ draft: ProfileV3PastTripDraft, profileID: String) -> ProfileV3PastTrip {
        let trip = ProfileV3PastTrip(
            id: UUID().uuidString,
            countryCode: draft.countryCode,
            year: draft.year,
            month: draft.month
        )
        tripsByProfile[profileID, default: []].append(trip)
        return trip
    }

    func update(id: String, with draft: ProfileV3PastTripDraft, profileID: String) throws -> ProfileV3PastTrip {
        guard let index = tripsByProfile[profileID]?.firstIndex(where: { $0.id == id }) else {
            throw ProfileV3RepositoryError.unavailable
        }
        let trip = ProfileV3PastTrip(id: id, countryCode: draft.countryCode, year: draft.year, month: draft.month)
        tripsByProfile[profileID]?[index] = trip
        return trip
    }

    func remove(id: String, profileID: String) {
        tripsByProfile[profileID]?.removeAll { $0.id == id }
    }
}
