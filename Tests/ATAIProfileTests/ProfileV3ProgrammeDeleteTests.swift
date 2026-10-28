import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Programme multi-select delete")
struct ProfileV3ProgrammeDeleteTests {
    @Test(.timeLimit(.minutes(1)))
    func editModeSelectsProgrammesAndBackLeavesItBeforeThePage() async throws {
        let (viewModel, router, _) = try await Self.loaded()
        let programmes = viewModel.editingProgrammes
        try #require(programmes.count >= 2)
        #expect(programmes.map(\.id) == (viewModel.overview?.featured ?? []).map(\.id) + viewModel.orderedOthers.map(\.id))

        viewModel.toggleSelection(programmes[0])
        #expect(viewModel.selectedIDs.isEmpty)

        viewModel.tapEdit()
        viewModel.tapDeleteSelected()
        #expect(router.presentedConfirmations == 0)
        viewModel.toggleSelection(programmes[0])
        viewModel.toggleSelection(programmes[1])
        #expect(viewModel.selectedIDs == [programmes[0].id, programmes[1].id])
        viewModel.toggleSelection(programmes[0])
        #expect(viewModel.selectedIDs == [programmes[1].id])

        viewModel.tapBack()
        #expect(!viewModel.isEditing)
        #expect(viewModel.selectedIDs.isEmpty)
        #expect(router.wentBack == 0)
        viewModel.tapBack()
        #expect(router.wentBack == 1)
    }

    @Test(.timeLimit(.minutes(1)))
    func deletingAsksFirstThenRemovesEverySelectedProgramme() async throws {
        let (viewModel, router, repository) = try await Self.loaded()
        let programmes = viewModel.editingProgrammes
        try #require(programmes.count >= 3)
        viewModel.tapEdit()
        viewModel.toggleSelection(programmes[2])
        viewModel.toggleSelection(programmes[0])

        viewModel.tapDeleteSelected()
        #expect(viewModel.isConfirmingDelete)
        #expect(router.presentedConfirmations == 1)
        #expect(await repository.removed.isEmpty)

        viewModel.confirmDelete()
        #expect(viewModel.isDeleting)
        try await Self.waitUntil { !viewModel.isDeleting && viewModel.overview?.programmes.count == programmes.count - 2 }

        #expect(await repository.removed == [programmes[0].id, programmes[2].id])
        #expect(router.dismissedConfirmations == 1)
        #expect(router.changes >= 1)
        #expect(viewModel.deletions == 1)
        #expect(!viewModel.isEditing)
        #expect(!viewModel.isConfirmingDelete)
        #expect(viewModel.selectedIDs.isEmpty)
        #expect(viewModel.actionError == nil)
        let remaining = Set(viewModel.overview?.programmes.map(\.id) ?? [])
        #expect(!remaining.contains(programmes[0].id))
        #expect(!remaining.contains(programmes[2].id))
        #expect(remaining.contains(programmes[1].id))
    }

    @Test(.timeLimit(.minutes(1)))
    func aProgrammeThatFailsToDeleteStaysSelected() async throws {
        let (viewModel, router, repository) = try await Self.loaded()
        let programmes = viewModel.editingProgrammes
        try #require(programmes.count >= 2)
        let first = programmes[0]
        await repository.fail(first.id)
        viewModel.tapEdit()
        viewModel.toggleSelection(programmes[0])
        viewModel.toggleSelection(programmes[1])
        viewModel.tapDeleteSelected()
        viewModel.confirmDelete()
        try await Self.waitUntil { !viewModel.isDeleting && viewModel.actionError != nil }

        #expect(await repository.removed == [programmes[1].id])
        #expect(router.dismissedConfirmations == 1)
        #expect(viewModel.isEditing)
        #expect(viewModel.selectedIDs == [first.id])
        #expect(viewModel.actionError == ProfileV3Strings.removeProgrammeFailed)
        let remaining = Set(viewModel.overview?.programmes.map(\.id) ?? [])
        #expect(remaining.contains(first.id))
        #expect(!remaining.contains(programmes[1].id))
    }

    @Test(.timeLimit(.minutes(1)))
    func cancellingOrClosingTheConfirmationDeletesNothing() async throws {
        let (viewModel, router, repository) = try await Self.loaded()
        let programme = try #require(viewModel.editingProgrammes.first)
        viewModel.tapEdit()
        viewModel.toggleSelection(programme)

        viewModel.tapDeleteSelected()
        viewModel.cancelDelete()
        #expect(router.dismissedConfirmations == 1)
        #expect(!viewModel.isConfirmingDelete)
        viewModel.confirmDelete()

        viewModel.tapDeleteSelected()
        viewModel.deleteConfirmationDidDismiss()
        #expect(!viewModel.isConfirmingDelete)
        viewModel.confirmDelete()

        #expect(router.presentedConfirmations == 2)
        #expect(!viewModel.isDeleting)
        #expect(viewModel.isEditing)
        #expect(viewModel.selectedIDs == [programme.id])
        #expect(await repository.removed.isEmpty)
    }

