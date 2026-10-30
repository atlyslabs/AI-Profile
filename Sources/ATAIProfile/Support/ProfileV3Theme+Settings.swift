import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    static let sheetGrabberTop = ProfileV3Theme.Space.s8
    static let sheetHeaderTop = ProfileV3Theme.Space.s20
    static let sheetHeaderIconTop: CGFloat = 9
    static let sheetTitleOnlyTop = ProfileV3Theme.Space.s28
    static let sheetHeaderIconSpacing = ProfileV3Theme.Space.s16
    static let settingsSheetBottom = ProfileV3Theme.Space.s16
    static let pickerDividerInset = ProfileV3Theme.Space.s40
    static let pickerConfirmTop = ProfileV3Theme.Space.s40
    static let ctaBarBottom = ProfileV3Theme.Space.s16
    static let sheetMeasureTolerance: CGFloat = 0.5
    static let deleteReasonTitleTop: CGFloat = 77
    static let deleteReasonFieldTop: CGFloat = 45
    static let deleteReasonFieldHeight: CGFloat = 116
    static let deleteReasonFieldPadding = ProfileV3Theme.Space.s10
    static let deleteReasonEditorInset: CGFloat = 5
    static let deleteReasonCTABottom = ProfileV3Theme.Space.s24
    static let insightActionSpacing = ProfileV3Theme.Space.s12

    enum Accounts {
        static let badgeHeight: CGFloat = 22
        static let conciergeHeight: CGFloat = 52
        static let titleSpacing = ProfileV3Theme.Space.s14
        static let subtitleSpacing = ProfileV3Theme.Space.s6
        static let rowSpacing = ProfileV3Theme.Space.s4
        static let rowsInset = ProfileV3Theme.Space.s20
        static let rowsBottom = ProfileV3Theme.Space.s24
    }

    enum Confirmation {
        static let top: CGFloat = 70
        static let iconCircle: CGFloat = 40
        static let iconSpacing: CGFloat = 46
        static let textSpacing = ProfileV3Theme.Space.s12
        static let titleWidth: CGFloat = 295
        static let bodyWidth: CGFloat = 271
        static let buttonsTop: CGFloat = 64
        static let buttonSpacing = ProfileV3Theme.Space.s16
        static let plainTop = 150 - ProfileV3Theme.Sizes.sheetGrabberTop - ProfileV3Theme.Sizes.sheetGrabberHeight
        static let plainButtonsTop: CGFloat = 39
    }

    enum ConnectorDeck {
        static let glowCanvas = CGSize(width: 274, height: 328.5)
        static let deckTop: CGFloat = 146
        static let cardWidth: CGFloat = 360
        static let cardHeight: CGFloat = 611
        static let cardSpacing = ProfileV3Theme.Space.s20
        static let badge: CGFloat = 80
        static let badgeTop: CGFloat = 89
        static let badgeSink: CGFloat = 60
        static let badgeFloatDrop: CGFloat = 75
        static let badgePairedDrop: CGFloat = 217
        static let badgePairX: CGFloat = 70
        static let atlysMark: CGFloat = 30
        static let linkWidth: CGFloat = 29
        static let linkHeight: CGFloat = 2
        static let warningTop: CGFloat = 242
        static let warningWidth: CGFloat = 292
        static let disconnectBottom: CGFloat = 34
        static let logo: CGFloat = 36
        static let emailTop: CGFloat = 196
        static let glowWidth: CGFloat = 274
        static let glowTop: CGFloat = 168
        static let titleTop: CGFloat = 300
        static let bodyTop: CGFloat = 339
        static let bodyWidth: CGFloat = 223
        static let podiumTop: CGFloat = 471
        static let podiumWidth: CGFloat = 289
        static let podiumRim: CGFloat = 30
        static let podiumInnerWidth: CGFloat = 274
        static let podiumInnerRim: CGFloat = 23
        static let podiumInnerTop: CGFloat = 3
        static let podiumBodyHeight: CGFloat = 105
        static let hintTop: CGFloat = 540
        static let glowOverhang: CGFloat = 11
        static let wellHeight: CGFloat = 731
        static let podiumUnderTop: CGFloat = -581
        static let underGlowHeight: CGFloat = 300
        static let secondPodiumTop: CGFloat = 520
        static let headerIconTop = ProfileV3Theme.Space.s40
        static let headerTitleTop: CGFloat = 80
        static let bottomFade: CGFloat = 124
    }

    enum Contact {
        static let helperTop = ProfileV3Theme.Space.s14
        static let helperWidth: CGFloat = 270
        static let fieldsTop: CGFloat = 80
        static let fieldSpacing: CGFloat = 44
        static let labelSpacing = ProfileV3Theme.Space.s8
        static let dialSpacing = ProfileV3Theme.Space.s6
        static let dialFlag: CGFloat = 16
    }

    enum Disconnect {
        static let logo: CGFloat = 56
        static let titleTop: CGFloat = 11
        static let lossesTop: CGFloat = 37
        static let lossSpacing: CGFloat = 17
        static let termsTop: CGFloat = 36
        static let termsInset = ProfileV3Theme.Space.s40
        static let termsSpacing = ProfileV3Theme.Space.s16
        static let barTop = ProfileV3Theme.Space.s24
        static let topInset: CGFloat = 73
        static let lossesInset = ProfileV3Theme.Space.s40
        static let consentTop = ProfileV3Theme.Space.s32
        static let consentSpacing = ProfileV3Theme.Space.s8
        static let consentBox: CGFloat = 24
        static let scrollBottom = ProfileV3Theme.Space.s16
        static let backTop = ProfileV3Theme.Space.s10
        static let footerSpacing = ProfileV3Theme.Space.s16
    }

    enum Passport {
        static let sectionTop = ProfileV3Theme.Space.s28
        static let controlSpacing = ProfileV3Theme.Space.s20
        static let cardWidth: CGFloat = 380
        static let cardHeight: CGFloat = 292
        static let pageSpacing: CGFloat = 13
        static let pageLabelSpacing = ProfileV3Theme.Space.s10
        static let backTop: CGFloat = 21
        static let backLeading = ProfileV3Theme.Space.s24
        static let backTrailing: CGFloat = 26
        static let backRowSpacing: CGFloat = 13
        static let backLineSpacing: CGFloat = 2
        static let backLabelHeight: CGFloat = 14
        static let backValueHeight: CGFloat = 16
        static let backValueToDivider: CGFloat = 7
        static let backShadeEnd: CGFloat = 0.18151
        static let glowTop: CGFloat = 64
        static let glowHeight: CGFloat = 177
        static let stripHeight: CGFloat = 46
        static let stripSpacing = ProfileV3Theme.Space.s10
        static let guillocheSize: CGFloat = 162
        static let guillocheOrigin = CGPoint(x: 25, y: -108)
        static let pageEdgeHeight: CGFloat = 7
        static let pageEdgeDrop: CGFloat = 8
        static let upperPageEdge = EdgeInsets(top: 289, leading: 10, bottom: 0, trailing: 6)
        static let lowerPageEdge = EdgeInsets(top: 293, leading: 19, bottom: 0, trailing: 15)
        static let contentInset: CGFloat = 36
        static let nameTop: CGFloat = 70
        static let emptyNameTop: CGFloat = 72
        static let fieldsTop: CGFloat = 113
        static let labelSpacing = ProfileV3Theme.Space.s12
        static let datesTop = ProfileV3Theme.Space.s24
        static let dateSpacing: CGFloat = 44
        static let badgeWidth: CGFloat = 81
        static let badgeHeight: CGFloat = 32
        static let badgeTrailing = ProfileV3Theme.Space.s22
        static let badgeTop: CGFloat = 69
        static let promptTop: CGFloat = 105.5
        static let promptSpacing = ProfileV3Theme.Space.s20
        static let promptTitleSpacing: CGFloat = 9
        static let promptTitleWidth: CGFloat = 253
        static let promptTitleLineHeight: CGFloat = 26
        static let promptWidth: CGFloat = 223
        static let promptButtonPadding = ProfileV3Theme.Space.s24
        static let headerTop = ProfileV3Theme.Space.s10
        static let stepTop = ProfileV3Theme.Space.s10
        static let listTop = ProfileV3Theme.Space.s40
        static let listSpacing = ProfileV3Theme.Space.s30
        static let listBottom = ProfileV3Theme.Space.s40
        static let reasonTitleWidth: CGFloat = 234
        static let reasonTitleTop = ProfileV3Theme.Space.s30
        static let howUsedTop = ProfileV3Theme.Space.s24
        static let reasonCardTop: CGFloat = 96
        static let reasonCardPadding = ProfileV3Theme.Space.s30
        static let reasonPromptTop: CGFloat = 15
        static let reasonPromptWidth: CGFloat = 248
        static let reasonDividerTop: CGFloat = 25
        static let reasonRowSpacing: CGFloat = 15
        static let reasonRowInset: CGFloat = 35
    }

    enum Progress {
        static let linkTop = 67 - ProfileV3Theme.Sizes.sheetGrabberTop - ProfileV3Theme.Sizes.sheetGrabberHeight
        static let titleTop: CGFloat = 31
        static let bodyTop = ProfileV3Theme.Space.s12
        static let bodyWidth: CGFloat = 271
        static let atlysMark: CGFloat = 30
        static let gmailMark: CGFloat = 56
        static let linkWidth: CGFloat = 152
        static let linkHeight: CGFloat = 24
        static let linkLeading: CGFloat = 11
        static let linkTrailing = ProfileV3Theme.Space.s4
        static let stopTop: CGFloat = 49
    }

    enum Terms {
        static let horizontalMargin: CGFloat = 25
        static let backTop = ProfileV3Theme.Space.s8
        static let wordmarkTop = ProfileV3Theme.Space.s24
        static let wordmarkWidth: CGFloat = 54
        static let wordmarkHeight: CGFloat = 22
        static let titleTop: CGFloat = 2
        static let dividerTop: CGFloat = 19
        static let contentTop: CGFloat = 26
        static let contentBottom = ProfileV3Theme.Space.s40
        static let sectionSpacing = ProfileV3Theme.Space.s32
        static let blockSpacing = ProfileV3Theme.Space.s24
        static let paragraphSpacing = ProfileV3Theme.Space.s8
    }
}

