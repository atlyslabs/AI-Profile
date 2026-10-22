import ATUIKit
import SwiftUI

@MainActor
final class ProfileV3GloveBoxSheetPresenter {
    private var isPresented = false

    func update(for viewModel: ProfileV3GloveBoxViewModel) {
        if viewModel.sheets.isEmpty {
            dismiss()
        } else if !isPresented {
            present(for: viewModel)
        }
    }

    func dismiss() {
        guard isPresented else { return }
        isPresented = false
        ProfileV3SheetWindow.dismiss()
    }

    private func present(for viewModel: ProfileV3GloveBoxViewModel) {
        isPresented = true
        ProfileV3SheetWindow.present(
            cornerRadius: ProfileV3Theme.GloveBox.Layout.sheetRadius,
            dimOpacity: ProfileV3Theme.GloveBox.Palette.dimOpacity,
            dismissOnBackdropTap: true,
            onDismiss: { [weak self, weak viewModel] in
                guard let self, isPresented else { return }
                isPresented = false
                viewModel?.sheetsDidClose()
            }
        ) { _, bottomInset in
            ProfileV3GloveBoxSheetStack(viewModel: viewModel, bottomInset: bottomInset)
        }
    }
}
