import Foundation

#if DEBUG
actor ProfileV3PastTripsStore {
    private var tripsByProfile: [String: [ProfileV3PastTrip]]

    init(tripsByProfile: [String: [ProfileV3PastTrip]] = [:]) {
        self.tripsByProfile = tripsByProfile
    }

    func trips(profileID: String) -> [ProfileV3PastTrip] {
        (tripsByProfile[profileID] ?? []).listed
    }

    func add(_ draft: ProfileV3PastTripDraft, profileID: String) {
        let trips = tripsByProfile[profileID] ?? []
        guard draft.date != nil || !trips.contains(where: { $0.date == nil && $0.countryCode == draft.countryCode }) else {
            return
        }
        let trip = ProfileV3PastTrip(
            id: draft.date == nil ? "country:\(draft.countryCode)" : UUID().uuidString,
            countryCode: draft.countryCode,
            date: draft.date
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
            date: ProfileV3TripYearMonth(year: year, month: month)
        )
    }

    func remove(id: String, profileID: String) {
        tripsByProfile[profileID]?.removeAll { $0.id == id }
    }
}
#endif
