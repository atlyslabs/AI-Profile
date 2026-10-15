import Foundation

struct ProfileV3EditField: Equatable {
    enum Input: String, Equatable {
        case countryPicker = "country_picker"
        case currencyPicker = "currency_picker"
        case contactForm = "contact_form"
        case singleSelect = "single_select"
    }

    struct Option: Identifiable, Equatable {
        let value: String
        let title: String
        var isSelected = false

        var id: String { value }
    }

    let field: String
    let title: String
    let input: Input
    var subtitle: String?
    var submitLabel: String?
    var currentCode: String?
    var currentContact: ProfileV3ContactDetails?
    var options: [Option] = []
    var submitProfileID: String?

    var currentCountry: ProfileV3Country? {
        currentCode.flatMap { ProfileV3Country(code: $0) }
    }

    var selectedValue: String? {
        options.first(where: \.isSelected)?.value ?? options.first { $0.value == currentCode }?.value
    }
}

struct ProfileV3LoyaltyEntryForm: Equatable {
    struct Field: Identifiable, Equatable {
        static let membershipNumberKey = "membership_number"
        static let pointsKey = "points"

        let key: String
        let label: String
        let isRequired: Bool

        var id: String { key }
    }

    let programID: String
    var programName: String?
    var kind: String?
    var title: String?
    var submitLabel: String?
    var fields: [Field] = []

    func field(_ key: String) -> Field? { fields.first { $0.key == key } }
}

struct ProfileV3BenefitsSheet: Equatable {
    static let empty = ProfileV3BenefitsSheet()

    var title = ""
    var subtitle = ""
    var count = 0
    var learnMoreLabel = ""
    var learnMore: ProfileV3Directive?
    var offers: [ProfileV3Benefit] = []
}

struct ProfileV3ConnectorsScreen: Equatable {
    let title: String
    let blurb: String
    let connectors: [ProfileV3Connector]
    var controlPanel: ProfileV3Directive?
}

struct ProfileV3ConnectorCard: Identifiable, Equatable {
    let key: ProfileV3ConnectorKey
    let headline: String
    let body: String
    let isConnected: Bool
    let disconnectHint: String
    let connectLabel: String?
    var accountEmail: String?
    var iconURL: URL?

    var id: String { key.rawValue }
}

struct ProfileV3ConnectorControlPanel: Equatable {
    let title: String
    let cards: [ProfileV3ConnectorCard]
}

struct ProfileV3DisconnectConfirm: Equatable {
    let connector: ProfileV3ConnectorKey
    let title: String
    let warning: String
    let losses: [String]
    let detailIntro: String
    let detailLosses: [String]
    let detailParagraphs: [String]
    let consentLabel: String
    let isConsentRequired: Bool
    let confirmTitle: String
    let cancelTitle: String
}
