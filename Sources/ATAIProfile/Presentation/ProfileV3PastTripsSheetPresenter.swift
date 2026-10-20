import ATUIKit
import SwiftUI

@MainActor
final class ProfileV3PastTripsSheetPresenter {
    private typealias Sizes = ProfileV3Theme.Sizes.TripSheet

    private var presented: ProfileV3PastTripsViewModel.Sheet?

    func show(_ sheet: ProfileV3PastTripsViewModel.Sheet?, for viewModel: ProfileV3PastTripsViewModel) {
        guard sheet != presented else { return }
        dismiss()
        guard let sheet else { return }
        presented = sheet
        present(sheet, for: viewModel)
    }

    func dismiss() {
        guard presented != nil else { return }
        presented = nil
        ProfileV3SheetWindow.dismiss()
    }

    private func present(_ sheet: ProfileV3PastTripsViewModel.Sheet, for viewModel: ProfileV3PastTripsViewModel) {
        let onDismiss: () -> Void = { [weak self, weak viewModel] in
            guard let self, presented == sheet else { return }
            presented = nil
            viewModel?.sheetDidDismiss(sheet)
        }
        switch sheet {
        case .add:
            guard let editor = viewModel.editor else { return }
            presentFloating(onDismiss: onDismiss) {
                ProfileV3AddPastTripSheet(viewModel: editor)
            }
        case .actions:
            let trip = viewModel.actionsTrip
            presentFloating(onDismiss: onDismiss) {
                ProfileV3PastTripActionsSheet(
                    editTitle: trip?.edit?.label ?? "",
                    deleteTitle: trip?.delete?.label ?? "",
                    onEdit: viewModel.tapEdit,
                    onDelete: viewModel.tapDelete
                )
            }
        case .confirmDelete:
            ProfileV3SheetWindow.present(
                cornerRadius: Sizes.confirmRadius,
                dimOpacity: ProfileV3Theme.Opacity.tripBackdrop,
                dismissOnBackdropTap: true,
                onDismiss: onDismiss
            ) { _, bottomInset in
                ProfileV3PastTripDeleteSheet(viewModel: viewModel)
                    .padding(.bottom, bottomInset)
            }
        }
    }

    private func presentFloating<Content: View>(
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        ProfileV3SheetWindow.present(
            cornerRadius: Sizes.radius,
            layout: .floating(horizontalInset: Sizes.inset, bottomInset: Sizes.bottom),
            dimOpacity: ProfileV3Theme.Opacity.tripBackdrop,
            dismissOnBackdropTap: true,
            onDismiss: onDismiss
        ) { _, _ in
            content()
                .overlay(alignment: .top) { ProfileV3TripSheetGrabber() }
                .profileV3TapToDismissKeyboard()
        }
    }
}

private struct ProfileV3TripSheetGrabber: View {
    private typealias Sizes = ProfileV3Theme.Sizes.TripSheet

    var body: some View {
        Capsule()
            .fill(ProfileV3Theme.Palette.tripSheetGrabber)
            .frame(width: Sizes.grabberWidth, height: Sizes.grabberHeight)
            .padding(.top, Sizes.grabberTop)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
