import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum CustomRules {
        static let note = CGSize(width: 320, height: 308)
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
        static let backTilt: Double = -4.15
        static let noteTop: CGFloat = 102
        static let pillTop: CGFloat = 64
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
        static let dropLift: CGFloat = -7
        static let dropMid: CGFloat = 70
        static let dropFall: CGFloat = 455
        static let dropLeanBack: Double = -0.4
        static let dropTiltMid: Double = 1.95
        static let dropTilt: Double = 3.9
        static let glowRadius: CGFloat = 196
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
    static let ruleGlowCentre = Color(red: 77 / 255, green: 217 / 255, blue: 112 / 255).opacity(0.26)
    static let ruleGlowMid = Color(red: 92 / 255, green: 222 / 255, blue: 122 / 255).opacity(0.13)
    static let ruleGlowEdge = Color(red: 122 / 255, green: 229 / 255, blue: 143 / 255).opacity(0)
}

extension ProfileV3Theme.Opacity {
    static let ruleBackNote: Double = 0.5
    static let ruleGlowPeak: Double = 0.65
    static let ruleBackdrop: Double = 0.6
    static let rulePillShadow: Double = 0.05
}

extension ProfileV3Theme.Motion {
    static let customRuleGlowIn: Double = 0.55
    static let customRuleGlowOut: Double = 0.57
    static let customRuleHold: Double = 1.18
    static let customRuleLift: Double = 0.18
    static let customRuleFallStart: Double = 0.30
    static let customRuleFallEnd: Double = 0.46
    static let customRuleDropSeconds: Double = 2.2
    static let customRuleEditor = Animation.easeInOut(duration: 0.25)
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

    static let ruleGlow = RadialGradient(
        stops: [
            .init(color: Palette.ruleGlowCentre, location: 0),
            .init(color: Palette.ruleGlowMid, location: 0.42),
            .init(color: Palette.ruleGlowEdge, location: 1),
        ],
        center: .center,
        startRadius: 0,
        endRadius: Sizes.CustomRules.glowRadius
    )
}
