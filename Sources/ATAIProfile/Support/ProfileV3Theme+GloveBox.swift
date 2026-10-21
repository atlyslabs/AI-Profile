import ATUIKit
import SwiftUI

extension ProfileV3Theme {
    enum GloveBox {
        enum Layout {
            static let headerTop: CGFloat = 24

            static let cardTop: CGFloat = 83
            static let cardMargin: CGFloat = 30
            static let cardMaxHeight: CGFloat = 597
            static let cardRadius: CGFloat = 40
            static let cardBottom: CGFloat = 26
            static let cardMinBottomGap: CGFloat = 24
            static let cardShadowRadius: CGFloat = 35
            static let cardHighlightOffset = CGSize(width: -16, height: -50)
            static let cardShadowOffset = CGSize(width: 17, height: 21)
            static let envelope: CGFloat = 200
            static let glow: CGFloat = 197
            static let glowBlur: CGFloat = 50
            static let glowOffsetY: CGFloat = -10.5
            static let titleTop: CGFloat = 37
            static let titleWidth: CGFloat = 281
            static let subtitleTop: CGFloat = 36
            static let subtitleWidth: CGFloat = 238
            static let actionTop: CGFloat = 61
            static let actionInset: CGFloat = 23
            static let actionHeight: CGFloat = 50

            static let addressTop: CGFloat = 31
            static let addressWidth: CGFloat = 316
            static let addressHeight: CGFloat = 86
            static let addressBorder: CGFloat = 3
            static let addressInset: CGFloat = 24
            static let addressShadowRadius: CGFloat = 35
            static let addressShadowOffset = CGSize(width: 17, height: 21)
            static let copyTop: CGFloat = 29
            static let copyHeight: CGFloat = 32
            static let copyIcon: CGFloat = 16
            static let copySpacing: CGFloat = 5
            static let copyShadowRadius: CGFloat = 7
            static let copyShadowY: CGFloat = 4.675
            static let aboutTop: CGFloat = 34
            static let aboutWidth: CGFloat = 281
            static let forwardingTop: CGFloat = 38
            static let forwardingWidth: CGFloat = 303
            static let sheetTop: CGFloat = 59
            static let sheetRadius: CGFloat = 44
            static let sheetInset: CGFloat = 40
            static let sheetShadowRadius: CGFloat = 7.5
            static let sheetShadowY: CGFloat = -10
            static let sheetTitleTop: CGFloat = 40
            static let listTop: CGFloat = 36
            static let listBottom: CGFloat = 40
            static let rowSpacing: CGFloat = 20
            static let rowGap: CGFloat = 16
            static let rowTextSpacing: CGFloat = 10
            static let rowTitleSpacing: CGFloat = 5
            static let rowTextWidth: CGFloat = 191
            static let logo: CGFloat = 20
            static let glyph: CGFloat = 10
            static let metaSpacing: CGFloat = 8
            static let folderWidth: CGFloat = 76.2246
            static let folderHeight: CGFloat = 59.3339
            static let emptySpacing: CGFloat = 40
            static let emptyTextSpacing: CGFloat = 24
            static let emptyBodyWidth: CGFloat = 286

            static let detailRadius: CGFloat = 44
            static let detailBackTop: CGFloat = 20
            static let detailInset: CGFloat = 32
            static let detailHeaderTop: CGFloat = 46
            static let detailTitleSpacing: CGFloat = 11
            static let detailMetaTop: CGFloat = 24
            static let detailDividerTop: CGFloat = 37
            static let detailNoteTop: CGFloat = 43
            static let detailNoteWidth: CGFloat = 260
            static let detailCTATop: CGFloat = 48
            static let badgeHeight: CGFloat = 22
            static let badgeRadius: CGFloat = 8
            static let badgeLeading: CGFloat = 6
            static let badgeTrailing: CGFloat = 5
            static let dimBlur: CGFloat = 4

