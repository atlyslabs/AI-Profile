import ATUIKit
import SwiftUI

struct ProfileV3BackTagHeader: View {
    let title: String
    var step: (current: Int, count: Int)?
    var top: CGFloat = ProfileV3Theme.Sizes.Passport.headerTop
    let onBack: () -> Void

    var body: some View {
        ZStack {
            ProfileV3TagLabel(text: title)
                .overlay(alignment: .bottom) {
                    if let step {
                        ProfileV3StepIndicator(count: step.count, current: step.current, style: .currentOnly)
                            .alignmentGuide(.bottom) { $0[.top] - ProfileV3Theme.Sizes.Passport.stepTop }
                    }
                }
            HStack {
                ProfileV3CircleIconButton.back(action: onBack)
                Spacer()
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, top)
    }
}

#if DEBUG
#Preview("Back and tag header") {
    ProfileV3BackTagHeader(title: ProfileV3Strings.previousPassports) {}
        .background(Color(at: .pureWhite))
}
#endif
