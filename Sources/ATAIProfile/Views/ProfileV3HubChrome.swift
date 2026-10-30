import ATUIKit
import Observation
import SwiftUI

@Observable
final class ProfileV3HubScroll {
    @ObservationIgnored var offset: CGFloat = 0 {
        didSet { update() }
    }

    @ObservationIgnored var kycTagBottom: CGFloat? {
        didSet { update() }
    }

    private(set) var collapse: CGFloat = 0
    private(set) var pinOffset: CGFloat = 0
    private(set) var notchReveal: Double = 0

    private func update() {
        let collapse = min(max(offset / ProfileV3Theme.Sizes.Collapse.distance, 0), 1)
        if collapse != self.collapse {
            self.collapse = collapse
        }
        let pinOffset = max(0, offset)
        if pinOffset != self.pinOffset {
            self.pinOffset = pinOffset
        }
        let notchReveal = min(
            ProfileV3Theme.ramp(collapse, from: ProfileV3Theme.Motion.collapseTabFadeStart, to: 1),
            Self.tagCoverage(kycTagBottom)
        )
        if notchReveal != self.notchReveal {
            self.notchReveal = notchReveal
        }
    }

    private static func tagCoverage(_ tagBottom: CGFloat?) -> Double {
        guard let tagBottom else { return 0 }
        let fadeBottom = ProfileV3Theme.Sizes.Collapse.backdropFadeBottom
        let fadeHeight = fadeBottom - ProfileV3Theme.Sizes.Collapse.backdropSolidBottom
        return ProfileV3Theme.ramp(fadeBottom - tagBottom, from: 0, to: fadeHeight)
    }
}

struct ProfileV3HubHeader: View {
    let scroll: ProfileV3HubScroll
    let name: String?
    let isLoaded: Bool
    let onBack: () -> Void
    let onSettings: () -> Void

    var body: some View {
        ProfileV3TopBar(
            onBack: onBack,
            trailing: { ProfileV3CircleIconButton.settings(size: ProfileV3Theme.Sizes.navButton, action: onSettings) },
            title: {
                if let name {
                    Text(ProfileV3Traveller.shortName(fullName: name))
                        .typoGraphy(.H6InterMedium18)
                        .foregroundStyle(Color(at: .pureBlack))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.horizontal, ProfileV3Theme.Sizes.navButton + ProfileV3Theme.Space.s12)
                        .opacity(nameOpacity)
                        .accessibilityLabel(name)
                        .accessibilityHidden(nameOpacity < 1)
                }
            }
        )
        .profileV3TopBarBackdrop()
    }

    private var nameOpacity: Double {
        guard isLoaded else { return 1 }
        return ProfileV3Theme.ramp(scroll.collapse, from: ProfileV3Theme.Motion.collapseNameFadeStart, to: 1)
    }
}

struct ProfileV3HubTabSwipe: View {
    let scroll: ProfileV3HubScroll
    let passCount: Int
    let onSwipe: (Int) -> Bool

    @State private var swipes = 0

    var body: some View {
        if scroll.collapse >= ProfileV3Theme.Motion.collapseInteractionLimit, passCount > 1 {
            Color.clear
                .frame(height: ProfileV3Theme.Sizes.Collapse.tabSwipeHeight)
                .contentShape(Rectangle())
                .padding(.top, ProfileV3Theme.Sizes.Collapse.tabTop - ProfileV3Theme.Sizes.Collapse.tabSwipeHeight / 2)
                .gesture(
                    DragGesture(minimumDistance: ProfileV3Theme.Sizes.Collapse.tabSwipeMinimum)
                        .onEnded { value in
                            guard abs(value.translation.width) > abs(value.translation.height) else { return }
                            if onSwipe(value.translation.width < 0 ? 1 : -1) {
                                swipes += 1
                            }
                        }
                )
                .sensoryFeedback(.impact(weight: .light), trigger: swipes)
                .accessibilityHidden(true)
        }
    }
}

struct ProfileV3HubPodiumSlot: View {
    let scroll: ProfileV3HubScroll
    let isRevealed: Bool

    var body: some View {
        let collapse = scroll.collapse
        let isCollapsing = collapse > 0
        ProfileV3Podium()
            .profileV3EntryReveal(isRevealed)
            .opacity(isCollapsing ? 0 : 1)
            .scaleEffect(isCollapsing ? ProfileV3Theme.Motion.entryScale : 1)
            .offset(y: isCollapsing ? ProfileV3Theme.Motion.entryOffsetY : 0)
            .animation(
                isCollapsing ? ProfileV3Theme.Motion.podiumHide : ProfileV3Theme.Motion.podiumShow,
                value: isCollapsing
            )
            .padding(.top, ProfileV3Theme.Sizes.Podium.topSpacing)
            .frame(height: ProfileV3Theme.Sizes.Podium.slot * (1 - collapse), alignment: .top)
    }
}

struct ProfileV3HubPinnedBlock: View {
    let viewModel: ProfileV3HubViewModel
    @ObservedObject var stage: ProfileV3HubStage
    let scroll: ProfileV3HubScroll
    let onExpand: (ProfileV3WorldPass, CGRect, ProfileV3GlobePose) -> Void

