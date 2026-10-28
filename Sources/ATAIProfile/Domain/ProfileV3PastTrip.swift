import Foundation

struct ProfileV3PastTrip: Identifiable, Equatable, Sendable {
    let id: String
    let countryCode: String
    let date: ProfileV3TripYearMonth?
    var imageURL: URL?
    var name: String?
    var monthLabel: String?
    var delete: ProfileV3TripAction?

    var sortKey: Int { date.map { $0.year * 100 + $0.month } ?? 0 }

    var revision: String { "\(id)-\(countryCode)-\(sortKey)" }

    var countryName: String {
        name ?? ProfileV3Country(code: countryCode)?.name ?? countryCode
    }

    var monthName: String? {
        guard let date else { return nil }
        return monthLabel ?? ProfileV3TripCalendar.monthName(date.month)
    }

    var displayImageURL: URL? {
        imageURL ?? ProfileV3DestinationArt.url(for: countryCode)
    }

    func matches(_ draft: ProfileV3PastTripDraft) -> Bool {
        countryCode == draft.countryCode
    }
}

struct ProfileV3PastTripDraft: Equatable, Sendable {
    let countryCode: String
}

struct ProfileV3TripAction: Equatable, Sendable {
    let label: String
    let submit: ProfileV3BoardAction
}

struct ProfileV3TripYearMonth: Equatable, Sendable {
    let year: Int
    let month: Int
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
    var deleteConfirm: ProfileV3TripDeleteConfirm?
}

struct ProfileV3AddTripScreen: Equatable, Sendable {
    var countryTitle: String
    var searchPlaceholder: String
    var countryCTA: String
    var countries: [ProfileV3Country]
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
}

extension Array where Element == ProfileV3PastTrip {
    var listed: [ProfileV3PastTrip] {
        let dated = filter { $0.date != nil }.sorted { $0.sortKey > $1.sortKey }
        let covered = Set(dated.map(\.countryCode))
        let undated = filter { $0.date == nil && !covered.contains($0.countryCode) }
            .sorted { $0.countryName.localizedStandardCompare($1.countryName) == .orderedAscending }
        return dated + undated
    }
}
