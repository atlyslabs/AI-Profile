import ATUIKit
import SwiftUI

enum ProfileV3SheetDetent {
    case large
    case height(CGFloat)
    case fitted(CGFloat?, until: PresentationDetent = .medium, ignoresKeyboard: Bool = false)
}

private struct ProfileV3SheetStyle: ViewModifier {
    let detent: ProfileV3SheetDetent?
    let cornerRadius: CGFloat
    let isDismissDisabled: Bool

    @State private var bottomInset: CGFloat = 0

    func body(content: Content) -> some View {
        detented(content)
            .presentationCornerRadius(cornerRadius)
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(isDismissDisabled)
    }

    @ViewBuilder
    private func detented(_ content: Content) -> some View {
        switch detent {
        case nil:
            content
        case .large:
            content.presentationDetents([.large])
        case .height(let height):
            content.presentationDetents([.height(height)])
        case .fitted(let height, let fallback, let ignoresKeyboard):
            content
                .background {
                    Color.clear
                        .ignoresSafeArea(ignoresKeyboard ? .keyboard : [])
                        .onGeometryChange(for: CGFloat.self) { $0.safeAreaInsets.bottom } action: { bottomInset = $0 }
                }
                .profileV3FittedDetent(height.map { $0 + bottomInset }, until: fallback)
        }
    }
}

extension View {
    func profileV3FittedDetent(_ height: CGFloat?, until fallback: PresentationDetent = .medium) -> some View {
        presentationDetents(height.map { [.height($0)] } ?? [fallback])
    }

    func profileV3Sheet(
        _ detent: ProfileV3SheetDetent? = nil,
        cornerRadius: CGFloat = ProfileV3Theme.Sizes.sheetCornerRadius,
        isDismissDisabled: Bool = false
    ) -> some View {
        modifier(ProfileV3SheetStyle(detent: detent, cornerRadius: cornerRadius, isDismissDisabled: isDismissDisabled))
    }
}

struct ProfileV3FittedConfirmationSheet<Confirmation: View>: View {
    var cornerRadius = ProfileV3Theme.Sizes.sheetCornerRadius
    let isBusy: Bool
    @ViewBuilder let confirmation: Confirmation

    @State private var height: CGFloat = 0

    var body: some View {
        confirmation
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height = $0 }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(at: .pureWhite).ignoresSafeArea())
            .profileV3Sheet(.fitted(height > 0 ? height : nil), cornerRadius: cornerRadius, isDismissDisabled: isBusy)
    }
}
