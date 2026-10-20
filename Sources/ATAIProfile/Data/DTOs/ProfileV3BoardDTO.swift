import Foundation

struct ProfileV3LossyDTO<Value: Decodable & Equatable>: Decodable, Equatable {
    let value: Value?

    init(from decoder: Decoder) throws {
        value = try? Value(from: decoder)
    }
}

struct ProfileV3BoardDTO: Decodable, Equatable {
    private let rawHeader: ProfileV3LossyDTO<ProfileV3BoardHeaderDTO>?
    private let rawProfiles: [ProfileV3LossyDTO<ProfileV3ProfileBoardDTO>]?

    var header: ProfileV3BoardHeaderDTO? { rawHeader?.value }
    var profiles: [ProfileV3ProfileBoardDTO] { rawProfiles?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case rawHeader = "header"
        case rawProfiles = "profiles"
    }
}

struct ProfileV3BoardHeaderDTO: Decodable, Equatable {
    let settings: ProfileV3BoardSettingsDTO?
    private let rawTravellerSwitcher: [ProfileV3LossyDTO<ProfileV3TravellerSwitchDTO>]?

    var travellerSwitcher: [ProfileV3TravellerSwitchDTO] { rawTravellerSwitcher?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case settings
        case rawTravellerSwitcher = "traveller_switcher"
    }
}

struct ProfileV3BoardSettingsDTO: Decodable, Equatable {
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    var next: ProfileV3DirectiveDTO? { rawNext?.value }

    enum CodingKeys: String, CodingKey {
        case rawNext = "next"
    }
}

struct ProfileV3TravellerSwitchDTO: Decodable, Equatable {
    let profileID: String
    let name: String?
    let isMain: Bool?

    enum CodingKeys: String, CodingKey {
        case profileID = "profile_id"
        case name
        case isMain = "is_main"
    }
}

struct ProfileV3ProfileBoardDTO: Decodable, Equatable {
    let profileID: String
    let isMain: Bool?
    let name: String?
    private let rawWorldpassCard: ProfileV3LossyDTO<ProfileV3WorldPassCardDTO>?
    private let rawLoyaltyCard: ProfileV3LossyDTO<ProfileV3LoyaltyCardDTO>?
    private let rawSections: [ProfileV3LossyDTO<ProfileV3BoardSectionDTO>]?
    private let rawProfileKYC: ProfileV3LossyDTO<ProfileV3ProfileKYCDTO>?

    var worldpassCard: ProfileV3WorldPassCardDTO? { rawWorldpassCard?.value }
    var loyaltyCard: ProfileV3LoyaltyCardDTO? { rawLoyaltyCard?.value }
    var sections: [ProfileV3BoardSectionDTO] { rawSections?.compactMap(\.value) ?? [] }
    var profileKYC: ProfileV3ProfileKYCDTO? { rawProfileKYC?.value }

    enum CodingKeys: String, CodingKey {
        case profileID = "profile_id"
        case isMain = "is_main"
        case name
        case rawWorldpassCard = "worldpass_card"
        case rawLoyaltyCard = "loyalty_card"
        case rawSections = "sections"
        case rawProfileKYC = "profile_kyc"
    }
}

struct ProfileV3ProfileKYCDTO: Decodable, Equatable {
    let isMain: Bool?
    let anyMainExists: Bool?
    let required: [String]?
    let missing: [String]?
    let complete: Bool?

    enum CodingKeys: String, CodingKey {
        case isMain = "is_main"
        case anyMainExists = "any_main_exists"
        case required
        case missing
        case complete
    }
}

struct ProfileV3WorldPassCardDTO: Decodable, Equatable {
    let glow: String?
    private let rawPassNumber: ProfileV3LossyDTO<ProfileV3ScalarDTO>?
    private let rawKYCComplete: ProfileV3LossyDTO<Bool>?
    private let rawKYCState: ProfileV3LossyDTO<ProfileV3KYCStateDTO>?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?
    private let rawStats: [ProfileV3LossyDTO<ProfileV3GlobeStatDTO>]?
    private let rawGlobe: ProfileV3LossyDTO<ProfileV3GlobeDTO>?
    private let rawWorldpassLabel: ProfileV3LossyDTO<String>?

    var passNumber: String? { rawPassNumber?.value?.stringValue }
    var worldpassLabel: String? { rawWorldpassLabel?.value }
    var next: ProfileV3DirectiveDTO? { rawNext?.value }
    var globe: ProfileV3GlobeDTO? { rawGlobe?.value }
    var kycComplete: Bool? { rawKYCComplete?.value }
    var kycState: ProfileV3KYCStateDTO? { rawKYCState?.value }

    var stats: [ProfileV3GlobeStatDTO] {
        let nested = globe?.stats ?? []
        return nested.isEmpty ? (rawStats?.compactMap(\.value) ?? []) : nested
    }

    var countryCodes: [String] { globe?.countryCodes ?? [] }

    enum CodingKeys: String, CodingKey {
        case glow
        case rawPassNumber = "pass_number"
        case rawKYCComplete = "kyc_complete"
        case rawKYCState = "kyc_state"
        case rawNext = "next"
        case rawStats = "stats"
        case rawGlobe = "globe"
        case rawWorldpassLabel = "worldpass_label"
    }
}

struct ProfileV3KYCStateDTO: Decodable, Equatable {
    let state: String?
    let statusLabel: String?
    let subline: String?

