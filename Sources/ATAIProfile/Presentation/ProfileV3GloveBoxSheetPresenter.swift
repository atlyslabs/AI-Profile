import ATUIKit
import SwiftUI

@MainActor
final class ProfileV3GloveBoxSheetPresenter {
    private let slot = ProfileV3SheetSlot()

    func update(for viewModel: ProfileV3GloveBoxViewModel) {
        if viewModel.sheets.isEmpty {
            dismiss()
        } else if !slot.isPresented {
            present(for: viewModel)
        }
    }

    func dismiss() {
        slot.dismiss()
    }

    private func present(for viewModel: ProfileV3GloveBoxViewModel) {
        slot.present(
            cornerRadius: ProfileV3Theme.Sizes.largeSheetCornerRadius,
            dimOpacity: ProfileV3Theme.Opacity.sheetBackdropDeep,
            dismissOnBackdropTap: true,
            onDismiss: { [weak viewModel] in viewModel?.sheetsDidClose() }
        ) { _, bottomInset in
            ProfileV3GloveBoxSheetStack(viewModel: viewModel, bottomInset: bottomInset)
        }
    }
}
