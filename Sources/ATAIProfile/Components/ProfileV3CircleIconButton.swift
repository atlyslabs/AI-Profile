import ATUIKit
import SwiftUI

struct ProfileV3CircleIconButton: View {
    let icon: Image
    let accessibilityLabel: String
    var size: CGFloat = ProfileV3Theme.Sizes.circleButton
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            icon
                .profileV3Icon(ProfileV3Theme.Icon.xl)
                .foregroundStyle(ProfileV3Theme.Palette.floatingControlInk)
                .frame(width: size, height: size)
                .background(ProfileV3FloatingControlBackground())
                .contentShape(Circle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityLabel(accessibilityLabel)
    }
}

extension ProfileV3CircleIconButton {
    static func back(
        size: CGFloat = ProfileV3Theme.Sizes.circleButton,
        action: @escaping () -> Void
    ) -> ProfileV3CircleIconButton {
        ProfileV3CircleIconButton(
            icon: ATIcon.SwiftUIImage.chevronLeft,
            accessibilityLabel: ProfileV3Strings.back,
            size: size,
            action: action
        )
    }

    static func settings(
        size: CGFloat = ProfileV3Theme.Sizes.circleButton,
        action: @escaping () -> Void
    ) -> ProfileV3CircleIconButton {
        ProfileV3CircleIconButton(
            icon: ATIcon.SwiftUIImage.settings,
            accessibilityLabel: ProfileV3Strings.settings,
            size: size,
            action: action
        )
    }

    static func close(
        size: CGFloat = ProfileV3Theme.Sizes.circleButton,
        action: @escaping () -> Void
    ) -> ProfileV3CircleIconButton {
        ProfileV3CircleIconButton(
            icon: ATIcon.SwiftUIImage.close,
            accessibilityLabel: ProfileV3Strings.close,
            size: size,
            action: action
        )
    }
}

#if DEBUG
#Preview("Circle icon buttons") {
    HStack(spacing: ProfileV3Theme.Space.s16) {
        ProfileV3CircleIconButton.back {}
        ProfileV3CircleIconButton.settings {}
        ProfileV3CircleIconButton.close {}
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
