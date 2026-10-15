import ATUIKit
import SwiftUI

struct ProfileV3RetryPanel: View {
    let message: String
    var actionTitle = ProfileV3Strings.retry
    let action: () -> Void

    var body: some View {
        VStack(spacing: ProfileV3Theme.Space.s20) {
            Text(message)
                .typoGraphy(.B2InterSemibold12)
                .foregroundStyle(Color(at: .neutralGrey400))
                .multilineTextAlignment(.center)
                .frame(maxWidth: ProfileV3Theme.Sizes.Agent.summaryWidth)
            ProfileV3PillButton(title: actionTitle, size: .large, action: action)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, ProfileV3Theme.Space.s32)
        .accessibilityElement(children: .contain)
        .profileV3FeedbackOnAppear(.error)
    }
}

#if DEBUG
#Preview("Retry panel") {
    ProfileV3RetryPanel(message: ProfileV3Strings.loadFailed, action: {})
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}
#endif
