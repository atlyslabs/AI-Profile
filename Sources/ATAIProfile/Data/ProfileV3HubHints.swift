import Foundation

struct ProfileV3HubHints {
    static let holdHintShowLimit = 3
    static let flipDemoShowLimit = 5
    static let programmeReorderHintShowLimit = 5
    static let personaLoaderShowLimit = 5

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasSeenHoldHint: Bool {
        get { defaults.bool(forKey: Keys.holdHintSeen) }
        nonmutating set { defaults.set(newValue, forKey: Keys.holdHintSeen) }
    }

    var flipDemoShows: Int {
        get { defaults.integer(forKey: Keys.flipDemoShows) }
        nonmutating set { defaults.set(newValue, forKey: Keys.flipDemoShows) }
    }

    var isFlipDemoDue: Bool {
        flipDemoShows < Self.flipDemoShowLimit
    }

    var holdHintShows: Int {
        get { defaults.integer(forKey: Keys.holdHintShows) }
        nonmutating set { defaults.set(newValue, forKey: Keys.holdHintShows) }
    }

    var isHoldHintDue: Bool {
        flipDemoShows > 0 && !hasSeenHoldHint && holdHintShows < Self.holdHintShowLimit
    }

    var programmeReorderHintShows: Int {
        get { defaults.integer(forKey: Keys.programmeReorderHintShows) }
        nonmutating set { defaults.set(newValue, forKey: Keys.programmeReorderHintShows) }
    }

    var isProgrammeReorderHintDue: Bool {
        programmeReorderHintShows < Self.programmeReorderHintShowLimit
    }

    var hasSeenConnectedAppsHint: Bool {
        get { defaults.bool(forKey: Keys.connectedAppsHintSeen) }
        nonmutating set { defaults.set(newValue, forKey: Keys.connectedAppsHintSeen) }
    }

    var personaLoaderShows: Int {
        get { defaults.integer(forKey: Keys.personaLoaderShows) }
        nonmutating set { defaults.set(newValue, forKey: Keys.personaLoaderShows) }
    }

    var isPersonaLoaderDue: Bool {
        personaLoaderShows < Self.personaLoaderShowLimit
    }

    var hasSeenPersonaCoach: Bool {
        get { defaults.bool(forKey: Keys.personaCoachSeen) }
        nonmutating set { defaults.set(newValue, forKey: Keys.personaCoachSeen) }
    }

    private enum Keys {
        static let holdHintSeen = "profileV3.holdToExploreSeen"
        static let holdHintShows = "profileV3.holdToExploreShows"
        static let flipDemoShows = "profileV3.flipDemoShows"
        static let programmeReorderHintShows = "profileV3.programmeReorderHintShows"
        static let connectedAppsHintSeen = "profileV3.connectedAppsHintSeen"
        static let personaCoachSeen = "profileV3.personaCoachSeen"
        static let personaLoaderShows = "profileV3.personaLoaderShows"
    }
}
