import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Settings monogram")
struct ProfileV3SettingsMonogramTests {
    @Test func theAppsFirstNameWinsOverTheBoard() async throws {
        let board = try await CachedBoardStub.withMockBoard()
        let viewModel = ProfileV3SettingsViewModel(deps: .preview(firstName: " Rahul "), repository: Self.repository, board: board)

        #expect(viewModel.monogram == "r")
    }

    @Test func aMissingOrBlankNameFallsBackToTheCachedBoardsMainTraveller() async throws {
        let board = try await CachedBoardStub.withMockBoard()
        let expected = ProfileV3SettingsViewModel.monogram(from: board.board.mainProfile?.name)
        #expect(expected != nil)

        for name in [nil, "", "   "] as [String?] {
            let viewModel = ProfileV3SettingsViewModel(deps: .preview(firstName: name), repository: Self.repository, board: board)
            #expect(viewModel.monogram == expected)
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func withNothingCachedTheBoardIsFetchedOnAppear() async throws {
        let board = ProfileV3MockRepository(delay: .zero)
        let expected = ProfileV3SettingsViewModel.monogram(from: try await board.loadBoard().mainProfile?.name)
        let viewModel = ProfileV3SettingsViewModel(deps: .preview(firstName: nil), repository: Self.repository, board: board)
        #expect(viewModel.monogram == nil)

        viewModel.loadMonogramIfNeeded()
        while viewModel.monogram == nil { try await Task.sleep(for: .milliseconds(10)) }

        #expect(viewModel.monogram == expected)
    }

    @Test func withoutABoardThereIsNoLetter() {
        let viewModel = ProfileV3SettingsViewModel(deps: .preview(firstName: nil), repository: Self.repository)
        viewModel.loadMonogramIfNeeded()
        #expect(viewModel.monogram == nil)
    }

    @Test func theHubsMainTravellerFillsTheLetterWhenNothingIsCached() {
        let viewModel = ProfileV3SettingsViewModel(
            deps: .preview(firstName: nil),
            repository: Self.repository,
            board: UncachedBoardStub(),
            profileName: " Priya Sharma "
        )
        #expect(viewModel.monogram == "p")

        let named = ProfileV3SettingsViewModel(
            deps: .preview(firstName: "Rahul"),
            repository: Self.repository,
            board: UncachedBoardStub(),
            profileName: "Priya Sharma"
        )
        #expect(named.monogram == "r")
    }

    @Test func theHubHandsSettingsItsMainTravellersName() async throws {
        let repository = ProfileV3MockRepository(delay: .zero)
        let hub = ProfileV3HubViewModel(
            repository: repository,
            hints: ProfileV3HubHints(defaults: UserDefaults(suiteName: "profileV3.hints.\(UUID().uuidString)") ?? .standard)
        )
        await hub.loadIfNeeded()

        let name = try #require(hub.mainProfileName)
        #expect(name == (try await repository.loadBoard()).mainProfile?.name)
    }

    private static var repository: ProfileV3MockRepository { ProfileV3MockRepository(delay: .zero) }
}

private struct UncachedBoardStub: ProfileV3BoardRepository {
    func loadBoard() async throws -> ProfileV3Board { throw ProfileV3RepositoryError.unavailable }
    func loadLatestBoard() async throws -> ProfileV3Board { throw ProfileV3RepositoryError.unavailable }
    @MainActor func cachedBoard() -> ProfileV3Board? { nil }
    func loadBenefits(profileID: String?) async throws -> ProfileV3BenefitsSheet { throw ProfileV3RepositoryError.unavailable }
    func loadBenefit(id: String) async throws -> ProfileV3Benefit? { nil }
    func redeemBenefit(id: String) async throws {}
    func loadCoupons() async throws -> ProfileV3CouponsSheet { throw ProfileV3RepositoryError.unavailable }
    func loadCoupon(id: String) async throws -> ProfileV3CouponDetail? { nil }
}

private struct CachedBoardStub: ProfileV3BoardRepository {
    let board: ProfileV3Board

    static func withMockBoard() async throws -> CachedBoardStub {
        CachedBoardStub(board: try await ProfileV3MockRepository(delay: .zero).loadBoard())
    }

    func loadBoard() async throws -> ProfileV3Board { board }
    func loadLatestBoard() async throws -> ProfileV3Board { board }
    @MainActor func cachedBoard() -> ProfileV3Board? { board }
    func loadBenefits(profileID: String?) async throws -> ProfileV3BenefitsSheet { throw ProfileV3RepositoryError.unavailable }
    func loadBenefit(id: String) async throws -> ProfileV3Benefit? { nil }
    func redeemBenefit(id: String) async throws {}
    func loadCoupons() async throws -> ProfileV3CouponsSheet { throw ProfileV3RepositoryError.unavailable }
    func loadCoupon(id: String) async throws -> ProfileV3CouponDetail? { nil }
}
