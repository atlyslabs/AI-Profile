import SwiftUI

public enum ProfileV3EntrySource: String, Sendable {
    case chat
    case accountSettings = "account_settings"
    case deepLink = "deep_link"
}

enum ProfileV3Analytics {

    enum Screen: String {
        case hub = "aiProfile"
        case settings = "aiSettings"
        case agentPickup = "aiProfileAgentPickup"
        case programmes = "aiProfileProgrammes"
        case addProgramme = "aiProfileAddProgramme"
        case benefit = "aiProfileBenefit"
        case coupons = "aiProfileCoupons"
        case connectors = "aiProfileConnectors"
        case travellers = "aiProfileTravellers"
        case permissions = "aiProfilePermissions"
        case programmeSources = "aiProfileProgrammeSources"
        case pastTrips = "aiProfilePastTrips"
    }

    typealias EntrySource = ProfileV3EntrySource

    enum PassDirection: String {
        case next
        case previous
    }

    enum PassFace: String {
        case profile
        case benefits
    }

    enum ConnectSource: String {
        case card
        case connectMore = "connect_more"
    }

    enum BenefitOrigin: String {
        case stack
        case giftCard
        case featured
        case list
    }

    enum CouponOrigin: String {
        case rail
        case list
    }

    enum CTAOrigin: String {
        case settings
        case agentCard = "agent_card"
        case programmes
        case addProgramme = "add_programme"
        case knowMore = "know_more"
        case programmeInsight = "programme_insight"
        case passport
    }

    enum ProfileField: String {
        case residence
        case citizenship
        case currency
    }

    enum SettingsConnector: String {
        case information
        case app
    }

    enum GloveBoxItem: String {
        case mail
        case phone
        case card
    }

    private enum EventName {
        static let screenView = "screen_view"
        static let kycNudgeShown = "profile_kyc_nudge_shown"
        static let worldPassTapped = "profile_worldpass_tapped"
        static let cardConnectClicked = "profile_card_connect_clicked"
        static let passSwitched = "profile_pass_switched"
        static let agentClicked = "profile_agent_clicked"
        static let viewBenefitsClicked = "profile_view_benefits_clicked"
        static let benefitsScreenViewed = "profile_benefits_screen_viewed"
        static let benefitClicked = "profile_benefits_clicked"
        static let benefitRedeemed = "profile_benefit_redeemed"
        static let benefitRedeemFailed = "profile_benefit_redeem_failed"
        static let couponClicked = "profile_coupon_clicked"
        static let programCardScrolled = "profile_connector_program_card_scrolled"
        static let cardTypeSelected = "profile_connector_card_type_selected"
        static let loyaltyCardClicked = "profile_loyalty_card_clicked"
        static let cardDetailScreenViewed = "profile_connector_card_detail_screen_viewed"
        static let cardDetailsEntered = "profile_connector_card_details_entered"
        static let addedCardClicked = "profile_connector_added_card_clicked"
        static let viewInsightClicked = "profile_connector_card_view_insight_clicked"
        static let insightViewed = "profile_connector_card_insight_viewed"
        static let cardNumberCopied = "profile_connector_card_number_copied"
        static let cardEditClicked = "profile_connector_card_edit_clicked"
        static let cardRemoveClicked = "profile_connector_card_remove_clicked"
        static let accountCenterTapped = "settings_account_center_tapped"
        static let residenceClicked = "settings_residence_clicked"
        static let residenceUpdated = "settings_residence_updated"
        static let citizenshipClicked = "settings_citizenship_clicked"
        static let citizenshipUpdated = "settings_citizenship_updated"
        static let currencyClicked = "settings_currency_clicked"
        static let currencyUpdated = "settings_currency_updated"
        static let contactInfoClicked = "settings_contact_info_clicked"
        static let contactInfoUpdated = "settings_contact_info_updated"
        static let settingsConnectorClicked = "settings_connector_clicked"
        static let settingsBackClicked = "settings_back_clicked"
        static let permissionClicked = "settings_permission_clicked"
        static let permissionChanged = "settings_permission_changed"
        static let permissionClosed = "settings_permission_closed"
        static let couponsClicked = "settings_coupons_clicked"
        static let termsClicked = "settings_terms_clicked"
        static let logoutClicked = "settings_logout_clicked"
        static let loggedOut = "settings_logged_out"
        static let passVaultClicked = "pass_vault_clicked"
        static let passVaultAddCredentialsClicked = "pass_vault_add_credentials_clicked"
        static let passVaultWebsiteSelected = "pass_vault_website_selected"
        static let passVaultCredentialsAdded = "pass_vault_credentials_added"
        static let passVaultWebsiteClicked = "pass_vault_website_clicked"
        static let gloveBoxOpened = "glove_box_opened"
        static let gloveBoxItemClicked = "glove_box_item_clicked"
        static let fieldSaveFailed = "profile_field_save_failed"
        static let contactSaveFailed = "profile_contact_save_failed"
        static let gmailActivateClicked = "gmail_connector_activate_clicked"
        static let gmailConnectSuccess = "gmail_connector_connect_success"
        static let gmailConnectFailure = "gmail_connector_connect_failure"
        static let gmailLaterClicked = "gmail_connector_later_clicked"
        static let connectorDisconnectClicked = "profile_connector_disconnect_clicked"
        static let connectorDisconnected = "profile_connector_disconnected"
        static let connectorDisconnectFailed = "profile_connector_disconnect_failed"
        static let travellerClicked = "settings_traveller_clicked"
        static let travellerSaved = "settings_traveller_saved"
        static let travellerSaveFailed = "settings_traveller_save_failed"
        static let travellerAdded = "settings_traveller_added"
        static let travellerAddFailed = "settings_traveller_add_failed"
        static let travellerRemoved = "settings_traveller_removed"
        static let travellerRemoveFailed = "settings_traveller_remove_failed"
        static let accountDeletionReasonSubmitted = "account_deletion_reason_submitted"
        static let agentPreferenceChanged = "profile_agent_preference_changed"
        static let previousPassportsOpened = "profile_previous_passports_opened"
        static let passportScanned = "profile_passport_scanned"
        static let agentFormSaved = "profile_agent_form_saved"
        static let agentFormSaveFailed = "profile_agent_form_save_failed"
        static let carSelected = "profile_car_selected"
        static let programmeInsightOpened = "profile_programme_insight_opened"
        static let programmeRemoved = "profile_programme_removed"
        static let programmeRemoveFailed = "profile_programme_remove_failed"
        static let programmeScanStarted = "profile_programme_scan_started"
        static let programmeScanFinished = "profile_programme_scan_finished"
        static let programmeAddFailed = "profile_programme_add_failed"
        static let completeKYCClicked = "complete_kyc_clicked"
        static let kycScreenSeen = "kyc_screen_seen"
        static let kycGmailDecision = "kyc_decision_on_gmail_connector"
        static let kycOnboardingCompleted = "kyc_onboarding_completed"
        static let ctaClicked = "profile_cta_clicked"
        static let deepLinkOpened = "profile_deep_link_opened"
    }

