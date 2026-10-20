import ATUIKit
import SwiftUI

struct ProfileV3KYCGlow: View {
    let title: String
    let subtitle: String?
    let tone: ProfileV3KYCGlowTone
    let trigger: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasRisen: Bool

    init(title: String, subtitle: String?, tone: ProfileV3KYCGlowTone, trigger: Int) {
        self.title = title
        self.subtitle = subtitle
        self.tone = tone
        self.trigger = trigger
        _hasRisen = State(initialValue: trigger > 0)
    }

    private var holdsGlow: Bool { tone == .negative && hasRisen }

    var body: some View {
        PhaseAnimator(ProfileV3KYCGlowPhase.sequence, trigger: trigger) { phase in
            overlay(phase)
                .onChange(of: phase) { _, phase in
                    if phase == .risen { hasRisen = true }
                }
        } animation: { phase in
            phase.animation
        }
        .frame(width: ProfileV3Theme.Sizes.worldPassWidth, height: ProfileV3Theme.Sizes.worldPassHeight)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func overlay(_ phase: ProfileV3KYCGlowPhase) -> some View {
        ZStack {
            glow(phase)
            caption
                .offset(y: ProfileV3Theme.Sizes.worldPassGlobeOffsetY)
                .opacity(phase.showsCaption ? 1 : 0)
        }
    }

    private func glow(_ phase: ProfileV3KYCGlowPhase) -> some View {
        let radius = ProfileV3Theme.Sizes.kycGlowRadius
        let isCentred = reduceMotion || phase.isCentred
        let restingY = ProfileV3Theme.Sizes.worldPassGlobeOffsetY
        return Circle()
            .fill(RadialGradient(gradient: gradient, center: .center, startRadius: 0, endRadius: radius))
            .frame(width: radius * 2, height: radius * 2)
            .scaleEffect(isCentred ? 1 : ProfileV3Theme.Sizes.kycGlowStartScale)
            .offset(y: isCentred ? restingY : ProfileV3Theme.Sizes.worldPassHeight / 2)
            .opacity(phase == .idle && holdsGlow ? 1 : phase.glowOpacity)
    }

    private var caption: some View {
        VStack(spacing: ProfileV3Theme.Space.s6) {
            if !title.isEmpty {
                Text(title)
                    .typoGraphy(.T1InterBold11)
                    .textCase(.uppercase)
                    .foregroundStyle(ProfileV3Theme.Palette.kycGlowTitle)
            }
            if let subtitle {
                Text(subtitle)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(ProfileV3Theme.Palette.kycGlowSubtitle)
            }
        }
        .multilineTextAlignment(.center)
    }

    private var gradient: Gradient {
        switch tone {
        case .positive: return ProfileV3Theme.kycGlowActiveGradient
        case .negative, .hidden: return ProfileV3Theme.kycGlowInactiveGradient
        }
    }
}

private enum ProfileV3KYCGlowPhase: Equatable {
    case idle
    case seeded
    case risen
    case captioned

    static let sequence: [ProfileV3KYCGlowPhase] = [.idle, .seeded, .risen, .captioned]

    var isCentred: Bool { self != .seeded }
    var glowOpacity: Double { self == .idle || self == .seeded ? 0 : 1 }
    var showsCaption: Bool { self == .captioned }

    var animation: Animation? {
        switch self {
        case .idle: return ProfileV3Theme.Motion.kycGlowFade
        case .seeded: return nil
        case .risen: return ProfileV3Theme.Motion.kycGlowRise
        case .captioned: return ProfileV3Theme.Motion.kycGlowCaption
        }
    }
}

#if DEBUG
private struct ProfileV3KYCGlowPreview: View {
    @State private var trigger = 0

    var body: some View {
        ScrollView {
            VStack(spacing: ProfileV3Theme.Space.s20) {
                ProfileV3WorldPassCard(pass: ProfileV3Fixtures.worldPass, glowTrigger: trigger)
                ProfileV3WorldPassCard(pass: ProfileV3Fixtures.notDonePass, glowTrigger: trigger)
                ProfileV3WorldPassCard(pass: ProfileV3Fixtures.coTravellerPass, glowTrigger: trigger)
            }
            .padding(ProfileV3Theme.Space.s32)
        }
        .background(Color(at: .pureWhite))
        .task { trigger += 1 }
    }
}

#Preview("KYC glow") {
    ProfileV3KYCGlowPreview()
}
#endif
