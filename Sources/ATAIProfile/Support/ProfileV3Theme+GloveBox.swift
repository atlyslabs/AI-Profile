import ATUIKit
import SwiftUI

extension ProfileV3Theme {
    enum GloveBox {
        enum Layout {
            static let headerTop: CGFloat = 24
            static let dimBlur: CGFloat = 4

            static let cabinet = CGSize(width: 440, height: 562.31)

            static func cabinetScale(for width: CGFloat) -> CGFloat {
                min(width / cabinet.width, 1)
            }

            static let introCabinetTop: CGFloat = 34.69
            static let homeCabinetTop: CGFloat = 25.69
            static let box = CGRect(x: 39, y: 0, width: 362, height: 309.419)
            static let boxBorder: CGFloat = 2.022
            static let boxRadius: CGFloat = 23.257
            static let boxSheen = CGSize(width: 357.955, height: 293.24)
            static let boxSide = CGSize(width: 40.963, height: 306.747)
            static let boxSideOffset: CGFloat = 158.61
            static let bevel = CGSize(width: 357.955, height: 38.4246)
            static let bevelInset: CGFloat = 40.4469
            static let shine = CGSize(width: 13.91, height: 339.604)
            static let shineBlur: CGFloat = 19.053
            static let shineAngle = Angle.degrees(41.34)
            static let shineSkew = Angle.degrees(20.58)
            static let shineScaleY: CGFloat = 0.94
            static let shineCentres = [CGPoint(x: 243.42, y: 144.21), CGPoint(x: 19.55, y: 144.21)]
            static let glow = CGRect(x: 3.812, y: 245.782, width: 357.237, height: 44.774)
            static let glowBlurScale: CGFloat = 0.24
            static let labelTop: CGFloat = 65.54
            static let introLabelShift: CGFloat = 5.91
            static let introContentShift: CGFloat = 3.43
            static let ringCentreY: CGFloat = 170.03
            static let rings: [(diameter: CGFloat, opacity: Double)] = [
                (127.009, 0.2), (165.758, 0.2), (221.011, 0.1), (287.695, 0.1)
            ]
            static let ringStroke: CGFloat = 1.07635
            static let dialCentreY: CGFloat = 167.97
            static let dial: CGFloat = 62.6927
            static let dialSpacing: CGFloat = 35.247
            static let dialShadowDrop: CGFloat = 2.02
            static let dialDot: CGFloat = 3.0335
            static let dialDotRadius: CGFloat = 25.785
            static let dialDotCount = 12
            static let dialFace: CGFloat = 44.4916
            static let dialIcon: CGFloat = 15.1676
            static let pillTop: CGFloat = 249.31
            static let pillHeight: CGFloat = 22
            static let pillIcon: CGFloat = 12
            static let pillSpacing: CGFloat = 4
            static let pillIconLeading: CGFloat = 4
            static let pillInset: CGFloat = 8

            static let shelf = CGRect(x: 20, y: 290.31, width: 400, height: 35)
            static let shelfGradientStart = CGPoint(x: 187.45, y: 176.36)
            static let shelfGradientEnd = CGPoint(x: 244.56, y: 406.99)
            static let shelfLip = CGRect(x: 20, y: 305.31, width: 400, height: 6)
            static let shelfSeam = CGRect(x: 39, y: 305.31, width: 363, height: 6)
            static let legs = CGRect(x: 58, y: 325.31, width: 326, height: 237)
            static let legsInner = CGRect(x: 117, y: 325.31, width: 208, height: 237)
            static let legShadows = [
                CGRect(x: 58, y: 325.31, width: 59, height: 27),
                CGRect(x: 325, y: 325.31, width: 59, height: 27),
                CGRect(x: 117, y: 325.31, width: 208, height: 15)
            ]
            static let shelfHighlights = [
                CGRect(x: 271, y: 290.31, width: 113, height: 15),
                CGRect(x: 271, y: 311.31, width: 113, height: 14)
            ]
            static let legEdges = [
                CGRect(x: 108, y: 327.31, width: 9, height: 240),
                CGRect(x: 325, y: 327.31, width: 9, height: 240)
            ]
            static let introFade = CGRect(x: 0, y: 352.31, width: 440, height: 289)
            static let homeFade = CGRect(x: 0, y: 340.31, width: 440, height: 104)

