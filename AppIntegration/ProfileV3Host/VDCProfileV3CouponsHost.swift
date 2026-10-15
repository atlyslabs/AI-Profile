import ATAIProfile
import SwiftUI
import UIKit

@MainActor
final class VDCProfileV3CouponsHost: ProfileV3CouponsHost {
    func presentCoupons(from presenter: UIViewController) {
        weak var presented: UIViewController?
        let host = UIHostingController(rootView: CouponsView(
            viewModel: CouponsViewModel(),
            onBack: { presented?.dismiss(animated: true) }
        ))
        presented = host
        host.view.backgroundColor = .white
        host.modalPresentationStyle = .fullScreen
        presenter.present(host, animated: true)
    }
}
