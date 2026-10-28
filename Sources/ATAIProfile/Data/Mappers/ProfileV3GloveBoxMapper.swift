import Foundation
import os

enum ProfileV3GloveBoxCopy {
    static var title: String { ProfileV3L10n.moAiprofileGloveboxTitleGloveBox }
    static var settingsSubtitle: String { ProfileV3L10n.moAiprofileGloveboxLabelVirtualEmail }
    static var settingsDescription: String { ProfileV3L10n.moAiprofileGloveboxDescriptionSettingsCard }
    static var emailTitle: String { ProfileV3L10n.moAiprofileGloveboxTitleEmail }
    static var about: String { ProfileV3L10n.moAiprofileGloveboxDescriptionEmailAbout }
    static var forwarding: String { ProfileV3L10n.moAiprofileGloveboxLabelEmailsForwardedTo }
    static var waitingToConfirm: String { ProfileV3L10n.moAiprofileGloveboxLabelWaitingToConfirm }
    static var pause: String { ProfileV3L10n.moAiprofileGloveboxButtonPause }
    static var resume: String { ProfileV3L10n.moAiprofileGloveboxButtonResume }
    static var sendLink: String { ProfileV3L10n.moAiprofileGloveboxButtonSendLink }
    static var active: String { ProfileV3L10n.moAiprofileGloveboxBadgeActive }
    static var paused: String { ProfileV3L10n.moAiprofileGloveboxBadgePaused }
    static var viewAll: String { ProfileV3L10n.moAiprofileGloveboxButtonViewAll }
    static var listTitle: String { ProfileV3L10n.moAiprofileGloveboxTitleEmailList }
    static var activateTitle: String { ProfileV3L10n.moAiprofileGloveboxTitleActivate }
    static var activateSubtitle: String { ProfileV3L10n.moAiprofileGloveboxDescriptionActivate }
    static var activateButton: String { ProfileV3Strings.activate }
    static var unlockTitle: String { ProfileV3L10n.moAiprofileGloveboxTitleUnlock }
    static var unlockSubtitle: String { ProfileV3L10n.moAiprofileGloveboxDescriptionUnlock }
    static var completeKYC: String { ProfileV3L10n.moAiprofileGloveboxButtonCompleteKyc }
    static var tryAgain: String { ProfileV3L10n.moAiprofileGeneralButtonTryAgain }
    static var unavailable: String { ProfileV3L10n.moAiprofileGloveboxErrorUnavailable }
    static var signInAgain: String { ProfileV3L10n.moAiprofileGloveboxErrorSignInAgain }
    static var accountRequired: String { ProfileV3L10n.moAiprofileGloveboxErrorAccountRequired }
    static var noAddress: String { ProfileV3L10n.moAiprofileGloveboxErrorNoAddress }
    static var invalidEmail: String { ProfileV3L10n.moAiprofileGloveboxErrorInvalidEmail }
    static var forwardingExists: String { ProfileV3L10n.moAiprofileGloveboxErrorForwardingExists }
    static var rateLimited: String { ProfileV3L10n.moAiprofileGloveboxErrorRateLimited }
    static var emailNotSent: String { ProfileV3L10n.moAiprofileGloveboxErrorEmailNotSent }
    static var emailNotFound: String { ProfileV3L10n.moAiprofileGloveboxErrorNotFound }
    static var oldAddress: String { ProfileV3L10n.moAiprofileGloveboxStatusSentToOldAddress }
    static var sentToInbox: String { ProfileV3L10n.moAiprofileGloveboxStatusSentToInbox }
    static var handledForYou: String { ProfileV3L10n.moAiprofileGloveboxStatusHandledForYou }
    static var inTheThread: String { ProfileV3L10n.moAiprofileGloveboxStatusInTheThread }
    static var needsAttention: String { ProfileV3L10n.moAiprofileAccountStatusNeedsAttention }
    static var notForwardedPaused: String { ProfileV3L10n.moAiprofileGloveboxNoticeForwardingPaused }
    static var notForwardedPending: String { ProfileV3L10n.moAiprofileGloveboxNoticeForwardingPending }
    static var notForwardedNoAddress: String { ProfileV3L10n.moAiprofileGloveboxNoticeForwardingMissing }
    static var phoneTitle: String { ProfileV3L10n.moAiprofileGloveboxTitlePhoneNumber }
    static var phoneBadge: String { ProfileV3L10n.moAiprofileGloveboxBadgeActiveOnTrip }
    static var phoneAbout: String { ProfileV3L10n.moAiprofileGloveboxDescriptionPhoneAbout }
    static var phoneHeadlineLead: String { ProfileV3L10n.moAiprofileGloveboxHeadlineNewNumberLead + " " }
    static var phoneHeadlineEmphasis: String { ProfileV3L10n.moAiprofileGloveboxHeadlineNewNumberEmphasis }
    static var phoneHeadlineTrail: String { " " + ProfileV3L10n.moAiprofileGloveboxHeadlineNewNumberTrail }
    static var phoneListTitle: String { ProfileV3L10n.moAiprofileGloveboxTitleCallsList }
    static var cardTitle: String { ProfileV3L10n.moAiprofileGloveboxTitleVirtualCard }
    static var cardProtected: String { ProfileV3L10n.moAiprofileGloveboxNoticeCardProtected }
    static var cardExpires: String { ProfileV3L10n.moAiprofileGloveboxLabelCardExpires }
    static var cardCVC: String { ProfileV3L10n.moAiprofileGloveboxLabelCardCvc }
    static var cardName: String { ProfileV3L10n.moAiprofileGloveboxLabelCardName }
    static var cardPayTitle: String { ProfileV3L10n.moAiprofileGloveboxTitleHowYouPay }
    static var cardPayBody: String { ProfileV3L10n.moAiprofileGloveboxDescriptionHowYouPay }
    static var cardEmptyTitle: String { ProfileV3L10n.moAiprofileGloveboxEmptyStateNoTransactions }
    static var cardEmptyBody: String { ProfileV3L10n.moAiprofileGloveboxEmptyStateNoTransactionsBody }
    static var cardListTitle: String { ProfileV3L10n.moAiprofileGloveboxTitleTransactionsList }
    static var cardAdd: String { ProfileV3L10n.moAiprofileGloveboxButtonAddCard }
    static var cardSecure: String { ProfileV3L10n.moAiprofileGloveboxNoticeCardSecure }
    static var sample: String { ProfileV3L10n.moAiprofileGloveboxLabelSample }
    static var changed: String { ProfileV3L10n.moAiprofileGloveboxBadgeChanged }
}

