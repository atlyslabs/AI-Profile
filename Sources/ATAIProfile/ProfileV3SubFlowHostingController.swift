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
    private let cover = ProfileV3ScreenCoverToken()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(Color(at: .pureWhite))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cover.begin()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isLeavingScreen { cover.end() }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cover.end()
        guard isBeingDismissed || presentingViewController == nil else { return }
        let onDismissed = onDismissed
        self.onDismissed = nil
        onDismissed?()
    }
}
