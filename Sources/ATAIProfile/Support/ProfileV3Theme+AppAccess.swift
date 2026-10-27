import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum AppAccess {
        static let contentTop: CGFloat = 33
        static let autoCard = CGSize(width: 208, height: 116)
        static let autoCardSpacing = ProfileV3Theme.Space.s20
        static let autoCardLeading: CGFloat = 24
        static let autoCardNameTop: CGFloat = 22
        static let autoCardNameWidth: CGFloat = 107
        static let autoCardLogoTop: CGFloat = 23
        static let autoCardLogoTrailing: CGFloat = 25
        static let autoCardStatusTop: CGFloat = 82
        static let dividerGap: CGFloat = 36
        static let logo: CGFloat = 20
        static let listBottom: CGFloat = 120
        static let hintTop: CGFloat = 53
        static let hintTrailing: CGFloat = 28
        static let hint = CGSize(width: 145, height: 62.4884)
        static let hintPointer: CGFloat = 6.4884
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
        static let glyphTop: CGFloat = 32
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
        static let cornerRadius: CGFloat = 40
        static let editFieldsTop: CGFloat = 134
        static let deleteDividerTop: CGFloat = 164
        static let deleteRowTop: CGFloat = 20
        static let deleteIcon: CGFloat = 15
        static let editBottom: CGFloat = 49
    }

    enum CredentialStore {
        static let cardTop: CGFloat = 5
        static let cardHeight: CGFloat = 122
        static let cardRadius: CGFloat = 30
        static let cardTextLeading: CGFloat = 26
        static let cardTitleTop: CGFloat = 26
        static let cardBlurbTop: CGFloat = 18
        static let cardBlurbWidth: CGFloat = 108.7222
        static let cardInsetShadow: CGFloat = 2.368
        static let cardBigShield = CGSize(width: 130, height: 163)
        static let cardBigShieldTrailing: CGFloat = -6
        static let cardBigShieldTop: CGFloat = -19
        static let cardShield = CGSize(width: 54, height: 67.5)
        static let cardShieldTrailing: CGFloat = 31
        static let cardShieldTop: CGFloat = 27.75
        static let cardLockBox = CGSize(width: 46.7736, height: 38.8463)
        static let cardLock = CGSize(width: 43.781, height: 35.025)
        static let cardLockTrailing: CGFloat = 34.6534
        static let cardLockTop: CGFloat = 40.87
        static let lockBox = CGSize(width: 57.1677, height: 47.4789)
        static let lock = CGSize(width: 53.511, height: 42.809)
        static let lockOffset = CGSize(width: 9.6792, height: 25.0034)
        static let lockRotation: Double = -5.2
        static let subtitleTop: CGFloat = 17
        static let rowsTop: CGFloat = 67
        static let rowHeight: CGFloat = 86
        static let rowSpacing: CGFloat = 18
        static let rowRadius: CGFloat = 30
        static let rowLeading: CGFloat = 29
        static let rowIcon: CGFloat = 20
        static let rowTextGap: CGFloat = 17
        static let rowTrailing: CGFloat = 26
        static let listBottom: CGFloat = 54
        static let pickerSearchTop: CGFloat = 24
        static let pickerRowsTop: CGFloat = 32
    }
}

extension ProfileV3Theme.Sizes.Confirmation {
    static let subjectTop = 60 - ProfileV3Theme.Sizes.sheetGrabberTop - ProfileV3Theme.Sizes.sheetGrabberHeight
    static let subjectIconSpacing: CGFloat = 26
    static let subjectWidth: CGFloat = 317
    static let subjectButtonsTop: CGFloat = 40
}

extension ProfileV3Theme.Sizes.ConnectorDeck {
    static let appLogo: CGFloat = 56
    static let appTitleTop: CGFloat = 230
    static let appBodyTop: CGFloat = 269
    static let editTop: CGFloat = 397
    static let editLeading: CGFloat = 12
    static let editTrailing: CGFloat = 18
    static let editVertical: CGFloat = 5
    static let editGlyph: CGFloat = 16
}

extension ProfileV3Theme.Palette {
    static let autoConnectedStart = Color(hex: "003715")
    static let autoConnectedEnd = Color(hex: "019D3C")
    static let appHintStart = Color(hex: "555555")
    static let appHintEnd = Color(hex: "020202")
    static let appHintShadow = Color.black.opacity(0.12)
    static let deckEditPill = Color.black.opacity(0.4)
    static let credentialCardStart = Color(hex: "3A3937")
    static let credentialCardEnd = Color(hex: "8D9295")
    static let credentialShieldStart = Color(hex: "3A3937")
    static let credentialShieldEnd = Color(hex: "C8D0D5")
}

extension ProfileV3Theme.Opacity {
    static let autoConnectedStatus: Double = 0.6
    static let appShieldStroke: Double = 0.1
    static let appCredentialsNote: Double = 0.4
    static let credentialCardBlurb: Double = 0.7
    static let credentialCardShield: Double = 0.2
    static let credentialCardBigShield: Double = 0.04
    static let credentialCardLock: Double = 0.8
    static let credentialCardInsetShadow: Double = 0.8
    static let credentialSheetShield: Double = 0.3
    static let credentialDeleteSubject: Double = 0.5
}

extension ProfileV3Theme.Motion {
    static let appCredentialsSuccessSeconds: Double = 1.2
}

extension ProfileV3Theme {
    static let autoConnectedGradient = LinearGradient(
        colors: [Palette.autoConnectedStart, Palette.autoConnectedEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

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
        colors: [Palette.credentialShieldStart, Palette.credentialShieldEnd],
        startPoint: UnitPoint(x: 1, y: -0.0297),
        endPoint: UnitPoint(x: -0.2761, y: 0.2861)
    )
}
