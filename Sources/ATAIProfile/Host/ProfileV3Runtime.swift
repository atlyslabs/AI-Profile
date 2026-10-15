import Foundation
import Moya

/// The package's launch entry. A host registers its configuration provider and its host actions
/// once; the profile environment is built from those the first time a screen asks for it.
@MainActor
public enum ProfileV3Runtime {
    private static var configurationProvider: (() -> any ProfileV3ConfigurationProviding)?
    private static var hostActions: ProfileV3HostActions?
    private static var appVersion: String?
    private static var plugins: [PluginType] = []
    private static var built: ProfileV3Environment?

    public static func registerConfigurationProvider(
        _ provider: @escaping () -> any ProfileV3ConfigurationProviding,
        appVersion: String? = nil,
        plugins: [PluginType] = []
    ) {
        configurationProvider = provider
        self.appVersion = appVersion
        self.plugins = plugins
        built = nil
    }

    public static func registerHostActions(_ actions: ProfileV3HostActions) {
        hostActions = actions
        built = nil
    }

    static var environment: ProfileV3Environment {
        if let built { return built }
        guard let configurationProvider, let hostActions else {
            preconditionFailure(
                "ProfileV3Runtime.registerConfigurationProvider and registerHostActions must run before ProfileV3 is used"
            )
        }
        let environment = ProfileV3Environment(
            provider: configurationProvider(),
            actions: hostActions,
            appVersion: appVersion,
            plugins: plugins
        )
        built = environment
        return environment
    }
}
