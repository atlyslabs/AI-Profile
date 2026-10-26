import ATUIKit
import SwiftUI

struct ProfileV3AddPastTripsPill: View {
    var title = ProfileV3Strings.addPastTrips
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Sizes = ProfileV3Theme.Sizes.PastTripsPill

    var body: some View {
        Button(action: action) {
            HStack(spacing: Sizes.gap) {
                Text(title)
                    .typoGraphy(.T1InterBold11)
                    .textCase(.uppercase)
                ATIcon.SwiftUIImage.addCircle
                    .profileV3Icon(Sizes.icon)
            }
            .foregroundStyle(Color(at: .pureWhite))
            .padding(.leading, Sizes.leading)
            .padding(.trailing, Sizes.trailing)
            .frame(height: ProfileV3Theme.Control.tapTarget)
            .background(
                Capsule()
                    .fill(ProfileV3Theme.detailPillGradient)
                    .shadow(
                        color: ProfileV3Theme.Palette.shadow,
                        radius: ProfileV3Theme.Shadow.cardRadius,
                        y: ProfileV3Theme.Shadow.chipY
                    )
            )
            .background {
                if !reduceMotion {
                    ProfileV3PulseRings()
                }
            }
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityLabel(title)
    }
}

private struct ProfileV3PulseRings: View {
    private typealias Sizes = ProfileV3Theme.Sizes.PastTripsPill
    private typealias Motion = ProfileV3Theme.Motion

    @Environment(\.profileV3PausesAnimations) private var isPaused

    var body: some View {
        SwiftUI.TimelineView(ProfileV3AmbientSchedule(isPaused: isPaused)) { context in
            let elapsed = context.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach((0..<Sizes.ringCount).reversed(), id: \.self) { index in
                    ring(progress: progress(elapsed: elapsed, index: index))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func ring(progress: Double?) -> some View {
        let eased = CGFloat(progress ?? 0)
        let scaleX: CGFloat = 1 + Sizes.ringGrowX * eased
        let scaleY: CGFloat = 1 + Sizes.ringGrowY * eased
        let fade: Double = progress.map { ProfileV3Theme.Opacity.tripRing * (1 - $0) } ?? 0
        return Capsule()
            .strokeBorder(
                Color(at: .pureWhite).opacity(ProfileV3Theme.Opacity.tripRingStroke),
                lineWidth: Sizes.ringStroke
            )
            .scaleEffect(x: scaleX, y: scaleY)
            .opacity(fade)
    }

    private func progress(elapsed: Double, index: Int) -> Double? {
        let time = elapsed.truncatingRemainder(dividingBy: Motion.pulseCycleSeconds)
            - Double(index) * Motion.pulseStaggerSeconds
        guard time > 0, time < Motion.pulseRingSeconds else { return nil }
        return Motion.pulseCurve.value(at: time / Motion.pulseRingSeconds)
    }
}
