import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum Invite {
        static let cardWidth: CGFloat = 330
        static let cardHeight: CGFloat = 197
        static let cardRadius = ProfileV3Theme.Radius.xl
        static let subtitleTop: CGFloat = 7
        static let cardTop: CGFloat = 54
        static let cardShadowRadius: CGFloat = 12
        static let cardShadowY: CGFloat = 8

        static let foilCore = CGSize(width: 260, height: 395)
        static let foilBox = CGSize(width: 395, height: 260)
        static let foilOrigin = CGPoint(x: -34, y: -32)
        static let foilRadius = ProfileV3Theme.Radius.lg

        static let codeSize: CGFloat = 32
        static let codeTracking: CGFloat = 0
        static let codeMinScale: CGFloat = 0.6
        static let codeTop: CGFloat = 50
        static let codeCaptionSpacing = ProfileV3Theme.Space.s6
        static let countLeading = ProfileV3Theme.Space.s16
        static let countBottom: CGFloat = 18

        static let pip: CGFloat = 24
        static let pipSpacing: CGFloat = 7.273
        static let pipTrailing: CGFloat = 19
        static let pipStroke: CGFloat = 1.091
        static let pipDash: [CGFloat] = [1.2, 1.8]
        static let pipCheck: CGFloat = 12.364

        static let ctaTop: CGFloat = 62
    }
}

extension ProfileV3Theme.Palette {
    static let inviteFoilWash = Color(hex: "E5F4E4").opacity(0.33)
    static let inviteFoilLift = Color(at: .pureWhite).opacity(0.2)
    static let invitePipRing = Color(hex: "1C1F21")
    static let inviteCaption = Color(hex: "586464")
}
