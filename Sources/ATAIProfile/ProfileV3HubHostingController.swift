import ATUIKit
import SwiftUI
import UIKit

final class ProfileV3HubHostingController: UIHostingController<ProfileV3HubRoot> {

    private unowned let navCon: UINavigationController
    private let onBack: (() -> Void)?
    private let viewModel: ProfileV3HubViewModel
    private let repository: any ProfileV3Repository
    private let environment: ProfileV3Environment
    private var settingsPresenter: ProfileV3SettingsSheetPresenter?
    private var addProgrammePresenter: ProfileV3AddProgrammeSheetPresenter?
    private let programmeSelections = ProfileV3ProgrammeSelectionMemory()
    private let entrySource: ProfileV3Analytics.EntrySource

    init(
        navCon: UINavigationController,
        repository: any ProfileV3Repository,
        environment: ProfileV3Environment,
        userFirstName: String?,
        entrySource: ProfileV3Analytics.EntrySource,
        onBack: (() -> Void)? = nil
    ) {
        self.navCon = navCon
        self.entrySource = entrySource
        self.onBack = onBack
        self.repository = repository
        self.environment = environment
        let viewModel = ProfileV3HubViewModel(
            repository: repository,
            userFirstName: userFirstName,
            addsTripsWithoutDate: environment.app.addsPastTripsWithoutDate
        )
        self.viewModel = viewModel
        super.init(rootView: ProfileV3HubRoot(
            viewModel: viewModel,
            globe: environment.globe,
            floatingBarClearance: environment.app.floatingBarClearance
        ))
        viewModel.router = self
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(Color(at: .pureWhite))
        ProfileV3Analytics.screen(.hub, entrySource: entrySource)
    }
}

extension ProfileV3HubHostingController: ProfileV3HubRouter {

    func goBack() {
        if let onBack {
            onBack()
        } else {
            _ = navCon.popViewController(animated: true)
        }
    }

    func openSettings(profileID: String?) {
        makeSettingsPresenter(profileID: profileID).present()
    }

    private func makeSettingsPresenter(profileID: String?) -> ProfileV3SettingsSheetPresenter {
        let presenter = ProfileV3SettingsSheetPresenter(
            navCon: navCon,
            repository: repository,
            board: repository,
            kyc: environment.kyc,
            account: environment.account,
            coupons: environment.coupons,
            app: environment.app,
            session: environment.session,
            client: environment.client,
            profileID: profileID,
            profileName: viewModel.mainProfileName,
            onConnectConnector: { [weak self] step in self?.startConnectorCapture(step) },
            onTravellersChanged: { [weak viewModel] in viewModel?.requestRefresh() },
            onConnectorsDisconnected: { [weak viewModel] in viewModel?.refreshAfterDisconnecting($0) },
            onOpenProgrammes: { [weak viewModel] in viewModel?.tapMainProgrammes() },
            onFinish: { [weak self] finished in
                guard self?.settingsPresenter === finished else { return }
                self?.settingsPresenter = nil
            }
        )
        settingsPresenter = presenter
        return presenter
    }

    func openKnowMore(_ directive: ProfileV3Directive?) {
        let route = directive?.route() ?? .worldPassAbout
        guard route == .worldPassAbout || route == .termsOfService else { return }
        presentOnTop(ProfileV3EntryPoint.makeTerms(repository: repository))
    }

    func openTravelPersona(profileID: String?) {
        present(ProfileV3EntryPoint.makeTravelPersona(profileID: profileID, repository: repository), animated: true)
    }

    func openAgent(_ agent: ProfileV3Agent, requiresKYC: Bool, profileID: String?) {
        guard requiresKYC else {
            present(
                ProfileV3EntryPoint.makeAgentFlow(
                    agent: agent,
                    profileID: profileID,
                    repository: repository,
                    identityCapture: environment.identityCapture,
                    residenceCode: { [account = environment.account] in account.snapshot().residenceCode },
                    onSaved: { [weak viewModel] in viewModel?.requestRefresh() }
                ),
                animated: true
            )
            return
        }
        let host = ProfileV3EntryPoint.makeKYCRedirect(
            for: .agent(agent),
            status: viewModel.gateKYCStatus,
            onClose: { [weak self] in self?.presentedViewController?.dismiss(animated: true) },
            onRedirect: { [weak self] in
                self?.presentedViewController?.dismiss(animated: true) {
                    self?.startKYC(resuming: .agent(agent))
                }
            }
        )
        present(host, animated: true)
    }

    func openAddProgramme(requiresKYC: Bool, profileID: String?) {
        guard requiresKYC else {
            let presenter = ProfileV3AddProgrammeSheetPresenter(
                profileID: profileID,
                repository: repository,
                selections: programmeSelections,
                onAdded: { [weak viewModel] in viewModel?.requestRefresh() },
                onRedirectToKYC: { [weak self] in self?.startKYC(resuming: .addProgramme) },
                onFinish: { [weak self] finished in
                    guard self?.addProgrammePresenter === finished else { return }
                    self?.addProgrammePresenter = nil
                }
            )
            addProgrammePresenter = presenter
            presenter.present(from: self)
            return
        }
        let host = ProfileV3EntryPoint.makeAddProgramme(
            requiresKYC: requiresKYC,
            profileID: profileID,
            repository: repository,
            selections: programmeSelections,
            onAdded: { [weak viewModel] in viewModel?.requestRefresh() },
            onRedirectToKYC: { [weak self] in self?.startKYC(resuming: .addProgramme) }
        )
        presentOnTop(host)
    }

