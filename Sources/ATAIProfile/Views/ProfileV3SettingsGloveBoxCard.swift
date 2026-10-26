import ATUIKit
import SwiftUI

struct ProfileV3SettingsGloveBoxCard: View {
    let showsActivate: Bool
    let action: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                Text(ProfileV3GloveBoxCopy.title)
                    .typoGraphy(.H7InterSemibold16)
                    .foregroundStyle(Color(at: .pureBlack))
                    .frame(height: Layout.settingsTitleLine)
                Text(ProfileV3GloveBoxCopy.settingsSubtitle)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.GloveBox.Palette.settingsSubtitleOpacity))
                    .frame(height: Layout.settingsSubtitleLine)
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
            .padding(.top, Layout.settingsTitleTop)
            .padding(.horizontal, Layout.settingsCardInset)
            .padding(.bottom, Layout.settingsCardInset)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background { dials }
            .profileV3AccessCard()
            .contentShape(RoundedRectangle(cornerRadius: ProfileV3Theme.Sizes.InformationAccess.cardRadius, style: .continuous))
        }
        .buttonStyle(.profileV3Pressable)
    }

    private var dials: some View {
        Canvas { context, size in
            let icons = [ATIcon.SwiftUIImage.creditCard, ATIcon.SwiftUIImage.call, ATIcon.SwiftUIImage.mail]
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
