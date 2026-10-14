import ATUIKit
import SwiftUI

struct ProfileV3GradientButton: View {
    enum Style {
        case car
        case redeem

        var feedback: SensoryFeedback {
            switch self {
            case .car: return .impact(weight: .medium)
            case .redeem: return .impact(weight: .light)
            }
        }
    }

    let title: String
    var style: Style = .car
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            label
                .contentShape(Capsule())
        }
        .buttonStyle(.profileV3Pressable(style.feedback))
        .accessibilityLabel(title)
    }

    private var text: some View {
        Text(title)
            .typoGraphy(.B1InterSemibold14)
            .foregroundStyle(Color(at: .pureBlack))
            .frame(maxWidth: .infinity)
            .frame(height: ProfileV3Theme.Control.large)
    }

    @ViewBuilder
    private var label: some View {
        switch style {
        case .car:
            text
                .background(
                    ProfileV3Theme.carButtonGradient
                        .blur(radius: ProfileV3Theme.Sizes.gradientButtonBlur)
                        .padding(-ProfileV3Theme.Sizes.gradientButtonBlur)
                        .overlay(ProfileV3Theme.redeemFrost)
                )
                .clipShape(Capsule())
        case .redeem:
            text
                .background {
                    ZStack {
                        Capsule().fill(ProfileV3Theme.redeemGradient)
                        Capsule().fill(ProfileV3Theme.redeemFrost)
                    }
                }
                .overlay(
                    Capsule().stroke(ProfileV3Theme.Palette.redeemBorder, lineWidth: ProfileV3Theme.Stroke.hairline)
                )
                .shadow(
                    color: ProfileV3Theme.Palette.shadow,
                    radius: ProfileV3Theme.Shadow.redeemRadius,
                    y: ProfileV3Theme.Shadow.redeemY
                )
        }
    }
}

#if DEBUG
#Preview("Gradient buttons") {
    VStack(spacing: ProfileV3Theme.Space.s20) {
        ProfileV3GradientButton(title: ProfileV3Strings.updatePassport) {}
        ProfileV3GradientButton(title: ProfileV3Strings.redeem, style: .redeem) {}
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
