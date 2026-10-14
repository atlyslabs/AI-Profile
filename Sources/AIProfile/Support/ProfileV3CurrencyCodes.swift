import Foundation

enum ProfileV3CurrencyCodes {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var cachedGeneration = -1
    nonisolated(unsafe) private static var codes: [String: String] = [:]
    nonisolated(unsafe) private static var searchTexts: [String: String] = [:]

    static func code(for country: ProfileV3Country) -> String? {
        prepare()
        lock.lock()
        defer { lock.unlock() }
        return codes[country.code.uppercased()]
    }

    static func searchText(for country: ProfileV3Country) -> String? {
        prepare()
        lock.lock()
        defer { lock.unlock() }
        return searchTexts[country.code.uppercased()]
    }

    private static func prepare() {
        let generation = ProfileV3Countries.generation
        lock.lock()
        let isCurrent = cachedGeneration == generation
        lock.unlock()
        guard !isCurrent else { return }

        var nextCodes: [String: String] = [:]
        var nextSearch: [String: String] = [:]
        for country in ProfileV3Countries.all {
            let identifier = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: country.code])
            guard let code = Locale(identifier: identifier).currency?.identifier else { continue }
            nextCodes[country.code] = code
            let names = [Locale.current, Locale(identifier: "en_US")].compactMap {
                $0.localizedString(forCurrencyCode: code)
            }
            nextSearch[country.code] = ([code] + names).joined(separator: " ")
        }

        lock.lock()
        if cachedGeneration != generation {
            codes = nextCodes
            searchTexts = nextSearch
            cachedGeneration = generation
        }
        lock.unlock()
    }
}