    private enum ParamKey {
        static let screenName = "screenName"
        static let actionSource = "actionSource"
        static let entrySource = "entrySource"
        static let agentKey = "agentKey"
        static let agentId = "agentId"
        static let agentIndex = "agentIndex"
        static let agentName = "agentName"
        static let benefitId = "benefitId"
        static let benefitTitle = "benefitTitle"
        static let benefitList = "benefitList"
        static let couponId = "couponId"
        static let programmeId = "programmeId"
        static let passId = "passId"
        static let travellerId = "travellerId"
        static let travellerName = "travellerName"
        static let tapOn = "tapOn"
        static let cardName = "cardName"
        static let cardsName = "cardsName"
        static let connectorType = "connectorType"
        static let slideDepthPercentage = "slideDepthPercentage"
        static let loyaltyDetails = "loyaltyDetails"
        static let insightShown = "insightShown"
        static let kycStatus = "kycStatus"
        static let kycDone = "kycDone"
        static let kycTotal = "kycTotal"
        static let direction = "direction"
        static let actionType = "actionType"
        static let isActive = "isActive"
        static let foundCount = "foundCount"
        static let requiresKYC = "requiresKYC"
        static let status = "status"
        static let origin = "origin"
        static let routedToGate = "routedToGate"
        static let errorKind = "errorKind"
        static let fieldKey = "fieldKey"
        static let newResidence = "newResidence"
        static let oldResidence = "oldResidence"
        static let newCitizenship = "newCitizenship"
        static let oldCitizenship = "oldCitizenship"
        static let newCurrency = "newCurrency"
        static let oldCurrency = "oldCurrency"
        static let newContactInfo = "newContactInfo"
        static let oldContactInfo = "oldContactInfo"
        static let newPermission = "newPermission"
        static let oldPermission = "oldPermission"
        static let source = "source"
        static let changedFields = "changedFields"
        static let connectorName = "connectorName"
        static let passportChanged = "passportChanged"
        static let oldDetails = "oldDetails"
        static let newDetails = "newDetails"
        static let details = "details"
        static let reason = "reason"
        static let reasonLength = "reason_length"
        static let hasReason = "has_reason"
        static let sectionId = "sectionId"
        static let sectionName = "sectionName"
        static let changedValue = "changedValue"
        static let changedSections = "changedSections"
        static let oldSections = "oldSections"
        static let carId = "carId"
        static let itemId = "itemId"
        static let screenTitle = "screenTitle"
        static let screenNumber = "screenNumber"
        static let decisionStep = "decisionStep"
        static let decision = "decision"
        static let completedSteps = "completedSteps"
        static let ctaAction = "ctaAction"
        static let hasPayload = "hasPayload"
        static let urlPath = "urlPath"
        static let website = "website"
        static let emailAdded = "emailAdded"
        static let itemType = "itemType"
        static let activated = "activated"
    }

