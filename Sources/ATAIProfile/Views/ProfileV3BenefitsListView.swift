import ATUIKit
import SwiftUI

struct ProfileV3BenefitsListView: View {
    let benefits: [ProfileV3Benefit]
    var title = ""
    var subtitle = ""
    var learnMoreLabel = ""
    var phase: ProfileV3LoadPhase = .loaded
    var isLoadingMore = false
    var onRetry: (() -> Void)?
    var loadDetail: ((ProfileV3Benefit) async throws -> ProfileV3Benefit?)?
    var redeemError: String?
    var redemption: ProfileV3BenefitRedemption?
    var onRedeem: ((ProfileV3Benefit) -> Void)?
    var onClearRedeemError: (() -> Void)?
    let onClose: () -> Void
    var onKnowMore: (() -> Void)?
    var onActivateLocked: ((ProfileV3Benefit) -> Void)?
    var onImpression: ((ProfileV3Benefit, Int) -> Void)?

    @StateObject private var presenter = ProfileV3HeroPresenter<ProfileV3Benefit>()

    var body: some View {
        ProfileV3OfferListScaffold(
            phase: phase,
            isLoadingMore: isLoadingMore,
            isScrollDisabled: presenter.isPresenting,
            onRetry: onRetry,
            onClose: onClose
        ) {
            Text(resolvedTitle)
                .font(Font.Inter.get(size: ProfileV3Theme.Typography.benefitsWordmarkSize, weight: .medium))
                .tracking(ProfileV3Theme.Typography.benefitsWordmarkTracking)
                .foregroundStyle(ProfileV3Theme.statusTextGradient)
                .padding(.top, ProfileV3Theme.Space.s14)
            Text(resolvedSubtitle)
                .typoGraphy(.B2InterSemibold12)
                .foregroundStyle(Color(at: .neutralGrey600))
                .padding(.top, ProfileV3Theme.Space.s10)
            Button(action: { onKnowMore?() }) {
                Text(resolvedLearnMoreLabel)
                    .typoGraphy(.B2InterSemibold12)
                    .underline()
                    .foregroundStyle(Color(at: .pureBlack))
            }
            .buttonStyle(.plain)
            .padding(.top, ProfileV3Theme.Space.s14)
            .accessibilityLabel(resolvedLearnMoreLabel)
        } rows: {
            ForEach(Array(benefits.enumerated()), id: \.element.id) { index, benefit in
                ProfileV3BenefitCard(benefit: benefit, growsToFitText: true) {
                    open(benefit)
                }
                .profileV3OnImpression { onImpression?(benefit, index) }
            }
        } overlay: {
            ProfileV3BenefitHeroOverlay(
                presenter: presenter,
                loadDetail: loadDetail,
                onRedeem: onRedeem,
                redeemError: redeemError,
                onClearRedeemError: onClearRedeemError
            )
        }
        .onChange(of: redemption) { _, redemption in
            presenter.dismiss(after: redemption)
        }
    }

    private func open(_ benefit: ProfileV3Benefit) {
        ProfileV3Analytics.benefitClicked(
            benefitId: benefit.id,
            status: benefit.status.analyticsValue,
            origin: .list,
            routedToGate: benefit.requiresKYC
        )
        if !benefit.requiresKYC {
            ProfileV3Analytics.screen(.benefit, benefitId: benefit.id)
        }
        presenter.open(benefit, onLocked: onActivateLocked)
    }

    private var resolvedTitle: String { title.nonEmpty ?? ProfileV3Strings.worldPass }
    private var resolvedSubtitle: String { subtitle.nonEmpty ?? ProfileV3Strings.benefitsTagline }
    private var resolvedLearnMoreLabel: String { learnMoreLabel.nonEmpty ?? ProfileV3Strings.knowMore }
}

#if DEBUG
#Preview("Benefits list") {
    ProfileV3BenefitsListView(benefits: ProfileV3BenefitCatalogue.all, onClose: {})
}

#Preview("Benefits list · redeem failed") {
    ProfileV3BenefitsListView(
        benefits: ProfileV3BenefitCatalogue.all,
        redeemError: ProfileV3Strings.redeemFailed,
        onRedeem: { _ in },
        onClearRedeemError: {},
        onClose: {}
    )
}

#Preview("Benefits list · loading") {
    ProfileV3BenefitsListView(benefits: [], phase: .loading, onClose: {})
}

#Preview("Benefits list · failed") {
    ProfileV3BenefitsListView(benefits: [], phase: .failed, onRetry: {}, onClose: {})
}

#Preview("Benefits list · empty") {
    ProfileV3BenefitsListView(benefits: [], onClose: {})
}

#Preview("Benefits list · loading more") {
    ProfileV3BenefitsListView(
        benefits: Array(ProfileV3BenefitCatalogue.all.prefix(2)),
        isLoadingMore: true,
        onClose: {}
    )
}
#endif
