import ATCore
import ATUIKit
import Foundation
import Moya

@MainActor
final class ProfileV3Environment {
    nonisolated let client: ProfileV3NetworkClient
    nonisolated let session: any ProfileV3SessionProviding
    let kyc: any ProfileV3KYCHost
    let identityCapture: any ProfileV3IdentityCaptureHost
    let globe: any ProfileV3GlobeRendering
    let account: any ProfileV3AccountHost
    let coupons: any ProfileV3CouponsHost
    let app: any ProfileV3AppHost
    let boardStore: ProfileV3BoardStore

    init(
        provider: any ProfileV3ConfigurationProviding,
        actions: ProfileV3HostActions,
        appVersion: String? = nil,
        plugins: [PluginType] = []
    ) {
        let client = ProfileV3NetworkClient(baseProvider: provider, appVersion: appVersion, plugins: plugins)
        self.client = client
        self.session = provider
        self.kyc = actions.kyc
        self.identityCapture = actions.identityCapture
        self.globe = actions.globe
        self.account = actions.account
        self.coupons = actions.coupons
        self.app = actions.app
        self.boardStore = ProfileV3BoardStore(client: client, session: provider)
        ProfileV3Analytics.install(actions.analytics)
        ProfileV3FieldValidation.install(actions.validation)
        ProfileV3Countries.install(actions.countries ?? Self.defaultCountries)
        PhoneCodeResolver.install { [provider] in provider.userResidencyCode }
    }

    func makeRepository() -> any ProfileV3Repository {
        ProfileV3LiveRepository(client: client, boardStore: boardStore, session: session, account: account)
    }

    private static var defaultCountries: [ProfileV3Country] {
        ATFormFieldCountryDirectory.defaultCountries.map { ProfileV3Country(code: $0.code, name: $0.name) }
    }
}
