import ATUIKit
import SwiftUI

struct ProfileV3InteractiveGlobe: View {
    let visitedCountryCodes: [String]
    var isAnimating = true
    var pose: ProfileV3GlobePose?
    var onSphere: ((ProfileV3GlobeSphere) -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.profileV3PausesAnimations) private var isPaused
    @Environment(\.profileV3Globe) private var globe
    @State private var isLandReady = false
    @State private var hasTakenHandoff = false
    @State private var spin = ProfileV3GlobeSpin.resting
    @State private var dragOrigin: ProfileV3GlobeSpin?
    @State private var direction: Double = 1
    @State private var arrivals: [String: Date] = [:]
    @State private var size: CGSize = .zero
    @State private var frameClock = ProfileV3GlobeFrameClock()
    @State private var flare: Image?

    private typealias Globe = ProfileV3Theme.Globe

    private var isRunning: Bool { isAnimating && !reduceMotion }
    private var cruise: Double { isRunning ? direction * Globe.cruiseSpeed : 0 }

    var body: some View {
        let landReady = isLandReady
        SwiftUI.TimelineView(.profileV3Ambient(paused: !isRunning || isPaused)) { timeline in
            Canvas { context, size in
                frameClock.date = timeline.date
                _ = landReady
                draw(in: context, size: size, at: timeline.date)
            }
        }
        .background { orbits }
        .overlay { rim }
        .contentShape(Rectangle())
        .gesture(drag)
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(ProfileV3HeroSpace.name)) } action: { frame in
            size = frame.size
            let local = sphere(in: frame.size)
            onSphere?(ProfileV3GlobeSphere(
                centre: CGPoint(x: frame.minX + local.centre.x, y: frame.minY + local.centre.y),
                radius: local.radius
            ))
        }
        .task {
            await globe.prepare(Globe.expandedAppearance)
            isLandReady = true
        }
        .task {
            guard flare == nil, let url = ProfileV3PlaceholderArt.globeFlare.url,
                  let image = await ProfileV3RemoteImage.image(at: url) else { return }
            flare = Image(uiImage: image)
        }
        .onAppear {
            let now = Date()
            if let handedOff = handedOffSpin(at: now) {
                spin = handedOff
                hasTakenHandoff = isRunning
            } else {
                spin = spin.coasting(velocity: cruise, cruise: cruise, at: now)
            }
            scheduleArrivals(from: now)
        }
        .onChange(of: isAnimating) { _, animating in
            let now = Date()
            if animating, let handedOff = handedOffSpin(at: now) {
                spin = handedOff
                hasTakenHandoff = true
            } else {
                hasTakenHandoff = false
                spin = spin.coasting(velocity: isRunning ? spin.velocity(at: now) : 0, cruise: cruise, at: now)
            }
            scheduleArrivals(from: now)
        }
        .onChange(of: visitedCountryCodes) { _, codes in
            arrivals = arrivals.filter { codes.contains($0.key) }
            scheduleArrivals(from: .now)
        }
        .accessibilityHidden(true)
    }

    private var orbits: some View {
        let sphere = sphere(in: size)
        return ProfileV3GlobeOrbits()
            .frame(width: sphere.radius * 4, height: sphere.radius * 4)
            .position(sphere.centre)
            .allowsHitTesting(false)
    }

    private var rim: some View {
        let sphere = sphere(in: size)
        return ProfileV3GlobeRim()
            .frame(width: sphere.radius * 2, height: sphere.radius * 2)
            .position(sphere.centre)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: Globe.dragMinimumDistance)
            .onChanged { value in
                let radius = sphere(in: size).radius
                guard radius > 0 else { return }
                let origin = dragOrigin ?? spin.frozen(at: frameClock.date)
                dragOrigin = origin
                spin = origin.dragged(by: value.translation, radius: radius, at: frameClock.date)
            }
            .onEnded { value in
                let radius = sphere(in: size).radius
                dragOrigin = nil
                guard radius > 0 else { return }
                let fling = Double(value.velocity.width / radius)
                var spinDirection = direction
                if abs(fling) > Globe.flingThreshold {
                    spinDirection = fling < 0 ? -1 : 1
                } else if value.translation.width != 0 {
                    spinDirection = value.translation.width < 0 ? -1 : 1
                }
                direction = spinDirection
                let velocity = isRunning ? min(max(fling, -Globe.maxFlingSpeed), Globe.maxFlingSpeed) : 0
                let cruise = isRunning ? spinDirection * Globe.cruiseSpeed : 0
                spin = spin.coasting(velocity: velocity, cruise: cruise, at: frameClock.date)
            }
    }

    /// Until this globe takes over, follow the flying globe's pose. The spin captured at appear is the
    /// card's, and painting that once the card has finished is the flash.
    private func orientation(at date: Date) -> (yaw: Double, pitch: Double) {
        if hasTakenHandoff {
            publishPose(at: date)
            return (spin.yaw(at: date), spin.pitch)
        }
        if let pose, let yaw = pose.yaw {
            let carried = yaw + pose.velocity * max(date.timeIntervalSince(pose.date), 0)
            return (carried, pose.pitch ?? Globe.restPitch)
        }
        return (spin.yaw(at: date), spin.pitch)
    }

    private func handedOffSpin(at date: Date) -> ProfileV3GlobeSpin? {
        guard let pose, let yaw = pose.yaw else { return nil }
        let carried = yaw + pose.velocity * max(date.timeIntervalSince(pose.date), 0)
        if pose.velocity < 0 { direction = -1 } else if pose.velocity > 0 { direction = 1 }
        return ProfileV3GlobeSpin(
            yaw: carried,
            pitch: pose.pitch ?? Globe.restPitch,
            velocity: isRunning ? pose.velocity : 0,
            cruise: cruise,
            time: date
        )
    }

    private func publishPose(at date: Date) {
        guard let pose, isRunning else { return }
        pose.yaw = spin.yaw(at: date)
        pose.pitch = spin.pitch
        pose.velocity = spin.velocity(at: date)
        pose.date = date
        pose.isRunning = isRunning
    }

    private func scheduleArrivals(from date: Date) {
        guard isRunning else { return }
        var delay = arrivals.isEmpty ? Globe.markerEntranceDelay : 0
        for code in visitedCountryCodes where arrivals[code] == nil {
            arrivals[code] = date.addingTimeInterval(delay)
            delay += Globe.markerEntranceStagger
        }
    }

    private func sphere(in size: CGSize) -> ProfileV3GlobeSphere {
        let diameter = min(size.width * Globe.sphereWidthRatio, size.height - 2 * Globe.sphereVerticalInset)
        return ProfileV3GlobeSphere(
            centre: CGPoint(x: size.width / 2, y: size.height / 2),
            radius: max(diameter, 0) / 2
        )
    }

    private func draw(in context: GraphicsContext, size: CGSize, at date: Date) {
        let sphere = sphere(in: size)
        guard sphere.radius > 0 else { return }
        let orientation = orientation(at: date)
        let projection = ProfileV3Globe.Projection(
            centre: sphere.centre,
            radius: sphere.radius,
            yaw: orientation.yaw,
            pitch: orientation.pitch
        )
        let disc = Path(ellipseIn: sphere.bounds)
        context.fill(disc, with: .color(ProfileV3Theme.Palette.globeOcean))
        globe.drawLand(Globe.expandedAppearance, in: context, projection: projection)
        context.fill(
            disc,
            with: .radialGradient(Globe.vignette, center: sphere.centre, startRadius: 0, endRadius: sphere.radius)
        )
        context.fill(
            disc,
            with: .linearGradient(
                Globe.shade,
                startPoint: CGPoint(x: sphere.centre.x, y: sphere.bounds.minY),
                endPoint: CGPoint(x: sphere.centre.x, y: sphere.bounds.maxY)
            )
        )
        drawMarkers(in: context, projection: projection, at: date)
    }

    private func drawMarkers(in context: GraphicsContext, projection: ProfileV3Globe.Projection, at date: Date) {
        let flare = flare.map { context.resolve($0) }
        for (index, code) in visitedCountryCodes.enumerated() {
            guard let location = ProfileV3GlobeLocations.coordinate(for: code) else { continue }
            let (point, depth) = projection.project(latitude: location.latitude, longitude: location.longitude)
            let entrance = entrance(for: code, at: date)
            let opacity = ProfileV3Theme.ramp(
                CGFloat(depth),
                from: Globe.markerHiddenDepth,
                to: Globe.markerShownDepth
            ) * entrance.opacity
            guard opacity > 0 else { continue }
            let nearness = CGFloat(min(max(depth, 0), 1))
            let diameter = Globe.markerDiameters[index % Globe.markerDiameters.count]
                * entrance.scale
                * (1 - Globe.markerDepthShrink * (1 - nearness))

            if let flare, flare.size.width > 0 {
                var sprite = context
                sprite.opacity = opacity * Globe.markerFlareOpacity
                sprite.translateBy(x: point.x, y: point.y)
                sprite.rotate(by: Globe.markerFlareRotation)
                sprite.scaleBy(x: 1, y: -1)
                let flareWidth = diameter * Globe.markerFlareRatio
                let flareHeight = flareWidth * flare.size.height / flare.size.width
                sprite.draw(
                    flare,
                    in: CGRect(x: -flareWidth / 2, y: -flareHeight / 2, width: flareWidth, height: flareHeight)
                )
            }

            var ring = context
            ring.opacity = opacity
            let lineWidth = ProfileV3Theme.Stroke.fine
            let bounds = CGRect(x: point.x - diameter / 2, y: point.y - diameter / 2, width: diameter, height: diameter)
                .insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
            ring.stroke(
                Path(ellipseIn: bounds),
                with: .linearGradient(
                    Globe.markerRing,
                    startPoint: CGPoint(x: bounds.midX, y: bounds.minY),
                    endPoint: CGPoint(x: bounds.midX, y: bounds.maxY)
                ),
                lineWidth: lineWidth
            )
        }
    }

    private func entrance(for code: String, at date: Date) -> (scale: CGFloat, opacity: Double) {
        guard !reduceMotion else { return (1, 1) }
        guard let arrival = arrivals[code] else { return (0, 0) }
        let elapsed = date.timeIntervalSince(arrival)
        guard elapsed > 0 else { return (0, 0) }
        guard elapsed < Globe.markerEntrance.settlingDuration else { return (1, 1) }
        let growth = CGFloat(Globe.markerEntrance.value(target: 1.0, time: elapsed))
        return (
            Globe.markerEntranceScale + (1 - Globe.markerEntranceScale) * growth,
            min(elapsed / Globe.markerEntranceFadeSeconds, 1)
        )
    }
}

