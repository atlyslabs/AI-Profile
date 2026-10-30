import ATUIKit
import SwiftUI

struct ProfileV3InstagramConnectSheet: View {
    @ObservedObject var model: ProfileV3InstagramConnectModel

    private typealias Layout = ProfileV3Theme.Sizes.InstagramConnect
    private typealias Credentials = ProfileV3Theme.Sizes.AppCredentials

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                switch model.step {
                case .explainer:
                    explainer.transition(.opacity)
                case .username:
                    usernameStep.transition(.opacity)
                case .redirect:
                    redirectStep.transition(.opacity)
                }
            }
            .animation(ProfileV3Theme.Motion.contentSwitch, value: model.step)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .overlay(alignment: .top) { header }
            if model.step == .username {
                bar
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(alignment: .top) { background }
        .presentationDetents([.height(Layout.sheetHeight)])
        .presentationCornerRadius(Credentials.cornerRadius)
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled(model.phase == .saving)
        .sensoryFeedback(.success, trigger: model.phase == .saved)
        .task { model.start() }
        .onDisappear(perform: model.cancel)
    }

    private var header: some View {
        ProfileV3AgentSheetChrome(control: .close(model.close), isEnabled: model.phase != .saving)
    }

    @ViewBuilder
    private var background: some View {
        ZStack(alignment: .top) {
            Color(at: .pureWhite)
            switch model.step {
            case .explainer:
                ProfileV3RainbowGlow(diameter: Layout.wash)
                    .opacity(ProfileV3Theme.Opacity.aiConnectorWash)
                    .offset(y: Layout.washCentreY - Layout.wash / 2)
            case .redirect:
                ProfileV3Theme.instagramFollowWash
                    .frame(height: Layout.followWashHeight)
                    .offset(y: Layout.followWashTop)
            case .username:
                EmptyView()
            }
        }
        .ignoresSafeArea()
        .animation(ProfileV3Theme.Motion.contentSwitch, value: model.step)
        .accessibilityHidden(true)
    }

    private var shield: some View {
        ZStack(alignment: .top) {
            ProfileV3ShieldShape()
                .stroke(
                    Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.appShieldStroke),
                    lineWidth: Credentials.shieldStroke
                )
                .clipShape(ProfileV3ShieldShape())
            ProfileV3AppLogo(url: model.app.iconURL, size: Credentials.glyph)
                .frame(width: Credentials.glyph, height: Credentials.glyph)
                .padding(.top, Credentials.glyphTop)
        }
        .frame(width: Credentials.shield.width, height: Credentials.shield.height)
        .padding(.top, ProfileV3Theme.Sizes.Agent.backTop + Credentials.shieldTop)
        .accessibilityHidden(true)
    }

    private var explainer: some View {
        Button(action: model.continueFromExplainer) {
            VStack(spacing: 0) {
                shield
                VStack(spacing: Layout.cardSpacing) {
                    ProfileV3InstagramStepCard(
                        title: ProfileV3Strings.instagramStepUsername,
                        detail: ProfileV3Strings.instagramStepUsernameDetail,
                        artWidth: Layout.handleArtWidth,
                        artTrailing: Layout.handleTrailing
                    ) {
                        ProfileV3InstagramHandleArt()
                    }
                    ProfileV3InstagramStepCard(
                        title: ProfileV3Strings.instagramStepRedirect,
                        detail: ProfileV3Strings.instagramStepRedirectDetail,
                        artWidth: Layout.orbArtWidth,
                        artTrailing: Layout.orbTrailing
                    ) {
                        ProfileV3AylOrb(size: Layout.cardOrb)
                            .rotationEffect(.degrees(Layout.cardOrbTilt))
                    }
                    ProfileV3InstagramStepCard(
                        title: ProfileV3Strings.instagramStepFollow,
                        detail: ProfileV3Strings.instagramStepFollowDetail,
                        detailWidth: Layout.followDetailWidth,
                        artWidth: Layout.followArtWidth,
                        artTrailing: Layout.followTrailing
                    ) {
                        ProfileV3InstagramFollowArt()
                    }
                }
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, Layout.cardsTop)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var usernameStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                shield
                Text(ProfileV3Strings.appUsernameTitle)
                    .typoGraphy(.H5InterMedium20)
                    .foregroundStyle(Color(at: .pureBlack))
                    .multilineTextAlignment(.center)
                    .frame(width: Credentials.titleWidth)
                    .padding(.top, Credentials.titleTop)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s8) {
                    ProfileV3CredentialField(
                        label: ProfileV3Strings.appUsernameLabel,
                        text: $model.username,
                        keyboard: .asciiCapable,
                        contentType: .username
                    )
                    if let error = model.errorMessage {
                        Text(error)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(ProfileV3Theme.Palette.destructive)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .disabled(model.phase != .idle)
                .padding(.top, Credentials.fieldsTop)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
    }

    private var bar: some View {
        VStack(spacing: Layout.noteToBar) {
            Text(ProfileV3Strings.appCredentialsNote)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.appCredentialsNote))
                .multilineTextAlignment(.center)
                .frame(width: Credentials.noteWidth)
            ProfileV3SubmitControl(
                phase: model.phase,
                title: ProfileV3Strings.appCredentialsAdd,
                successMessage: ProfileV3Strings.appUsernameAdded,
                isEnabled: model.canSubmit,
                action: model.submit
            )
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        }
        .padding(.top, Credentials.barTop)
        .padding(.bottom, ProfileV3Theme.Sizes.Save.barBottom)
    }

    private var redirectStep: some View {
        VStack(spacing: 0) {
            shield
            ProfileV3CredentialField(
                label: ProfileV3Strings.appUsernameLabel,
                text: .constant(model.trimmedUsername),
                isEditable: false
            ) {
                ProfileV3StatusDot(kind: .complete)
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, Layout.redirectFieldTop)
            ProfileV3AylOrb(size: Layout.redirectOrb)
                .padding(.top, Layout.redirectOrbTop)
            Text(ProfileV3Strings.instagramComeSayHi)
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.instagramLead))
                .padding(.top, Layout.redirectLeadTop)
            Text(ProfileV3Strings.instagramFollowUs)
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .padding(.top, Layout.redirectTitleTop)
            Spacer(minLength: 0)
            Text(ProfileV3Strings.instagramRedirecting)
                .typoGraphy(.B1InterSemibold14)
                .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.instagramRedirecting))
                .padding(.bottom, Layout.redirectingBottom)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .accessibilityElement(children: .combine)
    }
}

