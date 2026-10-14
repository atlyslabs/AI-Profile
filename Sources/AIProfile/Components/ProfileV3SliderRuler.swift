import ATUIKit
import SwiftUI

struct ProfileV3SliderRuler: View {
    var body: some View {
        Canvas { context, size in
            let count = ProfileV3Theme.Counts.sliderRulerTicks
            let width = ProfileV3Theme.Stroke.medium
            let pitch = (size.width - width) / CGFloat(max(count - 1, 1))
            var ticks = Path()
            for index in 0..<count {
                let isMajor = index % ProfileV3Theme.Counts.sliderRulerMajorInterval
                    == ProfileV3Theme.Counts.sliderRulerMajorPhase
                let height = isMajor ? size.height : ProfileV3Theme.Sizes.sliderMinorTickHeight
                let rect = CGRect(
                    x: CGFloat(index) * pitch,
                    y: (size.height - height) / 2,
                    width: width,
                    height: height
                )
                ticks.addPath(Path(roundedRect: rect, cornerRadius: width / 2))
            }
            context.fill(
                ticks,
                with: .linearGradient(
                    ProfileV3Theme.sliderRulerGradient,
                    startPoint: .zero,
                    endPoint: CGPoint(x: size.width, y: 0)
                )
            )
        }
        .frame(height: ProfileV3Theme.Sizes.sliderRulerHeight)
        .opacity(ProfileV3Theme.Opacity.sliderRuler)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Slider ruler") {
    ProfileV3SliderRuler()
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}
#endif
