import ATUIKit
import SwiftUI

struct ProfileV3GloveBoxView: View {
    @ObservedObject var viewModel: ProfileV3GloveBoxViewModel
    let onBack: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        ZStack(alignment: .bottom) {
            page
                .blur(radius: viewModel.openEmail == nil ? 0 : Layout.dimBlur)
                .allowsHitTesting(viewModel.openEmail == nil)
                .accessibilityHidden(viewModel.openEmail != nil)
            if let email = viewModel.openEmail {
                ProfileV3Theme.GloveBox.Palette.dim
                    .ignoresSafeArea()
                    .onTapGesture(perform: viewModel.closeEmail)
                    .transition(.opacity)
                ProfileV3GloveBoxEmailDetail(
                    email: email,
                    onBack: viewModel.closeEmail,
                    onFollowUp: viewModel.tapFollowUp
                )
                .transition(.move(edge: .bottom))
            }
        }
    }

    private var page: some View {
        VStack(spacing: 0) {
            ProfileV3BackTagHeader(title: viewModel.gloveBox.title, top: Layout.headerTop, onBack: onBack)
            switch viewModel.gloveBox.stage {
            case .intro(let intro):
                ProfileV3GloveBoxIntroCard(intro: intro, onAction: viewModel.tapIntroAction)
                    .padding(.horizontal, Layout.cardMargin)
                    .padding(.top, Layout.cardTop)
                    .padding(.bottom, Layout.cardMinBottomGap)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .transition(.opacity)
            case .inbox(let inbox):
                ProfileV3GloveBoxInboxView(
                    inbox: inbox,
                    isCopied: viewModel.isCopied,
                    copies: viewModel.copies,
                    onCopy: viewModel.copyAddress,
                    onOpen: viewModel.open
                )
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(background.ignoresSafeArea())
    }

    private var background: Color {
        if case .inbox = viewModel.gloveBox.stage { return ProfileV3Theme.GloveBox.Palette.inboxBackground }
        return Color(at: .pureWhite)
    }
}

struct ProfileV3GloveBoxIntroCard: View {
    let intro: ProfileV3GloveBoxIntro
    let onAction: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        VStack(spacing: 0) {
            artwork
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            if !intro.title.isEmpty {
                Text(intro.title)
                    .typoGraphy(.H3DentonMedium28)
                    .foregroundStyle(Color(at: .pureBlack))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: Layout.titleWidth)
                    .padding(.top, Layout.titleTop)
            }
            if !intro.subtitle.isEmpty {
                Text(intro.subtitle)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.GloveBox.Palette.aboutOpacity))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: Layout.subtitleWidth)
                    .padding(.top, Layout.subtitleTop)
            }
            if !intro.actionTitle.isEmpty {
                ProfileV3GloveBoxActionButton(title: intro.actionTitle, action: onAction)
                    .padding(.horizontal, Layout.actionInset)
                    .padding(.top, Layout.actionTop)
            }
        }
        .padding(.bottom, Layout.cardBottom)
        .frame(maxWidth: .infinity, maxHeight: Layout.cardMaxHeight)
        .background(card)
    }

    private var artwork: some View {
        ZStack {
            Circle()
                .fill(ProfileV3Theme.GloveBox.glowGradient)
                .opacity(ProfileV3Theme.GloveBox.Palette.glowOpacity)
                .frame(width: Layout.glow, height: Layout.glow)
                .blur(radius: Layout.glowBlur)
                .offset(y: Layout.glowOffsetY)
            ProfileV3GloveBoxArt.envelope.image
                .resizable()
                .scaledToFit()
                .frame(width: Layout.envelope, height: Layout.envelope)
        }
        .accessibilityHidden(true)
    }

    private var card: some View {
        let shape = RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous)
        return shape
            .fill(Color(at: .pureWhite))
            .overlay(shape.fill(ProfileV3Theme.GloveBox.cardShading))
            .shadow(
                color: ProfileV3Theme.GloveBox.Palette.cardHighlight,
                radius: Layout.cardShadowRadius,
                x: Layout.cardHighlightOffset.width,
                y: Layout.cardHighlightOffset.height
            )
            .shadow(
                color: ProfileV3Theme.GloveBox.Palette.cardShadow,
                radius: Layout.cardShadowRadius,
                x: Layout.cardShadowOffset.width,
                y: Layout.cardShadowOffset.height
            )
    }
}