private struct ProfileV3InstagramStepCard<Art: View>: View {
    let title: String
    let detail: String
    var detailWidth: CGFloat?
    let artWidth: CGFloat
    let artTrailing: CGFloat
    @ViewBuilder var art: () -> Art

    private typealias Layout = ProfileV3Theme.Sizes.InstagramConnect

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: Layout.cardTextSpacing) {
                Text(title)
                    .typoGraphy(.H7InterSemibold16)
                    .foregroundStyle(ProfileV3Theme.errorStateTitleGradient)
                    .lineLimit(1)
                    .minimumScaleFactor(Layout.cardTitleMinScale)
                Text(detail)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.instagramLead))
                    .frame(maxWidth: detailWidth, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            art()
                .frame(width: artWidth)
                .accessibilityHidden(true)
        }
        .padding(.leading, Layout.cardLeading)
        .padding(.trailing, artTrailing)
        .frame(height: Layout.cardHeight)
        .background(
            RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous)
                .fill(ProfileV3Theme.instagramCardGradient)
        )
        .accessibilityElement(children: .combine)
    }
}

private struct ProfileV3InstagramHandleArt: View {
    private typealias Layout = ProfileV3Theme.Sizes.InstagramConnect

    var body: some View {
        VStack(spacing: Layout.handleSpacing) {
            Text(verbatim: "@")
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .rotationEffect(.degrees(Layout.handleTilt))
            Text(ProfileV3Strings.instagramSampleHandle)
                .typoGraphy(.H7InterSemibold16)
                .foregroundStyle(Color(at: .pureWhite))
                .lineLimit(1)
                .padding(.horizontal, Layout.handlePadding)
                .frame(height: Layout.handleHeight)
                .background(Capsule().fill(ProfileV3Theme.instagramHandleGradient))
        }
    }
}

private struct ProfileV3InstagramFollowArt: View {
    private typealias Layout = ProfileV3Theme.Sizes.InstagramConnect

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.followSpacing) {
            Text(ProfileV3Strings.instagramFollow)
                .font(Font.Inter.get(size: Layout.followFontSize, weight: .semibold))
                .foregroundStyle(Color(at: .pureWhite))
                .frame(width: Layout.followWidth, height: Layout.followHeight)
                .background(
                    RoundedRectangle(cornerRadius: Layout.followRadius, style: .continuous)
                        .fill(ProfileV3Theme.Palette.instagramFollow)
                )
            Text(ProfileV3Strings.instagramHi)
                .font(Font.Inter.get(size: Layout.hiFontSize, weight: .semibold))
                .foregroundStyle(Color(at: .pureWhite))
                .frame(width: Layout.hiWidth, height: Layout.hiHeight)
                .background(Capsule().fill(ProfileV3Theme.Palette.instagramHi))
                .overlay(alignment: .bottomLeading) {
                    ZStack(alignment: .topLeading) {
                        Circle()
                            .fill(ProfileV3Theme.Palette.instagramHi)
                            .frame(width: Layout.hiTailLarge, height: Layout.hiTailLarge)
                            .offset(x: Layout.hiTailLargeOffset.width, y: Layout.hiTailLargeOffset.height)
                        Circle()
                            .fill(ProfileV3Theme.Palette.instagramHi)
                            .frame(width: Layout.hiTailSmall, height: Layout.hiTailSmall)
                            .offset(x: Layout.hiTailSmallOffset.width, y: Layout.hiTailSmallOffset.height)
                    }
                    .frame(width: Layout.hiWidth, height: Layout.hiHeight, alignment: .topLeading)
                }
        }
    }
}

struct ProfileV3AylOrb: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(ProfileV3Theme.aylOrbGradient)
            ProfileV3GloveBoxArt.aylMark.image
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(ProfileV3Theme.Palette.aylOrbMark)
                .frame(width: size * ProfileV3Theme.Sizes.InstagramConnect.orbMarkRatio)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

#if DEBUG
private struct ProfileV3InstagramConnectPreview: View {
    @StateObject private var model = ProfileV3InstagramConnectModel(
        app: ProfileV3AppAccessFixtures.content.apps[0],
        repository: ProfileV3MockRepository(delay: .milliseconds(300)),
        openURL: { _ in },
        onFinish: {}
    )

    var body: some View {
        Color.gray
            .sheet(isPresented: .constant(true)) {
                ProfileV3InstagramConnectSheet(model: model)
            }
    }
}

#Preview("Instagram connect") {
    ProfileV3InstagramConnectPreview()
}
#endif
