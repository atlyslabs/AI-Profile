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
                    .id(intro)
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

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var entranceStart = Date()
    @State private var isEntranceDone: Bool

    init(intro: ProfileV3GloveBoxIntro, animatesEntrance: Bool = true, onAction: @escaping () -> Void) {
        self.intro = intro
        self.onAction = onAction
        _isEntranceDone = State(initialValue: !animatesEntrance)
    }

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Motion = ProfileV3Theme.GloveBox.Motion.Intro

    var body: some View {
        TimelineView(.animation(paused: isEntranceDone || reduceMotion)) { context in
            content(at: elapsed(at: context.date))
        }
        .task {
            guard !isEntranceDone else { return }
            if !reduceMotion {
                try? await Task.sleep(for: .seconds(Motion.delay + Motion.duration))
            }
            isEntranceDone = true
        }
    }

    private func elapsed(at date: Date) -> Double {
        isEntranceDone || reduceMotion ? .infinity : date.timeIntervalSince(entranceStart) - Motion.delay
    }

    private func content(at time: Double) -> some View {
        ZStack {
            stack(showing: .card, at: time)
                .background(card(at: time))
                .opacity(Motion.fade.value(at: time))
                .scaleEffect(Motion.cardScale.value(at: time))
                .offset(x: Motion.cardX.value(at: time), y: Motion.cardY.value(at: time))
            stack(showing: .copy, at: time)
        }
    }

    private enum Part {
        case card
        case copy
    }

    private func stack(showing part: Part, at time: Double) -> some View {
        let showsCopy = part == .copy
        return VStack(spacing: 0) {
            artwork
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .opacity(showsCopy ? 0 : 1)
            if !intro.title.isEmpty {
                Text(intro.title)
                    .typoGraphy(.H3DentonMedium28)
                    .foregroundStyle(Color(at: .pureBlack))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: Layout.titleWidth)
                    .introRise(showsCopy, at: time)
                    .padding(.top, Layout.titleTop)
            }
            if !intro.subtitle.isEmpty {
                Text(intro.subtitle)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.GloveBox.Palette.aboutOpacity))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: Layout.subtitleWidth)
                    .introRise(showsCopy, at: time)
                    .padding(.top, Layout.subtitleTop)
            }
            if !intro.actionTitle.isEmpty {
                ProfileV3GloveBoxActionButton(title: intro.actionTitle, action: onAction)
                    .padding(.horizontal, Layout.actionInset)
                    .introRise(showsCopy, at: time)
                    .padding(.top, Layout.actionTop)
            }
        }
        .padding(.bottom, Layout.cardBottom)
        .frame(maxWidth: .infinity, maxHeight: Layout.cardMaxHeight)
        .allowsHitTesting(showsCopy)
        .accessibilityHidden(!showsCopy)
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

    private func card(at time: Double) -> some View {
        let shape = RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous)
        return shape
            .fill(Color(at: .pureWhite))
            .overlay(shape.fill(ProfileV3Theme.GloveBox.cardShading))
            .overlay { shimmer(at: time).clipShape(shape) }
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

    @ViewBuilder
    private func shimmer(at time: Double) -> some View {
        let opacity = Motion.shimmerOpacity.value(at: time)
        if opacity > 0 {
            GeometryReader { proxy in
                Rectangle()
                    .fill(ProfileV3Theme.GloveBox.shimmerGradient)
                    .offset(x: proxy.size.width * (Motion.shimmerStart + Motion.shimmerTravel.value(at: time)))
            }
            .opacity(opacity)
            .allowsHitTesting(false)
        }
    }
}

private typealias IntroMotion = ProfileV3Theme.GloveBox.Motion.Intro

private extension View {
    func introRise(_ isShown: Bool, at time: Double) -> some View {
        opacity(isShown ? IntroMotion.fade.value(at: time) : 0)
            .offset(y: IntroMotion.rise.value(at: time))
    }
}
