import ATUIKit
import SwiftUI

struct ProfileV3BenefitMeter: View {
    let status: ProfileV3Benefit.Status

    var body: some View {
        if case .partiallyRedeemed(_, _, let progress) = status {
            VStack(spacing: ProfileV3Theme.Space.s16) {
                ProfileV3ProgressBar(progress: progress)
                ProfileV3BenefitFooter(status: status)
            }
        }
    }
}

struct ProfileV3ProgressBar: View {
    let progress: Double
    var track: Color = ProfileV3Theme.Palette.benefitMeterTrack
    var height: CGFloat = ProfileV3Theme.Sizes.Benefit.meterHeight
    var width: CGFloat? = ProfileV3Theme.Sizes.Benefit.meterWidth

    private var clamped: Double { min(max(progress, 0), 1) }

    var body: some View {
        Capsule()
            .fill(track)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(Color(at: .accentEmerald500))
                        .frame(width: proxy.size.width * clamped)
                }
            }
            .animation(ProfileV3Theme.Motion.expand, value: clamped)
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Benefit meter") {
    VStack(spacing: ProfileV3Theme.Space.s32) {
        ProfileV3BenefitMeter(status: ProfileV3Fixtures.partiallyRedeemedBenefit.status)
        ProfileV3BenefitMeter(status: ProfileV3Fixtures.giftCards[1].status)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
