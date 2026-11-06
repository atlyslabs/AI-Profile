import SwiftUI

struct ProfileV3OrbParticle {
    let rest: CGPoint
    let size: CGFloat
    let start: CGSize
    let isLight: Bool
    private let travel: ProfileV3Keyframes
    private let glow: ProfileV3Keyframes

    init(index: Int, rest: CGPoint, size: CGFloat, start: CGSize) {
        typealias Motion = ProfileV3Theme.Motion.AylOrbAssembly
        let delay = Motion.particleDelay + Motion.particleStagger * Double(index % Motion.particleStaggerCycle)
        self.rest = rest
        self.size = size
        self.start = start
        isLight = index.isMultiple(of: Motion.particleLightCycle)
        travel = ProfileV3Keyframes(0)
            .hold(until: delay)
            .to(1, at: Motion.seconds, .easeInOut)
        glow = ProfileV3Keyframes(0)
            .to(Motion.particleGlowOpacity, at: delay + Motion.particleGlow, .easeInOut)
            .to(Motion.particlePeakOpacity, at: delay + Motion.particlePeak, .easeInOut)
            .to(0, at: Motion.seconds, .easeInOut)
    }

    func position(at elapsed: TimeInterval) -> CGPoint {
        let remaining = 1 - travel.value(at: elapsed)
        return CGPoint(x: rest.x + start.width * remaining, y: rest.y + start.height * remaining)
    }

    func opacity(at elapsed: TimeInterval) -> Double {
        glow.value(at: elapsed)
    }
}

struct ProfileV3AylOrbAssembly: View {
    let size: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()

    var body: some View {
        Group {
            if reduceMotion {
                ProfileV3AylOrb(size: size)
            } else {
                TimelineView(.animation) { context in
                    ProfileV3AylOrbAssemblyFrame(size: size, elapsed: context.date.timeIntervalSince(start))
                }
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct ProfileV3AylOrbAssemblyFrame: View {
    let size: CGFloat
    let elapsed: TimeInterval

    private typealias Motion = ProfileV3Theme.Motion.AylOrbAssembly

    var body: some View {
        let particleScale = Motion.particleScale.value(at: elapsed)
        ZStack {
            ProfileV3Theme.Palette.aylOrbLime
                .opacity(Motion.limeOpacity.value(at: elapsed))
            ProfileV3AylOrb(size: size)
                .opacity(Motion.orbOpacity.value(at: elapsed))
            ForEach(Array(ProfileV3Theme.Sizes.InstagramConnect.orbParticles.enumerated()), id: \.offset) { _, particle in
                Circle()
                    .fill(particle.isLight ? ProfileV3Theme.Palette.aylOrbParticleLight : ProfileV3Theme.Palette.aylOrbParticle)
                    .frame(width: particle.size, height: particle.size)
                    .scaleEffect(particleScale)
                    .opacity(particle.opacity(at: elapsed))
                    .position(particle.position(at: elapsed))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .scaleEffect(Motion.scale.value(at: elapsed))
        .blur(radius: Motion.blur.value(at: elapsed))
    }
}
