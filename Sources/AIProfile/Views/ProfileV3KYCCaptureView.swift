import ATUIKit
import SwiftUI

struct ProfileV3KYCCaptureView: View {
    @ObservedObject var viewModel: ProfileV3KYCCaptureViewModel

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(at: .pureWhite).ignoresSafeArea())
            .onAppear(perform: viewModel.start)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .loading, .finished:
            ProfileV3Spinner()
        case .gmail(let gmail):
            viewModel.kyc.gmailConnectView(viewModel.gmailScreen(gmail), actions: viewModel.gmailActions)
        case .itr(let itr):
            viewModel.kyc.itrConnectView(viewModel.itrScreen(itr), actions: viewModel.itrActions)
        case .passport(let stepID, let front, let back):
            viewModel.kyc.passportCaptureView(
                viewModel.passportScreen(stepID: stepID, front: front, back: back),
                actions: viewModel.passportActions
            )
            .id(stepID ?? viewModel.capture.profileID)
        case .selfie(let stepID, let copy):
            viewModel.kyc.selfieCaptureView(viewModel.selfieScreen(copy: copy), actions: viewModel.selfieActions)
                .id(stepID ?? viewModel.capture.profileID)
        case .failed(let message):
            ZStack(alignment: .top) {
                VStack(spacing: ProfileV3Theme.Space.s20) {
                    ProfileV3AtlysOrb(ring: .muted)
                    ProfileV3RetryPanel(message: message, action: viewModel.retry)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                ProfileV3CloseBar(action: viewModel.leave)
            }
        }
    }
}

#if DEBUG
#Preview("Loading") {
    ProfileV3KYCCaptureView(viewModel: .preview(.loading))
}

#Preview("Gmail") {
    ProfileV3KYCCaptureView(viewModel: .preview(.gmail(.init(step: ProfileV3Fixtures.gmailCaptureStep))))
}

#Preview("Gmail connecting") {
    ProfileV3KYCCaptureView(
        viewModel: .preview(.gmail(.init(step: ProfileV3Fixtures.gmailCaptureStep, isConnecting: true)))
    )
}

#Preview("ITR") {
    ProfileV3KYCCaptureView(viewModel: .preview(.itr(.init(step: ProfileV3Fixtures.itrCaptureStep))))
}

#Preview("ITR completed") {
    ProfileV3KYCCaptureView(viewModel: .preview(.itr(.init(step: ProfileV3Fixtures.itrCompletedCaptureStep))))
}

#Preview("Passport") {
    ProfileV3KYCCaptureView(viewModel: .preview(.passport(stepID: "passport", front: nil, back: nil)))
}

#Preview("Selfie") {
    ProfileV3KYCCaptureView(viewModel: .preview(.selfie(stepID: "selfie", copy: nil)))
}

#Preview("Failed") {
    ProfileV3KYCCaptureView(viewModel: .preview(.failed(ProfileV3Strings.somethingWentWrong)))
}
#endif
