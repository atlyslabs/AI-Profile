import ATUIKit
import SwiftUI
import UIKit

@MainActor
final class ProfileV3AddProgrammeSheetPresenter {

    private let viewModel: ProfileV3AddProgrammeViewModel
    private let onRedirectToKYC: () -> Void
    private let onFinish: (ProfileV3AddProgrammeSheetPresenter) -> Void
    private var afterDismiss: (() -> Void)?
    private var loader: UIViewController?
    private var isSheetShown = false

    init(
        profileID: String?,
        repository: any ProfileV3LoyaltyRepository,
        selections: ProfileV3ProgrammeSelectionMemory?,
        onAdded: @escaping () -> Void,
        onRedirectToKYC: @escaping () -> Void,
        onFinish: @escaping (ProfileV3AddProgrammeSheetPresenter) -> Void
    ) {
        self.onRedirectToKYC = onRedirectToKYC
        self.onFinish = onFinish
        viewModel = ProfileV3AddProgrammeViewModel(
            requiresKYC: false,
            profileID: profileID,
            repository: repository,
            selections: selections,
            onAdded: onAdded
        )
        viewModel.router = self
    }

    func present(from host: UIViewController) {
        guard ProfileV3FeatureFlags.isProgrammeScanLoaderEnabled else {
            showProgrammePicker()
            return
        }
        showLoader(from: host)
    }

    private func showLoader(from host: UIViewController) {
        let loader = UIHostingController(
            rootView: ProfileV3AddProgrammeView(viewModel: viewModel, presentation: .loader)
        )
        loader.view.backgroundColor = .clear
        loader.modalPresentationStyle = .overFullScreen
        loader.modalTransitionStyle = .crossDissolve
        self.loader = loader
        host.present(loader, animated: true)
    }

    private func showSheet() {
        let viewModel = viewModel
        ProfileV3SheetWindow.present(
            dismissOnBackdropTap: true,
            onDismiss: { [weak self] in self?.finishDismiss() }
        ) { maxHeight, bottomInset in
            ProfileV3AddProgrammeView(
                viewModel: viewModel,
                presentation: .sheet,
                maxHeight: maxHeight,
                bottomInset: bottomInset
            )
        }
    }

    private func dismissLoader(completion: (() -> Void)? = nil) {
        guard let loader else {
            completion?()
            return
        }
        self.loader = nil
        loader.dismiss(animated: true, completion: completion)
    }

    private func finishDismiss() {
        let completion = afterDismiss
        afterDismiss = nil
        withExtendedLifetime(self) {
            onFinish(self)
            completion?()
        }
    }
}

extension ProfileV3AddProgrammeSheetPresenter: ProfileV3AddProgrammeRouter {

    func showProgrammePicker() {
        guard !isSheetShown else { return }
        isSheetShown = true
        showSheet()
        dismissLoader()
    }

    func dismissAddProgramme() {
        guard isSheetShown else {
            dismissLoader { [weak self] in self?.finishDismiss() }
            return
        }
        ATBottomSheetWindowPresenter.dismiss()
    }

    func redirectToKYC() {
        afterDismiss = onRedirectToKYC
        dismissAddProgramme()
    }
}
