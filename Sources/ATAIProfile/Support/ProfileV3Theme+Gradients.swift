import ATUIKit
import SwiftUI

extension ProfileV3Theme {
    static let tagGradient = LinearGradient(
        colors: [Color(at: .neutralGrey800), Color(at: .neutralGrey400)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let passportPageEdgeShade = LinearGradient(
        colors: [Palette.passportPageEdgeShade, Palette.passportPageEdgeShadeEnd],
        startPoint: .top,
        endPoint: .bottom
    )

    static let passportBackShade = LinearGradient(
        stops: [
            .init(color: Palette.passportPageEdgeShade, location: 0),
            .init(color: Palette.passportPageEdgeShadeEnd, location: Sizes.Passport.backShadeEnd)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let activateGradient = LinearGradient(
        colors: [Palette.activateTop, Palette.activateBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    static let activateRingGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureBlack), location: 0),
            .init(color: Palette.statusBlue, location: 0.19),
            .init(color: Palette.statusRed, location: 0.66),
            .init(color: Palette.statusYellow, location: 0.99)
        ],
        startPoint: UnitPoint(x: -0.01, y: -0.15),
        endPoint: UnitPoint(x: 0.99, y: 1.12)
    )

    static let worldPassTitleGradient = LinearGradient(
        colors: [Color(at: .pureWhite), Palette.worldPassTitleEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let toastTextGradient = LinearGradient(
        colors: [Palette.toastStart, Palette.toastEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let worldPassNumberGradient = LinearGradient(
        colors: [Palette.worldPassNumberStart, Palette.worldPassNumberEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let worldPassNumberOnDarkGradient = LinearGradient(
        colors: [Palette.worldPassNumberOnDarkStart, Palette.worldPassNumberOnDarkEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let redeemGradient = LinearGradient(
        colors: [Palette.glowLavender, Palette.glowPink, Palette.glowYellow],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let redeemFrost = LinearGradient(
        colors: [Color(at: .pureWhite).opacity(0.3), Color(at: .pureWhite).opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let savedGradient = LinearGradient(
        stops: [
            .init(color: Palette.savedStart, location: 0),
            .init(color: Palette.savedAqua, location: 0.28),
            .init(color: Palette.savedMint, location: 0.5),
            .init(color: Palette.savedLime, location: 0.73),
            .init(color: Palette.savedEnd, location: 1)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let carButtonGradient = LinearGradient(
        colors: [Palette.glowLavender, Palette.glowPink, Palette.peach, Palette.glowYellow],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let clearToWhiteFade = LinearGradient(
        colors: [Color(at: .pureWhite).opacity(0), Color(at: .pureWhite)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let whiteToClearFade = LinearGradient(
        colors: [Color(at: .pureWhite), Color(at: .pureWhite).opacity(0)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let tyreTrackFade = LinearGradient(
        stops: [
            .init(color: .black, location: 0),
            .init(color: .black, location: Sizes.Staged.trackFadeStart),
            .init(color: .black.opacity(0), location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let citizenshipLockFade = LinearGradient(
        stops: [
            .init(color: Color(at: .pureWhite).opacity(0), location: 0),
            .init(color: Color(at: .pureWhite).opacity(0.78), location: Sizes.CitizenshipLock.fadeMidStop),
            .init(color: Color(at: .pureWhite), location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let backFaceWashGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureWhite), location: 0),
            .init(color: Color(at: .pureWhite), location: 0.163),
            .init(color: Palette.washLavender, location: 0.456),
            .init(color: Palette.washCoral, location: 0.574),
            .init(color: Palette.washMagenta, location: 0.926)
        ],
        startPoint: UnitPoint(x: -0.683, y: 1.411),
        endPoint: UnitPoint(x: 0.199, y: -0.014)
    )

    static let pendingRingGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureBlack), location: 0),
            .init(color: Color(at: .pureBlack), location: 0.163),
            .init(color: Palette.pendingRingIndigo, location: 0.303),
            .init(color: Palette.pendingRingFuchsia, location: 0.464),
            .init(color: Palette.pendingRingRed, location: 0.75),
            .init(color: Palette.pendingRingGold, location: 1)
        ],
        startPoint: UnitPoint(x: -0.346, y: 0.416),
        endPoint: UnitPoint(x: 1, y: 0.42)
    )

    static let plusRingGradient = LinearGradient(
        stops: [
            .init(color: Palette.plusRingNavy, location: 0),
            .init(color: Palette.plusRingBlue, location: 0.5),
            .init(color: Palette.plusRingPlum, location: 0.75),
            .init(color: Palette.plusRingOrange, location: 1)
        ],
        startPoint: UnitPoint(x: 0.5, y: 0.024),
        endPoint: UnitPoint(x: 0.179, y: 0.94)
    )

    static let travellerCardLipGradient = LinearGradient(
        colors: [Palette.travellerCardLipTop, Palette.travellerCardLipBottom],
        startPoint: UnitPoint(x: 0.5, y: -0.429),
        endPoint: .bottom
    )

    static let programmeTextGradient = LinearGradient(
        colors: [Color(at: .pureWhite), Color(at: .pureWhite).opacity(0.6)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let programmeTilePillGradient = LinearGradient(
        colors: [Palette.programmeTilePillTop, Palette.programmeTilePillBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let programmeTextGradientDark = LinearGradient(
        colors: [Color(at: .pureBlack), Palette.cardDarkSecondary],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let programmeTilePillGradientDark = LinearGradient(
        colors: [Palette.cardDarkPillTop, Palette.cardDarkPillBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    struct CardShade {
        let primary: Color
        let secondary: Color
        let faint: Color
        let label: Color
        let dots: Color
        let number: LinearGradient
        let pill: LinearGradient
        let pillBorder: Color
        let divider: Color
        let shadow: Color

        static func resolve(_ overlay: ProfileV3TextOverlay) -> CardShade {
            switch overlay {
            case .light: return light
            case .dark: return dark
            }
        }

        static let light = CardShade(
            primary: Color(at: .pureWhite),
            secondary: Palette.statLabel,
            faint: Palette.programmeTileExpiry,
            label: Palette.programmeTilePointsLabel,
            dots: Palette.programmeTileDots,
            number: programmeTextGradient,
            pill: programmeTilePillGradient,
            pillBorder: Palette.programmeTilePillBorder,
            divider: Palette.programmeTileDivider,
            shadow: Palette.artTextShadow
        )

        static let dark = CardShade(
            primary: Color(at: .pureBlack),
            secondary: Palette.cardDarkSecondary,
            faint: Palette.cardDarkFaint,
            label: Palette.cardDarkPointsLabel,
            dots: Color(at: .pureBlack),
            number: programmeTextGradientDark,
            pill: programmeTilePillGradientDark,
            pillBorder: Palette.cardDarkPillBorder,
            divider: Palette.cardDarkDivider,
            shadow: Palette.artTextShadowOnLight
        )
    }

    static let programmesBottomFadeGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureWhite).opacity(0), location: 0),
            .init(color: Color(at: .pureWhite).opacity(0), location: 0.15),
            .init(color: Palette.programmesBottomFade, location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let podiumShadowGradient = LinearGradient(
        colors: [Palette.podiumShadowStart, Palette.podiumShadowEnd],
        startPoint: UnitPoint(x: 0.04, y: 0.5),
        endPoint: UnitPoint(x: 0.35, y: 0.5)
    )

    static let hoverShadowGradient = RadialGradient(
        colors: [Palette.hoverShadow, Palette.hoverShadow.opacity(0)],
        center: .center,
        startRadius: 0,
        endRadius: Sizes.hoverShadowWidth / 2
    )

    static let kycGlowActiveGradient = Gradient(stops: [
        .init(color: Palette.kycGlowActive, location: 0),
        .init(color: Palette.kycGlowActiveMid, location: 0.5),
        .init(color: Palette.kycGlowEnd, location: 1)
    ])

    static let kycGlowInactiveGradient = Gradient(stops: [
        .init(color: Palette.kycGlowInactive, location: 0),
        .init(color: Palette.kycGlowInactiveMid1, location: 0.25),
        .init(color: Palette.kycGlowInactiveMid2, location: 0.5),
        .init(color: Palette.kycGlowInactiveMid3, location: 0.75),
        .init(color: Palette.kycGlowEnd, location: 1)
    ])

    static let statusTextGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureBlack), location: 0),
            .init(color: Palette.statusBlue, location: 0.33),
            .init(color: Palette.statusRed, location: 0.66),
            .init(color: Palette.statusYellow, location: 0.99)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let orbRingGradient = LinearGradient(
        stops: [
            .init(color: Palette.orbRingEnd, location: 0),
            .init(color: Palette.background, location: 0.3),
            .init(color: Palette.background, location: 0.7),
            .init(color: Palette.orbRingEnd, location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let kycOverlayGlowGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureWhite), location: 0),
            .init(color: Color(at: .pureWhite), location: 0.16),
            .init(color: Palette.kycOverlayLavender, location: 0.46),
            .init(color: Palette.kycOverlayIndigo, location: 0.6),
            .init(color: Palette.kycOverlayCoral, location: 0.74),
            .init(color: Palette.kycOverlayGold, location: 0.93)
        ],
        startPoint: UnitPoint(x: -0.28, y: 1.06),
        endPoint: UnitPoint(x: 0.23, y: 0.15)
    )

    static let spinnerGradient = AngularGradient(
        stops: [
            .init(color: Palette.spinnerTail, location: 0),
            .init(color: Palette.spinner, location: Motion.spinnerFadeEnd),
            .init(color: Palette.spinner, location: Motion.spinnerTrim),
            .init(color: Palette.spinnerTail, location: 1)
        ],
        center: .center,
        startAngle: .zero,
        endAngle: .degrees(360)
    )

    static let collapseTabGradient = LinearGradient(
        colors: [Palette.collapseTabTop, Palette.collapseTabBottom],
        startPoint: UnitPoint(x: 0.5, y: -0.43),
        endPoint: .bottom
    )

    static let collapseNotchGradient = LinearGradient(
        stops: [
            .init(color: Palette.collapseNotchFill.opacity(0), location: 0.5),
            .init(color: Palette.collapseNotchFill, location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let collapseNotchStrokeGradient = LinearGradient(
        colors: [Palette.collapseNotchStroke.opacity(0), Palette.collapseNotchStroke],
        startPoint: .top,
        endPoint: .bottom
    )

    static let detailPillGradient = LinearGradient(
        colors: [Palette.detailPillTop, Palette.detailPillBottom],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let sliderKnobRimGradient = LinearGradient(
        colors: [Color(at: .pureBlack), Palette.sliderKnobLight],
        startPoint: .top,
        endPoint: .bottom
    )

    static let sliderKnobFaceGradient = LinearGradient(
        colors: [Palette.sliderKnobLight, Color(at: .pureBlack)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let sliderRulerGradient = Gradient(stops: [
        .init(color: Palette.rulerTickFaded, location: 0),
        .init(color: Palette.rulerTick, location: 0.5),
        .init(color: Palette.rulerTickFaded, location: 1)
    ])
}
