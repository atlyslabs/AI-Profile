import ATUIKit
import SwiftUI

extension AnalyticsScreen {
    static let profile = AnalyticsScreen("Profile")
    static let profileBenefitList = AnalyticsScreen("ProfileBenefitList", .list)
    static let settings = AnalyticsScreen("Settings")
        .with(ProfileV3AnalyticsScreenKey.actionSource, ProfileV3Analytics.profileSource)
    static func connectors(travellerID: String?) -> AnalyticsScreen {
        AnalyticsScreen("Connectors", .component)
            .with(ProfileV3AnalyticsScreenKey.actionSource, ProfileV3Analytics.profileSource)
            .with(ProfileV3AnalyticsScreenKey.travellerId, travellerID)
    }
    static let gloveBox = AnalyticsScreen("GloveBox", .component)
    static let credentialsWebsiteList = AnalyticsScreen("CredentialsWebsiteList", .list)
    static let serviceTerms = AnalyticsScreen("ServiceTerms", .bottomSheet)
    static let userResidenceList = AnalyticsScreen("UserResidenceList", .bottomSheet)
    static let userCitizenshipList = AnalyticsScreen("UserCitizenshipList", .bottomSheet)
    static let userCurrencyList = AnalyticsScreen("UserCurrencyList", .bottomSheet)
    static let editTravellersList = AnalyticsScreen("EditTravellersList", .bottomSheet)
        .with(ProfileV3AnalyticsScreenKey.actionSource, ProfileV3Analytics.profileSource)

    private static let profileAgentBase = AnalyticsScreen("ProfileAgent", .list)
    static let travelPersonaAgent = profileAgentBase
        .with(ProfileV3AnalyticsScreenKey.agentName, "TravelPersonaAgent")
        .with(ProfileV3AnalyticsScreenKey.actionSource, ProfileV3Analytics.profileSource)
    static let cityProfileAgent = profileAgentBase.with(ProfileV3AnalyticsScreenKey.agentName, "CityProfileAgent")

    static func profileAgent(agentID: String, travellerID: String?) -> AnalyticsScreen {
        profileAgentBase
            .with(ProfileV3AnalyticsScreenKey.agentName, ProfileV3Analytics.agentScreenName(agentID))
            .with(ProfileV3AnalyticsScreenKey.actionSource, ProfileV3Analytics.profileSource)
            .with(ProfileV3AnalyticsScreenKey.agentKey, ProfileV3Analytics.agentKey(agentID))
            .with(ProfileV3AnalyticsScreenKey.travellerId, travellerID)
    }

    static func profileBenefit(benefitID: String, travellerID: String?) -> AnalyticsScreen {
        AnalyticsScreen("ProfileBenefit", .list)
            .with(ProfileV3AnalyticsScreenKey.benefitName, ProfileV3Analytics.benefitScreenName(benefitID))
            .with(ProfileV3AnalyticsScreenKey.actionSource, ProfileV3Analytics.profileSource)
            .with(ProfileV3AnalyticsScreenKey.benefitId, benefitID)
            .with(ProfileV3AnalyticsScreenKey.travellerId, travellerID)
    }

    static func connectorAgents(connector: String) -> AnalyticsScreen {
        AnalyticsScreen("ConnectorAgents", .component)
            .with(ProfileV3AnalyticsScreenKey.connectorName, ProfileV3Analytics.connectorScreenName(connector))
    }
}

enum ProfileV3AnalyticsScreenKey {
    static let agentName = "agent_name"
    static let benefitName = "benefit_name"
    static let connectorName = "connector_name"
    static let actionSource = "actionSource"
    static let agentKey = "agentKey"
    static let benefitId = "benefitId"
    static let travellerId = "travellerId"
}

extension ProfileV3Analytics {
    static func agentScreenName(_ agentID: String) -> String? {
        switch ProfileV3AgentID(apiValue: agentID) {
        case .personal: return "PersonalAgent"
        case .flight: return "FlightAgent"
        case .stay: return "StayAgent"
        case .airportLogistics: return "AirportLogisticsAgent"
        case .food: return "FoodAgent"
        case .medical: return "MedicalAgent"
        case .itinerary: return "ItineraryAgent"
        case nil: return nil
        }
    }

    static func benefitScreenName(_ benefitID: String) -> String? {
        let words = Set(benefitID.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init))
        return benefitScreens.first { screen in screen.words.contains { words.isSuperset(of: $0) } }?.name
    }

    private static let benefitScreens: [(name: String, words: [Set<String>])] = [
        ("SlotPriorityBenefit", [["slot", "priority"]]),
        ("FTIBenefit", [["fti"], ["fast", "track"], ["immigration"]]),
        ("AirportHotlineBenefit", [["hotline"]]),
        ("ForexBenefit", [["forex"]]),
        ("TransfersBenefit", [["transfer"], ["transfers"]]),
        ("EsimBenefit", [["esim"]]),
        ("ActivityBenefit", [["activity"], ["activities"]]),
        ("AylCashBenefit", [["ayl", "cash"], ["aylcash"]]),
        ("SuperCarBenefit", [["supercar"], ["super", "car"], ["super", "card"], ["car"], ["cars"]]),
        ("HotelCreditBenefit", [["hotel", "credit"], ["hotel", "credits"], ["hotels", "credit"], ["hotels", "credits"]]),
        ("HotelBenefit", [["hotel"], ["hotels"], ["stay"], ["stays"]]),
        ("InsuranceBenefit", [["insurance"], ["baggage"], ["medical"], ["delay"], ["protection"]]),
        ("FlightBenefit", [["flight"], ["flights"]])
    ]

    static func connectorScreenName(_ connector: String) -> String {
        switch connector.lowercased() {
        case "claude": return "Claude Connector"
        case "chatgpt": return "GPT Connector"
        case "gemini": return "Gemini Connector"
        case "grok": return "Grok Connector"
        case "muse": return "Muse Connector"
        case "instinct": return "Instinct Connector"
        case "itr": return "ITR Connector"
        default: return "Other Connector"
        }
    }
}

extension View {
    @ViewBuilder
    func profileV3TrackScrollDepth(_ isOn: Bool) -> some View {
        if isOn {
            trackScrollDepth()
        } else {
            self
        }
    }
}
