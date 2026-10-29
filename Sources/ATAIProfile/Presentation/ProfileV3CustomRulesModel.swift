import Combine
import Foundation

@MainActor
final class ProfileV3CustomRulesModel: ObservableObject {
    enum Phase: Equatable {
        case editing
        case saving
        case saved
    }

    enum Commit: Equatable {
        case saved
        case handedOff
    }

    struct Editor: Equatable {
        let index: Int?

        var isAdding: Bool { index == nil }
    }

    @Published private(set) var title: String
    @Published private(set) var field: ProfileV3CustomRulesField
    @Published private(set) var editor: Editor?
    @Published private(set) var draft = ""
    @Published private(set) var phase: Phase = .editing
    @Published private(set) var errorMessage: String?
    @Published private(set) var reveals = 0
    @Published var confirmsDelete = false

    private let commit: (_ rules: [String]) async throws -> Commit
    private var writeTask: Task<Void, Never>?
    private var settleTask: Task<Void, Never>?
    private var revealsOnClose = false

    init(
        title: String,
        field: ProfileV3CustomRulesField,
        commit: @escaping (_ rules: [String]) async throws -> Commit
    ) {
        self.title = title
        self.field = field
        self.commit = commit
    }

    var cards: [ProfileV3CustomRule] {
        field.rules.enumerated().reversed().map { ProfileV3CustomRule(index: $0.offset, text: $0.element) }
    }

    var canAdd: Bool { field.canAdd }

    var trimmedDraft: String { draft.trimmingCharacters(in: .whitespacesAndNewlines) }

    var canSave: Bool {
        guard let editor, phase == .editing, !trimmedDraft.isEmpty else { return false }
        guard let index = editor.index, field.rules.indices.contains(index) else { return editor.isAdding }
        return trimmedDraft != field.rules[index]
    }

    func update(title: String, field: ProfileV3CustomRulesField) {
        self.title = title
        self.field = field
    }

    func setDraft(_ text: String) {
        draft = String(text.prefix(field.editor.maxCharacters))
    }

    func startAdding() {
        guard editor == nil, canAdd else { return }
        open(Editor(index: nil), draft: "")
    }

    func startEditing(_ rule: ProfileV3CustomRule) {
        guard editor == nil, field.rules.indices.contains(rule.index) else { return }
        open(Editor(index: rule.index), draft: rule.text)
    }

    func close() {
        guard phase != .saving else { return }
        settleTask?.cancel()
        editor = nil
        phase = .editing
        errorMessage = nil
        confirmsDelete = false
        draft = ""
        if revealsOnClose {
            revealsOnClose = false
            reveals += 1
        }
    }

    func save() {
        guard canSave, let editor else { return }
        var rules = field.rules
        if let index = editor.index {
            rules[index] = trimmedDraft
        } else {
            rules.append(trimmedDraft)
        }
        write(rules, reveals: editor.isAdding)
    }

    func requestDelete() {
        guard editor?.index != nil, phase == .editing else { return }
        errorMessage = nil
        confirmsDelete = true
    }

    func cancelDelete() {
        guard phase != .saving else { return }
        confirmsDelete = false
    }

    func confirmDelete() {
        guard let index = editor?.index, field.rules.indices.contains(index), phase == .editing else { return }
        var rules = field.rules
        rules.remove(at: index)
        write(rules, reveals: false)
    }

    func cancel() {
        writeTask?.cancel()
        settleTask?.cancel()
    }

    private func open(_ editor: Editor, draft: String) {
        settleTask?.cancel()
        phase = .editing
        errorMessage = nil
        confirmsDelete = false
        setDraft(draft)
        self.editor = editor
    }

    private func write(_ rules: [String], reveals: Bool) {
        let isDelete = confirmsDelete
        phase = .saving
        errorMessage = nil
        writeTask = Task { [weak self] in
            guard let self else { return }
            do {
                let outcome = try await commit(rules)
                guard !Task.isCancelled else { return }
                revealsOnClose = reveals
                if outcome == .handedOff || isDelete {
                    phase = .editing
                    close()
                } else {
                    phase = .saved
                    settle()
                }
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                phase = .editing
                confirmsDelete = false
                errorMessage = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed)
            }
        }
    }

    private func settle() {
        settleTask?.cancel()
        settleTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.savedDismissMilliseconds))
            guard let self, !Task.isCancelled else { return }
            phase = .editing
            close()
        }
    }
}
