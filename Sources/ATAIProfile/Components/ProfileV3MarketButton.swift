import ATUIKit
import SwiftUI

struct ProfileV3MarketButton: View {
    let selected: ProfileV3ProgrammeMarket.Option
    let action: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.AddProgramme

    var body: some View {
        Button(action: action) {
            HStack(spacing: Sizes.marketSpacing) {
                ProfileV3CountryFlag(isoCode: selected.countryCode, size: ProfileV3Theme.Icon.xl, placeholder: .globe)
                Text(selected.pillLabel)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(Color(at: .pureBlack))
                    .lineLimit(1)
                ATIcon.SwiftUIImage.expandMore
                    .profileV3Icon(ProfileV3Theme.Icon.xl)
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
            .contentShape(Capsule())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityLabel(selected.label)
    }
}

#if DEBUG
#Preview("Market button") {
    let market = ProfileV3ProgrammeCatalogue.mockMarket(selected: nil)
    return HStack {
        ProfileV3MarketButton(selected: market.options[0], action: {})
        ProfileV3MarketButton(selected: ProfileV3ProgrammeMarket.Option(value: "ae", label: "United Arab Emirates"), action: {})
    }
    .padding()
}
#endif