extension ProfileV3InteractiveGlobe {
    @MainActor
    static func prepare(using globe: any ProfileV3GlobeRendering) async {
        await globe.prepare(ProfileV3Theme.Globe.expandedAppearance)
        guard let url = ProfileV3PlaceholderArt.globeFlare.url else { return }
        _ = await ProfileV3RemoteImage.image(at: url)
    }
}

private final class ProfileV3GlobeFrameClock {
    var date = Date()
}

struct ProfileV3GlobeSphere: Equatable {
    let centre: CGPoint
    let radius: CGFloat

    var bounds: CGRect {
        CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2)
    }
}

private struct ProfileV3GlobeSpin {
    var yaw: Double
    var pitch: Double
    var velocity: Double = 0
    var cruise: Double = 0
    var time = Date()

    static var resting: ProfileV3GlobeSpin {
        ProfileV3GlobeSpin(
            yaw: (90 - ProfileV3Theme.Globe.restLongitude) * .pi / 180,
            pitch: ProfileV3Theme.Globe.restPitch
        )
    }

    func yaw(at date: Date) -> Double {
        let elapsed = max(date.timeIntervalSince(time), 0)
        let decay = ProfileV3Theme.Globe.spinDecaySeconds
        return yaw + cruise * elapsed + (velocity - cruise) * decay * (1 - exp(-elapsed / decay))
    }

