import ATUIKit
import SwiftUI

struct ProfileV3WorldPassCarousel: View {
    let passes: [ProfileV3WorldPass]
    @Binding var selectedID: String?
    var expandedID: String?
    var showsHint = false
    var flipDemoPassID: String?
    var kycGlowPlays: [String: Int] = [:]
    var collapseProgress: CGFloat = 0
    var flipAffordancePassIDs: Set<String> = []
    let onLongPress: (ProfileV3WorldPass, CGRect, ProfileV3GlobePose) -> Void
    var onAddProgramme: (() -> Void)?
    var onOpenProgrammes: ((ProfileV3WorldPass) -> Void)?
    var onAddHousehold: (() -> Void)?
    var onFlipSeen: (() -> Void)?
    var onHintShown: (() -> Void)?
    var onFlip: ((ProfileV3WorldPass, _ showingBenefits: Bool) -> Void)?

    @State private var hintPassID: String?
    @State private var tapSelections = 0

    var body: some View {
        ProfileV3CentredCarousel(
            itemWidth: ProfileV3Theme.Sizes.worldPassWidth,
            height: ProfileV3Theme.Sizes.worldPassHeight,
            spacing: ProfileV3Theme.Sizes.worldPassSpacing,
            selection: $selectedID,
            isScrollDisabled: collapseProgress >= ProfileV3Theme.Motion.collapseInteractionLimit,
            scrollComponent: .worldPassCarousel,
            scrollPosition: 1
        ) {
            ForEach(passes) { pass in
                ProfileV3WorldPassCarouselItem(
                    pass: pass,
                    isHidden: expandedID == pass.id,
                    isSelected: selectedID == pass.id,
                    showsHint: showsHint && hintPassID == pass.id,
                    playsFlipDemo: flipDemoPassID == pass.id && selectedID == pass.id,
                    glowTrigger: kycGlowPlays[pass.id, default: 0],
                    collapseProgress: collapseProgress,
                    showsFlipAffordance: flipAffordancePassIDs.contains(pass.id),
                    onLongPress: { frame, pose in onLongPress(pass, frame, pose) },
                    onSelect: { select(pass) },
                    onAddProgramme: onAddProgramme,
                    onOpenProgrammes: onOpenProgrammes.map { open in { open(pass) } },
                    onFlipSeen: onFlipSeen,
                    onHintShown: onHintShown,
                    onFlip: onFlip.map { flip in { flip(pass, $0) } }
                )
            }
            if let onAddHousehold {
                ProfileV3HouseholdCard(
                    isSelected: selectedID == ProfileV3HouseholdCard.selectionID,
                    collapseProgress: collapseProgress,
                    onSelect: selectHousehold,
                    onAdd: onAddHousehold
                )
                .id(ProfileV3HouseholdCard.selectionID)
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: tapSelections)
        .task(id: ProfileV3CarouselHint(passID: selectedID, isEnabled: showsHint)) {
            await scheduleHint()
        }
    }

    private func select(_ pass: ProfileV3WorldPass) {
        guard selectedID != pass.id else { return }
        tapSelections += 1
        withAnimation(ProfileV3Theme.Motion.selection) {
            selectedID = pass.id
        }
    }

    private func selectHousehold() {
        guard selectedID != ProfileV3HouseholdCard.selectionID else { return }
        tapSelections += 1
        withAnimation(ProfileV3Theme.Motion.selection) {
            selectedID = ProfileV3HouseholdCard.selectionID
        }
    }

    private func scheduleHint() async {
        withAnimation(ProfileV3Theme.Motion.selection) {
            hintPassID = nil
        }
        guard showsHint, let id = selectedID else { return }
        try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.hintDelayMilliseconds))
        guard !Task.isCancelled else { return }
        withAnimation(ProfileV3Theme.Motion.hintAppear) {
            hintPassID = id
        }
    }
}

private struct ProfileV3CarouselHint: Hashable {
    let passID: String?
    let isEnabled: Bool
}

