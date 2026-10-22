import ATUIKit
import SwiftUI

private struct ProfileV3HoverModifier: ViewModifier {
    let isActive: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.profileV3PausesAnimations) private var isPaused
    @State private var activatedAt: Date?

    private var isHovering: Bool { isActive && !reduceMotion }

    func body(content: Content) -> some View {
        SwiftUI.TimelineView(.profileV3Ambient(paused: !isHovering || isPaused)) { context in
            hovering(content, wave: isHovering ? wave(at: context.date) : nil)
        }
        .onChange(of: isHovering, initial: true) { _, hovering in
            activatedAt = hovering ? .now : nil
        }
    }

    private func wave(at date: Date) -> CGFloat {
        guard let activatedAt else { return 0 }
        let halfCycle = ProfileV3Theme.Motion.hoverHalfCycleSeconds
        let phase = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2 * halfCycle)
        let settle = min(max(date.timeIntervalSince(activatedAt) / ProfileV3Theme.Motion.hoverSettleSeconds, 0), 1)
        return CGFloat(sin(.pi * phase / halfCycle) * settle)
    }

    private func hovering(_ content: Content, wave: CGFloat?) -> some View {
        let raised = wave.map { (1 + $0) / 2 } ?? 0
        return content
            .offset(y: -ProfileV3Theme.Motion.hoverAmplitude * (wave ?? 0))
            .overlay(alignment: .bottom) {
                ProfileV3HoverShadow()
                    .scaleEffect(1 + (ProfileV3Theme.Motion.hoverShadowRaisedScale - 1) * raised)
                    .opacity(1 + (ProfileV3Theme.Motion.hoverShadowRaisedOpacity - 1) * raised)
                    .offset(y: ProfileV3Theme.Sizes.hoverShadowDrop + ProfileV3Theme.Sizes.hoverShadowHeight / 2)
                    .opacity(isActive ? 1 : 0)
                    .animation(
                        isActive ? ProfileV3Theme.Motion.podiumShow : ProfileV3Theme.Motion.podiumHide,
                        value: isActive
                    )
            }
    }
}

private struct ProfileV3HoverShadow: View {
    var body: some View {
        Circle()
            .fill(ProfileV3Theme.hoverShadowGradient)
            .frame(width: ProfileV3Theme.Sizes.hoverShadowWidth, height: ProfileV3Theme.Sizes.hoverShadowWidth)
            .scaleEffect(y: ProfileV3Theme.Sizes.hoverShadowHeight / ProfileV3Theme.Sizes.hoverShadowWidth)
            .frame(height: ProfileV3Theme.Sizes.hoverShadowHeight)
            .allowsHitTesting(false)
    }
}

extension View {
    func profileV3Hover(isActive: Bool = true) -> some View {
        modifier(ProfileV3HoverModifier(isActive: isActive))
    }
}

#if DEBUG
#Preview("Hovering card") {
    VStack(spacing: 0) {
        ProfileV3WorldPassCard(pass: ProfileV3Fixtures.worldPass)
            .profileV3Hover()
            .zIndex(1)
        ProfileV3Podium()
            .padding(.top, ProfileV3Theme.Sizes.Podium.topSpacing)
    }
    .padding(.vertical, ProfileV3Theme.Space.s32)
    .frame(maxWidth: .infinity)
    .background(Color(at: .pureWhite))
}
#endif