    private enum DetailKey {
        static let email = "email"
        static let phone = "phone"
        static let name = "name"
        static let passportNumber = "passport_number"
        static let relationship = "relationship"
        static let points = "points"
        static let membershipNumber = "membership_number"
    }

    static let profileSource = "profile"
    private static let settingsSource = "settings"
    private static let otherWebsiteCardName = "other_website"
    static let travelPersonaAgentName = "travel_person_agent"

    // MARK: - Screens

    static func screen(
        _ screen: Screen,
        entrySource: EntrySource? = nil,
        travellerId: String? = nil,
        agentKey: String? = nil
    ) {
        screenView(screen.rawValue, [
            ParamKey.entrySource: entrySource?.rawValue,
            ParamKey.travellerId: travellerId,
            ParamKey.agentKey: agentKey
        ])
    }

    static func agentScreen(agentID: String, travellerId: String?) {
        screenView(agentName(agentID), [ParamKey.travellerId: travellerId, ParamKey.agentKey: agentKey(agentID)])
    }

    static func travelPersonaScreen(travellerId: String?) {
        screenView(travelPersonaAgentName, [ParamKey.travellerId: travellerId])
    }

    static func benefitScreen(benefitId: String, travellerId: String?) {
        screenView(benefitScreenName(benefitId), [ParamKey.travellerId: travellerId, ParamKey.benefitId: benefitId])
    }

    private static func screenView(_ name: String, _ params: [String: Any?]) {
        var merged: [String: Any?] = [ParamKey.screenName: name, ParamKey.actionSource: profileSource]
        merged.merge(params) { _, new in new }
        log(EventName.screenView, asScreenView: true, merged)
    }

    // MARK: - Hub

    static func kycNudgeShown(passId: String, kycStatus: String, kycDone: Int?, kycTotal: Int?) {
        log(EventName.kycNudgeShown, [
            ParamKey.passId: passId,
            ParamKey.kycStatus: kycStatus,
            ParamKey.kycDone: kycDone,
            ParamKey.kycTotal: kycTotal
        ])
    }

    static func worldPassTapped(travellerId: String, travellerName: String, tapOn: PassFace) {
        log(EventName.worldPassTapped, [
            ParamKey.travellerId: travellerId,
            ParamKey.travellerName: travellerName,
            ParamKey.tapOn: tapOn.rawValue
        ])
    }

    static func cardConnectClicked(travellerId: String?, actionSource: ConnectSource) {
        log(EventName.cardConnectClicked, [ParamKey.travellerId: travellerId, ParamKey.actionSource: actionSource.rawValue])
    }

    static func passSwitched(travellerId: String, direction: PassDirection) {
        log(EventName.passSwitched, [ParamKey.travellerId: travellerId, ParamKey.direction: direction.rawValue])
    }

    static func agentClicked(
        agentId: String,
        agentIndex: Int?,
        agentName: String,
        travellerId: String?,
        isActive: Bool,
        requiresKYC: Bool
    ) {
        log(EventName.agentClicked, [
            ParamKey.travellerId: travellerId,
            ParamKey.agentId: agentId,
            ParamKey.agentIndex: agentIndex,
            ParamKey.agentKey: agentKey(agentId),
            ParamKey.agentName: agentName,
            ParamKey.isActive: isActive,
            ParamKey.requiresKYC: requiresKYC
        ])
    }

    // MARK: - Benefits and coupons

    static func viewBenefitsClicked(travellerId: String?) {
        log(EventName.viewBenefitsClicked, [ParamKey.travellerId: travellerId])
    }

    static func benefitsScreenViewed(travellerId: String?, benefitList: [String]) {
        log(EventName.benefitsScreenViewed, [ParamKey.travellerId: travellerId, ParamKey.benefitList: benefitList])
    }