extension ProfileV3Theme.Palette {
    static let passportCard = Color(hex: "F6F7F7")
    static let passportStripDivider = Color(hex: "C0C4C3").opacity(0.2)
    static let passportPageEdgeShade = Color(at: .pureBlack).opacity(0.2)
    static let passportPageEdgeShadeEnd = Color(at: .neutralGrey600).opacity(0)
    static let passportGlowUpload = Color(hex: "FFD9EE")
    static let passportGlowActive = Color(hex: "D9FAFF").opacity(0.8)
    static let passportGlowExpired = Color(hex: "E4E4E4").opacity(0.8)
    static let passportBadgeActive = Color(at: .actionApprovedLimeGreen400)
    static let passportBadgeExpiredText = Color(hex: "FCFDFD")
    static let passportPromptTitle = Color(at: .neutralGrey700)
    static let confirmTitle = Color(at: .neutralGrey800)
    static let confirmBody = Color(at: .semanticTextSecondary)
    static let connectorCardShadow = Color(at: .pureBlack).opacity(0.06)
    static let destructive = Color(at: .accentRed500)
    static let destructiveGlyph = Color(at: .accentRed700)
    static let destructiveSoft = Color(at: .accentRed50)
    static let neutralSoft = Color(at: .neutralGrey50)
    static let disabledText = Color(at: .neutralGrey200)
    static let reasonBorder = Color(at: .neutralGrey400)
}

