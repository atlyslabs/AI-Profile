import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Settings failure")
struct ProfileV3SettingsFailureTests {
    @Test(.timeLimit(.minutes(1)))
    func aFailedMenuStillOffersLogoutAndDeleteAccount() async throws {
        let viewModel = ProfileV3SettingsViewModel(deps: .preview(), repository: ProfileV3FailingRepository())
        viewModel.loadMenuIfNeeded()
        while viewModel.menuPhase == .loading { try await Task.sleep(for: .milliseconds(10)) }

        #expect(viewModel.menuPhase == .failed)
        #expect(viewModel.menu == nil)
        #expect(viewModel.title == ProfileV3Strings.settings)
        #expect(viewModel.failedMenuRows.map(\.route) == [.logout, .deleteAccount])
        #expect(viewModel.failedMenuRows.map(\.isDanger) == [false, true])
    }

    @Test func theFailedRowsOpenLogoutAndDeleteAccount() {
        let viewModel = ProfileV3SettingsViewModel(deps: .preview(), repository: ProfileV3FailingRepository())
        viewModel.tap(viewModel.failedMenuRows[0])
        #expect(viewModel.path.last == .logout)
        viewModel.sheetDidDismiss()
        viewModel.tap(viewModel.failedMenuRows[1])
        #expect(viewModel.path.last == .deleteAccount)
    }
}
