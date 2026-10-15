import Foundation

public struct ProfileV3Country: Hashable, Identifiable, Sendable {
    public let code: String
    public let name: String

    public var id: String { code }

    public static let india = ProfileV3Country(code: "IN", name: "India")

    public init(code: String, name: String) {
        self.code = code
        self.name = name
    }

    public init?(code: String) {
        guard let match = ProfileV3Countries.country(code: code) else { return nil }
        self = match
    }

    public init?(name: String) {
        guard let match = ProfileV3Countries.country(name: name) else { return nil }
        self = match
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.code.caseInsensitiveCompare(rhs.code) == .orderedSame
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code.uppercased())
    }
}

enum ProfileV3Countries {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var byCode: [String: ProfileV3Country] = [:]
    nonisolated(unsafe) private static var byName: [String: ProfileV3Country] = [:]
    nonisolated(unsafe) private static var ordered: [ProfileV3Country] = []
    nonisolated(unsafe) private static var installedGeneration = 0

    static var generation: Int {
        lock.lock()
        defer { lock.unlock() }
        return installedGeneration
    }

    static func install(_ countries: [ProfileV3Country]) {
        var codes: [String: ProfileV3Country] = [:]
        var names: [String: ProfileV3Country] = [:]
        var list: [ProfileV3Country] = []
        list.reserveCapacity(countries.count)
        for country in countries {
            let code = country.code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            let name = country.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !code.isEmpty, !name.isEmpty, codes[code] == nil else { continue }
            let entry = ProfileV3Country(code: code, name: name)
            codes[code] = entry
            let folded = Self.fold(name)
            if names[folded] == nil {
                names[folded] = entry
            }
            list.append(entry)
        }
        list.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        lock.lock()
        byCode = codes
        byName = names
        ordered = list
        installedGeneration += 1
        lock.unlock()
    }

    static var all: [ProfileV3Country] {
        lock.lock()
        defer { lock.unlock() }
        return ordered
    }

    static func country(code: String) -> ProfileV3Country? {
        let key = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !key.isEmpty else { return nil }
        lock.lock()
        defer { lock.unlock() }
        return byCode[key]
    }

    static func country(name: String) -> ProfileV3Country? {
        let key = fold(name)
        guard !key.isEmpty else { return nil }
        lock.lock()
        defer { lock.unlock() }
        return byName[key]
    }

    private static func fold(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }
}
