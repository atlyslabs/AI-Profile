import ATUIKit
import SwiftUI

struct ProfileV3CheckboxMark: View {
    let isSelected: Bool
    var size: CGFloat = ProfileV3Theme.Icon.xl
    var tint: Color = ProfileV3Theme.Palette.graphite

    var body: some View {
        (isSelected ? ATIcon.SwiftUIImage.checkBox : ATIcon.SwiftUIImage.checkBoxOutlineBlank)
            .profileV3Icon(size)
            .foregroundStyle(tint)
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Checkbox marks") {
    HStack(spacing: ProfileV3Theme.Space.s16) {
        ProfileV3CheckboxMark(isSelected: true)
        ProfileV3CheckboxMark(isSelected: false)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
