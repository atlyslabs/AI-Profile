import ATUIKit
import SwiftUI

struct ProfileV3TabShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 207.814
        let sy = rect.height / 7
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()
        path.move(to: point(11.4142, 0.667867))
        path.addCurve(to: point(14.8165, 0), control1: point(12.4943, 0.22683), control2: point(13.6499, 0))
        path.addLine(to: point(192.997, 0))
        path.addCurve(to: point(196.4, 0.667867), control1: point(194.164, 0), control2: point(195.32, 0.226831))
        path.addLine(to: point(207.191, 5.07421))
        path.addCurve(to: point(206.813, 7), control1: point(208.206, 5.48893), control2: point(207.91, 7))
        path.addLine(to: point(1.00121, 7))
        path.addCurve(to: point(0.623189, 5.07421), control1: point(-0.0958358, 7), control2: point(-0.392449, 5.48893))
        path.closeSubpath()
        return path
    }
}

struct ProfileV3CollapsedTab: View {
    var body: some View {
        ProfileV3TabShape()
            .fill(ProfileV3Theme.collapseTabGradient)
            .frame(width: ProfileV3Theme.Sizes.Collapse.tabShapeWidth, height: ProfileV3Theme.Sizes.Collapse.tabHeight)
            .frame(width: ProfileV3Theme.Sizes.Collapse.tabWidth)
            .accessibilityHidden(true)
    }
}

private struct ProfileV3KYCNotchShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 203
        let sy = rect.height / 36
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()
        path.move(to: point(0, 0))
        path.addLine(to: point(203, 0))
        path.addLine(to: point(188.715, 25.7129))
        path.addCurve(to: point(171.232, 36), control1: point(185.188, 32.0622), control2: point(178.495, 36))
        path.addLine(to: point(31.7681, 36))
        path.addCurve(to: point(14.2849, 25.7129), control1: point(24.5047, 36), control2: point(17.8123, 32.0622))
        path.closeSubpath()
        return path
    }
}

struct ProfileV3KYCNotch: View {
    let text: String

    var body: some View {
        ZStack(alignment: .top) {
            ProfileV3KYCNotchShape()
                .fill(Color(at: .pureWhite))
            ProfileV3KYCNotchShape()
                .fill(ProfileV3Theme.collapseNotchGradient)
            ProfileV3KYCNotchShape()
                .stroke(ProfileV3Theme.collapseNotchStrokeGradient, lineWidth: ProfileV3Theme.Stroke.hairline)
            ProfileV3TagLabel.kyc(text)
                .padding(.top, ProfileV3Theme.Space.s10)
        }
        .frame(width: ProfileV3Theme.Sizes.Collapse.notchWidth, height: ProfileV3Theme.Sizes.Collapse.notchHeight)
        .compositingGroup()
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Collapsed tab and KYC notch") {
    VStack(spacing: ProfileV3Theme.Space.s20) {
        ProfileV3CollapsedTab()
        ProfileV3KYCNotch(text: ProfileV3Strings.kycIncomplete)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
