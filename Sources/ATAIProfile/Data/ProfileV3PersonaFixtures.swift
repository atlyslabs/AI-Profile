import Foundation

#if DEBUG
final class ProfileV3PersonaStore: @unchecked Sendable {
    struct Source: Equatable {
        let id: String
        let kind: ProfileV3PersonaTrait.Row.Kind
        var title: String
        var subtitle: String
        var delta: Int
        var isIgnored = false
    }

    struct TraitInfo {
        let id: String
        let name: String
        let description: String
        let labels: [String]
    }

    static let start = 50
    static let range = 0 ... 100

    private let lock = NSLock()
    private var sourcesByTrait: [String: [Source]]
    private var nextID = 0

    init(sourcesByTrait: [String: [Source]] = ProfileV3PersonaFixtures.sources) {
        self.sourcesByTrait = sourcesByTrait
    }

    func sources(for trait: String) -> [Source] {
        lock.lock()
        defer { lock.unlock() }
        return sourcesByTrait[trait] ?? []
    }

    func score(for trait: String) -> Int {
        Self.score(of: sources(for: trait))
    }

    static func score(of newestFirst: [Source]) -> Int {
        newestFirst.reversed().reduce(start) { score, source in
            guard !source.isIgnored else { return score }
            return min(max(score + source.delta, range.lowerBound), range.upperBound)
        }
    }

    func setScore(_ target: Int, for trait: String) {
        lock.lock()
        defer { lock.unlock() }
        var sources = sourcesByTrait[trait] ?? []
        let target = min(max(target, Self.range.lowerBound), Self.range.upperBound)
        let delta = target - Self.score(of: sources)
        if let latest = sources.first, latest.kind == .user {
            let merged = latest.delta + delta
            if merged == 0 {
                sources.removeFirst()
            } else {
                sources[0].delta = merged
                sources[0].title = Self.changeTitle(target, raised: merged > 0)
            }
        } else if delta != 0 {
            nextID += 1
            sources.insert(
                Source(
                    id: "user-\(trait)-\(nextID)",
                    kind: .user,
                    title: Self.changeTitle(target, raised: delta > 0),
                    subtitle: "Changes made by you",
                    delta: delta
                ),
                at: 0
            )
        }
        sourcesByTrait[trait] = sources
    }

    func setIgnored(_ isIgnored: Bool, sourceID: String?, trait: String) {
        lock.lock()
        defer { lock.unlock() }
        guard var sources = sourcesByTrait[trait] else { return }
        for index in sources.indices where sourceID == nil || sources[index].id == sourceID {
            sources[index].isIgnored = isIgnored
        }
        sourcesByTrait[trait] = sources
    }

    private static func changeTitle(_ score: Int, raised: Bool) -> String {
        raised ? "Raised to \(score)" : "Lowered to \(score)"
    }
}

enum ProfileV3PersonaFixtures {
    static let traits: [ProfileV3PersonaStore.TraitInfo] = [
        .init(
            id: "adventure",
            name: "Adventure",
            description: "Finds the right amount of adventure in your trips. Surfaces experiences that add a little "
                + "excitement without going overboard.",
            labels: ["Keep it safe", "Balanced", "Chase the rush"]
        ),
        .init(
            id: "new_places",
            name: "New places",
            description: "Tracks your appetite for discovering somewhere new. Prioritizes destinations and "
                + "experiences that keep things fresh.",
            labels: ["Stick to favourites", "Balanced", "Always somewhere new"]
        ),
        .init(
            id: "outdoors",
            name: "Outdoors",
            description: "Understands how much nature fits into your ideal trip. Balances outdoor experiences with "
                + "everything else you enjoy.",
            labels: ["City comforts", "Balanced", "Into the wild"]
        ),
        .init(
            id: "social",
            name: "Social",
            description: "Learns how you like to experience places with other people. Finds the right mix of "
                + "social energy and personal space.",
            labels: ["Me time", "Balanced", "The more the merrier"]
        ),
        .init(
            id: "nightlife",
            name: "Nightlife",
            description: "Picks up on how much your evenings matter when you travel. Surfaces nights out and "
                + "experiences that match your vibe.",
            labels: ["Early nights", "Balanced", "Out till late"]
        ),
        .init(
            id: "pace",
            name: "Pace",
            description: "Learns the rhythm that makes a trip feel right for you. Balances packed days with enough "
                + "time to slow down.",
            labels: ["Slow and easy", "Balanced", "Pack it all in"]
        ),
        .init(
            id: "local",
            name: "Local",
            description: "Measures how much you like getting beneath the surface of a destination. Finds local "
                + "experiences that fit naturally into your trip.",
            labels: ["Classic sights", "Balanced", "Live like a local"]
        ),
        .init(
            id: "culture_history",
            name: "Culture & History",
            description: "Understands how much stories and heritage shape your travel. Surfaces places with "
                + "culture, history, and character you'll appreciate.",
            labels: ["Light touch", "Balanced", "Deep dive"]
        ),
        .init(
            id: "comfort",
            name: "Comfort",
            description: "Learns where you draw the line between comfort and adventure. Balances familiar comforts "
                + "with experiences worth stepping out for.",
            labels: ["Rough it", "Balanced", "All the comforts"]
        ),
        .init(
            id: "planning",
            name: "Planning",
            description: "Understands how much structure you like before you travel. Builds itineraries around "
                + "your preferences while leaving room for the unexpected.",
            labels: ["Go with the flow", "Balanced", "Every detail planned"]
        )
    ]

