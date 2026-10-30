import Foundation

struct ProfileV3AppAccess: Equatable, Sendable {
    var autoConnected: [ProfileV3AutoConnectedApp]
    var apps: [ProfileV3LinkedApp]

    var pending: [ProfileV3LinkedApp] { apps.filter { !$0.isConnected } }
    var connected: [ProfileV3LinkedApp] { apps.filter(\.isConnected) }

    func app(_ id: String) -> ProfileV3LinkedApp? {
        apps.first { $0.id == id }
    }

    func applying(_ instagram: ProfileV3InstagramAccount) -> ProfileV3AppAccess {
        var content = self
        if let index = content.apps.firstIndex(where: \.isInstagram) {
            content.apps[index].username = instagram.username
            content.apps[index].isConnected = instagram.isConnected
        }
        return content
    }
}

struct ProfileV3AutoConnectedApp: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let iconURL: URL?
}

struct ProfileV3LinkedApp: Identifiable, Equatable, Sendable {
    static let instagramID = "instagram"

    let id: String
    let name: String
    let iconURL: URL?
    let blurb: String
    var username: String?
    var isConnected: Bool
    var asksForUsernameOnly = false
    var canDisconnect = true

    var isInstagram: Bool { id == Self.instagramID }
    var isAwaitingMessage: Bool { isInstagram && username != nil && !isConnected }

    static var instagram: ProfileV3LinkedApp {
        ProfileV3LinkedApp(
            id: instagramID,
            name: "Instagram",
            iconURL: ProfileV3AppLogos.instagram,
            blurb: ProfileV3Strings.instagramBlurb,
            username: nil,
            isConnected: false,
            asksForUsernameOnly: true,
            canDisconnect: false
        )
    }
}

struct ProfileV3InstagramAccount: Equatable, Sendable {
    static let unlinked = ProfileV3InstagramAccount(username: nil, hasMessaged: false)

    var username: String?
    var hasMessaged: Bool

    var isConnected: Bool { username != nil && hasMessaged }
}

enum ProfileV3InstagramUsername {
    static let maxLength = 30
    static let messageURL = URL(string: "https://ig.me/m/ayl.chat")!

    private static let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789._")

    static func normalised(_ text: String) -> String {
        String(text.trimmingCharacters(in: .whitespacesAndNewlines).drop { $0 == "@" })
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    static func isValid(_ username: String) -> Bool {
        (1 ... maxLength).contains(username.count) && username.allSatisfy(allowed.contains)
    }

    static func errorMessage(for error: Error) -> String {
        if case .invalidRequest(message: nil)? = error as? ProfileV3Error {
            return ProfileV3Strings.instagramUsernameInvalid
        }
        return ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed)
    }
}

struct ProfileV3AppCredentials: Equatable, Sendable {
    var website = ""
    var username = ""
    var password = ""

    var trimmed: ProfileV3AppCredentials {
        ProfileV3AppCredentials(
            website: website.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )
    }

    var websiteURL: URL? {
        let text = website.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !text.contains(" ") else { return nil }
        let candidate = text.contains("://") ? text : "https://\(text)"
        guard let url = URL(string: candidate), let host = url.host(), host.contains(".") else { return nil }
        return url
    }
}
