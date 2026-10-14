import SwiftUI

struct ProfileV3BackFaceWash: View {
    var body: some View {
        ProfileV3BackFaceWashShape()
            .fill(ProfileV3Theme.backFaceWashGradient)
            .frame(width: ProfileV3Theme.Sizes.BackFace.washWidth, height: ProfileV3Theme.Sizes.BackFace.washHeight)
            .opacity(ProfileV3Theme.Opacity.backFaceWash)
            .blur(radius: ProfileV3Theme.Sizes.BackFace.washBlur)
            .rotationEffect(.degrees(ProfileV3Theme.Rotation.backFaceWash))
            .position(x: ProfileV3Theme.Sizes.BackFace.washCentreX, y: ProfileV3Theme.Sizes.BackFace.washCentreY)
            .frame(width: ProfileV3Theme.Sizes.worldPassWidth, height: ProfileV3Theme.Sizes.worldPassHeight)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

private struct ProfileV3BackFaceWashShape: Shape {
    func path(in rect: CGRect) -> Path {
        let scaleX = rect.width / ProfileV3Theme.Sizes.BackFace.washWidth
        let scaleY = rect.height / ProfileV3Theme.Sizes.BackFace.washHeight
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * scaleX, y: rect.minY + y * scaleY)
        }
        var path = Path()
        path.move(to: point(10.272, 216.78))
        path.addCurve(
            to: point(14.255, 227.799),
            control1: point(12.596, 221.08),
            control2: point(14.363, 224.939)
        )
        path.addCurve(
            to: point(14.302, 228.897),
            control1: point(14.242, 228.138),
            control2: point(14.257, 228.512)
        )
        path.addCurve(
            to: point(39.864, 230.598),
            control1: point(20.626, 237.974),
            control2: point(31.924, 231.831)
        )
        path.addCurve(
            to: point(189.232, 158.3),
            control1: point(53.338, 228.506),
            control2: point(174.354, 158.3)
        )
        path.addCurve(
            to: point(209.562, 108.705),
            control1: point(204.11, 158.3),
            control2: point(203.948, 115.819)
        )
        path.addCurve(
            to: point(229.731, 0.186),
            control1: point(215.176, 101.591),
            control2: point(213.45, 6.463)
        )
        path.addCurve(
            to: point(224.269, 72.898),
            control1: point(242.757, -4.836),
            control2: point(224.924, 93.821)
        )
        path.addLine(to: point(220.532, 226.106))
        path.addCurve(
            to: point(218.655, 228.066),
            control1: point(220.506, 227.146),
            control2: point(219.693, 227.996)
        )
        path.addLine(to: point(42.265, 239.976))
        path.addCurve(
            to: point(41.558, 239.897),
            control1: point(42.026, 239.992),
            control2: point(41.787, 239.965)
        )
        path.addLine(to: point(16.388, 232.445))
        path.addCurve(
            to: point(14.302, 228.897),
            control1: point(15.116, 232.069),
            control2: point(14.477, 230.402)
        )
        path.addCurve(
            to: point(10.272, 216.78),
            control1: point(12.479, 226.282),
            control2: point(11.07, 222.404)
        )
        path.addCurve(
            to: point(8.317, 181.82),
            control1: point(3.512, 204.273),
            control2: point(-7.96, 188.037)
        )
        path.addCurve(
            to: point(10.809, 183.917),
            control1: point(9.643, 181.314),
            control2: point(10.959, 182.506)
        )
        path.addCurve(
            to: point(10.272, 216.78),
            control1: point(9.233, 198.719),
            control2: point(9.21, 209.295)
        )
        path.closeSubpath()
        return path
    }
}
