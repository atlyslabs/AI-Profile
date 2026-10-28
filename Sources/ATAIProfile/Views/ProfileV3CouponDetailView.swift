import ATUIKit
import SwiftUI

struct ProfileV3CouponDetailView: View {
    let coupon: ProfileV3CouponDetail
    let onClose: () -> Void
    var onRedeem: (() -> Void)?

    private var canRedeem: Bool {
        guard !coupon.isDepleted, ProfileV3FeatureFlags.isCouponRedeemEnabled, onRedeem != nil else {
            return false
        }
        return coupon.redeemLabel != nil
    }

    private var footer: (title: String, action: () -> Void)? {
        if canRedeem, let label = coupon.redeemLabel { return (label, { onRedeem?() }) }
        guard !coupon.gotItLabel.isEmpty else { return nil }
        return (coupon.gotItLabel, onClose)
    }

    var body: some View {
        ProfileV3OfferDetailScaffold(
            imageURL: coupon.imageURL,
            title: coupon.title,
            termsTitle: coupon.termsTitle,
            terms: coupon.terms,
            isDepleted: coupon.isDepleted,
            footer: footer,
            onClose: onClose,
            scrollComponent: .couponDetail,
            scrollItemId: coupon.id
        ) {
            VStack(spacing: ProfileV3Theme.Space.s16) {
                ProfileV3ProgressBar(progress: coupon.percentRedeemed)
                ProfileV3UsageCaption(usedLabel: coupon.usedLabel, validLabel: coupon.activeLabel)
            }
        }
    }
}

#if DEBUG
#Preview("Coupon detail") {
    ProfileV3CouponDetailView(coupon: ProfileV3Fixtures.couponDetail, onClose: {})
}

#Preview("Coupon detail · depleted") {
    ProfileV3CouponDetailView(coupon: ProfileV3Fixtures.depletedCouponDetail, onClose: {})
}
#endif
