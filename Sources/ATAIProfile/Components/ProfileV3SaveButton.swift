import ATUIKit
import SwiftUI

struct ProfileV3SaveButton: View {
    let phase: ProfileV3SavePhase
    let title: String
    let savedTitle: String
    let action: () -> Void

    private var isSaved: Bool { phase == .saved }

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfileV3Theme.Sizes.Save.buttonSpacing) {
                leading
                Text(displayTitle)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(Color(at: .pureBlack))
            }
            .padding(.leading, leadingPadding)
            .padding(.trailing, trailingPadding)
            .frame(height: ProfileV3Theme.Sizes.Save.buttonHeight)
            .profileV3CapsuleChrome(
                fill: background,
                border: isSaved ? Color(at: .pureWhite) : ProfileV3Theme.Palette.saveButtonBorder,
                lineWidth: isSaved ? ProfileV3Theme.Stroke.hairline : ProfileV3Theme.Stroke.thin,
                shadowRadius: isSaved ? ProfileV3Theme.Shadow.savedRadius : ProfileV3Theme.Shadow.softRadius,
                shadowY: isSaved ? ProfileV3Theme.Shadow.savedY : ProfileV3Theme.Shadow.softY
            )
            .animation(ProfileV3Theme.Motion.saveState, value: phase)
        }
        .buttonStyle(.profileV3Pressable(.impact(weight: .medium)))
        .disabled(phase == .saving || phase == .saved)
        .accessibilityLabel(displayTitle)
        .accessibilityValue(phase == .saving ? ProfileV3Strings.loading : "")
    }

    private var displayTitle: String {
        isSaved ? savedTitle : title
    }

    @ViewBuilder
    private var leading: some View {
        switch phase {
        case .idle, .failed:
            ATIcon.SwiftUIImage.check
                .profileV3Icon(ProfileV3Theme.Sizes.Save.buttonIcon)
                .foregroundStyle(Color(at: .pureBlack))
        case .saving:
            ProfileV3Spinner(size: ProfileV3Theme.Sizes.Save.buttonIcon, lineWidth: ProfileV3Theme.Stroke.regular)
        case .saved:
            EmptyView()
        }
    }

    private var leadingPadding: CGFloat {
        isSaved ? ProfileV3Theme.Sizes.Save.savedPadding : ProfileV3Theme.Sizes.Save.buttonLeading
    }

    private var trailingPadding: CGFloat {
        isSaved ? ProfileV3Theme.Sizes.Save.savedPadding : ProfileV3Theme.Sizes.Save.buttonTrailing
    }

    private var background: AnyShapeStyle {
        isSaved ? AnyShapeStyle(ProfileV3Theme.savedGradient) : AnyShapeStyle(Color(at: .pureWhite))
    }
}

#if DEBUG
#Preview("Save button phases") {
    VStack(spacing: ProfileV3Theme.Space.s24) {
        ForEach([ProfileV3SavePhase.idle, .saving, .saved], id: \.self) { phase in
            ProfileV3SaveButton(
                phase: phase,
                title: ProfileV3Strings.saveChanges,
                savedTitle: ProfileV3Strings.agentPreferencesUpdated
            ) {}
        }
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
