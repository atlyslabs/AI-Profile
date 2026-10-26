import ATUIKit
import SwiftUI

struct ProfileV3DisconnectEmailView: View {
    var confirm: ProfileV3DisconnectConfirm?
    var isDisconnecting = false
    let onBack: () -> Void
    let onDisconnect: () -> Void

    @State private var hasArrived = false
    @State private var hasConsented = false

    private var consentLabel: String { confirm?.consentLabel ?? "" }

    private var isConsentRequired: Bool { !consentLabel.isEmpty && confirm?.isConsentRequired ?? true }

    var body: some View {
        confirmScreen
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
                    if !consentLabel.isEmpty {
                        consent
                            .padding(.horizontal, ProfileV3Theme.Sizes.Disconnect.termsInset)
                            .padding(.top, ProfileV3Theme.Sizes.Disconnect.consentTop)
                    }
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
            if let title = confirm?.title.nonEmpty {
                Text(title)
                    .typoGraphy(.H6InterMedium18)
                    .foregroundStyle(ProfileV3Theme.Palette.confirmTitle)
                    .frame(width: ProfileV3Theme.Sizes.Confirmation.titleWidth)
                    .padding(.top, ProfileV3Theme.Sizes.Disconnect.titleTop)
            }
            if let warning = confirm?.warning.nonEmpty {
                Text(warning)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(ProfileV3Theme.Palette.confirmBody)
                    .frame(width: ProfileV3Theme.Sizes.Confirmation.bodyWidth)
                    .padding(.top, ProfileV3Theme.Sizes.Disconnect.bodyTop)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private var losses: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(
                Array((confirm?.losses ?? []).enumerated()),
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
            if let intro = confirm?.detailIntro.nonEmpty {
                Text(intro)
            }
            if let detailLosses = confirm?.detailLosses.nonEmpty {
                Text(ProfileV3Strings.disconnectTermsListLead)
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(detailLosses.enumerated()), id: \.offset) { _, item in
                        Text(ProfileV3Strings.bulleted(item))
                    }
                }
            }
            ForEach(
                Array((confirm?.detailParagraphs ?? []).enumerated()),
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
            if hasConsented || !isConsentRequired, let confirmTitle = confirm?.confirmTitle.nonEmpty {
                ProfileV3ContinueButton(
                    title: confirmTitle,
                    tint: ProfileV3Theme.Palette.destructive,
                    action: onDisconnect
                )
                .transition(.opacity)
            }
            if let cancelTitle = confirm?.cancelTitle.nonEmpty {
                ProfileV3ContinueButton(title: cancelTitle, action: onBack)
            }
        }
        .profileV3CTABar(top: ProfileV3Theme.Sizes.Disconnect.barTop)
        .opacity(isDisconnecting ? 0 : 1)
        .animation(ProfileV3Theme.Motion.consentReveal, value: hasConsented)
    }
}

#if DEBUG
#Preview("Disconnect email") {
    ProfileV3DisconnectEmailView(onBack: {}, onDisconnect: {})
}

#Preview("Disconnect email · server copy") {
    ProfileV3DisconnectEmailView(
        confirm: ProfileV3Fixtures.disconnectConfirm(.gmail),
        onBack: {},
        onDisconnect: {}
    )
}

#Preview("Disconnect email · no consent needed") {
    ProfileV3DisconnectEmailView(
        confirm: ProfileV3Fixtures.disconnectConfirm(.gmail, isConsentRequired: false),
        onBack: {},
        onDisconnect: {}
    )
}
#endif
