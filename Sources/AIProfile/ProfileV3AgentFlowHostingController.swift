import ATUIKit
import SwiftUI
import UIKit

final class ProfileV3AgentFlowHostingController: UIHostingController<ProfileV3AgentFlowView> {
    private let viewModel: ProfileV3AgentFlowViewModel
    private let repository: any ProfileV3AgentRepository
    private let identityCapture: any ProfileV3IdentityCaptureHost

    init(
        agent: ProfileV3Agent,
        profileID: String?,
        repository: any ProfileV3AgentRepository,
        identityCapture: any ProfileV3IdentityCaptureHost,
        residenceCode: @escaping @MainActor () -> String? = { nil }
    ) {
        let viewModel = ProfileV3AgentFlowViewModel(
            agent: agent,
            profileID: profileID,
            repository: repository,
            residenceCode: residenceCode
        )
        self.viewModel = viewModel
        self.repository = repository
        self.identityCapture = identityCapture
        super.init(rootView: ProfileV3AgentFlowView(viewModel: viewModel))
        viewModel.router = self
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = ProfileV3Theme.Sizes.Agent.sheetCornerRadius
        }
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileV3Analytics.screen(.agent, agentKey: ProfileV3Analytics.agentKey(viewModel.agent.id))
        view.backgroundColor = UIColor(Color(at: .pureWhite))
    }

    private var topPresented: UIViewController {
        var top: UIViewController = self
        while let presented = top.presentedViewController, !presented.isBeingDismissed {
            top = presented
        }
        return top
    }

    private func presentPassportHowUsed() {
        let viewModel = ProfileV3PassportHowUsedViewModel(repository: repository)
        topPresented.present(ProfileV3PassportHowUsedHostingController(viewModel: viewModel), animated: true)
    }
}

extension ProfileV3AgentFlowHostingController: ProfileV3AgentFlowRouter {
    func dismissAgentFlow() {
        presentingViewController?.dismiss(animated: true)
    }

    func presentPassportScan(_ request: ProfileV3PassportScanRequest) {
        ProfileV3PassportScanLauncher.present(using: identityCapture, from: topPresented, request: request) { [weak self] in
            self?.presentPassportHowUsed()
        }
    }
}
