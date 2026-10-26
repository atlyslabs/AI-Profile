import ATUIKit
import SwiftUI

struct ProfileV3DisconnectProgressSheet: View {
    var bottomInset: CGFloat = 0
    let onStop: () -> Void

    @State private var isBreathing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetGrabber()
            severedLink
                .padding(.top, ProfileV3Theme.Sizes.Progress.linkTop)
            Text(ProfileV3Strings.disconnectProgressTitle)
                .typoGraphy(.H6InterMedium18)
                .foregroundStyle(ProfileV3Theme.Palette.confirmTitle)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, ProfileV3Theme.Sizes.Progress.titleTop)
            Text(ProfileV3Strings.disconnectProgressBody)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(ProfileV3Theme.Palette.confirmBody)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: ProfileV3Theme.Sizes.Progress.bodyWidth)
                .padding(.top, ProfileV3Theme.Sizes.Progress.bodyTop)
                .opacity(isBreathing ? ProfileV3Theme.Motion.progressBreathLow : 1)
                .animation(
                    reduceMotion ? nil : ProfileV3Theme.Motion.progressBreath.repeatForever(autoreverses: true),
                    value: isBreathing
                )
            ProfileV3ContinueButton(
                title: ProfileV3Strings.stopDisconnecting,
                icon: ProfileV3Vector.autostop.image,
                iconSize: ProfileV3Theme.Icon.lg,
                action: onStop
            )
            .padding(.top, ProfileV3Theme.Sizes.Progress.stopTop)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.bottom, ProfileV3Theme.Sizes.ctaBarBottom + bottomInset)
        .frame(maxWidth: .infinity)
        .background(Color(at: .pureWhite))
        .onAppear { isBreathing = true }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ProfileV3Strings.disconnectProgressTitle)
    }

    private var severedLink: some View {
        HStack(spacing: 0) {
            ProfileV3ConnectorGlyph.atlysMark.image
                .resizable()
                .scaledToFit()
                .frame(
                    width: ProfileV3Theme.Sizes.Progress.atlysMark,
                    height: ProfileV3Theme.Sizes.Progress.atlysMark
                )
                .rotationEffect(.degrees(ProfileV3Theme.Rotation.quarter))
            ProfileV3ConnectorGlyph.disconnectLink.image
                .resizable()
                .scaledToFit()
                .frame(
                    width: ProfileV3Theme.Sizes.Progress.linkWidth,
                    height: ProfileV3Theme.Sizes.Progress.linkHeight
                )
                .padding(.leading, ProfileV3Theme.Sizes.Progress.linkLeading)
                .padding(.trailing, ProfileV3Theme.Sizes.Progress.linkTrailing)
            ProfileV3RemoteImage(url: ProfileV3ConnectorArt.gmail.url, contentMode: .fit, placeholder: .clear)
                .frame(
                    width: ProfileV3Theme.Sizes.Progress.gmailMark,
                    height: ProfileV3Theme.Sizes.Progress.gmailMark
                )
        }
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Disconnect progress") {
    ProfileV3DisconnectProgressSheet {}
        .frame(maxHeight: .infinity, alignment: .bottom)
        .background(Color(at: .neutralGrey400))
}
#endif
