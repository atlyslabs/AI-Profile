import ATUIKit
import SwiftUI

struct ProfileV3CouponsListView: View {
    let coupons: [ProfileV3Coupon]
    var title = ""
    var subtitle = ""
    var phase: ProfileV3LoadPhase = .loaded
    var isLoadingMore = false
    var onRetry: (() -> Void)?
    var loadDetail: ((ProfileV3Coupon) async throws -> ProfileV3CouponDetail?)?
    let onClose: () -> Void

    @StateObject private var presenter = ProfileV3HeroPresenter<ProfileV3Coupon>()

    var body: some View {
        ProfileV3OfferListScaffold(
            phase: phase,
            isLoadingMore: isLoadingMore,
            isScrollDisabled: presenter.isPresenting,
            onRetry: onRetry,
            onClose: onClose,
            scrollComponent: .couponsList
        ) {
            if !title.isEmpty {
                Text(title)
                    .typoGraphy(.H5InterMedium20)
                    .foregroundStyle(Color(at: .pureBlack))
                    .padding(.top, ProfileV3Theme.Space.s14)
            }
            if !subtitle.isEmpty {
                Text(subtitle)
                    .typoGraphy(.B2InterSemibold12)
                    .foregroundStyle(Color(at: .neutralGrey600))
                    .padding(.top, ProfileV3Theme.Space.s10)
            }
        } rows: {
            ForEach(coupons.indexed) { row in
                let coupon = row.element
                ProfileV3UsageCard(usage: ProfileV3Usage(coupon: coupon)) { presenter.present(coupon) }
                    .trackRow(row.index, of: coupons.count)
            }
        } overlay: {
            if phase == .loaded, coupons.isEmpty, !isLoadingMore {
                ProfileV3EmptyState(icon: ATIcon.SwiftUIImage.localOffer, title: ProfileV3Strings.noCoupons)
                    .frame(width: ProfileV3Theme.Sizes.emptyStateTextWidth)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
            ProfileV3CouponHeroOverlay(presenter: presenter, loadDetail: loadDetail)
        }
        .scrollTracking(active: !presenter.isPresenting)
    }
}

#if DEBUG
#Preview("Coupons list") {
    ProfileV3CouponsListView(
        coupons: ProfileV3Fixtures.coupons,
        title: ProfileV3Fixtures.couponsSheet.title,
        subtitle: ProfileV3Fixtures.couponsSheet.subtitle,
        onClose: {}
    )
}

#Preview("Coupons list · loading") {
    ProfileV3CouponsListView(coupons: [], phase: .loading, onClose: {})
}

#Preview("Coupons list · failed") {
    ProfileV3CouponsListView(coupons: [], phase: .failed, onRetry: {}, onClose: {})
}

#Preview("Coupons list · empty") {
    ProfileV3CouponsListView(coupons: [], title: ProfileV3Fixtures.couponsSheet.title, onClose: {})
}

#Preview("Coupons list · loading more") {
    ProfileV3CouponsListView(
        coupons: Array(ProfileV3Fixtures.coupons.prefix(2)),
        isLoadingMore: true,
        onClose: {}
    )
}
#endif
