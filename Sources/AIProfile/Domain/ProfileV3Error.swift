import Foundation

enum ProfileV3Error: LocalizedError, Equatable {
    case unauthorized
    case notImplemented(action: String)
    case invalidRequest(message: String?)
    case server(code: String?, message: String?)
    case conflict(code: String?, message: String?)
    case transient(message: String?)
    case passportFrontPending
    case underlying(String)

    static func message(for error: Error, fallback: String = ProfileV3Strings.somethingWentWrong) -> String {
        (error as? ProfileV3Error)?.errorDescription ?? fallback
    }

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return ProfileV3Strings.somethingWentWrong
        case .notImplemented:
            return ProfileV3Strings.actionUnavailable
        case .invalidRequest(let message):
            return message ?? ProfileV3Strings.somethingWentWrong
        case .server(_, let message):
            return message ?? ProfileV3Strings.somethingWentWrong
        case .conflict(_, let message):
            return message ?? ProfileV3Strings.somethingWentWrong
        case .transient(let message):
            return message ?? ProfileV3Strings.somethingWentWrong
        case .passportFrontPending:
            return ProfileV3Strings.passportUploadFailed
        case .underlying(let message):
            return message
        }
    }
}
