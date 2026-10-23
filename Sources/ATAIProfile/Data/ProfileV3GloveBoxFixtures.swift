#if DEBUG
import Foundation

enum ProfileV3GloveBoxFixtures {
    enum Start: String, CaseIterable, Identifiable {
        case unlock
        case warmingUp
        case home
        case homeSample

        var id: String { rawValue }

        var title: String {
            switch self {
            case .unlock: return "Unlock"
            case .warmingUp: return "Warming up"
            case .home: return "Active"
            case .homeSample: return "Active, nothing yet"
            }
        }

        var detail: String {
            switch self {
            case .unlock: return "Complete KYC to unlock the email, number and card"
            case .warmingUp: return "KYC done, the glove box is getting ready"
            case .home: return "Email, number and card with recent activity"
            case .homeSample: return "Number waits for a trip, sample activity shown"
            }
        }

        var gloveBox: ProfileV3GloveBox {
            ProfileV3GloveBox(title: ProfileV3GloveBoxFixtures.title, stage: stage)
        }

        private var stage: ProfileV3GloveBox.Stage {
            switch self {
            case .unlock: return .intro(ProfileV3GloveBoxFixtures.unlock)
            case .warmingUp: return .intro(ProfileV3GloveBoxFixtures.warmingUp)
            case .home: return .home(ProfileV3GloveBoxFixtures.home)
            case .homeSample: return .home(ProfileV3GloveBoxFixtures.sampleHome)
            }
        }
    }

    static let title = "Glove box"

    private static let subtitle = "A travel email, number and card that work for you. Your real ones stay private."
    private static let note = "I found a better seat at the same price and upgraded you.\n"
        + "The seat was available, so I grabbed it before it was gone — no extra cost."
    private static let followUp = "Tell me more"
    private static let dated = "25 Jun, 2026"
    private static let viewAll = "View all"
    private static let sample = "Sample"
    private static let active = ProfileV3GloveBoxBadge(label: "Active", tone: .live)
    private static let emiratesLogo = URL(string: "https://media.atlys.com/b2c/ai-native/loyalty/flights/emirates_skywards.png")
    private static let marriottLogo = URL(string: "https://media.atlys.com/b2c/ai-native/loyalty/hotels/marriott_bonvoy.png")
    private static let calendarUpdated = ProfileV3GloveBoxMeta(glyphs: [.calendar, .done], label: "Calendar updated", dateLabel: dated)

    static let unlock = ProfileV3GloveBoxIntro(
        title: "Your Glove box is ready to unlock",
        subtitle: subtitle,
        status: .locked,
        statusLabel: "Activate",
        actionTitle: "Complete KYC",
        action: .completeKYC
    )

    static let warmingUp = ProfileV3GloveBoxIntro(
        title: "Activate your Glove box",
        subtitle: subtitle,
        status: .warmingUp,
        statusLabel: "Warming up",
        actionTitle: "Complete KYC",
        action: .activate
    )

    static let emails = [
        ProfileV3GloveBoxEmail(
            id: "emirates",
            sender: "Emirates",
            summary: "Your flight on 12 Oct now leaves 40 min later",
            logoURL: emiratesLogo,
            meta: ProfileV3GloveBoxMeta(glyphs: [.mail, .seen], label: "change caught", dateLabel: dated),
            badge: "Changed",
            note: note,
            followUpTitle: followUp
        ),
        ProfileV3GloveBoxEmail(
            id: "marriott",
            sender: "Marriot Dubai",
            summary: "free upgrade available",
            logoURL: marriottLogo,
            attention: "Needs attention",
            meta: ProfileV3GloveBoxMeta(glyphs: [.done], label: "Added to trip", dateLabel: dated),
            note: "Your stay qualifies for a free room upgrade. Want me to accept it?",
            followUpTitle: followUp
        ),
        ProfileV3GloveBoxEmail(
            id: "vfs",
            sender: "VFS Global",
            summary: "Booking confirmed for 12 to 16 Oct",
            meta: calendarUpdated,
            note: "Your appointment is confirmed and I've added it to your calendar.",
            followUpTitle: followUp
        ),
        ProfileV3GloveBoxEmail(
            id: "vfs-return",
            sender: "VFS Global",
            summary: "Booking confirmed for 12 to 16 Oct",
            meta: calendarUpdated,
            note: "Your appointment is confirmed and I've added it to your calendar.",
            followUpTitle: followUp
        ),
        ProfileV3GloveBoxEmail(
            id: "emirates-booking",
            sender: "Emirates",
            summary: "Booking confirmed for 12 to 16 Oct",
            logoURL: emiratesLogo,
            meta: calendarUpdated,
            note: note,
            followUpTitle: followUp
        )
    ]

