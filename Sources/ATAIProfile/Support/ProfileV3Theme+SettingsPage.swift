import SwiftUI

extension ProfileV3Theme.Sizes {
    static let headerRevealDistance = ProfileV3Theme.Space.s24
    static let headerFadeGap = ProfileV3Theme.Space.s12

    enum SettingsPage {
        static let headerTop: CGFloat = 21
        static let headerBarBottom = ProfileV3Theme.Space.s10
        static let headerFade = ProfileV3Theme.Sizes.Agent.stickyFadeHeight
        static let avatar: CGFloat = 80
        static let avatarTop: CGFloat = 38
        static let avatarLetterOffsetY: CGFloat = -3
        static let uploadTop: CGFloat = 22
        static let uploadHeight: CGFloat = 28
        static let uploadPadding: CGFloat = 15
        static let uploadSpacing: CGFloat = 5
        static let uploadIcon: CGFloat = 18
        static let uploadTitleSize: CGFloat = 12
        static let cardsTop = ProfileV3Theme.Space.s40
        static let cardSpacing = ProfileV3Theme.Space.s24
        static let cardRadius = ProfileV3Theme.Radius.xxxl
        static let surfaceRadius = ProfileV3Theme.Radius.card
        static let cardPadding = ProfileV3Theme.Space.s24
        static let cardIconSpacing = ProfileV3Theme.Space.s16
        static let cardTitleSpacing = ProfileV3Theme.Space.s6
        static let cardHeaderTop = ProfileV3Theme.Space.s24
        static let cardHeaderBottom = ProfileV3Theme.Space.s20
        static let cardHeaderTrailing = ProfileV3Theme.Space.s24
        static let accountsSubtitleWidth: CGFloat = 206
        static let sectionGap = ProfileV3Theme.Space.s32
        static let switchGap = ProfileV3Theme.Space.s24
        static let switchTextSpacing: CGFloat = 5
        static let switchSubtitleWidth: CGFloat = 263
        static let switchToggle: CGFloat = 36
        static let rowsTop = ProfileV3Theme.Space.s20
        static let rowSpacing = ProfileV3Theme.Space.s16
        static let dangerIcon: CGFloat = 18
        static let bottom = ProfileV3Theme.Space.s40
        static let loadStateHeight: CGFloat = 240
        static let connectorsHeaderBottom: CGFloat = 15
        static let accessCardInset = ProfileV3Theme.Space.s24
        static let accessCardSpacing: CGFloat = 15
        static let accessCardHeight: CGFloat = 92
        static let accessCardRadius: CGFloat = 25
        static let accessCardTextLeading: CGFloat = 25
        static let accessCardTitleTop: CGFloat = 20
        static let accessCardSubtitleTop = ProfileV3Theme.Space.s6
        static let accessCardTextWidth: CGFloat = 126
        static let informationArtTop: CGFloat = 17
        static let informationArtSize = CGSize(width: 80, height: 30)
        static let informationArtTrailing: CGFloat = 24
        static let appArtTop: CGFloat = 18
        static let appArtSize = CGSize(width: 74.67, height: 28)
        static let appArtTrailing: CGFloat = 24.3
        static let partnersCardHeight: CGFloat = 116
        static let partnersSubtitleWidth: CGFloat = 159
        static let partnersLogosTop: CGFloat = 21
        static let partnersLogosTrailing: CGFloat = 25
        static let partnersLogos = CGSize(width: 86, height: 73)
        static let partnersLogoSlots: [(origin: CGPoint, size: CGFloat)] = [
            (CGPoint(x: 25, y: 0), 33),
            (CGPoint(x: 55, y: 25), 31),
            (CGPoint(x: 0, y: 28), 28),
            (CGPoint(x: 28, y: 52), 21)
        ]
        static let credentialCardHeight: CGFloat = 107
        static let credentialSubtitleWidth: CGFloat = 165
        static let credentialShield = CGSize(width: 50, height: 63)
        static let credentialShieldTop: CGFloat = 21.9
        static let credentialShieldTrailing: CGFloat = 32
        static let credentialLock = CGSize(width: 38.68, height: 30.95)
        static let credentialLockOffset = CGSize(width: -0.3, height: -1.3)
        static let credentialLockTilt: Double = -5.2
        static let credentialLockOpacity = 0.8
    }

