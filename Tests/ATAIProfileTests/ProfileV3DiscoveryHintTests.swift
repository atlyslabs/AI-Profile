import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Discovery hints, debug KYC states and server-only labels")
struct ProfileV3DiscoveryHintTests {
    @Test func theFlipDemoPlaysOnTheMainCardForFiveVisits() async {
        let hints = Self.hints()
        for _ in 1 ... ProfileV3HubHints.flipDemoShowLimit {
            let viewModel = ProfileV3HubViewModel(repository: ProfileV3MockRepository(delay: .zero), hints: hints)
            await viewModel.loadIfNeeded()
            #expect(viewModel.playsFlipDemo)
            #expect(viewModel.flipDemoPassID != nil)
            #expect(viewModel.flipDemoPassID == viewModel.mainProfileID)
            viewModel.markFlipSeen()
            viewModel.markFlipSeen()
            #expect(viewModel.flipDemoPassID == nil)
        }
        #expect(hints.flipDemoShows == ProfileV3HubHints.flipDemoShowLimit)
        let sixth = ProfileV3HubViewModel(repository: ProfileV3MockRepository(delay: .zero), hints: hints)
        await sixth.loadIfNeeded()
        #expect(!sixth.playsFlipDemo)
        #expect(sixth.flipDemoPassID == nil)
    }

    @Test func theHoldHintWaitsForTheFirstFlipDemo() {
        let hints = Self.hints()
        #expect(!hints.isHoldHintDue)
        hints.flipDemoShows = 1
        #expect(hints.isHoldHintDue)
    }

    @Test(.timeLimit(.minutes(1)))
    func theReorderHintStopsAfterItsFifthShow() async throws {
        let hints = Self.hints()
        hints.programmeReorderHintShows = ProfileV3HubHints.programmeReorderHintShowLimit - 1
        let fifth = Self.programmes(hints: hints)
        await fifth.load(reducesMotion: true)
        #expect(fifth.orderedOthers.count > 1)
        try await Self.waitUntil { fifth.showsReorderHint }
        #expect(hints.programmeReorderHintShows == ProfileV3HubHints.programmeReorderHintShowLimit)
        fifth.dismissReorderHint()

        let sixth = Self.programmes(hints: hints)
        await sixth.load(reducesMotion: true)
        try await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.reorderHintDelayMilliseconds + 300))
        #expect(!sixth.showsReorderHint)
        #expect(hints.programmeReorderHintShows == ProfileV3HubHints.programmeReorderHintShowLimit)
    }

    @Test func liveLeavesTheBoardAsTheServerSentIt() throws {
        let board = try Self.board()
        #expect(board.applying(.live) == board)
    }

    @Test func noPassportAsksForThePassportOnTheMainTravelerOnly() throws {
        let board = try Self.board()
        let debug = board.applying(.noPassport)
        let main = try #require(debug.mainProfile)
        #expect(main.pass.kycStatus == .notStarted)
        #expect(main.pass.kycCapture?.steps == [ProfileV3CaptureStepKey.passport])
        #expect(main.home.kycProgress == ProfileV3KYCProgress(done: 2, total: 3))
        #expect(main.home.kycStatusText(showsExpiryDate: true) == "Passport missing")
        let co = try #require(debug.profiles.first { !$0.isMain })
        #expect(co.pass == board.profiles.first { !$0.isMain }?.pass)
        #expect(co.home.worldPasses.first { $0.id == main.profileID } == main.pass)
    }

    @Test func noKYCAsksForEveryStep() throws {
        let main = try #require(try Self.board().applying(.noKYC).mainProfile)
        #expect(main.pass.kycCapture?.steps == [
            ProfileV3CaptureStepKey.passport,
            ProfileV3CaptureStepKey.selfie,
            ProfileV3CaptureStepKey.gmailConnect
        ])
        #expect(main.home.kycProgress == nil)
        #expect(main.home.kycActionLabel == "Complete KYC")
    }

    @Test func reKYCExpiresTheMainPass() throws {
        let main = try #require(try Self.board().applying(.reKYC).mainProfile)
        #expect(main.pass.kycStatus == .expired(on: ""))
        #expect(main.pass.resolvedKYCGlowTone == .negative)
        #expect(main.pass.kycTitle == "KYC expired")
        #expect(main.home.kycStatusText(showsExpiryDate: false) == "KYC expired")
        #expect(!main.home.needsKYCReconnect)
    }

    @Test func theWorldPassHeaderNamesTheServersBrand() throws {
        let board = try Self.board()
        #expect(board.mainProfile?.pass.brand == "ayl worldpass")
        #expect(board.profiles.first { !$0.isMain }?.pass.brand == nil)
    }

    @Test func labelsTheServerLeavesOutStayEmpty() throws {
        let sheet = ProfileV3CouponsMapper.sheet(
            try JSONDecoder().decode(ProfileV3CouponsSheetDTO.self, from: Data(#"{"coupons":[]}"#.utf8))
        )
        #expect(sheet.title.isEmpty)
        #expect(sheet.coupons.isEmpty)
        let home = try #require(try Self.board().mainProfile?.home)
        #expect(home.viewAllBenefitsLabel.isEmpty)
        #expect(home.kycStatusText(showsExpiryDate: true) == nil)
        #expect(ProfileV3Strings.noCoupons == "No coupons available.")
    }

    private static func hints() -> ProfileV3HubHints {
        ProfileV3HubHints(defaults: UserDefaults(suiteName: "profileV3.hints.\(UUID().uuidString)") ?? .standard)
    }

    private static func programmes(hints: ProfileV3HubHints) -> ProfileV3ProgrammesViewModel {
        ProfileV3ProgrammesViewModel(
            pass: ProfileV3Fixtures.worldPass,
            passes: ProfileV3Fixtures.worldPasses,
            repository: ProfileV3MockRepository(delay: .zero),
            hints: hints
        )
    }

    private static func board() throws -> ProfileV3Board {
        let json = #"""
        {"profiles":[
          {"profile_id":"main","is_main":true,"worldpass_card":{"worldpass_label":" ayl worldpass ","kyc_state":{"state":"active","status_label":"KYC active"}}},
          {"profile_id":"co","is_main":false}
        ]}
        """#
        return ProfileV3BoardMapper.board(try JSONDecoder().decode(ProfileV3BoardDTO.self, from: Data(json.utf8)))
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}