            static let introTitleTop: CGFloat = 460.31
            static let introSubtitleGap: CGFloat = 27
            static let introSubtitleWidth: CGFloat = 252.626
            static let introBottom: CGFloat = 24
            static let actionInset: CGFloat = 60
            static let actionHeight: CGFloat = 50
            static let actionBottom: CGFloat = 28

            static func introTitleWidth(_ status: ProfileV3GloveBoxIntro.Status) -> CGFloat {
                switch status {
                case .locked: return 281
                case .warmingUp: return 199
                }
            }

            static let homeSheetTop: CGFloat = 409.31
            static let sheetRadius: CGFloat = 44
            static let sheetShadowRadius: CGFloat = 15
            static let sheetShadowY: CGFloat = -10
            static let sheetPadding = EdgeInsets(top: 41, leading: 30, bottom: 52, trailing: 30)
            static let sectionSpacing: CGFloat = 32

            static let sectionRadius: CGFloat = 40
            static let sectionTop: CGFloat = 32
            static let sectionLeading: CGFloat = 29
            static let sectionTrailing: CGFloat = 31
            static let sectionBottom: CGFloat = 30
            static let sectionShadowRadius: CGFloat = 11.69
            static let sectionShadowY: CGFloat = 4.675
            static let sectionIcon: CGFloat = 15.922
            static let sectionIconGap: CGFloat = 13
            static let sectionValueTop: CGFloat = 25
            static let sectionAboutTop: CGFloat = 16
            static let sectionAboutWidth: CGFloat = 303
            static let forwardingTop: CGFloat = 18
            static let previewTop: CGFloat = 27
            static let phoneAboutTop: CGFloat = 20
            static let headlineTop: CGFloat = 16
            static let headlineWidth: CGFloat = 230
            static let leadTop: CGFloat = 22
            static let viewAllTop: CGFloat = 20
            static let viewAllBottom: CGFloat = 21
            static let viewAllIcon: CGFloat = 16
            static let viewAllSpacing: CGFloat = 8
            static let copyIcon: CGFloat = 16
            static let copyHitInset: CGFloat = 8
            static let valueSpacing: CGFloat = 8
            static let copyGap: CGFloat = 13
            static let flag: CGFloat = 20
            static let emailPreviewLimit = 3
            static let transactionPreviewLimit = 3

            static let badgeHeight: CGFloat = 22
            static let badgeRadius: CGFloat = 8
            static let badgeLeading: CGFloat = 6
            static let badgeTrailing: CGFloat = 5
            static let badgeMinWidth: CGFloat = 73
            static let pendingBadgeInset: CGFloat = 10
            static let sampleInset = EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10)
            static let sampleTop: CGFloat = 11
            static let sampleTrailing: CGFloat = 11

            static let previewRadius: CGFloat = 20
            static let previewPadding = EdgeInsets(top: 28, leading: 22, bottom: 28, trailing: 22)
            static let rowSpacing: CGFloat = 20
            static let rowGap: CGFloat = 16
            static let rowTextSpacing: CGFloat = 10
            static let rowTitleSpacing: CGFloat = 5
            static let rowTextWidth: CGFloat = 187
            static let logo: CGFloat = 20
            static let glyph: CGFloat = 10
            static let metaSpacing: CGFloat = 8
            static let callPillTop: CGFloat = 22

