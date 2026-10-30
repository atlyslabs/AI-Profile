import Foundation

#if DEBUG
enum ProfileV3AIConnectorFixtures {
    static let assistants: [(key: String, name: String)] = [
        ("claude", "Claude"),
        ("chatgpt", "ChatGPT"),
        ("gemini", "Gemini"),
        ("grok", "Grok")
    ]

    static let statusTemplate = "Synced on \(ProfileV3AIConnectorMapper.datePlaceholder)"

    static func rows(syncedAt: [String: Date]) -> [ProfileV3Connector] {
        assistants.map { assistant in
            let synced = syncedAt[assistant.key]
            return ProfileV3Connector(
                id: assistant.key,
                name: assistant.name,
                icon: .remote(nil),
                status: synced == nil ? .needsAttention : .connected,
                next: ProfileV3Directive(go: "ai_connector", connector: assistant.key),
                connectLabel: synced == nil ? "Connect" : nil,
                statusLabel: ProfileV3AIConnectorMapper.statusLabel(statusTemplate, syncedAt: synced),
                syncedAt: synced
            )
        }
    }

    static func detail(_ connector: String) -> ProfileV3AIConnector {
        let name = name(for: connector)
        return ProfileV3AIConnector(
            connector: connector,
            eyebrow: "CONNECTORS",
            title: name,
            subtitle: "Bring what \(name) knows about your travel into Atlys.",
            benefits: [
                .init(
                    id: 0,
                    title: "Your travel history, in one go",
                    body: "Trips you’ve taken, places you want to go, and the airlines and hotels you like, "
                        + "straight from your \(name) chats."
                ),
                .init(
                    id: 1,
                    title: "Skip the questions",
                    body: "Atlys fills in your preferences from what \(name) already knows, so you don’t have to."
                ),
                .init(
                    id: 2,
                    title: "You see it first",
                    body: "You read \(name)’s answer before you paste it. We never connect to your \(name) account."
                )
            ],
            disclaimers: [
                .init(id: 0, text: "What you paste is saved to your Atlys profile and used to plan your trips."),
                .init(
                    id: 1,
                    text: "Your chats in \(name) follow \(name)’s own Terms and Privacy Policy.",
                    links: [
                        .init(label: "Terms", url: URL(string: "https://www.anthropic.com/legal/consumer-terms")!),
                        .init(label: "Privacy Policy", url: URL(string: "https://www.anthropic.com/legal/privacy")!)
                    ]
                )
            ],
            ctaLabel: "Get started",
            next: ProfileV3Directive(go: "ai_connector_connect", connector: connector)
        )
    }

    static func connect(_ connector: String) -> ProfileV3AIConnectorConnect {
        let name = name(for: connector)
        return ProfileV3AIConnectorConnect(
            connector: connector,
            eyebrow: "CONNECTORS",
            title: "Bring in your \(name) history",
            steps: [
                .init(
                    id: 0,
                    label: "STEP 1",
                    title: "Copy this prompt into \(name)",
                    prompt: .init(text: prompt, copyLabel: "Copy prompt", copiedLabel: "Copied")
                ),
                .init(
                    id: 1,
                    label: "STEP 2",
                    title: "Paste \(name)’s answer here",
                    body: "Read it first, and delete anything you’d rather not share.",
                    input: .init(key: "text", placeholder: "Paste the answer"),
                    submit: .init(label: "Save", action: "connect_ai_connector", connector: connector)
                )
            ]
        )
    }

    private static func name(for connector: String) -> String {
        assistants.first { $0.key == connector }?.name ?? connector.capitalized
    }

    private static let prompt = """
    I’m setting up my travel profile on Atlys. From what you know about me in our past conversations, \
    list only what’s about travel, as short bullet points under these headings. Skip a heading if there’s \
    nothing for it, and don’t guess.

    TRIPS: places I’ve been (month and year if you know) and trips I’ve planned
    WISHLIST: places I want to go
    FLIGHTS: airlines, cabin, seat, time of day, airports I use
    STAYS: hotel chains, kind of place, room needs, area
    LOYALTY: programmes, tiers and cards I use (names only, never numbers)
    FOOD: diet, cuisines, drinks, things I avoid
    BUDGET: how much I like to spend on flights, hotels and trips
    STYLE: pace, activities, who I travel with

    Don’t include passwords, card numbers, passport numbers, member numbers or anything not about travel.
    """
}

final class ProfileV3AIConnectorStore: @unchecked Sendable {
    private let lock = NSLock()
    private var synced: [String: Date] = [:]

    var syncedAt: [String: Date] { lock.withLock { synced } }

    func connect(_ connector: String, at date: Date = .now) {
        lock.withLock { synced[connector] = date }
    }
}
#endif
