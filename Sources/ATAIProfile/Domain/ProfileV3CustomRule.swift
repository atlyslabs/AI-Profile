import Foundation

struct ProfileV3CustomRule: Identifiable, Equatable {
    let index: Int
    let text: String

    var id: Int { index }
}

struct ProfileV3CustomRulesField: Equatable {
    struct Editor: Equatable {
        let addTitle: String
        let editTitle: String
        let noteLabel: String
        let saveLabel: String
        let savedToast: String
        let maxCharacters: Int
    }

    struct DeleteConfirm: Equatable {
        let title: String
        let confirmLabel: String
        let cancelLabel: String
    }

    var rules: [String]
    let addLabel: String
    let editor: Editor
    let deleteConfirm: DeleteConfirm
    let maxRules: Int

    var canAdd: Bool { rules.count < maxRules }
}

extension ProfileV3FormSection {
    var isCustomRules: Bool {
        if case .customRules = control { return true }
        return false
    }
}

extension ProfileV3AgentForm {
    var customRulesSection: ProfileV3FormSection? {
        sections.first(where: \.isCustomRules)
    }
}
