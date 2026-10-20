import ATUIKit
import SwiftUI
import UIKit

struct ProfileV3ProgrammesEvents {
    var requiresKYC: (ProfileV3WorldPass) -> Bool
    var onProgrammesChanged: () -> Void
    var onPassChanged: (ProfileV3WorldPass) -> Void
    var onUseInsight: () -> Void
    var onOpenBenefits: () -> Void
    var onRequestKYC: () -> Void
}

final class ProfileV3ProgrammesHostingController: UIHostingController<ProfileV3ProgrammesView> {

    private let viewModel: ProfileV3ProgrammesViewModel
    private let repository: any ProfileV3LoyaltyRepository
    private let selections: ProfileV3ProgrammeSelectionMemory?
    private let events: ProfileV3ProgrammesEvents
    private var addProgrammePresenter: ProfileV3AddProgrammeSheetPresenter?
    private let pageTransition = ProfileV3PushTransition()
    private let cover = ProfileV3ScreenCoverToken()

    init(
        pass: ProfileV3WorldPass,
        passes: [ProfileV3WorldPass],
        repository: any ProfileV3LoyaltyRepository,
        selections: ProfileV3ProgrammeSelectionMemory?,
        events: ProfileV3ProgrammesEvents
    ) {
        self.repository = repository
        self.selections = selections
        self.events = events
        let viewModel = ProfileV3ProgrammesViewModel(pass: pass, passes: passes, repository: repository)
        self.viewModel = viewModel
        super.init(rootView: ProfileV3ProgrammesView(viewModel: viewModel))
        viewModel.router = self
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(Color(at: .pureWhite))
        ProfileV3Analytics.screen(.programmes)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cover.begin()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isLeavingScreen { cover.end() }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cover.end()
    }
}

extension ProfileV3ProgrammesHostingController: ProfileV3ProgrammesRouter {

    func goBack() {
        dismiss(animated: true)
    }

    func openInsight(for programme: ProfileV3LoyaltyProgramme) {
        guard let insight = programme.insight else { return }
        let dismissInsight: () -> Void = { [weak self] in self?.presentedViewController?.dismiss(animated: true) }
        let host = ProfileV3SubFlowHostingController(rootView: ProfileV3ProgrammeInsightView(
            programme: programme,
            insight: insight,
            onClose: dismissInsight,
            onContinue: { [weak self] in
                self?.presentedViewController?.dismiss(animated: true) {
                    self?.dismiss(animated: true) {
                        self?.events.onUseInsight()
                    }
                }
            },
            onAction: insight.action.map { directive in
                { [weak self] in
                    self?.presentedViewController?.dismiss(animated: true) {
                        self?.openInsightAction(directive)
                    }
                }
            },
            onOpenSources: insight.detail.sources.flatMap { directive in
                guard case .loyaltySources(let programID, let profileID) = directive.route() else { return nil }
                return { [weak self] in
                    ProfileV3Analytics.cta(directive, origin: .programmeInsight)
                    self?.openSources(for: programme, programID: programID, profileID: profileID)
                }
            }
        ))
        host.modalPresentationStyle = .overFullScreen
        host.modalTransitionStyle = .crossDissolve
        present(host, animated: true)
    }

    private func openSources(for programme: ProfileV3LoyaltyProgramme, programID: String, profileID: String?) {
        guard let insightHost = presentedViewController, insightHost.presentedViewController == nil else { return }
        ProfileV3Analytics.screen(.programmeSources)
        let model = ProfileV3ProgrammeSourcesViewModel(
            programme: programme,
            programID: programID,
            profileID: profileID ?? viewModel.pass.id,
            repository: repository
        )
        let host = ProfileV3PageHostingController(rootView: ProfileV3ProgrammeSourcesView(
            viewModel: model,
            onBack: { [weak insightHost] in insightHost?.presentedViewController?.dismiss(animated: true) }
        ))
        host.modalPresentationStyle = .overFullScreen
        host.transitioningDelegate = pageTransition
        host.onDismissed = { model.cancel() }
        insightHost.present(host, animated: true)
        model.load()
    }

    func openInsightAction(_ directive: ProfileV3Directive) {
        ProfileV3Analytics.cta(directive, origin: .programmeInsight)
        switch directive.route() {
        case .loyaltyAdd:
            openAddProgramme()
        case .benefitsSheet:
            dismiss(animated: true) { [weak self] in self?.events.onOpenBenefits() }
        case .programsPage:
            dismiss(animated: true)
        default:
            return
        }
    }

    func openAddProgramme() {
        if events.requiresKYC(viewModel.pass) {
            events.onRequestKYC()
            return
        }
        let presenter = ProfileV3AddProgrammeSheetPresenter(
            profileID: viewModel.pass.id,
            repository: repository,
            selections: selections,
            onAdded: { [weak viewModel] in viewModel?.programmesDidChange() },
            onRedirectToKYC: { [weak self] in self?.events.onRequestKYC() },
            onFinish: { [weak self] finished in
                guard self?.addProgrammePresenter === finished else { return }
                self?.addProgrammePresenter = nil
            }
        )
        addProgrammePresenter = presenter
        presenter.present(from: self)
    }

    func programmesChanged() {
        events.onProgrammesChanged()
    }

    func passChanged(to pass: ProfileV3WorldPass) {
        events.onPassChanged(pass)
    }
}
