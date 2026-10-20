import ATUIKit
import SwiftUI

private struct ProfileV3ConnectorGlowShape: Shape {
    func path(in rect: CGRect) -> Path {
        let canvas = ProfileV3Theme.Sizes.ConnectorDeck.glowCanvas
        let sx = rect.width / canvas.width
        let sy = rect.height / canvas.height
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()
        path.move(to: point(274, 317))
        path.addCurve(to: point(137, 328.5), control1: point(274, 323.351), control2: point(212.663, 328.5))
        path.addCurve(to: point(0, 317), control1: point(61.337, 328.5), control2: point(0, 323.351))
        path.addLine(to: point(0, 2.0134))
        path.addCurve(to: point(2.01339, 0), control1: point(0, 0.901431), control2: point(0.901427, 0))
        path.addLine(to: point(271.987, 0))
        path.addCurve(to: point(274, 2.01339), control1: point(273.099, 0), control2: point(274, 0.901427))
        path.closeSubpath()
        return path
    }
}

private enum ProfileV3ConnectorDeckStage {
    case rest, risen, second, emerged, dimmed, paired
}

private enum ProfileV3ConnectorDeckFinale {
    struct Step {
        let stage: ProfileV3ConnectorDeckStage
        let delay: Double
        let animation: Animation
        let haptic: @MainActor (ProfileV3ConnectorHaptics) -> Void
    }

    static let steps: [Step] = {
        let motion = ProfileV3Theme.Motion.self
        return [
            Step(
                stage: .second,
                delay: motion.connectorDeckRiseDuration + motion.connectorDeckRiseGap,
                animation: motion.connectorDeckSubmerge,
                haptic: { $0.submerge() }
            ),
            Step(
                stage: .emerged,
                delay: motion.connectorDeckSubmergeDuration + motion.connectorDeckSubmergeGap,
                animation: motion.connectorDeckEmerge,
                haptic: { $0.emerge() }
            ),
            Step(
                stage: .dimmed,
                delay: motion.connectorDeckEmergeDuration + motion.connectorDeckEmergeGap,
                animation: motion.connectorDeckDim,
                haptic: { $0.dim() }
            ),
            Step(
                stage: .paired,
                delay: motion.connectorDeckDimDuration + motion.connectorDeckDimGap,
                animation: motion.connectorDeckSlide,
                haptic: { $0.pair() }
            )
        ]
    }()
}

struct ProfileV3ConnectorDeckCard: View {
    let entry: ProfileV3ConnectorDeckEntry
    let confirm: ProfileV3DisconnectConfirm?
    let onEngaged: (() -> Void)?
    let onArmed: (() -> Void)?
    let onEdit: (() -> Void)?

    @State private var drag: CGFloat = 0
    @State private var isEngaged = false
    @State private var stage: ProfileV3ConnectorDeckStage
    @State private var finaleTask: Task<Void, Never>?

    init(
        entry: ProfileV3ConnectorDeckEntry,
        confirm: ProfileV3DisconnectConfirm? = nil,
        initiallyArmed: Bool = false,
        onEngaged: (() -> Void)? = nil,
        onArmed: (() -> Void)? = nil,
        onEdit: (() -> Void)? = nil
    ) {
        self.entry = entry
        self.confirm = confirm
        self.onEngaged = onEngaged
        self.onArmed = onArmed
        self.onEdit = onEdit
        _stage = State(initialValue: initiallyArmed ? .paired : .rest)
    }

    private typealias Deck = ProfileV3Theme.Sizes.ConnectorDeck

    private var hasDropped: Bool { stage != .rest }
    private var isDragging: Bool { isEngaged || hasDropped }

    private var nearRimTop: CGFloat {
        switch stage {
        case .rest: return Deck.podiumTop
        case .risen, .second, .emerged, .dimmed, .paired: return Deck.podiumUnderTop
        }
    }

    private var farRimTop: CGFloat { nearRimTop + Deck.wellHeight }

    private var secondRimTop: CGFloat {
        switch stage {
        case .rest, .risen: return Deck.cardHeight + Deck.podiumRim
        case .second, .emerged, .dimmed, .paired: return Deck.secondPodiumTop
        }
    }

