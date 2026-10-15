import ATAIProfile
import SwiftUI

struct VDCProfileV3GlobeRenderer: ProfileV3GlobeRendering {
    func prepare(_ appearance: ProfileV3Globe.Appearance) async {
        _ = await GlobePoints.load(GlobePoints.Density(appearance.density))
    }

    func drawLand(
        _ appearance: ProfileV3Globe.Appearance,
        in context: GraphicsContext,
        projection: ProfileV3Globe.Projection
    ) {
        let look = KYCParticleGlobe.Appearance(appearance)
        guard let land = GlobePoints.cache[look.density] else { return }
        KYCParticleGlobe.drawLand(
            land,
            in: context,
            projection: GlobeProjection(
                centre: projection.centre,
                radius: projection.radius,
                yaw: projection.yaw,
                pitch: projection.pitch
            ),
            appearance: look
        )
    }
}

private extension GlobePoints.Density {
    init(_ density: ProfileV3Globe.Density) {
        let land: Land
        switch density.land {
        case .landMask: land = .bitmap
        case .coastlines(let spacing): land = .coastlines(spacing: spacing)
        }
        self.init(samples: density.samples, keep: density.keep, minLatitude: density.minLatitude, land: land)
    }
}

private extension KYCParticleGlobe.Appearance {
    init(_ appearance: ProfileV3Globe.Appearance) {
        self.init(
            coast: appearance.coast,
            stray: appearance.stray,
            interior: appearance.interior,
            coastOpacity: appearance.coastOpacity,
            strayOpacity: appearance.strayOpacity,
            interiorOpacity: appearance.interiorOpacity,
            rimGlow: nil,
            landTint: appearance.landTint,
            density: GlobePoints.Density(appearance.density),
            dotScale: appearance.dotScale,
            depthFade: appearance.depthFade,
            edgeGlow: appearance.edgeGlow
        )
    }
}
