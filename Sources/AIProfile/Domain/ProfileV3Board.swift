import Foundation

struct ProfileV3ProfileBoard: Identifiable, Equatable {
    let profileID: String
    let isMain: Bool
    let name: String
    let pass: ProfileV3WorldPass
    let home: ProfileV3Home

    var id: String { profileID }
}

struct ProfileV3Board: Equatable {
    let profiles: [ProfileV3ProfileBoard]
    var settings: ProfileV3Directive?

    var mainProfile: ProfileV3ProfileBoard? {
        profiles.first(where: \.isMain) ?? profiles.first
    }

    func profile(id: String?) -> ProfileV3ProfileBoard? {
        guard let id else { return mainProfile }
        return profiles.first { $0.profileID == id } ?? mainProfile
    }
}
