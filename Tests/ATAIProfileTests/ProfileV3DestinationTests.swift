import SwiftUI
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
@Suite("Hub destinations", .serialized)
struct ProfileV3DestinationTests {
    @Test func addingALoyaltyProgrammeOpensForTheMainTraveller() async throws {
        let router = DestinationRouterSpy()
        let viewModel = Self.viewModel(router: router)
        await viewModel.loadIfNeeded()
        let mainID = try #require(viewModel.mainProfileID)
        viewModel.selectPass(id: ProfileV3Fixtures.coTravellerPass.id)
        #expect(viewModel.selectedPassID == ProfileV3Fixtures.coTravellerPass.id)

        viewModel.open(.addLoyaltyProgramme)

        #expect(viewModel.selectedPassID == mainID)
        #expect(router.addedProgrammes.map(\.profileID) == [mainID])
        #expect(router.addedProgrammes.map(\.requiresKYC) == [viewModel.addProgrammeRequiresKYC(for: viewModel.selectedPass)])
        #expect(router.addedTravellers == 0)
    }

    @Test func addingATravellerOpensItsSheet() async {
        let router = DestinationRouterSpy()
        let viewModel = Self.viewModel(router: router)
        await viewModel.loadIfNeeded()

        viewModel.open(.addTraveller)

        #expect(router.addedTravellers == 1)
        #expect(router.addedProgrammes.isEmpty)
    }

    @Test func aPendingDestinationIsTakenOnce() {
        let destinations = ProfileV3PendingDestination()
        destinations.post(.addTraveller)
        destinations.post(.addLoyaltyProgramme)

        #expect(destinations.take() == .addLoyaltyProgramme)
        #expect(destinations.take() == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func theHubOpensALinkOnlyWhileItIsOnScreen() async throws {
        let destinations = ProfileV3PendingDestination()
        destinations.post(.addTraveller)
        let router = DestinationRouterSpy()
        let viewModel = Self.viewModel(router: router)
        let tabs = UITabBarController()
        tabs.viewControllers = [
            UIHostingController(rootView: ProfileV3HubView(viewModel: viewModel, destinations: destinations)),
            UIViewController()
        ]
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        try await Self.waitUntil { router.addedTravellers == 1 }
        #expect(destinations.destination == nil)

        tabs.selectedIndex = 1
        try await Task.sleep(for: .milliseconds(300))
        destinations.post(.addLoyaltyProgramme)
        try await Task.sleep(for: .milliseconds(500))
        #expect(router.addedProgrammes.isEmpty)
        #expect(destinations.destination == .addLoyaltyProgramme)

        tabs.selectedIndex = 0
        try await Self.waitUntil { router.addedProgrammes.count == 1 }
        #expect(destinations.destination == nil)
        #expect(router.addedTravellers == 1)
    }

    private static func viewModel(router: DestinationRouterSpy) -> ProfileV3HubViewModel {
        let viewModel = ProfileV3HubViewModel(
            repository: ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore())
        )
        viewModel.router = router
        return viewModel
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 300 where !condition() {
            try await Task.sleep(for: .milliseconds(50))
        }
        #expect(condition())
    }
}

@MainActor
private final class DestinationRouterSpy: ProfileV3HubRouter {
    private(set) var addedProgrammes: [(requiresKYC: Bool, profileID: String?)] = []
    private(set) var addedTravellers = 0

    func openAddProgramme(requiresKYC: Bool, profileID: String?) {
        addedProgrammes.append((requiresKYC, profileID))
    }

    func openAddTraveller() {
        addedTravellers += 1
    }

    func goBack() {}
    func openSettings(profileID: String?) {}
    func openKnowMore(_ directive: ProfileV3Directive?) {}
    func openAgent(_ agent: ProfileV3Agent, requiresKYC: Bool, profileID: String?) {}
    func openProgrammes(for pass: ProfileV3WorldPass, passes: [ProfileV3WorldPass]) {}
    func openKYC() {}
    func openBenefitKYC(_ benefit: ProfileV3Benefit) {}
    func openTravelPersona(profileID: String?) {}
}
