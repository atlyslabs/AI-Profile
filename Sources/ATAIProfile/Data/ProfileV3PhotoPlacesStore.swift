import Foundation

struct ProfileV3PhotoPlacesState: Codable, Equatable, Sendable {
    var isConnected = false
    var scannedThrough: Date?
    var countries: [ProfileV3PhotoCountry] = []
    var needsUpload = false
}

struct ProfileV3PhotoPlacesStore {
    private let defaults: UserDefaults
    private let userID: () -> String?

    init(defaults: UserDefaults = .standard, userID: @escaping () -> String?) {
        self.defaults = defaults
        self.userID = userID
    }

    func load() -> ProfileV3PhotoPlacesState {
        guard let key, let data = defaults.data(forKey: key),
              let state = try? JSONDecoder().decode(ProfileV3PhotoPlacesState.self, from: data) else {
            return ProfileV3PhotoPlacesState()
        }
        return state
    }

    func save(_ state: ProfileV3PhotoPlacesState) {
        guard let key, let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: key)
    }

    func clear() {
        guard let key else { return }
        defaults.removeObject(forKey: key)
    }

    private var key: String? {
        userID()?.nonEmpty.map { "profileV3.photoPlaces.\($0)" }
    }
}
