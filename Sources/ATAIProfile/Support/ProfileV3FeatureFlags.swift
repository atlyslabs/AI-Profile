import Foundation

enum ProfileV3FeatureFlags {
    static let isBenefitRedeemEnabled = false
    static let isCouponRedeemEnabled = false
    static let isPassAddTravellerEnabled = false
    static let isProgrammeInsightContinueEnabled = false
    static let isConnectOtherEmailsEnabled = false
    static let isITRDisconnectEnabled = false
    static let isAgentSourcesPillEnabled = false
    static let isProgrammeScanLoaderEnabled = false
    static let isPersonaEditingEnabled = false
    #if DEBUG
    static let isAppAccessEnabled = true
    #else
    static let isAppAccessEnabled = false
    #endif
}
