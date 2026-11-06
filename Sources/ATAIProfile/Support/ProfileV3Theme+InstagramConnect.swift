import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum InstagramConnect {
        static let sheetHeight: CGFloat = 684
        static let explainerWashTop: CGFloat = 310
        static let explainerWash = CGSize(width: 686, height: 622)
        static let followWashTop: CGFloat = 453
        static let followWashHeight: CGFloat = 399
        static let cardsTop = ProfileV3Theme.Space.s48
        static let cardSpacing = ProfileV3Theme.Space.s24
        static let cardHeight: CGFloat = 109
        static let cardRadius = ProfileV3Theme.Radius.card
        static let cardLeading: CGFloat = 31
        static let handleTrailing: CGFloat = 23
        static let orbTrailing: CGFloat = 21
        static let followTrailing = ProfileV3Theme.Space.s12
        static let handleArtWidth: CGFloat = 84
        static let orbArtWidth: CGFloat = 61
        static let followArtWidth: CGFloat = 68
        static let cardTextSpacing = ProfileV3Theme.Space.s6
        static let cardTitleMinScale: CGFloat = 0.8
        static let followDetailWidth: CGFloat = 260
        static let handleSpacing: CGFloat = 5
        static let handleTilt: Double = 14.86
        static let handlePadding: CGFloat = 9.5
        static let handleHeight: CGFloat = 29
        static let cardOrb: CGFloat = 52
        static let cardOrbTilt: Double = 11.05
        static let orbMarkRatio: CGFloat = 0.587
        static let followSpacing: CGFloat = 10.5
        static let followWidth: CGFloat = 68
        static let followHeight: CGFloat = 22.4
        static let followRadius: CGFloat = 6.7
        static let followFontSize: CGFloat = 9
        static let hiWidth: CGFloat = 48
        static let hiHeight: CGFloat = 26.7
        static let hiFontSize: CGFloat = 10.7
        static let hiTailLarge: CGFloat = 15.1
        static let hiTailSmall: CGFloat = 6.2
        static let hiTailLargeOffset = CGSize(width: 25.8, height: 17.3)
        static let hiTailSmallOffset = CGSize(width: 19.6, height: 30.2)
        static let noteToBar: CGFloat = 16
        static let redirectFieldTop: CGFloat = 46
        static let redirectOrb: CGFloat = 65
        static let redirectOrbTop: CGFloat = 78
        static let redirectLeadTop: CGFloat = 35
        static let redirectTitleTop = ProfileV3Theme.Space.s6
        static let redirectingBottom: CGFloat = 36
        static let introTitleTop: CGFloat = 38
        static let introTitleWidth: CGFloat = 260
        static let introSceneOffset: CGFloat = 146
        static let introScene = CGSize(width: ProfileV3Theme.Canvas.width, height: 452)
        static let introMap = CGRect(x: 68, y: 91, width: 306, height: 285)
        static let introMapRadius: CGFloat = 22
        static let introPlace = CGPoint(x: 8, y: 206.5)
        static let introPlacePeekX: CGFloat = 283
        static let introPlaceWidth: CGFloat = 267
        static let introPlaceRing: CGFloat = 5
        static let introPlaceLeading: CGFloat = 14
        static let introPlaceTrailing: CGFloat = 16
        static let introPlaceVertical: CGFloat = 9
        static let introPlaceSpacing = ProfileV3Theme.Space.s12
        static let introPlaceTextSpacing: CGFloat = 2
        static let introPlaceBorder: CGFloat = 0.5
        static let introPlaceThumbSlot = CGSize(width: 41, height: 38)
        static let introPlaceThumb: CGFloat = 36
        static let introPlaceThumbRadius: CGFloat = 10
        static let introPlaceThumbNudge: CGFloat = 0.5
        static let introPinGlyph: CGFloat = 16.8
        static let introPinBorder: CGFloat = 1.8
        static let introPins: [ProfileV3InstagramPin] = [
            ProfileV3InstagramPin(origin: CGPoint(x: 130, y: 91), size: 24, detail: 1, isHighlighted: true),
            ProfileV3InstagramPin(origin: CGPoint(x: 259, y: 52), size: 16, detail: 0.494, isHighlighted: false),
            ProfileV3InstagramPin(origin: CGPoint(x: 19, y: 79), size: 16, detail: 0.494, isHighlighted: false)
        ]
        static let introReels: [ProfileV3InstagramReel] = [
            ProfileV3InstagramReel(
                art: .aurora, center: CGPoint(x: 23.01, y: 167.08), size: CGSize(width: 135, height: 187),
                radius: 30, tilt: 8.107, target: CGPoint(x: 106, y: 181), order: 0
            ),
            ProfileV3InstagramReel(
                art: .london, center: CGPoint(x: 208.14, y: 218.79), size: CGSize(width: 142.24, height: 195.82),
                radius: 30, tilt: -2.389, target: CGPoint(x: 212, y: 195), order: 4
            ),
            ProfileV3InstagramReel(
                art: .tokyo, center: CGPoint(x: 80.14, y: 454.79), size: CGSize(width: 142.24, height: 195.82),
                radius: 30, tilt: 12.639, target: CGPoint(x: 148, y: 261), order: 3
            ),
            ProfileV3InstagramReel(
                art: .dining, center: CGPoint(x: 385.55, y: 313.94), size: CGSize(width: 142.24, height: 195.82),
                radius: 30, tilt: 12.446, target: CGPoint(x: 304, y: 241), order: 2
            ),
            ProfileV3InstagramReel(
                art: .amalfi, center: CGPoint(x: 445.13, y: 90.8), size: CGSize(width: 121.41, height: 167.14),
                radius: 26.9, tilt: -7.526, target: CGPoint(x: 332, y: 155), order: 1
            )
        ]
        static let pageRedirectBottom: CGFloat = 60
        static let pageRedirectLabelTop: CGFloat = 87
        static let pageRedirectFade: CGFloat = 143.5
        static let pageRedirectFadeSolid: CGFloat = 220.5
        static let pageRedirectWashVisible: CGFloat = 223
        private static let orbParticleTable: [(x: CGFloat, y: CGFloat, size: CGFloat, dx: CGFloat, dy: CGFloat)] = [
            (35.41, 32.43, 1.1, 18, 18.39), (28.64, 35.91, 2.1, -44.47, -2.43), (33.01, 25.81, 1.243, 26.27, -19.06),
            (37.22, 38.68, 2.243, -8.58, 51.18), (23.65, 30.88, 1.386, -20.25, -34.67), (40.75, 27.14, 2.386, 26.57, 10.69),
            (29.65, 42.78, 1.529, -43.55, 20.55), (27.12, 22.21, 2.529, 15.95, -33.07), (43.95, 36.64, 1.671, 4.54, 25.14),
            (20.46, 37.38, 2.671, -38.98, -22.32), (38.21, 20.1, 1.814, 33.35, -4.81), (36.7, 46.04, 2.814, -17.04, 15.3),
            (19.57, 24.98, 1.957, -3.76, -41.8), (47.52, 29.12, 1.1, 20.7, 23.04), (23.22, 45.53, 2.1, -19.7, -6.09),
            (30.3, 16.01, 1.243, 30.07, -25.21), (45.49, 43.44, 2.243, -7.21, 27.56), (14.86, 33.16, 1.386, -4.14, -18.24),
            (45.25, 19.67, 2.386, 35.36, 9.72), (31.57, 50.98, 1.529, -24.91, 8.23), (20.23, 17.81, 2.529, 13.61, -42.91),
            (51.76, 35.04, 1.671, 11.19, 32.39), (16.07, 43.83, 2.671, -18.71, -15.34), (36.91, 12.55, 1.814, 40.54, -12.9),
            (42.78, 50.5, 2.814, -19.19, 25.63), (12.21, 25.98, 1.957, 2.97, -22.21), (52.08, 23.35, 1.1, 31.98, 24.33),
            (23.92, 52.78, 2.1, -29.87, -1.59), (24.83, 11.31, 1.243, 19.16, -8.28), (52.65, 43.06, 2.243, -1.57, 37.9),
            (9.97, 38.35, 1.386, -14.12, -24.14), (45.2, 12.58, 2.386, 15.83, 11.65), (36.49, 56.06, 1.529, -30.26, 19.12),
            (13.19, 17.53, 2.529, 11.8, -23.4), (57.05, 30.4, 1.671, -2.2, 18.64), (15.42, 50.83, 2.671, -31, -13.37),
            (32.56, 7.03, 1.814, 24.51, -2.41), (49.74, 51.51, 2.814, -16.34, 38.47), (6.45, 30.03, 1.957, -5.95, -31.3),
            (53.49, 16.46, 1.1, 14.17, 18.47), (27.64, 58.76, 2.1, -38.83, 8.29), (18, 9.51, 1.243, 21.46, -21.09),
            (58.87, 39.68, 2.243, -8.01, 20.68), (7.76, 45.09, 1.386, -27.55, -25.77)
        ]
        static let orbParticles: [ProfileV3OrbParticle] = orbParticleTable.enumerated().map { index, particle in
            ProfileV3OrbParticle(
                index: index,
                rest: CGPoint(x: particle.x, y: particle.y),
                size: particle.size,
                start: CGSize(width: particle.dx, height: particle.dy)
            )
        }
    }
}

