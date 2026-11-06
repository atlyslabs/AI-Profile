import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum City {
        static let carouselTop: CGFloat = 91 - ProfileV3Theme.Sizes.Agent.backTop - ProfileV3Theme.Sizes.circleButton
        static let window = CGSize(width: 189, height: 232)
        static let windowSpacing: CGFloat = 30.17
        static let windowSideScale: CGFloat = 0.84
        static let windowRadius: CGFloat = 107.907
        static let windowBezel = CGSize(width: 181.245, height: 224.806)
        static let windowBezelTop: CGFloat = 3.6
        static let windowFrame = CGSize(width: 159.922, height: 197.829)
        static let windowFrameTop: CGFloat = 17.09
        static let windowGlass = CGSize(width: 136.661, height: 176.248)
        static let windowGlassTop: CGFloat = 27.88
        static let windowGlassRadius: CGFloat = 89.922
        static let windowGlare = CGSize(width: 104, height: 158)
        static let windowGlareTop: CGFloat = 9.12
        static let windowGlareRadius: CGFloat = 80
        static let windowGlareBlur: CGFloat = 3.5
        static let windowPhotoBlur: CGFloat = 1.8
        static let windowRing: CGFloat = 0.45
        static let windowCodeSize: CGFloat = 24
        static let windowCodeTracking: CGFloat = -0.96
        static let windowTextGap = ProfileV3Theme.Space.s8
        static let addRingPulseWidth: CGFloat = 1.6
        static let addRingSettleWidth: CGFloat = 0.65
        static let addLabelTop: CGFloat = 22
        static let addDetailTop: CGFloat = 9
        static let addDetailWidth: CGFloat = 110
        static let tagRowTop: CGFloat = 30
        static let tagChipHeight: CGFloat = 36
        static let tagChipLeading = ProfileV3Theme.Space.s12
        static let tagChipTrailing = ProfileV3Theme.Space.s16
        static let tagChipIcon = ProfileV3Theme.Icon.lg
        static let tagChipGap = ProfileV3Theme.Space.s10
        static let tagEditWidth: CGFloat = 48
        static let tagRowGap: CGFloat = 7
        static let tagChipMaxWidth: CGFloat = 220
        static let foundTop: CGFloat = 30
        static let sourcesTop = ProfileV3Theme.Space.s16
        static let sourcesIcon = ProfileV3Theme.Icon.lg
        static let sourcesIconOverlap: CGFloat = -8
        static let sourcesChevron: CGFloat = 18
        static let sourcesChevronGap: CGFloat = 5
        static let tabsTop: CGFloat = 48
        static let tabsTopWithoutSources: CGFloat = 36
        static let tabHeight: CGFloat = 38
        static let tabLeading = ProfileV3Theme.Space.s12
        static let tabTrailing = ProfileV3Theme.Space.s16
        static let tabIcon = ProfileV3Theme.Icon.md
        static let tabGap = ProfileV3Theme.Space.s10
        static let tabSpacing = ProfileV3Theme.Space.s16
        static let tabStripPadding = ProfileV3Theme.Space.s10
        static let tabStripHeight = tabHeight + tabStripPadding * 2
        static let pinnedTabsTop = ProfileV3Theme.Sizes.Agent.backTop + ProfileV3Theme.Sizes.circleButton
        static let pinnedTabsFade = ProfileV3Theme.Space.s16
        static let sectionScrollInset = pinnedTabsTop + tabStripHeight
        static let sectionReachedLine = sectionScrollInset + ProfileV3Theme.Space.s8
        static let sectionsTop: CGFloat = 36
        static let sectionSpacing = ProfileV3Theme.Space.s16
        static let notchHeight: CGFloat = 43
        static let notchIcon = ProfileV3Theme.Icon.xl
        static let notchIconTop: CGFloat = 19
        static let notchDepth: CGFloat = 12.6592
        static let notchHalfWidth: CGFloat = 65.5
        static let glow = CGSize(width: 301, height: 98)
        static let glowTop: CGFloat = 33
        static let glowBlur: CGFloat = 17
        static let cardRadius = ProfileV3Theme.Radius.xxl
        static let cardPadding = ProfileV3Theme.Space.s30
        static let cardTitleTop: CGFloat = 38
        static let cardTrailingPadding = ProfileV3Theme.Space.s24
        static let cardBottom = ProfileV3Theme.Space.s32
        static let cardShadowRadius: CGFloat = 15
        static let cardShadowY: CGFloat = 4
        static let cardHeaderGap = ProfileV3Theme.Space.s10
        static let cardContentTop = ProfileV3Theme.Space.s32
        static let cardNoteTop: CGFloat = 28
        static let addButton = ProfileV3Theme.Control.comfortable
        static let addButtonOverhang: CGFloat = 14
        static let optionHeight = ProfileV3Theme.Control.comfortable
        static let optionRadius = ProfileV3Theme.Radius.xl
        static let optionGap = ProfileV3Theme.Space.s20
        static let optionGridWidth: CGFloat = 320
        static let tightTracking: CGFloat = -0.56
        static let optionLeading: CGFloat = 21
        static let optionOrbLeading = ProfileV3Theme.Space.s12
        static let optionTrailing: CGFloat = 17
        static let optionOrb = ProfileV3Theme.Icon.xl
        static let optionOrbCheck = ProfileV3Theme.Icon.sm
        static let optionIconGap = ProfileV3Theme.Space.s10
        static let logoChipLeading: CGFloat = 9
        static let logoChipLogo = ProfileV3Theme.Control.compact
        static let logoChipSpacing = ProfileV3Theme.Space.s16
        static let classCard = CGSize(width: 140, height: 157)
        static let classCardSpacing = ProfileV3Theme.Space.s16
        static let classCardTitle: CGFloat = 19
        static let classCardTitleWidth: CGFloat = 102
        static let classArt = CGSize(width: 106, height: 130)
        static let classArtOffset = CGSize(width: 26, height: 30)
        static let placeHeight: CGFloat = 86
        static let placeRadius = ProfileV3Theme.Radius.xl
        static let placeThumb: CGFloat = 61
        static let placeThumbRadius = ProfileV3Theme.Radius.md
        static let placeThumbInset: CGFloat = 15
        static let placeTextGap: CGFloat = 15
        static let placeSpacing = ProfileV3Theme.Space.s12
        static let placeLineGap = ProfileV3Theme.Space.s4
        static let optOutTop = ProfileV3Theme.Space.s24
        static let optOutGap = ProfileV3Theme.Space.s20
        static let optOutRowGap = ProfileV3Theme.Space.s12
        static let optOutBox = ProfileV3Theme.Icon.xl
        static let noteWidth: CGFloat = 302
        static let sliderTop = ProfileV3Theme.Space.s24
        static let shimmerWidth: CGFloat = 110
        static let saveBarClearance: CGFloat = 120
        static let introTitleTop: CGFloat = 44
        static let introTitleWidth: CGFloat = 310
        static let introTitleSize: CGFloat = 24
        static let introTitleTracking: CGFloat = -0.96
        static let introDeckTop: CGFloat = 70
        static let cityLoadHeight: CGFloat = 320
        static let purposeLoadHeight: CGFloat = 200
        static let introDeckHeight: CGFloat = 364
        static let deckCard = CGSize(width: 286.878, height: 326.722)
        static let deckCardRadius: CGFloat = 25.5
        static let deckPadding: CGFloat = 28
        static let deckCodeSize: CGFloat = 39.23
        static let deckCodeTracking: CGFloat = -1.57
        static let deckNameTop = ProfileV3Theme.Space.s4
        static let deckTagTop = ProfileV3Theme.Space.s20
        static let deckTagHeight: CGFloat = 28.5
        static let deckTagIcon = ProfileV3Theme.Icon.md
        static let deckPill = CGSize(width: 234.284, height: 58.969)
        static let deckPillRadius: CGFloat = 47.813
        static let deckPillBlur: CGFloat = 9.563
        static let deckPillsTop: CGFloat = 170.49
        static let deckPillSpacing: CGFloat = 18.8
        static let deckPillTilt: Double = -1.59
        static let deckPillTiltSecond: Double = 0.19
        static let deckPillPadding = ProfileV3Theme.Space.s16
        static let deckMiddleTilt: Double = -6.16
        static let deckBackTilt: Double = 8.12
        static let deckDropTilt: Double = 7
        static let deckDrop = CGSize(width: 12, height: 430)
        static let tagSheetOptionsTop: CGFloat = 38
        static let tagSheetButtonTop: CGFloat = 59
        static let tagSheetBottom: CGFloat = 57
        static let tagSheetButtonWidth: CGFloat = 343
        static let tagSheetButtonHeight: CGFloat = 51
        static let purposeTop: CGFloat = 46
        static let purposeFieldTop = ProfileV3Theme.Space.s10
        static let purposeButtonTop: CGFloat = 70
    }
}