    func openProgrammes(for pass: ProfileV3WorldPass, passes: [ProfileV3WorldPass]) {
        let app = environment.app
        let events = ProfileV3ProgrammesEvents(
            requiresKYC: { [weak viewModel] in viewModel?.addProgrammeRequiresKYC(for: $0) ?? false },
            onProgrammesChanged: { [weak viewModel] in viewModel?.requestRefresh() },
            onPassChanged: { [weak viewModel] in viewModel?.selectPass(id: $0.id) },
            onUseInsight: { [weak self] in self?.afterSettings { self?.viewModel.useInsight() } },
            onOpenChat: app.opensChat ? { app.openChat(prompt: $0) } : nil,
            onOpenBenefits: { [weak self] in self?.afterSettings { self?.viewModel.tapViewAllBenefits() } },
            onRequestKYC: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.startKYC(resuming: .addProgramme)
                }
            }
        )
        let host = ProfileV3EntryPoint.makeProgrammes(
            pass: pass,
            passes: passes,
            repository: repository,
            selections: programmeSelections,
            events: events
        )
        presentOnTop(host)
    }

    func openKYC() {
        startKYC(resuming: .none)
    }

    func openBenefitKYC(_ benefit: ProfileV3Benefit) {
        let host = ProfileV3EntryPoint.makeKYCRedirect(
            for: .benefit(benefit),
            status: viewModel.gateKYCStatus,
            onClose: { [weak self] in self?.presentedViewController?.dismiss(animated: true) },
            onRedirect: { [weak self] in
                self?.presentedViewController?.dismiss(animated: true) {
                    self?.startKYC(resuming: .benefit(benefit))
                }
            }
        )
        present(host, animated: true)
    }

    func openAddTraveller() {
        afterSettings { [weak self] in
            guard let self else { return }
            makeSettingsPresenter(profileID: viewModel.mainProfileID).presentAddTraveller()
        }
    }
}

extension ProfileV3HubHostingController {

    private func presentOnTop(_ controller: UIViewController) {
        var top: UIViewController = self
        while let next = top.presentedViewController, !next.isBeingDismissed {
            top = next
        }
        top.present(controller, animated: true)
    }

    private func startConnectorCapture(_ step: String) {
        guard let mainProfileID = viewModel.mainProfileID else { return }
        presentKYCCapture(.connector(step, profileID: mainProfileID))
    }

    private func afterSettings(_ action: @escaping () -> Void) {
        guard let settingsPresenter, settingsPresenter.isOpen else {
            action()
            return
        }
        settingsPresenter.close(then: action)
    }

    private func startKYC(resuming: ProfileV3HubViewModel.KYCResumption) {
        if let settingsPresenter, settingsPresenter.isOpen {
            settingsPresenter.close { [weak self] in self?.startKYC(resuming: resuming) }
            return
        }
        switch viewModel.kycFlow(resuming: resuming) {
        case .capture(let capture):
            presentKYCCapture(capture)
        case .refreshBoard:
            viewModel.requestRefresh()
        case .minimal:
            presentMinimalKYC(resuming: resuming)
        case .onboarding:
            presentOnboardingKYC(resuming: resuming)
        case .alreadyComplete:
            return
        }
    }

    private func presentKYCCapture(_ capture: ProfileV3KYCCapture) {
        weak var host: UIViewController?
        let captureViewModel = ProfileV3KYCCaptureViewModel(
            capture: capture,
            repository: repository,
            kyc: environment.kyc,
            onFinish: { [weak self] completedSteps in
                let refresh: () -> Void = {
                    self?.viewModel.refreshAfterCapture(profileID: capture.profileID, completedSteps: completedSteps)
                }
                guard let host else {
                    refresh()
                    return
                }
                let dismiss = { host.dismiss(animated: true, completion: refresh) }
                if host.isBeingPresented,
                   let coordinator = host.transitionCoordinator,
                   coordinator.animate(alongsideTransition: nil, completion: { _ in dismiss() }) {
                    return
                }
                dismiss()
            }
        )
        let controller = ProfileV3SubFlowHostingController(
            rootView: ProfileV3KYCCaptureView(viewModel: captureViewModel)
        )
        controller.modalPresentationStyle = .fullScreen
        host = controller
        present(controller, animated: true)
    }

    private func presentOnboardingKYC(resuming: ProfileV3HubViewModel.KYCResumption) {
        environment.kyc.startOnboarding(on: navCon) { [weak self] outcome in
            self?.returnFromKYC(completed: outcome == .completed, resuming: resuming)
        }
    }

    private func presentMinimalKYC(resuming: ProfileV3HubViewModel.KYCResumption) {
        environment.kyc.presentMinimalCapture(from: self) { [weak self] outcome in
            self?.returnFromKYC(completed: outcome == .completed, resuming: resuming)
        }
    }

    private func returnFromKYC(completed: Bool, resuming: ProfileV3HubViewModel.KYCResumption) {
        let ancestors = sequence(first: self as UIViewController, next: \.parent)
        if let anchor = ancestors.first(where: navCon.viewControllers.contains) {
            _ = navCon.popToViewController(anchor, animated: true)
        }
        guard completed else { return }
        viewModel.kycCompleted(resuming: resuming)
    }
}

struct ProfileV3HubRoot: View {
    let viewModel: ProfileV3HubViewModel
    let globe: any ProfileV3GlobeRendering
    let floatingBarClearance: CGFloat

    var body: some View {
        ProfileV3HubView(viewModel: viewModel)
            .environment(\.profileV3Globe, globe)
            .environment(\.profileV3FloatingBarClearance, floatingBarClearance)
            .environment(\.profileV3PausesAnimations, ProfileV3ScreenCover.shared.isCovered)
    }
}
