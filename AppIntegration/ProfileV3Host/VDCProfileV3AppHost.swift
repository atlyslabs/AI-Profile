import AIProfile
import SwiftUI

@MainActor
final class VDCProfileV3AppHost: ProfileV3AppHost {
    func showStatusMessage(_ text: String, isSuccess: Bool) {
        FlashMessageGenerator.showFlashMessage(withText: text, type: isSuccess ? .success : .failure)
    }

    func logOut() {
        LoginCoordinator.logOutUser()
    }

    func restartSplash(onFinish: @escaping @MainActor () -> Void) -> AnyView {
        AnyView(AICSplash(replays: true, onFinish: onFinish))
    }

    var floatingBarClearance: CGFloat {
        AVTabBarController.floatingBarClearance
    }
}