extension ProfileV3Theme.Palette {
    static let cityWindowRing = Color(hex: "666666")
    static let cityWindowEdge = Color(hex: "A6A6A6")
    static let cityWindowShine = Color(hex: "EAE8E8")
    static let cityWindowGlass = Color(hex: "031D2F")
    static let cityWindowGlare = Color(hex: "D9D9D9")
    static let cityWindowGlareFade = Color(hex: "737373").opacity(0)
    static let cityAddGlass = Color(hex: "172017")
    static let cityAddAccent = Color(hex: "9DD645")
    static let cityAddButtonLime = Color(hex: "A1E000")
    static let cityInkMid = Color(hex: "454545")
    static let cityInkEnd = Color(hex: "393939")
    static let cityCardBorder = Color(hex: "E6E7E8")
    static let cityOptionBorder = Color(hex: "E3E3E3")
    static let cityOptionSelectedBorder = Color(at: .neutralGrey400)
    static let cityOptionText = Color(hex: "666666")
    static let cityGlowComplete = Color(hex: "DEFCB8")
    static let cityGlowPending = Color(hex: "F5F5F5")
    static let cityNotchComplete = Color(hex: "33551C")
    static let cityNotchPending = Color(hex: "C6C6C6")
    static let citySourcesText = Color(at: .neutralGrey700)
    static let cityPlace = Color(hex: "FAFAFA")
    static let cityPlaceThumb = Color(hex: "EFEFEF")
    static let cityPlaceBorder = Color(at: .pureBlack).opacity(0.05)
    static let cityDeckCard = Color(hex: "031624")
    static let cityDeckPill = Color(at: .pureWhite).opacity(0.2)
    static let cityDeckTagBorder = Color(at: .pureWhite).opacity(0.6)
    static let cityButtonGlow = Color(at: .pureBlack).opacity(0.25)
}