    static func benefitClicked(_ benefit: ProfileV3Benefit, travellerId: String?, origin: BenefitOrigin, routedToGate: Bool) {
        log(EventName.benefitClicked, [
            ParamKey.travellerId: travellerId,
            ParamKey.benefitId: benefit.id,
            ParamKey.benefitTitle: benefit.title,
            ParamKey.status: benefit.status.analyticsValue,
            ParamKey.origin: origin.rawValue,
            ParamKey.routedToGate: routedToGate
        ])
    }

    static func benefitRedeemed(benefitId: String, travellerId: String?) {
        log(EventName.benefitRedeemed, [ParamKey.travellerId: travellerId, ParamKey.benefitId: benefitId])
    }

    static func benefitRedeemFailed(benefitId: String, travellerId: String?, error: Error) {
        log(EventName.benefitRedeemFailed, [
            ParamKey.travellerId: travellerId,
            ParamKey.benefitId: benefitId,
            ParamKey.errorKind: errorKind(error)
        ])
    }

    static func couponClicked(couponId: String, origin: CouponOrigin) {
        log(EventName.couponClicked, [ParamKey.couponId: couponId, ParamKey.origin: origin.rawValue])
    }

    // MARK: - Loyalty programmes

    static func programCardScrolled(travellerId: String?, slideDepthPercentage: Int, connectorType: String) {
        log(EventName.programCardScrolled, [
            ParamKey.travellerId: travellerId,
            ParamKey.slideDepthPercentage: String(slideDepthPercentage),
            ParamKey.connectorType: connectorType
        ])
    }

    static func cardTypeSelected(travellerId: String?, connectorType: String) {
        log(EventName.cardTypeSelected, [ParamKey.travellerId: travellerId, ParamKey.connectorType: connectorType])
    }

    static func loyaltyCardClicked(travellerId: String?, cardName: String, connectorType: String) {
        log(EventName.loyaltyCardClicked, [
            ParamKey.travellerId: travellerId,
            ParamKey.cardName: cardName,
            ParamKey.connectorType: connectorType
        ])
    }

    static func cardDetailScreenViewed(travellerId: String?, item: ProfileV3ProgrammeCatalogueItem) {
        log(EventName.cardDetailScreenViewed, [
            ParamKey.travellerId: travellerId,
            ParamKey.cardName: item.name,
            ParamKey.connectorType: connectorType(item.category)
        ])
    }

    static func cardDetailsEntered(travellerId: String?, submission: ProfileV3ProgrammeSubmission) {
        let details: [String: Any?] = [
            DetailKey.points: submission.points,
            DetailKey.membershipNumber: submission.membershipNumber
        ]
        log(EventName.cardDetailsEntered, [
            ParamKey.travellerId: travellerId,
            ParamKey.cardName: submission.item.name,
            ParamKey.connectorType: connectorType(submission.item.category),
            ParamKey.loyaltyDetails: details.compactMapValues { $0 }
        ])
    }

    static func addedCardClicked(travellerId: String, cardsName: [String]) {
        log(EventName.addedCardClicked, [ParamKey.travellerId: travellerId, ParamKey.cardsName: cardsName])
    }

    static func viewInsightClicked(travellerId: String, programme: ProfileV3LoyaltyProgramme) {
        log(EventName.viewInsightClicked, programmeParams(programme, travellerId: travellerId))
    }

    static func insightViewed(travellerId: String, programme: ProfileV3LoyaltyProgramme, insightShown: String) {
        var params = programmeParams(programme, travellerId: travellerId)
        params[ParamKey.insightShown] = insightShown
        log(EventName.insightViewed, params)
    }

    static func cardNumberCopied(travellerId: String, programme: ProfileV3LoyaltyProgramme) {
        log(EventName.cardNumberCopied, programmeParams(programme, travellerId: travellerId))
    }

    static func cardEditClicked(travellerId: String) {
        log(EventName.cardEditClicked, [ParamKey.travellerId: travellerId])
    }

    static func cardRemoveClicked(travellerId: String, programme: ProfileV3LoyaltyProgramme) {
        log(EventName.cardRemoveClicked, programmeParams(programme, travellerId: travellerId))
    }

    private static func programmeParams(_ programme: ProfileV3LoyaltyProgramme, travellerId: String) -> [String: Any?] {
        [
            ParamKey.travellerId: travellerId,
            ParamKey.cardName: programme.name,
            ParamKey.connectorType: programme.category.map(connectorType)
        ]
    }

    static func connectorType(_ category: ProfileV3ProgrammeCategory) -> String {
        switch category {
        case .all: return "all"
        case .creditCards: return "cards"
        case .hotels: return "hotels"
        case .flights: return "flights"
        case .travelPasses: return "travel_passes"
        }
    }

