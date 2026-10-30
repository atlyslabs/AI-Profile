import ATUIKit
import SwiftUI

private struct ProfileV3NotchedCardShape: Shape {
    var cornerRadius: CGFloat
    var notchWidth: CGFloat
    var notchHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        let r = cornerRadius
        let top = rect.minY + notchHeight
        let scale = notchWidth / 25
        let nx = rect.midX - notchWidth / 2
        func n(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: nx + x * scale, y: top - (7 - y) * (notchHeight / 7))
        }
        var path = Path()
        path.move(to: n(7.547, 2.0517))
        path.addCurve(to: n(17.447, 2.0517), control1: n(10.28, -0.6819), control2: n(14.714, -0.6819))
        path.addCurve(to: n(24.994, 7), control1: n(19.594, 4.1986), control2: n(21.958, 7))
        path.addLine(to: CGPoint(x: rect.maxX - r, y: top))
        path.addArc(center: CGPoint(x: rect.maxX - r, y: top + r), radius: r,
                    startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r), radius: r,
                    startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + r, y: rect.maxY - r), radius: r,
                    startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: top + r))
        path.addArc(center: CGPoint(x: rect.minX + r, y: top + r), radius: r,
                    startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.addLine(to: n(0, 7))
        path.addCurve(to: n(7.547, 2.0517), control1: n(3.036, 7), control2: n(5.4, 4.1986))
        path.closeSubpath()
        return path
    }
}

struct ProfileV3KYCProgressCard: View {
    let headline: String
    let progress: ProfileV3KYCProgress
    var onTap: (() -> Void)?

    private var shape: ProfileV3NotchedCardShape {
        ProfileV3NotchedCardShape(
            cornerRadius: ProfileV3Theme.Sizes.cardCornerRadius,
            notchWidth: ProfileV3Theme.Sizes.KYCCard.notchWidth,
            notchHeight: ProfileV3Theme.Sizes.KYCCard.notchHeight
        )
    }

    var body: some View {
        Button(action: { onTap?() }) { card }
            .buttonStyle(.profileV3Pressable)
            .disabled(onTap == nil)
    }

    private var card: some View {
        VStack(spacing: ProfileV3Theme.Space.s16) {
            HStack(spacing: 0) {
                ProfileV3TagLabel(text: headline)
                Spacer(minLength: ProfileV3Theme.Space.s16)
                HStack(spacing: 0) {
                    Text(ProfileV3Strings.kycStepFraction(done: progress.done, total: progress.total))
                        .foregroundStyle(Color(at: .pureBlack))
                    Text(ProfileV3Strings.kycStepsDone)
                        .foregroundStyle(Color(at: .neutralGrey500))
                }
                .typoGraphy(.T1InterBold11)
                .textCase(.uppercase)
            }
            bar
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, ProfileV3Theme.Sizes.KYCCard.contentTop)
        .padding(.bottom, ProfileV3Theme.Space.s32)
        .frame(maxWidth: .infinity)
        .profileV3Card(shape: shape)
        .padding(.top, ProfileV3Theme.Sizes.KYCCard.notchHeight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(headline) \(ProfileV3Strings.kycStepFraction(done: progress.done, total: progress.total))"
                + ProfileV3Strings.kycStepsDone
        )
    }

    private var bar: some View {
        ProfileV3ProgressBar(
            progress: progress.fraction,
            track: ProfileV3Theme.Palette.kycProgressTrack,
            height: ProfileV3Theme.Sizes.KYCCard.barHeight,
            width: nil
        )
    }
}

#if DEBUG
#Preview("KYC progress card") {
    VStack(spacing: ProfileV3Theme.Space.s20) {
        ProfileV3TagLabel.kyc(ProfileV3Strings.kycIncomplete)
        ProfileV3KYCProgressCard(
            headline: ProfileV3Strings.kycAlmostThere,
            progress: ProfileV3KYCProgress(done: 4, total: 6)
        )
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(ProfileV3Theme.Palette.background)
}
#endif
