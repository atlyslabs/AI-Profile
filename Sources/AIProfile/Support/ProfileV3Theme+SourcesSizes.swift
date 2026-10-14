import SwiftUI

extension ProfileV3Theme.Sizes {
    enum Sources {
        static let titleTop: CGFloat = 50
        static let chipsTop: CGFloat = 31
        static let dividerTop: CGFloat = 32
        static let stepsTop: CGFloat = 39
        static let stepGap: CGFloat = 24
        static let tile: CGFloat = 48
        static let tileSpacing: CGFloat = 20
        static let connectorGlyph: CGFloat = 22
        static let textSpacing: CGFloat = 11
        static let textColumnWidth: CGFloat = 240
        static let detailLineSpacing: CGFloat = 2.7
        static let evidenceIcon: CGFloat = 10
        static let evidenceSpacing: CGFloat = 12
        static let bottomPadding: CGFloat = 40
    }

    enum HowUsed {
        static let clusterTop: CGFloat = 20
        static let clusterSize = CGSize(width: 91.92, height: 64.05)
        static let largeOrb: CGFloat = 50
        static let largeOrbOrigin = CGPoint(x: 0, y: 7.14)
        static let mediumOrb: CGFloat = 35
        static let mediumOrbOrigin = CGPoint(x: 56.92, y: 1.25)
        static let smallOrb: CGFloat = 22
        static let smallOrbOrigin = CGPoint(x: 51.92, y: 42.05)
        static let titleTop: CGFloat = 10
        static let sectionGap: CGFloat = 30
        static let tile: CGFloat = 50
        static let tileGlyph: CGFloat = 18
        static let tileSpacing: CGFloat = 20
        static let textSpacing: CGFloat = 12
        static let separatorDash: [CGFloat] = [3, 3]
        static let buttonTop: CGFloat = 40
        static let buttonIcon: CGFloat = 18
        static let buttonSpacing: CGFloat = 4
    }

    enum GlassOrb {
        static let glintWidth: CGFloat = 0.57
        static let glintHeight: CGFloat = 0.85
        static let tiltedGlintHeight: CGFloat = 0.918
        static let topGlintHeight: CGFloat = 0.5
        static let bottomGlintWidth: CGFloat = 0.428
        static let bottomGlintHeight: CGFloat = 0.375
        static let glintFadeStart: CGFloat = 0.05
        static let glintFadeEnd: CGFloat = 0.54
        static let glintBlur: CGFloat = 0.0087
        static let innerShadowWidth: CGFloat = 0.063
        static let innerShadowBlur: CGFloat = 0.031
        static let tilt: Double = -30
    }
}
