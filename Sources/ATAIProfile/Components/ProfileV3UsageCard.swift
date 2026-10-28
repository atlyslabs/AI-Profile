import ATUIKit
import SwiftUI

struct ProfileV3Usage: Equatable {
    let title: String
    let usedLabel: String
    let validLabel: String
    let progress: Double
}

extension ProfileV3Usage {
    init(coupon: ProfileV3Coupon) {
        self.init(
            title: coupon.title,
            usedLabel: coupon.usedLabel,
            validLabel: coupon.activeLabel,
            progress: coupon.percentRedeemed
        )
    }

    init(benefit: ProfileV3Benefit) {
        switch benefit.status {
        case .partiallyRedeemed(let usage, let validTill, let progress):
            self.init(title: benefit.title, usedLabel: usage, validLabel: validTill, progress: progress)
        case .active(let validTill):
            self.init(title: benefit.title, usedLabel: "", validLabel: validTill, progress: 0)
        case .redeemed(let on):
            self.init(title: benefit.title, usedLabel: "", validLabel: on, progress: 1)
        case .locked:
            self.init(title: benefit.title, usedLabel: "", validLabel: "", progress: 0)
        }
    }
}

struct ProfileV3UsageCard: View {
    let usage: ProfileV3Usage
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Benefit.titleSpacing) {
                Text(usage.title)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(Color(at: .pureBlack))
                ProfileV3UsageCaption(usedLabel: usage.usedLabel, validLabel: usage.validLabel)
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, ProfileV3Theme.Sizes.Benefit.contentLeading)
            .padding(.trailing, ProfileV3Theme.Sizes.Coupon.textTrailing)
            .padding(.vertical, ProfileV3Theme.Sizes.Benefit.contentVertical)
            .frame(
                maxWidth: .infinity,
                minHeight: ProfileV3Theme.Sizes.couponCardHeight,
                maxHeight: .infinity,
                alignment: .leading
            )
            .overlay(alignment: .trailing) {
                ProfileV3ProgressRing(progress: usage.progress)
                    .padding(.trailing, ProfileV3Theme.Sizes.Benefit.ringTrailing)
            }
            .profileV3Card()
        }
        .buttonStyle(.profileV3Pressable)
        .disabled(onTap == nil)
        .accessibilityLabel(usage.title)
        .accessibilityValue([usage.usedLabel, usage.validLabel].compactMap(\.nonEmpty).joined(separator: ", "))
    }
}

struct ProfileV3UsageCaption: View {
    let usedLabel: String
    let validLabel: String

    var body: some View {
        HStack(spacing: ProfileV3Theme.Space.s8) {
            if !usedLabel.isEmpty {
                Text(usedLabel)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .accentEmerald600))
            }
            if !usedLabel.isEmpty, !validLabel.isEmpty {
                ProfileV3SeparatorDot()
            }
            if !validLabel.isEmpty {
                Text(validLabel)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey400))
            }
        }
    }
}

struct ProfileV3SeparatorDot: View {
    var body: some View {
        Circle()
            .fill(Color(at: .neutralGrey400))
            .frame(width: ProfileV3Theme.Sizes.separatorDot, height: ProfileV3Theme.Sizes.separatorDot)
            .accessibilityHidden(true)
    }
}

struct ProfileV3UsageRail<Item: Identifiable>: View {
    let items: [Item]
    let usage: (Item) -> ProfileV3Usage
    var scrollComponent: ScrollComponent?
    var scrollPosition: Int?
    let onSelect: (Item) -> Void

    @State private var width = ProfileV3Theme.Canvas.width

    private var cardWidth: CGFloat {
        guard items.count > 1 else {
            return width - 2 * ProfileV3Theme.Sizes.screenHorizontalMargin
        }
        return ProfileV3Theme.Sizes.Coupon.cardWidth * ProfileV3Theme.Canvas.scale(for: width)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ProfileV3Theme.Sizes.Coupon.railSpacing) {
                ForEach(items) { item in
                    ProfileV3UsageCard(usage: usage(item)) { onSelect(item) }
                        .frame(width: cardWidth)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin, for: .scrollContent)
        .scrollClipDisabled()
        .scrollDisabled(items.count < 2)
        .trackScroll(ifNamed: scrollComponent, at: scrollPosition)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
    }
}

#if DEBUG
private let profileV3PreviewCoupons = [
    ProfileV3Coupon(
        id: "baggage_protection_500",
        title: "$500 baggage protection",
        usedLabel: "$0 used",
        activeLabel: "Active till Jan 2027",
        percentRedeemed: 0
    ),
    ProfileV3Coupon(
        id: "gift_card_200",
        title: "$200 gift card",
        usedLabel: "$80 used",
        activeLabel: "Active till Jan 2027",
        percentRedeemed: 0.4
    )
]

#Preview("Usage card") {
    ProfileV3UsageCard(usage: ProfileV3Usage(coupon: profileV3PreviewCoupons[1]), onTap: {})
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}

#Preview("Usage rail") {
    ProfileV3UsageRail(items: profileV3PreviewCoupons, usage: ProfileV3Usage.init(coupon:)) { _ in }
        .padding(.vertical, ProfileV3Theme.Space.s32)
        .background(Color(at: .pureWhite))
}

#Preview("Usage rail · gift cards") {
    ProfileV3UsageRail(items: ProfileV3Fixtures.giftCards, usage: ProfileV3Usage.init(benefit:)) { _ in }
        .padding(.vertical, ProfileV3Theme.Space.s32)
        .background(Color(at: .pureWhite))
}
#endif