    enum CodingKeys: String, CodingKey {
        case state
        case statusLabel = "status_label"
        case status
        case subline
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        state = container.lenientString(forKey: .state)
        statusLabel = container.lenientString(forKey: .statusLabel) ?? container.lenientString(forKey: .status)
        subline = container.lenientString(forKey: .subline)
    }
}

enum ProfileV3BoardSectionDTO: Decodable, Equatable {
    case kycBanner(ProfileV3KYCBannerDTO)
    case benefits(ProfileV3BenefitsSectionDTO)
    case coupons(ProfileV3CouponsSectionDTO)
    case agentGrid(ProfileV3AgentGridDTO)
    case unsupported(String)

    var asKYCBanner: ProfileV3KYCBannerDTO? {
        if case .kycBanner(let banner) = self { return banner }
        return nil
    }

    var asBenefits: ProfileV3BenefitsSectionDTO? {
        if case .benefits(let section) = self { return section }
        return nil
    }

    var asCoupons: ProfileV3CouponsSectionDTO? {
        if case .coupons(let section) = self { return section }
        return nil
    }

    var asAgentGrid: ProfileV3AgentGridDTO? {
        if case .agentGrid(let grid) = self { return grid }
        return nil
    }

    enum CodingKeys: String, CodingKey {
        case kind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = (try? container.decodeIfPresent(String.self, forKey: .kind)) ?? nil
        switch kind {
        case "kyc_banner":
            self = (try? ProfileV3KYCBannerDTO(from: decoder)).map(Self.kycBanner) ?? .unsupported("kyc_banner")
        case "benefits":
            self = (try? ProfileV3BenefitsSectionDTO(from: decoder)).map(Self.benefits) ?? .unsupported("benefits")
        case "coupons":
            self = (try? ProfileV3CouponsSectionDTO(from: decoder)).map(Self.coupons) ?? .unsupported("coupons")
        case "agent_grid":
            self = (try? ProfileV3AgentGridDTO(from: decoder)).map(Self.agentGrid) ?? .unsupported("agent_grid")
        default:
            self = .unsupported(kind ?? "")
        }
    }
}

struct ProfileV3KYCBannerDTO: Decodable, Equatable {
    let status: String?
    let statusLabel: String?
    let title: String?
    let expiryLabel: String?
    let progress: ProfileV3KYCProgressDTO?
    private let rawCTA: ProfileV3LossyDTO<ProfileV3NavCTADTO>?

    var cta: ProfileV3NavCTADTO? { rawCTA?.value }
    var isReconnect: Bool { status == "reconnect" }

    enum CodingKeys: String, CodingKey {
        case status
        case statusLabel = "status_label"
        case title
        case expiryLabel = "expiry_label"
        case progress
        case rawCTA = "cta"
    }
}

struct ProfileV3KYCProgressDTO: Decodable, Equatable {
    let done: ProfileV3ScalarDTO?
    let total: ProfileV3ScalarDTO?
}

struct ProfileV3BenefitsSectionDTO: Decodable, Equatable {
    private let rawFeatured: ProfileV3LossyDTO<ProfileV3OfferCardDTO>?
    private let rawViewAll: ProfileV3LossyDTO<ProfileV3NavCTADTO>?

    var featured: ProfileV3OfferCardDTO? { rawFeatured?.value }
    var viewAll: ProfileV3NavCTADTO? { rawViewAll?.value }

    enum CodingKeys: String, CodingKey {
        case rawFeatured = "featured"
        case rawViewAll = "view_all"
    }
}

struct ProfileV3AgentGridDTO: Decodable, Equatable {
    let heading: String?
    let headingEmphasis: String?
    let updatedAt: String?
    private let rawTiles: [ProfileV3LossyDTO<ProfileV3AgentTileDTO>]?

    var tiles: [ProfileV3AgentTileDTO] { rawTiles?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case heading
        case headingEmphasis = "heading_emphasis"
        case updatedAt = "updated_at"
        case rawTiles = "tiles"
    }
}

struct ProfileV3AgentTileDTO: Decodable, Equatable {
    let agentType: String?
    let name: String?
    let title: String?
    let icon: String?
    let blurb: String?
    let updatedLabel: String?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?
    private let rawActivate: ProfileV3LossyDTO<ProfileV3NavCTADTO>?

    var next: ProfileV3DirectiveDTO? { rawNext?.value }
    var activate: ProfileV3NavCTADTO? { rawActivate?.value }

    enum CodingKeys: String, CodingKey {
        case agentType = "agent_type"
        case name
        case title
        case icon
        case blurb
        case updatedLabel = "updated_label"
        case rawNext = "next"
        case rawActivate = "activate"
    }
}

struct ProfileV3LoyaltyCardDTO: Decodable, Equatable {
    let kind: String?
    let title: String?
    let count: ProfileV3ScalarDTO?
    let updatedLabel: String?
    private let rawPrograms: [ProfileV3LossyDTO<ProfileV3ProgrammeRowDTO>]?
    private let rawAdd: ProfileV3LossyDTO<ProfileV3NavCTADTO>?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    var programs: [ProfileV3ProgrammeRowDTO] { rawPrograms?.compactMap(\.value) ?? [] }
    var add: ProfileV3NavCTADTO? { rawAdd?.value }
    var next: ProfileV3DirectiveDTO? { rawNext?.value }

    enum CodingKeys: String, CodingKey {
        case kind
        case title
        case count
        case updatedLabel = "updated_label"
        case rawPrograms = "programs"
        case rawAdd = "add"
        case rawNext = "next"
    }
}