    private var wellMouth: CGFloat { farRimTop + Deck.podiumRim / 2 }

    private var floatBadgeDrop: CGFloat {
        switch stage {
        case .rest, .risen, .second: return -Deck.badge
        case .emerged: return Deck.badgeFloatDrop
        case .dimmed, .paired: return Deck.badgePairedDrop
        }
    }

    private var isPaired: Bool { stage == .paired }

    private var isDimmed: Bool { stage == .dimmed || stage == .paired }

    private var floatBadgeX: CGFloat { isPaired ? Deck.badgePairX : 0 }

    private var floatBadgeMotion: Animation {
        switch stage {
        case .paired: return ProfileV3Theme.Motion.connectorDeckSlide
        case .dimmed: return ProfileV3Theme.Motion.connectorDeckDim
        case .rest, .risen, .second, .emerged: return ProfileV3Theme.Motion.connectorDeckEmerge
        }
    }

    private var pairedTop: CGFloat { wellMouth + Deck.badgePairedDrop }

    private var beamBottom: CGFloat {
        nearRimTop + Deck.podiumRim / 2 + Deck.glowOverhang
    }

    private var beamRestHeight: CGFloat {
        Deck.podiumTop + Deck.podiumRim / 2 + Deck.glowOverhang - Deck.glowTop
    }

    private var glowTop: CGFloat { beamBottom - beamRestHeight }

    private var badgeTravel: CGFloat {
        Deck.podiumTop + Deck.podiumRim / 2 - Deck.badgeTop - Deck.badge / 2
    }

    private var badgeOffset: CGFloat { hasDropped ? badgeTravel + Deck.badgeSink : drag }

    private func pullProgress(_ height: CGFloat) -> Double {
        guard badgeTravel > 0 else { return 0 }
        return Double(min(max(height, 0), badgeTravel) / badgeTravel)
    }

