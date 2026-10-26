import ATUIKit
import SwiftUI

struct ProfileV3ErrorState: View {
    var title = ProfileV3Strings.errorStateTitle
    var subtitle = ProfileV3Strings.errorStateSubtitle
    var actionTitle = ProfileV3Strings.retry
    let action: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.ErrorState

    var body: some View {
        VStack(spacing: 0) {
            ATIcon.SwiftUIImage.linkOff
                .profileV3Icon(Layout.icon)
                .foregroundStyle(Color(at: .neutralGrey300))
                .accessibilityHidden(true)
            Text(title)
                .typoGraphy(.B1InterSemibold14)
                .foregroundStyle(ProfileV3Theme.errorStateTitleGradient)
                .multilineTextAlignment(.center)
                .padding(.top, Layout.titleTop)
                .accessibilityAddTraits(.isHeader)
            Text(subtitle)
                .typoGraphy(.B2InterSemibold12)
                .foregroundStyle(ProfileV3Theme.Palette.errorStateSubtitle)
                .multilineTextAlignment(.center)
                .frame(maxWidth: Layout.subtitleWidth)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Layout.subtitleTop)
            Button(action: action) {
                HStack(spacing: Layout.retrySpacing) {
                    ATIcon.SwiftUIImage.refresh
                        .profileV3Icon(Layout.retryIcon)
                    Text(actionTitle)
                        .typoGraphy(.B1InterSemibold14)
                }
                .foregroundStyle(Color(at: .backgroundDarkTheme))
                .padding(Layout.retryHitInset)
                .contentShape(Rectangle())
            }
            .buttonStyle(.profileV3Pressable(.selection))
            .padding(-Layout.retryHitInset)
            .padding(.top, Layout.retryTop)
            .accessibilityLabel(actionTitle)
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
}

#if DEBUG
#Preview("Error state") {
    ProfileV3ErrorState {}
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(at: .pureWhite))
}
#endif
