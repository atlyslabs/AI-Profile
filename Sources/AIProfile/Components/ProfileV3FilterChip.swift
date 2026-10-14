import ATUIKit
import SwiftUI

struct ProfileV3FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .typoGraphy(.B1InterSemibold14)
                .foregroundStyle(isSelected ? Color(at: .pureWhite) : Color(at: .pureBlack))
                .padding(.horizontal, ProfileV3Theme.Space.s20)
                .frame(height: ProfileV3Theme.Control.regular)
                .profileV3CapsuleChrome(
                    fill: isSelected ? ProfileV3Theme.Palette.filterChipSelected : Color(at: .pureWhite),
                    border: ProfileV3Theme.Palette.filterChipBorder,
                    lineWidth: isSelected ? 0 : ProfileV3Theme.Stroke.hairline,
                    shadowRadius: 0,
                    shadowY: 0
                )
                .animation(ProfileV3Theme.Motion.selection, value: isSelected)
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(title)
    }
}

#if DEBUG
#Preview("Filter chips") {
    HStack(spacing: ProfileV3Theme.Space.s12) {
        ForEach(ProfileV3ProgrammeCategory.allCases) { category in
            ProfileV3FilterChip(title: category.title, isSelected: category == .all) {}
        }
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
