import ATUIKit
import SwiftUI

struct ProfileV3Spinner: View {
    var size: CGFloat = ProfileV3Theme.Sizes.spinner
    var lineWidth: CGFloat = ProfileV3Theme.Stroke.heavy
    var accessibilityLabel: String = ProfileV3Strings.loading

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSpinning = false

    var body: some View {
        Circle()
            .trim(from: 0, to: ProfileV3Theme.Motion.spinnerTrim)
            .stroke(
                ProfileV3Theme.spinnerGradient,
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .padding(lineWidth / 2)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isSpinning ? 360 : 0))
            .animation(reduceMotion ? nil : ProfileV3Theme.Motion.spinner, value: isSpinning)
            .onChange(of: reduceMotion, initial: true) { _, isReduced in isSpinning = !isReduced }
            .accessibilityLabel(accessibilityLabel)
    }
}

struct ProfileV3PagingFooter<Page: Hashable>: View {
    let hasFailed: Bool
    let page: Page
    let loadMore: () -> Void
    let retry: () -> Void

    var body: some View {
        if hasFailed {
            ProfileV3PillButton(title: ProfileV3Strings.tryAgain, action: retry)
                .frame(maxWidth: .infinity)
        } else {
            ProfileV3Spinner()
                .frame(maxWidth: .infinity)
                .id(page)
                .onAppear(perform: loadMore)
        }
    }
}

#if DEBUG
#Preview("Spinner") {
    ProfileV3Spinner()
        .padding(ProfileV3Theme.Space.s32)
        .background(Color(at: .pureWhite))
}
#endif
