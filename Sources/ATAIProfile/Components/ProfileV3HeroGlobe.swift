import SwiftUI

struct ProfileV3GlobeHandoff: Equatable {
    var yaw: Double
    var velocity: Double
    var date: Date

    func yaw(at other: Date) -> Double {
        yaw + velocity * max(other.timeIntervalSince(date), 0)
    }

    static func from(_ pose: ProfileV3GlobePose, fallbackLongitude: Double, velocity: Double) -> ProfileV3GlobeHandoff {
        ProfileV3GlobeHandoff(
            yaw: pose.yaw ?? (90 - fallbackLongitude) * .pi / 180,
            velocity: velocity,
            date: pose.date
        )
    }
}

struct ProfileV3HeroGlobeState: Equatable {
    let pose: ProfileV3GlobePose
    let handoff: ProfileV3GlobeHandoff
    let destinationPitch: Double

    static func == (lhs: ProfileV3HeroGlobeState, rhs: ProfileV3HeroGlobeState) -> Bool {
        lhs.pose === rhs.pose && lhs.handoff == rhs.handoff && lhs.destinationPitch == rhs.destinationPitch
    }
}

struct ProfileV3HeroGlobe: View, Animatable {
    var progress: CGFloat
    let source: ProfileV3GlobeSphere
    let destination: ProfileV3GlobeSphere
    let state: ProfileV3HeroGlobeState
    var isAnimating = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.profileV3Globe) private var globe
    @State private var isLandReady = false

    private typealias Globe = ProfileV3Theme.Globe

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    private var isRunning: Bool { isAnimating && !reduceMotion }

    var body: some View {
        let sphere = source.interpolated(to: destination, progress: progress)
        let blend = Double(min(max(progress, 0), 1))
        let pitch = Globe.cardPitch + (state.destinationPitch - Globe.cardPitch) * Double(progress)
        let landReady = isLandReady
        ZStack {
            ProfileV3GlobeOrbits()
                .frame(width: sphere.radius * 4, height: sphere.radius * 4)
                .position(sphere.centre)
            SwiftUI.TimelineView(.animation(paused: !isRunning)) { timeline in
                Canvas { context, _ in
                    let yaw = state.handoff.yaw(at: timeline.date)
                    state.pose.yaw = yaw
                    state.pose.pitch = pitch
                    state.pose.velocity = isRunning ? state.handoff.velocity : 0
                    state.pose.date = timeline.date
                    state.pose.isRunning = isRunning
                    _ = landReady
                    draw(in: context, sphere: sphere, yaw: yaw, pitch: pitch, blend: blend)
                }
            }
        }
        .task {
            await globe.prepare(Globe.cardAppearance)
            await globe.prepare(Globe.expandedAppearance)
            isLandReady = true
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func draw(in context: GraphicsContext, sphere: ProfileV3GlobeSphere, yaw: Double, pitch: Double, blend: Double) {
        guard sphere.radius > 0 else { return }
        let disc = Path(ellipseIn: sphere.bounds)
        var settled = context
        settled.opacity = blend
        settled.fill(disc, with: .color(ProfileV3Theme.Palette.globeOcean))
        drawLand(
            in: context,
            projection: ProfileV3Globe.Projection(centre: sphere.centre, radius: sphere.radius, yaw: yaw, pitch: pitch),
            blend: blend
        )
        settled.fill(
            disc,
            with: .radialGradient(Globe.vignette, center: sphere.centre, startRadius: 0, endRadius: sphere.radius)
        )
        settled.fill(
            disc,
            with: .linearGradient(
                Globe.shade,
                startPoint: CGPoint(x: sphere.centre.x, y: sphere.bounds.minY),
                endPoint: CGPoint(x: sphere.centre.x, y: sphere.bounds.maxY)
            )
        )
    }

    /// The card and the open globe sample different land. Crossfade the two fields with the flight so
    /// the last frame is the field the settled globe draws, instead of swapping it on afterwards.
    private func drawLand(in context: GraphicsContext, projection: ProfileV3Globe.Projection, blend: Double) {
        if blend < 1 {
            var card = context
            card.opacity = 1 - blend
            globe.drawLand(Globe.cardAppearance, in: card, projection: projection)
        }
        if blend > 0 {
            var expanded = context
            expanded.opacity = blend
            globe.drawLand(Globe.expandedAppearance, in: expanded, projection: projection)
        }
    }
}

extension ProfileV3GlobeSphere {
    static func card(in frame: CGRect) -> ProfileV3GlobeSphere {
        ProfileV3GlobeSphere(
            centre: CGPoint(x: frame.midX, y: frame.midY + ProfileV3Theme.Sizes.worldPassGlobeOffsetY),
            radius: ProfileV3Theme.Sizes.worldPassGlobe * ProfileV3Theme.Globe.cardSphereRatio
        )
    }

    static func detailEstimate(in frame: CGRect) -> ProfileV3GlobeSphere {
        ProfileV3GlobeSphere(
            centre: CGPoint(x: frame.midX, y: frame.midY),
            radius: frame.width * ProfileV3Theme.Globe.sphereWidthRatio / 2
        )
    }

    func interpolated(to other: ProfileV3GlobeSphere, progress: CGFloat) -> ProfileV3GlobeSphere {
        ProfileV3GlobeSphere(
            centre: CGPoint(
                x: centre.x + (other.centre.x - centre.x) * progress,
                y: centre.y + (other.centre.y - centre.y) * progress
            ),
            radius: radius + (other.radius - radius) * progress
        )
    }
}
