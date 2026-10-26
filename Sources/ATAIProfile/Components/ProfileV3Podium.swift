import ATUIKit
import SwiftUI

struct ProfileV3Podium: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(ProfileV3Theme.podiumShadowGradient)
                .frame(width: ProfileV3Theme.Sizes.Podium.shadowWidth, height: ProfileV3Theme.Sizes.Podium.shadowHeight)
                .blur(radius: ProfileV3Theme.Sizes.Podium.shadowBlur)
                .offset(x: ProfileV3Theme.Sizes.Podium.shadowOffsetX, y: ProfileV3Theme.Sizes.Podium.shadowOffsetY)
            ProfileV3RemoteImage(url: ProfileV3PlaceholderArt.podium.url, contentMode: .fit, placeholder: .clear)
                .frame(width: ProfileV3Theme.Sizes.Podium.discWidth, height: ProfileV3Theme.Sizes.Podium.height)
                .blendMode(.multiply)
        }
        .frame(height: ProfileV3Theme.Sizes.Podium.height)
        .padding(.horizontal, ProfileV3Theme.Sizes.Podium.renderSpill)
        .drawingGroup()
        .padding(.horizontal, -ProfileV3Theme.Sizes.Podium.renderSpill)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Podium") {
    ProfileV3Podium()
        .padding(ProfileV3Theme.Space.s32)
        .background(Color(at: .pureWhite))
}
#endif
