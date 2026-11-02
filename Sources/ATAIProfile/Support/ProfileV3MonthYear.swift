import Foundation

enum ProfileV3MonthYear {
    static func formatted(_ raw: String) -> String {
        let digits = String(raw.filter(\.isNumber).prefix(4))
        guard digits.count > 2 else { return digits }
        return "\(digits.prefix(2))/\(digits.dropFirst(2))"
    }

    static func isComplete(_ text: String) -> Bool {
        text.filter(\.isNumber).count == 4
    }

    static func isCurrentOrLater(_ text: String, now: Date = Date()) -> Bool {
        let digits = text.filter(\.isNumber)
        guard digits.count == 4, let month = Int(digits.prefix(2)), let year = Int(digits.suffix(2)),
              (1...12).contains(month) else { return false }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        let today = calendar.dateComponents([.year, .month], from: now)
        guard let currentYear = today.year, let currentMonth = today.month else { return false }
        return (2000 + year, month) >= (currentYear, currentMonth)
    }
}
