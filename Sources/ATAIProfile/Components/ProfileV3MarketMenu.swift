import ATUIKit
import SwiftUI

struct ProfileV3MarketMenu: View {
    let market: ProfileV3ProgrammeMarket
    let selected: ProfileV3ProgrammeMarket.Option
    let onSelect: (String) -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.AddProgramme

    var body: some View {
        Menu {
            ForEach(market.options) { option in
                Button {
                    onSelect(option.value)
                } label: {
                    if option == selected {
                        Label(option.label, systemImage: "checkmark")
                    } else {
                        Text(option.label)
                    }
                }
            }
        } label: {
            HStack(spacing: Sizes.marketSpacing) {
                mark(for: selected)
                Text(selected.label)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(Color(at: .pureBlack))
                    .lineLimit(1)
                ATIcon.SwiftUIImage.expandMore
                    .profileV3Icon(ProfileV3Theme.Icon.lg)
                    .foregroundStyle(Color(at: .pureBlack))
            }
            .padding(.horizontal, Sizes.marketPadding)
            .frame(height: ProfileV3Theme.Control.regular)
            .profileV3CapsuleChrome(
                fill: Color(at: .pureWhite),
                border: ProfileV3Theme.Palette.filterChipBorder,
                lineWidth: ProfileV3Theme.Stroke.hairline,
                shadowRadius: 0,
                shadowY: 0
            )
        }
        .accessibilityLabel(selected.label)
    }

    @ViewBuilder
    private func mark(for option: ProfileV3ProgrammeMarket.Option) -> some View {
        if let code = option.countryCode, let country = ATCountry(isoCode: code) {
            ATCountryFlagView(country: country)
                .frame(width: ProfileV3Theme.Icon.lg, height: ProfileV3Theme.Icon.lg)
                .clipShape(Circle())
        } else {
            ATIcon.SwiftUIImage.globe
                .profileV3Icon(ProfileV3Theme.Icon.lg)
                .foregroundStyle(Color(at: .pureBlack))
        }
    }
}

#if DEBUG
#Preview("Market menu") {
    let market = ProfileV3ProgrammeCatalogue.mockMarket(selected: nil)
    return HStack {
        ProfileV3MarketMenu(market: market, selected: market.options[0], onSelect: { _ in })
        ProfileV3MarketMenu(market: market, selected: market.options[1], onSelect: { _ in })
    }
    .padding()
}
#endif
