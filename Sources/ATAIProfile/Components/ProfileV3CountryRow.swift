import ATUIKit
import SwiftUI

struct ProfileV3CountryRow: View {
    enum Mark {
        case radio
        case checkbox
    }

    let name: String
    let isoCode: String
    var trailing: String?
    let isSelected: Bool
    var mark = Mark.radio
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfileV3Theme.Space.s12) {
                switch mark {
                case .radio:
                    ProfileV3RadioMark(isSelected: isSelected, size: ProfileV3Theme.Icon.xl, tint: Color(at: .pureBlack))
                case .checkbox:
                    ProfileV3CheckboxMark(isSelected: isSelected, tint: Color(at: .pureBlack))
                }
                ProfileV3CountryFlag(
                    isoCode: isoCode,
                    size: ProfileV3Theme.Icon.xl,
                    placeholder: .disc(Color(at: .neutralGrey200))
                )
                .frame(width: ProfileV3Theme.Sizes.countryFlagBox, height: ProfileV3Theme.Sizes.countryFlagBox)
                Text(name)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(ProfileV3Theme.Palette.countryText)
                if let trailing {
                    ProfileV3SeparatorDot()
                        .padding(.horizontal, ProfileV3Theme.Space.s4)
                    Text(trailing)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(Color(at: .neutralGrey400))
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, ProfileV3Theme.Space.s18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityLabel(trailing.map { "\(name), \($0)" } ?? name)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

}

#if DEBUG
#Preview("Country rows") {
    VStack(spacing: 0) {
        ProfileV3CountryRow(name: "United States", isoCode: "US", trailing: "USD", isSelected: true) {}
        ProfileV3DashedDivider()
            .padding(.leading, ProfileV3Theme.Sizes.pickerDividerInset)
        ProfileV3CountryRow(name: "United Arab Emirates", isoCode: "AE", isSelected: false) {}
        ProfileV3DashedDivider()
            .padding(.leading, ProfileV3Theme.Sizes.pickerDividerInset)
        ProfileV3CountryRow(name: "India", isoCode: "IN", isSelected: false) {}
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
