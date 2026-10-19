import Foundation

struct ProfileV3PastTrip: Identifiable, Equatable, Sendable {
    let id: String
    let countryCode: String
    let year: Int
    let month: Int
    var imageURL: URL?
    var name: String?
    var monthLabel: String?
    var edit: ProfileV3TripAction?
    var delete: ProfileV3TripAction?

    var sortKey: Int { year * 100 + month }

    var revision: String { "\(id)-\(countryCode)-\(sortKey)" }

    var countryName: String {
        name ?? ProfileV3Country(code: countryCode)?.name ?? countryCode
    }

    var monthName: String {
        monthLabel ?? ProfileV3TripCalendar.monthName(month)
    }

    var displayImageURL: URL? {
        imageURL ?? ProfileV3DestinationArt.url(for: countryCode)
    }

    func matches(_ draft: ProfileV3PastTripDraft) -> Bool {
        countryCode == draft.countryCode && year == draft.year && month == draft.month
    }
}

struct ProfileV3PastTripDraft: Equatable, Sendable {
    let countryCode: String
    let year: Int
    let month: Int
}

struct ProfileV3TripAction: Equatable, Sendable {
    let label: String
    let submit: ProfileV3BoardAction
}

struct ProfileV3TripYearMonth: Equatable, Sendable {
    let year: Int
    let month: Int
}

struct ProfileV3TripMonth: Equatable, Sendable {
    let value: Int
    let label: String
}

struct ProfileV3TripDuration: Equatable, Sendable {
    var title: String
    var yearLabel: String
    var monthLabel: String
    var years: [Int]
    var months: [ProfileV3TripMonth]
    var max: ProfileV3TripYearMonth?
    var defaultValue: ProfileV3TripYearMonth?
    var ctaLabel: String

    var pickableYears: [Int] {
        guard let max else { return years }
        return years.filter { $0 <= max.year }
    }

    func months(in year: Int?) -> [ProfileV3TripMonth] {
        guard let max, let year, year >= max.year else { return months }
        return months.filter { $0.value <= max.month }
    }

    func label(forMonth value: Int) -> String {
        months.first { $0.value == value }?.label ?? ProfileV3TripCalendar.shortMonthName(value)
    }

    static func fallback(
        ctaLabel: String,
        now: Date = Date(),
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> ProfileV3TripDuration {
        let today = calendar.dateComponents([.year, .month], from: now)
        let year = today.year ?? 0
        let month = today.month ?? 1
        return ProfileV3TripDuration(
            title: ProfileV3Strings.selectDuration,
            yearLabel: ProfileV3Strings.tripYear,
            monthLabel: ProfileV3Strings.tripMonth,
            years: Array((year - ProfileV3Theme.Counts.pastTripYears)...year),
            months: (1...ProfileV3Theme.Counts.monthsInYear).map {
                ProfileV3TripMonth(value: $0, label: ProfileV3TripCalendar.shortMonthName($0))
            },
            max: ProfileV3TripYearMonth(year: year, month: month),
            defaultValue: ProfileV3TripYearMonth(year: year, month: month),
            ctaLabel: ctaLabel
        )
    }
}

struct ProfileV3TripDeleteConfirm: Equatable, Sendable {
    let title: String
    let confirmLabel: String
    let cancelLabel: String
}

struct ProfileV3PastTripsScreen: Equatable, Sendable {
    var title: String
    var trips: [ProfileV3PastTrip]
    var addDirective: ProfileV3Directive?
    var duration: ProfileV3TripDuration?
    var deleteConfirm: ProfileV3TripDeleteConfirm?
}

struct ProfileV3AddTripScreen: Equatable, Sendable {
    var countryTitle: String
    var searchPlaceholder: String
    var countryCTA: String
    var countries: [ProfileV3Country]
    var duration: ProfileV3TripDuration
    var submit: ProfileV3BoardAction?
}

enum ProfileV3TripsEntry: Equatable, Sendable {
    case add(label: String, next: ProfileV3Directive)
    case pill(flags: [String], more: Int, next: ProfileV3Directive?, add: ProfileV3Directive?)
}

enum ProfileV3TripCalendar {
    private static let symbols: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static func monthName(_ month: Int) -> String {
        symbols.standaloneMonthSymbols[safe: month - 1] ?? ""
    }

    static func shortMonthName(_ month: Int) -> String {
        (symbols.shortStandaloneMonthSymbols[safe: month - 1] ?? "").uppercased()
    }
}

extension Array where Element == ProfileV3PastTrip {
    var newestFirst: [ProfileV3PastTrip] {
        sorted { $0.sortKey > $1.sortKey }
    }
}
