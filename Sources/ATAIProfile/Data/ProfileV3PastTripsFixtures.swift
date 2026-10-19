import Foundation

#if DEBUG
enum ProfileV3PastTripsFixtures {
    static let trips = [
        ProfileV3PastTrip(id: "trip-mu-2026", countryCode: "MU", year: 2026, month: 3),
        ProfileV3PastTrip(id: "trip-jp-2025", countryCode: "JP", year: 2025, month: 3)
    ]

    static let byProfile = [ProfileV3Fixtures.worldPass.id: trips]

    static func screen(_ trips: [ProfileV3PastTrip], profileID: String) -> ProfileV3PastTripsScreen {
        ProfileV3PastTripsScreen(
            title: ProfileV3Strings.pastTripsTitle,
            trips: trips.map { trip in
                var trip = trip
                trip.edit = ProfileV3TripAction(
                    label: ProfileV3Strings.editTrip,
                    submit: action("edit_past_trip", tripID: trip.id, profileID: profileID)
                )
                trip.delete = ProfileV3TripAction(
                    label: ProfileV3Strings.deleteTrip,
                    submit: action("delete_past_trip", tripID: trip.id, profileID: profileID)
                )
                return trip
            },
            addDirective: ProfileV3Directive(go: "add_trip", profileID: profileID),
            duration: .fallback(ctaLabel: ProfileV3Strings.saveTrip),
            deleteConfirm: ProfileV3TripDeleteConfirm(
                title: ProfileV3Strings.deletePastTripTitle,
                confirmLabel: ProfileV3Strings.proceedToDelete,
                cancelLabel: ProfileV3Strings.keepPastTrip
            )
        )
    }

    static func addScreen(profileID: String) -> ProfileV3AddTripScreen {
        ProfileV3AddTripScreen(
            countryTitle: ProfileV3Strings.searchForCountry,
            searchPlaceholder: ProfileV3Strings.search,
            countryCTA: ProfileV3Strings.tripDone,
            countries: ProfileV3Countries.all,
            duration: .fallback(ctaLabel: ProfileV3Strings.addCountry),
            submit: ProfileV3BoardAction(fields: [
                "action": .string("add_past_trip"),
                "profile_id": .string(profileID)
            ])
        )
    }

    private static func action(_ name: String, tripID: String, profileID: String) -> ProfileV3BoardAction {
        ProfileV3BoardAction(fields: [
            "action": .string(name),
            "trip_id": .string(tripID),
            "profile_id": .string(profileID)
        ])
    }
}
#endif
