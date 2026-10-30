import Foundation

enum ProfileV3ConnectorKey: String, Equatable {
    case gmail
    case itr

    var canDisconnect: Bool {
        switch self {
        case .gmail: return true
        case .itr: return ProfileV3FeatureFlags.isITRDisconnectEnabled
        }
    }
}

struct ProfileV3Directive: Equatable {
    let go: String
    var profileID: String?
    var agentType: String?
    var benefitID: String?
    var connector: String?
    var programID: String?
    var programName: String?
    var kind: String?
    var field: String?
    var fieldKey: String?
    var reason: String?
    var steps: [String] = []
    var trait: String?
    var page: Int?
    var prompt: String?
}

enum ProfileV3Route: Equatable {
    case settings
    case editField(String)
    case connectors
    case connectorControlPanel
    case disconnectConfirm(ProfileV3ConnectorKey)
    case agent(ProfileV3AgentID, profileID: String?)
    case globeStats(profileID: String)
    case loyaltyAdd
    case loyaltyEnterDetails(programID: String, programName: String?, kind: String?)
    case programsPage(profileID: String?)
    case programInsight(programID: String, profileID: String?)
    case loyaltySources(programID: String, profileID: String?)
    case benefitsSheet
    case benefitDetail(benefitID: String)
    case back
    case kycGate(reason: String?)
    case kycCapture(steps: [String])
    case coTravellerCapture(profileID: String, steps: [String])
    case coupons
    case inviteCode
    case termsOfService
    case permissions
    case editTraveler
    case addTraveller
    case deleteTravellerConfirm(profileID: String)
    case worldPassAbout
    case logout
    case deleteAccount
    case deleteAccountConfirm
    case passportUpdate(profileID: String?)
    case passportReason
    case passportHowUsed
    case passportPrevious(profileID: String?)
    case ridePicker(agentType: String, profileID: String?)
    case rideRegions
    case travelPersona(profileID: String?)
    case personaTrait(trait: String, profileID: String?, page: Int)
    case pastTrips(profileID: String?)
    case addTrip(profileID: String?)
    case aiChat(prompt: String)
    case aiConnector(String)
    case aiConnectorConnect(String)
    case unsupported(String)
}

extension ProfileV3Directive {
    func route(fallbackProfileID: String? = nil) -> ProfileV3Route {
        let profile = profileID ?? fallbackProfileID
        switch go {
        case "settings":
            return .settings
        case "ai_chat":
            guard let prompt = prompt?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty else {
                return .unsupported(go)
            }
            return .aiChat(prompt: prompt)
        case "edit_field":
            return field.map(ProfileV3Route.editField) ?? .unsupported(go)
        case "connectors":
            return .connectors
        case "ai_connector":
            return aiConnectorKey.map(ProfileV3Route.aiConnector) ?? .unsupported(go)
        case "ai_connector_connect":
            return aiConnectorKey.map(ProfileV3Route.aiConnectorConnect) ?? .unsupported(go)
        case "connector_control_panel":
            return .connectorControlPanel
        case "disconnect_confirm":
            return connectorKey.map(ProfileV3Route.disconnectConfirm) ?? .unsupported(go)
        case "agent":
            guard let agent = agentType.flatMap(ProfileV3AgentID.init(apiValue:)) else { return .unsupported(go) }
            return .agent(agent, profileID: profile)
        case "globe_stats":
            return profile.map { ProfileV3Route.globeStats(profileID: $0) } ?? .unsupported(go)
        case "loyalty_add":
            return .loyaltyAdd
        case "loyalty_enter_details":
            guard let programID else { return .unsupported(go) }
            return .loyaltyEnterDetails(programID: programID, programName: programName, kind: kind)
        case "programs_page":
            return .programsPage(profileID: profile)
        case "program_insight":
            guard let programID else { return .unsupported(go) }
            return .programInsight(programID: programID, profileID: profile)
        case "loyalty_sources":
            guard let programID else { return .unsupported(go) }
            return .loyaltySources(programID: programID, profileID: profile)
        case "benefits_sheet":
            return .benefitsSheet
        case "benefit_detail":
            return benefitID.map { ProfileV3Route.benefitDetail(benefitID: $0) } ?? .unsupported(go)
        case "back":
            return .back
        case "kyc", "kyc_gate":
            return .kycGate(reason: reason)
        case "kyc_capture":
            return .kycCapture(steps: steps)
        case "co_traveler_capture":
            return profile.map { ProfileV3Route.coTravellerCapture(profileID: $0, steps: steps) } ?? .unsupported(go)
        case "connect_connector":
            return .kycGate(reason: reason)
        case "coupons":
            return .coupons
        case "invite_friends", "invite_code":
            return .inviteCode
        case "terms":
            return .termsOfService
        case ProfileV3PermissionDefaults.rowKey:
            return .permissions
        case "edit_traveler":
            return .editTraveler
        case "add_traveller", "add_traveler":
            return .addTraveller
        case "delete_traveller_confirm", "delete_traveler_confirm":
            return profileID.map { ProfileV3Route.deleteTravellerConfirm(profileID: $0) } ?? .unsupported(go)
        case "worldpass_about":
            return .worldPassAbout
        case "logout", "logout_confirm":
            return .logout
        case "delete_account":
            return .deleteAccount
        case "delete_confirm":
            return .deleteAccountConfirm
        case ProfileV3PassportRoute.update:
            return .passportUpdate(profileID: profileID)
        case ProfileV3PassportRoute.reason:
            return .passportReason
        case ProfileV3PassportRoute.howUsed:
            return .passportHowUsed
        case ProfileV3PassportRoute.previous:
            return .passportPrevious(profileID: profileID)
        case "ride_picker":
            return agentType.map { ProfileV3Route.ridePicker(agentType: $0, profileID: profile) } ?? .unsupported(go)
        case "ride_regions":
            return .rideRegions
        case "travel_persona":
            return .travelPersona(profileID: profile)
        case "persona_trait":
            return trait.map { .personaTrait(trait: $0, profileID: profile, page: max(page ?? 1, 1)) } ?? .unsupported(go)
        case "past_trips":
            return .pastTrips(profileID: profile)
        case "add_trip":
            return .addTrip(profileID: profile)
        default:
            return .unsupported(go)
        }
    }

    private var connectorKey: ProfileV3ConnectorKey? {
        connector.flatMap(ProfileV3ConnectorKey.init(rawValue:))
    }

    private var aiConnectorKey: String? {
        connector?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().nonEmpty
    }
}

extension ProfileV3AgentID {
    init?(apiValue: String) {
        self.init(rawValue: apiValue.replacingOccurrences(of: "_", with: "-"))
    }

    var apiValue: String { rawValue.replacingOccurrences(of: "-", with: "_") }
}
