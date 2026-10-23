import Foundation

enum ProfileV3GloveBoxCopy {
    static let title = "Glove box"
    static let about = "Follow up, reply, and coordinate with hotels and airlines. Your real inbox stays private."
    static let forwarding = "Emails forwarded to"
    static let waitingToConfirm = "Waiting for you to confirm"
    static let pause = "Pause"
    static let resume = "Resume"
    static let sendLink = "Send link"
    static let active = "Active"
    static let paused = "Paused"
    static let viewAll = "View all"
    static let listTitle = "Glove box  ·  Email"
    static let activateTitle = "Activate your Glove box"
    static let activateSubtitle = "A travel email that works for you. Your real one stays private."
    static let activateButton = "Activate"
    static let tryAgain = "Try again"
    static let unavailable = "Glove box couldn't be opened."
    static let oldAddress = "Sent to an old address"
    static let processing = "Processing"
    static let stored = "Stored"
    static let failed = "Couldn't forward"
    static let phoneTitle = "Phone number"
    static let phoneAbout = "Agent answers every call, day or night. It handles the simple ones and puts urgent ones through to you."
    static let phoneHeadlineLead = "You get a "
    static let phoneHeadlineEmphasis = "new number"
    static let phoneHeadlineTrail = " every time you travel"
    static let phoneListTitle = "Glove box  ·  Calls"
    static let cardTitle = "Virtual card"
    static let cardProtected = "Card details are protected"
    static let cardPayTitle = "How you pay"
    static let cardPayBody = "When the assistant books or buys for you. Change it anytime."
    static let cardEmptyTitle = "No transactions yet..."
    static let cardEmptyBody = "Once your agent starts handling your travel, confirmations and updates will land here."
    static let cardListTitle = "Glove box  ·  Transactions"
    static let cardAdd = "Add card"
    static let cardSecure = "Your card details are securely stored and used only when needed to manage your bookings."
}

enum ProfileV3GloveBoxMapper {
    static let pageSize = 20

    static func account(_ dto: ProfileV3GloveBoxCardDTO) -> ProfileV3GloveBoxAccount {
        ProfileV3GloveBoxAccount(
            address: text(dto.address),
            previousAddresses: dto.previousAddresses ?? [],
            forwardingEmail: text(dto.forwarding?.email),
            forwardingPaused: dto.forwarding?.paused == true,
            pendingEmail: text(dto.forwardingPending?.email),
            eligible: dto.eligible != false
        )
    }

    static func page(_ dto: ProfileV3GloveBoxMessagesDTO) -> ProfileV3GloveBoxInboxPage {
        ProfileV3GloveBoxInboxPage(
            emails: dto.items.map(email),
            nextCursor: text(dto.nextCursor)
        )
    }

    static func email(_ dto: ProfileV3GloveBoxMessageItemDTO) -> ProfileV3GloveBoxEmail {
        let received = dto.receivedAt.flatMap(date)
        return ProfileV3GloveBoxEmail(
            id: dto.id,
            sender: text(dto.fromName) ?? text(dto.senderDomain) ?? "",
            summary: text(dto.subject) ?? "",
            attention: dto.status == "failed" ? ProfileV3GloveBoxCopy.failed : nil,
            meta: meta(previousAddress: dto.toPreviousAddress == true, received: received),
            badge: badge(for: dto.status)
        )
    }

    static func detail(_ dto: ProfileV3GloveBoxMessageDTO, listItem: ProfileV3GloveBoxEmail) -> ProfileV3GloveBoxEmail {
        ProfileV3GloveBoxEmail(
            id: listItem.id,
            sender: text(dto.fromName) ?? listItem.sender,
            summary: text(dto.subject) ?? listItem.summary,
            logoURL: listItem.logoURL,
            attention: dto.status == "failed" ? ProfileV3GloveBoxCopy.failed : nil,
            meta: listItem.meta ?? meta(previousAddress: dto.toPreviousAddress == true, received: dto.receivedAt.flatMap(date)),
            badge: badge(for: dto.status),
            note: note(text: dto.text, html: dto.html),
            attachments: (dto.attachments ?? []).enumerated().compactMap { offset, attachment in
                guard let filename = cleaned(attachment.filename) else { return nil }
                return ProfileV3GloveBoxAttachment(
                    index: attachmentIndex(attachment.url, fallback: offset),
                    filename: filename,
                    contentType: cleaned(attachment.contentType) ?? "application/octet-stream"
                )
            },
            followUpTitle: listItem.followUpTitle
        )
    }

    static func section(
        account: ProfileV3GloveBoxAccount,
        emails: [ProfileV3GloveBoxEmail],
        hasMore: Bool
    ) -> ProfileV3GloveBoxEmailSection {
        let forwarding = forwardingLine(account)
        return ProfileV3GloveBoxEmailSection(
            title: "Email",
            badge: ProfileV3GloveBoxBadge(
                label: account.forwardingPaused ? ProfileV3GloveBoxCopy.paused : ProfileV3GloveBoxCopy.active,
                tone: account.forwardingPaused ? .pending : .live
            ),
            address: account.address ?? "",
            about: ProfileV3GloveBoxCopy.about,
            forwardingLabel: forwarding.label,
            forwardingAddress: forwarding.address,
            forwardingPaused: account.forwardingPaused,
            canPauseForwarding: account.forwardingEmail != nil,
            canSetForwardingAddress: account.forwardingEmail == nil,
            emails: emails,
            viewAllTitle: emails.count > 3 || hasMore ? ProfileV3GloveBoxCopy.viewAll : nil,
            listTitle: ProfileV3GloveBoxCopy.listTitle
        )
    }