    @Test func theCopyCountsTheSelection() {
        #expect(ProfileV3Strings.deleteProgrammes(1) == "Delete 1 program")
        #expect(ProfileV3Strings.deleteProgrammes(3) == "Delete 3 programs")
        #expect(ProfileV3Strings.deleteProgrammesConfirm(1) == "Are you sure you want to delete\n1 program")
        #expect(ProfileV3Strings.deleteProgrammesConfirm(2) == "Are you sure you want to delete\n2 programs")
        #expect(ProfileV3Strings.confirmDeleteProgrammes == "Confirm")
        #expect(ProfileV3Strings.cancel == "Cancel")
    }

    private static func loaded() async throws -> (ProfileV3ProgrammesViewModel, ProgrammesRouterSpy, RemovalStub) {
        let repository = RemovalStub()
        let router = ProgrammesRouterSpy()
        let viewModel = ProfileV3ProgrammesViewModel(
            pass: ProfileV3Fixtures.worldPass,
            passes: [ProfileV3Fixtures.worldPass],
            repository: repository,
            hints: ProfileV3HubHints(defaults: UserDefaults(suiteName: "profileV3.hints.\(UUID().uuidString)") ?? .standard)
        )
        viewModel.router = router
        await viewModel.load(reducesMotion: true)
        try #require(viewModel.overview != nil)
        return (viewModel, router, repository)
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

@MainActor
private final class ProgrammesRouterSpy: ProfileV3ProgrammesRouter {
    private(set) var wentBack = 0
    private(set) var presentedConfirmations = 0
    private(set) var dismissedConfirmations = 0
    private(set) var changes = 0

    func goBack() { wentBack += 1 }
    func openInsight(for _: ProfileV3LoyaltyProgramme) {}
    func openAddProgramme() {}
    func openInsightAction(_: ProfileV3Directive) {}
    func programmesChanged() { changes += 1 }
    func passChanged(to _: ProfileV3WorldPass) {}
    func presentDeleteConfirmation() { presentedConfirmations += 1 }
    func dismissDeleteConfirmation() { dismissedConfirmations += 1 }
}

private actor RemovalStub: ProfileV3LoyaltyRepository {
    private let mock = ProfileV3MockRepository(delay: .zero)
    private var failing: Set<String> = []
    private(set) var removed: [String] = []

    func fail(_ id: String) {
        failing.insert(id)
    }

    nonisolated func scanProgrammes() -> AsyncThrowingStream<ProfileV3ProgrammeScanEvent, Error> {
        mock.scanProgrammes()
    }

    func loadProgrammeCatalogue(query: String?, kind: String?) async throws -> ProfileV3ProgrammePicker {
        try await mock.loadProgrammeCatalogue(query: query, kind: kind)
    }

    func loadLoyaltyEntry(programID: String, programName: String?, kind: String?) async throws -> ProfileV3LoyaltyEntryForm {
        try await mock.loadLoyaltyEntry(programID: programID, programName: programName, kind: kind)
    }

    func loadProgrammeInsight(programID: String, profileID: String?) async throws -> ProfileV3ProgrammeInsight {
        try await mock.loadProgrammeInsight(programID: programID, profileID: profileID)
    }

    func loadProgrammeSources(programID: String, profileID: String?) async throws -> ProfileV3PreferenceSources {
        try await mock.loadProgrammeSources(programID: programID, profileID: profileID)
    }

    func addProgramme(_ submission: ProfileV3ProgrammeSubmission, profileID: String?) async throws {
        try await mock.addProgramme(submission, profileID: profileID)
    }

    func loadProgrammes(passID: String) async throws -> ProfileV3ProgrammeOverview {
        try await mock.loadProgrammes(passID: passID)
    }

    func removeProgramme(id: String, name: String, profileID: String) async throws {
        if failing.contains(id) { throw ProfileV3Error.server(code: nil, message: nil) }
        removed.append(id)
        try await mock.removeProgramme(id: id, name: name, profileID: profileID)
    }

    func reorderProgrammes(_: [String], profileID _: String, action _: String) async throws {}
}
