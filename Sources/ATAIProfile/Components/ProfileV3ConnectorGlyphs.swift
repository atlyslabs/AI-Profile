import ATUIKit
import SwiftUI

struct ProfileV3ContractShape: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / 36
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * scale, y: rect.minY + y * scale)
        }
        var path = Path()
        path.move(to: point(9, 33))
        path.addCurve(
            to: point(5.8125, 31.6875),
            control1: point(7.75, 33),
            control2: point(6.6875, 32.5625)
        )
        path.addCurve(
            to: point(4.5, 28.5),
            control1: point(4.9375, 30.8125),
            control2: point(4.5, 29.75)
        )
        path.addLine(to: point(4.5, 24))
        path.addLine(to: point(9, 24))
        path.addLine(to: point(9, 3))
        path.addLine(to: point(31.5, 3))
        path.addLine(to: point(31.5, 28.5))
        path.addCurve(
            to: point(30.1875, 31.6875),
            control1: point(31.5, 29.75),
            control2: point(31.0625, 30.8125)
        )
        path.addCurve(
            to: point(27, 33),
            control1: point(29.3125, 32.5625),
            control2: point(28.25, 33)
        )
        path.addLine(to: point(9, 33))
        path.move(to: point(27, 30))
        path.addCurve(
            to: point(28.0688, 29.5687),
            control1: point(27.425, 30),
            control2: point(27.7813, 29.8562)
        )
        path.addCurve(
            to: point(28.5, 28.5),
            control1: point(28.3563, 29.2812),
            control2: point(28.5, 28.925)
        )
        path.addLine(to: point(28.5, 6))
        path.addLine(to: point(12, 6))
        path.addLine(to: point(12, 24))
        path.addLine(to: point(25.5, 24))
        path.addLine(to: point(25.5, 28.5))
        path.addCurve(
            to: point(25.9313, 29.5687),
            control1: point(25.5, 28.925),
            control2: point(25.6438, 29.2812)
        )
        path.addCurve(
            to: point(27, 30),
            control1: point(26.2188, 29.8562),
            control2: point(26.575, 30)
        )
        path.move(to: point(13.5, 13.5))
        path.addLine(to: point(13.5, 10.5))
        path.addLine(to: point(27, 10.5))
        path.addLine(to: point(27, 13.5))
        path.addLine(to: point(13.5, 13.5))
        path.move(to: point(13.5, 18))
        path.addLine(to: point(13.5, 15))
        path.addLine(to: point(27, 15))
        path.addLine(to: point(27, 18))
        path.addLine(to: point(13.5, 18))
        path.move(to: point(9, 30))
        path.addLine(to: point(22.5, 30))
        path.addLine(to: point(22.5, 27))
        path.addLine(to: point(7.5, 27))
        path.addLine(to: point(7.5, 28.5))
        path.addCurve(
            to: point(7.9313, 29.5687),
            control1: point(7.5, 28.925),
            control2: point(7.6438, 29.2812)
        )
        path.addCurve(
            to: point(9, 30),
            control1: point(8.2188, 29.8562),
            control2: point(8.575, 30)
        )
        return path
    }
}

#if DEBUG
#Preview("Connector glyphs") {
    ProfileV3ContractShape()
        .fill(Color(at: .pureBlack))
        .frame(width: 36, height: 36)
        .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
