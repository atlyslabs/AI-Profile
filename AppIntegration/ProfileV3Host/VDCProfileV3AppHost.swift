import ATAIProfile
import SwiftUI

@MainActor
final class VDCProfileV3AppHost: ProfileV3AppHost {
    func showStatusMessage(_ text: String, isSuccess: Bool) {
        FlashMessageGenerator.showFlashMessage(withText: text, type: isSuccess ? .success : .failure)
    }

    func logOut() {
        LoginCoordinator.logOutUser()
    }

    func restartApp() {
        NotificationCenter.default.post(name: AVNavigationViewController.RestartApp, object: nil)
    }

    var floatingBarClearance: CGFloat {
        AVTabBarController.floatingBarClearance
    }
}
