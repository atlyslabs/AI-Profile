import ATUIKit
import SwiftUI

struct ProfileV3ProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(ProfileV3Theme.Palette.ringTrack, lineWidth: ProfileV3Theme.Stroke.thick)
                .padding(ProfileV3Theme.Stroke.thick / 2)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    Color(at: .accentEmerald500),
                    style: StrokeStyle(lineWidth: ProfileV3Theme.Stroke.thick, lineCap: .round)
                )
                .rotationEffect(.degrees(-ProfileV3Theme.Rotation.quarter))
                .padding(ProfileV3Theme.Stroke.thick / 2)
            Circle()
                .fill(Color(at: .pureWhite))
                .frame(width: ProfileV3Theme.Sizes.progressRingInner, height: ProfileV3Theme.Sizes.progressRingInner)
                .shadow(
                    color: ProfileV3Theme.Palette.shadow,
                    radius: ProfileV3Theme.Shadow.ringRadius,
                    y: ProfileV3Theme.Shadow.ringY
                )
            ATIcon.SwiftUIImage.flight
                .profileV3Icon(ProfileV3Theme.Icon.xl)
                .foregroundStyle(ProfileV3Theme.Palette.ringIcon)
        }
        .frame(width: ProfileV3Theme.Sizes.progressRing, height: ProfileV3Theme.Sizes.progressRing)
        .animation(ProfileV3Theme.Motion.expand, value: progress)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Progress rings") {
    HStack(spacing: ProfileV3Theme.Space.s20) {
        ProfileV3ProgressRing(progress: 0.1)
        ProfileV3ProgressRing(progress: 0.4)
        ProfileV3ProgressRing(progress: 0.85)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
