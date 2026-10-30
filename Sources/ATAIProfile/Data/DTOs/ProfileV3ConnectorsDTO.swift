import Foundation

struct ProfileV3ConnectorRowDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let connected: Bool?
    let accountEmail: String?
    let imageURL: String?
    let connectLabel: String?
    let statusLabel: String?
    let syncedAt: String?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    var next: ProfileV3DirectiveDTO? { rawNext?.value }

    enum CodingKeys: String, CodingKey {
        case key
        case label
        case connected
        case accountEmail = "account_email"
        case imageURL = "image_url"
        case connectLabel = "connect_label"
        case statusLabel = "status_label"
        case syncedAt = "synced_at"
        case rawNext = "next"
    }
}

struct ProfileV3DisconnectConnectorRequest: Encodable, Equatable {
    let action = "disconnect_connector"
    let connector: String
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
