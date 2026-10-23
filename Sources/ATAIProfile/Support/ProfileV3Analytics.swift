import SwiftUI

public enum ProfileV3EntrySource: String, Sendable {
    case chat
    case accountSettings = "account_settings"
    case deepLink = "deep_link"
}

enum ProfileV3Analytics {

    enum Screen: String {
        case hub = "aiProfile"
        case settings = "aiProfileSettings"
        case agent = "aiProfileAgent"
        case agentForm = "aiProfileAgentForm"
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

    enum PassState: String {
        case expanded
        case collapsed
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

    enum ProgrammeEditState: String {
        case editing
        case done
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

    private enum EventName {
        static let screenView = "screen_view"
        static let passViewed = "profile_pass_viewed"
        static let agentCardViewed = "profile_agent_card_viewed"
        static let benefitViewed = "profile_benefit_viewed"
        static let couponViewed = "profile_coupon_viewed"
        static let programmeViewed = "profile_programme_viewed"
        static let kycNudgeShown = "profile_kyc_nudge_shown"
        static let passSwitched = "profile_pass_switched"
        static let passExpanded = "profile_pass_expanded"
        static let agentClicked = "profile_agent_clicked"
        static let benefitClicked = "profile_benefit_clicked"
        static let benefitRedeemed = "profile_benefit_redeemed"
        static let benefitRedeemFailed = "profile_benefit_redeem_failed"
        static let couponClicked = "profile_coupon_clicked"
        static let settingsRowClicked = "profile_settings_row_clicked"
        static let fieldSaved = "profile_field_saved"
        static let fieldSaveFailed = "profile_field_save_failed"
        static let contactSaved = "profile_contact_saved"
        static let contactSaveFailed = "profile_contact_save_failed"
        static let gmailActivateClicked = "gmail_connector_activate_clicked"
        static let gmailConnectSuccess = "gmail_connector_connect_success"
        static let gmailConnectFailure = "gmail_connector_connect_failure"
        static let gmailLaterClicked = "gmail_connector_later_clicked"
        static let connectorDisconnectClicked = "profile_connector_disconnect_clicked"
        static let connectorDisconnected = "profile_connector_disconnected"
        static let connectorDisconnectFailed = "profile_connector_disconnect_failed"
        static let travellerClicked = "profile_traveller_clicked"
        static let travellerSaved = "profile_traveller_saved"
        static let travellerSaveFailed = "profile_traveller_save_failed"
        static let travellerAdded = "profile_traveller_added"
        static let travellerAddFailed = "profile_traveller_add_failed"
        static let travellerRemoved = "profile_traveller_removed"
        static let travellerRemoveFailed = "profile_traveller_remove_failed"
        static let accountDeletionReasonSubmitted = "account_deletion_reason_submitted"
        static let logout = "profile_logout"
        static let agentOptionToggled = "profile_agent_option_toggled"
        static let previousPassportsOpened = "profile_previous_passports_opened"
        static let passportScanned = "profile_passport_scanned"
        static let agentFormSaved = "profile_agent_form_saved"
        static let agentFormSaveFailed = "profile_agent_form_save_failed"
        static let carSelected = "profile_car_selected"
        static let programmeInsightOpened = "profile_programme_insight_opened"
        static let programmeEditToggled = "profile_programme_edit_toggled"
        static let programmeRemoved = "profile_programme_removed"
        static let programmeRemoveFailed = "profile_programme_remove_failed"
        static let programmeScanStarted = "profile_programme_scan_started"
        static let programmeScanFinished = "profile_programme_scan_finished"
        static let programmeSelected = "profile_programme_selected"
        static let programmeAdded = "profile_programme_added"
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
        static let benefitId = "benefitId"
        static let benefitIndex = "benefitIndex"
        static let couponId = "couponId"
        static let couponIndex = "couponIndex"
        static let programmeId = "programmeId"
        static let programmeIndex = "programmeIndex"
        static let passId = "passId"
        static let passIndex = "passIndex"
        static let kycStatus = "kycStatus"
        static let kycDone = "kycDone"
        static let kycTotal = "kycTotal"
        static let direction = "direction"
        static let toState = "toState"
        static let isActive = "isActive"
        static let foundCount = "foundCount"
        static let totalCount = "totalCount"
        static let requiresKYC = "requiresKYC"
        static let status = "status"
        static let origin = "origin"
        static let routedToGate = "routedToGate"
        static let errorKind = "errorKind"
        static let rowKey = "rowKey"
        static let fieldKey = "fieldKey"
        static let value = "value"
        static let changedFields = "changedFields"
        static let connectorKey = "connectorKey"
        static let travellerId = "travellerId"
        static let passportChanged = "passportChanged"
        static let reasonLength = "reason_length"
        static let hasReason = "has_reason"
        static let sectionId = "sectionId"
        static let optionId = "optionId"
        static let isSelected = "isSelected"
        static let changedSections = "changedSections"
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
    }

