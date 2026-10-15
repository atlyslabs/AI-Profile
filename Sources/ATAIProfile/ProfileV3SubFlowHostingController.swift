import ATUIKit
import SwiftUI
import UIKit

final class ProfileV3SubFlowHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(Color(at: .pureWhite))
    }
}

final class ProfileV3PageHostingController<Content: View>: UIHostingController<Content> {
    var onDismissed: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(Color(at: .pureWhite))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard isBeingDismissed || presentingViewController == nil else { return }
        let onDismissed = onDismissed
        self.onDismissed = nil
        onDismissed?()
    }
}
