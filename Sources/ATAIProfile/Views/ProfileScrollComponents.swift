import ATUIKit
import SwiftUI

extension ScrollComponent {
    static let profileHub = ScrollComponent(.profile, "hub")

    // Sections of the hub. Rails carry their order on the page: world-pass carousel (1), gift
    // cards (2), coupons (3). Benefit cards and agent tiles carry the backend id and their place
    // in the stack or grid.
    static let worldPassCarousel = ScrollComponent(.profile, "world_pass_carousel", axis: .horizontal)
    static let giftCardsRail = ScrollComponent(.profile, "gift_cards", axis: .horizontal)
    static let couponsRail = ScrollComponent(.profile, "coupons", axis: .horizontal)
    static let benefitCard = ScrollComponent(.profile, "benefit_card")
    static let agentTile = ScrollComponent(.profile, "agent_tile")

    // Full screens over the hub
    static let couponsList = ScrollComponent(.profile, "coupons_list", depth: .items)
    static let benefitsList = ScrollComponent(.profile, "benefits_list", depth: .items)
    static let couponDetail = ScrollComponent(.profile, "coupon_detail")
    static let benefitDetail = ScrollComponent(.profile, "benefit_detail")
    static let pastTripsList = ScrollComponent(.profile, "past_trips_list", depth: .items)

    // Agents
    static let agentForm = ScrollComponent(.profile, "agent_form")
    static let customRulesRail = ScrollComponent(.profile, "custom_rules", axis: .horizontal)
    static let sectionSources = ScrollComponent(.profile, "section_sources")
    static let rideRegions = ScrollComponent(.profile, "ride_regions")
    static let previousPassportsList = ScrollComponent(.profile, "previous_passports_list", depth: .items)
    static let passportReason = ScrollComponent(.profile, "passport_reason")
    static let passportHowUsed = ScrollComponent(.profile, "passport_how_used")
    static let airportPickup = ScrollComponent(.profile, "airport_pickup")
    static let householdApply = ScrollComponent(.profile, "household_apply")
    static let travelPersona = ScrollComponent(.profile, "travel_persona")
    static let personaTrait = ScrollComponent(.profile, "persona_trait")

    // Loyalty programmes
    static let programmes = ScrollComponent(.profile, "programmes")
    static let featuredProgrammesRail = ScrollComponent(.profile, "featured_programmes", axis: .horizontal)
    static let programmeInsight = ScrollComponent(.profile, "programme_insight")
    static let programmeSources = ScrollComponent(.profile, "programme_sources")
    static let addProgramme = ScrollComponent(.profile, "add_programme")
    static let programmeCardCarousel = ScrollComponent(.profile, "programme_cards", axis: .horizontal)

    // Settings
    static let settingsMenu = ScrollComponent(.settings, "menu")
    static let informationAccess = ScrollComponent(.settings, "information_access")
    static let appAccess = ScrollComponent(.settings, "app_access")
    static let autoConnectedAppsRail = ScrollComponent(.settings, "auto_connected_apps", axis: .horizontal)
    static let connectorDeck = ScrollComponent(.settings, "connector_deck", axis: .horizontal)
    static let appCredentials = ScrollComponent(.settings, "app_credentials")
    static let credentialStore = ScrollComponent(.settings, "credential_store")
    static let disconnectEmail = ScrollComponent(.settings, "disconnect_email")
    static let permissions = ScrollComponent(.settings, "permissions")
    static let terms = ScrollComponent(.settings, "terms")
    static let travellersList = ScrollComponent(.settings, "travellers_list", depth: .items)
    static let contactInfo = ScrollComponent(.settings, "contact_info")
    static let editTraveller = ScrollComponent(.settings, "edit_traveller")
    static let addTraveller = ScrollComponent(.settings, "add_traveller")
    static let deleteReason = ScrollComponent(.settings, "delete_reason")
    static let gloveBoxIntro = ScrollComponent(.settings, "glove_box_intro")
    static let gloveBoxHome = ScrollComponent(.settings, "glove_box_home")
}

extension View {
    /// For a shared scroll view that only some screens track: nil leaves it untracked.
    @ViewBuilder
    func trackScroll(ifNamed component: ScrollComponent?, at position: Int? = nil, id itemId: String? = nil) -> some View {
        if let component {
            trackScroll(component, at: position, id: itemId)
        } else {
            self
        }
    }
}
