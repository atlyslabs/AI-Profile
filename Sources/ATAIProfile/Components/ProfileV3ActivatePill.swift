import ATUIKit
import SwiftUI

struct ProfileV3ActivatePill: View {
    var showsBolt = false

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.lg, style: .continuous)
    }

    var body: some View {
        HStack(spacing: ProfileV3Theme.Space.s4) {
            if showsBolt {
                ProfileV3Vector.bolt.image
                    .profileV3Icon(ProfileV3Theme.Icon.sm)
            }
            Text(ProfileV3Strings.activate)
                .typoGraphy(.T1InterBold11)
                .textCase(.uppercase)
        }
        .foregroundStyle(Color(at: .pureWhite))
        .padding(.leading, showsBolt ? ProfileV3Theme.Space.s4 : ProfileV3Theme.Space.s8)
        .padding(.trailing, ProfileV3Theme.Space.s8)
        .frame(height: ProfileV3Theme.Sizes.activatePillHeight)
        .background(shape.fill(ProfileV3Theme.activateGradient))
        .overlay(shape.strokeBorder(ProfileV3Theme.activateRingGradient, lineWidth: ProfileV3Theme.Stroke.hairline))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ProfileV3Strings.activate)
    }
}

#if DEBUG
#Preview("Activate pills") {
    HStack(spacing: ProfileV3Theme.Space.s16) {
        ProfileV3ActivatePill()
        ProfileV3ActivatePill(showsBolt: true)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
