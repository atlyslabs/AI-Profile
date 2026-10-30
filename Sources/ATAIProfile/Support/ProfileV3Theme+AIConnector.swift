import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum AIConnector {
        static let cornerRadius: CGFloat = 40
        static let gear: CGFloat = 24
        static let gearTop: CGFloat = 39
        static let eyebrowGap: CGFloat = 16
        static let headerHeight: CGFloat = 93
        static let logo: CGFloat = 80
        static let logoTop: CGFloat = 41
        static let titleTop: CGFloat = 20
        static let titleWidth: CGFloat = 260
        static let subtitleTop: CGFloat = 13
        static let subtitleWidth: CGFloat = 229
        static let benefitsTop: CGFloat = 56
        static let benefitsWidth: CGFloat = 333
        static let benefitSpacing: CGFloat = 32
        static let benefitCheck: CGFloat = 18
        static let benefitCheckTop: CGFloat = 2
        static let benefitGap: CGFloat = 20
        static let benefitTextSpacing: CGFloat = 13
        static let dividerTop: CGFloat = 18
        static let disclaimersTop: CGFloat = 16
        static let disclaimerInset: CGFloat = 40
        static let disclaimerSpacing: CGFloat = 12
        static let ctaHeight: CGFloat = 48
        static let connectLogo: CGFloat = 48
        static let connectLogoTop: CGFloat = 57
        static let dotsGap: CGFloat = 13
        static let dotSmall: CGFloat = 8
        static let dotLarge: CGFloat = 12
        static let dotSpacing: CGFloat = 11
        static let connectTitleTop: CGFloat = 33
        static let stepsTop: CGFloat = 35
        static let stepLeading: CGFloat = 53
        static let timelineX: CGFloat = 32
        static let stepDot: CGFloat = 10
        static let stepLabelHeight: CGFloat = 14
        static let stepTitleTop: CGFloat = 9
        static let stepCardTop: CGFloat = 20
        static let stepSpacing: CGFloat = 44
        static let timelineTail: CGFloat = 71
        static let timelineDash: [CGFloat] = [2, 2]
        static let cardRadius: CGFloat = 40
        static let cardPadding: CGFloat = 28
        static let cardBottom: CGFloat = 24
        static let promptCardHeight: CGFloat = 175
        static let promptFadeTop: CGFloat = 50
        static let promptFadeHeight: CGFloat = 70
        static let promptStripTop: CGFloat = 120
        static let copyTop: CGFloat = 124
        static let copyRadius: CGFloat = 20
        static let copyHorizontal: CGFloat = 18
        static let copyVertical: CGFloat = 10
        static let bodyGap: CGFloat = 16
        static let pasteRadius: CGFloat = 16
        static let pastePadding: CGFloat = 13
        static let pasteMinLines = 3
        static let pasteMaxLines = 12
        static let errorTop: CGFloat = 8
        static let saveTop: CGFloat = 16
        static let wash: CGFloat = 585
        static let washCentreY: CGFloat = 573.5
        static let bottom: CGFloat = 40
        static let revealMargin: CGFloat = 16
    }
}

extension ProfileV3Theme.Typography {
    static let aiConnectorCopySize: CGFloat = 12
    static let aiConnectorCopyTracking: CGFloat = -0.48
    static let aiConnectorCopyLineSpacing: CGFloat = 3.5
    static let aiConnectorStatusMinScale: CGFloat = 0.8
}

extension ProfileV3Theme.Palette {
    static let aiConnectorStrip = Color(hex: "FFFEF9")
    static let aiConnectorBorder = Color(hex: "E0E0E0")
    static let aiConnectorPlaceholder = Color(hex: "999999")
    static let aiConnectorCopyText = Color(hex: "111111")
    static let aiConnectorStepDot = Color(hex: "807F7A")
    static let aiConnectorDots = Color(hex: "D9D9D9")
    static let aiConnectorDivider = Color(at: .pureBlack).opacity(0.2)
}

extension ProfileV3Theme.Opacity {
    static let aiConnectorSubtitle: Double = 0.4
    static let aiConnectorDisclaimer: Double = 0.5
    static let aiConnectorStepLabel: Double = 0.5
    static let aiConnectorWash: Double = 0.2
}

extension ProfileV3Theme {
    static let aiConnectorCardGradient = LinearGradient(
        colors: [Color(at: .pureWhite), Color(at: .pureWhite).opacity(0.6)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let aiConnectorPromptFade = LinearGradient(
        colors: [Palette.aiConnectorStrip.opacity(0), Palette.aiConnectorStrip],
        startPoint: .top,
        endPoint: .bottom
    )
}
