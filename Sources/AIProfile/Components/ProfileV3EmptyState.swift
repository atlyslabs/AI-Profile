import ATUIKit
import SwiftUI

struct ProfileV3EmptyState: View {
    let icon: Image
    let title: String
    var subtitle: String?
    var iconGap: CGFloat = ProfileV3Theme.Space.s16

    var body: some View {
        VStack(spacing: ProfileV3Theme.Space.s16) {
            icon
                .profileV3Icon(ProfileV3Theme.Sizes.emptyStateIcon)
                .foregroundStyle(Color(at: .neutralGrey400))
                .padding(.bottom, iconGap)
            Text(title)
                .typoGraphy(.H6InterMedium18)
                .foregroundStyle(ProfileV3Theme.Palette.emptyStateTitle)
            if let subtitle {
                Text(subtitle)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey400))
            }
        }
        .multilineTextAlignment(.center)
    }
}

#if DEBUG
#Preview("Empty state") {
    ProfileV3EmptyState(
        icon: ATIcon.SwiftUIImage.search,
        title: ProfileV3Strings.searchEmptyTitle,
        subtitle: ProfileV3Strings.searchEmptySubtitle
    )
    .frame(width: ProfileV3Theme.Sizes.emptyStateTextWidth)
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
