import ATUIKit
import SwiftUI
import UIKit

@MainActor
enum ProfileV3SheetWindow {
    static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }

    static func present<Content: View>(
        cornerRadius: CGFloat = ProfileV3Theme.Sizes.sheetCornerRadius,
        layout: ATBottomSheetLayout = .edgeToEdge,
        dimOpacity: Double = ProfileV3Theme.Opacity.sheetBackdrop,
        dismissOnBackdropTap: Bool,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: (_ maxHeight: CGFloat, _ bottomInset: CGFloat) -> Content
    ) {
        let metrics = metrics()
        ATBottomSheetWindowPresenter.present(
            cornerRadius: cornerRadius,
            layout: layout,
            maxHeightFraction: ProfileV3Theme.Ratio.sheetMaxHeight,
            dimmedBackdropOpacity: dimOpacity,
            dismissOnBackdropTap: dismissOnBackdropTap,
            showsGrabHandle: false,
            onDismiss: onDismiss
        ) {
            content(metrics.maxHeight, metrics.bottomInset)
        }
    }

    static func dismiss() {
        ATBottomSheetWindowPresenter.dismiss()
    }

    private static func metrics() -> (maxHeight: CGFloat, bottomInset: CGFloat) {
        guard let window = keyWindow() else {
            return (ProfileV3Theme.Sizes.sheetFallbackHeight, 0)
        }
        let bottomInset = window.safeAreaInsets.bottom
        let available = window.bounds.height - bottomInset
        return (available * ProfileV3Theme.Ratio.sheetMaxHeight, bottomInset)
    }
}
