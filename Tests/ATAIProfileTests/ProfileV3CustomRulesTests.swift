import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Custom rules")
struct ProfileV3CustomRulesTests {
    @Test func theAgentScreenServesItsRulesAsAField() throws {
        let dto = try JSONDecoder().decode(ProfileV3AgentScreenDTO.self, from: Data(#"""
        {"agent_type":"flight","title":"Flight agent",
         "save":{"action":"save_agent_preferences","agent_type":"flight"},
         "fields":[
          {"key":"seat","label":"Seat","input":"single_select","options":[{"value":"aisle","label":"Aisle"}],"value":"aisle"},
          {"key":"custom_rules","label":"CUSTOM RULES","input":"custom_rules","assist":"",
           "value":["  No red-eye flights ","","Window seat on long flights"],"add_label":"Custom",
           "editor":{"add_title":"Add a rule","edit_title":"Edit a rule","note_label":"NOTE","save_label":"Save",
                     "saved_toast":"Custom rule saved","max_chars":500},
           "delete_confirm":{"title":"Are you sure you want to delete your rule","confirm_label":"Delete",
                             "cancel_label":"Keep rule"},
           "max_rules":20,"found":true}
         ]}
        """#.utf8))
        guard case .preferences(let form) = ProfileV3AgentMapper.flow(from: dto).flow,
              let section = form.customRulesSection,
              case .customRules(let field) = section.control else {
            Issue.record("expected a custom rules section")
            return
        }
        #expect(section.id == "custom_rules")
        #expect(section.title == "CUSTOM RULES")
        #expect(section.status == .complete)
        #expect(field.rules == ["No red-eye flights", "Window seat on long flights"])
        #expect(field == ProfileV3AgentFixtures.customRulesField(field.rules))
        #expect(form.sections.last?.isCustomRules == true)

        let body = try ProfileV3AgentSubmission.body(for: form, profileID: nil)
        let values = try #require((try JSONSerialization.jsonObject(with: body) as? [String: Any])?["values"] as? [String: Any])
        #expect(values["custom_rules"] as? [String] == ["No red-eye flights", "Window seat on long flights"])
    }

    @Test(.timeLimit(.minutes(1)))
    func addingARuleSavesTheWholeListAndRevealsIt() async throws {
        let repository = RulesRepositoryStub()
        let viewModel = Self.viewModel(rules: ["Window seat"], repository: repository)
        let model = try #require(viewModel.customRules)
        #expect(model.title == "CUSTOM RULES")

        model.startAdding()
        #expect(model.editor?.isAdding == true)
        #expect(!model.canSave)
        model.setDraft("   ")
        #expect(!model.canSave)
        model.setDraft("  No red-eye flights  ")
        #expect(model.canSave)

        model.save()
        try await waitUntil { model.phase == .saved }
        #expect(repository.savedRules == [["Window seat", "No red-eye flights"]])
        #expect(repository.savedProfileIDs == [nil])
        #expect(model.editor != nil)
        #expect(model.reveals == 0)
        #expect(!viewModel.showsSaveBar || viewModel.saveState == .saved)

        try await waitUntil { model.editor == nil }
        #expect(model.reveals == 1)
        #expect(model.cards.map(\.text) == ["No red-eye flights", "Window seat"])
        #expect(model.draft.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func editingSavesOnlyAChangeInPlace() async throws {
        let repository = RulesRepositoryStub()
        let viewModel = Self.viewModel(rules: ["Window seat", "No layovers"], repository: repository)
        let model = try #require(viewModel.customRules)

        let older = try #require(model.cards.last)
        model.startEditing(older)
        #expect(model.draft == "Window seat")
        #expect(!model.canSave)
        model.setDraft("Aisle seat")
        model.save()
        try await waitUntil { model.editor == nil }
        #expect(repository.savedRules == [["Aisle seat", "No layovers"]])
        #expect(model.reveals == 0)
    }

    @Test(.timeLimit(.minutes(1)))
    func deletingAsksFirstAndSendsTheShorterList() async throws {
        let repository = RulesRepositoryStub()
        let viewModel = Self.viewModel(rules: ["Only rule"], repository: repository)
        let model = try #require(viewModel.customRules)

        model.startEditing(try #require(model.cards.first))
        model.requestDelete()
        #expect(model.confirmsDelete)
        model.cancelDelete()
        #expect(!model.confirmsDelete)
        #expect(repository.savedRules.isEmpty)

        model.requestDelete()
        model.confirmDelete()
        try await waitUntil { model.editor == nil }
        #expect(repository.savedRules == [[]])
        #expect(!model.confirmsDelete)
        #expect(model.cards.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func aRefusedSaveShowsTheServerMessage() async throws {
        let message = "You can keep up to 20 rules for this agent. Delete one to add another."
        let repository = RulesRepositoryStub(error: ProfileV3Error.invalidRequest(message: message))
        let viewModel = Self.viewModel(rules: [], repository: repository)
        let model = try #require(viewModel.customRules)

        model.startAdding()
        model.setDraft("No red-eye flights")
        model.save()
        try await waitUntil { model.errorMessage != nil }
        #expect(model.errorMessage == message)
        #expect(model.phase == .editing)
        #expect(model.editor != nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func withAHouseholdTheRuleGoesThroughTheHouseholdSheet() async throws {
        let repository = RulesRepositoryStub()
        var form = Self.form(rules: [])
        form.household = ProfileV3HouseholdPrompt(
            eyebrow: "",
            iconURL: nil,
            title: "Apply to",
            travellers: [
                ProfileV3HouseholdPrompt.Traveller(id: "main", name: "Me", passNumber: "", isSelected: true),
                ProfileV3HouseholdPrompt.Traveller(id: "co", name: "Sam", passNumber: "", isSelected: true)
            ],
            confirmLabel: "Apply"
        )
        let viewModel = ProfileV3AgentFormViewModel(form: form, avatarURL: nil, repository: repository, onFinish: {})
        let model = try #require(viewModel.customRules)

        model.startAdding()
        model.setDraft("Vegetarian meals")
        model.save()
        try await waitUntil { model.editor == nil }
        #expect(viewModel.householdApply != nil)
        #expect(repository.savedRules.isEmpty)
        #expect(model.reveals == 1)

        viewModel.confirmHousehold()
        try await waitUntil { !repository.savedRules.isEmpty }
        #expect(repository.savedRules == [["Vegetarian meals"]])
        #expect(repository.savedProfileIDs == [["main", "co"]])
    }

    @Test func theDraftIsCappedAndAddingStopsAtTheLimit() throws {
        var field = ProfileV3AgentFixtures.customRulesField(["One", "Two"])
        let model = ProfileV3CustomRulesModel(title: "CUSTOM RULES", field: field) { _ in .saved }
        model.startAdding()
        model.setDraft(String(repeating: "a", count: 600))
        #expect(model.draft.count == 500)
        model.close()

        field = ProfileV3CustomRulesField(
            rules: ["One", "Two"],
            addLabel: field.addLabel,
            editor: field.editor,
            deleteConfirm: field.deleteConfirm,
            maxRules: 2
        )
        model.update(title: "CUSTOM RULES", field: field)
        #expect(!model.canAdd)
        model.startAdding()
        #expect(model.editor == nil)
    }

    @Test func theEditorKeepsItsDesignSpacingWhenThereIsRoom() {
        let fit = ProfileV3CustomRuleEditorFit(height: 894, header: 80, bottom: 40)
        #expect(fit.noteGap == 52)
        #expect(fit.noteHeight == 308)
        #expect(fit.pillGap == 64)
    }

    @Test func saveStaysAboveTheKeyboardByClosingGapsBeforeShorteningTheNote() {
        let roomy = ProfileV3CustomRuleEditorFit(height: 538, header: 80, bottom: 40)
        #expect(roomy.noteGap == 52)
        #expect(roomy.noteHeight == 308)
        #expect(roomy.pillGap == 42)

        let tight = ProfileV3CustomRuleEditorFit(height: 377, header: 80, bottom: 40)
        #expect(tight.pillGap == 24)
        #expect(tight.noteGap == 24)
        #expect(tight.noteHeight == 193)

        for height: CGFloat in [538, 457, 377] {
            let fit = ProfileV3CustomRuleEditorFit(height: height, header: 80, bottom: 40)
            let saveBottom = 80 + fit.noteGap + fit.noteHeight + fit.pillGap + 40
            #expect(saveBottom == height - 16)
        }
    }

    private static func form(rules: [String]) -> ProfileV3AgentForm {
        var form = ProfileV3AgentFixtures.food
        form.household = nil
        form.sections.removeAll(where: \.isCustomRules)
        form.sections.append(ProfileV3AgentFixtures.customRulesSection(rules))
        return form
    }

    private static func viewModel(rules: [String], repository: RulesRepositoryStub) -> ProfileV3AgentFormViewModel {
        ProfileV3AgentFormViewModel(form: form(rules: rules), avatarURL: nil, repository: repository, onFinish: {})
    }

    private func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

private final class RulesRepositoryStub: ProfileV3AgentRepository, @unchecked Sendable {
    private let lock = NSLock()
    private let error: Error?
    private var saved: [(form: ProfileV3AgentForm, profileIDs: [String]?)] = []

    init(error: Error? = nil) {
        self.error = error
    }

    var savedRules: [[String]] {
        lock.withLock {
            saved.compactMap { entry in
                guard case .customRules(let field)? = entry.form.customRulesSection?.control else { return nil }
                return field.rules
            }
        }
    }

    var savedProfileIDs: [[String]?] { lock.withLock { saved.map(\.profileIDs) } }

    func loadAgentFlow(agentID: String, profileID: String?) async throws -> ProfileV3AgentFlow {
        guard let form = lock.withLock({ saved.last?.form }) else { throw ProfileV3RepositoryError.unavailable }
        return .preferences(form)
    }

    func saveAgentForm(_ form: ProfileV3AgentForm, profileID: String?, profileIDs: [String]?) async throws -> String? {
        if let error { throw error }
        lock.withLock { saved.append((form, profileIDs)) }
        return nil
    }

    func loadPreviousPassports(profileID: String?) async throws -> ProfileV3PreviousPassports {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPassportScan(profileID: String?) async throws -> ProfileV3PassportScan { .fallback }

    func uploadPassportScan(_ side: ProfileV3PassportSide, data: Data, profileID: String?) async throws
        -> ProfileV3PassportScanResult {
        ProfileV3PassportScanResult(field: nil, backRequired: nil)
    }

    func loadPassportReason() async throws -> ProfileV3PassportReasonScreen { .fallback }

    func loadPassportHowUsed() async throws -> ProfileV3PassportHowUsed {
        throw ProfileV3RepositoryError.unavailable
    }

    func updatePassport(reason: String, profileID: String?) async throws {}

    func loadPreferenceSources(_ source: ProfileV3SectionSource, profileID: String?) async throws
        -> ProfileV3PreferenceSources {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadRidePicker(agentType: String, profileID: String?) async throws -> ProfileV3RidePicker {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadRideRegions() async throws -> ProfileV3RideRegions {
        throw ProfileV3RepositoryError.unavailable
    }
}
