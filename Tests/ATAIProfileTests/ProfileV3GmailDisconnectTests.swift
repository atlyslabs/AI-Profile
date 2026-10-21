import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Gmail disconnect refresh")
struct ProfileV3GmailDisconnectTests {
    @Test(.timeLimit(.minutes(1)))
    func aSuccessfulDisconnectIsReportedToSettings() async throws {
        let router = ProfileV3ConnectorsRouterSpy()
        let model = ProfileV3ConnectorsSettingsModel(repository: ProfileV3MockRepository(delay: .zero))
        model.router = router
        model.tapDeckDisconnect("gmail")
        model.confirmDisconnect()
        try await Self.waitUntil(attempts: 1_000) { !model.isDisconnecting }

        #expect(router.disconnected == [.gmail])
        #expect(router.flashes.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func aFailedDisconnectIsNotReported() async throws {
        let router = ProfileV3ConnectorsRouterSpy()
        let model = ProfileV3ConnectorsSettingsModel(repository: ProfileV3FailingRepository())
        model.router = router
        model.tapDeckDisconnect("gmail")
        model.confirmDisconnect()
        try await Self.waitUntil(attempts: 1_000) { !model.isDisconnecting }

        #expect(router.disconnected.isEmpty)
        #expect(router.flashes.count == 1)
    }

    @Test(.timeLimit(.minutes(1)))
    func disconnectingGmailReloadsTheBoardAndPlaysTheRedGlow() async throws {
        let session = Self.connectedSession()
        let viewModel = try await Self.hub(session)
        let main = try #require(viewModel.mainProfileID)
        #expect(viewModel.kycGlowCue?.tone == .positive)
        let plays = viewModel.kycGlowPlays[main, default: 0]

        session.updateHomes { _, home in Self.disconnectingGmail(home, mainID: main) }
        viewModel.refreshAfterDisconnecting([.gmail])
        try await Self.waitUntil { !viewModel.isSyncingKYC }

        #expect(viewModel.home?.isGmailConnected == false)
        #expect(viewModel.selectedPass?.resolvedKYCGlowTone == .negative)
        #expect(viewModel.kycGlowPlays[main] == plays + 1)
        #expect(viewModel.kycGlowCue?.tone == .negative)
    }

    @Test(.timeLimit(.minutes(1)))
    func theRefreshWaitsUntilTheBoardShowsGmailDisconnected() async throws {
        let session = Self.connectedSession()
        let viewModel = try await Self.hub(session)
        let main = try #require(viewModel.mainProfileID)
        let plays = viewModel.kycGlowPlays[main, default: 0]

        viewModel.refreshAfterDisconnecting([.gmail])
        try await Task.sleep(for: .milliseconds(300))
        #expect(viewModel.isSyncingKYC)
        #expect(viewModel.kycGlowPlays[main] == plays)

        session.updateHomes { _, home in Self.disconnectingGmail(home, mainID: main) }
        try await Self.waitUntil(attempts: 500) { !viewModel.isSyncingKYC }

        #expect(viewModel.kycGlowPlays[main] == plays + 1)
        #expect(viewModel.kycGlowCue?.tone == .negative)
    }

    private static func hub(_ session: ProfileV3SessionStore) async throws -> ProfileV3HubViewModel {
        let viewModel = ProfileV3HubViewModel(
            repository: ProfileV3MockRepository(delay: .zero, session: session),
            hints: ProfileV3HubHints(defaults: UserDefaults(suiteName: "profileV3.hints.\(UUID().uuidString)") ?? .standard)
        )
        await viewModel.loadIfNeeded()
        viewModel.armKYCGlow()
        return viewModel
    }

    private static func connectedSession() -> ProfileV3SessionStore {
        var main = ProfileV3Fixtures.homeKYCComplete
        main.isGmailConnected = true
        var coTraveller = ProfileV3Fixtures.coTravellerHome
        coTraveller.worldPasses = main.worldPasses
        coTraveller.isGmailConnected = true
        return ProfileV3SessionStore(homes: [
            ProfileV3Fixtures.worldPass.id: main,
            ProfileV3Fixtures.coTravellerPass.id: coTraveller
        ])
    }

    private static func disconnectingGmail(_ home: ProfileV3Home, mainID: String) -> ProfileV3Home {
        var home = home
        home.isGmailConnected = false
        home.worldPasses = home.worldPasses.map { pass in
            guard pass.id == mainID else { return pass }
            var pass = pass
            pass.kycStatus = .notStarted
            pass.kycGlowTone = .negative
            return pass
        }
        return home
    }

    private static func waitUntil(attempts: Int = 200, _ condition: () -> Bool) async throws {
        for _ in 0 ..< attempts where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

@MainActor
private final class ProfileV3ConnectorsRouterSpy: ProfileV3ConnectorsRouting, ProfileV3SettingsFeedbackRouting {
    private(set) var disconnected: [ProfileV3ConnectorKey] = []
    private(set) var flashes: [String] = []

    func presentConnectorOnboarding() {}
    func startConnectorCapture(_ step: String) {}
    func presentDisconnectEmail() {}
    func dismissDisconnectEmail() {}
    func presentDisconnectProgress() {}
    func dismissDisconnectProgress() {}

    func connectorDidDisconnect(_ connector: ProfileV3ConnectorKey) {
        disconnected.append(connector)
    }

    func showFlash(_ text: String, isSuccess: Bool) {
        flashes.append(text)
    }
}
