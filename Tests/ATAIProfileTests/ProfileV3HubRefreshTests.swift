import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Hub refresh")
struct ProfileV3HubRefreshTests {
    @Test(.timeLimit(.minutes(1)))
    func aStaleBoardRefreshesQuietlyWhenTheHubComesBack() async throws {
        let session = Self.session(withProgrammes: false)
        let viewModel = Self.hub(ProfileV3MockRepository(delay: .zero, session: session))
        await viewModel.loadIfNeeded()
        #expect(viewModel.selectedPass?.programmes.isEmpty == true)

        session.updateHomes { _, _ in Self.home(withProgrammes: true) }
        viewModel.refreshIfStale(now: Date())
        try await Task.sleep(for: .milliseconds(200))
        #expect(viewModel.selectedPass?.programmes.isEmpty == true)

        viewModel.refreshIfStale(now: Date().addingTimeInterval(61))
        #expect(viewModel.home != nil)
        try await Self.waitUntil { viewModel.selectedPass?.programmes.isEmpty == false }
        #expect(viewModel.notice == nil)
    }

    @Test func aNewerBoardAnotherScreenFetchedShowsWithoutAFetch() async throws {
        let old = try await Self.board(withProgrammes: false)
        let new = try await Self.board(withProgrammes: true)
        let repository = StoreBackedRepository(cached: old, cachedAt: Date(), server: old)
        let viewModel = Self.hub(repository)
        #expect(viewModel.selectedPass?.programmes.isEmpty == true)

        repository.cached = new
        repository.cachedAt = Date().addingTimeInterval(1)
        viewModel.refreshIfStale()
        #expect(viewModel.selectedPass?.programmes.isEmpty == false)
        #expect(repository.fetches == 0)
    }

    @Test(.timeLimit(.minutes(1)))
    func aFailedQuietRefreshKeepsTheBoardAndSaysNothing() async throws {
        let old = try await Self.board(withProgrammes: false)
        let repository = StoreBackedRepository(cached: old, cachedAt: .distantPast, server: old)
        repository.failsFetch = true
        let viewModel = Self.hub(repository)

        viewModel.refreshIfStale()
        try await Self.waitUntil { repository.fetches == 1 }
        try await Task.sleep(for: .milliseconds(100))
        #expect(viewModel.home != nil)
        #expect(viewModel.notice == nil)
        #expect(viewModel.selectedPass?.programmes.isEmpty == true)
    }

    private static func home(withProgrammes: Bool) -> ProfileV3Home {
        var home = ProfileV3Fixtures.homeKYCComplete
        if !withProgrammes {
            home.worldPasses = home.worldPasses.map { pass in
                var pass = pass
                pass.programmes = []
                return pass
            }
        }
        return home
    }

    private static func session(withProgrammes: Bool) -> ProfileV3SessionStore {
        ProfileV3SessionStore(homes: [ProfileV3Fixtures.worldPass.id: home(withProgrammes: withProgrammes)])
    }

    private static func board(withProgrammes: Bool) async throws -> ProfileV3Board {
        try await ProfileV3MockRepository(delay: .zero, session: session(withProgrammes: withProgrammes)).loadBoard()
    }

    private static func hub(_ repository: any ProfileV3HubRepository) -> ProfileV3HubViewModel {
        ProfileV3HubViewModel(
            repository: repository,
            hints: ProfileV3HubHints(defaults: UserDefaults(suiteName: "profileV3.refresh.\(UUID().uuidString)") ?? .standard)
        )
    }

    private static func waitUntil(attempts: Int = 200, _ condition: () -> Bool) async throws {
        for _ in 0 ..< attempts where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

private final class StoreBackedRepository: ProfileV3HubRepository, @unchecked Sendable {
    var cached: ProfileV3Board
    var cachedAt: Date
    var server: ProfileV3Board
    var failsFetch = false
    private(set) var fetches = 0

    init(cached: ProfileV3Board, cachedAt: Date, server: ProfileV3Board) {
        self.cached = cached
        self.cachedAt = cachedAt
        self.server = server
    }

    @MainActor func cachedBoard() -> ProfileV3Board? { cached }
    @MainActor func cachedBoardFetchedAt() -> Date? { cachedAt }
    func loadBoard() async throws -> ProfileV3Board { try await loadLatestBoard() }
    func loadLatestBoard() async throws -> ProfileV3Board {
        fetches += 1
        if failsFetch { throw ProfileV3RepositoryError.unavailable }
        return server
    }
    func loadBenefits(profileID: String?) async throws -> ProfileV3BenefitsSheet { throw CancellationError() }
    func loadBenefit(id: String) async throws -> ProfileV3Benefit? { nil }
    func redeemBenefit(id: String) async throws {}
    func loadCoupons() async throws -> ProfileV3CouponsSheet { throw CancellationError() }
    func loadCoupon(id: String) async throws -> ProfileV3CouponDetail? { nil }
    func loadPastTrips(profileID: String) async throws -> ProfileV3PastTripsScreen { throw CancellationError() }
    func loadAddTrip(profileID: String) async throws -> ProfileV3AddTripScreen { throw CancellationError() }
    func addPastTrips(_ submit: ProfileV3BoardAction, countries: [String]) async throws {}
    func deletePastTrip(_ submit: ProfileV3BoardAction) async throws {}
}