    static func programmeInsightOpened(programmeId: String) {
        log(EventName.programmeInsightOpened, [ParamKey.programmeId: programmeId])
    }

    static func programmeRemoved(programmeId: String) {
        log(EventName.programmeRemoved, [ParamKey.programmeId: programmeId])
    }

    static func programmeRemoveFailed(programmeId: String, error: Error) {
        log(EventName.programmeRemoveFailed, [ParamKey.programmeId: programmeId, ParamKey.errorKind: errorKind(error)])
    }

    static func programmeScanStarted() {
        log(EventName.programmeScanStarted)
    }

    static func programmeScanFinished(foundCount: Int) {
        log(EventName.programmeScanFinished, [ParamKey.foundCount: foundCount])
    }

    static func programmeAddFailed(itemId: String, error: Error) {
        log(EventName.programmeAddFailed, [ParamKey.itemId: itemId, ParamKey.errorKind: errorKind(error)])
    }

    // MARK: - Settings

    static func accountCenterTapped(isOpening: Bool) {
        log(EventName.accountCenterTapped, [ParamKey.actionType: isOpening ? "open" : "close"])
    }

    static func settingsFieldClicked(_ field: ProfileV3ProfileField) {
        switch field {
        case .residence: log(EventName.residenceClicked)
        case .citizenship: log(EventName.citizenshipClicked)
        case .currency: log(EventName.currencyClicked)
        case .contact: log(EventName.contactInfoClicked)
        }
    }

    static func fieldUpdated(_ field: ProfileField, to value: String, from previous: String?) {
        switch field {
        case .residence:
            log(EventName.residenceUpdated, [ParamKey.newResidence: value, ParamKey.oldResidence: previous])
        case .citizenship:
            log(EventName.citizenshipUpdated, [ParamKey.newCitizenship: value, ParamKey.oldCitizenship: previous])
        case .currency:
            log(EventName.currencyUpdated, [ParamKey.newCurrency: value, ParamKey.oldCurrency: previous])
        }
    }

    static func fieldSaveFailed(_ field: ProfileField, error: Error) {
        log(EventName.fieldSaveFailed, [ParamKey.fieldKey: field.rawValue, ParamKey.errorKind: errorKind(error)])
    }

    static func contactUpdated(to details: ProfileV3ContactDetails, from previous: ProfileV3ContactDetails) {
        log(EventName.contactInfoUpdated, [
            ParamKey.newContactInfo: contactInfo(details),
            ParamKey.oldContactInfo: contactInfo(previous)
        ])
    }

    static func contactSaveFailed(errorKind: String, changedFields: [String]) {
        log(EventName.contactSaveFailed, [
            ParamKey.errorKind: errorKind,
            ParamKey.changedFields: joined(changedFields)
        ])
    }

    private static func contactInfo(_ details: ProfileV3ContactDetails) -> [String: String] {
        [DetailKey.email: details.email, DetailKey.phone: details.mobileNumber]
    }

    static func settingsConnectorClicked(_ connector: SettingsConnector) {
        log(EventName.settingsConnectorClicked, [ParamKey.connectorName: connector.rawValue])
    }

    static func settingsBackClicked() {
        log(EventName.settingsBackClicked)
    }

    static func permissionClicked() {
        log(EventName.permissionClicked)
    }

    static func permissionChanged(key: String, to optionID: String, from previous: String?) {
        log(EventName.permissionChanged, [
            ParamKey.newPermission: permissionValue(optionID),
            ParamKey.oldPermission: previous.map(permissionValue),
            ParamKey.source: permissionSource(key)
        ])
    }

    /// Both sides are keyed by source (`connector` / `action` / `call`).
    static func permissionClosed(new: [String: String], old: [String: String]) {
        log(EventName.permissionClosed, [
            ParamKey.newPermission: new,
            ParamKey.oldPermission: old
        ])
    }

    /// Which control the row belongs to, as the spec's `source` values.
    static func permissionSource(_ key: String) -> String {
        if key.contains("connector") { return "connector" }
        if key.contains("call") { return "call" }
        return "action"
    }

    static func permissionValue(_ optionID: String) -> String {
        optionID == "ask_some" ? "ask_sometimes" : optionID
    }

    static func couponsClicked() {
        log(EventName.couponsClicked)
    }

    static func termsClicked() {
        log(EventName.termsClicked)
    }

    static func logoutClicked() {
        log(EventName.logoutClicked)
    }

    static func loggedOut() {
        log(EventName.loggedOut)
    }

    // MARK: - Connectors

    static func gmailActivateClicked() {
        log(EventName.gmailActivateClicked, [ParamKey.actionSource: profileSource])
    }

