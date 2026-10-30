import ATUIKit
import SwiftUI

struct ProfileV3ContinueButton: View {
    var title = ProfileV3Strings.continueTitle
    var icon: Image?
    var iconSize = ProfileV3Theme.Sizes.pillIcon
    var horizontalPadding: CGFloat = 0
    var tint: Color = Color(at: .pureBlack)
    var fill: Color = Color(at: .pureWhite)
    var disabledTint: Color?
    var isLoading = false
    var isEnabled = true
    let action: () -> Void

    private var foreground: Color {
        isEnabled ? tint : (disabledTint ?? tint)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfileV3Theme.Sizes.Save.buttonSpacing) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foreground)
                        .frame(width: ProfileV3Theme.Icon.lg, height: ProfileV3Theme.Icon.lg)
                } else if let icon {
                    icon
                        .profileV3Icon(iconSize)
                        .frame(
                            width: ProfileV3Theme.Icon.lg,
                            height: ProfileV3Theme.Icon.lg
                        )
                }
                Text(title)
                    .typoGraphy(.B1InterSemibold14)
            }
            .foregroundStyle(foreground)
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity)
            .frame(height: ProfileV3Theme.Sizes.Save.buttonHeight)
            .profileV3CapsuleChrome(fill: fill)
            .animation(ProfileV3Theme.Motion.saveState, value: isLoading)
        }
        .buttonStyle(.profileV3Pressable(.impact(weight: .medium)))
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled || disabledTint != nil ? 1 : ProfileV3Theme.Opacity.disabled)
        .accessibilityLabel(title)
        .accessibilityValue(isLoading ? ProfileV3Strings.loading : "")
    }
}

#if DEBUG
#Preview("Continue button") {
    VStack(spacing: ProfileV3Theme.Space.s20) {
        ProfileV3ContinueButton {}
        ProfileV3ContinueButton(isLoading: true) {}
        ProfileV3ContinueButton(isEnabled: false) {}
        ProfileV3ContinueButton(title: ProfileV3Strings.logout, tint: ProfileV3Theme.Palette.destructive) {}
        ProfileV3ContinueButton(
            title: ProfileV3Strings.deleteAccount,
            icon: ATIcon.SwiftUIImage.deleteOutline,
            tint: ProfileV3Theme.Palette.destructive,
            disabledTint: ProfileV3Theme.Palette.disabledText,
            isEnabled: false
        ) {}
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
