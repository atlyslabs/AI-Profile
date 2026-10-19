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
    }
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
}

extension ProfileV3Theme.Opacity {
    static let autoConnectedStatus: Double = 0.6
    static let appShieldStroke: Double = 0.1
    static let appCredentialsNote: Double = 0.4
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
}
