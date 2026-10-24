import SwiftUI

extension ProfileV3Theme.Sizes {
    enum Agent {
        static let orb: CGFloat = 42
        static let orbLarge: CGFloat = 72
        static let glowEndRadius: CGFloat = 170
        static let glowCentre = UnitPoint(x: 0.5, y: 1.15)
        static let cardPaddingTop: CGFloat = 20
        static let cardPaddingLeading: CGFloat = 24
        static let cardPaddingTrailing: CGFloat = 20
        static let cardPaddingBottom: CGFloat = 28
        static let summaryLineLimit = 3
        static let sheetCornerRadius: CGFloat = 44
        static let sheetGrabberWidth: CGFloat = 24
        static let backTop: CGFloat = 30
        static let tagTop = ProfileV3Theme.Space.s40
        static let tagLineHeight: CGFloat = 14
        static let orbTop: CGFloat = 73
        static let stickyBarHeight: CGFloat = 90
        static let stickyFadeHeight: CGFloat = 61
        static let stickyTagDrop = backTop + ProfileV3Theme.Sizes.circleButton / 2 - tagTop - tagLineHeight / 2
        static let titleWidth: CGFloat = 216
        static let summaryTop = ProfileV3Theme.Space.s24
        static let summaryWidth: CGFloat = 310
    }

    enum Car {
        static let cardWidth: CGFloat = 173
        static let cardHeight: CGFloat = 159
        static let cardSpacing: CGFloat = 15
        static let cornerRadius: CGFloat = 30
        static let nameLeading: CGFloat = 23
        static let nameTop: CGFloat = 24
        static let nameWidth: CGFloat = 127
        static let subtitleTop: CGFloat = 10
        static let subtitleWidth: CGFloat = 381
        static let carouselTop: CGFloat = 19
    }

    enum Baggage {
        static let art = CGSize(width: 180, height: 184)
        static let tileHeight: CGFloat = 184
        static let gridSpacing: CGFloat = 20
        static let cornerRadius: CGFloat = 30
        static let contentInset: CGFloat = 23
        static let titleWidth: CGFloat = 106
        static let titleNudge: CGFloat = 1
        static let detailTop: CGFloat = 13.75
        static let mark: CGFloat = 18
        static let markTrailing: CGFloat = 25
        static let stepperHeight: CGFloat = 48
        static let stepperButton: CGFloat = 24
        static let stepperInset: CGFloat = 14
        static let stepperHitInset: CGFloat = 10
        static let tabHeight: CGFloat = 40
        static let tabInsetHorizontal: CGFloat = 5
        static let tabInsetVertical: CGFloat = 4
        static let tabSpacing: CGFloat = 2
        static let gridTop: CGFloat = 26
        static let maxCount = 9
    }

    enum MedicalCard {
        static let height: CGFloat = 271
        static let compactHeight: CGFloat = 214
        static let padding: CGFloat = 32
        static let flagSpacing: CGFloat = 8
        static let flag: CGFloat = 18
        static let valueLeading: CGFloat = 196
        static let emblem: CGFloat = 109
        static let emblemTop: CGFloat = 23
        static let emblemBleed: CGFloat = 35
        static let emblemFadeWidth: CGFloat = 50
        static let emblemFadeHeight: CGFloat = 73
        static let emblemFadeTop: CGFloat = 55
        static let sheenWidth: CGFloat = 431
        static let sheenHeight: CGFloat = 14
        static let sheenBlur: CGFloat = 17
        static let sheenAngle: Double = 33.43
        static let sheenCentre = CGPoint(x: 218.69, y: 105.55)
    }

    enum Picker {
        static let rowHeight: CGFloat = 60
        static let checkbox: CGFloat = 24
        static let logo: CGFloat = 24
        static let cardWidth: CGFloat = 190
        static let cardHeight: CGFloat = 302
        static let cardSideScale: CGFloat = 170 / 190
        static let cardSpacing: CGFloat = 20
        static let cardNamePadding: CGFloat = 20
        static let nameTop: CGFloat = 20
        static let nameWidth: CGFloat = 142
        static let nameLines = 2
        static let nameHeight: CGFloat = 38
        static let sideNameOpacity: Double = 0.4
        static let sideNameLift = cardHeight / 2 * (1 - cardSideScale)
        static let carouselHeight = cardHeight + nameTop + nameHeight
    }

    enum Save {
        static let barFadeHeight: CGFloat = 110
        static let buttonHeight = ProfileV3Theme.Control.comfortable
        static let buttonIcon = ProfileV3Theme.Icon.xl
        static let buttonLeading = ProfileV3Theme.Space.s14
        static let buttonTrailing = ProfileV3Theme.Space.s24
        static let buttonSpacing = ProfileV3Theme.Space.s6
        static let savedPadding: CGFloat = 42
        static let barBottom = ProfileV3Theme.Space.s16
    }

    enum Pickup {
        static let stageHeight: CGFloat = 330
        static let ring: CGFloat = 206
        static let ringOuter: CGFloat = 290
        static let height: CGFloat = 295
        static let sideWidth: CGFloat = 150
        static let spacing: CGFloat = 60
        static let sideScale: CGFloat = 0.92
        static let nameTop: CGFloat = 20
        static let buttonTop: CGFloat = 32
        static let captionTop: CGFloat = 20
        static let captionWidth: CGFloat = 241
    }

    enum RideRegions {
        static let headingTop: CGFloat = 37
        static let headingWidth: CGFloat = 216
        static let dividerTop = ProfileV3Theme.Space.s40
        static let dividerSpacing = ProfileV3Theme.Space.s40
        static let cardsTop: CGFloat = 37
        static let cardSpacing = ProfileV3Theme.Space.s16
        static let cardInset: CGFloat = 29
        static let cardRadius: CGFloat = 32
        static let fallbackAspect: CGFloat = 1.819
        static let bottom = ProfileV3Theme.Space.s32
    }

    enum Staged {
        static let carTravel: CGFloat = 269
        static let trackWidth: CGFloat = 10
        static let trackImage: CGFloat = 350
        static let trackImageOffset = CGSize(width: -21.5, height: -44)
        static let trackSqueeze: CGFloat = 0.3
        static let trackSpacing: CGFloat = 72
        static let trackRearInset: CGFloat = 86
        static let trackFadeStart: CGFloat = 0.35
        static let fadeSolidHeight: CGFloat = 196
        static let fadeGradientHeight: CGFloat = 100
        static let titleTop: CGFloat = 590
        static let titleWidth: CGFloat = 237
        static var trackOrigin: CGFloat {
            (Pickup.stageHeight - Pickup.height) / 2 + Pickup.height - trackRearInset
        }
    }
}
