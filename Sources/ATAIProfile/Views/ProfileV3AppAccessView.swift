import ATUIKit
import SwiftUI

struct ProfileV3AppAccessView: View {
    let onBack: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3BackTagHeader(
                title: ProfileV3Strings.appAccess,
                top: ProfileV3Theme.Sizes.SettingsPage.headerTop,
                onBack: onBack
            )
            ProfileV3RemoteImage(url: ProfileV3ConnectorArt.appAccess.url, contentMode: .fit, placeholder: .clear)
                .frame(
                    width: ProfileV3Theme.Sizes.SettingsPage.appArtSize.width,
                    height: ProfileV3Theme.Sizes.SettingsPage.appArtSize.height
                )
                .background { ProfileV3AccessGlow() }
                .padding(.top, Layout.comingSoonArtTop)
                .accessibilityHidden(true)
            Text(ProfileV3Strings.comingSoon)
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .padding(.top, Layout.comingSoonTitleTop)
            Text(ProfileV3Strings.appAccessComingSoon)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.accessSubtitle))
                .frame(maxWidth: Layout.comingSoonBodyWidth)
                .padding(.top, Layout.subtitleTop)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite))
    }
}

#if DEBUG
#Preview("App access") {
    ProfileV3AppAccessView(onBack: {})
}
#endif
