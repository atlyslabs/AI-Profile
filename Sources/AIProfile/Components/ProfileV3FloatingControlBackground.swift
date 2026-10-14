import SwiftUI

struct ProfileV3FloatingControlBackground: View {
    var body: some View {
        Circle()
            .fill(Color.white)
            .overlay { Circle().fill(Color.black.opacity(0.05)) }
            .profileV3LiquidGlassIfAvailable(in: Circle(), interactive: true)
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

private extension View {
    @ViewBuilder
    func profileV3LiquidGlassIfAvailable(in shape: some Shape, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
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
