import Combine
import Foundation
import Observation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Settings render work")
struct ProfileV3SettingsRenderTests {
    @Test func coverTokensKeepTheCountBalanced() {
        let cover = ProfileV3ScreenCover.shared
        let start = cover.depth
        let settings = ProfileV3ScreenCoverToken()
        let programmes = ProfileV3ScreenCoverToken()

        settings.begin()
        settings.begin()
        #expect(cover.depth == start + 1)
        #expect(cover.isCovered)
        programmes.begin()
        settings.end()
        settings.end()
        #expect(cover.depth == start + 1)
        programmes.end()
        #expect(cover.depth == start)
    }

    @Test(.timeLimit(.minutes(1)))
    func theMenuLoadsOnceWhenThePageReappears() async throws {
        let viewModel = ProfileV3SettingsViewModel(deps: .preview(), repository: ProfileV3MockRepository(delay: .zero))
        viewModel.loadMenuIfNeeded()
        while viewModel.menu == nil { try await Task.sleep(for: .milliseconds(10)) }

        let changed = ChangeFlag()
        withObservationTracking { _ = viewModel.menu } onChange: { changed.set() }
        viewModel.loadMenuIfNeeded()
        try await Task.sleep(for: .milliseconds(100))

        #expect(!changed.value)
    }

    @Test func sheetNavigationDoesNotTouchWhatThePageReads() {
        let viewModel = ProfileV3SettingsViewModel(deps: .preview(), repository: ProfileV3MockRepository(delay: .zero))
        let changed = ChangeFlag()
        withObservationTracking {
            _ = viewModel.menu
            _ = viewModel.menuPhase
            _ = viewModel.pagePath
            _ = viewModel.isAccountExpanded
        } onChange: { changed.set() }

        viewModel.path = [.residence]
        viewModel.path = [.residence, .citizenship]
        viewModel.sheetDidDismiss()

        #expect(!changed.value)
        #expect(viewModel.pagePath.isEmpty)
    }

    @Test func typingADeletionReasonPublishesNothingWhileThereIsNoError() {
        let account = ProfileV3AccountSettingsModel(deps: .preview(), repository: ProfileV3MockRepository(delay: .zero))
        var publishes = 0
        let subscription = account.objectWillChange.sink { publishes += 1 }

        for _ in 0 ..< 5 { account.clearDeletionError() }

        #expect(publishes == 0)
        subscription.cancel()
    }
}

private final class ChangeFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var changed = false

    var value: Bool { lock.withLock { changed } }

    func set() { lock.withLock { changed = true } }
}
