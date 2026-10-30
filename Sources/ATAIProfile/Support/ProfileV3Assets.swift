import SwiftUI

enum ProfileV3RemoteArt {
    static let base = "https://ik.imagekit.io/atlys/b2c/profile-v3"

    static func url(_ assetName: String, _ ext: String = "png") -> URL? {
        let leaf = assetName.hasPrefix("profile_v3_")
            ? String(assetName.dropFirst("profile_v3_".count))
            : assetName
        return URL(string: "\(base)/\(leaf).\(ext)")
    }
}

enum ProfileV3Vector: String {
    case bolt = "profile_v3_bolt"
    case sparkle = "profile_v3_sparkle"
    case statusComplete = "profile_v3_status_complete"
    case worldPassPlus = "profile_v3_worldpass_plus"
    case flip360 = "profile_v3_flip_360"
    case flip360Back = "profile_v3_flip_360_back"
    case whatsApp = "WhatsApp"
    case autostop = "profile_v3_autostop"
    case passport = "profile_v3_passport"
    case swipeVertical = "profile_v3_swipe_vertical"
    case mobileCheck = "profile_v3_mobile_check"
    case iosShare = "profile_v3_ios_share"

    var image: Image {
        Image(rawValue, bundle: self == .whatsApp ? .main : .module)
    }
}

enum ProfileV3CarArt {
    private static let base = "https://media.atlys.com/b2c/ai-native/cars"

    static func stage(_ id: String) -> URL? { URL(string: "\(base)/\(id).png") }
}

enum ProfileV3DestinationArt {
    private static let base = "https://media.atlys.com/f_auto,w_800/b2c/Home%20page/version-3/images/"

    static func url(for countryCode: String) -> URL? {
        URL(string: base + "\(countryCode.uppercased()).avif?tr=orig&v=1")
    }
}

enum ProfileV3PlaceholderArt: String {
    case podium = "profile_v3_podium"
    case programmeCardsEmpty = "profile_v3_programme_cards_empty"
    case passportCoverIndia = "profile_v3_passport_cover_india"
    case passportCoverGeneric = "profile_v3_passport_cover_generic"
    case agentFlight = "profile_v3_agent_flight"
    case agentStay = "profile_v3_agent_stay"
    case agentAirport = "profile_v3_agent_airport"
    case agentFood = "profile_v3_agent_food"
    case agentMedical = "profile_v3_agent_medical"
    case agentItinerary = "profile_v3_agent_itinerary"
    case agentPersonal = "profile_v3_agent_personal"
    case passportGuilloche = "profile_v3_passport_guilloche"
    case globeFlare = "profile_v3_globe_flare"

    var url: URL? { ProfileV3RemoteArt.url(rawValue) }

    static func agent(_ id: ProfileV3AgentID) -> ProfileV3PlaceholderArt {
        switch id {
        case .flight: return .agentFlight
        case .stay: return .agentStay
        case .airportLogistics: return .agentAirport
        case .food: return .agentFood
        case .medical: return .agentMedical
        case .itinerary: return .agentItinerary
        case .personal: return .agentPersonal
        }
    }

    static func agent(id: String) -> ProfileV3PlaceholderArt? {
        ProfileV3AgentID(rawValue: id).map { agent($0) }
    }
}

enum ProfileV3ProgrammeArt: String {
    case orbStar = "profile_v3_orb_star"

    var url: URL? { ProfileV3RemoteArt.url(rawValue) }
}

enum ProfileV3ConnectorArt: String {
    case gmail = "profile_v3_connector_gmail"
    case informationAccess = "profile_v3_connectors_information_access"
    case appAccess = "profile_v3_connectors_app_access"

    var url: URL? { ProfileV3RemoteArt.url(rawValue) }
}

enum ProfileV3SettingsArt: String {
    case avatarGlobe = "profile_v3_settings_avatar_globe"

    var url: URL? { ProfileV3RemoteArt.url(rawValue) }
}

enum ProfileV3ConnectorGlyph: String {
    case atlysMark = "profile_v3_atlys_mark"
    case atlysWordmark = "profile_v3_atlys_wordmark"
    case disconnectLink = "profile_v3_disconnect_link"
    case shieldCheck = "profile_v3_shield_check"
    case addCircle = "profile_v3_add_circle"
    case editStroke = "profile_v3_edit_stroke"
    case vaultLock = "profile_v3_vault_lock"
    case credentialCardArt = "profile_v3_credential_card_art"
    case reserveGlyph = "reserve_logo_clear"

    var image: Image {
        Image(rawValue, bundle: self == .reserveGlyph ? .main : .module)
    }
}

enum ProfileV3InviteArt: String {
    case codeCard = "profile_v3_invite_code_card"

    var image: Image { Image(rawValue, bundle: .module) }
}

enum ProfileV3PersonaArt: String {
    case gmail = "profile_v3_persona_gmail"
    case edited = "profile_v3_persona_edited"
    case flag = "profile_v3_persona_flag"
    case scaleMidpoint = "profile_v3_persona_scale_mid"
    case scaleKnob = "profile_v3_persona_scale_knob"

    var image: Image { Image(rawValue, bundle: .module) }
}

enum ProfileV3GloveBoxArt: String {
    case attention = "profile_v3_glovebox_attention"
    case closeSmall = "profile_v3_glovebox_close_small"
    case glow = "profile_v3_glovebox_glow"
    case aylMark = "profile_v3_glovebox_ayl"
    case cardGlobe = "profile_v3_glovebox_card_globe"
    case cardDigits = "profile_v3_glovebox_card_digits"
    case cardExpiry = "profile_v3_glovebox_card_expiry"
    case cardCVC = "profile_v3_glovebox_card_cvc"
    case noticeGlow = "profile_v3_glovebox_notice_glow"
    case addCardGlow = "profile_v3_glovebox_add_card_glow"
    case emptyCard = "profile_v3_glovebox_empty_card"
    case dialMail = "profile_v3_glovebox_dial_mail"
    case dialCall = "profile_v3_glovebox_dial_call"
    case dialCreditCard = "profile_v3_glovebox_dial_credit_card"

    var image: Image { Image(rawValue, bundle: .module) }
}

enum ProfileV3CustomRuleArt: String {
    case watermark = "profile_v3_custom_rule_watermark"

    var image: Image { Image(rawValue, bundle: .module) }
}

enum ProfileV3AgentArt: String {
    case sourceGoogle = "profile_v3_source_google"
    case sourceEmail = "profile_v3_source_email"
    case caduceus = "profile_v3_caduceus"
    case tyreTracks = "profile_v3_tyre_tracks"
    case howUsedOrb = "profile_v3_how_used_orb"

    var url: URL? { ProfileV3RemoteArt.url(rawValue) }
}
