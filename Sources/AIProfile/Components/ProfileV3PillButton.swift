import ATUIKit
import SwiftUI

struct ProfileV3PillButton: View {
    enum Size {
        case compact
        case medium
        case large
    }

    private var height: CGFloat {
        switch size {
        case .compact: return ProfileV3Theme.Control.compact
        case .medium: return ProfileV3Theme.Control.comfortable
        case .large: return ProfileV3Theme.Control.xLarge
        }
    }

    private var horizontalPadding: CGFloat {
        size == .medium ? ProfileV3Theme.Space.s24 : ProfileV3Theme.Space.s16
    }

    let title: String
    var size: Size = .compact
    var tint: Color = Color(at: .pureWhite)
    var titleTint: Color = Color(at: .pureBlack)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .typoGraphy(size == .compact ? .B2InterSemibold12 : .B1InterSemibold14)
                .foregroundStyle(titleTint)
            .padding(.horizontal, horizontalPadding)
            .frame(height: height)
            .frame(maxWidth: size == .large ? .infinity : nil)
            .profileV3CapsuleChrome(
                fill: tint,
                border: ProfileV3Theme.Palette.cardBorder,
                lineWidth: ProfileV3Theme.Stroke.hairline,
                shadowRadius: ProfileV3Theme.Shadow.pillRadius,
                shadowY: ProfileV3Theme.Shadow.pillY
            )
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(title)
    }
}

#if DEBUG
#Preview("Pill buttons") {
    VStack(spacing: ProfileV3Theme.Space.s24) {
        ProfileV3PillButton(title: ProfileV3Strings.viewAllBenefits(24)) {}
        ProfileV3PillButton(title: ProfileV3Strings.retry, size: .medium) {}
        ProfileV3PillButton(title: ProfileV3Strings.disconnectEmail, size: .large) {}
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
