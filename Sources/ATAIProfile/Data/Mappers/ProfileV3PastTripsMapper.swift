import Foundation

enum ProfileV3PastTripsMapper: ProfileV3DTOReading {
    private static let monthRange = 1...ProfileV3Theme.Counts.monthsInYear

    static func screen(_ dto: ProfileV3PastTripsScreenDTO) -> ProfileV3PastTripsScreen {
        ProfileV3PastTripsScreen(
            title: text(dto.title) ?? "",
            trips: dto.trips.compactMap(trip),
            addDirective: dto.add?.directive,
            duration: dto.duration.map(duration),
            deleteConfirm: dto.deleteConfirm.map(deleteConfirm)
        )
    }

    static func addScreen(_ dto: ProfileV3AddTripScreenDTO) -> ProfileV3AddTripScreen {
        let step = dto.country
        return ProfileV3AddTripScreen(
            countryTitle: text(step?.title) ?? "",
            searchPlaceholder: text(step?.searchPlaceholder) ?? "",
            countryCTA: text(step?.ctaLabel) ?? "",
            countries: (step?.countries ?? []).compactMap(country),
            duration: dto.duration.map(duration) ?? .fallback(),
            submit: action(dto.submit)
        )
    }

    static func entry(_ dto: ProfileV3GlobeDTO?) -> ProfileV3TripsEntry? {
        if let pill = dto?.tripsPill {
            let flags = pill.flags.compactMap { text($0)?.uppercased() }
            let more = max(pill.more?.intValue ?? 0, 0)
            if !flags.isEmpty || more > 0 || pill.next != nil {
                return .pill(flags: flags, more: more, next: pill.next?.directive, add: pill.add?.directive)
            }
        }
        if let add = dto?.addTrips, let next = add.next?.directive, let label = text(add.label) {
            return .add(label: label, next: next)
        }
        return nil
    }

    static func trip(_ dto: ProfileV3PastTripDTO) -> ProfileV3PastTrip? {
        guard let id = text(dto.tripID?.stringValue),
              let code = text(dto.code)?.uppercased(),
              let year = dto.year?.intValue,
              let month = dto.month?.intValue, monthRange.contains(month) else { return nil }
        return ProfileV3PastTrip(
            id: id,
            countryCode: code,
            year: year,
            month: month,
            imageURL: remoteURL(dto.imageURL),
            name: text(dto.name),
            monthLabel: text(dto.monthLabel),
            edit: tripAction(dto.edit),
            delete: tripAction(dto.delete)
        )
    }

    private static func tripAction(_ dto: ProfileV3TripActionDTO?) -> ProfileV3TripAction? {
        guard let dto, let submit = action(dto.submit), let label = text(dto.label) else { return nil }
        return ProfileV3TripAction(label: label, submit: submit)
    }

    private static func action(_ dto: ProfileV3BoardActionDTO?) -> ProfileV3BoardAction? {
        guard let fields = dto?.fields, !fields.isEmpty else { return nil }
        return ProfileV3BoardAction(fields: fields)
    }

    private static func duration(_ dto: ProfileV3TripDurationDTO) -> ProfileV3TripDuration {
        let fallback = ProfileV3TripDuration.fallback()
        let years = dto.years.compactMap(\.intValue)
        let months = dto.months.compactMap { month -> ProfileV3TripMonth? in
            guard let value = month.value?.intValue, monthRange.contains(value) else { return nil }
            return ProfileV3TripMonth(value: value, label: text(month.label) ?? ProfileV3TripCalendar.shortMonthName(value))
        }
        return ProfileV3TripDuration(
            title: text(dto.title) ?? "",
            yearLabel: text(dto.yearLabel) ?? "",
            monthLabel: text(dto.monthLabel) ?? "",
            years: years.isEmpty ? fallback.years : years,
            months: months.isEmpty ? fallback.months : months,
            max: yearMonth(dto.max) ?? fallback.max,
            defaultValue: yearMonth(dto.defaultValue) ?? fallback.defaultValue,
            ctaLabel: text(dto.ctaLabel) ?? ""
        )
    }

    private static func yearMonth(_ dto: ProfileV3TripYearMonthDTO?) -> ProfileV3TripYearMonth? {
        guard let year = dto?.year?.intValue, let month = dto?.month?.intValue, monthRange.contains(month) else {
            return nil
        }
        return ProfileV3TripYearMonth(year: year, month: month)
    }

    private static func deleteConfirm(_ dto: ProfileV3TripDeleteConfirmDTO) -> ProfileV3TripDeleteConfirm {
        ProfileV3TripDeleteConfirm(
            title: text(dto.title) ?? "",
            confirmLabel: text(dto.confirmLabel) ?? "",
            cancelLabel: text(dto.cancelLabel) ?? ""
        )
    }

    private static func country(_ dto: ProfileV3TripCountryDTO) -> ProfileV3Country? {
        guard let code = text(dto.code)?.uppercased() else { return nil }
        return ProfileV3Country(code: code, name: text(dto.name) ?? ProfileV3Country(code: code)?.name ?? code)
    }
}
