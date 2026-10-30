import ATUIKit
import SwiftUI

private struct ProfileV3HeroOverlay<Item: Identifiable, Detail, Content: View>: View {
    @ObservedObject var presenter: ProfileV3HeroPresenter<Item>
    var loadDetail: ((Item) async throws -> Detail?)?
    @ViewBuilder let content: (Item, Detail?) -> Content

    var body: some View {
        ZStack {
            if let item = presenter.item {
                ProfileV3HeroOverlayItem(
                    item: item,
                    loadDetail: loadDetail,
                    onClose: presenter.dismiss,
                    content: content
                )
                .id(item.id)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(ProfileV3Theme.Motion.contentFade, value: presenter.item?.id)
    }
}

private struct ProfileV3HeroOverlayItem<Item: Identifiable, Detail, Content: View>: View {
    let item: Item
    let loadDetail: ((Item) async throws -> Detail?)?
    let onClose: () -> Void
    @ViewBuilder let content: (Item, Detail?) -> Content

    @State private var phase: ProfileV3LoadPhase
    @State private var detail: Detail?
    @State private var attempt = 0

    init(
        item: Item,
        loadDetail: ((Item) async throws -> Detail?)?,
        onClose: @escaping () -> Void,
        @ViewBuilder content: @escaping (Item, Detail?) -> Content
    ) {
        self.item = item
        self.loadDetail = loadDetail
        self.onClose = onClose
        self.content = content
        _phase = State(initialValue: loadDetail == nil ? .loaded : .loading)
    }

    var body: some View {
        ZStack {
            content(item, detail)
                .opacity(phase == .loaded ? 1 : 0)
            if phase != .loaded {
                Color(at: .pureWhite)
                    .ignoresSafeArea()
                    .overlay {
                        ProfileV3LoadStateView(phase: phase) { attempt += 1 }
                    }
                    .overlay(alignment: .top) {
                        ProfileV3CloseBar(action: onClose)
                    }
            }
        }
        .task(id: attempt) {
            await load()
        }
    }

    private func load() async {
        guard let loadDetail else {
            phase = .loaded
            return
        }
        phase = .loading
        do {
            let resolved = try await loadDetail(item)
            guard !Task.isCancelled else { return }
            detail = resolved
            phase = .loaded
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            phase = .failed
        }
    }
}

struct ProfileV3BenefitHeroOverlay: View {
    let presenter: ProfileV3HeroPresenter<ProfileV3Benefit>
    var loadDetail: ((ProfileV3Benefit) async throws -> ProfileV3Benefit?)?
    var onRedeem: ((ProfileV3Benefit) -> Void)?
    var redeemError: String?
    var onClearRedeemError: (() -> Void)?

    var body: some View {
        ProfileV3HeroOverlay(presenter: presenter, loadDetail: loadDetail) { benefit, detail in
            let shown = profileV3HeroBenefit(detail, fallingBackTo: benefit)
            ProfileV3BenefitDetailView(
                benefit: shown,
                onClose: { presenter.dismiss() },
                onRedeem: onRedeem.map { redeem in { redeem(shown) } }
            )
            .profileV3ErrorAlert(
                redeemError ?? ProfileV3Strings.redeemFailed,
                isPresented: redeemError != nil,
                onDismiss: { onClearRedeemError?() }
            )
        }
    }
}

struct ProfileV3CouponHeroOverlay: View {
    let presenter: ProfileV3HeroPresenter<ProfileV3Coupon>
    var loadDetail: ((ProfileV3Coupon) async throws -> ProfileV3CouponDetail?)?

    var body: some View {
        ProfileV3HeroOverlay(presenter: presenter, loadDetail: loadDetail) { coupon, detail in
            ProfileV3CouponDetailView(
                coupon: profileV3HeroCoupon(detail, fallingBackTo: coupon),
                onClose: { presenter.dismiss() }
            )
        }
    }
}

private func profileV3HeroBenefit(_ detail: ProfileV3Benefit?, fallingBackTo benefit: ProfileV3Benefit) -> ProfileV3Benefit {
    var shown = detail ?? benefit
    if shown.imageURL == nil { shown.imageURL = benefit.imageURL }
    return shown
}

private func profileV3HeroCoupon(_ detail: ProfileV3CouponDetail?, fallingBackTo coupon: ProfileV3Coupon) -> ProfileV3CouponDetail {
    var shown = detail ?? coupon.pendingDetail
    if shown.imageURL == nil { shown.imageURL = coupon.imageURL }
    return shown
}

#if DEBUG
@MainActor
private func profileV3PreviewPresenter<Item>(_ item: Item) -> ProfileV3HeroPresenter<Item> {
    let presenter = ProfileV3HeroPresenter<Item>()
    presenter.present(item)
    return presenter
}

#Preview("Benefit hero") {
    ProfileV3BenefitHeroOverlay(
        presenter: profileV3PreviewPresenter(ProfileV3Fixtures.activeBenefit),
        onRedeem: { _ in }
    )
}

#Preview("Benefit hero · redeem failed") {
    ProfileV3BenefitHeroOverlay(
        presenter: profileV3PreviewPresenter(ProfileV3Fixtures.activeBenefit),
        onRedeem: { _ in },
        redeemError: ProfileV3Strings.redeemFailed,
        onClearRedeemError: {}
    )
}

#Preview("Benefit hero · detail failed") {
    ProfileV3BenefitHeroOverlay(
        presenter: profileV3PreviewPresenter(ProfileV3Fixtures.activeBenefit),
        loadDetail: { _ in throw ProfileV3RepositoryError.agentNotFound }
    )
}

#Preview("Benefit hero · detail loading") {
    ProfileV3BenefitHeroOverlay(
        presenter: profileV3PreviewPresenter(ProfileV3Fixtures.activeBenefit),
        loadDetail: { _ in
            try await Task.sleep(for: .seconds(60))
            return nil
        }
    )
}

#Preview("Coupon hero") {
    ProfileV3CouponHeroOverlay(presenter: profileV3PreviewPresenter(ProfileV3Fixtures.coupon))
}

#Preview("Coupon hero · failed") {
    ProfileV3CouponHeroOverlay(
        presenter: profileV3PreviewPresenter(ProfileV3Fixtures.coupon),
        loadDetail: { _ in throw ProfileV3RepositoryError.agentNotFound }
    )
}
#endif
