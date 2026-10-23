import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum ErrorState {
        static let icon: CGFloat = 24
        static let titleTop: CGFloat = 17.7
        static let subtitleTop: CGFloat = 9.65
        static let subtitleWidth: CGFloat = 207
        static let retryTop: CGFloat = 36.35
        static let retryIcon: CGFloat = 18
        static let retrySpacing: CGFloat = 3
        static let retryHitInset: CGFloat = 12
        static let cardTop: CGFloat = 44
        static let cardHeight: CGFloat = 421
        static let cardContentDrop: CGFloat = 11
        static let cardRadius: CGFloat = 40
        static let rowsTop: CGFloat = 47
    }
}

extension ProfileV3Theme.Palette {
    static let errorStateSubtitle = Color(hex: "787878")
    static let errorStateCardBorder = Color(hex: "E6E7E8")
}

extension ProfileV3Theme {
    static let errorStateTitleGradient = LinearGradient(
        stops: [
            .init(color: Color(at: .pureBlack), location: 0),
            .init(color: Color(hex: "5057EA"), location: 0.33),
            .init(color: Color(hex: "EF4646"), location: 0.66),
            .init(color: Color(hex: "EDD758"), location: 0.99)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}