    static func gmailConnectSuccess() {
        log(EventName.gmailConnectSuccess, [ParamKey.actionSource: profileSource])
    }

    static func gmailConnectFailure(errorKind: String) {
        log(EventName.gmailConnectFailure, [ParamKey.actionSource: profileSource, ParamKey.errorKind: errorKind])
    }

    static func gmailLaterClicked() {
        log(EventName.gmailLaterClicked, [ParamKey.actionSource: profileSource])
    }

    static func connectorDisconnectClicked(connectorName: String) {
        log(EventName.connectorDisconnectClicked, [ParamKey.connectorName: connectorName])
    }

    static func connectorDisconnected(connectorName: String) {
        log(EventName.connectorDisconnected, [ParamKey.connectorName: connectorName])
    }

    static func connectorDisconnectFailed(connectorName: String, error: Error) {
        log(EventName.connectorDisconnectFailed, [
            ParamKey.connectorName: connectorName,
            ParamKey.errorKind: errorKind(error)
        ])
    }

    // MARK: - Credential store

    static func passVaultClicked() {
        log(EventName.passVaultClicked, [ParamKey.actionSource: settingsSource])
    }

    static func passVaultAddCredentialsClicked() {
        log(EventName.passVaultAddCredentialsClicked)
    }

    static func passVaultWebsiteSelected(_ site: ProfileV3VaultSite) {
        log(EventName.passVaultWebsiteSelected, [
            ParamKey.website: vaultWebsite(site.loginURL),
            ParamKey.cardName: site.displayName
        ])
    }

    static func passVaultOtherWebsiteSelected(typed: String) {
        log(EventName.passVaultWebsiteSelected, [
            ParamKey.website: vaultWebsite(typed),
            ParamKey.cardName: otherWebsiteCardName
        ])
    }

    static func passVaultCredentialsAdded(_ credentials: ProfileV3AppCredentials, sites: [ProfileV3VaultSite]) {
        let url = credentials.websiteURL
        let website = url.flatMap(ProfileV3VaultSite.bareHost)
        log(EventName.passVaultCredentialsAdded, [
            ParamKey.website: website,
            ParamKey.cardName: url.flatMap { ProfileV3VaultSite.matching($0, in: sites) }?.displayName ?? website,
            ParamKey.emailAdded: credentials.username
        ])
    }

    static func passVaultWebsiteClicked(_ url: URL, cardName: String?) {
        let website = ProfileV3VaultSite.bareHost(url)
        log(EventName.passVaultWebsiteClicked, [ParamKey.website: website, ParamKey.cardName: cardName ?? website])
    }

    private static func vaultWebsite(_ address: String?) -> String? {
        address.flatMap { ProfileV3AppCredentials(website: $0).websiteURL }.flatMap(ProfileV3VaultSite.bareHost)
    }

    // MARK: - Glove box

    static func gloveBoxOpened() {
        log(EventName.gloveBoxOpened)
    }

    static func gloveBoxItemClicked(_ item: GloveBoxItem, activated: Bool) {
        log(EventName.gloveBoxItemClicked, [ParamKey.itemType: item.rawValue, ParamKey.activated: activated])
    }

    // MARK: - Travellers

    static func travellerClicked(travellerId: String) {
        log(EventName.travellerClicked, [ParamKey.travellerId: travellerId])
    }

    static func travellerSaved(
        travellerId: String,
        oldDetails: [String: String],
        newDetails: [String: String],
        passportChanged: Bool
    ) {
        log(EventName.travellerSaved, [
            ParamKey.travellerId: travellerId,
            ParamKey.oldDetails: oldDetails,
            ParamKey.newDetails: newDetails,
            ParamKey.passportChanged: passportChanged
        ])
    }

    static func travellerSaveFailed(travellerId: String, error: Error) {
        log(EventName.travellerSaveFailed, [ParamKey.travellerId: travellerId, ParamKey.errorKind: errorKind(error)])
    }

    static func travellerAdded(travellerId: String?, details: [String: String]) {
        log(EventName.travellerAdded, [ParamKey.travellerId: travellerId, ParamKey.details: details])
    }

    static func travellerAddFailed(error: Error) {
        log(EventName.travellerAddFailed, [ParamKey.errorKind: errorKind(error)])
    }

    static func travellerRemoved(travellerId: String) {
        log(EventName.travellerRemoved, [ParamKey.travellerId: travellerId])
    }

    static func travellerRemoveFailed(travellerId: String, error: Error) {
        log(EventName.travellerRemoveFailed, [ParamKey.travellerId: travellerId, ParamKey.errorKind: errorKind(error)])
    }

