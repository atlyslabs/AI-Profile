import SwiftUI

private struct ProfileV3FlipModifier<Back: View>: ViewModifier, Animatable {
    var angle: Double
    let back: Back

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func body(content: Content) -> some View {
        let showsBack = angle >= 90
        let hidden = ProfileV3Theme.Opacity.hiddenFace
        ZStack {
            back
                .rotation3DEffect(.degrees(ProfileV3Theme.Rotation.half), axis: (x: 0, y: 1, z: 0))
                .opacity(showsBack ? 1 : hidden)
                .zIndex(showsBack ? 1 : 0)
                .allowsHitTesting(showsBack)
                .accessibilityHidden(!showsBack)
            content
                .opacity(showsBack ? hidden : 1)
                .zIndex(showsBack ? 0 : 1)
                .allowsHitTesting(!showsBack)
                .accessibilityHidden(showsBack)
        }
        .rotation3DEffect(
            .degrees(angle),
            axis: (x: 0, y: 1, z: 0),
            perspective: ProfileV3Theme.Sizes.Flip.perspective
        )
    }
}

extension View {
    func profileV3Flip<Back: View>(isFlipped: Bool, @ViewBuilder back: () -> Back) -> some View {
        modifier(ProfileV3FlipModifier(angle: isFlipped ? 180 : 0, back: back()))
    }
}
