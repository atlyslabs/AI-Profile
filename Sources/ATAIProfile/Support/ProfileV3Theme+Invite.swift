import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum Invite {
        static let cardWidth: CGFloat = 330
        static let cardHeight: CGFloat = 197
        static let cardRadius = ProfileV3Theme.Radius.xl
        static let subtitleTop: CGFloat = 7
        static let cardTop: CGFloat = 54

        /// The card art carries its own corners and shadow: its body is 1320x788 inside a
        /// 1416x884 canvas, and the shadow falls downward, so the inset is not symmetric.
        static let cardArtWidthRatio: CGFloat = 1416.0 / 1320.0
        static let cardArtHeightRatio: CGFloat = 884.0 / 788.0
        static let cardArtInsetRatio = CGSize(width: 48.0 / 1320.0, height: 16.0 / 788.0)

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
    static let invitePipRing = Color(hex: "1C1F21")
    static let inviteCaption = Color(hex: "586464")
}
