import ATUIKit
import SwiftUI

struct ProfileV3LoadStateView: View {
    let phase: ProfileV3LoadPhase
    var loadingLabel = ProfileV3Strings.loading
    let retry: () -> Void

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .loading:
            ProfileV3Spinner(accessibilityLabel: loadingLabel)
                .transition(.opacity)
        case .failed:
            ProfileV3StatusPanel(
                title: ProfileV3Strings.loadFailedTitle,
                subtitle: ProfileV3Strings.loadFailedSubtitle,
                actionTitle: ProfileV3Strings.retry,
                action: retry
            )
            .profileV3FeedbackOnAppear(.error)
            .transition(.opacity)
        case .loaded:
            EmptyView()
        }
    }
}

#if DEBUG
#Preview("Load state · loading") {
    ProfileV3LoadStateView(phase: .loading, retry: {})
        .background(Color(at: .pureWhite))
}

#Preview("Load state · failed") {
    ProfileV3LoadStateView(phase: .failed, retry: {})
        .background(Color(at: .pureWhite))
}
#endif