    static let calls = [
        ProfileV3GloveBoxCall(
            id: "marriott",
            title: "Marriot Dubai",
            summary: "Called Mariot Hotel Dubai and got an early checking for 11 am",
            logoURL: marriottLogo,
            meta: calendarUpdated,
            recording: .audio(duration: "1:23", speed: "1x"),
            badge: "Changed",
            note: note,
            followUpTitle: followUp
        ),
        ProfileV3GloveBoxCall(
            id: "grab",
            title: "Grab - Spoke to driver",
            summary: "Called Mariot Hotel Dubai and got an early checking for 11 am",
            logoURL: ProfileV3AppAccessFixtureLogos.grab,
            meta: calendarUpdated,
            recording: .missing("Could not record conversation..."),
            note: note,
            followUpTitle: followUp
        ),
        ProfileV3GloveBoxCall(
            id: "baan-rim-pa",
            title: "Baan Rim Pa",
            summary: "Called restaurant and got a booking for 6 people",
            meta: calendarUpdated,
            recording: .audio(duration: "1:23", speed: "1x"),
            note: note,
            followUpTitle: followUp
        )
    ]

    static let transactions = [
        transaction(id: "soho", outcome: .approved),
        transaction(id: "soho-blocked", outcome: .blocked),
        transaction(id: "soho-repeat", outcome: .approved),
        transaction(id: "soho-last", outcome: .approved)
    ]

    static let hdfc = ProfileV3GloveBoxCardSection.LinkedCard(label: "HDFC ***5818", logoURL: hdfcLogo)

    static let email = ProfileV3GloveBoxEmailSection(
        title: "Email",
        badge: active,
        address: "mohak.k7@trips.atlys.com",
        about: "follow up, reply, negotiate, and coordinate with hotels, airlines and more, while you stay out of the thread.",
        forwardingLabel: "Emails forwarded to",
        forwardingAddress: "mohak.n@gmail.com",
        emails: emails,
        viewAllTitle: viewAll,
        listTitle: "Glove box  ·  Email"
    )

    static let phone = ProfileV3GloveBoxPhoneSection(
        title: "Phone number",
        badge: active,
        number: ProfileV3GloveBoxNumber(value: "+1 847-757-XXXX", countryCode: "IT", isCopyable: true),
        about: "Agent answers every call, day or night. It handles the simple ones and puts urgent ones through to you.",
        trip: ProfileV3GloveBoxPhoneSection.Trip(
            label: "Trip: Thailand",
            number: ProfileV3GloveBoxNumber(value: "+91 865362674", countryCode: "IT", isCopyable: true),
            badge: active
        ),
        calls: calls,
        viewAllTitle: viewAll,
        listTitle: "Glove box  ·  Calls"
    )

