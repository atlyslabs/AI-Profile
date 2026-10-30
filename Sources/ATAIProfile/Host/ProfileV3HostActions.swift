import Foundation

@MainActor
public struct ProfileV3HostActions {
    public var account: any ProfileV3AccountHost
    public var app: any ProfileV3AppHost
    public var kyc: any ProfileV3KYCHost
    public var identityCapture: any ProfileV3IdentityCaptureHost
    public var coupons: any ProfileV3CouponsHost
    public var invites: (any ProfileV3InviteHost)?
    public var analytics: any ProfileV3AnalyticsReporting
    public var globe: any ProfileV3GlobeRendering
    public var validation: any ProfileV3FieldValidating
    public var countries: [ProfileV3Country]?

    public init(
        account: any ProfileV3AccountHost,
        app: any ProfileV3AppHost,
        kyc: any ProfileV3KYCHost,
        identityCapture: any ProfileV3IdentityCaptureHost,
        coupons: any ProfileV3CouponsHost,
        analytics: any ProfileV3AnalyticsReporting,
        globe: any ProfileV3GlobeRendering,
        validation: any ProfileV3FieldValidating,
        countries: [ProfileV3Country]? = nil,
        invites: (any ProfileV3InviteHost)? = nil
    ) {
        self.account = account
        self.app = app
        self.kyc = kyc
        self.identityCapture = identityCapture
        self.coupons = coupons
        self.analytics = analytics
        self.globe = globe
        self.validation = validation
        self.countries = countries
        self.invites = invites
    }
}