    enum Partners {
        static let titleTop: CGFloat = 28
        static let titleSpacing = ProfileV3Theme.Space.s12
        static let subtitleWidth: CGFloat = 318
        static let headerSolid: CGFloat = 208
        static let headerFade: CGFloat = 98
        static let focusY: CGFloat = 472
        static let listLeading: CGFloat = 30
        static let nameWidth: CGFloat = 186
        static let headlineWidth: CGFloat = 151
        static let focusTextSpacing = ProfileV3Theme.Space.s8
        static let focusBodySpacing = ProfileV3Theme.Space.s16
        static let logoCentreFromTrailing: CGFloat = 110
        static let offsets: [CGFloat] = [0, 158, 274, 363, 440]
        static let logoSizes: [CGFloat] = [132, 85, 57, 44, 32]
        static let logoOpacities: [Double] = [1, 0.8, 0.6, 0.6, 0]
        static let logoBlurs: [CGFloat] = [0, 0, 2, 3, 4]
        static let nameOpacities: [Double] = [1, 0.5, 0.4, 0.3, 0]
        static let rowHeights: [CGFloat] = [170, 91, 63, 50, 38]
        static let dragFollow: CGFloat = 0.5
        static let swipeDistance: CGFloat = 40
        static let swipeStep: CGFloat = 120
        static let maxSwipeSteps = 3
        static let info: CGFloat = 38
        static let infoIcon = ProfileV3Theme.Icon.xl
        static let infoOffset = CGSize(width: 50, height: 48)
        static let infoShadowRadius: CGFloat = 11.7
        static let infoShadowY: CGFloat = 4.675
        static let rippleScale: CGFloat = 1.52
        static let rippleLineWidth: CGFloat = 2
        static let rippleSecondLineWidth: CGFloat = 1.5
        static let rippleEndLineWidth: CGFloat = 0.6
        static let glowRadius: CGFloat = 22
    }

    enum Permissions {
        static let cardsTop: CGFloat = 36
        static let cardSpacing: CGFloat = 43
        static let cardInset: CGFloat = 31
        static let cardRadius = ProfileV3Theme.Radius.xxxl
        static let cardContentSpacing = ProfileV3Theme.Space.s24
        static let tagHeight: CGFloat = 14
        static let questionLineHeight: CGFloat = 19
        static let questionGap = ProfileV3Theme.Space.s24
        static let bottom = ProfileV3Theme.Space.s40
        static let loadStateHeight: CGFloat = 240
    }

    enum SegmentedControl {
        static let height = ProfileV3Theme.Control.comfortable
        static let inset = ProfileV3Theme.Space.s4
        static let segmentPadding = ProfileV3Theme.Space.s16
        static let minimumScale: CGFloat = 0.8
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
        static let chipLogo = ProfileV3Theme.Icon.xl
        static let chipPadding: CGFloat = 2
        static let chipTrailing = ProfileV3Theme.Space.s8
        static let chipGap = ProfileV3Theme.Space.s8
        static let loadStateHeight: CGFloat = 200
        static let bottom = ProfileV3Theme.Space.s40
        static let comingSoonArtTop: CGFloat = 120
        static let comingSoonTitleTop: CGFloat = 60
        static let comingSoonBodyWidth: CGFloat = 240
    }
}

extension ProfileV3Theme {
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
    static let inkText = Color(at: .backgroundDarkTheme)
}

extension ProfileV3Theme.Opacity {
    static let sectionTag: Double = 0.5
    static let segmentIdle: Double = 0.5
    static let accessGlowFill: Double = 0.4
    static let accessGlow: Double = 0.5
    static let shieldFill: Double = 0.2
    static let shieldShadow: Double = 0.06
    static let accessSubtitle: Double = 0.5
}