extension ProfileV3Theme.Palette {
    static let instagramFollow = Color(hex: "455EFF")
    static let instagramHi = Color(hex: "6A3DF1")
    static let aylOrbMark = Color(at: .pureWhite)
    static let aylOrbLime = Color(hex: "D8FB71")
    static let aylOrbParticle = Color(hex: "BFE84D")
    static let aylOrbParticleLight = Color(hex: "E8FFB3")
    static let instagramPlaceBorder = Color(at: .borderLightLight100)
    static let instagramPlaceDetail = Color(at: .neutralGrey400)
    static let instagramPinShadow = Color(hex: "D3D4DF").opacity(0.76)
}

extension ProfileV3Theme.Opacity {
    static let instagramLead: Double = 0.5
    static let instagramRedirecting: Double = 0.8
    static let instagramExplainerWash: Double = 0.56
    static let instagramPlaceRing: Double = 0.1
    static let instagramPlaceShadow: Double = 0.08
}

extension ProfileV3Theme.Shadow {
    static let instagramPlaceRadius: CGFloat = 7.2
    static let instagramPlaceY: CGFloat = 7.2
    static let instagramPinRadius: CGFloat = 2.7
    static let instagramPinY: CGFloat = 3.6
}

extension ProfileV3Theme.Motion {
    static let fastOutSlowIn = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0.4, y: 0),
        endControlPoint: UnitPoint(x: 0.2, y: 1)
    )

    enum InstagramIntro {
        static let seconds: TimeInterval = 3.4
        static let holdSeconds: TimeInterval = 1
        static let reelStart: TimeInterval = 0.38
        static let reelStagger: TimeInterval = 0.09
        static let reelShrink: TimeInterval = 0.35
        static let reelFade: TimeInterval = 0.8
        static let reelTravel: TimeInterval = 1.05
        static let reelShrinkScale: Double = 0.86
        static let reelEndScale: Double = 0.045
        static let mapOpacity = ProfileV3Keyframes(0.06)
            .hold(until: 0.38)
            .to(0.4, at: 1.1, fastOutSlowIn)
            .to(1, at: 1.9, .easeOut)
        static let placeOpacity = ProfileV3Keyframes(0)
            .hold(until: 1.98)
            .to(1, at: 2.18, .easeOut)
        static let placeScale = ProfileV3Keyframes(0.94)
            .hold(until: 1.98)
            .to(1.015, at: 2.26, .easeOut)
            .to(1, at: 2.42, fastOutSlowIn)
        static let placeRise = ProfileV3Keyframes(10)
            .hold(until: 1.98)
            .to(0, at: 2.38, .easeOut)
    }

    enum AylOrbAssembly {
        static let seconds: TimeInterval = 2
        static let particleDelay: TimeInterval = 0.15
        static let particleStagger: TimeInterval = 0.03
        static let particleStaggerCycle = 9
        static let particleLightCycle = 4
        static let particleGlow: TimeInterval = 0.35
        static let particlePeak: TimeInterval = 1.05
        static let particleGlowOpacity: Double = 0.8
        static let particlePeakOpacity: Double = 0.85
        static let scale = ProfileV3Keyframes(0.9).to(1, at: seconds, .easeInOut)
        static let blur = ProfileV3Keyframes(48).hold(until: 0.3).to(0, at: seconds, .easeInOut)
        static let limeOpacity = ProfileV3Keyframes(0.3).hold(until: 0.3).to(1, at: seconds, .easeInOut)
        static let orbOpacity = ProfileV3Keyframes(0.08).hold(until: 0.3).to(1, at: seconds, .easeInOut)
        static let particleScale = ProfileV3Keyframes(1.7).to(1, at: seconds, .easeInOut)
    }
}

