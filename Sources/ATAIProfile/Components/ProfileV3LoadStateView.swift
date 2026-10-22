import ATUIKit
import SwiftUI

struct ProfileV3LoadStateView: View {
    enum FailureStyle {
        case statusPanel
        case errorState
    }

    let phase: ProfileV3LoadPhase
    var loadingLabel = ProfileV3Strings.loading
    var failureStyle = FailureStyle.statusPanel
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
            failure
                .profileV3FeedbackOnAppear(.error)
                .transition(.opacity)
        case .loaded:
            EmptyView()
        }
    }

    @ViewBuilder
    private var failure: some View {
        switch failureStyle {
        case .statusPanel:
            ProfileV3StatusPanel(
                title: ProfileV3Strings.loadFailedTitle,
                subtitle: ProfileV3Strings.loadFailedSubtitle,
                actionTitle: ProfileV3Strings.retry,
                action: retry
            )
        case .errorState:
            ProfileV3ErrorState(action: retry)
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

#Preview("Load state · error state") {
    ProfileV3LoadStateView(phase: .failed, failureStyle: .errorState, retry: {})
        .background(Color(at: .pureWhite))
}
#endif