    static let profileSource = "profile"

    static func screen(
        _ screen: Screen,
        entrySource: EntrySource? = nil,
        agentKey: String? = nil,
        benefitId: String? = nil
    ) {
        log(EventName.screenView, asScreenView: true, [
            ParamKey.screenName: screen.rawValue,
            ParamKey.actionSource: profileSource,
            ParamKey.entrySource: entrySource?.rawValue,
            ParamKey.agentKey: agentKey,
            ParamKey.benefitId: benefitId
        ])
    }

    static func passViewed(passId: String, passIndex: Int, kycStatus: String) {
        log(EventName.passViewed, [
            ParamKey.passId: passId,
            ParamKey.passIndex: passIndex,
            ParamKey.kycStatus: kycStatus
        ])
    }

    static func agentCardViewed(
        agentId: String,
        agentIndex: Int,
        agentKey: String,
        isActive: Bool,
        foundCount: Int,
        totalCount: Int
    ) {
        log(EventName.agentCardViewed, [
            ParamKey.agentId: agentId,
            ParamKey.agentIndex: agentIndex,
            ParamKey.agentKey: agentKey,
            ParamKey.isActive: isActive,
            ParamKey.foundCount: foundCount,
            ParamKey.totalCount: totalCount
        ])
    }

    static func benefitViewed(benefitId: String, benefitIndex: Int, status: String) {
        log(EventName.benefitViewed, [
            ParamKey.benefitId: benefitId,
            ParamKey.benefitIndex: benefitIndex,
            ParamKey.status: status
        ])
    }

    static func couponViewed(couponId: String, couponIndex: Int) {
        log(EventName.couponViewed, [ParamKey.couponId: couponId, ParamKey.couponIndex: couponIndex])
    }

    static func programmeViewed(programmeId: String, programmeIndex: Int) {
        log(EventName.programmeViewed, [ParamKey.programmeId: programmeId, ParamKey.programmeIndex: programmeIndex])
    }

    static func kycNudgeShown(passId: String, kycStatus: String, kycDone: Int?, kycTotal: Int?) {
        log(EventName.kycNudgeShown, [
            ParamKey.passId: passId,
            ParamKey.kycStatus: kycStatus,
            ParamKey.kycDone: kycDone,
            ParamKey.kycTotal: kycTotal
        ])
    }

    static func passSwitched(passId: String, direction: PassDirection) {
        log(EventName.passSwitched, [ParamKey.passId: passId, ParamKey.direction: direction.rawValue])
    }

    static func passExpanded(passId: String, toState: PassState) {
        log(EventName.passExpanded, [ParamKey.passId: passId, ParamKey.toState: toState.rawValue])
    }

    static func agentClicked(agentId: String, agentKey: String, isActive: Bool, requiresKYC: Bool) {
        log(EventName.agentClicked, [
            ParamKey.agentId: agentId,
            ParamKey.agentKey: agentKey,
            ParamKey.isActive: isActive,
            ParamKey.requiresKYC: requiresKYC
        ])
    }

    static func benefitClicked(benefitId: String, status: String, origin: BenefitOrigin, routedToGate: Bool) {
        log(EventName.benefitClicked, [
            ParamKey.benefitId: benefitId,
            ParamKey.status: status,
            ParamKey.origin: origin.rawValue,
            ParamKey.routedToGate: routedToGate
        ])
    }

    static func benefitRedeemed(benefitId: String) {
        log(EventName.benefitRedeemed, [ParamKey.benefitId: benefitId])
    }

    static func benefitRedeemFailed(benefitId: String, error: Error) {
        log(EventName.benefitRedeemFailed, [ParamKey.benefitId: benefitId, ParamKey.errorKind: errorKind(error)])
    }

    static func couponClicked(couponId: String, origin: CouponOrigin) {
        log(EventName.couponClicked, [ParamKey.couponId: couponId, ParamKey.origin: origin.rawValue])
    }

    static func settingsRowClicked(rowKey: String) {
        log(EventName.settingsRowClicked, [ParamKey.rowKey: rowKey])
    }

    static func fieldSaved(_ field: ProfileField, value: String) {
        log(EventName.fieldSaved, [ParamKey.fieldKey: field.rawValue, ParamKey.value: value])
    }

    static func fieldSaveFailed(_ field: ProfileField, error: Error) {
        log(EventName.fieldSaveFailed, [ParamKey.fieldKey: field.rawValue, ParamKey.errorKind: errorKind(error)])
    }

