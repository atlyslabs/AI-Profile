import Foundation

struct ProfileV3HubHints {
    static let holdHintShowLimit = 3

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasSeenHoldHint: Bool {
        get { defaults.bool(forKey: Keys.holdHintSeen) }
        nonmutating set { defaults.set(newValue, forKey: Keys.holdHintSeen) }
    }

    var hasSeenFlipDemo: Bool {
        get { defaults.bool(forKey: Keys.flipDemoSeen) }
        nonmutating set { defaults.set(newValue, forKey: Keys.flipDemoSeen) }
    }

    var holdHintShows: Int {
        get { defaults.integer(forKey: Keys.holdHintShows) }
        nonmutating set { defaults.set(newValue, forKey: Keys.holdHintShows) }
    }

    var isHoldHintDue: Bool {
        hasSeenFlipDemo && !hasSeenHoldHint && holdHintShows < Self.holdHintShowLimit
    }

    var hasSeenProgrammeReorderHint: Bool {
        get { defaults.bool(forKey: Keys.programmeReorderHintSeen) }
        nonmutating set { defaults.set(newValue, forKey: Keys.programmeReorderHintSeen) }
    }

    private enum Keys {
        static let holdHintSeen = "profileV3.holdToExploreSeen"
        static let holdHintShows = "profileV3.holdToExploreShows"
        static let flipDemoSeen = "profileV3.flipDemoSeen"
        static let programmeReorderHintSeen = "profileV3.programmeReorderHintSeen"
    }
}
