import ATUIKit
import SwiftUI

struct ProfileV3SkeletonCard: View {
    var height: CGFloat = ProfileV3Theme.Sizes.skeletonCardHeight

    var body: some View {
        Color(at: .pureWhite)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .profileV3Card()
            .shimmer()
    }
}

#if DEBUG
#Preview("Skeleton cards") {
    VStack(spacing: ProfileV3Theme.Space.s20) {
        ProfileV3SkeletonCard()
        ProfileV3SkeletonCard(height: 144)
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