    static func contactSaved(changedFields: [String]) {
        log(EventName.contactSaved, [ParamKey.changedFields: joined(changedFields)])
    }

    static func contactSaveFailed(errorKind: String, changedFields: [String]) {
        log(EventName.contactSaveFailed, [
            ParamKey.errorKind: errorKind,
            ParamKey.changedFields: joined(changedFields)
        ])
    }

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

    static func connectorDisconnectClicked(connectorKey: String) {
        log(EventName.connectorDisconnectClicked, [ParamKey.connectorKey: connectorKey])
    }

    static func connectorDisconnected(connectorKey: String) {
        log(EventName.connectorDisconnected, [ParamKey.connectorKey: connectorKey])
    }

    static func connectorDisconnectFailed(connectorKey: String, error: Error) {
        log(EventName.connectorDisconnectFailed, [
            ParamKey.connectorKey: connectorKey,
            ParamKey.errorKind: errorKind(error)
        ])
    }

    static func travellerClicked(travellerId: String) {
        log(EventName.travellerClicked, [ParamKey.travellerId: travellerId])
    }

    static func travellerSaved(travellerId: String, passportChanged: Bool) {
        log(EventName.travellerSaved, [ParamKey.travellerId: travellerId, ParamKey.passportChanged: passportChanged])
    }

    static func travellerSaveFailed(travellerId: String, error: Error) {
        log(EventName.travellerSaveFailed, [ParamKey.travellerId: travellerId, ParamKey.errorKind: errorKind(error)])
    }

    static func travellerAdded(travellerId: String?) {
        log(EventName.travellerAdded, [ParamKey.travellerId: travellerId])
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

    static func accountDeletionReasonSubmitted(reason: String) {
        log(EventName.accountDeletionReasonSubmitted, [
            ParamKey.actionSource: profileSource,
            ParamKey.reasonLength: reason.count,
            ParamKey.hasReason: !reason.isEmpty
        ])
    }

    static func logout() {
        log(EventName.logout)
    }

    static func agentOptionToggled(agentKey: String, sectionId: String, optionId: String, isSelected: Bool) {
        log(EventName.agentOptionToggled, [
            ParamKey.agentKey: agentKey,
            ParamKey.sectionId: sectionId,
            ParamKey.optionId: optionId,
            ParamKey.isSelected: isSelected
        ])
    }

    static func previousPassportsOpened(agentKey: String) {
        log(EventName.previousPassportsOpened, [ParamKey.agentKey: agentKey])
    }

    static func passportScanned(agentKey: String, sectionId: String) {
        log(EventName.passportScanned, [ParamKey.agentKey: agentKey, ParamKey.sectionId: sectionId])
    }

    static func agentFormSaved(agentKey: String, changedSections: [String]) {
        log(EventName.agentFormSaved, [ParamKey.agentKey: agentKey, ParamKey.changedSections: joined(changedSections)])
    }

    static func agentFormSaveFailed(agentKey: String, error: Error) {
        log(EventName.agentFormSaveFailed, [ParamKey.agentKey: agentKey, ParamKey.errorKind: errorKind(error)])
    }

    static func carSelected(carId: String, agentKey: String) {
        log(EventName.carSelected, [ParamKey.carId: carId, ParamKey.agentKey: agentKey])
    }

    static func programmeInsightOpened(programmeId: String) {
        log(EventName.programmeInsightOpened, [ParamKey.programmeId: programmeId])
    }

    static func programmeEditToggled(toState: ProgrammeEditState) {
        log(EventName.programmeEditToggled, [ParamKey.toState: toState.rawValue])
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

    static func programmeSelected(itemId: String) {
        log(EventName.programmeSelected, [ParamKey.itemId: itemId])
    }

    static func programmeAdded(itemId: String) {
        log(EventName.programmeAdded, [ParamKey.itemId: itemId])
    }

    static func programmeAddFailed(itemId: String, error: Error) {
        log(EventName.programmeAddFailed, [ParamKey.itemId: itemId, ParamKey.errorKind: errorKind(error)])
    }

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

    static func agentKey(_ agentID: String) -> String {
        ProfileV3AgentID(rawValue: agentID)?.apiValue ?? agentID.replacingOccurrences(of: "-", with: "_")
    }

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

    private static let sinkLock = NSLock()
    nonisolated(unsafe) private static var sink: (any ProfileV3AnalyticsReporting)?

    static func install(_ reporter: any ProfileV3AnalyticsReporting) {
        sinkLock.lock()
        sink = reporter
        sinkLock.unlock()
    }

    private static func log(_ name: String, asScreenView: Bool = false, _ params: [String: Any?] = [:]) {
        sinkLock.lock()
        let reporter = sink
        sinkLock.unlock()
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
