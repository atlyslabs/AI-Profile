import ATUIKit
import SwiftUI

struct ProfileV3OptionCard: View {
    let option: ProfileV3CardOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: ProfileV3Theme.Sizes.optionCardTextSpacing) {
                Text(option.code)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(Color(at: .neutralGrey900))
                Text(option.detail)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey900).opacity(ProfileV3Theme.Opacity.cardSubtitle))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, ProfileV3Theme.Space.s16)
            .padding(.vertical, ProfileV3Theme.Space.s12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .profileV3Chrome(
                shape,
                border: Color(at: .pureBlack),
                lineWidth: isSelected ? ProfileV3Theme.Stroke.hairline : 0,
                shadowRadius: ProfileV3Theme.Shadow.chipRadius,
                shadowY: ProfileV3Theme.Shadow.chipY
            )
            .animation(ProfileV3Theme.Motion.selection, value: isSelected)
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(option.code)
        .accessibilityValue(option.detail)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.md, style: .continuous)
    }
}

#if DEBUG
#Preview("Option cards") {
    HStack(spacing: ProfileV3Theme.Space.s16) {
        ProfileV3OptionCard(
            option: ProfileV3CardOption(id: "avml", code: "AVML", detail: "vegetarian (asian)"),
            isSelected: true,
            action: {}
        )
        ProfileV3OptionCard(
            option: ProfileV3CardOption(id: "vgml", code: "VGML", detail: "vegan, no animal products"),
            isSelected: false,
            action: {}
        )
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
