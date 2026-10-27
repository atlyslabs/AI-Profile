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
    var travellerID: String?

    @StateObject private var presenter = ProfileV3HeroPresenter<ProfileV3Benefit>()

    var body: some View {
        ProfileV3OfferListScaffold(
            phase: phase,
            isLoadingMore: isLoadingMore,
            isScrollDisabled: presenter.isPresenting,
            onRetry: onRetry,
            onClose: onClose
        ) {
            if !title.isEmpty {
                Text(title)
                    .font(Font.Inter.get(size: ProfileV3Theme.Typography.benefitsWordmarkSize, weight: .medium))
                    .tracking(ProfileV3Theme.Typography.benefitsWordmarkTracking)
                    .foregroundStyle(ProfileV3Theme.statusTextGradient)
                    .padding(.top, ProfileV3Theme.Space.s14)
            }
            if !subtitle.isEmpty {
                Text(subtitle)
                    .typoGraphy(.B2InterSemibold12)
                    .foregroundStyle(Color(at: .neutralGrey600))
                    .padding(.top, ProfileV3Theme.Space.s10)
            }
            if !learnMoreLabel.isEmpty {
                Button(action: { onKnowMore?() }) {
                    Text(learnMoreLabel)
                        .typoGraphy(.B2InterSemibold12)
                        .underline()
                        .foregroundStyle(Color(at: .pureBlack))
                }
                .buttonStyle(.plain)
                .padding(.top, ProfileV3Theme.Space.s14)
                .accessibilityLabel(learnMoreLabel)
            }
        } rows: {
            ForEach(benefits) { benefit in
                ProfileV3BenefitCard(benefit: benefit, growsToFitText: true) {
                    open(benefit)
                }
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
        ProfileV3Analytics.benefitClicked(benefit, travellerId: travellerID, origin: .list, routedToGate: benefit.requiresKYC)
        if !benefit.requiresKYC {
            ProfileV3Analytics.benefitScreen(benefitId: benefit.id, travellerId: travellerID)
        }
        presenter.open(benefit, onLocked: onActivateLocked)
    }

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
