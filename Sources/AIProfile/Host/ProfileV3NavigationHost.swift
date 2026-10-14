import UIKit

@MainActor
public protocol ProfileV3NavigationHost: AnyObject, Sendable {
    func restartApp()

    func isRestarting(_ navigationController: UINavigationController) -> Bool
}
