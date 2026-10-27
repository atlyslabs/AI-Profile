import SwiftUI
import UIKit

@MainActor
public enum ProfileV3EntryPoint {
    private static var addTravellerPresenter: ProfileV3SettingsSheetPresenter?

    static var environment: ProfileV3Environment {
        ProfileV3Runtime.environment
    }

    static func makeRepository() -> any ProfileV3Repository {
        environment.makeRepository()
    }

    public nonisolated static func prefetchBoard() {
        Task { @MainActor in environment.boardStore.prefetch() }
    }

    public static func open(_ destination: ProfileV3Destination) {
        ProfileV3PendingDestination.shared.post(destination)
    }

    public static func presentAddTraveller(navCon: UINavigationController) {
        guard addTravellerPresenter == nil else { return }
        let repository = environment.makeRepository()
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
            profileID: environment.boardStore.cachedBoard()?.mainProfile?.profileID,
            profileName: nil,
            onConnectConnector: nil,
            onTravellersChanged: nil,
            onConnectorsDisconnected: nil,
            onOpenProgrammes: nil,
            onFinish: { finished in
                guard addTravellerPresenter === finished else { return }
                addTravellerPresenter = nil
            }
        )
        addTravellerPresenter = presenter
        presenter.presentAddTraveller()
    }

    public nonisolated static func makeHub(
        navCon: UINavigationController,
        entrySource: ProfileV3EntrySource
    ) -> UIViewController {
        MainActor.assumeIsolated {
            let repository = environment.makeRepository()
            return ProfileV3HubHostingController(
                navCon: navCon,
                repository: repository,
                environment: environment,
                userFirstName: environment.account.snapshot().firstName,
                entrySource: entrySource
            )
        }
    }

    public static func makeHubSurface(onClose: @escaping () -> Void) -> AnyView {
        AnyView(ProfileV3HubSurface(onClose: onClose))
    }

    static func makeKYCRedirect(
        for subject: ProfileV3KYCRedirectView.Subject,
        status: String?,
        onClose: @escaping () -> Void,
        onRedirect: @escaping () -> Void
    ) -> UIViewController {
        let host = UIHostingController(
            rootView: ProfileV3KYCRedirectView(
                subject: subject,
                onClose: onClose,
                onRedirect: onRedirect,
                status: status
            )
        )
        host.view.backgroundColor = .clear
        host.modalPresentationStyle = .overFullScreen
        host.modalTransitionStyle = .crossDissolve
        return host
    }

    static func makeTerms(repository: any ProfileV3SettingsRepository) -> UIViewController {
        weak var presented: UIViewController?
        let host = ProfileV3SubFlowHostingController(
            rootView: ProfileV3TermsHost(
                repository: repository,
                onBack: { presented?.dismiss(animated: true) }
            )
        )
        presented = host
        host.modalPresentationStyle = .fullScreen
        return host
    }

    static func makeAgentFlow(
        agent: ProfileV3Agent,
        profileID: String?,
        repository: any ProfileV3AgentRepository,
        identityCapture: any ProfileV3IdentityCaptureHost,
        residenceCode: @escaping @MainActor () -> String? = { nil },
        onSaved: @escaping () -> Void = {}
    ) -> UIViewController {
        ProfileV3AgentFlowHostingController(
            agent: agent,
            profileID: profileID,
            repository: repository,
            identityCapture: identityCapture,
            residenceCode: residenceCode,
            onSaved: onSaved
        )
    }

    static func makeTravelPersona(
        profileID: String?,
        repository: any ProfileV3PersonaRepository
    ) -> UIViewController {
        ProfileV3TravelPersonaHostingController(profileID: profileID, repository: repository)
    }

    static func makeProgrammes(
        pass: ProfileV3WorldPass,
        passes: [ProfileV3WorldPass],
        repository: any ProfileV3LoyaltyRepository,
        selections: ProfileV3ProgrammeSelectionMemory?,
        events: ProfileV3ProgrammesEvents
    ) -> UIViewController {
        ProfileV3ProgrammesHostingController(
            pass: pass,
            passes: passes,
            repository: repository,
            selections: selections,
            events: events
        )
    }

    static func makeAddProgramme(
        requiresKYC: Bool,
        profileID: String?,
        repository: any ProfileV3LoyaltyRepository,
        selections: ProfileV3ProgrammeSelectionMemory?,
        onAdded: @escaping () -> Void,
        onRedirectToKYC: @escaping () -> Void
    ) -> UIViewController {
        ProfileV3AddProgrammeHostingController(
            requiresKYC: requiresKYC,
            profileID: profileID,
            repository: repository,
            selections: selections,
            onAdded: onAdded,
            onRedirectToKYC: onRedirectToKYC
        )
    }
}
