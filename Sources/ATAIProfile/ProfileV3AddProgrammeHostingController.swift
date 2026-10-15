import SwiftUI
import UIKit

final class ProfileV3AddProgrammeHostingController: UIHostingController<ProfileV3AddProgrammeView> {
    private let viewModel: ProfileV3AddProgrammeViewModel
    private let onRedirectToKYC: () -> Void

    init(
        requiresKYC: Bool,
        profileID: String?,
        repository: any ProfileV3LoyaltyRepository,
        selections: ProfileV3ProgrammeSelectionMemory?,
        onAdded: @escaping () -> Void,
        onRedirectToKYC: @escaping () -> Void
    ) {
        let viewModel = ProfileV3AddProgrammeViewModel(
            requiresKYC: requiresKYC,
            profileID: profileID,
            repository: repository,
            selections: selections,
            onAdded: onAdded
        )
        self.viewModel = viewModel
        self.onRedirectToKYC = onRedirectToKYC
        super.init(rootView: ProfileV3AddProgrammeView(viewModel: viewModel))
        viewModel.router = self
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}

extension ProfileV3AddProgrammeHostingController: ProfileV3AddProgrammeRouter {
    func redirectToKYC() {
        let redirect = onRedirectToKYC
        presentingViewController?.dismiss(animated: true) {
            redirect()
        }
    }

    func dismissAddProgramme() {
        presentingViewController?.dismiss(animated: true)
    }
}
