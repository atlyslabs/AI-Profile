import Foundation

enum ProfileV3InstagramMapper {
    static func account(_ dto: ProfileV3InstagramAccountDTO) -> ProfileV3InstagramAccount {
        guard let username = dto.username.map(ProfileV3InstagramUsername.normalised)?.nonEmpty else {
            return .unlinked
        }
        return ProfileV3InstagramAccount(username: username, hasMessaged: dto.dmConnected)
    }

    static func linkedUsername(_ dto: ProfileV3InstagramLinkDTO, requested: String) -> String {
        dto.username.map(ProfileV3InstagramUsername.normalised)?.nonEmpty ?? requested
    }
}
