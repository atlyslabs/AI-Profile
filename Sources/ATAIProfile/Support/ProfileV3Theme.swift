import ATUIKit
import SwiftUI

enum ProfileV3Theme {
    enum Canvas {
        static let width: CGFloat = 440
        static let content: CGFloat = width - 2 * Sizes.screenHorizontalMargin

        static func scale(for available: CGFloat) -> CGFloat {
            available > 0 ? min(1, available / width) : 1
        }
    }

    enum Space {
        static let s4: CGFloat = 4
        static let s6: CGFloat = 6
        static let s8: CGFloat = 8
        static let s10: CGFloat = 10
        static let s12: CGFloat = 12
        static let s14: CGFloat = 14
        static let s16: CGFloat = 16
        static let s18: CGFloat = 18
        static let s20: CGFloat = 20
        static let s22: CGFloat = 22
        static let s24: CGFloat = 24
        static let s28: CGFloat = 28
        static let s30: CGFloat = 30
        static let s32: CGFloat = 32
        static let s40: CGFloat = 40
        static let s48: CGFloat = 48
        static let s50: CGFloat = 50
    }

    enum Icon {
        static let xs: CGFloat = 10
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 40
    }

    enum Radius {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 30
        static let xxxl: CGFloat = 40
    }

    enum Control {
        static let compact: CGFloat = 32
        static let regular: CGFloat = 40
        static let tapTarget: CGFloat = 44
        static let comfortable: CGFloat = 48
        static let large: CGFloat = 50
        static let xLarge: CGFloat = 56
    }

    enum Stroke {
        static let fine: CGFloat = 0.5
        static let thin: CGFloat = 0.8
        static let hairline: CGFloat = 1
        static let medium: CGFloat = 1.2
        static let regular: CGFloat = 2
        static let thick: CGFloat = 3
        static let heavy: CGFloat = 4
    }

    enum Sizes {
        static let emptyStateIcon = Icon.xxl
        static let hubHeaderBottomPadding = Space.s8
        static let pillIcon = Icon.md
        static let settingsRowHeight = Control.regular
        static let settingsRowIcon = Icon.lg
        static let sheetCornerRadius = Radius.xxxl
        static let sheetHeaderIcon = Icon.xl
        static let sliderRulerSpacing: CGFloat = 19
        static let worldPassCornerRadius = Radius.xxl
        static let screenHorizontalMargin = Space.s30
        static let circleButton = Control.large
        static let navButton: CGFloat = 45.4
        static let topBarInset = Space.s16
        static let cardCornerRadius: CGFloat = 35
        static let sheetFallbackHeight: CGFloat = 700
        static let settingsLoadStateHeight: CGFloat = 420
        static let cardContentPadding = Space.s28
        static let separatorDot: CGFloat = 4
        static let activatePillHeight: CGFloat = 22
        static let chipHeight: CGFloat = 36
        static let statusDot: CGFloat = 18
        static let radioMark: CGFloat = 20
        static let statusDotCore: CGFloat = 5
        static let sheetGrabberWidth: CGFloat = 36
        static let sheetGrabberHeight: CGFloat = 5
        static let skeletonCardHeight: CGFloat = 154
        static let couponCardHeight: CGFloat = 102
        static let progressRing: CGFloat = 62
        static let progressRingInner: CGFloat = 56
        static let stackSecondPeek: CGFloat = 16
        static let stackThirdInset: CGFloat = 37
        static let stackThirdPeek: CGFloat = 32
        static let stackFallbackWidth: CGFloat = Benefit.designWidth
        static let orbInnerScale: CGFloat = 0.82
        static let orbArc: ClosedRange<CGFloat> = 0.08 ... 0.72
        static let toastGlowRadius: CGFloat = 100
        static let orbImageScale: CGFloat = 0.62
        static let orbShadowY: CGFloat = 1
        static let agentsHeadingMaxWidth: CGFloat = 269
        static let countryFlagBox: CGFloat = 32
        static let topBarTop = Space.s6
        static let topBarCentre: CGFloat = topBarTop + navButton / 2
        static let carouselTop = Space.s16
        static let worldPassWidth: CGFloat = 252
        static let worldPassHeight: CGFloat = 350
        static let worldPassSpacing: CGFloat = 41
        static let worldPassGlobe: CGFloat = 152
        static let worldPassGlobeOffsetY: CGFloat = -30.5
        static let worldPassGlobeOrbits: CGFloat = 280
        static let worldPassDividerWidth: CGFloat = 212
        static let worldPassNumberMaxWidth: CGFloat = 168
        static let worldPassContentInset = Space.s20
        static let hoverShadowWidth: CGFloat = 196
        static let hoverShadowHeight: CGFloat = 26
        static let hoverShadowDrop: CGFloat = 50
        static let kycGlowRadius: CGFloat = 234
        static let kycGlowStartScale: CGFloat = 0.5
        static let spinner: CGFloat = 56
        static let statusPanelWidth: CGFloat = 253
        static let statusSubtitleWidth: CGFloat = 216
        static let hintPillHeight: CGFloat = 23
        static let hintOffsetX: CGFloat = -50
        static let hintOffsetY: CGFloat = 194
        static let joystickOuter: CGFloat = 77
        static let joystickMiddle: CGFloat = 39
        static let joystickInner: CGFloat = 21
        static let sourcesIconOverlap: CGFloat = -8
        static let sourcesGlyph = CGSize(width: 14, height: 12)
        static let sourcesPillHeight: CGFloat = 30
        static let sourcesPillChevron: CGFloat = 18
        static let sourcesPillChevronGap: CGFloat = 5
        static let gradientButtonBlur: CGFloat = 10
        static let optionCardTextSpacing: CGFloat = 2
        static let sliderTrackHeight: CGFloat = 6
        static let sliderKnob: CGFloat = 20
        static let sliderKnobRim: CGFloat = 1.5625
        static let sliderRulerHeight: CGFloat = 43
        static let sliderMinorTickHeight: CGFloat = 21.5
        static let underlinedFieldWidth: CGFloat = 160
        static let underlinedFieldCaretAllowance: CGFloat = 4
        static let emptyStateTop: CGFloat = 120
        static let emptyStateTextWidth: CGFloat = 260
        static let stepBarWidth: CGFloat = 17
        static let stepBarHeight: CGFloat = 3
        static let hubBarBottom: CGFloat = 74
        static let topBarBackdropHeight: CGFloat = Collapse.backdropTop + hubHeaderBottomPadding
        static let benefitsHeaderTop: CGFloat = 60
    }

