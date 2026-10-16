import ATUIKit
import SwiftUI

struct ProfileV3TravellerCardLip: View {
    var body: some View {
        ProfileV3TravellerCardLipShape()
            .fill(ProfileV3Theme.travellerCardLipGradient)
            .frame(
                width: ProfileV3Theme.Sizes.Traveller.cardLipWidth,
                height: ProfileV3Theme.Sizes.Traveller.cardLipHeight
            )
            .accessibilityHidden(true)
    }
}

private struct ProfileV3TravellerCardLipShape: Shape {
    private static let designWidth: CGFloat = 207.814
    private static let designHeight: CGFloat = 7

    func path(in rect: CGRect) -> Path {
        let scaleX: CGFloat = rect.width / Self.designWidth
        let scaleY: CGFloat = rect.height / Self.designHeight
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * scaleX, y: rect.minY + y * scaleY)
        }
        var path = Path()
        path.move(to: point(11.4142, 0.667867))
        path.addCurve(to: point(14.8165, 0), control1: point(12.4943, 0.22683), control2: point(13.6498, 0))
        path.addLine(to: point(192.997, 0))
        path.addCurve(to: point(196.4, 0.667867), control1: point(194.164, 0), control2: point(195.32, 0.226831))
        path.addLine(to: point(207.191, 5.07421))
        path.addCurve(to: point(206.813, 7), control1: point(208.206, 5.48893), control2: point(207.91, 7))
        path.addLine(to: point(1.00121, 7))
        path.addCurve(to: point(0.623189, 5.07421), control1: point(-0.0958357, 7), control2: point(-0.392449, 5.48893))
        path.closeSubpath()
        return path
    }
}

#if DEBUG
#Preview("Traveller card lip") {
    ProfileV3TravellerCardLip()
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}
#endif
