import ATUIKit
import SwiftUI

struct ProfileV3PartnersView: View {
    let partners: ProfileV3Partners
    let onBack: () -> Void
    let onOpenInfo: (ProfileV3Partner) -> Void

    @State private var focus = 0
    @State private var landing = ProfileV3PartnerLanding(startedAt: .now, flies: true)
    @State private var isLandingDone = false
    @GestureState(resetTransaction: Transaction(animation: ProfileV3Theme.Motion.entry)) private var dragY: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Layout = ProfileV3Theme.Sizes.Partners

    init(
        partners: ProfileV3Partners,
        focus: Int = 0,
        onBack: @escaping () -> Void,
        onOpenInfo: @escaping (ProfileV3Partner) -> Void
    ) {
        self.partners = partners
        self.onBack = onBack
        self.onOpenInfo = onOpenInfo
        _focus = State(initialValue: max(0, min(partners.partners.count - 1, focus)))
    }

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { proxy in
                wheel(width: proxy.size.width)
            }
            header
        }
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .contentShape(Rectangle())
        .gesture(swipe)
        .task(id: landing.startedAt) {
            isLandingDone = false
            try? await Task.sleep(for: .seconds(ProfileV3PartnerLanding.duration))
            guard !Task.isCancelled else { return }
            isLandingDone = true
        }
    }

    private var header: some View {
        VStack(spacing: 0) {
            ProfileV3BackTagHeader(title: nil, top: ProfileV3Theme.Sizes.SettingsPage.headerTop, onBack: onBack)
            Text(partners.title)
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .padding(.top, Layout.titleTop)
                .accessibilityAddTraits(.isHeader)
            if !partners.pageSubtitle.isEmpty {
                Text(partners.pageSubtitle)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.accessSubtitle))
                    .frame(maxWidth: Layout.subtitleWidth)
                    .padding(.top, Layout.titleSpacing)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .background(alignment: .top) {
            VStack(spacing: 0) {
                Color(at: .pureWhite)
                    .frame(height: Layout.headerSolid)
                LinearGradient(
                    colors: [Color(at: .pureWhite), Color(at: .pureWhite).opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: Layout.headerFade)
            }
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)
        }
    }

    private func wheel(width: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(partners.partners.enumerated()), id: \.element.id) { index, partner in
                let distance = index - focus
                if abs(distance) < Layout.offsets.count {
                    row(partner, index: index, distance: distance, width: width)
                }
            }
        }
        .frame(width: width, alignment: .topLeading)
        .animation(reduceMotion ? nil : ProfileV3Theme.Motion.entry, value: focus)
    }

    private func row(_ partner: ProfileV3Partner, index: Int, distance: Int, width: CGFloat) -> some View {
        let level = min(abs(distance), Layout.offsets.count - 1)
        let height = Layout.rowHeights[level]
        let centre = Layout.focusY + CGFloat(distance.signum()) * Layout.offsets[level] + dragY * Layout.dragFollow
        return HStack(alignment: .center, spacing: 0) {
            details(partner, isFocused: distance == 0, level: level)
                .frame(width: Layout.nameWidth, alignment: .leading)
            Spacer(minLength: 0)
            logo(partner, isFocused: distance == 0, level: level)
                .frame(width: Layout.logoCentreFromTrailing * 2, height: height)
        }
        .padding(.leading, Layout.listLeading)
        .frame(width: width, height: height)
        .contentShape(Rectangle())
        .onTapGesture { move(to: index) }
        .offset(y: centre - height / 2)
        .accessibilityElement(children: distance == 0 ? .contain : .combine)
        .accessibilityAddTraits(distance == 0 ? [.isButton, .isSelected] : .isButton)
        .accessibilityAction { move(to: index) }
    }

    private func details(_ partner: ProfileV3Partner, isFocused: Bool, level: Int) -> some View {
        VStack(alignment: .leading, spacing: Layout.focusTextSpacing) {
            Text(partner.name)
                .typoGraphy(isFocused ? .H5InterSemibold20 : .H7InterSemibold16)
                .foregroundStyle(Color(at: .pureBlack))
                .opacity(Layout.nameOpacities[level])
            if isFocused, partner.headline != nil || partner.body != nil {
                VStack(alignment: .leading, spacing: Layout.focusBodySpacing) {
                    if let headline = partner.headline {
                        Text(headline)
                            .typoGraphy(.H7InterSemibold16)
                            .foregroundStyle(Color(at: .pureBlack))
                            .frame(maxWidth: Layout.headlineWidth, alignment: .leading)
                    }
                    if let body = partner.body {
                        Text(body)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.accessSubtitle))
                    }
                }
                .transition(.opacity)
            }
        }
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private func logo(_ partner: ProfileV3Partner, isFocused: Bool, level: Int) -> some View {
        let size = Layout.logoSizes[level]
        if isFocused {
            focusedLogo(partner, size: size)
        } else {
            ProfileV3PartnerLogo(url: partner.logoURL, size: size)
                .opacity(Layout.logoOpacities[level])
                .blur(radius: Layout.logoBlurs[level])
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private func focusedLogo(_ partner: ProfileV3Partner, size: CGFloat) -> some View {
        let accent = partner.accentHex.map { Color(hex: $0) } ?? ProfileV3Theme.Palette.partnerAccentFallback
        Group {
            if reduceMotion {
                ProfileV3PartnerLogo(url: partner.logoURL, size: size)
            } else {
                TimelineView(.animation(minimumInterval: nil, paused: isLandingDone)) { context in
                    let pose = landing.pose(at: context.date)
                    ZStack {
                        ProfileV3PartnerRipple(size: size, accent: accent, ring: pose.ringOne)
                        ProfileV3PartnerRipple(size: size, accent: accent, ring: pose.ringTwo)
                        ProfileV3PartnerLogo(url: partner.logoURL, size: size)
                            .shadow(
                                color: accent.opacity(ProfileV3PartnerLanding.glowOpacity * pose.glow),
                                radius: Layout.glowRadius / 2 * max(pose.glow, ProfileV3PartnerLanding.glowRest)
                            )
                            .scaleEffect(pose.scale)
                            .blur(radius: pose.blur)
                            .opacity(pose.opacity)
                            .offset(pose.offset)
                    }
                }
            }
        }
        .overlay {
            if partner.infoURL != nil {
                ProfileV3PartnerInfoButton(name: partner.name) { onOpenInfo(partner) }
                    .offset(Layout.infoOffset)
            }
        }
        .accessibilityHidden(partner.infoURL == nil)
    }

    private var swipe: some Gesture {
        DragGesture(minimumDistance: ProfileV3Theme.Space.s10)
            .updating($dragY) { value, state, _ in state = value.translation.height }
            .onEnded { value in
                let flung = Int((-value.predictedEndTranslation.height / Layout.swipeStep).rounded())
                let dragged = abs(value.translation.height) > Layout.swipeDistance ? (value.translation.height < 0 ? 1 : -1) : 0
                let steps = flung == 0 ? dragged : max(-Layout.maxSwipeSteps, min(Layout.maxSwipeSteps, flung))
                move(to: focus + steps)
            }
    }

    private func move(to index: Int) {
        let next = max(0, min(partners.partners.count - 1, index))
        guard next != focus else { return }
        focus = next
        landing = ProfileV3PartnerLanding(startedAt: .now, flies: false)
    }
}

struct ProfileV3PartnerLanding: Equatable {
    struct Ring: Equatable {
        var scale: CGFloat = 1
        var opacity: Double = 0
        var lineWidth: CGFloat = 0
    }

    struct Pose: Equatable {
        var scale: CGFloat = 1
        var opacity: Double = 1
        var blur: CGFloat = 0
        var offset: CGSize = .zero
        var glow: Double = 0
        var ringOne = Ring()
        var ringTwo = Ring()
    }

    static let duration: TimeInterval = 4.614
    static let landed: TimeInterval = 1.418
    static let glowOpacity = 0.14
    static let glowRest = 0.45

    let startedAt: Date
    let flies: Bool

    func pose(at date: Date) -> Pose {
        let offset = flies ? 0 : Self.landed
        let time = min(max(date.timeIntervalSince(startedAt) + offset, 0), Self.duration)
        let pulse = Self.pulse.value(at: time)
        return Pose(
            scale: CGFloat(Self.scale.value(at: time) * pulse),
            opacity: Self.opacity.value(at: time),
            blur: CGFloat(Self.blur.value(at: time)),
            offset: CGSize(width: Self.offsetX.value(at: time), height: Self.offsetY.value(at: time)),
            glow: Self.glow.value(at: time),
            ringOne: Ring(
                scale: CGFloat(Self.ringOneScale.value(at: time)),
                opacity: Self.ringOneOpacity.value(at: time),
                lineWidth: CGFloat(Self.ringOneWidth.value(at: time))
            ),
            ringTwo: Ring(
                scale: CGFloat(Self.ringTwoScale.value(at: time)),
                opacity: Self.ringTwoOpacity.value(at: time),
                lineWidth: CGFloat(Self.ringTwoWidth.value(at: time))
            )
        )
    }

    private static let scale = ProfileV3Keyframes(0.72).to(1, at: 0.478, .easeOut)
    private static let opacity = ProfileV3Keyframes(0).to(1, at: 0.424, .easeOut)
    private static let blur = ProfileV3Keyframes(7).hold(until: 0.394).to(0, at: landed, .easeOut)
    private static let offsetX = ProfileV3Keyframes(-165).to(-209, at: 0.481, .easeOut).to(0, at: landed, .easeInOut)
    private static let offsetY = ProfileV3Keyframes(109).to(-25.8, at: 0.813, .easeOut).to(0, at: landed, .easeInOut)
    private static let pulse = ProfileV3Keyframes(1).hold(until: 1.714)
        .to(1.018, at: 2.139, .easeInOut).to(1, at: 2.664, .easeInOut)
        .to(1.018, at: 3.089, .easeInOut).to(1, at: 3.614, .easeInOut)
        .to(1.018, at: 4.039, .easeInOut).to(1, at: 4.564, .easeInOut)
    private static let glow = ProfileV3Keyframes(0).hold(until: 1.714)
        .to(1, at: 2.139, .easeInOut).to(0, at: 2.664, .easeInOut)
        .to(1, at: 3.089, .easeInOut).to(0, at: 3.614, .easeInOut)
        .to(1, at: 4.039, .easeInOut).to(0, at: 4.564, .easeInOut)
    private static let ringOneScale = ProfileV3Keyframes(1).hold(until: 1.472)
        .to(Double(ProfileV3Theme.Sizes.Partners.rippleScale), at: 2.534, .easeOut)
    private static let ringOneOpacity = ProfileV3Keyframes(0).hold(until: 1.472).to(0.32, at: 1.564, .easeOut).to(0, at: 2.534, .easeOut)
    private static let ringOneWidth = ProfileV3Keyframes(Double(ProfileV3Theme.Sizes.Partners.rippleLineWidth)).hold(until: 1.472)
        .to(Double(ProfileV3Theme.Sizes.Partners.rippleEndLineWidth), at: 2.534, .easeOut)
    private static let ringTwoScale = ProfileV3Keyframes(1).hold(until: 1.684)
        .to(Double(ProfileV3Theme.Sizes.Partners.rippleScale), at: 2.734, .easeOut)
    private static let ringTwoOpacity = ProfileV3Keyframes(0).hold(until: 1.684).to(0.2, at: 1.764, .easeOut).to(0, at: 2.734, .easeOut)
    private static let ringTwoWidth = ProfileV3Keyframes(Double(ProfileV3Theme.Sizes.Partners.rippleSecondLineWidth)).hold(until: 1.684)
        .to(Double(ProfileV3Theme.Sizes.Partners.rippleEndLineWidth), at: 2.734, .easeOut)
}

private struct ProfileV3PartnerLogo: View {
    let url: URL?
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(at: .neutralGrey100))
            ProfileV3RemoteImage(url: url, contentMode: .fill, placeholder: .clear)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

private struct ProfileV3PartnerRipple: View {
    let size: CGFloat
    let accent: Color
    let ring: ProfileV3PartnerLanding.Ring

    var body: some View {
        Circle()
            .stroke(accent, lineWidth: ring.lineWidth)
            .frame(width: size, height: size)
            .scaleEffect(ring.scale)
            .opacity(ring.opacity)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

private struct ProfileV3PartnerInfoButton: View {
    let name: String
    let action: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.Partners

    var body: some View {
        Button(action: action) {
            ATIcon.SwiftUIImage.infoOutline
                .profileV3Icon(Layout.infoIcon)
                .foregroundStyle(Color(at: .pureBlack))
                .frame(width: Layout.info, height: Layout.info)
                .background {
                    Circle()
                        .fill(Color(at: .pureWhite))
                        .shadow(color: ProfileV3Theme.Palette.partnerInfoShadow, radius: Layout.infoShadowRadius, y: Layout.infoShadowY)
                }
                .overlay(Circle().strokeBorder(ProfileV3Theme.Palette.settingsCardBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
                .frame(minWidth: ProfileV3Theme.Control.tapTarget, minHeight: ProfileV3Theme.Control.tapTarget)
                .contentShape(Circle())
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(name)
        .accessibilityAddTraits(.isLink)
    }
}

#if DEBUG
#Preview("Partners") {
    ProfileV3PartnersView(partners: ProfileV3Fixtures.partners, focus: 2, onBack: {}, onOpenInfo: { _ in })
}
#endif
