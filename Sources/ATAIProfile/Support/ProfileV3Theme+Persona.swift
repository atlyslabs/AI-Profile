import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum Persona {
        static let cardRadius: CGFloat = 40
        static let radarTop: CGFloat = 39
        static let radarHeight: CGFloat = 314
        static let cardBottom: CGFloat = 69
        static let cardTop: CGFloat = 34
        static let subtitleWidth: CGFloat = 244
        static let loadingTitleHeight: CGFloat = 50
        static let loadingSubtitleHeight: CGFloat = 32
        static let hintTop: CGFloat = 28
        static let hintWidth: CGFloat = 240
        static let hintBottom: CGFloat = 9
        static let radarRadius: CGFloat = 105.6
        static let radarInnerRadius: CGFloat = 10
        static let ringCount = 5
        static let ringsOverPolygon = 2
        static let ringLineWidth: CGFloat = 0.57
        static let spokeLineWidth: CGFloat = 0.5
        static let labelGap: CGFloat = 12
        static let labelWidth: CGFloat = 72
        static let labelSpacing = ProfileV3Theme.Space.s4
        static let handle: CGFloat = 15
        static let handleHighlighted: CGFloat = 21
        static let handleHitTarget: CGFloat = 44
        static let handleEntranceScale: CGFloat = 0.5
        static let dragMinimumDistance: CGFloat = 3
        static let rippleStart = handleHighlighted
        static let rippleInner: CGFloat = 35
        static let rippleOuter: CGFloat = 53
        static let rippleEnd: CGFloat = 57
        static let rippleRings = 2

        enum Coach {
            static let width: CGFloat = 131
            static let pointer: CGFloat = 4.913
            static let notch: CGFloat = 9.0554
            static let radius: CGFloat = 12
            static let textWidth: CGFloat = 107
            static let textTop: CGFloat = 12
            static let dotsTop: CGFloat = 10
            static let bottom: CGFloat = 9
            static let dot = CGSize(width: 8, height: 2)
            static let dotSpacing: CGFloat = 2
            static let tipGap: CGFloat = 23.3
            static let edgeInset: CGFloat = 12
            static let enterScale: CGFloat = 0.8
            static let targetMinimumRise = 0.3
        }

        static let detailTop: CGFloat = 28
        static let detailCardHeight: CGFloat = 328
        static let detailNameTop: CGFloat = 42
        static let detailScoreTop: CGFloat = 11
        static let detailSubtitleTop: CGFloat = 21
        static let detailSubtitleWidth: CGFloat = 202
        static let scaleWidth: CGFloat = 300
        static let scaleTrackHeight: CGFloat = 6
        static let scaleLabelsTop: CGFloat = 22
        static let scaleBottom: CGFloat = 43
        static let scaleKnob: CGFloat = 20
        static let scaleMidpoint: CGFloat = 17
        static let calculationTop = ProfileV3Theme.Space.s40
        static let calculationTitleWidth: CGFloat = 172
        static let calculationOrb: CGFloat = 24
        static let rowsTop: CGFloat = 39
        static let rowIcon: CGFloat = 48
        static let rowGlyph: CGFloat = 24
        static let rowGmailGlyph = CGSize(width: 22, height: 16.5)
        static let rowSpacing = ProfileV3Theme.Space.s20
        static let rowGap = ProfileV3Theme.Space.s24
        static let rowMinHeight: CGFloat = 77
        static let rowSubtitleTop: CGFloat = 6
        static let rowSubtitleWidth: CGFloat = 200
        static let connectorTop: CGFloat = 11
        static let connectorBottom: CGFloat = 13
        static let connectorDash: [CGFloat] = [1.93, 1.93]
        static let pillHorizontal = ProfileV3Theme.Space.s10
        static let pillVertical: CGFloat = 5
        static let bottom = ProfileV3Theme.Space.s50
        static let toastBottom = ProfileV3Theme.Space.s24
        static let toastClearance = ProfileV3Theme.Control.large + toastBottom
    }
}

