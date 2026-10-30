import ATUIKit
import SwiftUI

struct ProfileV3BackTagHeader: View {
    let title: String?
    var titleOpacity: Double = 1
    var step: (current: Int, count: Int)?
    var top: CGFloat = ProfileV3Theme.Sizes.Passport.headerTop
    let onBack: () -> Void

    var body: some View {
        ZStack {
            if let title {
                ProfileV3TagLabel(text: title)
                    .overlay(alignment: .bottom) {
                        if let step {
                            ProfileV3StepIndicator(count: step.count, current: step.current, style: .currentOnly)
                                .offset(y: ProfileV3Theme.Sizes.Passport.stepTop + ProfileV3Theme.Sizes.stepBarHeight)
                        }
                    }
                    .opacity(titleOpacity)
                    .accessibilityHidden(titleOpacity == 0)
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
    ProfileV3BackTagHeader(title: "PREVIOUS PASSPORTS") {}
        .background(Color(at: .pureWhite))
}
#endif