extension ProfileV3Theme.Motion {
    static let searchFocusDelayMilliseconds = 400
    static let disconnectEnter: Animation = .easeInOut(duration: 0.42)
    static let connectorDeckSubmergeDuration: Double = 0.7
    static let connectorDeckSubmerge: Animation = .easeInOut(duration: connectorDeckSubmergeDuration)
    static let connectorDeckEmergeDuration: Double = 1
    static let connectorDeckEmerge: Animation = .easeOut(duration: connectorDeckEmergeDuration)
    static let connectorDeckDimDuration: Double = 1.6
    static let connectorDeckDim: Animation = .easeInOut(duration: connectorDeckDimDuration)
    static let connectorDeckSlideDuration: Double = 0.7
    static let connectorDeckSlide: Animation = .easeInOut(duration: connectorDeckSlideDuration)
    static let connectorDeckAbsorb: Animation = .easeIn(duration: 0.45)
    static let connectorDeckRiseDuration: Double = 2.5
    static let connectorDeckRise: Animation = .easeInOut(duration: connectorDeckRiseDuration)
    static let connectorDeckRiseGap: Double = 0.15
    static let connectorDeckSubmergeGap: Double = 0.2
    static let connectorDeckEmergeGap: Double = 0.3
    static let connectorDeckDimGap: Double = 0.2
    static let disconnectEnterRise: CGFloat = 24
    static let consentReveal: Animation = .easeInOut(duration: 0.34)
    static let progressPanel: Animation = .easeInOut(duration: 0.5)
    static let progressBreath: Animation = .easeInOut(duration: 0.8)
    static let progressBreathLow: Double = 0.45
}