            static let audioPadding = EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
            static let audioPlay: CGFloat = 24
            static let audioGap: CGFloat = 16
            static let audioMetaSpacing: CGFloat = 9
            static let audioPreviewWidth: CGFloat = 244
            static let audioDetailWidth: CGFloat = 260
            static let waveBar: CGFloat = 2
            static let wavePitch: CGFloat = 4
            static let waveHeight: CGFloat = 20
            static let waveGroupGap: CGFloat = 10
            static let waveBars: [CGFloat] = [4.9, 2.64, 7.17, 12.46, 20, 13.96, 9.44, 13.2, 6.42, 10.18, 4.9]

            static let transactionGap: CGFloat = 30
            static let transactionTextSpacing: CGFloat = 8
            static let blockedSpacing: CGFloat = 6
            static let transactionsPadding = EdgeInsets(top: 30, leading: 24, bottom: 30, trailing: 24)

            static let cardTop: CGFloat = 21
            static let cardSize = CGSize(width: 320, height: 201)
            static let cardRadius: CGFloat = 25.263
            static let cardWash = CGRect(x: -8, y: -98.4, width: 342.448, height: 310.698)
            static let cardLightCentre = CGPoint(x: 46.07, y: 6.33)
            static let cardLightRadius: CGFloat = 110.868
            static let cardShadeCentre = CGPoint(x: 73.19, y: 223.91)
            static let cardShadeSize = CGSize(width: 191.102, height: 426.15)
            static let cardShadeAngle = Angle.degrees(98.81)
            static let cardBlobBlur: CGFloat = 13.9146
            static let cardGlobeCentre = CGPoint(x: 280.39, y: 114.23)
            static let cardGlobeSize: CGFloat = 267.538
            static let cardMark = CGRect(x: 21.02, y: 25, width: 28.898, height: 24)
            static let cardInset: CGFloat = 20
            static let cardNumberTop: CGFloat = 96
            static let cardGroupSpacing: CGFloat = 13
            static let cardNumberGap: CGFloat = 16
            static let cardMaskedGroups = 3
            static let cardDigits = CGSize(width: 53.999, height: 7.96777)
            static let cardLabelsTop: CGFloat = 135
            static let cardValuesTop: CGFloat = 156
            static let cardColumns: [CGFloat] = [20, 115, 190]
            static let cardExpiry = CGRect(x: 20, y: 162, width: 53.9492, height: 12.2425)
            static let cardCVC = CGRect(x: 115, y: 164, width: 30.9668, height: 7.96777)
            static let statsTop: CGFloat = 20
            static let statSpacing: CGFloat = 16
            static let statHeight: CGFloat = 70
            static let statRadius: CGFloat = 24
            static let statPadding = EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 16)
            static let statTextSpacing: CGFloat = 3
            static let factsTop: CGFloat = 24
            static let factSpacing: CGFloat = 16
            static let payDividerTop: CGFloat = 32
            static let payTitleTop: CGFloat = 32
            static let payBodyTop: CGFloat = 12
            static let payBodyWidth: CGFloat = 286
            static let optionsTop: CGFloat = 28
            static let optionSpacing: CGFloat = 20
            static let optionRadius: CGFloat = 24
            static let optionPadding = EdgeInsets(top: 23, leading: 23, bottom: 25, trailing: 25)
            static let optionTextSpacing: CGFloat = 16
            static let optionBodyWidth: CGFloat = 233
            static let radio: CGFloat = 24
            static let chipTop: CGFloat = 22
            static let chipHeight: CGFloat = 36
            static let chipLogo: CGFloat = 24
            static let chipSpacing: CGFloat = 10
            static let chipLeading: CGFloat = 6
            static let chipTrailing: CGFloat = 16
            static let chipInset: CGFloat = 3
            static let addButtonTop: CGFloat = 5
            static let addButton: CGFloat = 40
            static let addIcon: CGFloat = 16
            static let addCardTop: CGFloat = 32
            static let addCardHeight: CGFloat = 40
            static let addCardGlow = CGSize(width: 615, height: 149)
            static let addCardGlowOffset = CGSize(width: -26.5, height: -46)
            static let addCardGlowBlur: CGFloat = 5
            static let secureNoteTop: CGFloat = 18
            static let secureNoteWidth: CGFloat = 268
            static let transactionsDividerTop: CGFloat = 28
            static let transactionsTop: CGFloat = 28
            static let emptyHeight: CGFloat = 225
            static let emptyIcon = CGSize(width: 40, height: 27)
            static let emptySpacing: CGFloat = 30
            static let emptyTextSpacing: CGFloat = 9
            static let emptyBodyWidth: CGFloat = 286
            static let noticeTop: CGFloat = 22
            static let noticeInset: CGFloat = 31
            static let noticeHeight: CGFloat = 44
            static let noticeRadius: CGFloat = 20
            static let noticeLeading: CGFloat = 17
            static let noticeTrailing: CGFloat = 10
            static let noticeClose: CGFloat = 24
            static let noticeGlow = CGSize(width: 444, height: 103)
            static let noticeGlowOffset = CGSize(width: -23, height: -14)
            static let noticeGlowBlur: CGFloat = 6.5

