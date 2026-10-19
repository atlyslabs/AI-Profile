import ATUIKit
import SwiftUI
import UIKit

final class ProfileV3TravelPersonaHostingController: UIHostingController<ProfileV3TravelPersonaView> {
    private let viewModel: ProfileV3TravelPersonaViewModel

    init(profileID: String?, repository: any ProfileV3PersonaRepository) {
        let viewModel = ProfileV3TravelPersonaViewModel(profileID: profileID, repository: repository)
        self.viewModel = viewModel
        super.init(rootView: ProfileV3TravelPersonaView(viewModel: viewModel))
        viewModel.onClose = { [weak self] in self?.presentingViewController?.dismiss(animated: true) }
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = ProfileV3Theme.Sizes.Agent.sheetCornerRadius
        }
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(Color(at: .pureWhite))
        viewModel.load()
    }
}
