import ATUIKit
import SwiftUI

struct ProfileV3HubView: View {
    @ObservedObject var viewModel: ProfileV3HubViewModel
    @StateObject private var stage = ProfileV3HubStage()
    @StateObject private var benefitPresenter = ProfileV3HeroPresenter<ProfileV3Benefit>()
    @StateObject private var couponPresenter = ProfileV3HeroPresenter<ProfileV3Coupon>()
    @StateObject private var cover = ProfileV3HubCover()
    @State private var scroll = ProfileV3HubScroll()
    @State private var viewport: CGSize = .zero
    @State private var isKYCTagUnderBackdrop = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.profileV3Globe) private var globeRenderer
    @Environment(\.profileV3FloatingBarClearance) private var floatingBarClearance

    var body: some View {
        ZStack(alignment: .top) {
            content
            if viewModel.home == nil {
                ProfileV3LoadStateView(
                    phase: viewModel.phase.loadPhase,
                    loadingLabel: ProfileV3Strings.loadingHome,
                    retry: viewModel.retryLoad
                )
                .profileV3EntryReveal(stage.showsChrome)
                .transition(.opacity)
            }
            ProfileV3HubTabSwipe(
                scroll: scroll,
                passCount: viewModel.home?.worldPasses.count ?? 0,
                onSwipe: viewModel.selectPass(offsetBy:)
            )
            ProfileV3HubHeader(
                scroll: scroll,
                name: headerName,
                isLoaded: viewModel.home != nil,
                onBack: viewModel.tapBack,
                onSettings: viewModel.tapSettings
            )
            .profileV3EntryReveal(stage.showsChrome)
        }
        .coordinateSpace(.named(ProfileV3HeroSpace.name))
        .background(Color(at: .pureWhite).ignoresSafeArea(edges: .bottom))
        .fullScreenCover(isPresented: $cover.isPresented, onDismiss: closeCover) { overlays }
        .onChange(of: coversHub) { _, covers in cover.update(isCovering: covers) }
        .onChange(of: passImpressionKey, initial: true) { _, _ in viewModel.trackSelectedPass() }
        .onDisappear {
            viewModel.cancelPendingWork()
            stage.suspend()
        }
        .onGeometryChange(for: CGSize.self) { $0.size } action: { viewport = $0 }
        .task {
            await stage.enter(viewModel, reducesMotion: reduceMotion)
        }
        .onChange(of: viewModel.pendingBenefit) { _, benefit in
            guard let benefit else { return }
            presentBenefit(benefit)
            viewModel.clearPendingBenefit()
        }
        .onChange(of: viewModel.benefitRedemption) { _, redemption in
            benefitPresenter.dismiss(after: redemption)
        }
        .sensoryFeedback(.success, trigger: viewModel.kycStepCompletions)
        .sensoryFeedback(trigger: viewModel.kycGlowCue) { _, cue in
            switch cue?.tone {
            case .positive: return .success
            case .negative: return .warning
            case .hidden, nil: return nil
            }
        }
        .sensoryFeedback(.success, trigger: viewModel.benefitRedemption)
        .sensoryFeedback(.error, trigger: viewModel.redeemError) { _, error in error != nil }
        .sensoryFeedback(.error, trigger: viewModel.notice) { _, notice in notice != nil }
        .profileV3NoticeAlert(viewModel, isEnabled: !cover.isPresented)
    }

    private var overlays: some View {
        ZStack(alignment: .top) {
            ProfileV3HubPassOverlay(
                stage: stage,
                target: worldPassTarget,
                pastTripCodes: viewModel.pastTripCodes,
                isGlobeAnimating: viewModel.pastTrips == nil,
                onAddTraveller: viewModel.tapAddTraveller,
                onPastTrips: viewModel.openPastTrips
            )
            ProfileV3BenefitHeroOverlay(
                presenter: benefitPresenter,
                loadDetail: viewModel.benefitDetail,
                onRedeem: viewModel.redeem,
                redeemError: viewModel.redeemError,
                onClearRedeemError: viewModel.clearRedeemError
            )
            ProfileV3CouponHeroOverlay(presenter: couponPresenter, loadDetail: viewModel.couponDetail)
            ProfileV3HubSheets(viewModel: viewModel, isRevealed: cover.isMounted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .profileV3NoticeAlert(viewModel, isEnabled: true)
        .presentationBackground(.clear)
        .onAppear { cover.didAppear { coversHub } }
    }

    private var coversHub: Bool {
        stage.expandedPass != nil
            || benefitPresenter.isPresenting
            || couponPresenter.isPresenting
            || viewModel.showsAllBenefits
            || viewModel.showsAllCoupons
            || viewModel.pastTrips != nil
    }

    private func closeCover() {
        cover.didDismiss()
        viewModel.overlaysDidClose()
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: ProfileV3Theme.Sizes.hubBarBottom)
                ProfileV3HubPinnedBlock(
                    viewModel: viewModel,
                    stage: stage,
                    scroll: scroll,
                    isKYCTagUnderBackdrop: isKYCTagUnderBackdrop,
                    onExpand: expand
                )
                .zIndex(1)
                ProfileV3HubPodiumSlot(scroll: scroll, isRevealed: stage.showsChrome && viewModel.home != nil)
                phaseContent
                    .padding(.top, ProfileV3Theme.Sizes.Podium.contentGap)
            }
            .padding(.bottom, ProfileV3Theme.Space.s32)
            .profileV3ScrollOffsetAnchor(scrollOffset)
        }
        .contentMargins(.bottom, floatingBarClearance, for: .scrollContent)
        .profileV3ScrollOffset(scrollOffset)
        .scrollDisabled(
            viewModel.home == nil
                || stage.expandedPass != nil
                || benefitPresenter.isPresenting
                || couponPresenter.isPresenting
        )
    }

    private var scrollOffset: Binding<CGFloat> {
        Binding(get: { scroll.offset }, set: { scroll.offset = $0 })
    }

    private var headerName: String? {
        guard viewModel.home != nil else { return viewModel.placeholderName }
        return viewModel.isHouseholdSelected ? nil : viewModel.selectedPass?.holderName
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch viewModel.phase {
        case .loading, .failed:
            EmptyView()
        case .content(let home):
            if viewModel.isHouseholdSelected {
                ProfileV3HouseholdPlaceholder()
                    .transition(.opacity)
            } else {
                loadedContent(home)
                    .id(viewModel.contentVersion)
                    .transition(
                        .asymmetric(
                            insertion: .offset(y: ProfileV3Theme.Motion.contentSwitchOffset).combined(with: .opacity),
                            removal: .opacity
                        )
                    )
            }
        }
    }

    private func loadedContent(_ home: ProfileV3Home) -> some View {
        VStack(spacing: ProfileV3Theme.Space.s20) {
            if let kycLine = home.kycStatusText(showsExpiryDate: true) {
                kycSection(home, line: kycLine)
                    .profileV3EntryReveal(isRevealed(.kyc))
            }
            if !home.giftCards.isEmpty {
                ProfileV3UsageRail(
                    items: home.giftCards,
                    usage: ProfileV3Usage.init(benefit:),
                    onImpression: viewModel.trackBenefit
                ) { benefit in
                    ProfileV3Analytics.benefitClicked(
                        benefitId: benefit.id,
                        status: benefit.status.analyticsValue,
                        origin: .giftCard,
                        routedToGate: false
                    )
                    presentBenefit(benefit)
                }
                    .profileV3EntryReveal(isRevealed(.giftCards))
            }
            if home.featuredCoupon != nil {
                ProfileV3UsageRail(
                    items: viewModel.allCoupons,
                    usage: ProfileV3Usage.init(coupon:),
                    onImpression: viewModel.trackCoupon
                ) { coupon in
                    ProfileV3Analytics.couponClicked(couponId: coupon.id, origin: .rail)
                    ProfileV3Analytics.screen(.coupons)
                    cover.present { couponPresenter.present(coupon) }
                }
                    .profileV3EntryReveal(isRevealed(.featuredBenefit))
            }
            if home.featuredBenefit != nil {
                ProfileV3BenefitCardStack(
                    benefits: viewModel.stackBenefits,
                    isVisible: !viewModel.showsAllBenefits,
                    viewAllLabel: home.viewAllBenefitsLabel,
                    onSelect: openBenefit,
                    expandedID: benefitPresenter.item?.id,
                    onViewAll: viewModel.tapViewAllBenefits,
                    onFrontImpression: viewModel.trackBenefit
                )
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .profileV3EntryReveal(isRevealed(.featuredBenefit))
            }
            VStack(spacing: ProfileV3Theme.Space.s20) {
                ProfileV3DashedDivider()
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.vertical, ProfileV3Theme.Space.s20)
                ProfileV3AgentsHeader(
                    updatedAt: home.agentsUpdatedAt,
                    heading: home.agentsHeading,
                    headingEmphasis: home.agentsHeadingEmphasis
                )
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            }
            .profileV3EntryReveal(isRevealed(.agentsHeader))
            ProfileV3AgentGrid(
                agents: home.agents,
                isKYCComplete: home.kycStatus.isComplete,
                onImpression: viewModel.trackAgentCard,
                onActivate: viewModel.tapAgent
            )
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .profileV3EntryReveal(isRevealed(.agentGrid))
        }
    }

    private func kycSection(_ home: ProfileV3Home, line: String) -> some View {
        VStack(spacing: ProfileV3Theme.Space.s20) {
            ProfileV3TagLabel.kyc(viewModel.isSyncingKYC ? ProfileV3Strings.kycUpdating : line)
                .onGeometryChange(for: Bool.self) { proxy in
                    proxy.frame(in: .named(ProfileV3HeroSpace.name)).maxY
                        < ProfileV3Theme.Sizes.Collapse.backdropSolidBottom
                } action: { isKYCTagUnderBackdrop = $0 }
            Group {
                if let progress = home.kycProgress {
                    ProfileV3KYCProgressCard(
                        headline: ProfileV3Strings.kycAlmostThere,
                        progress: progress,
                        onTap: viewModel.tapCompleteKYC
                    )
                } else if home.needsKYCReconnect {
                    ProfileV3NudgeCard(
                        message: home.kycBannerTitle ?? ProfileV3Strings.kycReconnectMessage,
                        actionTitle: home.kycActionLabel ?? ProfileV3Strings.reconnect,
                        action: viewModel.tapCompleteKYC
                    )
                } else {
                    ProfileV3NudgeCard(
                        message: ProfileV3Strings.kycRegainAccess,
                        actionTitle: home.kycActionLabel ?? ProfileV3Strings.completeKYC,
                        action: viewModel.tapCompleteKYC
                    )
                }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .profileV3OnImpression { viewModel.trackKYCNudge(home) }
        }
    }

    private var passImpressionKey: String? {
        viewModel.home == nil ? nil : viewModel.selectedPassID
    }

    private var worldPassTarget: CGRect {
        let margin = ProfileV3Theme.Sizes.screenHorizontalMargin
        let cardWidth = max(0, viewport.width - 2 * margin)
        let top = ProfileV3Theme.Sizes.hubBarBottom + ProfileV3Theme.Space.s40
        let maxHeight = max(
            0,
            viewport.height - top - floatingBarClearance - ProfileV3Theme.Space.s16
        )
        let idealHeight = cardWidth / ProfileV3Theme.Sizes.Detail.aspectRatio
        let cardHeight = maxHeight > 0 ? min(idealHeight, maxHeight) : idealHeight
        return CGRect(x: margin, y: top, width: cardWidth, height: cardHeight)
    }

    private func isRevealed(_ detail: ProfileV3HubStage.EntryDetail) -> Bool {
        stage.isRevealed(detail, in: viewModel.home)
    }

    private func expand(_ pass: ProfileV3WorldPass, from frame: CGRect, globe pose: ProfileV3GlobePose) {
        ProfileV3Analytics.passExpanded(passId: pass.id, toState: .expanded)
        cover.present {
            stage.expand(pass, from: frame, to: worldPassTarget, globe: pose, renderer: globeRenderer)
            viewModel.markHoldHintSeen()
            viewModel.loadPastTripCodes(for: pass)
        }
    }

    private func openBenefit(_ benefit: ProfileV3Benefit) {
        ProfileV3Analytics.benefitClicked(
            benefitId: benefit.id,
            status: benefit.status.analyticsValue,
            origin: benefit.id == viewModel.home?.featuredBenefit?.id ? .featured : .stack,
            routedToGate: benefit.requiresKYC
        )
        guard !benefit.requiresKYC else {
            viewModel.activateLockedBenefit(benefit)
            return
        }
        presentBenefit(benefit)
    }

    private func presentBenefit(_ benefit: ProfileV3Benefit) {
        ProfileV3Analytics.screen(.benefit, benefitId: benefit.id)
        cover.present { benefitPresenter.present(benefit) }
    }
}

