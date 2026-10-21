#if DEBUG
import Foundation

enum ProfileV3GloveBoxFixtures {
    enum Start: String, CaseIterable, Identifiable {
        case unlock
        case activateAfterKYC
        case activateNow
        case inbox
        case emptyInbox

        var id: String { rawValue }

        var title: String {
            switch self {
            case .unlock: return "Unlock"
            case .activateAfterKYC: return "Activate, KYC pending"
            case .activateNow: return "Activate now"
            case .inbox: return "Inbox"
            case .emptyInbox: return "Empty inbox"
            }
        }

        var detail: String {
            switch self {
            case .unlock: return "Complete KYC to unlock the travel inbox"
            case .activateAfterKYC: return "Activate the address, KYC still to do"
            case .activateNow: return "KYC done, address ready to activate"
            case .inbox: return "Active address with recent emails"
            case .emptyInbox: return "Active address, nothing received yet"
            }
        }

        var gloveBox: ProfileV3GloveBox {
            ProfileV3GloveBox(title: ProfileV3GloveBoxFixtures.gloveBoxTitle, stage: stage)
        }

        private var stage: ProfileV3GloveBox.Stage {
            switch self {
            case .unlock: return .intro(ProfileV3GloveBoxFixtures.unlock)
            case .activateAfterKYC: return .intro(ProfileV3GloveBoxFixtures.activateAfterKYC)
            case .activateNow: return .intro(ProfileV3GloveBoxFixtures.activateNow)
            case .inbox: return .inbox(ProfileV3GloveBoxFixtures.inbox)
            case .emptyInbox: return .inbox(ProfileV3GloveBoxFixtures.emptyInbox)
            }
        }
    }

    static let gloveBoxTitle = "Glove box"

    private static let subtitle = "An alternate email, that works for you, so your real ones stay private."

    static let unlock = ProfileV3GloveBoxIntro(
        title: "Your travel inbox is ready to unlock",
        subtitle: subtitle,
        actionTitle: "Complete KYC",
        action: .completeKYC
    )

    static let activateAfterKYC = ProfileV3GloveBoxIntro(
        title: "Activate your email address",
        subtitle: subtitle,
        actionTitle: "Complete KYC",
        action: .completeKYC
    )

    static let activateNow = ProfileV3GloveBoxIntro(
        title: "Activate your email address",
        subtitle: subtitle,
        actionTitle: "Activate now",
        action: .activate
    )

    static let emails = [
        ProfileV3GloveBoxEmail(
            id: "emirates",
            sender: "Emirates",
            summary: "Your flight on 12 Oct now leaves 40 min later",
            logoURL: URL(string: "https://media.atlys.com/b2c/ai-native/loyalty/flights/emirates_skywards.png"),
            glyphs: [.mail, .seen],
            statusLabel: "change caught",
            dateLabel: "25 Jun, 2026",
            badge: "Changed",
            note: "I found a better seat at the same price and upgraded you.\n"
                + "The seat was available, so I grabbed it before it was gone — no extra cost.",
            followUpTitle: "Tell me more"
        ),
        ProfileV3GloveBoxEmail(
            id: "marriott",
            sender: "Marriot Dubai",
            summary: "free upgrade available",
            logoURL: URL(string: "https://media.atlys.com/b2c/ai-native/loyalty/hotels/marriott_bonvoy.png"),
            statusLabel: "Needs attention",
            needsAttention: true,
            note: "Your stay qualifies for a free room upgrade. Want me to accept it?",
            followUpTitle: "Tell me more"
        ),
        ProfileV3GloveBoxEmail(
            id: "vfs",
            sender: "VFS Global",
            summary: "Booking confirmed for 12 to 16 Oct",
            glyphs: [.calendar, .done],
            statusLabel: "Calendar updated",
            dateLabel: "25 Jun, 2026",
            note: "Your appointment is confirmed and I've added it to your calendar.",
            followUpTitle: "Tell me more"
        )
    ]

    static let inbox = ProfileV3GloveBoxInbox(
        address: "mohakn@trips.atlys.com",
        about: "Ayl follows up, replies, negotiates, and coordinates with hotels, airlines and more, "
            + "while you stay out of the thread.",
        forwardingLabel: "Emails forwarded to",
        forwardingAddress: "mohak.n@gmail.com",
        recentTitle: "Recent emails",
        emails: emails,
        emptyTitle: "Nothing in the Glovebox yet",
        emptyBody: "Once your agent starts handling your travel, confirmations and updates will land here."
    )

    static let emptyInbox = ProfileV3GloveBoxInbox(
        address: inbox.address,
        about: inbox.about,
        forwardingLabel: inbox.forwardingLabel,
        forwardingAddress: inbox.forwardingAddress,
        recentTitle: inbox.recentTitle,
        emails: [],
        emptyTitle: inbox.emptyTitle,
        emptyBody: inbox.emptyBody
    )
}
#endif
