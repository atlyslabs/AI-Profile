import ATUIKit
import SwiftUI

struct ProfileV3DetailGlow: View {
    var body: some View {
        ZStack {
            RadialGradient(
                colors: [ProfileV3Theme.Palette.glowPink, .clear],
                center: UnitPoint(x: 0.32, y: 0.5),
                startRadius: 0,
                endRadius: ProfileV3Theme.Sizes.BenefitDetail.glowRadius
            )
            RadialGradient(
                colors: [ProfileV3Theme.Palette.glowYellow, .clear],
                center: UnitPoint(x: 0.68, y: 0.3),
                startRadius: 0,
                endRadius: ProfileV3Theme.Sizes.BenefitDetail.glowRadius
            )
            RadialGradient(
                colors: [ProfileV3Theme.Palette.glowLavender, .clear],
                center: UnitPoint(x: 0.5, y: 0.78),
                startRadius: 0,
                endRadius: ProfileV3Theme.Sizes.BenefitDetail.glowRadius
            )
        }
        .frame(width: ProfileV3Theme.Sizes.BenefitDetail.glow, height: ProfileV3Theme.Sizes.BenefitDetail.glow)
        .blur(radius: ProfileV3Theme.Sizes.BenefitDetail.glowBlur)
        .allowsHitTesting(false)
    }
}