    func velocity(at date: Date) -> Double {
        let elapsed = max(date.timeIntervalSince(time), 0)
        return cruise + (velocity - cruise) * exp(-elapsed / ProfileV3Theme.Globe.spinDecaySeconds)
    }

    func frozen(at date: Date) -> ProfileV3GlobeSpin {
        ProfileV3GlobeSpin(yaw: yaw(at: date), pitch: pitch, time: date)
    }

    func dragged(by translation: CGSize, radius: CGFloat, at date: Date) -> ProfileV3GlobeSpin {
        let range = ProfileV3Theme.Globe.pitchRange
        let tilted = pitch + Double(translation.height / radius)
        return ProfileV3GlobeSpin(
            yaw: yaw + Double(translation.width / radius),
            pitch: min(max(tilted, range.lowerBound), range.upperBound),
            time: date
        )
    }

    func coasting(velocity: Double, cruise: Double, at date: Date) -> ProfileV3GlobeSpin {
        ProfileV3GlobeSpin(yaw: yaw(at: date), pitch: pitch, velocity: velocity, cruise: cruise, time: date)
    }
}

#if DEBUG
#Preview("Interactive globe") {
    ProfileV3InteractiveGlobe(visitedCountryCodes: ["IN", "AE", "GB", "FR", "IT", "EG", "SG", "MU"])
        .frame(width: 380, height: 330)
        .background(Color(at: .pureBlack))
}
#endif
