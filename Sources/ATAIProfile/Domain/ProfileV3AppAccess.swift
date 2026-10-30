import Foundation

struct ProfileV3AppAccess: Equatable, Sendable {
    var autoConnected: [ProfileV3AutoConnectedApp]
    var apps: [ProfileV3LinkedApp]

    var pending: [ProfileV3LinkedApp] { apps.filter { !$0.isConnected } }
    var connected: [ProfileV3LinkedApp] { apps.filter(\.isConnected) }

    func app(_ id: String) -> ProfileV3LinkedApp? {
        apps.first { $0.id == id }
    }
}

struct ProfileV3AutoConnectedApp: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let iconURL: URL?
}

struct ProfileV3LinkedApp: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let iconURL: URL?
    let blurb: String
    var username: String?
    var isConnected: Bool
    var asksForUsernameOnly = false
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
