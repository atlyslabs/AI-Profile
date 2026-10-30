import ATAuthKit
import ATCore
import Foundation

enum ProfileV3APIErrorMapper {
    private static let passportFrontRequiredCode = "kyc_passport_front_required"

    static func map(_ error: Error, action: String) -> Error {
        if error is CancellationError { return error }
        if let profileError = error as? ProfileV3Error { return profileError }

        let parsed = ProfileV3ServerFailureBox.shared.consume()
        let status = statusCode(of: error)
        let message = serverMessage(of: error) ?? parsed?.message
        ATCoreLogger.error(
            "[ProfileV3] \(action) failed status=\(status.map(String.init) ?? "-") error=\(error.localizedDescription)"
        )

        switch status {
        case 401:
            if let message, message.localizedCaseInsensitiveContains("re-authentication") {
                return ProfileV3Error.server(code: "reauth", message: ProfileV3VaultStrings.confirmItsYou)
            }
            return ProfileV3Error.unauthorized
        case 409:
            return ProfileV3Error.conflict(code: nil, message: message)
        case 404:
            return ProfileV3Error.server(code: parsed?.code, message: message)
        case 422:
            return ProfileV3Error.invalidRequest(message: message)
        case 501:
            return ProfileV3Error.notImplemented(action: action)
        case 502 where parsed?.code == "preferences_write_failed":
            return ProfileV3Error.partialSave(
                message: message,
                failedIDs: parsed?.failedProfileIDs ?? [],
                savedIDs: parsed?.savedProfileIDs ?? []
            )
        case 502, 503, 504:
            return ProfileV3Error.transient(message: message)
        default:
            if let message {
                return ProfileV3Error.server(code: parsed?.code, message: message)
            }
            return error
        }
    }

    static func mapCaptureUpload(_ error: Error, image: ProfileV3CaptureImage) -> Error {
        guard image == .passportBack, isPassportFrontPending(error) else { return error }
        return ProfileV3Error.passportFrontPending
    }

    private static func isPassportFrontPending(_ error: Error) -> Bool {
        switch error {
        case ProfileV3Error.conflict: return true
        case ProfileV3Error.server(let code, _): return code == passportFrontRequiredCode
        default: return false
        }
    }

    static func isUnauthorized(_ error: Error) -> Bool {
        if case ProfileV3Error.unauthorized = error { return true }
        return statusCode(of: error) == 401
    }

    static func withUnauthorizedRetry<T>(action: String, _ operation: () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch {
            guard isUnauthorized(error), await refreshIDToken() else { throw map(error, action: action) }
            do {
                return try await operation()
            } catch {
                throw map(error, action: action)
            }
        }
    }

    static func statusCode(of error: Error) -> Int? {
        guard case ATCoreError.server(let serverError) = error else { return nil }
        return serverError.statusCode
    }

    static func isTransportFailure(_ error: Error) -> Bool {
        switch error {
        case ATCoreError.offline, ATCoreError.network: return true
        case is URLError: return true
        default: return false
        }
    }

    private static func serverMessage(of error: Error) -> String? {
        guard case ATCoreError.server(let serverError) = error else { return nil }
        return serverError.message.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
    }

    @MainActor
    private static func refreshIDToken() async -> Bool {
        guard let user = ATAuthKit.currentUser else { return false }
        return await withCheckedContinuation { continuation in
            user.getIDTokenForcingRefresh(true) { token, _ in
                continuation.resume(returning: token != nil)
            }
        }
    }
}

extension ProfileV3NetworkClient {
    func request<T: Decodable>(_ target: ProfileV3API, action: String) async throws -> T {
        try await ProfileV3APIErrorMapper.withUnauthorizedRetry(action: action) { try await request(target) }
    }

    func requestData(_ target: ProfileV3API, action: String) async throws -> Data {
        try await ProfileV3APIErrorMapper.withUnauthorizedRetry(action: action) { try await requestData(target) }
    }

    func perform(_ target: ProfileV3API, action: String) async throws {
        try await ProfileV3APIErrorMapper.withUnauthorizedRetry(action: action) { try await perform(target) }
    }
}
