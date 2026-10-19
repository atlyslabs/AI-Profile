import Foundation

struct ProfileV3VaultCredential: Identifiable, Equatable, Sendable {
    let id: String
    var displayName: String
    var url: String?
    var status: ProfileV3VaultStatus
    var attentionReason: String?
    var usernameHint: String?
    var username: String?
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
}

struct ProfileV3VaultDraft: Equatable, Sendable {
    var siteSlug: String?
    var label: String?
    var url: String?
    var username: String?
    var password: String?

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
    static let addLogin = "Add a login"
    static let updateLogin = "Update login"
    static let somewhereElse = "Somewhere else"
    static let siteName = "Name"
    static let verifying = "Verifying…"
    static let verified = "Verified"
    static let needsAttention = "Needs attention"
    static let paused = "Paused"
    static let stillVerifying = "Still verifying"
    static let wrongPassword = "Wrong username or password. Update it."
    static let otpUnsupported = "This site asks for a one-time code. Not supported yet."
    static let siteUnreachable = "Couldn't reach the site. Try again later."
    static let retry = "Retry"
    static let deleteLogin = "Delete login"
    static let deleteLoginConfirm = "Delete this login? This can't be undone."
    static let delete = "Delete"
    static let pause = "Pause"
    static let resume = "Resume"
    static let showPassword = "Show password"
    static let passwordHidden = "••••••••"
    static let copyPassword = "Copy"
    static let copied = "Copied"
    static let confirmItsYou = "Confirm it's you, then try again."
    static let revealNeedsPhone = "Showing a password needs Face ID on an iPhone."
    static let emptyTitle = "No saved logins"
    static let emptyBody = "Add a website login and Atlys will check that it works."
    static let website = "Website"
    static let username = "Username"
}

extension ProfileV3VaultStatus {
    func badge(attention: String?, timedOut: Bool) -> String {
        if isChecking, timedOut { return ProfileV3VaultStrings.stillVerifying }
        switch self {
        case .added, .inUse: return ProfileV3VaultStrings.verifying
        case .live: return ProfileV3VaultStrings.verified
        case .needsAttention: return ProfileV3VaultStrings.needsAttention
        case .paused: return ProfileV3VaultStrings.paused
        case .revoked: return ProfileV3VaultStrings.needsAttention
        }
    }
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

enum ProfileV3VaultParsing {
    static func existingID(in message: String?) -> String? {
        guard let message, let range = message.range(of: "credential ") else { return nil }
        let tail = message[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
        let token = tail.prefix { $0 != " " && $0 != "." && $0 != "," }
        let id = String(token)
        return id.count >= 32 ? id : nil
    }

    static func date(_ value: String?) -> Date? {
        guard let value else { return nil }
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: value) { return date }
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: value)
    }
}
