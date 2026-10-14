import ATUIKit
import SwiftUI

struct ProfileV3GradientStatusText: View {
    let text: String

    var body: some View {
        Text(text)
            .typoGraphy(.B1InterSemibold14)
            .foregroundStyle(ProfileV3Theme.statusTextGradient)
            .multilineTextAlignment(.center)
    }
}

#if DEBUG
#Preview("Gradient status text") {
    VStack(spacing: ProfileV3Theme.Space.s20) {
        ProfileV3GradientStatusText(text: ProfileV3Strings.goingThroughEmails)
        ProfileV3GradientStatusText(text: ProfileV3Strings.redirectingToKYC)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
