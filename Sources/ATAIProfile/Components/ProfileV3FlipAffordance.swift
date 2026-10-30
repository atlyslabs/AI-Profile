import ATUIKit
import SwiftUI

private struct ProfileV3FlipNotchShape: Shape {
    var isBorder = false
    var outset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 42
        let sy = rect.height / 54
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()
        if isBorder {
            path.move(to: point(0, 0))
            path.addLine(to: point(0, 2.9097))
        } else {
            path.move(to: point(0, 2.9097))
        }
        path.addCurve(to: point(11.2878, 20.5537), control1: point(0, 9.98558), control2: point(7.04533, 14.8907))
        path.addCurve(to: point(13.3158, 27), control1: point(12.5736, 22.2701), control2: point(13.3158, 24.4248))
        path.addCurve(to: point(11.2877, 33.4466), control1: point(13.3158, 29.5752), control2: point(12.5736, 31.7301))
        path.addCurve(to: point(0, 51.0909), control1: point(7.04526, 39.1096), control2: point(0, 44.015))
        if isBorder {
            path.addLine(to: point(0, 54))
        } else {
            path.addLine(to: CGPoint(x: rect.minX - outset, y: point(0, 51.0909).y))
            path.addLine(to: CGPoint(x: rect.minX - outset, y: point(0, 2.9097).y))
            path.closeSubpath()
        }
        return path
    }
}

struct ProfileV3FlipAffordance: View {
    enum Face {
        case front
        case back
    }

    var face: Face = .front

    var body: some View {
        ZStack(alignment: .topLeading) {
            switch face {
            case .front: frontNotch
            case .back: backNotch
            }
            icon
                .resizable()
                .frame(width: ProfileV3Theme.Sizes.Flip.icon, height: ProfileV3Theme.Sizes.Flip.icon)
                .offset(x: iconLeading, y: ProfileV3Theme.Sizes.Flip.iconTop)
        }
        .frame(
            width: ProfileV3Theme.Sizes.Flip.notchWidth,
            height: ProfileV3Theme.Sizes.Flip.notchHeight,
            alignment: .topLeading
        )
        .padding(.top, ProfileV3Theme.Sizes.Flip.notchTop)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var icon: Image {
        switch face {
        case .front: ProfileV3Vector.flip360.image
        case .back: ProfileV3Vector.flip360Back.image
        }
    }

    private var iconLeading: CGFloat {
        switch face {
        case .front: ProfileV3Theme.Sizes.Flip.iconLeading
        case .back: ProfileV3Theme.Sizes.Flip.backIconLeading
        }
    }

    private var frontNotch: some View {
        ProfileV3FlipNotchShape(outset: ProfileV3Theme.Stroke.regular)
            .fill(Color(at: .pureWhite))
            .frame(width: ProfileV3Theme.Sizes.Flip.notchWidth, height: ProfileV3Theme.Sizes.Flip.notchHeight)
            .background(alignment: .topLeading) {
                EllipticalGradient(
                    colors: [ProfileV3Theme.Palette.passIndigo, ProfileV3Theme.Palette.passIndigo.opacity(0)],
                    center: .center,
                    startRadiusFraction: 0,
                    endRadiusFraction: 0.5
                )
                .frame(width: ProfileV3Theme.Sizes.Flip.glowWidth, height: ProfileV3Theme.Sizes.Flip.glowHeight)
                .offset(x: ProfileV3Theme.Sizes.Flip.glowLeading)
                .frame(
                    width: ProfileV3Theme.Sizes.Flip.notchWidth,
                    height: ProfileV3Theme.Sizes.Flip.notchHeight,
                    alignment: .topLeading
                )
                .clipped()
            }
    }

    private var backNotch: some View {
        ProfileV3FlipNotchShape(outset: ProfileV3Theme.Stroke.regular)
            .fill(Color(at: .pureWhite))
            .overlay {
                ProfileV3FlipNotchShape(isBorder: true)
                    .stroke(ProfileV3Theme.Palette.backFaceBorder, lineWidth: ProfileV3Theme.Stroke.regular)
            }
            .frame(width: ProfileV3Theme.Sizes.Flip.notchWidth, height: ProfileV3Theme.Sizes.Flip.notchHeight)
            .compositingGroup()
    }
}

#if DEBUG
#Preview("Flip affordance") {
    HStack(spacing: ProfileV3Theme.Space.s32) {
        RoundedRectangle(cornerRadius: ProfileV3Theme.Sizes.worldPassCornerRadius, style: .continuous)
            .fill(Color(at: .pureBlack))
            .frame(width: ProfileV3Theme.Sizes.worldPassWidth, height: ProfileV3Theme.Sizes.worldPassHeight)
            .overlay(alignment: .topLeading) { ProfileV3FlipAffordance() }
        RoundedRectangle(cornerRadius: ProfileV3Theme.Sizes.worldPassCornerRadius, style: .continuous)
            .stroke(ProfileV3Theme.Palette.backFaceBorder, lineWidth: ProfileV3Theme.Stroke.regular)
            .frame(width: ProfileV3Theme.Sizes.worldPassWidth, height: ProfileV3Theme.Sizes.worldPassHeight)
            .overlay(alignment: .topLeading) { ProfileV3FlipAffordance(face: .back) }
    }
    .padding(ProfileV3Theme.Space.s48)
    .background(Color(at: .pureWhite))
}
#endif
