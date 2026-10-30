import ATUIKit
import SwiftUI

struct ProfileV3SaveBar<Content: View>: View {
    var error: String?
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .bottom) {
            ProfileV3SaveBarFade()
            VStack(spacing: ProfileV3Theme.Space.s12) {
                if let error {
                    ProfileV3ErrorText(text: error, style: .bar)
                        .multilineTextAlignment(.center)
                }
                content
            }
            .padding(.bottom, ProfileV3Theme.Sizes.Save.barBottom)
        }
    }
}

struct ProfileV3SubmitControl: View {
    let phase: ProfileV3SavePhase
    let title: String
    let successMessage: String
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        ZStack {
            switch phase {
            case .idle, .failed:
                ProfileV3ContinueButton(
                    title: title,
                    disabledTint: Color(at: .neutralGrey400),
                    isEnabled: isEnabled,
                    action: action
                )
                .transition(.opacity)
            case .saving:
                ProfileV3Spinner(size: ProfileV3Theme.Icon.xl, lineWidth: ProfileV3Theme.Stroke.regular)
                    .frame(maxWidth: .infinity)
                    .frame(height: ProfileV3Theme.Sizes.Save.buttonHeight)
                    .profileV3CapsuleChrome()
                    .transition(.opacity)
            case .saved:
                ProfileV3Toast(message: successMessage)
                    .transition(.opacity)
            }
        }
        .animation(ProfileV3Theme.Motion.saveState, value: phase)
    }
}

#if DEBUG
#Preview("Save bar and submit control") {
    VStack(spacing: ProfileV3Theme.Space.s24) {
        ForEach([ProfileV3SavePhase.idle, .saving, .saved], id: \.self) { phase in
            ProfileV3SubmitControl(phase: phase, title: ProfileV3Strings.continueTitle, successMessage: "Saved") {}
        }
        ProfileV3SaveBar(error: ProfileV3Strings.saveFailed) {
            ProfileV3SaveButton(
                phase: .idle,
                title: ProfileV3Strings.saveChanges,
                savedTitle: ProfileV3Strings.agentPreferencesUpdated
            ) {}
        }
    }
    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
