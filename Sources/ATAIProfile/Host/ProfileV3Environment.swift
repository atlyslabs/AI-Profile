import ATCore
import Foundation
import Moya

@MainActor
public final class ProfileV3Environment {
    nonisolated public let client: ProfileV3NetworkClient
    nonisolated public let session: any ProfileV3SessionProviding
    public let kyc: any ProfileV3KYCHost
    public let identityCapture: any ProfileV3IdentityCaptureHost
    public let globe: any ProfileV3GlobeRendering
    public let analytics: any ProfileV3AnalyticsReporting
    public let validation: any ProfileV3FieldValidating
    public let account: any ProfileV3AccountHost
    public let coupons: any ProfileV3CouponsHost
    public let app: any ProfileV3AppHost
    let boardStore: ProfileV3BoardStore

    public init(
        baseProvider: any ATCoreBaseProvider,
        session: any ProfileV3SessionProviding,
        kyc: any ProfileV3KYCHost,
        identityCapture: any ProfileV3IdentityCaptureHost,
        globe: any ProfileV3GlobeRendering,
        analytics: any ProfileV3AnalyticsReporting,
        validation: any ProfileV3FieldValidating,
        account: any ProfileV3AccountHost,
        coupons: any ProfileV3CouponsHost,
        app: any ProfileV3AppHost,
        countries: [ProfileV3Country],
        appVersion: String? = nil,
        plugins: [PluginType] = []
    ) {
        let client = ProfileV3NetworkClient(baseProvider: baseProvider, appVersion: appVersion, plugins: plugins)
        self.client = client
        self.session = session
        self.kyc = kyc
        self.identityCapture = identityCapture
        self.globe = globe
        self.analytics = analytics
        self.validation = validation
        self.account = account
        self.coupons = coupons
        self.app = app
        self.boardStore = ProfileV3BoardStore(client: client, session: session)
        ProfileV3Analytics.install(analytics)
        ProfileV3FieldValidation.install(validation)
        ProfileV3Countries.install(countries)
    }

    func makeRepository() -> any ProfileV3Repository {
        ProfileV3LiveRepository(client: client, boardStore: boardStore, session: session, account: account)
    }
}
