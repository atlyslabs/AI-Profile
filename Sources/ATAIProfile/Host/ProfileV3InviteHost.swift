import UIKit

@MainActor
public protocol ProfileV3InviteHost: AnyObject, Sendable {
    func loadInviteCode() async throws -> ProfileV3InviteCode?
    func shareInviteCode(_ invite: ProfileV3InviteCode, from presenter: UIViewController)
}

@MainActor
final class ProfileV3UnavailableInviteHost: ProfileV3InviteHost {
    nonisolated init() {}

    func loadInviteCode() async throws -> ProfileV3InviteCode? { nil }

    func shareInviteCode(_ invite: ProfileV3InviteCode, from presenter: UIViewController) {}
}