    enum Shadow {
        static let cardRadius: CGFloat = 14
        static let cardY: CGFloat = 4.675
        static let artTextRadius: CGFloat = 6
        static let artTextY: CGFloat = 1
        static let pillRadius: CGFloat = 7
        static let pillY: CGFloat = 4.675
        static let chipRadius: CGFloat = 4.5
        static let chipY: CGFloat = 3.5
        static let redeemRadius: CGFloat = 15
        static let redeemY: CGFloat = 4
        static let savedRadius: CGFloat = 16
        static let savedY: CGFloat = 8
        static let plusRadius: CGFloat = 1.28
        static let plusY: CGFloat = 2.56
        static let ringRadius: CGFloat = 2
        static let ringY: CGFloat = 1
        static let orbRadius: CGFloat = 4
        static let glassOrbRadius: CGFloat = 6
        static let glassOrbY: CGFloat = 4
        static let sliderKnobRadius: CGFloat = 5.32
        static let sliderKnobY: CGFloat = 10.63
    }

    enum Counts {
        static let passportUpdateSteps = 2
        static let detailStatsFirstRow = 2
        static let stackLayers = 3
        static let detailPillMaxFlags = 5
        static let sourcesMaxIcons = 2
        static let programmeTileDotRows = 4
        static let programmeTileDotColumns = 12
        static let sliderRulerTicks = 42
        static let sliderRulerMajorInterval = 5
        static let sliderRulerMajorPhase = 3
        static let chipInlineLimit = 10
        static let addProgrammeSteps = 2
    }

    enum Rotation {
        static let stamp: Double = 40
        static let quarter: Double = 90
        static let half: Double = 180
        static let avatarArc: Double = 75
        static let diagonalBack: Double = -45
        static let backFaceWash: Double = -127.42
    }

    enum Typography {
        static let worldPassHeaderSize: CGFloat = 18.6
        static let baggageTabDetailSize: CGFloat = 12
        static let baggageTabMinScale: CGFloat = 0.8
        static let sourceStepDetailSize: CGFloat = 11
        static let worldPassHeaderTracking: CGFloat = -0.74
        static let passportCountrySize: CGFloat = 14
        static let passportCountryTracking: CGFloat = -0.56
        static let passportCountryMinScale: CGFloat = 0.6
        static let worldPassNumberFont = "Dotline"
        static let worldPassNumberSize: CGFloat = 20
        static let worldPassNumberTracking: CGFloat = 1
        static let worldPassNumberMinScale: CGFloat = 0.5
        static let carNameSize: CGFloat = 20
        static let benefitsWordmarkSize: CGFloat = 22
        static let benefitsWordmarkTracking: CGFloat = -0.88
    }

    enum Ratio {
        static let sheetMaxHeight: CGFloat = 0.92
    }

    enum Opacity {
        static let stagedTrack: Double = 0.2
        static let medicalSheen: Double = 0.2
        static let carSide: Double = 0.5
        static let baggageDetail: Double = 0.6
        static let backSlot: Double = 0.6
        static let stackSecondLayer: Double = 0.3
        static let stackThirdLayer: Double = 0.15
        static let sheetBackdrop: Double = 0.35
        static let reorderPlaceholder: Double = 0.3
        static let glassGlint: Double = 0.6
        static let glassGlintTilted: Double = 0.75
        static let glassInnerShadow: Double = 0.15
        static let sliderDisabled: Double = 0.1
        static let sliderRuler: Double = 0.5
        static let hintCapsule: Double = 0.26
        static let worldPassSubtitle: Double = 0.4
        static let cardSubtitle: Double = 0.5
        static let redeemedArtwork: Double = 0.8
        static let programmeTileBackGlow: Double = 0.75
        static let toastWash: Double = 0.18
        static let connectorFloatBadge: Double = 0.8
        static let backFaceWash: Double = 0.4
        static let agentGlowCore: Double = 0.9
        static let agentGlowEdge: Double = 0.5
        static let optionUnselected: Double = 0.6
        static let programmeTileDotPeak: Double = 0.55
        static let programmeTileDotFloor: Double = 0.35
    }

    enum Measure {
        static let inchesPerCentimetre: Double = 2.54
        static let inchesPerFoot: Double = 12
    }

    static func collapseAngleDegrees(_ progress: CGFloat) -> Double {
        let minimum = Sizes.Collapse.tabHeight / Sizes.worldPassHeight
        let ratio = max(minimum, 1 - progress * (1 - minimum))
        return Double(acos(ratio)) * 180 / .pi
    }

    static func ramp(_ value: CGFloat, from start: CGFloat, to end: CGFloat) -> Double {
        guard end > start else { return value >= end ? 1 : 0 }
        return Double(min(max((value - start) / (end - start), 0), 1))
    }
}
