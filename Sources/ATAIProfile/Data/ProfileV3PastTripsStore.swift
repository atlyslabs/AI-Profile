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
        guard !trips.contains(where: { $0.date == nil && $0.countryCode == draft.countryCode }) else { return }
        let trip = ProfileV3PastTrip(id: "country:\(draft.countryCode)", countryCode: draft.countryCode, date: nil)
        tripsByProfile[profileID, default: []].append(trip)
    }

    func remove(id: String, profileID: String) {
        tripsByProfile[profileID]?.removeAll { $0.id == id }
    }
}
#endif