            static let blobBlur: CGFloat = 25
            static let actionBlob = CGSize(width: 32.6, height: 29.3)
            static let addressBlob = CGSize(width: 32.6, height: 50.4)
            static let blobCentres: [UnitPoint] = [
                UnitPoint(x: 0.203, y: 0),
                UnitPoint(x: 0.3195, y: 1),
                UnitPoint(x: 0.539, y: 0.5),
                UnitPoint(x: 0.6554, y: 0.5),
                UnitPoint(x: 0.904, y: 0.5)
            ]
        }

        enum Palette {
            static let inboxBackground = Color(hex: "F3F3F6")
            static let cardShade = Color(at: .pureBlack).opacity(0.13)
            static let cardShadow = Color(at: .pureBlack).opacity(0.25)
            static let cardHighlight = Color(at: .pureWhite)
            static let actionFrost = Color(at: .pureWhite).opacity(0.1)
            static let addressShadow = Color(at: .pureBlack).opacity(0.12)
            static let addressBlobOpacity = 0.48
            static let copyBorder = Color(hex: "F4F5F6")
            static let copyShadow = Color(at: .pureBlack).opacity(0.05)
            static let sheetShadow = Color(at: .pureBlack).opacity(0.03)
            static let dim = Color(hex: "010101").opacity(0.8)
            static let glowOpacity = 0.4
            static let blobs = ["5057EA", "B038C2", "C81E1E", "F59E0B", "EDD758"].map { Color(hex: $0) }
            static let aboutOpacity = 0.5
            static let forwardingOpacity = 0.9
            static let forwardingLabelOpacity = 0.5
            static let summaryOpacity = 0.5
            static let metaOpacity = 0.3
            static let attentionOpacity = 0.7
            static let emptyTitleOpacity = 0.6
            static let emptyBodyOpacity = 0.5
            static let folderOpacity = 0.4
            static let sectionTitleOpacity = 0.5
        }

        static let glowGradient = LinearGradient(
            stops: [
                .init(color: Color(at: .pureWhite), location: 0),
                .init(color: Color(at: .pureWhite), location: 0.163),
                .init(color: Color(hex: "E5E6F7"), location: 0.456),
                .init(color: Color(hex: "5D64FF"), location: 0.605),
                .init(color: Color(hex: "FF5959"), location: 0.745),
                .init(color: Color(hex: "FFE23D"), location: 0.926)
            ],
            startPoint: UnitPoint(x: -0.774, y: 1.411),
            endPoint: UnitPoint(x: 0.056, y: -0.07)
        )

        static let cardShading = LinearGradient(
            stops: [
                .init(color: Palette.cardShade, location: 0.027),
                .init(color: Palette.cardShade.opacity(0), location: 0.262)
            ],
            startPoint: UnitPoint(x: 0.4, y: 0),
            endPoint: UnitPoint(x: 0.6, y: 1)
        )

