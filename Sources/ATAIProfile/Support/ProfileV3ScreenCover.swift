import Observation
import SwiftUI

@MainActor
@Observable
final class ProfileV3ScreenCover {
    static let shared = ProfileV3ScreenCover()

    private(set) var depth = 0

    var isCovered: Bool { depth > 0 }

    func begin() {
        depth += 1
    }

    func end() {
        depth = max(depth - 1, 0)
    }
}

@MainActor
final class ProfileV3ScreenCoverToken {
    private var isCovering = false

    func begin() {
        guard !isCovering else { return }
        isCovering = true
        ProfileV3ScreenCover.shared.begin()
    }

    func end() {
        guard isCovering else { return }
        isCovering = false
        ProfileV3ScreenCover.shared.end()
    }
}

extension UIViewController {
    var isLeavingScreen: Bool {
        isBeingDismissed || presentingViewController?.isBeingDismissed == true || presentingViewController == nil
    }
}

extension EnvironmentValues {
    var profileV3PausesAnimations: Bool {
        get { self[ProfileV3PausesAnimationsKey.self] }
        set { self[ProfileV3PausesAnimationsKey.self] = newValue }
    }
}

private struct ProfileV3PausesAnimationsKey: EnvironmentKey {
    static let defaultValue = false
}
