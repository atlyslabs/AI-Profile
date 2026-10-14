import Foundation

protocol ProfileV3DTOReading {}

extension ProfileV3DTOReading {
    static func text(_ raw: String?) -> String? {
        guard let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else { return nil }
        return trimmed
    }

    static func fraction(_ scalar: ProfileV3ScalarDTO?) -> Double {
        guard let value = scalar?.doubleValue else { return 0 }
        return min(max(value > 1 ? value / 100 : value, 0), 1)
    }

    static func remoteURL(_ raw: String?) -> URL? {
        guard let text = text(raw) else { return nil }
        let cleaned = text
            .replacingOccurrences(of: "\\/", with: "/")
            .replacingOccurrences(of: "\\", with: "/")
        if let url = URL(string: cleaned), isRemote(url) { return url }
        if cleaned.hasPrefix("//"), let url = URL(string: "https:\(cleaned)"), isRemote(url) { return url }
        return nil
    }

    private static func isRemote(_ url: URL) -> Bool {
        let scheme = url.scheme?.lowercased()
        return (scheme == "http" || scheme == "https") && !(url.host ?? "").isEmpty
    }
}
