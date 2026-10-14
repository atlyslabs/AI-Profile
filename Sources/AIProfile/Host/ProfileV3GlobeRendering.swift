import SwiftUI

@MainActor
public protocol ProfileV3GlobeRendering: Sendable {
    func prepare(_ appearance: ProfileV3Globe.Appearance) async

    func drawLand(
        _ appearance: ProfileV3Globe.Appearance,
        in context: GraphicsContext,
        projection: ProfileV3Globe.Projection
    )
}

public enum ProfileV3Globe {
    public struct Appearance: Equatable, Sendable {
        public var coast: Color
        public var stray: Color
        public var interior: Color
        public var coastOpacity: Double
        public var strayOpacity: Double
        public var interiorOpacity: Double
        public var landTint: Color?
        public var density: Density
        public var dotScale: CGFloat
        public var depthFade: Double
        public var edgeGlow: Double
    }

    public struct Density: Hashable, Sendable {
        public enum Land: Hashable, Sendable {
            case landMask
            case coastlines(spacing: Double)
        }

        public var samples: Int
        public var keep: Float
        public var minLatitude: Double
        public var land: Land
    }

    public struct Projection: Sendable {
        public let centre: CGPoint
        public let radius: CGFloat
        public let yaw: Double
        public let pitch: Double
        private let cosYaw: Double
        private let sinYaw: Double
        private let cosPitch: Double
        private let sinPitch: Double

        public init(centre: CGPoint, radius: CGFloat, yaw: Double, pitch: Double) {
            self.centre = centre
            self.radius = radius
            self.yaw = yaw
            self.pitch = pitch
            cosYaw = cos(yaw)
            sinYaw = sin(yaw)
            cosPitch = cos(pitch)
            sinPitch = sin(pitch)
        }

        public func project(x px: Double, y py: Double, z pz: Double) -> (point: CGPoint, depth: Double) {
            let x = px * cosYaw - pz * sinYaw
            let z = px * sinYaw + pz * cosYaw
            let y2 = py * cosPitch - z * sinPitch
            let z2 = py * sinPitch + z * cosPitch
            return (CGPoint(x: centre.x - CGFloat(x) * radius, y: centre.y - CGFloat(y2) * radius), z2)
        }

        public func project(latitude: Double, longitude: Double) -> (point: CGPoint, depth: Double) {
            let lat = latitude * .pi / 180
            let lon = longitude * .pi / 180
            return project(x: cos(lat) * cos(lon), y: sin(lat), z: cos(lat) * sin(lon))
        }
    }
}

extension EnvironmentValues {
    var profileV3Globe: any ProfileV3GlobeRendering {
        get { self[ProfileV3GlobeRendererKey.self] }
        set { self[ProfileV3GlobeRendererKey.self] = newValue }
    }
}

private struct ProfileV3GlobeRendererKey: EnvironmentKey {
    static let defaultValue: any ProfileV3GlobeRendering = ProfileV3PlaceholderGlobeRenderer()
}
