import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum InstagramConnect {
        static let sheetHeight: CGFloat = 684
        static let wash: CGFloat = 557
        static let washCentreY: CGFloat = 510.5
        static let followWashTop: CGFloat = 453
        static let followWashHeight: CGFloat = 399
        static let cardsTop: CGFloat = 48
        static let cardSpacing: CGFloat = 24
        static let cardHeight: CGFloat = 109
        static let cardRadius: CGFloat = 32
        static let cardLeading: CGFloat = 31
        static let handleTrailing: CGFloat = 23
        static let orbTrailing: CGFloat = 21
        static let followTrailing: CGFloat = 12
        static let handleArtWidth: CGFloat = 84
        static let orbArtWidth: CGFloat = 61
        static let followArtWidth: CGFloat = 68
        static let cardTextSpacing: CGFloat = 6
        static let cardTitleMinScale: CGFloat = 0.8
        static let followDetailWidth: CGFloat = 260
        static let handleSpacing: CGFloat = 5
        static let handleTilt: Double = 14.86
        static let handlePadding: CGFloat = 9.5
        static let handleHeight: CGFloat = 29
        static let cardOrb: CGFloat = 52
        static let cardOrbTilt: Double = 11.05
        static let orbMarkRatio: CGFloat = 0.587
        static let followSpacing: CGFloat = 10.5
        static let followWidth: CGFloat = 68
        static let followHeight: CGFloat = 22.4
        static let followRadius: CGFloat = 6.7
        static let followFontSize: CGFloat = 9
        static let hiWidth: CGFloat = 48
        static let hiHeight: CGFloat = 26.7
        static let hiFontSize: CGFloat = 10.7
        static let hiTailLarge: CGFloat = 15.1
        static let hiTailSmall: CGFloat = 6.2
        static let hiTailLargeOffset = CGSize(width: 25.8, height: 17.3)
        static let hiTailSmallOffset = CGSize(width: 19.6, height: 30.2)
        static let noteToBar: CGFloat = 16
        static let redirectFieldTop: CGFloat = 46
        static let redirectOrb: CGFloat = 65
        static let redirectOrbTop: CGFloat = 78
        static let redirectLeadTop: CGFloat = 35
        static let redirectTitleTop: CGFloat = 6
        static let redirectingBottom: CGFloat = 36
    }
}

extension ProfileV3Theme.Palette {
    static let instagramFollow = Color(hex: "455EFF")
    static let instagramHi = Color(hex: "6A3DF1")
    static let aylOrbMark = Color(at: .pureWhite)
}

extension ProfileV3Theme.Opacity {
    static let instagramLead: Double = 0.5
    static let instagramRedirecting: Double = 0.8
}

extension ProfileV3Theme {
    static let instagramCardGradient = LinearGradient(
        colors: [Color(at: .pureWhite), Color(at: .pureWhite).opacity(0.7)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let instagramHandleGradient = LinearGradient(
        stops: [
            .init(color: Color(hex: "334158"), location: 0.368),
            .init(color: Color(hex: "0C0F14"), location: 0.949)
        ],
        startPoint: .topTrailing,
        endPoint: .bottomLeading
    )

    static let aylOrbGradient = LinearGradient(
        stops: [
            .init(color: Color(hex: "D8FB71"), location: 0.137),
            .init(color: Color(hex: "ACC85A"), location: 0.381),
            .init(color: Color(hex: "42620F"), location: 0.728)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let instagramFollowWash = LinearGradient(
        stops: [
            .init(color: Color(hex: "D8FB71").opacity(0), location: 0.05),
            .init(color: Color(hex: "ACC85A"), location: 0.67),
            .init(color: Color(hex: "587F1B"), location: 0.97)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