extension ProfileV3Theme.Opacity {
    static let cityWindowBezel: Double = 0.4
    static let cityWindowPhoto: Double = 0.5
    static let cityWindowPhotoSharp: Double = 0.7
    static let cityWindowGlare: Double = 0.5
    static let cityWindowName: Double = 0.7
    static let cityAddDetail: Double = 0.6
    static let cityAddRingRest: Double = 0.4
    static let cityAddRingFade: Double = 0.12
    static let cityFoundNoun: Double = 0.5
    static let cityClassArt: Double = 0.5
    static let cityOrbIdle: Double = 0.3
    static let cityPlaceSubtitle: Double = 0.5
    static let cityDeckMiddle: Double = 0.8
    static let cityDeckBack: Double = 0.4
}

extension ProfileV3Theme.Motion {
    static let cityRingSeconds: Double = 1.6
    static let cityRingRiseSeconds: Double = 0.576
    static let cityRingSpreadSeconds: Double = 0.592
    static let cityRingPeakScale: CGFloat = 1.025
    static let cityRingSettleScale: CGFloat = 1.055
    static let cityDeckStepSeconds: Double = 1.6
    static let cityDeckHoldSeconds: Double = 0.8
    static let cityDeckMoveSeconds: Double = 0.55
    static let cityDeckFadeStartSeconds: Double = 0.98
    static let cityDeckRevealSeconds: Double = 0.18
    static let citySectionScrollSeconds: Double = 0.4
    static let citySectionScroll: Animation = .easeInOut(duration: citySectionScrollSeconds)
    static let cityTabFollowPauseSeconds: Double = citySectionScrollSeconds + 0.1
    static let citySearchDebounceMilliseconds = 250
}

extension ProfileV3Theme {
    static let cityInkGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureBlack), location: 0),
            .init(color: Palette.cityInkMid, location: 0.857),
            .init(color: Palette.cityInkEnd, location: 1)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let cityInkShade = LinearGradient(
        colors: [Color(at: .pureBlack).opacity(0.2), Color(at: .pureBlack).opacity(0)],
        startPoint: .bottom,
        endPoint: .center
    )

    static let cityAddButtonGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureWhite).opacity(0), location: 0.4225),
            .init(color: Palette.cityAddButtonLime, location: 1)
        ],
        startPoint: UnitPoint(x: 0.23, y: 0.92),
        endPoint: UnitPoint(x: 0.77, y: 0.08)
    )

    static let cityWindowBezelGradient = LinearGradient(
        colors: [Palette.cityWindowEdge.opacity(0.33), Palette.cityWindowShine.opacity(0.33), Palette.cityWindowEdge.opacity(0.33)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cityWindowFrameGradient = LinearGradient(
        colors: [Palette.cityWindowEdge.opacity(0.53), Palette.cityWindowShine.opacity(0.53), Palette.cityWindowEdge.opacity(0.53)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cityWindowGlareGradient = LinearGradient(
        stops: [
            .init(color: Palette.cityWindowGlareFade, location: 0.481),
            .init(color: Palette.cityWindowGlare, location: 0.883)
        ],
        startPoint: UnitPoint(x: 0.82, y: 0.12),
        endPoint: UnitPoint(x: 0.18, y: 0.88)
    )

    static func cityOrbCheckTint(_ optionID: String) -> Color {
        optionID.lowercased() == "morning" ? Color(at: .neutralGrey900) : Color(at: .pureWhite)
    }
}
