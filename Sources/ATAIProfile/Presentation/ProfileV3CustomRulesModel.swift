import Combine
import Foundation

@MainActor
final class ProfileV3CustomRulesModel: ObservableObject {
    enum Phase: Equatable {
        case editing
        case saving
        case saved
    }

    struct Editor: Equatable {
        let rule: ProfileV3CustomRule?

        var isAdding: Bool { rule == nil }
    }

    struct Dropped: Identifiable, Equatable {
        let id: Int
        let text: String
    }

    @Published private(set) var rules: [ProfileV3CustomRule] = []
    @Published private(set) var editor: Editor?
    @Published var draft = ""
    @Published private(set) var phase: Phase = .editing
    @Published private(set) var dropped: Dropped?
    @Published private(set) var errorMessage: String?

    private let agentID: String
    private let profileID: String?
    private let repository: any ProfileV3CustomRulesRepository
    private var loadTask: Task<Void, Never>?
    private var writeTask: Task<Void, Never>?
    private var settleTask: Task<Void, Never>?
    private var drops = 0

    init(agentID: String, profileID: String?, repository: any ProfileV3CustomRulesRepository) {
        self.agentID = agentID
        self.profileID = profileID
        self.repository = repository
    }

    var trimmedDraft: String { draft.trimmingCharacters(in: .whitespacesAndNewlines) }

    var canSave: Bool {
        guard let editor, phase == .editing, !trimmedDraft.isEmpty else { return false }
        guard let rule = editor.rule else { return true }
        return trimmedDraft != rule.text
    }

    var showsSavedToast: Bool { dropped != nil }

    func load() {
        loadTask?.cancel()
        let repository = repository
        let agentID = agentID
        let profileID = profileID
        loadTask = Task { [weak self] in
            let rules = (try? await repository.loadCustomRules(agentID: agentID, profileID: profileID)) ?? []
            guard let self, !Task.isCancelled else { return }
            self.rules = rules
        }
    }

    func startAdding() {
        guard editor == nil else { return }
        open(Editor(rule: nil), draft: "")
    }

    func startEditing(_ rule: ProfileV3CustomRule) {
        guard editor == nil else { return }
        open(Editor(rule: rule), draft: rule.text)
    }

    func close() {
        guard phase != .saving else { return }
        settleTask?.cancel()
        editor = nil
        dropped = nil
        phase = .editing
        errorMessage = nil
        draft = ""
    }

    func save() {
        guard canSave, let editor else { return }
        let text = trimmedDraft
        var rule = editor.rule ?? ProfileV3CustomRule(text: text)
        rule.text = text
        phase = .saving
        errorMessage = nil
        let repository = repository
        let agentID = agentID
        let profileID = profileID
        writeTask = Task { [weak self, rule] in
            do {
                try await repository.saveCustomRule(rule, agentID: agentID, profileID: profileID)
                self?.didSave(rule, adding: editor.isAdding)
            } catch {
                guard let self else { return }
                phase = .editing
                errorMessage = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed)
            }
        }
    }

    func delete() {
        guard let rule = editor?.rule, phase == .editing else { return }
        phase = .saving
        errorMessage = nil
        let repository = repository
        let agentID = agentID
        let profileID = profileID
        writeTask = Task { [weak self] in
            do {
                try await repository.deleteCustomRule(id: rule.id, agentID: agentID, profileID: profileID)
                guard let self else { return }
                rules.removeAll { $0.id == rule.id }
                phase = .editing
                close()
            } catch {
                guard let self else { return }
                phase = .editing
                errorMessage = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed)
            }
        }
    }

    func cancel() {
        loadTask?.cancel()
        writeTask?.cancel()
        settleTask?.cancel()
    }

    private func open(_ editor: Editor, draft: String) {
        settleTask?.cancel()
        dropped = nil
        phase = .editing
        errorMessage = nil
        self.draft = draft
        self.editor = editor
    }

    private func didSave(_ rule: ProfileV3CustomRule, adding: Bool) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index] = rule
        } else {
            rules.insert(rule, at: 0)
        }
        guard adding else {
            phase = .saved
            settle(after: .milliseconds(ProfileV3Theme.Motion.savedDismissMilliseconds)) { model in
                model.phase = .editing
                model.close()
            }
            return
        }
        drops += 1
        dropped = Dropped(id: drops, text: rule.text)
        draft = ""
        phase = .editing
        settle(after: .seconds(ProfileV3Theme.Motion.customRuleDropSeconds)) { model in
            model.dropped = nil
        }
    }

    private func settle(after delay: Duration, _ apply: @escaping (ProfileV3CustomRulesModel) -> Void) {
        settleTask?.cancel()
        settleTask = Task { [weak self] in
            try? await Task.sleep(for: delay)
            guard let self, !Task.isCancelled else { return }
            apply(self)
        }
    }
}
