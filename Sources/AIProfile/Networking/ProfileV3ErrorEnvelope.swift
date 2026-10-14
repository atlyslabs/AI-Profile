import Foundation

enum ProfileV3ErrorEnvelope {
    struct Parsed: Equatable, Sendable {
        let code: String?
        let message: String?
    }

    static func parse(_ data: Data) -> Parsed? {
        guard !data.isEmpty,
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        var code: String?
        var message: String?
        if let nested = object["error"] as? [String: Any] {
            code = trimmed(nested["code"] as? String)
            message = trimmed(nested["message"] as? String)
        } else if let flat = object["error"] as? String {
            message = trimmed(flat)
        }
        if message == nil { message = trimmed(object["message"] as? String) }
        if code == nil { code = trimmed(object["code"] as? String) }

        guard code != nil || message != nil else { return nil }
        return Parsed(code: code, message: message)
    }

    private static func trimmed(_ value: String?) -> String? {
        value?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
    }
}
