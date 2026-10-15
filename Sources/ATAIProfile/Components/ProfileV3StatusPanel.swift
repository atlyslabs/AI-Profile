import ATUIKit
import SwiftUI

struct ProfileV3StatusPanel: View {
    let title: String
    let subtitle: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: ProfileV3Theme.Space.s50) {
            VStack(spacing: ProfileV3Theme.Space.s16) {
                VStack(spacing: ProfileV3Theme.Space.s28) {
                    ATIcon.SwiftUIImage.errorOutline
                        .profileV3Icon(ProfileV3Theme.Icon.xxl)
                        .foregroundStyle(ProfileV3Theme.Palette.statusIcon)
                        .accessibilityHidden(true)
                    Text(title)
                        .typoGraphy(.H5InterMedium20)
                        .foregroundStyle(ProfileV3Theme.Palette.statusTitle)
                        .multilineTextAlignment(.center)
                }
                Text(subtitle)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey400))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: ProfileV3Theme.Sizes.statusSubtitleWidth)
            }
            ProfileV3PillButton(title: actionTitle, size: .medium, action: action)
        }
        .frame(maxWidth: ProfileV3Theme.Sizes.statusPanelWidth)
    }
}

#if DEBUG
#Preview("Status panel") {
    ProfileV3StatusPanel(
        title: ProfileV3Strings.loadFailedTitle,
        subtitle: ProfileV3Strings.loadFailedSubtitle,
        actionTitle: ProfileV3Strings.retry,
        action: {}
    )
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