private extension View {
    func profileV3NoticeAlert(_ viewModel: ProfileV3HubViewModel, isEnabled: Bool) -> some View {
        alert(
            ProfileV3Strings.loadFailedTitle,
            isPresented: Binding(
                get: { isEnabled && viewModel.notice != nil },
                set: { if !$0 { viewModel.clearNotice() } }
            )
        ) {
            Button(ProfileV3Strings.close, role: .cancel) { viewModel.clearNotice() }
        } message: {
            Text(viewModel.notice ?? "")
        }
    }
}

private struct ProfileV3HubSheets: View {
    @ObservedObject var viewModel: ProfileV3HubViewModel
    let isRevealed: Bool

    var body: some View {
        if isRevealed, viewModel.showsAllCoupons {
            ProfileV3CouponsListView(
                coupons: viewModel.allCoupons,
                title: viewModel.couponsSheet.title,
                subtitle: viewModel.couponsSheet.subtitle,
                phase: viewModel.allCouponsPhase,
                isLoadingMore: viewModel.isFetchingCoupons && viewModel.couponsSheet.coupons.isEmpty,
                onRetry: viewModel.retryAllCoupons,
                loadDetail: viewModel.couponDetail,
                onClose: viewModel.dismissAllCoupons
            )
            .transition(ProfileV3Theme.Motion.fullScreenTransition)
        }
        if isRevealed, let pastTrips = viewModel.pastTrips {
            ProfileV3PastTripsView(viewModel: pastTrips)
                .zIndex(1)
                .transition(ProfileV3Theme.Motion.pastTripsPageTransition)
        }
        if isRevealed, viewModel.showsAllBenefits {
            ProfileV3BenefitsListView(
                benefits: viewModel.allBenefits,
                title: viewModel.benefitsSheet.title,
                subtitle: viewModel.benefitsSheet.subtitle,
                learnMoreLabel: viewModel.benefitsSheet.learnMoreLabel,
                phase: viewModel.allBenefitsPhase,
                isLoadingMore: viewModel.isFetchingBenefits && viewModel.benefitsSheet.offers.isEmpty,
                onRetry: viewModel.retryAllBenefits,
                loadDetail: viewModel.benefitDetail,
                redeemError: viewModel.redeemError,
                redemption: viewModel.benefitRedemption,
                onRedeem: viewModel.redeem,
                onClearRedeemError: viewModel.clearRedeemError,
                onClose: viewModel.dismissAllBenefits,
                onKnowMore: viewModel.tapKnowMore,
                onActivateLocked: viewModel.activateLockedBenefit,
                onImpression: viewModel.trackBenefit
            )
            .transition(ProfileV3Theme.Motion.fullScreenTransition)
        }
    }
}

