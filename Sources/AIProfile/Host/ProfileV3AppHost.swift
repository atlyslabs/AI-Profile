import SwiftUI

@MainActor
public protocol ProfileV3AppHost: AnyObject, Sendable {
    func showStatusMessage(_ text: String, isSuccess: Bool)
    func logOut()
    func restartApp()
    var floatingBarClearance: CGFloat { get }
}

extension EnvironmentValues {
    var profileV3FloatingBarClearance: CGFloat {
        get { self[ProfileV3FloatingBarClearanceKey.self] }
        set { self[ProfileV3FloatingBarClearanceKey.self] = newValue }
    }
}

private struct ProfileV3FloatingBarClearanceKey: EnvironmentKey {
    static let defaultValue: CGFloat = 68
}