    var body: some View {
        let collapse = scroll.collapse
        let notchReveal = scroll.notchReveal
        ZStack(alignment: .top) {
            backdrop
                .offset(y: pinnedY(ProfileV3Theme.Sizes.Collapse.backdropTop))
                .opacity(ProfileV3Theme.ramp(collapse, from: ProfileV3Theme.Motion.collapseTabFadeStart, to: 1))
            carousel(collapse: collapse)
                .profileV3EntryReveal(stage.showsCards)
            if let notch = viewModel.home?.kycStatusText(showsExpiryDate: false) {
                ProfileV3KYCNotch(text: notch)
                    .offset(y: pinnedY(ProfileV3Theme.Sizes.Collapse.notchTop))
                    .opacity(notchReveal)
                    .allowsHitTesting(false)
                    .accessibilityHidden(notchReveal < 1)
            }
        }
        .padding(.top, ProfileV3Theme.Sizes.carouselTop)
        .modifier(ProfileV3HubPin(scroll: scroll))
        .allowsHitTesting(collapse < ProfileV3Theme.Motion.collapseInteractionLimit)
    }

    private var selection: Binding<String?> {
        Binding(
            get: { viewModel.isHouseholdSelected ? ProfileV3HouseholdCard.selectionID : viewModel.selectedPassID },
            set: { id in
                guard let id, stage.expandedPass == nil else { return }
                if id == ProfileV3HouseholdCard.selectionID {
                    viewModel.selectHousehold()
                } else {
                    viewModel.selectPass(id: id)
                }
            }
        )
    }

    private func carousel(collapse: CGFloat) -> some View {
        ProfileV3WorldPassCarousel(
            passes: viewModel.home?.worldPasses ?? [],
            selectedID: selection,
            expandedID: stage.expandedPass?.id,
            showsHint: viewModel.showsHoldHint && viewModel.flipDemoPassID != viewModel.selectedPassID
                && viewModel.home != nil && stage.isEntryComplete,
            flipDemoPassID: viewModel.home != nil && stage.isEntryComplete ? viewModel.flipDemoPassID : nil,
            kycGlowPlays: viewModel.kycGlowPlays,
            collapseProgress: collapse,
            flipAffordancePassIDs: viewModel.kycAnnouncedPassIDs,
            onLongPress: onExpand,
            onAddProgramme: viewModel.tapAddProgramme,
            onOpenProgrammes: viewModel.tapAddedCards,
            onAddHousehold: viewModel.home == nil ? nil : { viewModel.tapAddTraveller() },
            onFlipSeen: viewModel.markFlipSeen,
            onHintShown: viewModel.holdHintDidAppear,
            onFlip: viewModel.tapWorldPass
        )
    }

    private var backdrop: some View {
        ProfileV3FadeBand(
            solid: ProfileV3Theme.Sizes.Collapse.backdropSolidBottom - ProfileV3Theme.Sizes.Collapse.backdropTop,
            fade: ProfileV3Theme.Sizes.Collapse.backdropFadeBottom - ProfileV3Theme.Sizes.Collapse.backdropSolidBottom
        )
    }

    private func pinnedY(_ contentY: CGFloat) -> CGFloat {
        contentY - ProfileV3Theme.Sizes.Collapse.cardRestTop
    }
}

private struct ProfileV3HubPin: ViewModifier {
    let scroll: ProfileV3HubScroll

    func body(content: Content) -> some View {
        content.offset(y: scroll.pinOffset)
    }
}

struct ProfileV3HubPassOverlay: View {
    @ObservedObject var stage: ProfileV3HubStage
    let target: CGRect
    var latestPasses: [String: ProfileV3WorldPass] = [:]
    var isGlobeAnimating = true
    let onAddTraveller: () -> Void
    var onTrips: ((ProfileV3WorldPass, ProfileV3Directive) -> Void)?

    @State private var detailSphere: ProfileV3GlobeSphere?

    var body: some View {
        if let expanded = stage.expandedPass, let hero = stage.passHero {
            let pass = latestPasses[expanded.id] ?? expanded
            ZStack {
                Button(action: stage.collapse) {
                    ProfileV3FrostedBackdrop()
                        .opacity(hero.backdropOpacity)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(ProfileV3Strings.close)
                ProfileV3HeroRect(state: hero, fill: Color(at: .pureBlack))
                if ProfileV3FeatureFlags.isGlobeEnabled, let heroGlobe = stage.heroGlobe, !stage.isDetailSettled {
                    ProfileV3HeroGlobe(
                        progress: hero.progress,
                        source: .card(in: stage.heroSource),
                        destination: detailSphere ?? .detailEstimate(in: target),
                        state: heroGlobe,
                        isAnimating: isGlobeAnimating
                    )
                    .clipShape(ProfileV3HeroClip(frame: hero.frame, cornerRadius: hero.cornerRadius))
                    .transition(.identity)
                }
                ProfileV3WorldPassDetailView(
                    pass: pass,
                    showsChrome: stage.isDetailSettled,
                    isGlobeAnimating: isGlobeAnimating && stage.isDetailSettled && !stage.isGlobePaused,
                    globePose: stage.heroGlobe?.pose,
                    onGlobeSphere: { sphere in
                        guard sphere.radius > 1 else { return }
                        detailSphere = sphere
                    },
                    onAddTraveller: onAddTraveller,
                    onTrips: onTrips.map { open in { open(pass, $0) } }
                )
                    .frame(width: target.width, height: target.height)
                    .clipShape(
                        RoundedRectangle(cornerRadius: ProfileV3Theme.Sizes.Detail.cornerRadius, style: .continuous)
                    )
                    .position(x: target.midX, y: target.midY)
                    .allowsHitTesting(stage.isDetailSettled)
                if stage.isDetailSettled {
                    VStack {
                        ProfileV3CloseBar(action: stage.collapse)
                        Spacer()
                    }
                    .transition(.opacity)
                }
            }
            .coordinateSpace(.named(ProfileV3HeroSpace.name))
        }
    }
}
