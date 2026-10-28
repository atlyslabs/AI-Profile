import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum CustomRules {
        static let note = CGSize(width: 320, height: 308)
        static let noteMinHeight: CGFloat = 192
        static let noteRadius: CGFloat = 20
        static let noteBevelInset: CGFloat = 13
        static let noteLabelLeading: CGFloat = 30
        static let noteLabelTop: CGFloat = 24
        static let noteLabelSize: CGFloat = 14
        static let noteLabelTracking: CGFloat = -0.56
        static let noteTextLeading: CGFloat = 31
        static let noteTextTop: CGFloat = 62
        static let noteTextWidth: CGFloat = 247
        static let noteTextBottom: CGFloat = 70
        static let watermark = CGSize(width: 103.98, height: 86.354)
        static let watermarkCentreOffset = CGSize(width: 106.99, height: 106.18)
        static let watermarkInset = CGSize(
            width: note.width / 2 - watermarkCentreOffset.width - watermark.width / 2,
            height: note.height / 2 - watermarkCentreOffset.height - watermark.height / 2
        )
        static let backTilt: Double = -4.15
        static let noteTop: CGFloat = 102
        static let noteMinTop = ProfileV3Theme.Space.s24
        static let pillTop: CGFloat = 64
        static let pillMinTop = ProfileV3Theme.Space.s24
        static let pillMinBottom = ProfileV3Theme.Space.s16
        static let pillHeight: CGFloat = 40
        static let pillMinWidth: CGFloat = 149
        static let pillHorizontal = ProfileV3Theme.Space.s24
        static let pillShadowRadius: CGFloat = 7.5
        static let pillShadowY: CGFloat = 4
        static let trash: CGFloat = 50
        static let trashInset: CGFloat = 13
        static let trashFromCorner: CGFloat = 10
        static let card = CGSize(width: 202, height: 170)
        static let cardRadius: CGFloat = 32
        static let cardBevelInset: CGFloat = 9
        static let cardBevelRadius: CGFloat = 24
        static let cardTextLeading = ProfileV3Theme.Space.s24
        static let cardTextTop: CGFloat = 26
        static let cardTextWidth: CGFloat = 154
        static let cardTextLines = 5
        static let cardSpacing: CGFloat = 17
        static let cardsTop: CGFloat = 30
        static let customPillHeight: CGFloat = 48
        static let customPillLeading: CGFloat = 14.4
        static let customPillTrailing = ProfileV3Theme.Space.s24
        static let customPillGap: CGFloat = 5.6
        static let customPillIcon = ProfileV3Theme.Icon.xl
    }
}

extension ProfileV3Theme.Palette {
    static let ruleNoteTop = Color(hex: "FFF9ED")
    static let ruleNoteBottom = Color(hex: "D8D0BC")
    static let ruleNoteBackTop = Color(hex: "F4EDDE")
    static let ruleNoteLabel = Color(hex: "A09886")
    static let ruleNoteText = Color(hex: "1C1B1F")
    static let ruleWatermarkTop = Color(hex: "E3DCCA")
    static let ruleWatermarkBottom = Color(hex: "D9D1BD")
    static let rulePill = Color(hex: "1C1B1F")
    static let ruleTrash = Color(hex: "523600")
    static let ruleTrashBorder = Color(hex: "DFDFDF")
}

extension ProfileV3Theme.Opacity {
    static let ruleBackNote: Double = 0.5
    static let ruleBackdrop: Double = 0.6
    static let rulePillShadow: Double = 0.05
}

extension ProfileV3Theme.Motion {
    static let customRuleEditor = Animation.easeInOut(duration: 0.25)
    static let customRuleReveal = Animation.easeInOut(duration: 0.4)
}

extension ProfileV3Theme {
    static let ruleNoteGradient = LinearGradient(
        colors: [Palette.ruleNoteTop, Palette.ruleNoteBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    static let ruleNoteBackGradient = LinearGradient(
        colors: [Palette.ruleNoteBackTop, Palette.ruleNoteBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    static let ruleNoteBevel = LinearGradient(
        colors: [Palette.ruleNoteBackTop.opacity(0), Palette.ruleNoteBottom],
        startPoint: .top,
        endPoint: .bottom
    )
}
