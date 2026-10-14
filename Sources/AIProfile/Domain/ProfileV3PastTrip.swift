import Foundation

struct ProfileV3PastTrip: Identifiable, Equatable, Sendable {
    let id: String
    let countryCode: String
    let year: Int
    let month: Int
    var imageURL: URL?

    var sortKey: Int { year * 100 + month }

    var revision: String { "\(id)-\(countryCode)-\(sortKey)" }

    var countryName: String {
        ProfileV3Country(code: countryCode)?.name ?? countryCode
    }

    var monthName: String {
        ProfileV3TripCalendar.monthName(month)
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

    var countryCodes: [String] {
        var seen = Set<String>()
        return newestFirst.map(\.countryCode).filter { seen.insert($0).inserted }
    }
}

extension ProfileV3WorldPass {
    func mergingVisited(_ codes: [String]) -> ProfileV3WorldPass {
        guard !codes.isEmpty else { return self }
        var pass = self
        pass.visitedCountryCodes = codes + visitedCountryCodes
        return pass
    }
}
