import Foundation

enum ProfileV3ProgrammeCatalogue {
    #if DEBUG
    static let mockFoundCount = 6

    static func mockMarket(selected: String?) -> ProfileV3ProgrammeMarket {
        let options = [
            ProfileV3ProgrammeMarket.Option(value: "in", label: "India", shortLabel: "IND"),
            ProfileV3ProgrammeMarket.Option(value: "hk", label: "Hong Kong", shortLabel: "HKG"),
            ProfileV3ProgrammeMarket.Option(value: "sg", label: "Singapore", shortLabel: "SGP"),
            ProfileV3ProgrammeMarket.Option(value: "us", label: "United States", shortLabel: "USA")
        ]
        let chosen = options.first { $0.value == selected } ?? options[0]
        return ProfileV3ProgrammeMarket(
            options: [chosen] + options.filter { $0 != chosen },
            selected: chosen.value,
            chips: ["All", "Credit cards"],
            title: "Select country",
            searchPlaceholder: "Search"
        )
    }
    #endif

    static let all: [ProfileV3ProgrammeCatalogueItem] = [
        ProfileV3ProgrammeCatalogueItem(
            id: "maharaja-club",
            name: "Maharaja Club",
            category: .flights
        ),
        ProfileV3ProgrammeCatalogueItem(
            id: "krisflyer",
            name: "KrisFlyer",
            category: .flights
        ),
        ProfileV3ProgrammeCatalogueItem(
            id: "itc-green-club",
            name: "ITC Green Club",
            category: .hotels
        ),
        ProfileV3ProgrammeCatalogueItem(
            id: "marriott-bonvoy",
            name: "Marriott Bonvoy",
            category: .hotels
        ),
        ProfileV3ProgrammeCatalogueItem(
            id: "taj-innercircle",
            name: "Taj InnerCircle",
            category: .hotels
        ),
        ProfileV3ProgrammeCatalogueItem(
            id: "accor-all",
            name: "Accor Live Limitless",
            category: .hotels
        ),
        ProfileV3ProgrammeCatalogueItem(
            id: "emirates-skywards",
            name: "Emirates Skywards",
            category: .flights
        ),
        ProfileV3ProgrammeCatalogueItem(
            id: "hdfc-infinia",
            name: "HDFC Infinia",
            category: .creditCards
        ),
        ProfileV3ProgrammeCatalogueItem(
            id: "amex-platinum",
            name: "Amex Platinum",
            category: .creditCards
        ),
        ProfileV3ProgrammeCatalogueItem(
            id: "axis-magnus",
            name: "Axis Magnus",
            category: .creditCards
        ),
        ProfileV3ProgrammeCatalogueItem(
            id: "eurail-pass",
            name: "Eurail Global Pass",
            category: .travelPasses
        ),
        ProfileV3ProgrammeCatalogueItem(
            id: "jr-pass",
            name: "Japan Rail Pass",
            category: .travelPasses
        )
    ]

    static func masked(_ membershipNumber: String) -> String {
        let trimmed = membershipNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        return ProfileV3Strings.maskedNumber(String(trimmed.suffix(4)))
    }
}
