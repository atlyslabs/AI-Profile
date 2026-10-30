import SwiftUI

struct ProfileV3FloatingControlBackground: View {
    var body: some View {
        Circle()
            .fill(Color.white)
            .overlay { Circle().fill(ProfileV3Theme.Palette.floatingControlWash) }
            .profileV3LiquidGlassIfAvailable(in: Circle(), interactive: true)
            .shadow(
                color: ProfileV3Theme.Palette.floatingControlShadow,
                radius: ProfileV3Theme.Shadow.floatingRadius,
                y: ProfileV3Theme.Shadow.floatingY
            )
    }
}

private extension View {
    @ViewBuilder
    func profileV3LiquidGlassIfAvailable(in shape: some Shape, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *), ProfileV3FeatureFlags.isFloatingControlGlassEnabled {
            profileV3GlassLayer(in: shape, interactive: interactive)
        } else {
            self
        }
    }
}

@available(iOS 26.0, *)
private extension View {
    @ViewBuilder
    func profileV3GlassLayer(in shape: some Shape, interactive: Bool) -> some View {
        if interactive {
            glassEffect(.regular.interactive(), in: shape)
        } else {
            glassEffect(.regular, in: shape)
        }
    }
}
