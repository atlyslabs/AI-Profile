import ATUIKit
import SwiftUI

struct ProfileV3RadioMark: View {
    let isSelected: Bool
    var size: CGFloat = ProfileV3Theme.Sizes.radioMark
    var tint: Color = ProfileV3Theme.Palette.graphite

    var body: some View {
        (isSelected ? ATIcon.SwiftUIImage.radioButtonChecked : ATIcon.SwiftUIImage.radioButtonUnchecked)
            .profileV3Icon(size)
            .foregroundStyle(tint)
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Radio marks") {
    HStack(spacing: ProfileV3Theme.Space.s16) {
        ProfileV3RadioMark(isSelected: true)
        ProfileV3RadioMark(isSelected: false)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