            static let listPadding = EdgeInsets(top: 36, leading: 30, bottom: 40, trailing: 30)
            static let listHeaderGap: CGFloat = 46
            static let emailListHeaderGap: CGFloat = 56
            static let callsCardRadius: CGFloat = 32
            static let callsCardPadding: CGFloat = 24
            static let callsCardSpacing: CGFloat = 20
            static let callsListTop: CGFloat = 30

            static let detailBackTop: CGFloat = 20
            static let detailInset: CGFloat = 30
            static let detailHeaderTop: CGFloat = 46
            static let detailTitleSpacing: CGFloat = 11
            static let detailBlockSpacing: CGFloat = 24
            static let detailTitleWidth: CGFloat = 213
            static let detailDividerTop: CGFloat = 37
            static let detailNoteTop: CGFloat = 43
            static let detailNoteWidth: CGFloat = 260
            static let detailCTATop: CGFloat = 48
            static let detailEmptyBottom: CGFloat = 120

            static let blobBlur: CGFloat = 25
            static let actionBlob = CGSize(width: 32.6, height: 29.3)
            static let blobCentres: [UnitPoint] = [
                UnitPoint(x: 0.203, y: 0),
                UnitPoint(x: 0.3195, y: 1),
                UnitPoint(x: 0.539, y: 0.5),
                UnitPoint(x: 0.6554, y: 0.5),
                UnitPoint(x: 0.904, y: 0.5)
            ]
        }

        enum Palette {
            static let boxBorder = Color(hex: "CBCDD4")
            static let boxSheen = Color(hex: "D9D9D9")
            static let boxSide = Color(hex: "E9EAEF")
            static let boxSheenOpacity = 0.2
            static let boxSideOpacity = 0.67
            static let shineOpacities = [1.0, 0.49]
            static let ring = Color(hex: "333333")
            static let ringFade = Color(hex: "666666").opacity(0)
            static let dialLight = Color(hex: "EBE9E9")
            static let dialShadow = Color(hex: "908F8F")
            static let dialBase = Color(hex: "A7A6A6")
            static let dialFace = Color(hex: "FCFCFC")
            static let dialIcon = Color(hex: "8C8B8D")
            static let dialDot = Color(hex: "FEFEFE")
            static let lockedGlow = Color(hex: "97CF40").opacity(0.2)
            static let warmingGlow = Color(hex: "95CE3F").opacity(0.4)
            static let pillTop = Color(hex: "70706B")
            static let pillBottom = Color(hex: "333330")
            static let pillIcon = Color(hex: "FBF8FC")
            static let shelfTop = Color(hex: "D9D9D9")
            static let shelfSeam = Color(hex: "B1AFAF")
            static let legsInner = Color(hex: "E8E8E8")
            static let legShadow = Color(hex: "1E1E1E")
            static let legShadowFade = Color(red: 132 / 255, green: 132 / 255, blue: 132 / 255).opacity(0)
            static let legShadowOpacity = 0.2
            static let legEdgeOpacity = 0.1
            static let shelfHighlightOpacity = 0.3

            static let sheetShadow = Color(at: .pureBlack).opacity(0.03)
            static let sectionBorder = Color(hex: "E5E5E5")
            static let sectionShadow = Color(at: .pureBlack).opacity(0.02)
            static let preview = Color(hex: "F9F9F9")
            static let sectionTitleOpacity = 0.5
            static let aboutOpacity = 0.5
            static let forwardingOpacity = 0.9
            static let forwardingLabelOpacity = 0.5
            static let summaryOpacity = 0.5
            static let metaOpacity = 0.3
            static let metaIconOpacity = 0.6
            static let attentionOpacity = 0.7
            static let factOpacity = 0.5
            static let icon = Color(hex: "1C1B1F")
            static let control = Color(hex: "323232")
            static let pendingBadge = Color(hex: "242424")
            static let pendingBadgeOpacity = 0.6
            static let sample = Color(hex: "E4E6FF")
            static let sampleText = Color(hex: "7379EE")
            static let sampleOpacity = 0.9
            static let audioMeta = Color(hex: "606060")

            static let card = Color(at: .pureBlack)
            static let cardGreen = Color(red: 67 / 255, green: 173 / 255, blue: 18 / 255)
            static let cardDeep = Color(red: 28 / 255, green: 42 / 255, blue: 6 / 255).opacity(0.1)
            static let cardLight = Color(hex: "F7FFD3")
            static let cardLightOpacity = 0.3
            static let cardShade = Color(hex: "182C04")
            static let cardGlobeOpacity = 0.158
            static let cardLabelOpacity = 0.5
            static let chipText = Color(hex: "1A1A1A")
            static let addCardGlowOpacity = 0.55
            static let notice = Color(hex: "252525")
            static let noticeText = Color(hex: "FEFEFE")
            static let emptyIconOpacity = 0.4
            static let emptyTitleOpacity = 0.6
            static let emptyBodyOpacity = 0.5

            static let dimOpacity = 0.8
            static let actionFrost = Color(at: .pureWhite).opacity(0.1)
            static let blobs = ["5057EA", "B038C2", "C81E1E", "F59E0B", "EDD758"].map { Color(hex: $0) }
        }

        static let liveBadgeGradient = LinearGradient(
            colors: [Color(hex: "5F9310"), Color(hex: "9DD645")],
            startPoint: UnitPoint(x: 0, y: 0.33),
            endPoint: UnitPoint(x: 1, y: 0.67)
        )

        static let attentionGradient = LinearGradient(
            colors: [Color(at: .pureBlack), Color(hex: "E3AD0A")],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let approvedGradient = LinearGradient(
            colors: [Color(hex: "043122"), Color(hex: "0C9769")],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let secureNoteGradient = LinearGradient(
            colors: [Color(at: .pureBlack), Color(hex: "10B981")],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let emptyBodyGradient = LinearGradient(
            colors: [Color(at: .pureBlack), Color(hex: "666666")],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let sectionFill = LinearGradient(
            stops: [
                .init(color: Color(at: .pureWhite), location: 0.47),
                .init(color: Color(at: .pureWhite).opacity(0.64), location: 0.815)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let pillGradient = LinearGradient(
            colors: [Palette.pillTop, Palette.pillBottom],
            startPoint: .top,
            endPoint: .bottom
        )

        static let cardWash = LinearGradient(
            stops: [
                .init(color: Palette.cardGreen, location: 0.1157),
                .init(color: Palette.cardDeep, location: 0.6487)
            ],
            startPoint: UnitPoint(x: -0.006, y: 0.008),
            endPoint: UnitPoint(x: 1.006, y: 0.992)
        )

        static let ringGradient = Gradient(stops: [
            .init(color: Palette.ringFade, location: 0),
            .init(color: Palette.ring, location: 0.5),
            .init(color: Palette.ringFade, location: 1)
        ])

        static let shelfGradient = Gradient(stops: [
            .init(color: Color(at: .pureWhite), location: 0.2008),
            .init(color: Palette.shelfTop, location: 0.6306)
        ])

        static let introFadeStops: [Gradient.Stop] = [
            .init(color: Color(at: .pureWhite).opacity(0), location: 0),
            .init(color: Color(at: .pureWhite), location: 1)
        ]

        static let homeFadeStops: [Gradient.Stop] = [
            .init(color: Color(at: .pureWhite).opacity(0), location: 0),
            .init(color: Color(at: .pureWhite), location: 0.6)
        ]

        enum Motion {
            private static let settle = UnitCurve.bezier(
                startControlPoint: UnitPoint(x: 0.22, y: 1),
                endControlPoint: UnitPoint(x: 0.36, y: 1)
            )
            private static let easeOut = UnitCurve.bezier(
                startControlPoint: UnitPoint(x: 0, y: 0),
                endControlPoint: UnitPoint(x: 0.58, y: 1)
            )
            private static let easeInOut = UnitCurve.bezier(
                startControlPoint: UnitPoint(x: 0.42, y: 0),
                endControlPoint: UnitPoint(x: 0.58, y: 1)
            )

            static let glowLoop: Double = 6
            static let glowRadius = ProfileV3MotionTrack(
                start: 100,
                keys: [(1.5, 88, easeInOut), (3, 96, easeInOut), (4.5, 85, easeInOut), (6, 100, easeInOut)]
            )

            static let titleDuration: Double = 0.75
            static let titleFade = ProfileV3MotionTrack(start: 0, keys: [(0.65, 1, easeOut)])
            static let titleRise = ProfileV3MotionTrack(start: 16, keys: [(0.75, 0, easeOut)])

            static let sheet = ProfileV3Reveal(start: 0.2, end: 0.82, rise: 464)

            static let firstRow = ProfileV3Reveal(start: 0.1, end: 0.5, rise: 16)
            static let rowStagger: Double = 0.08

            static func row(_ index: Int) -> ProfileV3Reveal {
                let shift = Double(index) * rowStagger
                return ProfileV3Reveal(start: firstRow.start + shift, end: firstRow.end + shift, rise: firstRow.rise)
            }

            static func listDuration(rows: Int) -> Double {
                row(max(rows - 1, 0)).end
            }

            static let sheetSwitch: Animation = .spring(response: 0.45, dampingFraction: 0.88)
            static let stageSwitch: Animation = .easeInOut(duration: 0.35)
            static let notice: Animation = .easeInOut(duration: 0.25)

            fileprivate static var settleCurve: UnitCurve { settle }
        }
    }
}

struct ProfileV3MotionTrack {
    let start: Double
    let keys: [(time: Double, value: Double, curve: UnitCurve)]

    func value(at time: Double) -> Double {
        var previousTime = 0.0
        var previousValue = start
        for key in keys {
            if time <= key.time {
                let span = key.time - previousTime
                let progress = span > 0 ? max(0, time - previousTime) / span : 1
                return previousValue + (key.value - previousValue) * key.curve.value(at: progress)
            }
            previousTime = key.time
            previousValue = key.value
        }
        return previousValue
    }
}

struct ProfileV3Reveal {
    let start: Double
    let end: Double
    let rise: CGFloat

    func progress(at time: Double) -> Double {
        ProfileV3MotionTrack(
            start: 0,
            keys: [(start, 0, .linear), (end, 1, ProfileV3Theme.GloveBox.Motion.settleCurve)]
        ).value(at: time)
    }

    func offset(at time: Double) -> CGFloat {
        rise * (1 - progress(at: time))
    }
}
