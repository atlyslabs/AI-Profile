import Foundation

struct ProfileV3Permissions: Equatable {
    let title: String
    var sections: [ProfileV3PermissionSection]

    func selectedOptionID(in sectionID: String) -> String? {
        sections.first { $0.id == sectionID }?.selectedOptionID
    }

    func selecting(_ optionID: String?, in sectionID: String) -> ProfileV3Permissions {
        guard let index = sections.firstIndex(where: { $0.id == sectionID }) else { return self }
        var updated = self
        updated.sections[index].selectedOptionID = optionID
        return updated
    }
}

struct ProfileV3PermissionSection: Identifiable, Equatable {
    let id: String
    let title: String
    let options: [ProfileV3PermissionOption]
    var selectedOptionID: String?
}

struct ProfileV3PermissionOption: Identifiable, Equatable {
    let id: String
    let title: String
    var subtitle: String?
}
