import ATUIKit
import SwiftUI
import UIKit

final class ProfileV3CityProfileHostingController: UIHostingController<ProfileV3CityProfileView> {
    private let viewModel: ProfileV3CityProfileViewModel

    init(
        profileID: String?,
        repository: any ProfileV3CityPreferencesRepository,
        placeSearch: (any ProfileV3PlaceSearching)?
    ) {
        let viewModel = ProfileV3CityProfileViewModel(profileID: profileID, repository: repository, placeSearch: placeSearch)
        self.viewModel = viewModel
        super.init(rootView: ProfileV3CityProfileView(viewModel: viewModel))
        viewModel.onClose = { [weak self] in self?.presentingViewController?.dismiss(animated: true) }
        profileV3UsePageSheet()
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(Color(at: .pureWhite))
        viewModel.load()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed || presentingViewController == nil {
            viewModel.cancel()
        }
    }
}
