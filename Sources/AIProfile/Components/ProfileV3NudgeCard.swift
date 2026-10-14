import ATUIKit
import SwiftUI

struct ProfileV3NudgeCard: View {
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: ProfileV3Theme.Space.s16) {
            Button(action: action) {
                VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s8) {
                    Text(message)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                    Text(actionTitle)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(Color(at: .accentEmerald600))
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.profileV3Pressable)
            .accessibilityLabel(ProfileV3Strings.nudgeAccessibility(message: message, action: actionTitle))
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.cardContentPadding)
        .padding(.vertical, ProfileV3Theme.Space.s20)
        .profileV3Card()
    }
}

#if DEBUG
#Preview("Nudge card") {
    ProfileV3NudgeCard(
        message: ProfileV3Strings.kycRegainAccess,
        actionTitle: ProfileV3Strings.completeKYC,
        action: {}
    )
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
