import SwiftUI

struct ProfileV3AylOrb: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(ProfileV3Theme.aylOrbGradient)
            ProfileV3GloveBoxArt.aylMark.image
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(ProfileV3Theme.Palette.aylOrbMark)
                .frame(width: size * ProfileV3Theme.Sizes.InstagramConnect.orbMarkRatio)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
