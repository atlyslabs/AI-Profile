import Foundation

#if DEBUG
actor ProfileV3PastTripsStore {
    private var tripsByProfile: [String: [ProfileV3PastTrip]]

    init(tripsByProfile: [String: [ProfileV3PastTrip]] = [:]) {
        self.tripsByProfile = tripsByProfile
    }

    func trips(profileID: String) -> [ProfileV3PastTrip] {
        (tripsByProfile[profileID] ?? []).newestFirst
    }

    func add(_ draft: ProfileV3PastTripDraft, profileID: String) {
        let trip = ProfileV3PastTrip(
            id: UUID().uuidString,
            countryCode: draft.countryCode,
            year: draft.year,
            month: draft.month
        )
        tripsByProfile[profileID, default: []].append(trip)
    }

    func reschedule(id: String, year: Int, month: Int, profileID: String) throws {
        guard let index = tripsByProfile[profileID]?.firstIndex(where: { $0.id == id }),
              let trip = tripsByProfile[profileID]?[index] else {
            throw ProfileV3RepositoryError.unavailable
        }
        tripsByProfile[profileID]?[index] = ProfileV3PastTrip(
            id: id,
            countryCode: trip.countryCode,
            year: year,
            month: month
        )
    }

    func remove(id: String, profileID: String) {
        tripsByProfile[profileID]?.removeAll { $0.id == id }
    }
}
#endif
