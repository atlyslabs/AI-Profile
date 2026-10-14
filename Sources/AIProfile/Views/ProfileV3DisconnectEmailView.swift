import ATUIKit
import SwiftUI

struct ProfileV3DisconnectEmailView: View {
    var confirm: ProfileV3DisconnectConfirm?
    var isDisconnecting = false
    let onBack: () -> Void
    let onDisconnect: () -> Void
    let onStop: () -> Void

    @State private var hasArrived = false
    @State private var hasConsented = false

    private var consentLabel: String { confirm?.consentLabel ?? ProfileV3Strings.disconnectConsent }

    private var isConsentRequired: Bool { confirm?.isConsentRequired ?? true }

    var body: some View {
        ZStack(alignment: .bottom) {
            confirmScreen
            if isDisconnecting {
                Color(at: .pureBlack)
                    .opacity(ProfileV3Theme.Motion.progressScrimOpacity)
                    .ignoresSafeArea()
                    .transition(.opacity.animation(ProfileV3Theme.Motion.progressScrim))
                ProfileV3DisconnectProgressPanel(onStop: onStop)
                    .transition(.move(edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(at: .pureWhite))
        .animation(ProfileV3Theme.Motion.progressPanel, value: isDisconnecting)
    }

    private var confirmScreen: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heading
                    losses
                        .padding(.top, ProfileV3Theme.Sizes.Disconnect.lossesTop)
                    terms
                        .padding(.horizontal, ProfileV3Theme.Sizes.Disconnect.termsInset)
                        .padding(.top, ProfileV3Theme.Sizes.Disconnect.termsTop)
                    consent
                        .padding(.horizontal, ProfileV3Theme.Sizes.Disconnect.termsInset)
                        .padding(.top, ProfileV3Theme.Sizes.Disconnect.consentTop)
                }
                .padding(.top, ProfileV3Theme.Sizes.Disconnect.topInset)
                .padding(.bottom, ProfileV3Theme.Sizes.Disconnect.scrollBottom)
            }
            .scrollDisabled(isDisconnecting)
            HStack {
                ProfileV3CircleIconButton.back(action: onBack)
                Spacer()
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Sizes.Disconnect.backTop)
            .opacity(isDisconnecting ? 0 : 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) { footer }
        .opacity(hasArrived ? 1 : 0)
        .offset(y: hasArrived ? 0 : ProfileV3Theme.Motion.disconnectEnterRise)
        .onAppear {
            withAnimation(ProfileV3Theme.Motion.disconnectEnter) { hasArrived = true }
        }
    }

