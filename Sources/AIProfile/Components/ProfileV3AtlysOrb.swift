import ATUIKit
import SwiftUI

struct ProfileV3AtlysOrb: View {
    enum Ring: Equatable {
        case scanning
        case found
        case muted
        case still
    }

    struct Metrics: Equatable {
        let ringOuter: CGFloat
        let ringInner: CGFloat
        let star: CGFloat
        let lineWidth: CGFloat
        let ringOpacity: Double

        static let scanning = Metrics(
            ringOuter: ProfileV3Theme.Sizes.AddProgramme.ringOuter,
            ringInner: ProfileV3Theme.Sizes.AddProgramme.ringInner,
            star: ProfileV3Theme.Sizes.AddProgramme.orb,
            lineWidth: ProfileV3Theme.Stroke.medium,
            ringOpacity: ProfileV3Theme.Motion.orbRingOpacity
        )

        static let insight = Metrics(
            ringOuter: ProfileV3Theme.Sizes.Insight.orbRingOuter,
            ringInner: ProfileV3Theme.Sizes.Insight.orbRingInner,
            star: ProfileV3Theme.Sizes.Insight.orb,
            lineWidth: ProfileV3Theme.Stroke.hairline,
            ringOpacity: 1
        )
    }

    var ring: Ring = .scanning
    var metrics: Metrics = .scanning
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSpinning = false

    private var shouldSpin: Bool { !reduceMotion && ring == .scanning }

    var body: some View {
        ZStack {
            switch ring {
            case .scanning, .muted, .still:
                scanningRings
                    .rotationEffect(.degrees(isSpinning ? 360 : 0))
                    .animation(isSpinning ? ProfileV3Theme.Motion.orbSpin : nil, value: isSpinning)
            case .found:
                Circle()
                    .fill(Color(at: .pureWhite))
                    .overlay(
                        Circle().stroke(
                            Color(at: .accentEmerald500),
                            lineWidth: ProfileV3Theme.Stroke.regular
                        )
                    )
                    .frame(
                        width: ProfileV3Theme.Sizes.AddProgramme.foundRing,
                        height: ProfileV3Theme.Sizes.AddProgramme.foundRing
                    )
                    .transition(.scale(scale: ProfileV3Theme.Motion.popInScale).combined(with: .opacity))
            }
            ProfileV3RemoteImage(url: ProfileV3ProgrammeArt.orbStar.url, placeholder: .clear)
                .frame(width: metrics.star, height: metrics.star)
                .clipShape(Circle())
                .grayscale(ring == .muted ? 1 : 0)
        }
        .frame(width: metrics.ringOuter, height: metrics.ringOuter)
        .animation(ProfileV3Theme.Motion.expand, value: ring)
        .onChange(of: shouldSpin, initial: true) { _, spin in isSpinning = spin }
        .accessibilityHidden(true)
    }

    private var scanningRings: some View {
        ZStack {
            Circle()
                .stroke(ProfileV3Theme.orbRingGradient, lineWidth: metrics.lineWidth)
                .frame(width: metrics.ringOuter, height: metrics.ringOuter)
            Circle()
                .stroke(ProfileV3Theme.orbRingGradient, lineWidth: metrics.lineWidth)
                .frame(width: metrics.ringInner, height: metrics.ringInner)
                .rotationEffect(.degrees(ProfileV3Theme.Rotation.half))
        }
        .opacity(metrics.ringOpacity)
    }
}

#if DEBUG
#Preview("Atlys orb") {
    HStack(spacing: ProfileV3Theme.Space.s32) {
        ProfileV3AtlysOrb(ring: .scanning)
        ProfileV3AtlysOrb(ring: .found)
        ProfileV3AtlysOrb(ring: .muted)
        ProfileV3AtlysOrb(ring: .still, metrics: .insight)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
