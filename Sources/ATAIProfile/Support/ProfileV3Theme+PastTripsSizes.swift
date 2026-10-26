import SwiftUI

extension ProfileV3Theme.Sizes {
    enum PastTrips {
        static let listGap: CGFloat = 52
        static let listTop = ProfileV3Theme.Sizes.topBarTop + ProfileV3Theme.Sizes.navButton + listGap
        static let cardWidth: CGFloat = 250
        static let cardHeight: CGFloat = 342
        static let cardRadius: CGFloat = 37.4
        static let cardSpacing = ProfileV3Theme.Space.s24
        static let photoInset = ProfileV3Theme.Space.s10
        static let photoRadius: CGFloat = 28
        static let scrimHeight: CGFloat = 233
        static let flag: CGFloat = 28
        static let flagTop: CGFloat = 149.5
        static let nameTop = ProfileV3Theme.Space.s24
        static let monthTop = ProfileV3Theme.Space.s8
        static let yearTop: CGFloat = 260.5
        static let yearSize: CGFloat = 80
        static let yearTracking: CGFloat = -3.2
        static let moreOffsetX: CGFloat = 44
        static let moreOffsetY: CGFloat = 20
        static let headerFade: CGFloat = 150
        static let fab: CGFloat = 60
        static let fabIconRotation = Angle.degrees(45)
        static let fabBottom: CGFloat = 26
        static let bottomFade: CGFloat = 248
        static let listBottom: CGFloat = 140
        static let entranceOffset: CGFloat = 80
        static let entranceCount = 3
        static let revealPhotoBlur: CGFloat = 7
        static let revealYearBlur: CGFloat = 5.5
        static let glow: CGFloat = 381
        static let glowOffsetY: CGFloat = 38.5
        static let glowBlur: CGFloat = 50
        static let sheenTravel: CGFloat = 120
        static let sheenOuterWidth: CGFloat = 20
        static let sheenOuterBlur: CGFloat = 40
        static let sheenInnerWidth: CGFloat = 40
        static let sheenInnerBlur: CGFloat = 30
        static let backdropBlur: CGFloat = 4
        static let deleteLift: CGFloat = -30
        static let deleteScale: CGFloat = 0.95
        static let emptyTop: CGFloat = 160
        static let emptyTextWidth: CGFloat = 260
    }

    enum TripSheet {
        static let inset = ProfileV3Theme.Space.s30
        static let bottom: CGFloat = 28
        static let radius: CGFloat = 36
        static let confirmRadius: CGFloat = 44
        static let grabberWidth = ProfileV3Theme.Space.s24
        static let grabberHeight: CGFloat = 2
        static let grabberTop: CGFloat = 9
        static let titleTop: CGFloat = 40
        static let titleLine: CGFloat = 14
        static let closeButton = ProfileV3Theme.Control.regular
        static let closeTop = titleTop + titleLine / 2 - closeButton / 2
        static let closeTrailing = ProfileV3Theme.Space.s16
        static let indicatorTop: CGFloat = 13
        static let countryListTop: CGFloat = 80
        static let fadeHeight: CGFloat = 139
        static let ctaHeight: CGFloat = 40
        static let ctaInset: CGFloat = 21.5
        static let ctaBottom = ProfileV3Theme.Space.s20
        static let countryHeight: CGFloat = 612
        static let durationHeight: CGFloat = 473
        static let yearLabelTop: CGFloat = 131
        static let yearWheelTop: CGFloat = 162
        static let notchTop: CGFloat = 241
        static let monthLabelTop: CGFloat = 282
        static let monthWheelTop: CGFloat = 311
        static let wheelHeight: CGFloat = 28
        static let yearPitch: CGFloat = 104
        static let monthPitch: CGFloat = 94
        static let selectedWheelSize: CGFloat = 28
        static let notchWidth: CGFloat = 9.6
        static let notchDepth: CGFloat = 4
        static let notchInset: CGFloat = 22
        static let errorBottom = ProfileV3Theme.Space.s12
        static let actionsHeight: CGFloat = 182
        static let actionRowHeight = ProfileV3Theme.Control.tapTarget
        static let actionsTop: CGFloat = 51.5
        static let actionsDividerGap: CGFloat = 7.5
        static let actionsSecondGap: CGFloat = 13.5
        static let actionIcon = ProfileV3Theme.Icon.md
        static let actionGap = ProfileV3Theme.Space.s10
        static let dividerDash: [CGFloat] = [2, 2]
    }

    enum PastTripsPill {
        static let leading: CGFloat = 18
        static let trailing: CGFloat = 13.4
        static let gap: CGFloat = 14.9
        static let icon: CGFloat = 22
        static let ringStroke: CGFloat = 1.5
        static let ringGrowX: CGFloat = 0.25
        static let ringGrowY: CGFloat = 0.5
        static let ringCount = 3
    }
}