    private var heading: some View {
        VStack(spacing: 0) {
            ProfileV3RemoteImage(url: ProfileV3ConnectorArt.gmail.url, contentMode: .fit, placeholder: .clear)
                .frame(width: ProfileV3Theme.Sizes.Disconnect.logo, height: ProfileV3Theme.Sizes.Disconnect.logo)
                .accessibilityHidden(true)
            Text(confirm?.title ?? ProfileV3Strings.disconnectConfirmTitle)
                .typoGraphy(.H6InterMedium18)
                .foregroundStyle(ProfileV3Theme.Palette.confirmTitle)
                .frame(width: ProfileV3Theme.Sizes.Confirmation.titleWidth)
                .padding(.top, ProfileV3Theme.Sizes.Disconnect.titleTop)
            Text(confirm?.warning ?? ProfileV3Strings.disconnectConfirmBody)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(ProfileV3Theme.Palette.confirmBody)
                .frame(width: ProfileV3Theme.Sizes.Confirmation.bodyWidth)
                .padding(.top, ProfileV3Theme.Sizes.Disconnect.bodyTop)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private var losses: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(
                Array((confirm?.losses ?? ProfileV3Strings.disconnectLosses).enumerated()),
                id: \.offset
            ) { _, item in
                VStack(spacing: ProfileV3Theme.Sizes.Disconnect.lossSpacing) {
                    ATIcon.SwiftUIImage.cancel
                        .profileV3Icon(ProfileV3Theme.Icon.xl)
                        .foregroundStyle(ProfileV3Theme.Palette.confirmBody)
                    Text(item)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(ProfileV3Theme.Palette.confirmBody)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.Disconnect.lossesInset)
    }

    private var terms: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Disconnect.termsSpacing) {
            Text(confirm?.detailIntro ?? ProfileV3Strings.disconnectTermsIntro)
            Text(ProfileV3Strings.disconnectTermsListLead)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(
                    Array((confirm?.detailLosses ?? ProfileV3Strings.disconnectTermsItems).enumerated()),
                    id: \.offset
                ) { _, item in
                    Text(ProfileV3Strings.bulleted(item))
                }
            }
            ForEach(
                Array((confirm?.detailParagraphs ?? ProfileV3Strings.disconnectTermsClosing).enumerated()),
                id: \.offset
            ) { _, paragraph in
                Text(paragraph)
            }
        }
        .typoGraphy(.B1InterMedium14)
        .foregroundStyle(Color(at: .neutralGrey600))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var consent: some View {
        Button {
            withAnimation(ProfileV3Theme.Motion.consentReveal) { hasConsented.toggle() }
        } label: {
            HStack(spacing: ProfileV3Theme.Sizes.Disconnect.consentSpacing) {
                consentBox
                Text(consentLabel)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(ProfileV3Theme.statusTextGradient)
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(consentLabel)
        .accessibilityAddTraits(hasConsented ? [.isButton, .isSelected] : .isButton)
    }

    @ViewBuilder
    private var consentBox: some View {
        if hasConsented {
            ATIcon.SwiftUIImage.checkBox
                .profileV3Icon(ProfileV3Theme.Sizes.Disconnect.consentBox)
                .foregroundStyle(ProfileV3Theme.Palette.confirmTitle)
        } else {
            RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.xxs, style: .continuous)
                .stroke(
                    ProfileV3Theme.Palette.confirmTitle,
                    lineWidth: ProfileV3Theme.Stroke.regular
                )
                .frame(
                    width: ProfileV3Theme.Sizes.Disconnect.consentBox,
                    height: ProfileV3Theme.Sizes.Disconnect.consentBox
                )
        }
    }

    private var footer: some View {
        VStack(spacing: ProfileV3Theme.Sizes.Disconnect.footerSpacing) {
            if hasConsented || !isConsentRequired {
                ProfileV3ContinueButton(
                    title: confirm?.confirmTitle ?? ProfileV3Strings.disconnectEmail,
                    tint: ProfileV3Theme.Palette.destructive,
                    action: onDisconnect
                )
                .transition(.opacity)
            }
            ProfileV3ContinueButton(title: confirm?.cancelTitle ?? ProfileV3Strings.dontDisconnect, action: onBack)
        }
        .profileV3CTABar(top: ProfileV3Theme.Sizes.Disconnect.barTop)
        .opacity(isDisconnecting ? 0 : 1)
        .animation(ProfileV3Theme.Motion.consentReveal, value: hasConsented)
    }
}

private struct ProfileV3DisconnectProgressPanel: View {
    let onStop: () -> Void

    @State private var isBreathing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            severedLink
            Text(ProfileV3Strings.disconnectProgressTitle)
                .typoGraphy(.H6InterMedium18)
                .foregroundStyle(ProfileV3Theme.Palette.confirmTitle)
                .padding(.top, ProfileV3Theme.Sizes.Progress.titleTop)
            Text(ProfileV3Strings.disconnectProgressBody)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(ProfileV3Theme.Palette.confirmBody)
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
        .padding(.top, ProfileV3Theme.Sizes.Progress.panelTop)
        .padding(.bottom, ProfileV3Theme.Sizes.Disconnect.footerBottom)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: ProfileV3Theme.Sizes.Progress.panelRadius,
                topTrailingRadius: ProfileV3Theme.Sizes.Progress.panelRadius,
                style: .continuous
            )
            .fill(Color(at: .pureWhite))
            .ignoresSafeArea(edges: .bottom)
        )
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
#Preview("Disconnect email") {
    ProfileV3DisconnectEmailView(onBack: {}, onDisconnect: {}, onStop: {})
}

#Preview("Disconnect email · running") {
    ProfileV3DisconnectEmailView(isDisconnecting: true, onBack: {}, onDisconnect: {}, onStop: {})
}

#Preview("Disconnect email · server copy") {
    ProfileV3DisconnectEmailView(
        confirm: ProfileV3Fixtures.disconnectConfirm(.gmail),
        onBack: {},
        onDisconnect: {},
        onStop: {}
    )
}

#Preview("Disconnect email · no consent needed") {
    ProfileV3DisconnectEmailView(
        confirm: ProfileV3Fixtures.disconnectConfirm(.gmail, isConsentRequired: false),
        onBack: {},
        onDisconnect: {},
        onStop: {}
    )
}
#endif
