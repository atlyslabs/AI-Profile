import Foundation

struct ProfileV3InstagramAccountDTO: Decodable, Equatable {
    private let rawUsername: ProfileV3LossyDTO<String>?
    private let rawDMConnected: ProfileV3LossyDTO<Bool>?

    var username: String? { rawUsername?.value }
    var dmConnected: Bool { rawDMConnected?.value ?? false }

    enum CodingKeys: String, CodingKey {
        case rawUsername = "username"
        case rawDMConnected = "dm_connected"
    }
}

struct ProfileV3InstagramLinkRequest: Encodable, Equatable {
    let username: String
    let userID: String

    enum CodingKeys: String, CodingKey {
        case username
        case userID = "user_id"
    }
}

struct ProfileV3InstagramLinkDTO: Decodable, Equatable {
    let status: String?
    let username: String?
}
