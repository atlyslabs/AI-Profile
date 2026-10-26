import Foundation

final class ProfileV3ServerFailureBox: @unchecked Sendable {
    static let shared = ProfileV3ServerFailureBox()

    private let lock = NSLock()
    private var latest: ProfileV3ErrorEnvelope.Parsed?

    func store(_ parsed: ProfileV3ErrorEnvelope.Parsed?) {
        lock.lock()
        latest = parsed
        lock.unlock()
    }

    func consume() -> ProfileV3ErrorEnvelope.Parsed? {
        lock.lock()
        defer { lock.unlock() }
        let parsed = latest
        latest = nil
        return parsed
    }
}

enum ProfileV3ErrorEnvelope {
    struct Parsed: Equatable, Sendable {
        let code: String?
        let message: String?
        var profileIDs: [String] = []
        var failedProfileIDs: [String] = []
        var savedProfileIDs: [String] = []
    }

    static func parse(_ data: Data) -> Parsed? {
        guard !data.isEmpty,
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        var code: String?
        var message: String?
        var details: [String: Any]?
        if let nested = object["error"] as? [String: Any] {
            code = trimmed(nested["code"] as? String)
            message = trimmed(nested["message"] as? String)
            details = nested["details"] as? [String: Any]
        } else if let flat = object["error"] as? String {
            message = trimmed(flat)
        }
        if message == nil { message = trimmed(object["message"] as? String) }
        if message == nil { message = trimmed(object["detail"] as? String) }
        if code == nil { code = trimmed(object["code"] as? String) }
        if details == nil { details = object["details"] as? [String: Any] }

        guard code != nil || message != nil else { return nil }
        return Parsed(
            code: code,
            message: message,
            profileIDs: strings(details?["profile_ids"]),
            failedProfileIDs: strings(details?["failed_profile_ids"]),
            savedProfileIDs: strings(details?["saved_profile_ids"])
        )
    }

    private static func strings(_ value: Any?) -> [String] {
        guard let values = value as? [Any] else { return [] }
        return values.compactMap { trimmed($0 as? String) }
    }

    private static func trimmed(_ value: String?) -> String? {
        value?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
    }
}