extension ProfileV3Theme.Counts {
    static let pastTripYears = 80
    static let monthsInYear = 12
}

extension ProfileV3Theme.Typography {
    static let tripWheelSize: CGFloat = 16
    static let tripNameMinScale: CGFloat = 0.7
}

extension ProfileV3Theme.Palette {
    static let pastTripsBackground = Color(hex: "100F0F")
    static let tripScrim = Color(hex: "051528")
    static let tripSheetGrabber = Color(hex: "A9A9A9")
    static let tripNotch = Color(hex: "BFBFBF")
    static let tripActionIcon = Color(hex: "C2C2C2")
    static let tripPhotoPlaceholder = Color(hex: "1E1E1E")
}

extension ProfileV3Theme.Opacity {
    static let tripMore: Double = 0.4
    static let tripMonth: Double = 0.6
    static let tripPhotoStroke: Double = 0.4
    static let tripScrim: Double = 0.64
    static let tripYear: Double = 0.2
    static let tripBackdrop: Double = 0.4
    static let tripLabel: Double = 0.5
    static let tripNotch: Double = 0.5
    static let tripDivider: Double = 0.1
    static let tripWheelNear: Double = 0.3
    static let tripWheelFar: Double = 0.1
    static let tripSheen: Double = 0.45
    static let tripRing: Double = 0.6
    static let tripRingStroke: Double = 0.4
    static let tripGlowSettled: Double = 0.3
}

extension ProfileV3Theme.Motion {
    static let pastTripsPageSeconds: Double = 0.3
    static var pastTripsPageTransition: AnyTransition {
        .opacity.animation(.easeInOut(duration: pastTripsPageSeconds))
    }
    static let pastTripsEntrance: Animation = .timingCurve(0.16, 1, 0.3, 1, duration: 0.6)
    static let pastTripsStaggerSeconds: Double = 0.25
    static let pastTripsEntranceWindowSeconds: Double = 2
    static let pastTripsSheenDelaySeconds: Double = 0.7
    static let pastTripsSheenSeconds: Double = 0.9
    static let pastTripsRevealSeconds: Double = 0.9
    static let pastTripsGlowInSeconds: Double = 0.3
    static let pastTripsGlowOutSeconds: Double = 0.6
    static let pastTripsReveal: Animation = .easeOut(duration: pastTripsRevealSeconds)
    static let pastTripsGlowIn: Animation = .easeOut(duration: pastTripsGlowInSeconds)
    static let pastTripsGlowOut: Animation = .easeOut(duration: pastTripsGlowOutSeconds)
    static let pastTripsDelete: Animation = .easeInOut(duration: 0.5)
    static let pastTripsReflow: Animation = .easeInOut(duration: 0.6).delay(0.2)
    static let tripSheet: Animation = .spring(response: 0.35, dampingFraction: 0.9)
    static let tripStep: Animation = .spring(response: 0.5, dampingFraction: 0.86)
    static let pastTripsAutoAddMilliseconds = 350
    static let pulseCycleSeconds: Double = 3
    static let pulseRingSeconds: Double = 2
    static let pulseStaggerSeconds: Double = 0.5
    static let pulseCurve = UnitCurve.bezier(
        startControlPoint: UnitPoint(x: 0.25, y: 0),
        endControlPoint: UnitPoint(x: 0.35, y: 1)
    )
}

extension ProfileV3Theme {
    static let tripBezelGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureWhite).opacity(0.3), location: 0),
            .init(color: Color(at: .neutralGrey200).opacity(0.13), location: 0.5),
            .init(color: Color(at: .neutralGrey400).opacity(0.2), location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let tripScrimGradient = LinearGradient(
        stops: [
            .init(color: Palette.tripScrim.opacity(0), location: 0),
            .init(color: Palette.tripScrim.opacity(Opacity.tripScrim), location: 0.662),
            .init(color: Palette.tripScrim.opacity(Opacity.tripScrim), location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let tripYearGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureWhite).opacity(Opacity.tripYear), location: 0.19),
            .init(color: Color(at: .pureWhite).opacity(0), location: 0.738)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let pastTripsBottomFade = LinearGradient(
        colors: [Color(at: .pureBlack).opacity(0), Color(at: .pureBlack)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let tripSheenOuter = LinearGradient(
        colors: ["1AE5CC", "0BF4BD", "00FFB2", "8C84E7", "CC4DFF", "9F3EFF"].map { Color(hex: $0) },
        startPoint: .leading,
        endPoint: .trailing
    )

    static let tripSheenInner = LinearGradient(
        colors: ["8033FF", "994DFF", "7974FF", "33CCFF", "28D7EA"].map { Color(hex: $0) },
        startPoint: .leading,
        endPoint: .trailing
    )
}
