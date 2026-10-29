import Foundation

struct ProfileV3Permissions: Equatable {
    var sections: [ProfileV3PermissionSection]

    func selectedOptionID(in rowID: String) -> String? {
        sections.lazy.flatMap(\.rows).first { $0.id == rowID }?.selectedOptionID
    }

    func selecting(_ optionID: String?, in rowID: String) -> ProfileV3Permissions {
        var updated = self
        for index in updated.sections.indices {
            guard let row = updated.sections[index].rows.firstIndex(where: { $0.id == rowID }) else { continue }
            updated.sections[index].rows[row].selectedOptionID = optionID
            return updated
        }
        return self
    }
}

struct ProfileV3PermissionSection: Identifiable, Equatable {
    let id: String
    let title: String
    var rows: [ProfileV3PermissionRow]
}

struct ProfileV3PermissionRow: Identifiable, Equatable {
    let id: String
    let title: String
    let options: [ProfileV3PermissionOption]
    var selectedOptionID: String?
}

struct ProfileV3PermissionOption: Identifiable, Equatable {
    let id: String
    let title: String
}
