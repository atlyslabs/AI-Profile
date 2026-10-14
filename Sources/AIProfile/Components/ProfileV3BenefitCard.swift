import ATUIKit
import SwiftUI

struct ProfileV3BenefitCard: View {
    let benefit: ProfileV3Benefit
    var growsToFitText = false
    var contentOpacity: Double = 1
    var onSelect: (() -> Void)?

    @State private var cardWidth = ProfileV3Theme.Sizes.Benefit.designWidth

    private var isRedeemed: Bool {
        if case .redeemed = benefit.status { return true }
        return false
    }

    var body: some View {
        Button {
            onSelect?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text(benefit.title)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(Color(at: .pureBlack))
                    .lineLimit(ProfileV3Theme.Sizes.Benefit.titleLineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                Text(benefit.subtitle)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey400))
                    .fixedSize(horizontal: false, vertical: growsToFitText)
                    .frame(width: textColumnWidth, alignment: .leading)
                    .padding(.top, ProfileV3Theme.Sizes.Benefit.titleSpacing)
                    .frame(maxHeight: .infinity, alignment: .top)
                if showsFooter {
                    ProfileV3BenefitFooter(status: benefit.status)
                        .padding(.top, ProfileV3Theme.Sizes.Benefit.footerSpacing)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(width: titleColumnWidth, alignment: .leading)
            .padding(.leading, ProfileV3Theme.Sizes.Benefit.contentLeading)
            .padding(.top, ProfileV3Theme.Sizes.Benefit.contentTop)
            .padding(.bottom, ProfileV3Theme.Sizes.Benefit.contentBottom)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(
                minHeight: ProfileV3Theme.Sizes.Benefit.cardHeight,
                maxHeight: growsToFitText ? nil : ProfileV3Theme.Sizes.Benefit.cardHeight
            )
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { cardWidth = $0 }
            .overlay(alignment: .trailing) { trailingContent }
            .overlay(alignment: .topTrailing) {
                if isRedeemed {
                    stamp
                }
            }
            .opacity(contentOpacity)
            .profileV3Card()
        }
        .buttonStyle(.profileV3Pressable)
        .disabled(onSelect == nil)
        .accessibilityLabel(benefit.title)
        .accessibilityValue(benefit.status.accessibilityDescription)
        .accessibilityHint(benefit.subtitle)
    }

    @ViewBuilder
    private var trailingContent: some View {
        switch benefit.status {
        case .partiallyRedeemed(_, _, let progress):
            ProfileV3ProgressRing(progress: progress)
                .padding(.top, ProfileV3Theme.Sizes.Benefit.ringTop)
                .padding(.trailing, ProfileV3Theme.Sizes.Benefit.ringTrailing)
                .frame(maxHeight: .infinity, alignment: .top)
        case .redeemed:
            artwork
                .grayscale(1)
                .opacity(ProfileV3Theme.Opacity.redeemedArtwork)
        case .locked, .active:
            artwork
        }
    }

    private var showsFooter: Bool {
        switch benefit.status {
        case .locked, .partiallyRedeemed: return true
        case .active(let caption), .redeemed(let caption): return !caption.isEmpty
        }
    }

    private var textColumnWidth: CGFloat {
        let overflow = max(0, ProfileV3Theme.Sizes.Benefit.designWidth - cardWidth)
        return ProfileV3Theme.Sizes.Benefit.textColumnWidth - overflow
    }

    private var titleColumnWidth: CGFloat {
        min(ProfileV3Theme.Sizes.Benefit.textColumnWidth, textColumnWidth + ProfileV3Theme.Sizes.Benefit.titleOverhang)
    }

    @ViewBuilder
    private var artwork: some View {
        if let url = benefit.imageURL {
            ProfileV3RemoteImage(url: url, contentMode: .fit, placeholder: .clear)
                .frame(
                    width: ProfileV3Theme.Sizes.Benefit.designWidth,
                    height: ProfileV3Theme.Sizes.Benefit.cardHeight
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .allowsHitTesting(false)
        }
    }

    private var stamp: some View {
        Text(ProfileV3Strings.redeemed)
            .typoGraphy(.T1InterBold11)
            .textCase(.uppercase)
            .foregroundStyle(Color(at: .neutralGrey300))
            .rotationEffect(.degrees(ProfileV3Theme.Rotation.stamp))
            .padding(.top, ProfileV3Theme.Space.s24)
            .padding(.trailing, ProfileV3Theme.Space.s24)
    }
}

#if DEBUG
#Preview("Benefit card states") {
    ScrollView {
        VStack(spacing: ProfileV3Theme.Space.s24) {
            ProfileV3BenefitCard(benefit: ProfileV3Fixtures.lockedBenefit, onSelect: {})
            ProfileV3BenefitCard(benefit: ProfileV3Fixtures.activeBenefit)
            ProfileV3BenefitCard(benefit: ProfileV3Fixtures.giftCardBenefit)
            ProfileV3BenefitCard(benefit: ProfileV3Fixtures.redeemedBenefit)
            ProfileV3BenefitCard(benefit: ProfileV3Fixtures.lockedBenefit, growsToFitText: true, onSelect: {})
        }
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
    .background(Color(at: .pureWhite))
}
#endif
