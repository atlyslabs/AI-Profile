import Foundation

enum ProfileV3AgentDateCodec {
    enum Format: String, CaseIterable {
        case iso = "yyyy-MM-dd"
        case dayFirst = "dd/MM/yyyy"
        case dotted = "dd.MM.yyyy"

        fileprivate var pattern: String {
            switch self {
            case .iso: return #"^\d{4}-\d{1,2}-\d{1,2}"#
            case .dayFirst: return #"^\d{1,2}/\d{1,2}/\d{4}"#
            case .dotted: return #"^\d{1,2}\.\d{1,2}\.\d{4}"#
            }
        }

        fileprivate func fields(of parts: DateComponents) -> [Int?] {
            switch self {
            case .iso: return [parts.year, parts.month, parts.day]
            case .dayFirst, .dotted: return [parts.day, parts.month, parts.year]
            }
        }
    }

    static func parse(_ raw: String) -> (date: Date, format: Format)? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        for format in Format.allCases {
            guard let match = trimmed.range(of: format.pattern, options: .regularExpression),
                  let utc = formatters[format]?.date(from: String(trimmed[match])) else { continue }
            var parts = gmtCalendar.dateComponents([.year, .month, .day], from: utc)
            let written = trimmed[match].split { !$0.isNumber }.map { Int($0) }
            guard written == format.fields(of: parts) else { continue }
            parts.hour = 12
            guard let date = localCalendar.date(from: parts) else { continue }
            return (date, format)
        }
        return nil
    }

    static func string(from date: Date, format: Format) -> String {
        var parts = localCalendar.dateComponents([.year, .month, .day], from: date)
        parts.hour = 12
        guard let utc = gmtCalendar.date(from: parts) else { return "" }
        return formatters[format]?.string(from: utc) ?? ""
    }

    private static let gmtCalendar = calendar(.gmt)
    private static let localCalendar = calendar(.autoupdatingCurrent)
    private static let formatters = Dictionary(uniqueKeysWithValues: Format.allCases.map { ($0, formatter($0)) })

    private static func calendar(_ timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    private static func formatter(_ format: Format) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar(.gmt)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .gmt
        formatter.dateFormat = format.rawValue
        return formatter
    }
}