    static let card = ProfileV3GloveBoxCardSection(
        title: "Virtual card",
        card: ProfileV3GloveBoxCardSection.Card(
            lastFour: "2231",
            holder: "mohak n.",
            expiryLabel: "Expires",
            cvcLabel: "CVC",
            nameLabel: "Name"
        ),
        protectedNotice: "Cards details are protected",
        stats: [
            ProfileV3GloveBoxCardSection.Stat(id: "tables", value: "7 tables", label: "booked"),
            ProfileV3GloveBoxCardSection.Stat(id: "charges", value: "2 bad charges", label: "blocked")
        ],
        facts: [
            ProfileV3GloveBoxCardSection.Fact(id: "works-at", label: "Works at", value: "Restaurant only"),
            ProfileV3GloveBoxCardSection.Fact(id: "own-card", label: "Your own card", value: "Never shared"),
            ProfileV3GloveBoxCardSection.Fact(id: "no-show", label: "No-show fee", value: "Asks you first")
        ],
        payTitle: "How you pay",
        payBody: "When the assistant books or buys for you. Change it anytime.",
        payOptions: [
            ProfileV3GloveBoxCardSection.PayOption(
                id: "atlys",
                title: "Atlys pays, we bill you",
                body: "We pay the restaurant, hotel or shop with our card. You see every charge here and pay us in one go.",
                kind: .atlys
            ),
            ProfileV3GloveBoxCardSection.PayOption(
                id: "link",
                title: "Your own card, through link",
                body: "Pay with cards saved in your Link wallet. "
                    + "Each purchase gets a one-time card for the exact amount you approve.",
                kind: .link
            )
        ],
        selectedPayOptionID: "atlys",
        linkedCard: hdfc,
        addCardTitle: "Add card",
        secureNote: "Your card details are securely stored and used only when needed to manage your bookings.",
        transactions: transactions,
        emptyTitle: "No transactions yet...",
        emptyBody: "Once your agent starts handling your travel, confirmations and updates will land here.",
        viewAllTitle: viewAll,
        listTitle: "Glove box  ·  Transactions"
    )

    static let home = ProfileV3GloveBoxHome(email: email, phone: phone, card: card)

    static let sampleHome = ProfileV3GloveBoxHome(
        email: ProfileV3GloveBoxEmailSection(
            title: email.title,
            badge: email.badge,
            address: email.address,
            about: email.about,
            forwardingLabel: email.forwardingLabel,
            forwardingAddress: email.forwardingAddress,
            emails: Array(emails.prefix(2)),
            sampleLabel: sample,
            listTitle: email.listTitle
        ),
        phone: ProfileV3GloveBoxPhoneSection(
            title: phone.title,
            badge: ProfileV3GloveBoxBadge(label: "Actives on trip", tone: .pending),
            number: ProfileV3GloveBoxNumber(value: "+1 847-757-XXXX"),
            headline: ProfileV3GloveBoxPhoneSection.Headline(
                lead: "You get a ",
                emphasis: "new number",
                trail: " every time you travel"
            ),
            about: "...meanwhile see what our agent can do",
            calls: Array(calls.prefix(1)),
            sampleLabel: sample,
            listTitle: phone.listTitle
        ),
        card: ProfileV3GloveBoxCardSection(
            title: card.title,
            card: card.card,
            protectedNotice: card.protectedNotice,
            stats: card.stats,
            facts: card.facts,
            payTitle: card.payTitle,
            payBody: card.payBody,
            payOptions: card.payOptions,
            selectedPayOptionID: card.selectedPayOptionID,
            addCardTitle: card.addCardTitle,
            secureNote: card.secureNote,
            transactions: [],
            emptyTitle: card.emptyTitle,
            emptyBody: card.emptyBody,
            listTitle: card.listTitle
        )
    )

    private static func transaction(
        id: String,
        outcome: ProfileV3GloveBoxTransaction.Outcome
    ) -> ProfileV3GloveBoxTransaction {
        ProfileV3GloveBoxTransaction(
            id: id,
            title: "Dinner at SOHO, New York",
            summary: "Card check for table of 4",
            amount: "-$12.00",
            outcome: outcome,
            outcomeLabel: outcome == .approved ? "Approved" : "Blocked",
            note: note,
            followUpTitle: followUp
        )
    }

