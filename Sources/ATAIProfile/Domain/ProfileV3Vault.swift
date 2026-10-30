import Foundation

struct ProfileV3VaultCredential: Identifiable, Equatable, Sendable {
    let id: String
    var displayName: String
    var url: String?
    var status: ProfileV3VaultStatus
    var attentionReason: String?
    var usernameHint: String?
    var username: String?

    var displayURL: String? {
        url.flatMap(ProfileV3VaultSite.displayAddress)
    }
}

enum ProfileV3VaultStatus: String, Equatable, Sendable {
    case added
    case inUse = "in_use"
    case live
    case needsAttention = "needs_attention"
    case paused
    case revoked

    var isChecking: Bool { self == .added || self == .inUse }

    init(raw: String?) {
        self = raw.flatMap(Self.init(rawValue:)) ?? .added
    }
}

enum ProfileV3VaultAttention: String, Equatable, Sendable {
    case passwordRejected = "password_rejected"
    case otpRequired = "otp_required"
    case loginError = "login_error"
}

struct ProfileV3VaultSite: Identifiable, Equatable, Sendable {
    var id: String { slug }
    let slug: String
    let displayName: String
    let loginURL: String?

    static func matching(_ url: URL, in sites: [ProfileV3VaultSite]) -> ProfileV3VaultSite? {
        guard let host = bareHost(url) else { return nil }
        return sites.first { site in
            guard let siteHost = site.loginURL.flatMap(URL.init(string:)).flatMap(bareHost) else { return false }
            return host == siteHost || host.hasSuffix("." + siteHost)
        }
    }

    static func bareHost(_ url: URL) -> String? {
        guard let host = url.host()?.lowercased().nonEmpty else { return nil }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    static func displayAddress(_ address: String) -> String? {
        var text = address.trimmingCharacters(in: .whitespacesAndNewlines)
        for scheme in ["https://", "http://"] where text.lowercased().hasPrefix(scheme) {
            text = String(text.dropFirst(scheme.count))
        }
        if text.lowercased().hasPrefix("www.") { text = String(text.dropFirst(4)) }
        while text.hasSuffix("/") { text = String(text.dropLast()) }
        return text.nonEmpty
    }
}

struct ProfileV3VaultDraft: Equatable, Sendable {
    var siteSlug: String?
    var label: String?
    var url: String?
    var username: String?
    var password: String?

    static func new(_ credentials: ProfileV3AppCredentials, sites: [ProfileV3VaultSite]) -> ProfileV3VaultDraft {
        guard let url = credentials.websiteURL else {
            return ProfileV3VaultDraft(username: credentials.username, password: credentials.password)
        }
        if let site = ProfileV3VaultSite.matching(url, in: sites) {
            return ProfileV3VaultDraft(siteSlug: site.slug, username: credentials.username, password: credentials.password)
        }
        return ProfileV3VaultDraft(
            label: ProfileV3VaultSite.bareHost(url),
            url: url.absoluteString,
            username: credentials.username,
            password: credentials.password
        )
    }

    func encoded() throws -> Data {
        try JSONEncoder().encode(Payload(draft: self))
    }

    private struct Payload: Encodable {
        let siteSlug: String?
        let label: String?
        let url: String?
        let username: String?
        let password: String?

        init(draft: ProfileV3VaultDraft) {
            siteSlug = draft.siteSlug?.nonEmpty
            label = draft.label?.nonEmpty
            url = draft.url?.nonEmpty
            username = draft.username?.nonEmpty
            password = draft.password
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(siteSlug, forKey: .siteSlug)
            try container.encodeIfPresent(label, forKey: .label)
            try container.encodeIfPresent(url, forKey: .url)
            try container.encodeIfPresent(username, forKey: .username)
            try container.encodeIfPresent(password, forKey: .password)
        }

        enum CodingKeys: String, CodingKey {
            case siteSlug = "site_slug"
            case label
            case url
            case username
            case password
        }
    }
}

struct ProfileV3VaultWriteResult: Equatable, Sendable {
    let id: String
    let status: ProfileV3VaultStatus
}

struct ProfileV3VaultAlreadySaved: Error, Equatable {
    let id: String
    let message: String
}

enum ProfileV3VaultStrings {
    static var wrongPassword: String { ProfileV3L10n.moAiprofileAgentsErrorVaultWrongPassword }
    static var otpUnsupported: String { ProfileV3L10n.moAiprofileAgentsErrorVaultOtpUnsupported }
    static var siteUnreachable: String { ProfileV3L10n.moAiprofileAgentsErrorVaultSiteUnreachable }
    static var showPassword: String { ProfileV3L10n.moAiprofileAgentsPromptFaceIdShowPassword }
    static var unlockVault: String { ProfileV3L10n.moAiprofileAgentsPromptFaceIdUnlockVault }
    static let passwordHidden = "••••••••"
    static var confirmItsYou: String { ProfileV3L10n.moAiprofileAgentsErrorVaultConfirmItsYou }
    static var revealNeedsPhone: String { ProfileV3L10n.moAiprofileAgentsErrorVaultRevealNeedsPhone }
}

extension ProfileV3VaultAttention {
    var message: String {
        switch self {
        case .passwordRejected: return ProfileV3VaultStrings.wrongPassword
        case .otpRequired: return ProfileV3VaultStrings.otpUnsupported
        case .loginError: return ProfileV3VaultStrings.siteUnreachable
        }
    }
}

enum ProfileV3VaultUnlock: Equatable, Sendable {
    case unlocked
    case cancelled
}

enum ProfileV3VaultParsing {
    static func existingID(in message: String?) -> String? {
        guard let message, let range = message.range(of: "credential ") else { return nil }
        let tail = message[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
        let token = tail.prefix { $0 != " " && $0 != "." && $0 != "," }
        let id = String(token)
        return id.count >= 32 ? id : nil
    }
}
