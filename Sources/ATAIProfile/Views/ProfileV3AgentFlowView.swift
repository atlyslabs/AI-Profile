import ATUIKit
import SwiftUI

struct ProfileV3AgentFlowView: View {
    @ObservedObject var viewModel: ProfileV3AgentFlowViewModel

    var body: some View {
        Group {
            switch viewModel.content {
            case .loading:
                loading
            case .failed:
                failed
            case .form(let formViewModel):
                ProfileV3AgentFormView(viewModel: formViewModel)
            }
        }
        .background(Color(at: .pureWhite))
        .profileV3TapToDismissKeyboard()
        .task { await viewModel.load() }
    }

    private var header: some View {
        ProfileV3AgentSheetHeader(tag: viewModel.sheetTag, avatarURL: viewModel.avatarURL, onBack: viewModel.finish)
    }

    private var loading: some View {
        VStack(spacing: ProfileV3Theme.Space.s20) {
            header
            ProfileV3Spinner(accessibilityLabel: ProfileV3Strings.loadingAgent)
                .padding(.top, ProfileV3Theme.Space.s32)
            Text(ProfileV3Strings.loadingAgent)
                .typoGraphy(.B2InterSemibold12)
                .foregroundStyle(Color(at: .neutralGrey400))
                .multilineTextAlignment(.center)
                .frame(width: ProfileV3Theme.Sizes.Agent.summaryWidth)
            Spacer()
        }
    }

    private var failed: some View {
        VStack(spacing: ProfileV3Theme.Space.s20) {
            header
            ProfileV3RetryPanel(
                message: ProfileV3Strings.agentUnavailable,
                actionTitle: ProfileV3Strings.tryAgain,
                action: viewModel.retry
            )
            Spacer()
        }
    }
}

#if DEBUG
#Preview("Agent flow · flight") {
    ProfileV3AgentFlowView(
        viewModel: ProfileV3AgentFlowViewModel(
            agent: ProfileV3Fixtures.agents[0],
            repository: ProfileV3MockRepository()
        )
    )
}

#Preview("Agent flow · loading") {
    ProfileV3AgentFlowView(
        viewModel: ProfileV3AgentFlowViewModel(
            agent: ProfileV3Fixtures.agents[0],
            repository: ProfileV3MockRepository(delay: .seconds(60))
        )
    )
}

#Preview("Agent flow · failed") {
    ProfileV3AgentFlowView(
        viewModel: ProfileV3AgentFlowViewModel(
            agent: ProfileV3Fixtures.agents[0],
            repository: ProfileV3FailingRepository()
        )
    )
}

#Preview("Agent flow · airport logistics") {
    ProfileV3AgentFlowView(
        viewModel: ProfileV3AgentFlowViewModel(
            agent: ProfileV3Fixtures.agents[2],
            repository: ProfileV3MockRepository()
        )
    )
}
#endif