    static func home(email: ProfileV3GloveBoxEmailSection) -> ProfileV3GloveBoxHome {
        ProfileV3GloveBoxHome(email: email, phone: phone, card: card)
    }

    static func message(for error: Error) -> String {
        let raw = ProfileV3Error.message(for: error, fallback: ProfileV3GloveBoxCopy.unavailable)
        switch raw {
        case "unauthenticated", "invalid_token":
            return "Sign in again to open Glove box."
        case "account_required":
            return "Glove box needs an Atlys account."
        case "no_address":
            return "Set up your Glove box email first."
        case "invalid_email":
            return "That email address can't be used."
        case "forwarding_exists":
            return "Forwarding is already on."
        case "rate_limited":
            return "Too many tries. Wait and try again."
        case "email_not_sent":
            return "The confirmation email didn't send. Try again."
        case "not_found":
            return "That email isn't available."
        case "invalid_request":
            return ProfileV3Strings.somethingWentWrong
        default:
            return raw
        }
    }

    private static func forwardingLine(_ account: ProfileV3GloveBoxAccount) -> (label: String, address: String?) {
        if let email = account.forwardingEmail {
            return (ProfileV3GloveBoxCopy.forwarding, email)
        }
        if let pending = account.pendingEmail {
            return (ProfileV3GloveBoxCopy.waitingToConfirm, pending)
        }
        return ("", nil)
    }

    private static func meta(previousAddress: Bool, received: Date?) -> ProfileV3GloveBoxMeta? {
        let dateLabel = received.map(label)
        guard previousAddress || dateLabel != nil else { return nil }
        return ProfileV3GloveBoxMeta(
            glyphs: previousAddress ? [.mail] : [],
            label: previousAddress ? ProfileV3GloveBoxCopy.oldAddress : "",
            dateLabel: dateLabel
        )
    }

    private static func badge(for status: String?) -> String? {
        switch status {
        case "processing": return ProfileV3GloveBoxCopy.processing
        case "paused": return ProfileV3GloveBoxCopy.paused
        case "stored": return ProfileV3GloveBoxCopy.stored
        case "failed": return ProfileV3GloveBoxCopy.failed
        default: return nil
        }
    }

    private static func note(text: String?, html: String?) -> String? {
        cleaned(text) ?? html.flatMap { cleaned(plain($0)) }
    }

    private static func attachmentIndex(_ url: String?, fallback: Int) -> Int {
        guard let last = url?.split(separator: "/").last, let index = Int(last) else { return fallback }
        return index
    }

    private static func cleaned(_ raw: String?) -> String? {
        raw?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
    }

    private static func plain(_ html: String) -> String {
        var text = html.replacingOccurrences(of: "(?i)<br\\s*/?>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "(?i)</p>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func text(_ raw: String?) -> String? {
        raw?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
    }

    private static func date(_ raw: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: raw) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: raw)
    }

    private static func label(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "d MMM, yyyy"
        return formatter.string(from: date)
    }

    private static let phone = ProfileV3GloveBoxPhoneSection(
        title: ProfileV3GloveBoxCopy.phoneTitle,
        badge: ProfileV3GloveBoxBadge(label: "Active on trip", tone: .pending),
        number: ProfileV3GloveBoxNumber(value: "+1 847-757-XXXX"),
        headline: ProfileV3GloveBoxPhoneSection.Headline(
            lead: ProfileV3GloveBoxCopy.phoneHeadlineLead,
            emphasis: ProfileV3GloveBoxCopy.phoneHeadlineEmphasis,
            trail: ProfileV3GloveBoxCopy.phoneHeadlineTrail
        ),
        about: ProfileV3GloveBoxCopy.phoneAbout,
        calls: [],
        listTitle: ProfileV3GloveBoxCopy.phoneListTitle
    )

    private static let card = ProfileV3GloveBoxCardSection(
        title: ProfileV3GloveBoxCopy.cardTitle,
        card: ProfileV3GloveBoxCardSection.Card(
            lastFour: "",
            holder: "",
            expiryLabel: "Expires",
            cvcLabel: "CVC",
            nameLabel: "Name"
        ),
        protectedNotice: ProfileV3GloveBoxCopy.cardProtected,
        stats: [],
        facts: [],
        payTitle: ProfileV3GloveBoxCopy.cardPayTitle,
        payBody: ProfileV3GloveBoxCopy.cardPayBody,
        payOptions: [],
        addCardTitle: ProfileV3GloveBoxCopy.cardAdd,
        secureNote: ProfileV3GloveBoxCopy.cardSecure,
        transactions: [],
        emptyTitle: ProfileV3GloveBoxCopy.cardEmptyTitle,
        emptyBody: ProfileV3GloveBoxCopy.cardEmptyBody,
        listTitle: ProfileV3GloveBoxCopy.cardListTitle
    )
}