extension ProfileV3Theme.Shadow {
    static let connectorCardRadius: CGFloat = 7.5
    static let connectorCardY: CGFloat = 5
}

extension ProfileV3Theme {
    static let connectorDeckGlow = LinearGradient(
        stops: [
            .init(color: ProfileV3Theme.Palette.rainbowIndigo.opacity(0), location: 0.107),
            .init(color: ProfileV3Theme.Palette.rainbowCoral.opacity(0.8), location: 0.745),
            .init(color: ProfileV3Theme.Palette.rainbowGold.opacity(0.8), location: 0.926)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let connectorDeckBadge = LinearGradient(
        colors: [Color(at: .pureWhite), Color(hex: "999999")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let connectorDeckPodiumMouth = LinearGradient(
        colors: [ProfileV3Theme.Palette.whiteSmoke, Palette.connectorMouthDark],
        startPoint: .top,
        endPoint: .bottom
    )

    static let connectorDeckPodiumBody = LinearGradient(
        colors: [Color(hex: "737373").opacity(0.4), Color(hex: "D9D9D9").opacity(0)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let connectorDeckWellBody = LinearGradient(
        stops: [
            .init(color: Color(hex: "737373").opacity(0.4), location: 0),
            .init(color: Color(hex: "D9D9D9").opacity(0), location: 0.25),
            .init(color: Color(hex: "D9D9D9").opacity(0), location: 0.75),
            .init(color: Color(hex: "737373").opacity(0.4), location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let connectorDeckPodiumSheen = LinearGradient(
        stops: [
            .init(color: Palette.connectorSheen.opacity(0), location: 0),
            .init(color: Palette.connectorSheen.opacity(0.2), location: 0.343),
            .init(color: Color(at: .neutralGrey600).opacity(0), location: 1)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let connectorDeckBodyText = LinearGradient(
        colors: [Color(at: .pureWhite), Color(hex: "EAEAEA").opacity(0.6)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let connectorDeckUnderGlow = LinearGradient(
        stops: [
            .init(color: ProfileV3Theme.Palette.rainbowGold, location: 0),
            .init(color: ProfileV3Theme.Palette.rainbowCoral, location: 0.25),
            .init(color: ProfileV3Theme.Palette.rainbowIndigo.opacity(0), location: 0.9)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let passportScreenGradient = LinearGradient(
        colors: [Palette.background, Color(at: .pureWhite)],
        startPoint: .top,
        endPoint: .bottom
    )

}