#if DEBUG
@MainActor
private func profileV3PreviewHub(_ home: ProfileV3Home) -> ProfileV3HubView {
    let session = ProfileV3SessionStore(homes: [ProfileV3Fixtures.worldPass.id: home])
    return ProfileV3HubView(viewModel: ProfileV3HubViewModel(repository: ProfileV3MockRepository(session: session)))
}

#Preview("Profile hub") {
    ProfileV3HubView(viewModel: ProfileV3HubViewModel(repository: ProfileV3MockRepository()))
}

#Preview("Profile hub · loading") {
    ProfileV3HubView(viewModel: ProfileV3HubViewModel(repository: ProfileV3MockRepository(delay: .seconds(60))))
}

#Preview("Profile hub · failed") {
    ProfileV3HubView(viewModel: ProfileV3HubViewModel(repository: ProfileV3FailingRepository()))
}

#Preview("Profile hub · KYC not done") {
    profileV3PreviewHub(ProfileV3Fixtures.homeKYCNotDone)
}

#Preview("Profile hub · KYC complete") {
    profileV3PreviewHub(ProfileV3Fixtures.homeKYCComplete)
}

#Preview("Profile hub · reconnect Gmail") {
    var home = ProfileV3Fixtures.home
    home.needsKYCReconnect = true
    return profileV3PreviewHub(home)
}
#endif
