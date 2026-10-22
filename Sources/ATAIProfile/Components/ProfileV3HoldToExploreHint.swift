import ATUIKit
import SwiftUI

struct ProfileV3HoldToExploreHint: View {
    var progress: CGFloat = 0
    var showsPill = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.profileV3PausesAnimations) private var isPaused
    @State private var appearedAt: Date?

    private var clampedProgress: CGFloat { min(max(progress, 0), 1) }
    private var isFilling: Bool { clampedProgress > 0 }
    private var nudges: Bool { showsPill && !reduceMotion && !isFilling }

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s16) {
            if showsPill {
                pill
            }
            SwiftUI.TimelineView(.profileV3Ambient(paused: !nudges || isPaused)) { context in
                joystick
                    .padding(.leading, showsPill ? ProfileV3Theme.Space.s24 : 0)
                    .offset(nudge(at: context.date))
            }
        }
        .onAppear {
            appearedAt = .now
        }
        .allowsHitTesting(false)
    }

    private func nudge(at date: Date) -> CGSize {
        guard nudges, let appearedAt else { return .zero }
        let swing = ProfileV3Theme.Motion.hintNudgeSeconds
        let elapsed = max(date.timeIntervalSince(appearedAt), 0).truncatingRemainder(dividingBy: 2 * swing)
        let reach = UnitCurve.easeInOut.value(at: elapsed < swing ? elapsed / swing : 2 - elapsed / swing)
        return CGSize(width: ProfileV3Theme.Space.s8 * reach, height: -ProfileV3Theme.Space.s4 * reach)
    }

    private var pill: some View {
        Text(ProfileV3Strings.holdToExplore)
            .typoGraphy(.T1InterBold11)
            .textCase(.uppercase)
            .foregroundStyle(Color(at: .pureWhite))
            .padding(.horizontal, ProfileV3Theme.Space.s10)
            .frame(height: ProfileV3Theme.Sizes.hintPillHeight)
            .background(Capsule().fill(.ultraThinMaterial))
            .background(Capsule().fill(Color(at: .primaryBrandBlue500).opacity(ProfileV3Theme.Opacity.hintCapsule)))
            .overlay(Capsule().stroke(Color(at: .pureWhite), lineWidth: ProfileV3Theme.Stroke.hairline))
    }

    private var joystick: some View {
        let inner = ProfileV3Theme.Sizes.joystickInner
        let middle = ProfileV3Theme.Sizes.joystickMiddle
        let outer = ProfileV3Theme.Sizes.joystickOuter
        let fill = inner + (middle - inner) * clampedProgress
        return ZStack {
            Circle()
                .fill(Color(at: .primaryBrandBlue500).opacity(ProfileV3Theme.Opacity.hintCapsule))
                .frame(width: outer, height: outer)
            Circle()
                .fill(Color(at: .pureWhite))
                .frame(width: middle, height: middle)
            Circle()
                .fill(Color(at: .primaryBrandBlue500))
                .frame(width: fill, height: fill)
        }
        .frame(width: outer, height: outer)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Hold to explore hint") {
    VStack(spacing: ProfileV3Theme.Space.s32) {
        ProfileV3HoldToExploreHint()
        ProfileV3HoldToExploreHint(progress: 0.45)
        ProfileV3HoldToExploreHint(progress: 1, showsPill: false)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .neutralGrey900))
}
#endif