enum ProfileV3GloveBoxSamples {
    private static let emiratesLogo = URL(string: "https://media.atlys.com/b2c/ai-native/loyalty/flights/emirates_skywards.png")
    private static let marriottLogo = URL(string: "https://media.atlys.com/b2c/ai-native/loyalty/hotels/marriott_bonvoy.png")

    static var emails: [ProfileV3GloveBoxEmail] {
        [
            ProfileV3GloveBoxEmail(
                id: "sample-email-flight",
                sender: ProfileV3L10n.moAiprofileGloveboxSampleEmailFlightSender,
                summary: ProfileV3L10n.moAiprofileGloveboxSampleEmailFlightSubject,
                logoURL: emiratesLogo,
                meta: ProfileV3GloveBoxMeta(glyphs: [.mail, .seen], label: ProfileV3L10n.moAiprofileGloveboxSampleEmailFlightStatus),
                badge: ProfileV3GloveBoxCopy.changed,
                note: ProfileV3L10n.moAiprofileGloveboxSampleEmailFlightNote
            ),
            ProfileV3GloveBoxEmail(
                id: "sample-email-hotel",
                sender: ProfileV3L10n.moAiprofileGloveboxSampleEmailHotelSender,
                summary: ProfileV3L10n.moAiprofileGloveboxSampleEmailHotelSubject,
                logoURL: marriottLogo,
                attention: ProfileV3GloveBoxEmail.Attention(title: ProfileV3GloveBoxCopy.needsAttention),
                meta: ProfileV3GloveBoxMeta(glyphs: [.done], label: ProfileV3L10n.moAiprofileGloveboxSampleEmailHotelStatus),
                note: ProfileV3L10n.moAiprofileGloveboxSampleEmailHotelNote
            )
        ]
    }

    static var calls: [ProfileV3GloveBoxCall] {
        [
            ProfileV3GloveBoxCall(
                id: "sample-call-hotel",
                title: ProfileV3L10n.moAiprofileGloveboxSampleCallTitle,
                summary: ProfileV3L10n.moAiprofileGloveboxSampleCallSummary,
                logoURL: marriottLogo,
                meta: ProfileV3GloveBoxMeta(glyphs: [.calendar, .done], label: ProfileV3L10n.moAiprofileGloveboxSampleCallStatus),
                recording: .audio(duration: "1:23", speed: "1x"),
                badge: ProfileV3GloveBoxCopy.changed,
                note: ProfileV3L10n.moAiprofileGloveboxSampleCallNote
            )
        ]
    }

