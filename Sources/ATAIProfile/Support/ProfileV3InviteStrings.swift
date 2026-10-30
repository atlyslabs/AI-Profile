import Foundation

// MARK: - Awaiting Ditto keys (mo-aiprofile-invite-*); literals until the pipeline is rerun
extension ProfileV3Strings {
    static let inviteCode = "Invite code"
    static let yourInviteCode = "Your invite code"
    static let invitesLeft = "Invites left"
    static let shareInviteCodeLink = "Share invite code link"
    static func shareWithFriends(_ count: Int) -> String { "Share your code with up to \(count) friends." }
    static func inviteUsed(_ index: Int) -> String { "Invite \(index) used" }
    static func inviteUnused(_ index: Int) -> String { "Invite \(index) available" }
}