    static let sources: [String: [ProfileV3PersonaStore.Source]] = [
        "adventure": [
            .init(
                id: "gmail-dive",
                kind: .gmail,
                title: "Open water Dive course, 4 days",
                subtitle: "Signed up for it in your recent trip to Thailand",
                delta: 12
            ),
            .init(
                id: "gmail-dubai",
                kind: .gmail,
                title: "Dubai trip with no activities",
                subtitle: "4 days, 3 dinners, nothing else. With partner",
                delta: -3
            ),
            .init(id: "gmail-trek", kind: .gmail, title: "Himalayan trek, 6 days", subtitle: "Booked with a guide", delta: 13)
        ],
        "new_places": [
            .init(id: "gmail-iceland", kind: .gmail, title: "First trip to Iceland", subtitle: "Ring road, 8 days", delta: 35)
        ],
        "planning": [
            .init(id: "gmail-itinerary", kind: .gmail, title: "Day-by-day itinerary", subtitle: "Sent to yourself", delta: 40)
        ],
        "culture_history": [
            .init(id: "gmail-rome", kind: .gmail, title: "Vatican museums tour", subtitle: "Rome, 3 hours", delta: 25)
        ],
        "local": [
            .init(id: "gmail-resort", kind: .gmail, title: "All-inclusive resort", subtitle: "Bali, 5 nights", delta: -18)
        ]
    ]

    static func persona(_ store: ProfileV3PersonaStore, profileID: String?) -> ProfileV3TravelPersona {
        let found = traits.filter { store.score(for: $0.id) != ProfileV3PersonaStore.start }.count
        return ProfileV3TravelPersona(
            title: "Travel persona",
            iconURL: ProfileV3PlaceholderArt.agentPersonal.url,
            foundLabel: "Found \(found)/\(traits.count) traits",
            subtitle: "Build a travel personality that gets more personal with every trip.",
            range: ProfileV3PersonaStore.range,
            traits: traits.map { info in
                ProfileV3TravelPersona.Trait(
                    id: info.id,
                    name: info.name,
                    score: store.score(for: info.id),
                    detail: ProfileV3Directive(go: "persona_trait", profileID: profileID, trait: info.id),
                    submit: action("set_persona_score", trait: info.id, profileID: profileID)
                )
            }
        )
    }

    static func trait(_ id: String, store: ProfileV3PersonaStore, profileID: String?) -> ProfileV3PersonaTrait? {
        guard let info = traits.first(where: { $0.id == id }) else { return nil }
        let sources = store.sources(for: id)
        let score = store.score(for: id)
        let allIgnored = !sources.isEmpty && sources.allSatisfy(\.isIgnored)
        return ProfileV3PersonaTrait(
            trait: id,
            title: info.name,
            score: score,
            subtitle: info.description,
            scale: ProfileV3PersonaTrait.Scale(range: ProfileV3PersonaStore.range, value: score, labels: info.labels),
            calculationTitle: "See how your score was calculated",
            rows: sources.map { source in
                ProfileV3PersonaTrait.Row(
                    id: source.id,
                    kind: source.kind,
                    title: source.title,
                    subtitle: source.subtitle,
                    delta: source.delta,
                    deltaLabel: source.delta > 0 ? "+\(source.delta)" : "\(source.delta)",
                    isIgnored: source.isIgnored,
                    action: ProfileV3PersonaTrait.Action(
                        label: source.isIgnored ? "Undo" : "Ignore",
                        submit: action(
                            source.isIgnored ? "unignore_persona_source" : "ignore_persona_source",
                            trait: id,
                            profileID: profileID,
                            sourceID: source.id
                        )
                    )
                )
            },
            bulk: sources.isEmpty ? nil : ProfileV3PersonaTrait.Action(
                label: allIgnored ? "Undo all" : "Ignore all",
                submit: action(
                    allIgnored ? "unignore_all_persona_sources" : "ignore_all_persona_sources",
                    trait: id,
                    profileID: profileID
                )
            ),
            nextPage: nil,
            startingPoint: ProfileV3PersonaTrait.StartingPoint(title: "Starting point", subtitle: "Everyone starts at 50")
        )
    }

    static func action(
        _ name: String,
        trait: String,
        profileID: String?,
        sourceID: String? = nil
    ) -> ProfileV3BoardAction {
        var fields: [String: ProfileV3ScalarDTO] = ["action": .string(name), "trait": .string(trait)]
        if let profileID { fields["profile_id"] = .string(profileID) }
        if let sourceID { fields["source_id"] = .string(sourceID) }
        return ProfileV3BoardAction(fields: fields)
    }
}
#endif
