import SwiftUI

final class ProfileV3GlobePose {
    var yaw: Double?
    var pitch: Double?
    var velocity: Double = 0
    var date = Date()
    var isRunning = false
}

struct ProfileV3CardGlobe: View {
    var isAnimating = true
    var facingLongitude: Double = 90
    let appearance: ProfileV3Globe.Appearance
    var pose: ProfileV3GlobePose?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.profileV3Globe) private var globe
    @State private var isLandReady = false
    @State private var restingAngle: Double?
    @State private var runningSince: Date?

    private typealias Globe = ProfileV3Theme.Globe

    private var animates: Bool { isAnimating && !reduceMotion }

    var body: some View {
        let landReady = isLandReady
        SwiftUI.TimelineView(.animation(paused: !animates)) { timeline in
            let yaw = rotation(at: timeline.date)
            Canvas { context, size in
                if let pose {
                    pose.yaw = yaw
                    pose.pitch = Globe.cardPitch
                    pose.velocity = animates ? Globe.cardSpinSpeed : 0
                    pose.date = timeline.date
                    pose.isRunning = animates
                }
                _ = landReady
                let projection = ProfileV3Globe.Projection(
                    centre: CGPoint(x: size.width / 2, y: size.height / 2),
                    radius: min(size.width, size.height) * Globe.cardSphereRatio,
                    yaw: yaw,
                    pitch: Globe.cardPitch
                )
                globe.drawLand(appearance, in: context, projection: projection)
            }
        }
        .onAppear {
            if animates, runningSince == nil { runningSince = .now }
        }
        .task {
            await globe.prepare(appearance)
            isLandReady = true
        }
        .onChange(of: animates) { _, animating in
            if animating {
                if let handedOff = pose?.yaw { restingAngle = handedOff }
                runningSince = .now
            } else {
                restingAngle = rotation(at: .now)
                runningSince = nil
            }
        }
    }

    private func rotation(at date: Date) -> Double {
        let resting = restingAngle ?? (90 - facingLongitude) * .pi / 180
        guard let runningSince else { return resting }
        return resting + date.timeIntervalSince(runningSince) * Globe.cardSpinSpeed
    }
}

extension ProfileV3Globe.Appearance {
    func blended(toward other: ProfileV3Globe.Appearance, _ amount: Double) -> ProfileV3Globe.Appearance {
        var blended = self
        blended.coastOpacity += (other.coastOpacity - coastOpacity) * amount
        blended.strayOpacity += (other.strayOpacity - strayOpacity) * amount
        blended.interiorOpacity += (other.interiorOpacity - interiorOpacity) * amount
        blended.depthFade += (other.depthFade - depthFade) * amount
        blended.edgeGlow += (other.edgeGlow - edgeGlow) * amount
        blended.dotScale += (other.dotScale - dotScale) * CGFloat(amount)
        blended.landTint = other.landTint ?? landTint?.opacity(1 - amount)
        return blended
    }
}