    static func travellerDetails(
        name: String,
        phone: String?,
        passportNumber: String?,
        relationship: String?
    ) -> [String: String] {
        let details: [String: String?] = [
            DetailKey.name: name,
            DetailKey.phone: phone,
            DetailKey.passportNumber: passportNumber,
            DetailKey.relationship: relationship
        ]
        return details.compactMapValues { $0?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty }
    }

    static func accountDeletionReasonSubmitted(reason: String) {
        log(EventName.accountDeletionReasonSubmitted, [
            ParamKey.actionSource: profileSource,
            ParamKey.reason: reason,
            ParamKey.reasonLength: reason.count,
            ParamKey.hasReason: !reason.isEmpty
        ])
    }

    // MARK: - Agents

    static func agentPreferenceChanged(agentID: String, travellerId: String?, sectionName: String, changedValue: Any?) {
        log(EventName.agentPreferenceChanged, [
            ParamKey.travellerId: travellerId,
            ParamKey.agentName: agentName(agentID),
            ParamKey.sectionName: sectionName,
            ParamKey.changedValue: changedValue
        ])
    }

    static func previousPassportsOpened(agentKey: String) {
        log(EventName.previousPassportsOpened, [ParamKey.agentKey: agentKey])
    }

    static func passportScanned(agentKey: String, sectionId: String) {
        log(EventName.passportScanned, [ParamKey.agentKey: agentKey, ParamKey.sectionId: sectionId])
    }

    static func agentFormSaved(
        agentID: String,
        travellerId: String?,
        changedSections: [String: Any],
        oldSections: [String: Any]
    ) {
        log(EventName.agentFormSaved, [
            ParamKey.travellerId: travellerId,
            ParamKey.agentKey: agentKey(agentID),
            ParamKey.agentName: agentName(agentID),
            ParamKey.changedSections: changedSections,
            ParamKey.oldSections: oldSections
        ])
    }

    static func agentFormSaveFailed(agentID: String, travellerId: String?, error: Error) {
        log(EventName.agentFormSaveFailed, [
            ParamKey.travellerId: travellerId,
            ParamKey.agentKey: agentKey(agentID),
            ParamKey.agentName: agentName(agentID),
            ParamKey.errorKind: errorKind(error)
        ])
    }

    static func carSelected(carId: String, agentKey: String) {
        log(EventName.carSelected, [ParamKey.carId: carId, ParamKey.agentKey: agentKey])
    }

    // MARK: - KYC

    static func completeKYCClicked() {
        log(EventName.completeKYCClicked, [ParamKey.actionSource: profileSource])
    }

    static func kycScreenSeen(screenTitle: String?, screenNumber: Int) {
        log(EventName.kycScreenSeen, [
            ParamKey.actionSource: profileSource,
            ParamKey.screenTitle: screenTitle,
            ParamKey.screenNumber: screenNumber
        ])
    }

    static func kycGmailDecision(decisionStep: String, decision: String) {
        log(EventName.kycGmailDecision, [
            ParamKey.actionSource: profileSource,
            ParamKey.decisionStep: decisionStep,
            ParamKey.decision: decision
        ])
    }

    static func kycOnboardingCompleted(completedSteps: [String]) {
        log(EventName.kycOnboardingCompleted, [
            ParamKey.actionSource: profileSource,
            ParamKey.completedSteps: joined(completedSteps)
        ])
    }

    // MARK: - Other

    static func cta(_ directive: ProfileV3Directive?, origin: CTAOrigin) {
        guard let directive else { return }
        log(EventName.ctaClicked, [
            ParamKey.ctaAction: directive.go,
            ParamKey.origin: origin.rawValue,
            ParamKey.agentId: directive.agentType,
            ParamKey.benefitId: directive.benefitID,
            ParamKey.programmeId: directive.programID,
            ParamKey.hasPayload: directive.hasPayload
        ])
    }

    static func deepLinkOpened(urlPath: String) {
        log(EventName.deepLinkOpened, [ParamKey.urlPath: urlPath])
    }

    // MARK: - Names

    static func agentKey(_ agentID: String) -> String {
        ProfileV3AgentID(rawValue: agentID)?.apiValue ?? agentID.replacingOccurrences(of: "-", with: "_")
    }

    static func agentName(_ agentID: String) -> String {
        switch ProfileV3AgentID(apiValue: agentID) {
        case .personal:
            return "personal_info_agent"
        case .some(let agent):
            return agent.apiValue + "_agent"
        case .none:
            let key = agentKey(agentID)
            return key == "travel_persona" ? travelPersonaAgentName : key + "_agent"
        }
    }

