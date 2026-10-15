import SwiftUI

extension ProfileV3Theme.Sizes {
    enum KYCRedirect {
        static let cardSize: CGFloat = 182
        static let cardToCopy: CGFloat = 128
        static let copyToStatus: CGFloat = 63
        static let bottom: CGFloat = 180
    }

    enum CitizenshipLock {
        static let lockIcon: CGFloat = 22
        static let flag: CGFloat = 32
        static let flagToCopy: CGFloat = 20
        static let copyWidth: CGFloat = 219
        static let fadeHeight: CGFloat = 613
        static let fadeMidStop: CGFloat = 0.42
        static let bottomFadeHeight: CGFloat = 139
        static let rise: CGFloat = 350
        static let indiaCoverWidth: CGFloat = 182
        static let indiaCoverHeight: CGFloat = 260
        static let indiaCoverGap: CGFloat = 23
        static let indiaCoverOverhang: CGFloat = 37
        static let indiaCoverRadius: CGFloat = 15
        static let genericCoverWidth: CGFloat = 193
        static let genericCoverHeight: CGFloat = 259
        static let genericCoverGap: CGFloat = 10
        static let genericCoverOverhang: CGFloat = 23
    }

    enum BackFace {
        static let plusButton: CGFloat = 32
        static let emptyPlusTop: CGFloat = 47
        static let copyTop: CGFloat = 105
        static let copyWidth: CGFloat = 194
        static let emptyArtHeight: CGFloat = 158
        static let washWidth: CGFloat = 234.48
        static let washHeight: CGFloat = 240
        static let washCentreX: CGFloat = 188.5
        static let washCentreY: CGFloat = 59
        static let washBlur: CGFloat = 36
        static let stackTops: [CGFloat] = [125, 192, 265]
        static let singleStackTops: [CGFloat] = [126, 174, 219]
        static let singleStackWidths: [CGFloat] = [193, 215, 225]
        static let backSlotHeight: CGFloat = 136
        static let fadeHeight: CGFloat = 36
        static let slotDot: CGFloat = 5
    }

    enum Household {
        static let contentTop: CGFloat = 127
        static let plus: CGFloat = 60
        static let plusGlyph: CGFloat = 18
        static let plusStroke: CGFloat = 2
        static let titleTop: CGFloat = 21
        static let subtitleTop: CGFloat = 11
        static let subtitleWidth: CGFloat = 190
        static let dash: [CGFloat] = [2, 2]
        static let shellHeights: [CGFloat] = [Benefit.cardHeight, 144]
        static let shellSpacing = ProfileV3Theme.Space.s20
    }

    enum Benefit {
        static let cardHeight: CGFloat = 154
        static let designWidth = ProfileV3Theme.Canvas.content
        static let textColumnWidth: CGFloat = 211
        static let contentLeading = ProfileV3Theme.Space.s30
        static let contentVertical: CGFloat = 22
        static let contentTop: CGFloat = 23
        static let contentBottom: CGFloat = 27
        static let footerSpacing = ProfileV3Theme.Space.s20
        static let titleLineLimit = 2
        static let titleOverhang: CGFloat = 18
        static let titleSpacing = ProfileV3Theme.Space.s10
        static let imageWidth: CGFloat = 322
        static let imageHeight: CGFloat = 181
        static let ringTop: CGFloat = 19
        static let ringTrailing: CGFloat = 22
        static let meterWidth: CGFloat = 255
        static let meterHeight: CGFloat = 8
    }

    enum Coupon {
        static let cardWidth: CGFloat = 350
        static let railSpacing = ProfileV3Theme.Space.s20
        static let textTrailing: CGFloat = Benefit.ringTrailing + progressRing + ProfileV3Theme.Space.s12
    }

    enum BenefitDetail {
        static let heroHeight: CGFloat = 420
        static let glow: CGFloat = 440
        static let glowRadius: CGFloat = 200
        static let glowBlur: CGFloat = 30
        static let titleWidth: CGFloat = 211
        static let bodyWidth: CGFloat = 299
        static let meterBottom: CGFloat = 46
    }

    enum Collapse {
        static let tabWidth: CGFloat = 216
        static let tabShapeWidth: CGFloat = 208
        static let tabTopRatio: CGFloat = 0.89
        static let tabHeight: CGFloat = 7
        static let tabTop: CGFloat = topBarCentre + 47
        static let tabSwipeHeight: CGFloat = 28
        static let tabSwipeMinimum: CGFloat = 20
        static let notchWidth: CGFloat = 203
        static let notchHeight: CGFloat = 36
        static let notchTop: CGFloat = tabTop + 24
        static let backdropTop: CGFloat = tabTop - 22
        static let backdropSolidBottom: CGFloat = tabTop + 68
        static let backdropFadeBottom: CGFloat = tabTop + 100
        static let cameraDistance: CGFloat = 600
        static var cardRestTop: CGFloat { hubBarBottom + carouselTop }
        static var distance: CGFloat { worldPassHeight - Collapse.tabHeight }
        static var drop: CGFloat { Collapse.tabTop - Collapse.cardRestTop }
    }

    enum Detail {
        static let cornerRadius = ProfileV3Theme.Radius.xxxl
        static let aspectRatio: CGFloat = 380 / 716
        static let pillFlag: CGFloat = 20
        static let pillFlagOverlap: CGFloat = -4
        static let statsTop: CGFloat = 62
        static let statsHorizontal: CGFloat = 40
        static let bottom: CGFloat = 60
    }

    enum Flip {
        static let notchWidth: CGFloat = 42
        static let notchHeight: CGFloat = 54
        static let notchTop: CGFloat = 49
        static let glowWidth: CGFloat = 63
        static let glowHeight: CGFloat = 54
        static let glowLeading: CGFloat = -28
        static let icon: CGFloat = 20
        static let iconLeading: CGFloat = -10
        static let backIconLeading: CGFloat = -14
        static let iconTop: CGFloat = 17
        static let perspective: CGFloat = 0.4
    }

    enum KYCCard {
        static let notchWidth: CGFloat = 25
        static let notchHeight: CGFloat = 7
        static let contentTop: CGFloat = 26
        static let barHeight: CGFloat = 6
    }

    enum Podium {
        static let discWidth: CGFloat = 354
        static let height: CGFloat = 88
        static let shadowWidth: CGFloat = 321
        static let shadowHeight: CGFloat = 21
        static let shadowOffsetX: CGFloat = -41.5
        static let shadowOffsetY: CGFloat = 7.5
        static let shadowBlur: CGFloat = 7
        static let topSpacing: CGFloat = 24
        static let contentGap = ProfileV3Theme.Space.s22
        static var slot: CGFloat { Podium.topSpacing + Podium.height }
    }
}
