import ATUIKit
import SwiftUI

struct ProfileV3Chip: View {
    let title: String
    var isSelected: Bool
    var leadingImageURL: URL?
    let action: () -> Void

    private var hasLogo: Bool { leadingImageURL != nil }

    private var leadingPadding: CGFloat {
        hasLogo ? ProfileV3Theme.Space.s6 : ProfileV3Theme.Space.s16
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: hasLogo ? ProfileV3Theme.Space.s10 : ProfileV3Theme.Space.s8) {
                if let leadingImageURL {
                    ProfileV3RemoteImage(url: leadingImageURL)
                        .frame(width: ProfileV3Theme.Icon.xl, height: ProfileV3Theme.Icon.xl)
                        .clipShape(Circle())
                }
                Text(title)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(isSelected ? Color(at: .neutralGrey900) : ProfileV3Theme.Palette.secondaryText)
            }
            .padding(.leading, leadingPadding)
            .padding(.trailing, ProfileV3Theme.Space.s16)
            .frame(height: ProfileV3Theme.Sizes.chipHeight)
            .profileV3CapsuleChrome(
                border: Color(at: .pureBlack),
                lineWidth: isSelected ? ProfileV3Theme.Stroke.hairline : 0,
                shadowRadius: ProfileV3Theme.Shadow.chipRadius,
                shadowY: ProfileV3Theme.Shadow.chipY
            )
            .animation(ProfileV3Theme.Motion.selection, value: isSelected)
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(title)
    }
}

#if DEBUG
#Preview("Chips") {
    HStack(spacing: ProfileV3Theme.Space.s12) {
        ProfileV3Chip(title: "Economy", isSelected: true) {}
        ProfileV3Chip(title: "Business", isSelected: false) {}
        ProfileV3Chip(title: ProfileV3Strings.addChip, isSelected: false) {}
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
