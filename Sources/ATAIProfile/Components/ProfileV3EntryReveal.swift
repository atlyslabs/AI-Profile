import SwiftUI

struct ProfileV3EntryReveal: ViewModifier {
    let isRevealed: Bool
    var scale: CGFloat = ProfileV3Theme.Motion.entryScale
    var offsetY: CGFloat = ProfileV3Theme.Motion.entryOffsetY
    var animation: Animation?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let revealed = content
            .opacity(isRevealed ? 1 : 0)
            .scaleEffect(isRevealed ? 1 : (reduceMotion ? 1 : scale))
            .offset(y: isRevealed ? 0 : (reduceMotion ? 0 : offsetY))
            .allowsHitTesting(isRevealed)
            .accessibilityHidden(!isRevealed)
        if let animation {
            revealed.animation(reduceMotion ? nil : animation, value: isRevealed)
        } else {
            revealed
        }
    }
}

extension ProfileV3EntryReveal {
    static func staggered(
        _ index: Int,
        isRevealed: Bool,
        animation: Animation,
        stagger: Double,
        offsetY: CGFloat
    ) -> ProfileV3EntryReveal {
        ProfileV3EntryReveal(
            isRevealed: isRevealed,
            scale: 1,
            offsetY: offsetY,
            animation: animation.delay(Double(index) * stagger)
        )
    }
}

private struct ProfileV3SaveEntrance: ViewModifier {
    let isShown: Bool
    let revealsOnAppear: Bool
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .modifier(
                ProfileV3EntryReveal(
                    isRevealed: isShown && (hasAppeared || !revealsOnAppear),
                    offsetY: ProfileV3Theme.Motion.saveEntranceRise,
                    animation: ProfileV3Theme.Motion.entry
                )
            )
            .onAppear { hasAppeared = true }
    }
}

extension View {
    func profileV3EntryReveal(
        _ isRevealed: Bool,
        scale: CGFloat = ProfileV3Theme.Motion.entryScale,
        offsetY: CGFloat = ProfileV3Theme.Motion.entryOffsetY
    ) -> some View {
        modifier(ProfileV3EntryReveal(isRevealed: isRevealed, scale: scale, offsetY: offsetY))
    }

    func profileV3SaveEntrance() -> some View {
        modifier(ProfileV3SaveEntrance(isShown: true, revealsOnAppear: true))
    }

    func profileV3SaveEntrance(isShown: Bool) -> some View {
        modifier(ProfileV3SaveEntrance(isShown: isShown, revealsOnAppear: false))
    }
}
