import Foundation

public protocol ProfileV3SessionProviding: Sendable {
    var currentUserID: String? { get }

    @MainActor var isGuestSession: Bool { get }
}