private struct ProfileV3WorldPassCarouselItem: View {
    let pass: ProfileV3WorldPass
    let isHidden: Bool
    let isSelected: Bool
    let showsHint: Bool
    let playsFlipDemo: Bool
    let glowTrigger: Int
    let collapseProgress: CGFloat
    let showsFlipAffordance: Bool
    let onLongPress: (CGRect, ProfileV3GlobePose) -> Void
    let onSelect: () -> Void
    var onAddProgramme: (() -> Void)?
    var onOpenProgrammes: (() -> Void)?
    var onFlipSeen: (() -> Void)?
    var onHintShown: (() -> Void)?
    var onFlip: ((_ showingBenefits: Bool) -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false
    @State private var holdProgress: CGFloat = 0
    @State private var isFlipped = false
    @State private var didHold = false
    @State private var flips = 0
    @State private var holds = 0
    @State private var frameBox = ProfileV3FrameBox()
    @State private var globePose = ProfileV3GlobePose()

    private var showsFlipTab: Bool { isSelected && !isHidden && showsFlipAffordance }
    private var isCollapsing: Bool { collapseProgress > 0 }
    private var isInteractive: Bool { collapseProgress < ProfileV3Theme.Motion.collapseInteractionLimit }
    private var isHintVisible: Bool { showsHint && !isFlipped && !isHidden && !isCollapsing }

    private var chromeOpacity: Double {
        1 - ProfileV3Theme.ramp(collapseProgress, from: 0, to: ProfileV3Theme.Motion.collapseChromeFadeEnd)
    }

    private var tabOpacity: Double {
        ProfileV3Theme.ramp(collapseProgress, from: ProfileV3Theme.Motion.collapseTabFadeStart, to: 1)
    }

    private var tabFillOpacity: Double { collapseProgress >= 1 ? 1 : 0 }

    private var collapseScaleX: CGFloat {
        let tabRatio = ProfileV3Theme.Sizes.Collapse.tabShapeWidth / ProfileV3Theme.Sizes.worldPassWidth
        return 1 - (1 - tabRatio) * collapseProgress
    }

    var body: some View {
        ZStack(alignment: .top) {
            ProfileV3CollapsedTab()
                .offset(y: ProfileV3Theme.Sizes.Collapse.drop)
                .opacity(tabFillOpacity)
                .accessibilityHidden(true)
            Button(action: tap) {
                ProfileV3WorldPassCard(
                    pass: pass,
                    glowTrigger: glowTrigger,
                    showsFlipTab: showsFlipTab,
                    flipTabOpacity: chromeOpacity,
                    animatesGlobe: isSelected && !isHidden && !isCollapsing && !isFlipped,
                    globePose: globePose
                )
            }
            .buttonStyle(.plain)
            .profileV3Flip(isFlipped: isFlipped) {
                ProfileV3WorldPassBackFace(
                    pass: pass,
                    onAddProgramme: onAddProgramme,
                    onOpenProgrammes: pass.programmes.isEmpty ? nil : onOpenProgrammes,
                    onFlip: flip,
                    showsFlipTab: showsFlipTab,
                    flipTabOpacity: chromeOpacity
                )
            }
            .overlay {
                RoundedRectangle(cornerRadius: ProfileV3Theme.Sizes.worldPassCornerRadius, style: .continuous)
                    .fill(ProfileV3Theme.collapseTabGradient)
                    .opacity(tabOpacity)
                    .allowsHitTesting(false)
            }
            .scaleEffect(isPressed ? ProfileV3Theme.Motion.pressedScale : 1)
            .overlay(alignment: .topLeading) {
                if showsHint, !isFlipped {
                    ProfileV3HoldToExploreHint(progress: holdProgress)
                        .offset(x: ProfileV3Theme.Sizes.hintOffsetX, y: ProfileV3Theme.Sizes.hintOffsetY)
                        .opacity(isCollapsing ? 0 : 1)
                        .animation(ProfileV3Theme.Motion.podiumHide, value: isCollapsing)
                        .transition(.opacity.combined(with: .scale(scale: ProfileV3Theme.Motion.popInScale)))
                        .accessibilityHidden(true)
                }
            }
            .profileV3Hover(isActive: !isHidden && !isCollapsing)
            .profileV3Collapse(collapseProgress)
            .scaleEffect(x: collapseScaleX, y: 1, anchor: .top)
            .offset(y: ProfileV3Theme.Sizes.Collapse.drop * collapseProgress)
        }
        .opacity(isHidden ? 0 : 1)
        .profileV3HeroFrame(frameBox)
        .onLongPressGesture(
            minimumDuration: ProfileV3Theme.Motion.holdDuration,
            perform: hold,
            onPressingChanged: updatePress
        )
        .simultaneousGesture(
            LongPressGesture(minimumDuration: ProfileV3Theme.Motion.holdDuration)
                .onEnded { _ in hold() }
        )
        .allowsHitTesting(isInteractive)
        .modifier(
            ProfileV3WorldPassItemAccessibility(
                isActive: isInteractive && !isHidden,
                isFlipped: isFlipped,
                holderName: pass.holderName,
                kycStatus: pass.kycAccessibilityDescription,
                flip: flip,
                explore: { onLongPress(frameBox.rect, globePose) }
            )
        )
        .onChange(of: isSelected) { _, selected in
            if !selected, isFlipped {
                withAnimation(ProfileV3Theme.Motion.flip) {
                    isFlipped = false
                }
            }
        }
        .onChange(of: isHintVisible, initial: true) { _, visible in
            if visible { onHintShown?() }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: flips)
        .sensoryFeedback(.impact(weight: .medium), trigger: holds)
        .task(id: playsFlipDemo && !isHidden && !isCollapsing) {
            await playFlipDemo()
        }
    }

    private func tap() {
        guard !didHold else { return }
        guard isSelected else {
            onSelect()
            return
        }
        flip()
    }

    private func updatePress(_ pressing: Bool) {
        if pressing {
            didHold = false
            var reset = Transaction()
            reset.disablesAnimations = true
            withTransaction(reset) { holdProgress = 0 }
            withAnimation(.linear(duration: ProfileV3Theme.Motion.holdDuration)) {
                holdProgress = 1
            }
        } else if !didHold {
            withAnimation(ProfileV3Theme.Motion.podiumHide) {
                holdProgress = 0
            }
        }
        withAnimation(ProfileV3Theme.Motion.selection) {
            isPressed = pressing
        }
    }

    private func hold() {
        guard !didHold else { return }
        didHold = true
        if isFlipped {
            holdProgress = 0
            flip()
        } else {
            holds += 1
            onLongPress(frameBox.rect, globePose)
        }
    }

    private func flip() {
        onFlip?(isFlipped)
        flips += 1
        withAnimation(ProfileV3Theme.Motion.flip) {
            isFlipped.toggle()
        }
        onFlipSeen?()
    }

    private func playFlipDemo() async {
        guard playsFlipDemo, !isHidden, !isCollapsing else { return }
        guard !reduceMotion else {
            onFlipSeen?()
            return
        }
        try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.hintDelayMilliseconds))
        guard !Task.isCancelled else { return }
        let manualFlips = flips
        setFlipped(true)
        try? await Task.sleep(
            for: .seconds(ProfileV3Theme.Motion.flipSeconds + ProfileV3Theme.Motion.flipDemoHoldSeconds)
        )
        if flips == manualFlips {
            setFlipped(false)
        }
        guard !Task.isCancelled else { return }
        onFlipSeen?()
    }

    private func setFlipped(_ flipped: Bool) {
        guard isFlipped != flipped else { return }
        withAnimation(ProfileV3Theme.Motion.flip) {
            isFlipped = flipped
        }
    }
}