extension ProfileV3Theme {
    static let instagramCardGradient = LinearGradient(
        colors: [Color(at: .pureWhite), Color(at: .pureWhite).opacity(0.7)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let instagramHandleGradient = LinearGradient(
        stops: [
            .init(color: Color(hex: "334158"), location: 0.368),
            .init(color: Color(hex: "0C0F14"), location: 0.949)
        ],
        startPoint: .topTrailing,
        endPoint: .bottomLeading
    )

    static let aylOrbGradient = LinearGradient(
        stops: [
            .init(color: Color(hex: "D8FB71"), location: 0.137),
            .init(color: Color(hex: "ACC85A"), location: 0.381),
            .init(color: Color(hex: "42620F"), location: 0.728)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private static let instagramWashStops: [Gradient.Stop] = [
        .init(color: Color(hex: "D8FB71").opacity(0), location: 0.05),
        .init(color: Color(hex: "ACC85A"), location: 0.67),
        .init(color: Color(hex: "587F1B"), location: 0.97)
    ]

    static let instagramFollowWash = LinearGradient(
        stops: instagramWashStops,
        startPoint: .top,
        endPoint: .bottom
    )

    static let instagramExplainerWash = LinearGradient(
        stops: instagramWashStops,
        startPoint: UnitPoint(x: 0.013, y: -0.054),
        endPoint: UnitPoint(x: -0.146, y: 0.595)
    )

    static let instagramRedirectingGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureBlack), location: 0),
            .init(color: Color(hex: "898989"), location: 0.66),
            .init(color: Color(hex: "282828"), location: 0.99)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let instagramPinGradient = pinGradient(from: Color(at: .primaryBrandBlue500), to: Color(hex: "1D24B7"))
    static let instagramPinMutedGradient = pinGradient(from: Color(hex: "D7D7D7"), to: Color(hex: "7D7D7D"))

    private static func pinGradient(from start: Color, to end: Color) -> LinearGradient {
        LinearGradient(
            stops: [.init(color: start, location: 0.15), .init(color: end, location: 1)],
            startPoint: UnitPoint(x: 0.18, y: -0.1),
            endPoint: UnitPoint(x: 0.92, y: 1.29)
        )
    }
}