        static let shimmerGradient = LinearGradient(
            stops: [
                .init(color: Color(at: .pureWhite).opacity(0), location: 0),
                .init(color: Color(at: .pureWhite).opacity(0.08), location: 0.22),
                .init(color: Color(at: .pureWhite).opacity(0.75), location: 0.42),
                .init(color: Color(at: .pureWhite), location: 0.5),
                .init(color: Color(at: .pureWhite).opacity(0.75), location: 0.58),
                .init(color: Color(at: .pureWhite).opacity(0.08), location: 0.78),
                .init(color: Color(at: .pureWhite).opacity(0), location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let badgeGradient = LinearGradient(
            colors: [Color(hex: "5F9310"), Color(hex: "9DD645")],
            startPoint: UnitPoint(x: 0, y: 0.33),
            endPoint: UnitPoint(x: 1, y: 0.67)
        )

        static let attentionGradient = LinearGradient(
            colors: [Color(at: .pureBlack), Color(hex: "E3AD0A")],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let emptyBodyGradient = LinearGradient(
            colors: [Color(at: .pureBlack), Color(hex: "666666")],
            startPoint: .leading,
            endPoint: .trailing
        )

        enum Motion {
            private static let settle = UnitCurve.bezier(
                startControlPoint: UnitPoint(x: 0.22, y: 1),
                endControlPoint: UnitPoint(x: 0.36, y: 1)
            )

            static let duration: Double = 4.7

            static let addressOpacity = ProfileV3MotionTrack(start: 0, keys: [(0.1, 0, .linear), (0.2, 1, settle)])
            static let addressScale = ProfileV3MotionTrack(
                start: 1.26,
                keys: [(0.12, 1.26, .linear), (0.3, 0.965, settle), (0.43, 1.025, settle), (0.58, 1, settle)]
            )
            static let addressX = ProfileV3MotionTrack(
                start: -41.08,
                keys: [(0.12, -41.08, .linear), (0.3, 5.53, settle), (0.43, -3.95, settle), (0.58, 0, settle)]
            )
            static let addressY = ProfileV3MotionTrack(
                start: 261.32,
                keys: [
                    (0.12, 261.32, .linear), (0.3, 274.005, settle), (0.43, 271.425, settle),
                    (0.58, 272.5, settle), (0.86, 272.5, .linear), (1.48, 0, .easeInOut)
                ]
            )
            static let blobX = ProfileV3MotionTrack(
                start: -38,
                keys: [(0.55, 28, .easeInOut), (1.2, -18, .easeInOut), (2.2, 22, .easeInOut), (3.4, -12, .easeInOut), (4.7, 0, .easeInOut)]
            )
            static let blobY = ProfileV3MotionTrack(
                start: 8,
                keys: [(0.55, -10, .easeInOut), (1.2, 12, .easeInOut), (2.2, -8, .easeInOut), (3.4, 6, .easeInOut), (4.7, 0, .easeInOut)]
            )

            static let copy = ProfileV3Reveal(start: 1.42, end: 1.74, rise: 7)
            static let about = ProfileV3Reveal(start: 1.7, end: 2.12, rise: 12)
            static let forwarding = ProfileV3Reveal(start: 2.12, end: 2.52, rise: 10)
            static let sheet = ProfileV3Reveal(start: 2.58, end: 3.2, rise: 464)
            static let firstRow = ProfileV3Reveal(start: 3.24, end: 3.64, rise: 16)
            static let rowStagger: Double = 0.32

            static func row(_ index: Int) -> ProfileV3Reveal {
                let shift = Double(index) * rowStagger
                return ProfileV3Reveal(start: firstRow.start + shift, end: firstRow.end + shift, rise: firstRow.rise)
            }

            enum Intro {
                private static let easeOut = UnitCurve.bezier(
                    startControlPoint: UnitPoint(x: 0, y: 0),
                    endControlPoint: UnitPoint(x: 0.58, y: 1)
                )
                private static let easeInOut = UnitCurve.bezier(
                    startControlPoint: UnitPoint(x: 0.42, y: 0),
                    endControlPoint: UnitPoint(x: 0.58, y: 1)
                )

                static let delay: Double = 0.4
                static let duration: Double = 1.4

                static let fade = ProfileV3MotionTrack(start: 0, keys: [(0.65, 1, easeOut)])
                static let rise = ProfileV3MotionTrack(start: 16, keys: [(0.75, 0, easeOut)])
                static let cardScale = ProfileV3MotionTrack(start: 0.98, keys: [(0.75, 1, easeOut)])
                static let cardX = ProfileV3MotionTrack(start: 3.8, keys: [(0.75, 0, easeOut)])
                static let cardY = ProfileV3MotionTrack(start: 21.97, keys: [(0.75, 0, easeOut)])
                static let shimmerOpacity = ProfileV3MotionTrack(
                    start: 0,
                    keys: [(0.3, 0, .linear), (0.55, 0.65, easeInOut), (1.1, 0.65, .linear), (1.4, 0, easeInOut)]
                )
                static let shimmerStart: Double = -470 / 380
                static let shimmerTravel = ProfileV3MotionTrack(
                    start: 0,
                    keys: [(0.3, 0, .linear), (1.35, 1050 / 380, easeInOut)]
                )
            }

            static let detail: Animation = .spring(response: 0.45, dampingFraction: 0.88)
            static let stageSwitch: Animation = .easeInOut(duration: 0.35)

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
