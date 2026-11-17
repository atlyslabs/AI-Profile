import ATUIKit
import SwiftUI

struct ProfileV3SettingsGloveBoxCard: View {
    let showsActivate: Bool
    let action: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Page = ProfileV3Theme.Sizes.SettingsPage

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: Page.cardIconSpacing) {
                ATIcon.SwiftUIImage.groupWork
                    .profileV3Icon(ProfileV3Theme.Icon.lg)
                    .frame(width: ProfileV3Theme.Icon.lg, height: ProfileV3Theme.Icon.lg)
                    .foregroundStyle(Color(at: .pureBlack))
                VStack(alignment: .leading, spacing: 0) {
                    Text(ProfileV3GloveBoxCopy.title)
                        .typoGraphy(.B1InterSemibold14)
                        .foregroundStyle(Color(at: .pureBlack))
                    Text(ProfileV3GloveBoxCopy.settingsSubtitle)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.GloveBox.Palette.settingsSubtitleOpacity))
                        .padding(.top, Layout.settingsSubtitleTop)
                    Text(ProfileV3GloveBoxCopy.settingsDescription)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                        .frame(maxWidth: Layout.settingsBodyWidth, minHeight: Layout.settingsBodyLines, alignment: .leading)
                        .padding(.top, Layout.settingsBodyTop)
                    if showsActivate {
                        ProfileV3GloveBoxPill(label: ProfileV3Strings.activate, showsBolt: true, border: .spectrum)
                            .padding(.top, Layout.settingsPillTop)
                            .transition(.opacity)
                    }
                }
                .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .padding(Layout.settingsCardInset)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background { dials }
            .profileV3SettingsSurface()
        }
        .buttonStyle(.profileV3Pressable)
    }

    private var dials: some View {
        Canvas { context, size in
            let icons = [ProfileV3GloveBoxArt.dialCreditCard.image, ProfileV3GloveBoxArt.dialCall.image, ProfileV3GloveBoxArt.dialMail.image]
            for (icon, dial) in zip(icons, Layout.settingsDials) {
                ProfileV3GloveBoxDial.draw(
                    icon,
                    centre: CGPoint(x: size.width - dial.fromTrailing, y: dial.centreY),
                    diameter: dial.diameter,
                    in: context
                )
            }
        }
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Settings glove box card") {
    VStack(spacing: ProfileV3Theme.Space.s24) {
        ProfileV3SettingsGloveBoxCard(showsActivate: true) {}
        ProfileV3SettingsGloveBoxCard(showsActivate: false) {}
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