    var body: some View {
        ZStack(alignment: .top) {
            well
            pairedChrome
            ZStack(alignment: .top) {
                badge
                    .offset(y: badgeOffset)
                    .animation(ProfileV3Theme.Motion.connectorDeckAbsorb, value: hasDropped)
                    .padding(.top, Deck.badgeTop)
                    .gesture(dragGesture)
                    .allowsHitTesting(!hasDropped)
            }
            .frame(width: Deck.cardWidth, height: Deck.cardHeight, alignment: .top)
            .mask(alignment: .top) { bowlMask }
            if !entry.account.isEmpty {
                Text(entry.account)
                    .typoGraphy(.B2InterSemibold12)
                    .foregroundStyle(Color(at: .pureWhite))
                    .padding(.top, Deck.emailTop)
                    .opacity(isDragging ? 0 : 1)
            }
            if !entry.headline.isEmpty {
                Text(entry.headline)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(Color(at: .pureWhite))
                    .padding(.top, entry.isApp ? Deck.appTitleTop : Deck.titleTop)
                    .opacity(isDragging ? 0 : 1)
            }
            Text(entry.blurb)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(ProfileV3Theme.connectorDeckBodyText)
                .multilineTextAlignment(.center)
                .frame(width: Deck.bodyWidth)
                .padding(.top, entry.isApp ? Deck.appBodyTop : Deck.bodyTop)
                .opacity(isDragging ? 0 : 1)
            if entry.isApp, let onEdit {
                editPill(onEdit)
                    .padding(.top, Deck.editTop)
                    .opacity(isDragging ? 0 : 1)
            }
            if !entry.hint.isEmpty {
                Text(entry.hint)
                    .typoGraphy(.B2InterSemibold12)
                    .foregroundStyle(Color(at: .neutralGrey500))
                    .padding(.top, Deck.hintTop)
                    .opacity(hasDropped ? 0 : 1)
            }
        }
        .frame(width: Deck.cardWidth, height: Deck.cardHeight, alignment: .top)
        .background(Color(at: .pureBlack))
        .clipShape(RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.xxl, style: .continuous))
        .animation(ProfileV3Theme.Motion.selection, value: isDragging)
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: entry.isApp ? ProfileV3Strings.disconnectApp : ProfileV3Strings.disconnectEmail) {
            guard !hasDropped else { return }
            drop()
        }
        .accessibilityActions {
            if entry.isApp, let onEdit {
                Button(ProfileV3Strings.editConnector, action: onEdit)
            }
        }
        .onDisappear { finaleTask?.cancel() }
    }

    private func editPill(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: ProfileV3Theme.Space.s8) {
                ProfileV3ConnectorGlyph.editStroke.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Deck.editGlyph, height: Deck.editGlyph)
                Text(ProfileV3Strings.editConnector)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(Color(at: .pureWhite))
            }
            .padding(.leading, Deck.editLeading)
            .padding(.trailing, Deck.editTrailing)
            .padding(.vertical, Deck.editVertical)
            .background(Capsule().fill(ProfileV3Theme.Palette.deckEditPill))
            .contentShape(Capsule())
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(ProfileV3Strings.editConnector)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isEngaged { ProfileV3ConnectorHaptics.shared.beginDrag() }
                isEngaged = true
                drag = min(max(value.translation.height, 0), badgeTravel)
                ProfileV3ConnectorHaptics.shared.updateDrag(progress: pullProgress(value.translation.height))
            }
            .onEnded { value in
                guard value.translation.height >= badgeTravel else {
                    ProfileV3ConnectorHaptics.shared.cancelDrag()
                    withAnimation(ProfileV3Theme.Motion.selection) {
                        drag = 0
                        isEngaged = false
                    }
                    return
                }
                drop()
            }
    }

    private func drop() {
        ProfileV3ConnectorHaptics.shared.absorb()
        onEngaged?()
        withAnimation(ProfileV3Theme.Motion.connectorDeckRise) { stage = .risen }
        scheduleFinale()
    }

    private var well: some View {
        ZStack(alignment: .top) {
            wellBody
            rim(mouth: ProfileV3Theme.connectorDeckPodiumRim).offset(y: nearRimTop)
            ProfileV3ConnectorGlowShape()
                .fill(ProfileV3Theme.connectorDeckGlow)
                .frame(width: Deck.glowWidth, height: beamRestHeight)
                .offset(y: glowTop)
            underGlow
                .opacity(isDimmed ? 0 : 1)
                .animation(ProfileV3Theme.Motion.connectorDeckDim, value: isDimmed)
                .offset(y: wellMouth)
            floatBadge
            rim(mouth: ProfileV3Theme.connectorDeckWellMouth).offset(y: farRimTop)
            secondPodium
                .offset(y: secondRimTop)
                .animation(ProfileV3Theme.Motion.connectorDeckSubmerge, value: stage)
        }
        .frame(width: Deck.cardWidth, height: Deck.cardHeight, alignment: .top)
        .animation(ProfileV3Theme.Motion.connectorDeckRise, value: stage)
    }

    private func scheduleFinale() {
        finaleTask?.cancel()
        finaleTask = Task {
            for step in ProfileV3ConnectorDeckFinale.steps {
                try? await Task.sleep(for: .seconds(step.delay))
                guard !Task.isCancelled else { return }
                step.haptic(ProfileV3ConnectorHaptics.shared)
                withAnimation(step.animation) { stage = step.stage }
            }
            try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.connectorDeckSlideDuration))
            guard !Task.isCancelled else { return }
            onArmed?()
        }
    }

    private var pairedChrome: some View {
        ZStack(alignment: .top) {
            if let warning = confirm?.warning.nonEmpty {
                Text(warning)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(ProfileV3Theme.Palette.destructive)
                    .multilineTextAlignment(.center)
                    .frame(width: Deck.warningWidth)
                    .padding(.top, Deck.warningTop)
            }
            badgeChrome {
                ProfileV3ConnectorGlyph.atlysMark.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Deck.atlysMark, height: Deck.atlysMark)
                    .rotationEffect(.degrees(ProfileV3Theme.Rotation.quarter))
            }
            .offset(x: -Deck.badgePairX, y: pairedTop)
            Capsule()
                .fill(ProfileV3Theme.Palette.podiumShadowStart)
                .frame(width: Deck.linkWidth, height: Deck.linkHeight)
                .offset(y: pairedTop + (Deck.badge - Deck.linkHeight) / 2)
        }
        .frame(width: Deck.cardWidth, height: Deck.cardHeight, alignment: .top)
        .opacity(isPaired ? 1 : 0)
        .animation(ProfileV3Theme.Motion.connectorDeckSlide, value: isPaired)
    }

    private var floatBadge: some View {
        badge
            .opacity(isDimmed ? 1 : ProfileV3Theme.Opacity.connectorFloatBadge)
            .offset(x: floatBadgeX, y: floatBadgeDrop)
            .animation(floatBadgeMotion, value: stage)
            .frame(width: Deck.cardWidth, height: Deck.cardHeight, alignment: .top)
            .mask(alignment: .top) { Rectangle() }
            .offset(y: wellMouth)
    }

    private var wellBody: some View {
        Rectangle()
            .fill(ProfileV3Theme.connectorDeckWellBody)
            .overlay(ProfileV3Theme.connectorDeckPodiumSheen)
            .frame(width: Deck.podiumWidth, height: Deck.wellHeight)
            .offset(y: nearRimTop + Deck.podiumRim / 2)
    }

    private func rim(mouth: LinearGradient) -> some View {
        ZStack(alignment: .top) {
            Ellipse()
                .fill(ProfileV3Theme.Palette.connectorRim)
                .frame(width: Deck.podiumWidth, height: Deck.podiumRim)
            Ellipse()
                .fill(mouth)
                .frame(width: Deck.podiumInnerWidth, height: Deck.podiumInnerRim)
                .padding(.top, Deck.podiumInnerTop)
        }
        .frame(width: Deck.podiumWidth, alignment: .top)
    }

    private var underGlow: some View {
        ProfileV3Theme.connectorDeckUnderGlow
            .frame(width: Deck.glowWidth, height: Deck.underGlowHeight)
    }

    private var secondPodium: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(ProfileV3Theme.connectorDeckPodiumBody)
                .overlay(ProfileV3Theme.connectorDeckPodiumSheen)
                .frame(width: Deck.podiumWidth, height: Deck.podiumBodyHeight)
                .offset(y: Deck.podiumRim / 2)
            rim(mouth: ProfileV3Theme.connectorDeckPodiumMouth)
        }
        .frame(width: Deck.podiumWidth, alignment: .top)
    }

    private var bowlMask: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .frame(height: max(0, glowTop))
            ProfileV3ConnectorGlowShape()
                .frame(width: Deck.glowWidth, height: beamRestHeight)
                .offset(y: glowTop)
        }
        .frame(width: Deck.cardWidth, height: Deck.cardHeight, alignment: .top)
        .animation(ProfileV3Theme.Motion.connectorDeckRise, value: stage)
    }

    private var badge: some View {
        badgeChrome(isPlain: entry.isApp) {
            switch entry.icon {
            case .remote(let url) where entry.isApp:
                ProfileV3AppLogo(url: url, size: Deck.appLogo)
            case .remote(let url):
                ProfileV3RemoteImage(url: url, contentMode: .fit, placeholder: .clear)
                    .frame(width: Deck.logo, height: Deck.logo)
            case .contract:
                ProfileV3ContractShape()
                    .fill(Color(at: .pureBlack))
                    .frame(width: Deck.atlysMark, height: Deck.atlysMark)
            }
        }
    }

    private func badgeChrome<Content: View>(
        isPlain: Bool = false,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        content()
            .frame(width: Deck.badge, height: Deck.badge)
            .background(
                Circle().fill(
                    isPlain ? AnyShapeStyle(Color(at: .pureWhite)) : AnyShapeStyle(ProfileV3Theme.connectorDeckBadge)
                )
            )
            .shadow(
                color: ProfileV3Theme.Palette.shadow,
                radius: ProfileV3Theme.Shadow.pillRadius,
                y: ProfileV3Theme.Shadow.pillY
            )
    }
}