    static var transactions: [ProfileV3GloveBoxTransaction] {
        [
            ProfileV3GloveBoxTransaction(
                id: "sample-transaction-dinner",
                title: ProfileV3L10n.moAiprofileGloveboxSampleTransactionTitle,
                summary: ProfileV3L10n.moAiprofileGloveboxSampleTransactionSummary,
                amount: "-$12.00",
                outcome: .approved,
                outcomeLabel: ProfileV3L10n.moAiprofileGloveboxSampleTransactionStatus,
                note: ProfileV3L10n.moAiprofileGloveboxSampleTransactionNote
            )
        ]
    }
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
        let status = delivery(dto.status)
        return ProfileV3GloveBoxEmail(
            id: dto.id,
            sender: text(dto.fromName) ?? text(dto.senderDomain) ?? "",
            summary: text(dto.subject) ?? "",
            logoURL: logoURL(dto.senderLogoURL),
            attention: attention(dto.attention),
            delivery: status,
            meta: meta(
                delivery: status,
                action: text(dto.action),
                previousAddress: dto.toPreviousAddress == true,
                received: dto.receivedAt.flatMap(date)
            )
        )
    }

    static func detail(_ dto: ProfileV3GloveBoxMessageDTO, listItem: ProfileV3GloveBoxEmail) -> ProfileV3GloveBoxEmail {
        let status = listItem.delivery ?? delivery(dto.status)
        return ProfileV3GloveBoxEmail(
            id: listItem.id,
            sender: text(dto.fromName) ?? listItem.sender,
            summary: text(dto.subject) ?? listItem.summary,
            logoURL: listItem.logoURL ?? logoURL(dto.senderLogoURL),
            attention: listItem.attention ?? attention(dto.attention),
            delivery: status,
            meta: listItem.meta ?? meta(
                delivery: status,
                action: text(dto.action),
                previousAddress: dto.toPreviousAddress == true,
                received: dto.receivedAt.flatMap(date)
            ),
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
        let isSample = emails.isEmpty && !hasMore
        return ProfileV3GloveBoxEmailSection(
            title: ProfileV3GloveBoxCopy.emailTitle,
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
            forwardingNotice: forwardingNotice(account: account, emails: emails),
            emails: isSample ? ProfileV3GloveBoxSamples.emails : emails,
            sampleLabel: isSample ? ProfileV3GloveBoxCopy.sample : nil,
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
            return ProfileV3GloveBoxCopy.signInAgain
        case "account_required":
            return ProfileV3GloveBoxCopy.accountRequired
        case "no_address":
            return ProfileV3GloveBoxCopy.noAddress
        case "invalid_email":
            return ProfileV3GloveBoxCopy.invalidEmail
        case "forwarding_exists":
            return ProfileV3GloveBoxCopy.forwardingExists
        case "rate_limited":
            return ProfileV3GloveBoxCopy.rateLimited
        case "email_not_sent":
            return ProfileV3GloveBoxCopy.emailNotSent
        case "not_found":
            return ProfileV3GloveBoxCopy.emailNotFound
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

    private static func forwardingNotice(account: ProfileV3GloveBoxAccount, emails: [ProfileV3GloveBoxEmail]) -> String? {
        guard emails.contains(where: { $0.delivery == .notForwarded }) else { return nil }
        if account.forwardingPaused { return ProfileV3GloveBoxCopy.notForwardedPaused }
        guard account.forwardingEmail == nil else { return nil }
        return account.pendingEmail == nil ? ProfileV3GloveBoxCopy.notForwardedNoAddress : ProfileV3GloveBoxCopy.notForwardedPending
    }

    private static func meta(
        delivery: ProfileV3GloveBoxEmail.Delivery?,
        action: String?,
        previousAddress: Bool,
        received: Date?
    ) -> ProfileV3GloveBoxMeta? {
        var glyphs: [ProfileV3GloveBoxGlyph] = []
        if let delivery, delivery != .notForwarded { glyphs.append(.tick) }
        if previousAddress { glyphs.append(.mail) }
        let title = action ?? (previousAddress ? ProfileV3GloveBoxCopy.oldAddress : deliveryLabel(delivery)) ?? ""
        let dateLabel = received.map(label)
        guard !glyphs.isEmpty || !title.isEmpty || dateLabel != nil else { return nil }
        return ProfileV3GloveBoxMeta(glyphs: glyphs, label: title, dateLabel: dateLabel)
    }

    private static func delivery(_ status: String?) -> ProfileV3GloveBoxEmail.Delivery? {
        switch status?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "forwarded": return .forwarded
        case "handled": return .handled
        case "added_to_thread": return .addedToThread
        case "not_forwarded": return .notForwarded
        default: return nil
        }
    }

    private static func deliveryLabel(_ delivery: ProfileV3GloveBoxEmail.Delivery?) -> String? {
        switch delivery {
        case .forwarded: return ProfileV3GloveBoxCopy.sentToInbox
        case .handled: return ProfileV3GloveBoxCopy.handledForYou
        case .addedToThread: return ProfileV3GloveBoxCopy.inTheThread
        case .notForwarded, nil: return nil
        }
    }

    private static func attention(_ dto: ProfileV3GloveBoxAttentionDTO?) -> ProfileV3GloveBoxEmail.Attention? {
        guard let dto else { return nil }
        let title = text(dto.title)
        let detail = text(dto.detail)
        guard title != nil || detail != nil || text(dto.type) != nil else { return nil }
        return ProfileV3GloveBoxEmail.Attention(title: title ?? ProfileV3GloveBoxCopy.needsAttention, detail: detail)
    }

    private static func logoURL(_ raw: String?) -> URL? {
        guard let raw = text(raw), let url = URL(string: raw),
              let scheme = url.scheme?.lowercased(), scheme == "https" || scheme == "http" else { return nil }
        return url
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
        fractionalParser.withLock { $0.date(from: raw) } ?? plainParser.withLock { $0.date(from: raw) }
    }

    private static func label(_ date: Date) -> String {
        labelFormatter.withLock { $0.string(from: date) }
    }

    private static let fractionalParser: OSAllocatedUnfairLock<ISO8601DateFormatter> = {
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return OSAllocatedUnfairLock(uncheckedState: parser)
    }()

    private static let plainParser: OSAllocatedUnfairLock<ISO8601DateFormatter> = {
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime]
        return OSAllocatedUnfairLock(uncheckedState: parser)
    }()

    private static let labelFormatter: OSAllocatedUnfairLock<DateFormatter> = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "d MMM, yyyy"
        return OSAllocatedUnfairLock(uncheckedState: formatter)
    }()

    private static var phone: ProfileV3GloveBoxPhoneSection {
        ProfileV3GloveBoxPhoneSection(
            title: ProfileV3GloveBoxCopy.phoneTitle,
            badge: ProfileV3GloveBoxBadge(label: ProfileV3GloveBoxCopy.phoneBadge, tone: .pending),
            number: ProfileV3GloveBoxNumber(value: "+1 847-757-XXXX"),
            headline: ProfileV3GloveBoxPhoneSection.Headline(
                lead: ProfileV3GloveBoxCopy.phoneHeadlineLead,
                emphasis: ProfileV3GloveBoxCopy.phoneHeadlineEmphasis,
                trail: ProfileV3GloveBoxCopy.phoneHeadlineTrail
            ),
            about: ProfileV3GloveBoxCopy.phoneAbout,
            calls: ProfileV3GloveBoxSamples.calls,
            sampleLabel: ProfileV3GloveBoxCopy.sample,
            listTitle: ProfileV3GloveBoxCopy.phoneListTitle
        )
    }

    private static var card: ProfileV3GloveBoxCardSection {
        ProfileV3GloveBoxCardSection(
            title: ProfileV3GloveBoxCopy.cardTitle,
            card: ProfileV3GloveBoxCardSection.Card(
                lastFour: "",
                holder: "",
                expiryLabel: ProfileV3GloveBoxCopy.cardExpires,
                cvcLabel: ProfileV3GloveBoxCopy.cardCVC,
                nameLabel: ProfileV3GloveBoxCopy.cardName
            ),
            protectedNotice: ProfileV3GloveBoxCopy.cardProtected,
            stats: [],
            facts: [],
            payTitle: ProfileV3GloveBoxCopy.cardPayTitle,
            payBody: ProfileV3GloveBoxCopy.cardPayBody,
            payOptions: [],
            addCardTitle: ProfileV3GloveBoxCopy.cardAdd,
            secureNote: ProfileV3GloveBoxCopy.cardSecure,
            transactions: ProfileV3GloveBoxSamples.transactions,
            sampleLabel: ProfileV3GloveBoxCopy.sample,
            emptyTitle: ProfileV3GloveBoxCopy.cardEmptyTitle,
            emptyBody: ProfileV3GloveBoxCopy.cardEmptyBody,
            listTitle: ProfileV3GloveBoxCopy.cardListTitle
        )
    }
}
