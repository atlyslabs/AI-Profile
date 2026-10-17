import Foundation

struct ProfileV3ConnectorRowDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let connected: Bool?
    let accountEmail: String?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case key
        case label
        case connected
        case accountEmail = "account_email"
        case imageURL = "image_url"
    }
}

struct ProfileV3DisconnectConnectorRequest: Encodable, Equatable {
    let action = "disconnect_connector"
    let connector: String
}

struct ProfileV3SyncPhotoPlacesRequest: Encodable, Equatable {
    struct Country: Encodable, Equatable {
        let countryCode: String
        let photoCount: Int
        let firstSeen: Date?
        let lastSeen: Date?

        enum CodingKeys: String, CodingKey {
            case countryCode = "country_code"
            case photoCount = "photo_count"
            case firstSeen = "first_seen"
            case lastSeen = "last_seen"
        }
    }

    let action = "sync_photo_places"
    let access: String
    let scannedThrough: Date?
    let countries: [Country]

    enum CodingKeys: String, CodingKey {
        case action
        case access
        case scannedThrough = "scanned_through"
        case countries
    }

    init(_ upload: ProfileV3PhotoPlacesUpload) {
        access = upload.access == .limited ? "limited" : "full"
        scannedThrough = upload.scannedThrough
        countries = upload.countries.map {
            Country(countryCode: $0.countryCode, photoCount: $0.photoCount, firstSeen: $0.firstSeen, lastSeen: $0.lastSeen)
        }
    }

    static func body(for upload: ProfileV3PhotoPlacesUpload) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .sortedKeys
        return try encoder.encode(ProfileV3SyncPhotoPlacesRequest(upload))
    }
}

struct ProfileV3ConnectorCardDTO: Decodable, Equatable {
    let key: String?
    let headline: String?
    let body: String?
    let connected: Bool?
    let disconnectHint: String?
    let accountEmail: String?
    let imageURL: String?
    private let rawConnect: ProfileV3LossyDTO<ProfileV3NavCTADTO>?

    var connect: ProfileV3NavCTADTO? { rawConnect?.value }

    enum CodingKeys: String, CodingKey {
        case key
        case headline
        case body
        case connected
        case disconnectHint = "disconnect_hint"
        case accountEmail = "account_email"
        case imageURL = "image_url"
        case rawConnect = "connect"
    }
}

struct ProfileV3ConnectorControlPanelScreenDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    private let rawCards: [ProfileV3LossyDTO<ProfileV3ConnectorCardDTO>]?

    var cards: [ProfileV3ConnectorCardDTO] { rawCards?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case rawCards = "cards"
    }
}

struct ProfileV3DisconnectLossDTO: Decodable, Equatable {
    let key: String?
    let label: String?
}

struct ProfileV3ConsentDTO: Decodable, Equatable {
    let label: String?
    let required: Bool?
}

struct ProfileV3DisconnectActionDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let style: String?
    let action: String?
    let connector: String?
    let next: ProfileV3DirectiveDTO?
}

struct ProfileV3DisconnectConfirmScreenDTO: Decodable, Equatable {
    let type: String?
    let connector: String?
    let title: String?
    let warning: String?
    let detailIntro: String?
    private let rawLosses: [ProfileV3LossyDTO<ProfileV3DisconnectLossDTO>]?
    private let rawDetailLosses: [ProfileV3LossyDTO<String>]?
    private let rawDetailParagraphs: [ProfileV3LossyDTO<String>]?
    private let rawConsent: ProfileV3LossyDTO<ProfileV3ConsentDTO>?
    private let rawActions: [ProfileV3LossyDTO<ProfileV3DisconnectActionDTO>]?

    var losses: [ProfileV3DisconnectLossDTO] { rawLosses?.compactMap(\.value) ?? [] }
    var detailLosses: [String] { rawDetailLosses?.compactMap(\.value) ?? [] }
    var detailParagraphs: [String] { rawDetailParagraphs?.compactMap(\.value) ?? [] }
    var consent: ProfileV3ConsentDTO? { rawConsent?.value }
    var actions: [ProfileV3DisconnectActionDTO] { rawActions?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case type
        case connector
        case title
        case warning
        case detailIntro = "detail_intro"
        case rawLosses = "losses"
        case rawDetailLosses = "detail_losses"
        case rawDetailParagraphs = "detail_paragraphs"
        case rawConsent = "consent"
        case rawActions = "actions"
    }
}

struct ProfileV3ConnectorsScreenDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    let blurb: String?
    private let rawConnectors: [ProfileV3LossyDTO<ProfileV3ConnectorRowDTO>]?
    private let rawControlPanel: ProfileV3LossyDTO<ProfileV3NavCTADTO>?

    var connectors: [ProfileV3ConnectorRowDTO] { rawConnectors?.compactMap(\.value) ?? [] }
    var controlPanel: ProfileV3NavCTADTO? { rawControlPanel?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case blurb
        case rawConnectors = "connectors"
        case rawControlPanel = "control_panel"
    }
}
