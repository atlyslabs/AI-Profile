import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Custom rules")
struct ProfileV3CustomRulesTests {
    @Test(.timeLimit(.minutes(1)))
    func savingANewRuleClosesTheEditorAndRevealsTheRule() async throws {
        let model = ProfileV3CustomRulesModel(agentID: "food", profileID: nil, repository: ProfileV3MockRepository(delay: .zero))
        model.startAdding()
        #expect(model.editor?.isAdding == true)
        #expect(!model.canSave)
        model.draft = "   "
        #expect(!model.canSave)
        model.draft = "  Pick a veg restaurant every time  "
        #expect(model.canSave)

        model.save()
        try await waitUntil { model.phase == .saved }
        #expect(model.rules.map(\.text) == ["Pick a veg restaurant every time"])
        #expect(model.editor != nil)
        #expect(model.revealedRuleID == nil)

        try await waitUntil { model.editor == nil }
        #expect(model.revealedRuleID == model.rules.first?.id)
        #expect(model.draft.isEmpty)
        #expect(model.phase == .editing)

        model.startAdding()
        model.draft = "No red-eye flights"
        model.save()
        try await waitUntil { model.rules.count == 2 }
        model.close()
        #expect(model.editor == nil)
        #expect(model.rules.first?.text == "No red-eye flights")
        #expect(model.revealedRuleID == model.rules.first?.id)
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

    @Test(.timeLimit(.minutes(1)))
    func editingSavesOnlyAChangeAndThenCloses() async throws {
        let repository = ProfileV3MockRepository(delay: .zero)
        let rule = ProfileV3CustomRule(text: "Window seat on long flights")
        try await repository.saveCustomRule(rule, agentID: "flight", profileID: "p1")
        let model = ProfileV3CustomRulesModel(agentID: "flight", profileID: "p1", repository: repository)
        model.load()
        try await waitUntil { !model.rules.isEmpty }

        model.startEditing(rule)
        #expect(model.editor?.rule == rule)
        #expect(model.draft == rule.text)
        #expect(!model.canSave)
        model.draft = "Aisle seat on long flights"
        #expect(model.canSave)

        model.save()
        try await waitUntil { model.phase == .saved }
        #expect(model.rules.map(\.text) == ["Aisle seat on long flights"])
        #expect(model.rules.first?.id == rule.id)
        try await waitUntil { model.editor == nil }
        #expect(model.phase == .editing)
        #expect(model.revealedRuleID == nil)
        #expect(try await repository.loadCustomRules(agentID: "flight", profileID: "p1").map(\.text) == ["Aisle seat on long flights"])
    }

    @Test(.timeLimit(.minutes(1)))
    func deletingARuleRemovesItAndClosesTheEditor() async throws {
        let repository = ProfileV3MockRepository(delay: .zero)
        let rule = ProfileV3CustomRule(text: "No layovers over 3 hours")
        try await repository.saveCustomRule(rule, agentID: "flight", profileID: nil)
        let model = ProfileV3CustomRulesModel(agentID: "flight", profileID: nil, repository: repository)
        model.load()
        try await waitUntil { !model.rules.isEmpty }

        model.startEditing(rule)
        model.delete()
        try await waitUntil { model.editor == nil }

        #expect(model.rules.isEmpty)
        #expect(try await repository.loadCustomRules(agentID: "flight", profileID: nil).isEmpty)
    }

    @Test func rulesAreKeptPerOwnerTravelerAndAgent() throws {
        let suite = "profileV3.customRules.tests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = ProfileV3CustomRulesStore(defaults: defaults)
        let older = ProfileV3CustomRule(text: "Older", createdAt: Date(timeIntervalSince1970: 1))
        let newer = ProfileV3CustomRule(text: "Newer", createdAt: Date(timeIntervalSince1970: 2))
        store.save(older, owner: "u1", agentID: "food", profileID: nil)
        store.save(newer, owner: "u1", agentID: "food", profileID: nil)

        let reopened = ProfileV3CustomRulesStore(defaults: defaults)
        #expect(reopened.rules(owner: "u1", agentID: "food", profileID: nil).map(\.text) == ["Newer", "Older"])
        #expect(reopened.rules(owner: "u2", agentID: "food", profileID: nil).isEmpty)
        #expect(reopened.rules(owner: "u1", agentID: "flight", profileID: nil).isEmpty)
        #expect(reopened.rules(owner: "u1", agentID: "food", profileID: "co-traveler").isEmpty)

        reopened.delete(id: older.id, owner: "u1", agentID: "food", profileID: nil)
        #expect(store.rules(owner: "u1", agentID: "food", profileID: nil).map(\.text) == ["Newer"])
    }

    @Test(.timeLimit(.minutes(1)))
    func agentFormsLoadTheirRulesFromARepositoryThatKeepsThem() async throws {
        let repository = ProfileV3MockRepository(delay: .zero)
        let form = ProfileV3AgentFixtures.flight
        try await repository.saveCustomRule(ProfileV3CustomRule(text: "Window seat"), agentID: form.agentID, profileID: nil)
        let viewModel = ProfileV3AgentFormViewModel(form: form, avatarURL: nil, repository: repository, onFinish: {})
        let rules = try #require(viewModel.customRules)
        try await waitUntil { !rules.rules.isEmpty }
        #expect(rules.rules.map(\.text) == ["Window seat"])
    }

    private func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}