extension ProfileV3Theme.Palette {
    static let personaInk = Color(hex: "101010")
    static let personaLabel = Color(hex: "111827")
    static let personaGrid = Color(at: .neutralGrey600)
    static let personaScaleTrack = Color(hex: "D9D9D9")
    static let personaPillBorder = Color(at: .neutralGrey200)
    static let personaHandleRimTop = Color(hex: "BBBBBC")
    static let personaHandleRimBottom = Color(hex: "DFE1EA")
    static let personaHandleShadow = Color.black.opacity(0.15)
    static let personaCardEdge = Color(hex: "E9E9E9")
    static let personaYellow = Color(hex: "FFE23D")
    static let personaRed = Color(hex: "FF5959")
    static let personaBlue = Color(hex: "5D64FF")
    static let personaRadarMist = Color(hex: "E5E6F7")
    static let personaScaleEnd = Color(hex: "101010")
}

extension ProfileV3Theme.Opacity {
    static let personaRadarLayer: Double = 0.5
    static let personaRadarFill: Double = 0.7
    static let personaRing: Double = 0.3
    static let personaSpoke: Double = 0.2
    static let personaScore: Double = 0.6
    static let personaScaleTrack: Double = 0.2
    static let personaConnector: Double = 0.2
    static let personaIgnored: Double = 0.4
    static let personaRippleInner: Double = 0.1
    static let personaRippleOuter: Double = 0.05
    static let personaCoachDot: Double = 0.2
}

extension ProfileV3Theme.Shadow {
    static let personaHandleRadius: CGFloat = 3.5
    static let personaHandleY: CGFloat = 4
}

extension ProfileV3Theme.Motion {
    static let personaEntrance = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.5).delay(0.59)
    static let personaLabelEntrance = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.55)
    static let personaLabelDelay: Double = 0.95
    static let personaLabelStagger: Double = 0.07
    static let personaKnob: Animation = .spring(response: 0.32, dampingFraction: 0.72)
    static let personaRippleSeconds: Double = 2
    static let personaCoachDelayMilliseconds = 2300
    static let personaAdjustSaveMilliseconds = 800
}

extension ProfileV3Theme {
    static let personaCardGradient = ProfileV3BoxGradient(
        stops: [
            .init(color: Palette.personaCardEdge, location: 0),
            .init(color: Color(at: .pureWhite), location: 0.5),
            .init(color: Color(at: .pureWhite), location: 0.875),
            .init(color: Palette.personaCardEdge, location: 1)
        ],
        atOrigin: -0.0058,
        perWidth: 0.3769,
        perHeight: 0.629
    )

    static let personaRadarFill = ProfileV3BoxGradient(
        stops: [
            .init(color: Color(at: .pureWhite), location: 0),
            .init(color: Color(at: .pureWhite), location: 0.1635),
            .init(color: Palette.personaRadarMist, location: 0.456),
            .init(color: Palette.personaBlue, location: 0.6048),
            .init(color: Palette.personaRed, location: 0.7449),
            .init(color: Palette.personaYellow, location: 0.9258)
        ],
        atOrigin: 1.0012,
        perWidth: 0.3558,
        perHeight: -0.6159
    )

    static let personaHandleRim = LinearGradient(
        colors: [Palette.personaHandleRimTop, Palette.personaHandleRimBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    static let personaCoachGradient = LinearGradient(
        colors: [Palette.appHintStart, Palette.appHintEnd],
        startPoint: UnitPoint(x: 0.519, y: 0.085),
        endPoint: UnitPoint(x: 0.943, y: 1.3)
    )

    static let personaCaptionGradient = LinearGradient(
        stops: [
            .init(color: Palette.personaCaptionEdge, location: 0.054),
            .init(color: Palette.personaCaptionMid, location: 0.462),
            .init(color: Palette.personaCaptionEdge, location: 0.946)
        ],
        startPoint: UnitPoint(x: 0.19, y: -1.579),
        endPoint: UnitPoint(x: 0.81, y: 2.579)
    )

    static let personaScaleFill = LinearGradient(
        stops: [
            .init(color: Palette.personaYellow.opacity(0.5), location: 0.022),
            .init(color: Palette.personaRed.opacity(0.7), location: 0.157),
            .init(color: Palette.personaBlue, location: 0.404),
            .init(color: Palette.personaScaleEnd, location: 0.907)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}
