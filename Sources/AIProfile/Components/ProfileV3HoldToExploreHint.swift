import ATUIKit
import SwiftUI

struct ProfileV3HoldToExploreHint: View {
    var progress: CGFloat = 0
    var showsPill = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isNudged = false

    private var clampedProgress: CGFloat { min(max(progress, 0), 1) }
    private var isFilling: Bool { clampedProgress > 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s16) {
            if showsPill {
                pill
            }
            joystick
                .padding(.leading, showsPill ? ProfileV3Theme.Space.s24 : 0)
                .offset(nudge)
        }
        .onAppear {
            guard showsPill, !reduceMotion else { return }
            withAnimation(ProfileV3Theme.Motion.hintNudge) {
                isNudged = true
            }
        }
        .onDisappear {
            isNudged = false
        }
        .allowsHitTesting(false)
    }

    private var nudge: CGSize {
        guard isNudged, !isFilling else { return .zero }
        return CGSize(width: ProfileV3Theme.Space.s8, height: -ProfileV3Theme.Space.s4)
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
