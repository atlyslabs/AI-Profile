import AIProfile
import UIKit

@MainActor
final class VDCProfileV3NavigationHost: ProfileV3NavigationHost {
    func restartApp() {
        NotificationCenter.default.post(name: AVNavigationViewController.RestartApp, object: nil)
    }

    func isRestarting(_ navigationController: UINavigationController) -> Bool {
        (navigationController as? AVNavigationViewController)?.isShowingRestartScreen == true
    }
}