    static func benefitScreenName(_ benefitID: String) -> String {
        let words = Set(benefitID.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init))
        let match = benefitScreens.first { screen in screen.words.contains { words.isSuperset(of: $0) } }
        return match?.name ?? Screen.benefit.rawValue
    }

    private static let benefitScreens: [(name: String, words: [Set<String>])] = [
        ("aiSlotPriorityBenefit", [["slot", "priority"]]),
        ("aiFTIBenefit", [["fti"], ["fast", "track"], ["immigration"]]),
        ("aiAirportHotlineBenefit", [["hotline"]]),
        ("aiForexBenefit", [["forex"]]),
        ("aiTransfersBenefit", [["transfer"], ["transfers"]]),
        ("aiEsimBenefit", [["esim"]]),
        ("aiActivityBenefit", [["activity"], ["activities"]]),
        ("aiAylCashBenefit", [["ayl", "cash"], ["aylcash"]]),
        ("aiSuperCarBenefit", [["supercar"], ["super", "car"], ["super", "card"], ["car"], ["cars"]]),
        ("aiHotelCreditBenefit", [["hotel", "credit"], ["hotel", "credits"], ["hotels", "credit"], ["hotels", "credits"]]),
        ("aiHotelBenefit", [["hotel"], ["hotels"], ["stay"], ["stays"]]),
        ("aiInsuranceBenefit", [["insurance"], ["baggage"], ["medical"], ["delay"], ["protection"]]),
        ("aiFlightBenefit", [["flight"], ["flights"]])
    ]

    static func errorKind(_ error: Error) -> String {
        switch error {
        case let profileError as ProfileV3Error:
            switch profileError {
            case .unauthorized: return "unauthorized"
            case .notImplemented: return "not_implemented"
            case .invalidRequest: return "invalid_request"
            case .server(let code, _): return code ?? "server"
            case .conflict(let code, _): return code ?? "conflict"
            case .transient: return "transient"
            case .partialSave: return "preferences_write_failed"
            case .passportFrontPending: return "passport_front_pending"
            case .underlying: return "underlying"
            }
        case let repositoryError as ProfileV3RepositoryError:
            switch repositoryError {
            case .agentNotFound: return "agent_not_found"
            case .unavailable: return "unavailable"
            }
        case is URLError:
            return "network"
        default:
            if let status = ProfileV3APIErrorMapper.statusCode(of: error) { return "http_\(status)" }
            return ProfileV3APIErrorMapper.isTransportFailure(error) ? "network" : "unknown"
        }
    }

    private static func joined(_ values: [String]) -> String {
        values.joined(separator: ",")
    }

    // MARK: - Sink

    @TaskLocal static var scopedReporter: (any ProfileV3AnalyticsReporting)?

    private static let sinkLock = NSLock()
    nonisolated(unsafe) private static var sink: (any ProfileV3AnalyticsReporting)?

    static func install(_ reporter: any ProfileV3AnalyticsReporting) {
        sinkLock.lock()
        sink = reporter
        sinkLock.unlock()
    }

    private static func log(_ name: String, asScreenView: Bool = false, _ params: [String: Any?] = [:]) {
        sinkLock.lock()
        let installed = sink
        sinkLock.unlock()
        let reporter = scopedReporter ?? installed
        reporter?.logEvent(name, asScreenView: asScreenView, parameters: params.compactMapValues { $0 })
    }
}

extension ProfileV3KYCStatus {
    var analyticsValue: String {
        switch self {
        case .notStarted: return "not_started"
        case .expired: return "expired"
        case .complete: return "complete"
        }
    }
}

extension ProfileV3Benefit.Status {
    var analyticsValue: String {
        switch self {
        case .locked: return "locked"
        case .active: return "active"
        case .partiallyRedeemed: return "partially_redeemed"
        case .redeemed: return "redeemed"
        }
    }
}

private extension ProfileV3Directive {
    var hasPayload: Bool {
        [profileID, agentType, benefitID, connector, programID, programName, kind, field, fieldKey, reason]
            .contains { $0 != nil } || !steps.isEmpty
    }
}

@MainActor
final class ProfileV3ImpressionLog {
    private var seen: Set<String> = []

    func once(_ key: String, _ fire: () -> Void) {
        guard seen.insert(key).inserted else { return }
        fire()
    }

    func reset() {
        seen.removeAll()
    }
}

extension View {
    @ViewBuilder
    func profileV3OnImpression(_ action: @escaping () -> Void) -> some View {
        if #available(iOS 18.0, *) {
            onScrollVisibilityChange(threshold: 0.5) { isVisible in
                if isVisible { action() }
            }
        } else {
            onAppear(perform: action)
        }
    }
}
