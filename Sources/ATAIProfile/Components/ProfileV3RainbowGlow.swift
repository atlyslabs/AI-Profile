import SwiftUI

struct ProfileV3RainbowGlow: View {
    let diameter: CGFloat
    var fillOpacity: Double = 1
    var gradient = ProfileV3Theme.rainbowGlowGradient

    var body: some View {
        Circle()
            .fill(gradient)
            .opacity(fillOpacity)
            .frame(width: diameter, height: diameter)
            .blur(radius: ProfileV3Theme.Sizes.rainbowGlowBlur)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Rainbow glow") {
    ProfileV3RainbowGlow(diameter: 237, fillOpacity: ProfileV3Theme.Opacity.accessGlowFill)
        .padding(80)
        .background(Color.white)
}
#endif
