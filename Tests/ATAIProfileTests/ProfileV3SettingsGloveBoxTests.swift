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

    @Test func withoutAGloveBoxThereIsNoCard() {
        let viewModel = ProfileV3SettingsViewModel(deps: .preview(), repository: ProfileV3FailingRepository())

        viewModel.loadGloveBoxStatusIfNeeded()

        #expect(!viewModel.hasGloveBox)
        #expect(viewModel.gloveBoxHasAddress == nil)
        #expect(!viewModel.showsGloveBoxActivate)
    }
}
