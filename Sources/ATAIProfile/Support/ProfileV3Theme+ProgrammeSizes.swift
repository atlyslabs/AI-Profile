import SwiftUI

extension ProfileV3Theme.Sizes {
    enum AddProgramme {
        static let orb: CGFloat = 48
        static let marketSpacing: CGFloat = 10
        static let marketPadding: CGFloat = 10
        static let marketDividerHeight: CGFloat = 33
        static let marketGap: CGFloat = 20
        static let chipRowInset: CGFloat = 4
        static let ringInner: CGFloat = 90
        static let ringOuter: CGFloat = 109
        static let foundRing: CGFloat = 82
        static let glow: CGFloat = 319
        static let glowBlur: CGFloat = 50
        static let copyWidth: CGFloat = 258
        static let kycCopyWidth: CGFloat = 242
        static let orbToTitle: CGFloat = 24
        static let titleToStatus: CGFloat = 38
        static let sourceOverlap: CGFloat = -3
        static let scanningOffsetY: CGFloat = -18
        static let foundOffsetY: CGFloat = -68
        static let kycOrbToCopy: CGFloat = 190
        static let kycCopyToStatus: CGFloat = 40
        static let kycBottom: CGFloat = 150
        static let cardsTop: CGFloat = 32
        static let fieldsTop: CGFloat = 57
        static let fieldSpacing: CGFloat = 44
    }

    enum Insight {
        static let cardTop: CGFloat = 23
        static let orb: CGFloat = 40
        static let orbRingOuter: CGFloat = 68
        static let orbRingInner: CGFloat = 57
        static let orbOffsetY: CGFloat = -18
        static let bodyWidth: CGFloat = 263
        static let sourcesTop: CGFloat = 36
    }

    enum Programme {
        static let cardHeight: CGFloat = 152
        static let artAspectRatio: CGFloat = 1140 / 720
        static let artLogoInset: CGFloat = 68 / 1140
        static let cardWidths: [CGFloat] = [204, 215, 225]
        static let contentInset: CGFloat = 20
        static let logoTop: CGFloat = 8
        static let logoHeight: CGFloat = 29
        static let logoMaxWidth: CGFloat = 81
        static let numberGap: CGFloat = 3
        static let pointsTop: CGFloat = 16
        static let pointsLabelGap: CGFloat = 3
    }

    enum ProgrammeTile {
        static let insightWidth: CGFloat = 275
        static let pillBottom = ProfileV3Theme.Space.s24
        static let bottomRowReserve = pillBottom + ProfileV3Theme.Control.compact + ProfileV3Theme.Space.s20
        static let pillSpacing: CGFloat = 2
        static let flight: CGFloat = 36
        static let dot: CGFloat = 3
        static let dotPitch: CGFloat = 14
        static let dotRowPitch: CGFloat = 13
        static let backGlowRadius: CGFloat = 242
        static let copyGap: CGFloat = 9
        static let copyHitInset = ProfileV3Theme.Space.s12
        static let tierDividerHeight: CGFloat = 15
    }

    enum Programmes {
        static let tabTop: CGFloat = 86
        static let tabSpacing: CGFloat = 28
        static let listSpacing = ProfileV3Theme.Space.s16
        static let reorderShift: CGFloat = 190
        static let reorderHintLeading: CGFloat = 32
        static let reorderHintTop: CGFloat = 53
        static let reorderHintTextWidth: CGFloat = 166
        static let reorderHintTextTop = ProfileV3Theme.Space.s24
        static let reorderHintButtonTop: CGFloat = 33
        static let headerTop: CGFloat = 35
        static let headerWidth: CGFloat = 253
        static let cardsTop: CGFloat = 65
        static let bottomFade: CGFloat = 164
        static let barBottom = ProfileV3Theme.Space.s16
        static let editButtonWidth: CGFloat = 65
        static let checkboxLeading = ProfileV3Theme.Space.s24
        static let checkboxGap = ProfileV3Theme.Space.s20
        static let deleteSheetRadius: CGFloat = 44
    }
}

extension ProfileV3Theme.Opacity {
    static let programmesDeleteBackdrop: Double = 0.8
}
