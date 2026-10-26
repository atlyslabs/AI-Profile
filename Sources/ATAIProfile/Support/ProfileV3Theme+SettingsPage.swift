import SwiftUI

extension ProfileV3Theme.Sizes {
    static let headerRevealDistance = ProfileV3Theme.Space.s24
    static let headerFadeGap: CGFloat = 12

    enum SettingsPage {
        static let headerTop: CGFloat = 21
        static let headerBarBottom = ProfileV3Theme.Space.s10
        static let headerFade = ProfileV3Theme.Sizes.Agent.stickyFadeHeight
        static let avatar: CGFloat = 80
        static let avatarTop: CGFloat = 38
        static let avatarLetterOffsetY: CGFloat = -3
        static let cardsTop: CGFloat = 40
        static let cardSpacing: CGFloat = 25
        static let cardRadius = ProfileV3Theme.Radius.xxxl
        static let cardHeaderTop = ProfileV3Theme.Space.s24
        static let cardHeaderBottom = ProfileV3Theme.Space.s20
        static let cardHeaderTrailing = ProfileV3Theme.Space.s24
        static let rowsTop: CGFloat = 30
        static let rowSpacing = ProfileV3Theme.Space.s14
        static let dangerIcon: CGFloat = 18
        static let bottom: CGFloat = 40
        static let loadStateHeight: CGFloat = 240
        static let accessCardInset = ProfileV3Theme.Space.s30
        static let accessCardSpacing = ProfileV3Theme.Space.s12
        static let accessCardHeight: CGFloat = 122
        static let accessCardRadius: CGFloat = 25
        static let accessCardTextLeading: CGFloat = 24.5
        static let accessCardTitleTop: CGFloat = 26
        static let accessCardSubtitleTop: CGFloat = 11
        static let accessCardTextWidth: CGFloat = 122
        static let accessCardShadowRadius: CGFloat = 15
        static let accessCardShadowY: CGFloat = 4
        static let accessArtTop: CGFloat = 19
        static let informationArtSize = CGSize(width: 84, height: 81)
        static let informationArtTrailing: CGFloat = 38
        static let appArtSize = CGSize(width: 87, height: 81)
        static let appArtTrailing: CGFloat = 35
    }

    enum Permissions {
        static let cardsTop = ProfileV3Theme.Space.s40
        static let cardSpacing = ProfileV3Theme.Space.s30
        static let cardInset: CGFloat = 28
        static let cardTop: CGFloat = 29
        static let cardBottom = ProfileV3Theme.Space.s32
        static let tagHeight: CGFloat = 14
        static let optionsTop: CGFloat = 27
        static let optionSpacing = ProfileV3Theme.Space.s24
        static let subtitleTop = ProfileV3Theme.Space.s8
        static let subtitleWidth: CGFloat = 177
        static let bottom = ProfileV3Theme.Space.s40
        static let loadStateHeight: CGFloat = 240
    }

    enum InformationAccess {
        static let heroTop: CGFloat = 29
        static let heroWidth: CGFloat = 320
        static let shield = CGSize(width: 84, height: 105)
        static let shieldRim: CGFloat = 8
        static let shieldRimBlur: CGFloat = 2
        static let shieldShadowRadius: CGFloat = 46
        static let shieldShadowY: CGFloat = 30.6
        static let shieldShadowPadding: CGFloat = 120
        static let check = CGSize(width: 54, height: 54)
        static let checkOrigin = CGPoint(x: 14, y: 26)
        static let wordmark = CGSize(width: 48.0943, height: 21.2238)
        static let wordmarkOrigin = CGPoint(x: 19.16, y: 41.8)
        static let glow: CGFloat = 237
        static let glowBlur: CGFloat = 50
        static let glowCentreY: CGFloat = 151.5
        static let branch = CGSize(width: 101, height: 26.5)
        static let branchTop: CGFloat = 26
        static let branchLeading: CGFloat = 0.5
        static let stemLeading: CGFloat = 15
        static let stemWidth: CGFloat = 98
        static let stemY: CGFloat = 52
        static let lineWidth: CGFloat = 9
        static let titleTop: CGFloat = 31
        static let titleWidth: CGFloat = 260
        static let subtitleTop = ProfileV3Theme.Space.s12
        static let cardsTop = ProfileV3Theme.Space.s50
        static let cardSpacing = ProfileV3Theme.Space.s16
        static let cardRadius = ProfileV3Theme.Radius.xxl
        static let cardHeight: CGFloat = 84
        static let cardTop = ProfileV3Theme.Space.s30
        static let cardLeading: CGFloat = 27
        static let cardTrailing = ProfileV3Theme.Space.s30
        static let cardIcon = ProfileV3Theme.Icon.lg
        static let chipsTop: CGFloat = 27
        static let chipsBottom: CGFloat = 36
        static let chipSpacing = ProfileV3Theme.Space.s16
        static let chipLogo = ProfileV3Theme.Icon.xl
        static let chipPadding: CGFloat = 2
        static let chipTrailing = ProfileV3Theme.Space.s8
        static let chipGap = ProfileV3Theme.Space.s8
        static let cardShadowRadius: CGFloat = 15
        static let cardShadowY: CGFloat = 4
        static let loadStateHeight: CGFloat = 200
        static let bottom: CGFloat = 40
        static let comingSoonArtTop: CGFloat = 120
        static let comingSoonTitleTop: CGFloat = 60
        static let comingSoonBodyWidth: CGFloat = 240
    }
}

extension ProfileV3Theme {
    static let accessGlowGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureWhite), location: 0),
            .init(color: Color(at: .pureWhite), location: 0.163),
            .init(color: Color(hex: "E5E6F7"), location: 0.456),
            .init(color: Color(hex: "5D64FF"), location: 0.605),
            .init(color: Color(hex: "FF5959"), location: 0.745),
            .init(color: Color(hex: "FFE23D"), location: 0.926)
        ],
        startPoint: UnitPoint(x: -0.774, y: 1.411),
        endPoint: UnitPoint(x: 0.056, y: -0.07)
    )

    static let accessBranchGradient = LinearGradient(
        colors: [Color(at: .pureWhite).opacity(0), Color(at: .pureWhite)],
        startPoint: .leading,
        endPoint: UnitPoint(x: 0.658, y: 0.5)
    )

    static let accessStemGradient = LinearGradient(
        colors: [Color(at: .pureWhite).opacity(0), Color(at: .pureWhite)],
        startPoint: UnitPoint(x: -0.061, y: 0.5),
        endPoint: UnitPoint(x: 0.362, y: 0.5)
    )
}

extension ProfileV3Theme.Palette {
    static let inkText = Color(hex: "0B0B0B")
    static let inkGlyph = Color(hex: "323232")
}

extension ProfileV3Theme.Opacity {
    static let sectionTag: Double = 0.5
    static let accessGlowFill: Double = 0.4
    static let accessGlow: Double = 0.5
    static let shieldFill: Double = 0.2
    static let shieldShadow: Double = 0.06
    static let accessSubtitle: Double = 0.5
}