    private static let hdfcLogo = URL(
        string: "data:image/png;base64,"
            + "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAABYlAAAWJQFJUiTwAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAO"
            + "dEVYdFNvZnR3YXJlAEZpZ21hnrGWYwAABBVJREFUeAHVmk2IE0kUx//dyWR3BXV2M34tA5OIzIKju7MLsrAgZpddVg9qPOhBDxnUqziePaRz9OSIoF4k"
            + "CgoePIwXQURmxJMMOvHiB8jYjo74FZwxOorT3eWr/hiSdOW7O6Z/8LrTVdWd97qqUq/eiwQPYIx10ylJMkjSZ5+7bXFQbblHMk4yKUnSU3wruNIkwyRj"
            + "rHkmSYZI+tAubMUVknfMW7K+G+KT4uUo8Bp6aIwkx9rHE+ZVb9CDUoy/dYOOjUg5RsPCezpZSz+pWmV+dSyN6I8KmmDZpQsIb1hvftbu3MX71EE0gzFX"
            + "yKx4/lipVB+uVJH/eV2ayVAwV0BTfFkoupDBmnwOveH0m951qGSELCpkmpY02IKCDkHStTTpNCSqcxlA4y4GScqi05Dl46KJLeqBcZSuoJ0C12m0vLDE"
            + "ALIwDcsV6FQGWdk6sfgrZA4d4Il5YRh427sWUqjL9YTvD6QQ7u9HdRi6/v0H8soV1lU+jy/XbqAW2sMH+Jy94K7QNURnpkhbU91Zkjj5Ufxc8iukoA66"
            + "EpsRSWxBI0jRKL7bu6d2u7GbYgNK4UNpGLa+5hCy334KweEwszzgxTmQQLDgypsv3DFgGMHDdDNke/j8huCR4MOIT+JBeMD0qwJu3Z+pq+1f69cgvmo5"
            + "PGAnNyABD7ieU3Hw5PW62p499B/i/2+EB/zO50AQh49DHzcgjuAyyIeQ23WgFW/ZmdPOyldCeGAAfhHeOIClp066yhmMSrd0i/cDpHhkxza0G7mnB5Ht"
            + "Wxu5pVtGwOE9wJ0il/vMXr0W3xH9CVK44kauJdj8PFD4IKyTVq0UlnNN5lBuAHmj+V83kTfqVnTpxbOI/J2AHyzcnkBh3353BfdGX6qiOalyDXMQTeQQ"
            + "NQ4JRphUNQ7QOqLvRMWRrvIaFcHlntMDLfNn/xocG9pcV9tNv6yGR4xxA/g+s+VN/IZ4jyltJifbW7NxBI8cD887s2MUwWOEHxwDzsNaD4LEOD+YBtjD"
            + "aATB4ZyT3SleqU7A2lpWDWoZ088o/PEQtQitpbBMJGJ+ZvOfoE/XzibpM/VtiFAUQVk0gPcCbdFGUCO88vFoBvWw/MplhP+wthr6g0eYS+6GR2SKc2sl"
            + "SxxVcO08WRd8QiUdleIC0Rq9C505oblOifJClwFkoQpdP4JOwzCGRGlZoZdEk++cLHUp6BBYKJwhF/6KqK6imxd98TgjGfXFS/2E0aStlmKq6Rt/vHo1"
            + "GYnFsgiFGsoZhHp7IS1ZYl1oGrSpKTSErs9qExPDP6RS59EqzEqzqqx95JgfSW+eAGH+wlOrafgJs3ojy7zFVJzZIfO2YBvC/6gxyZpnjORwK4p7ssFl"
            + "VoSbB4m32OeYLQ6ztvBVXoX1l5tRJ03UCl8Be3uKXKLGcwkAAAAASUVORK5CYII="
    )
}
#endif
