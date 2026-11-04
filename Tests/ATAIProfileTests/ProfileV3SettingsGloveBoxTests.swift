import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Settings glove box entry")
struct ProfileV3SettingsGloveBoxTests {
    @Test(.timeLimit(.minutes(1)))
    func activateShowsUntilTheGloveBoxHasAnAddress() async throws {
        let store = ProfileV3GloveBoxStore()
        let viewModel = ProfileV3SettingsViewModel(
            deps: .preview(),
            repository: ProfileV3MockRepository(delay: .zero, gloveBox: store)
        )
        #expect(viewModel.hasGloveBox)
        #expect(!viewModel.showsGloveBoxActivate)

        viewModel.loadGloveBoxStatusIfNeeded()
        while viewModel.gloveBoxHasAddress == nil { try await Task.sleep(for: .milliseconds(10)) }
        #expect(viewModel.showsGloveBoxActivate)

        viewModel.tapGloveBox()
        #expect(viewModel.isGloveBoxPresented)
        store.update { $0.address = ProfileV3GloveBoxFixtures.email.address }
        viewModel.isGloveBoxPresented = false
        viewModel.gloveBoxDidClose()
        while viewModel.gloveBoxHasAddress == false { try await Task.sleep(for: .milliseconds(10)) }

        #expect(!viewModel.showsGloveBoxActivate)
    }

    @Test(.timeLimit(.minutes(1)))
    func anActiveGloveBoxShowsNoPill() async throws {
        let store = ProfileV3GloveBoxStore(account: ProfileV3GloveBoxAccount(address: "a@trips.atlys.com", eligible: true))
        let viewModel = ProfileV3SettingsViewModel(
            deps: .preview(),
            repository: ProfileV3MockRepository(delay: .zero, gloveBox: store)
        )

        viewModel.loadGloveBoxStatusIfNeeded()
        while viewModel.gloveBoxHasAddress == nil { try await Task.sleep(for: .milliseconds(10)) }

        #expect(viewModel.gloveBoxHasAddress == true)
        #expect(!viewModel.showsGloveBoxActivate)
    }

    @Test(.timeLimit(.minutes(1)))
    func anActiveGloveBoxShowsActivateWhileKYCIsNotDone() async throws {
        let store = ProfileV3GloveBoxStore(account: ProfileV3GloveBoxAccount(address: "a@trips.atlys.com", eligible: true))
        let viewModel = ProfileV3SettingsViewModel(
            deps: .preview(),
            repository: ProfileV3MockRepository(delay: .zero, gloveBox: store),
            board: KYCBoardStub(cached: Self.board(kycComplete: false), fetchedAt: Date())
        )

        viewModel.loadGloveBoxStatusIfNeeded()
        while viewModel.gloveBoxHasAddress == nil { try await Task.sleep(for: .milliseconds(10)) }

        #expect(viewModel.gloveBoxHasAddress == true)
        #expect(viewModel.showsGloveBoxActivate)
    }

    @Test func theKYCCheckTrustsARecentBoardAndRefetchesAnOlderOne() async {
        let done = Self.board(kycComplete: true)
        let notDone = Self.board(kycComplete: false)
        let stale = Date().addingTimeInterval(-(ProfileV3HubViewModel.staleBoardAge + 1))

        let recent = Self.settings(KYCBoardStub(cached: done, fetchedAt: Date(), latest: notDone))
        #expect(await recent.isMainTravellerKYCComplete())

        let older = Self.settings(KYCBoardStub(cached: done, fetchedAt: stale, latest: notDone))
        #expect(await older.isMainTravellerKYCComplete() == false)

        let restored = Self.settings(KYCBoardStub(cached: done, fetchedAt: nil, latest: notDone))
        #expect(await restored.isMainTravellerKYCComplete() == false)

        let offline = Self.settings(KYCBoardStub(cached: notDone, fetchedAt: stale))
        #expect(await offline.isMainTravellerKYCComplete() == false)

        let unknown = Self.settings(KYCBoardStub())
        #expect(await unknown.isMainTravellerKYCComplete())
    }

    @Test func withoutAGloveBoxThereIsNoCard() {
        let viewModel = ProfileV3SettingsViewModel(deps: .preview(), repository: ProfileV3FailingRepository())

        viewModel.loadGloveBoxStatusIfNeeded()

        #expect(!viewModel.hasGloveBox)
        #expect(viewModel.gloveBoxHasAddress == nil)
        #expect(!viewModel.showsGloveBoxActivate)
    }

    private static func settings(_ board: KYCBoardStub) -> ProfileV3SettingsViewModel {
        ProfileV3SettingsViewModel(deps: .preview(), repository: ProfileV3MockRepository(delay: .zero), board: board)
    }

    private static func board(kycComplete: Bool) -> ProfileV3Board {
        var home = ProfileV3Fixtures.home
        home.kycStatus = kycComplete ? .complete(validTill: "") : .notStarted
        let pass = ProfileV3Fixtures.worldPass
        return ProfileV3Board(profiles: [
            ProfileV3ProfileBoard(profileID: pass.id, isMain: true, name: pass.holderName, pass: pass, home: home)
        ])
    }
}

private struct KYCBoardStub: ProfileV3BoardRepository {
    var cached: ProfileV3Board?
    var fetchedAt: Date?
    var latest: ProfileV3Board?

    func loadBoard() async throws -> ProfileV3Board { try await loadLatestBoard() }
    func loadLatestBoard() async throws -> ProfileV3Board {
        guard let latest else { throw ProfileV3RepositoryError.unavailable }
        return latest
    }
    @MainActor func cachedBoard() -> ProfileV3Board? { cached }
    @MainActor func cachedBoardFetchedAt() -> Date? { fetchedAt }
    func loadBenefits(profileID: String?) async throws -> ProfileV3BenefitsSheet { throw ProfileV3RepositoryError.unavailable }
    func loadBenefit(id: String) async throws -> ProfileV3Benefit? { nil }
    func redeemBenefit(id: String) async throws {}
    func loadCoupons() async throws -> ProfileV3CouponsSheet { throw ProfileV3RepositoryError.unavailable }
    func loadCoupon(id: String) async throws -> ProfileV3CouponDetail? { nil }
}
