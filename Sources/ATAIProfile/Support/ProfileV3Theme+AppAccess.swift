import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum AppAccess {
        static let listTop: CGFloat = 44
        static let listBottom: CGFloat = 120
        static let hintTop: CGFloat = 53
        static let hintTrailing = ProfileV3Theme.Space.s28
        static let hint = CGSize(width: 145, height: 62.4884)
        static let hintPointer: CGFloat = 6.4884
        static let hintTipRun: CGFloat = 3.0713
        static let hintPointerOffset: CGFloat = 5.5
        static let hintTextTop: CGFloat = 19
        static let hintTextWidth: CGFloat = 116
        static let hintShadowRadius: CGFloat = 6
        static let hintShadowY: CGFloat = 8
    }

    enum AppCredentials {
        static let shield = CGSize(width: 76.6244, height: 95.7805)
        static let shieldTop: CGFloat = 49
        static let shieldStroke: CGFloat = 2
        static let glyph: CGFloat = 32
        static let glyphTop = ProfileV3Theme.Space.s32
        static let titleTop: CGFloat = 23
        static let titleWidth: CGFloat = 219
        static let fieldsTop: CGFloat = 58
        static let fieldSpacing: CGFloat = 59
        static let fieldGap = ProfileV3Theme.Space.s12
        static let accessory: CGFloat = 20
        static let noteTop: CGFloat = 57
        static let passwordNoteTop: CGFloat = 127
        static let noteWidth: CGFloat = 296
        static let barTop: CGFloat = 33
        static let editFieldsTop: CGFloat = 134
        static let deleteDividerTop: CGFloat = 164
        static let deleteRowTop = ProfileV3Theme.Space.s20
        static let deleteIcon: CGFloat = 15
        static let editBottom: CGFloat = 49
    }

    enum CredentialStore {
        static let cardTop: CGFloat = 5
        static let cardHeight: CGFloat = 122
        static let cardRadius = ProfileV3Theme.Radius.xxl
        static let cardTextLeading: CGFloat = 26
        static let cardTitleTop: CGFloat = 26
        static let cardBlurbTop = ProfileV3Theme.Space.s18
        static let cardBlurbWidth: CGFloat = 108.7222
        static let cardInsetShadow: CGFloat = 2.368
        static let cardArt = CGSize(width: 144, height: 119)
        static let cardArtFade: CGFloat = 16
        static let lockBox = CGSize(width: 57.1677, height: 47.4789)
        static let lock = CGSize(width: 53.511, height: 42.809)
        static let lockOffset = CGSize(width: 9.6792, height: 25.0034)
        static let lockRotation: Double = -5.2
        static let subtitleTop: CGFloat = 17
        static let rowsTop: CGFloat = 67
        static let rowHeight: CGFloat = 86
        static let rowSpacing = ProfileV3Theme.Space.s18
        static let rowRadius = ProfileV3Theme.Radius.xxl
        static let rowLeading: CGFloat = 29
        static let rowIcon: CGFloat = 20
        static let rowTextGap: CGFloat = 17
        static let rowTrailing: CGFloat = 26
        static let listBottom: CGFloat = 54
        static let pickerSearchTop = ProfileV3Theme.Space.s24
        static let pickerRowsTop = ProfileV3Theme.Space.s32
    }
}

extension ProfileV3Theme.Sizes.Confirmation {
    static let subjectTop = 60 - ProfileV3Theme.Sizes.sheetGrabberTop - ProfileV3Theme.Sizes.sheetGrabberHeight
    static let subjectIconSpacing: CGFloat = 26
    static let subjectWidth: CGFloat = 317
    static let subjectButtonsTop = ProfileV3Theme.Space.s40
}

extension ProfileV3Theme.Sizes.ConnectorDeck {
    static let appLogo: CGFloat = 56
    static let appTitleTop: CGFloat = 230
    static let appBodyTop: CGFloat = 269
    static let editTop: CGFloat = 397
    static let editLeading = ProfileV3Theme.Space.s12
    static let editTrailing = ProfileV3Theme.Space.s18
    static let editVertical: CGFloat = 5
    static let editGlyph: CGFloat = 16
}

extension ProfileV3Theme.Palette {
    static let appHintStart = Color(hex: "555555")
    static let appHintEnd = Color(hex: "020202")
    static let appHintShadow = Color.black.opacity(0.12)
    static let deckEditPill = Color.black.opacity(0.4)
    static let credentialCardStart = Color(hex: "3A3937")
    static let credentialCardEnd = Color(hex: "8D9295")
    static let credentialShieldEnd = Color(hex: "C8D0D5")
}

extension ProfileV3Theme.Opacity {
    static let appShieldStroke: Double = 0.1
    static let appCredentialsNote: Double = 0.4
    static let credentialCardBlurb: Double = 0.7
    static let credentialCardInsetShadow: Double = 0.8
    static let credentialSheetShield: Double = 0.3
    static let credentialDeleteSubject: Double = 0.5
}

extension ProfileV3Theme {
    static let appHintGradient = LinearGradient(
        colors: [Palette.appHintStart, Palette.appHintEnd],
        startPoint: UnitPoint(x: 0.4276, y: 1.2387),
        endPoint: UnitPoint(x: 0.8103, y: -0.1216)
    )

    static let credentialCardGradient = LinearGradient(
        stops: [
            .init(color: Palette.credentialCardStart, location: 0.0083),
            .init(color: Palette.credentialCardEnd, location: 1),
        ],
        startPoint: UnitPoint(x: 0.7829, y: -0.5615),
        endPoint: UnitPoint(x: 0.2171, y: 1.5615)
    )

    static let credentialShieldGradient = LinearGradient(
        colors: [ProfileV3Theme.Palette.credentialCardStart, Palette.credentialShieldEnd],
        startPoint: UnitPoint(x: 1, y: -0.0297),
        endPoint: UnitPoint(x: -0.2761, y: 0.2861)
    )
}
