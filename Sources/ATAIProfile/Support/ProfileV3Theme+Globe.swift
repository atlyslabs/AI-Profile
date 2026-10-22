import SwiftUI

extension ProfileV3Theme {
    enum Globe {
        static let landDensity = ProfileV3Globe.Density(
            samples: 4000,
            keep: 0.5,
            minLatitude: -60,
            land: .coastlines(spacing: 2)
        )
        static let cardLongitude = 15.0
        static let cardPitch = 0.32
        static let cardSpinSpeed = 0.35
        static let cardSphereRatio: CGFloat = 0.46
        static let cardAppearance = ProfileV3Globe.Appearance(
            coast: Palette.globeCoast,
            stray: Palette.globeCoast,
            interior: Palette.globeInterior,
            coastOpacity: 0.6,
            strayOpacity: 0.55,
            interiorOpacity: 0.22,
            landTint: Palette.globeLandTint,
            density: landDensity,
            dotScale: 0.005,
            depthFade: 0.25,
            edgeGlow: 1.5
        )
        static let expandedAppearance = ProfileV3Globe.Appearance(
            coast: Palette.globeCoast,
            stray: Palette.globeCoast,
            interior: Palette.globeInterior,
            coastOpacity: 0.85,
            strayOpacity: 0.6,
            interiorOpacity: 0.5,
            landTint: nil,
            density: landDensity,
            dotScale: 0.005,
            depthFade: 0.25,
            edgeGlow: 3
        )

        static let rimWidth: CGFloat = 5
        static let rimGlowWidth: CGFloat = 10
        static let rimGlowBlur: CGFloat = 5
        static let rimGlowOpacity = 0.5
        static let rimMaskOutset: CGFloat = 30
        static let rimGradient = AngularGradient(
            stops: [
                .init(color: Palette.globeRim, location: 0),
                .init(color: Palette.globeRim.opacity(0.3), location: 0.04),
                .init(color: Palette.globeRim.opacity(0), location: 0.07),
                .init(color: Palette.globeRim.opacity(0), location: 0.3),
                .init(color: Palette.globeRim.opacity(0.3), location: 0.34),
                .init(color: Palette.globeRim.opacity(0.28), location: 0.42),
                .init(color: Palette.globeRim.opacity(0.68), location: 0.5),
                .init(color: Palette.globeRim.opacity(0.55), location: 0.6),
                .init(color: Palette.globeRim.opacity(0.15), location: 0.75),
                .init(color: Palette.globeRim.opacity(0.35), location: 0.84),
                .init(color: Palette.globeRim.opacity(0.3), location: 0.92),
                .init(color: Palette.globeRim, location: 1)
            ],
            center: .center
        )

        static let restLongitude = 17.0
        static let restPitch = 0.44
        static let pitchRange = -0.6 ... 0.9
        static let sphereWidthRatio: CGFloat = 262 / 380
        static let sphereVerticalInset: CGFloat = 8
        static let shade = Gradient(stops: [
            .init(color: Palette.globeShade.opacity(0), location: 0.45),
            .init(color: Palette.globeShade.opacity(0.55), location: 1)
        ])
        static let vignette = Gradient(stops: [
            .init(color: Palette.globeShade.opacity(0.55), location: 0),
            .init(color: Palette.globeShade.opacity(0.35), location: 0.55),
            .init(color: Palette.globeShade.opacity(0), location: 0.85)
        ])

        static let cruiseSpeed = 0.18
        static let spinDecaySeconds = 0.9
        static let maxFlingSpeed = 9.0
        static let flingThreshold = 0.25
        static let dragMinimumDistance: CGFloat = 2

        static let markerDiameters: [CGFloat] = [42.84, 34.1, 33.52, 26.07, 26.07, 19.79]
        static let markerFlareRatio: CGFloat = 0.864
        static let markerFlareRotation = Angle.degrees(-124.72)
        static let markerFlareOpacity = 0.8
        static let markerRing = Gradient(colors: [Palette.globeMarkerRing, Palette.globeMarkerRingFade])
        static let markerHiddenDepth: CGFloat = 0
        static let markerShownDepth: CGFloat = 0.3
        static let markerDepthShrink: CGFloat = 0.15
        static let markerEntranceDelay = 0.25
        static let markerEntranceStagger = 0.09
        static let markerEntranceFadeSeconds = 0.25
        static let markerEntranceScale = 0.3
        static let markerEntrance = Spring(duration: 0.55, bounce: 0.35)
    }
}