private struct ProfileV3WorldPassItemAccessibility: ViewModifier {
    let isActive: Bool
    let isFlipped: Bool
    let holderName: String
    let kycStatus: String
    let flip: () -> Void
    let explore: () -> Void

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: isFlipped ? .contain : .ignore)
            .accessibilityLabel(isFlipped ? "" : "\(holderName), \(kycStatus)")
            .accessibilityHint(isFlipped ? "" : ProfileV3Strings.worldPassCardHint)
            .accessibilityAddTraits(isFlipped ? [] : .isButton)
            .accessibilityAction(named: ProfileV3Strings.flipCard, flip)
            .accessibilityAction(named: ProfileV3Strings.explorePass, explore)
            .accessibilityHidden(!isActive)
    }
}

#if DEBUG
private struct ProfileV3WorldPassCarouselPreview: View {
    @State private var selectedID: String? = ProfileV3Fixtures.worldPass.id
    @State private var collapse: CGFloat = 0

    var body: some View {
        VStack(spacing: ProfileV3Theme.Space.s32) {
            ProfileV3WorldPassCarousel(
                passes: ProfileV3Fixtures.worldPasses,
                selectedID: $selectedID,
                showsHint: true,
                collapseProgress: collapse,
                flipAffordancePassIDs: Set(ProfileV3Fixtures.worldPasses.map(\.id)),
                onLongPress: { _, _, _ in }
            )
            Slider(value: $collapse)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        }
        .padding(.vertical, ProfileV3Theme.Space.s32)
        .background(Color(at: .pureWhite))
        .coordinateSpace(.named(ProfileV3HeroSpace.name))
    }
}

#Preview("World Pass carousel") {
    ProfileV3WorldPassCarouselPreview()
}
#endif
