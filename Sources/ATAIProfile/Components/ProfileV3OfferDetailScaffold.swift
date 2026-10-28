import ATUIKit
import SwiftUI

struct ProfileV3OfferDetailScaffold<Meter: View>: View {
    let imageURL: URL?
    let title: String
    let termsTitle: String
    let terms: String
    let isDepleted: Bool
    let footer: (title: String, action: () -> Void)?
    let onClose: () -> Void
    var scrollComponent: ScrollComponent?
    var scrollItemId: String?
    @ViewBuilder let meter: () -> Meter

    @State private var isRevealed = false

    var body: some View {
        ZStack(alignment: .top) {
            Color(at: .pureWhite)
                .ignoresSafeArea()
            ProfileV3DetailGlow()
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)
                .ignoresSafeArea(edges: .top)
                .opacity(isDepleted ? 0 : 1)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    hero
                        .modifier(entry(0))
                    Text(title)
                        .typoGraphy(.H3InterMedium28)
                        .foregroundStyle(Color(at: .pureBlack))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: ProfileV3Theme.Sizes.BenefitDetail.titleWidth)
                        .padding(.top, ProfileV3Theme.Space.s10)
                        .modifier(entry(1))
                    if !termsTitle.isEmpty {
                        ProfileV3TagLabel(text: termsTitle)
                            .padding(.top, ProfileV3Theme.Space.s40)
                            .modifier(entry(2))
                    }
                    if !terms.isEmpty {
                        Text(terms)
                            .typoGraphy(.H7InterMedium16)
                            .foregroundStyle(Color(at: .neutralGrey500))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: ProfileV3Theme.Sizes.BenefitDetail.bodyWidth)
                            .padding(.top, ProfileV3Theme.Space.s24)
                            .modifier(entry(3))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, ProfileV3Theme.Space.s32)
            }
            .scrollBounceBehavior(.basedOnSize)
            .trackScroll(ifNamed: scrollComponent, id: scrollItemId)
            ProfileV3CloseBar(action: onClose)
                .modifier(entry(0))
        }
        .frame(maxWidth: .infinity)
        .onAppear { isRevealed = true }
        .safeAreaInset(edge: .bottom) {
            if let footer {
                ProfileV3GradientButton(title: footer.title, style: .redeem, action: footer.action)
                    .modifier(entry(4))
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.bottom, ProfileV3Theme.Space.s24)
                    .background(Color(at: .pureWhite).ignoresSafeArea())
            }
        }
    }

    private func entry(_ index: Int) -> ProfileV3EntryReveal {
        .staggered(
            index,
            isRevealed: isRevealed,
            animation: ProfileV3Theme.Motion.detailEntry,
            stagger: ProfileV3Theme.Motion.detailEntryStagger,
            offsetY: ProfileV3Theme.Motion.detailEntryOffset
        )
    }

    private var hero: some View {
        heroArt
            .frame(maxWidth: .infinity)
            .frame(height: ProfileV3Theme.Sizes.BenefitDetail.heroHeight)
            .clipped()
            .overlay(alignment: .bottom) {
                meter()
                    .padding(.bottom, ProfileV3Theme.Sizes.BenefitDetail.meterBottom)
            }
    }

    @ViewBuilder
    private var heroArt: some View {
        if let imageURL {
            ProfileV3RemoteImage(url: imageURL, contentMode: .fit, placeholder: .clear, showsLoader: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
