import Foundation

#if DEBUG
enum ProfileV3PastTripsFixtures {
    static let trips = [
        ProfileV3PastTrip(id: "trip-mu-2026", countryCode: "MU", date: ProfileV3TripYearMonth(year: 2026, month: 3)),
        ProfileV3PastTrip(id: "trip-jp-2025", countryCode: "JP", date: ProfileV3TripYearMonth(year: 2025, month: 3)),
        ProfileV3PastTrip(id: "country:IT", countryCode: "IT", date: nil)
    ]

    static let byProfile = [ProfileV3Fixtures.worldPass.id: trips]

    static func screen(_ trips: [ProfileV3PastTrip], profileID: String) -> ProfileV3PastTripsScreen {
        ProfileV3PastTripsScreen(
            title: "Your past trips",
            trips: trips.map { trip in
                var trip = trip
                if trip.date != nil {
                    trip.edit = ProfileV3TripAction(
                        label: "Edit",
                        submit: action("edit_past_trip", tripID: trip.id, profileID: profileID)
                    )
                }
                trip.delete = ProfileV3TripAction(
                    label: "Delete",
                    submit: action("delete_past_trip", tripID: trip.id, profileID: profileID)
                )
                return trip
            },
            addDirective: ProfileV3Directive(go: "add_trip", profileID: profileID),
            duration: duration(ctaLabel: "Save"),
            deleteConfirm: ProfileV3TripDeleteConfirm(
                title: "Are you sure you want to delete your past destination?",
                confirmLabel: ProfileV3Strings.proceedToDelete,
                cancelLabel: "Don't delete"
            )
        )
    }

    static func duration(ctaLabel: String) -> ProfileV3TripDuration {
        var duration = ProfileV3TripDuration.fallback()
        duration.title = "Select duration"
        duration.yearLabel = "Year"
        duration.monthLabel = ProfileV3Strings.tripMonth
        duration.ctaLabel = ctaLabel
        return duration
    }

    static func addScreen(profileID: String) -> ProfileV3AddTripScreen {
        ProfileV3AddTripScreen(
            countryTitle: "Search for country",
            searchPlaceholder: ProfileV3Strings.search,
            countryCTA: "Done",
            countries: ProfileV3Countries.all,
            duration: duration(ctaLabel: "Add country"),
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
