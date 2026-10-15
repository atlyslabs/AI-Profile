import ATAIProfile

enum VDCProfileV3Countries {
    static var catalogue: [ProfileV3Country] {
        Country.allCountries.map { ProfileV3Country(code: $0.countryCode, name: $0.rawValue) }
    }
}
