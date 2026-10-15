import ATUIKit
import SwiftUI

struct ProfileV3BenefitDetailView: View {
    let benefit: ProfileV3Benefit
    let onClose: () -> Void
    var onRedeem: (() -> Void)?

    private var canRedeem: Bool {
        guard !benefit.isDepleted, ProfileV3FeatureFlags.isBenefitRedeemEnabled, onRedeem != nil else {
            return false
        }
        if case .redeemed = benefit.status { return false }
        return true
    }

    private var footer: (title: String, action: () -> Void)? {
        if benefit.isDepleted { return (ProfileV3Strings.gotIt, onClose) }
        guard canRedeem else { return nil }
        return (ProfileV3Strings.redeem, { onRedeem?() })
    }

    var body: some View {
        ProfileV3OfferDetailScaffold(
            imageURL: benefit.imageURL,
            title: benefit.title,
            termsTitle: ProfileV3Strings.termsAndConditions,
            terms: benefit.terms ?? ProfileV3Strings.genericBenefitTerms,
            isDepleted: benefit.isDepleted,
            footer: footer,
            onClose: onClose
        ) {
            ProfileV3BenefitMeter(status: benefit.status)
        }
    }
}

#if DEBUG
#Preview("Benefit detail") {
    ProfileV3BenefitDetailView(benefit: ProfileV3Fixtures.lockedBenefit, onClose: {}, onRedeem: {})
}

#Preview("Benefit detail · partially redeemed") {
    ProfileV3BenefitDetailView(benefit: ProfileV3Fixtures.partiallyRedeemedBenefit, onClose: {}, onRedeem: {})
}

#Preview("Benefit detail · depleted") {
    ProfileV3BenefitDetailView(benefit: ProfileV3Fixtures.depletedBenefit, onClose: {}, onRedeem: {})
}

#Preview("Benefit detail · redeemed") {
    ProfileV3BenefitDetailView(benefit: ProfileV3Fixtures.redeemedBenefit, onClose: {}, onRedeem: {})
}
#endif
