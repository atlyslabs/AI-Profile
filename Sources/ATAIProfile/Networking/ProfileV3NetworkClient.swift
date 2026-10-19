import ATCore
import Foundation
import Moya

public final class ProfileV3NetworkClient: @unchecked Sendable {
    private let executor: ATCoreRequestExecutor<ProfileV3API>
    private let decoder = JSONDecoder()

    public init(
        baseProvider: any ATCoreBaseProvider,
        appVersion: String? = nil,
        plugins: [PluginType] = []
    ) {
        let provider: MoyaProvider<ProfileV3API> = ATCoreMoyaProviderFactory.makeProvider(
            baseProvider: baseProvider,
            plugins: [
                ATCoreAuthPlugin(baseProvider: baseProvider),
                ProfileV3HostHeadersPlugin(appVersion: appVersion ?? Self.bundleShortVersion),
                ProfileV3ErrorEnvelopePlugin(),
            ] + plugins
        )
        executor = ATCoreRequestExecutor(provider: provider)
    }

    func request<T: Decodable>(_ target: ProfileV3API) async throws -> T {
        let response = try await executor.requestRaw(target)
        do {
            return try decoder.decode(T.self, from: response.data)
        } catch {
            throw ATCoreError.decoding(message: error.localizedDescription)
        }
    }

    func requestData(_ target: ProfileV3API) async throws -> Data {
        try await executor.requestRaw(target).data
    }

    func perform(_ target: ProfileV3API) async throws {
        _ = try await executor.requestRaw(target)
    }

    private static var bundleShortVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}

private struct ProfileV3HostHeadersPlugin: PluginType {
    let appVersion: String

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.setValue("ios", forHTTPHeaderField: "x-platform")
        if request.value(forHTTPHeaderField: "x-app-version") == nil {
            request.setValue(appVersion, forHTTPHeaderField: "x-app-version")
        }
        return request
    }
}

private struct ProfileV3ErrorEnvelopePlugin: PluginType {
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        guard case .failure(let moyaError) = result,
              case .underlying(let underlying, let response?) = moyaError,
              let serverError = underlying as? ATCoreServerError else {
            return result
        }
        let parsed = ProfileV3ErrorEnvelope.parse(response.data)
        ProfileV3ServerFailureBox.shared.store(parsed)
        let message = parsed?.message ?? ""
        let rewritten = ATCoreServerError(message: message, statusCode: serverError.statusCode)
        return .failure(.underlying(rewritten, response))
    }
}
