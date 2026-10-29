import Foundation

enum ProfileV3PermissionsMapper: ProfileV3DTOReading {
    static func permissions(_ dto: ProfileV3PermissionsDTO) -> ProfileV3Permissions? {
        var seen = Set<String>()
        let entries = dto.permissions.filter { text($0.key).map { seen.insert($0).inserted } ?? false }
        let cardKeys = Set(entries.filter { text($0.parentKey) == nil }.compactMap { text($0.key) })
        func parent(of entry: ProfileV3PermissionDTO) -> String? {
            text(entry.parentKey).flatMap { cardKeys.contains($0) ? $0 : nil }
        }
        let sections = entries.filter { parent(of: $0) == nil }.compactMap { card -> ProfileV3PermissionSection? in
            guard let key = text(card.key) else { return nil }
            let children = entries.filter { parent(of: $0) == key }
            let rows = ([row(card, isChild: false)] + children.map { row($0, isChild: true) }).compactMap { $0 }
            guard !rows.isEmpty else { return nil }
            return ProfileV3PermissionSection(id: key, title: text(card.label) ?? "", rows: rows)
        }
        guard !sections.isEmpty else { return nil }
        return ProfileV3Permissions(sections: sections)
    }

    private static func row(_ dto: ProfileV3PermissionDTO, isChild: Bool) -> ProfileV3PermissionRow? {
        guard let key = text(dto.key) else { return nil }
        var values = Set<String>()
        let options = dto.options.compactMap { raw -> ProfileV3PermissionOption? in
            guard let value = text(raw), values.insert(value).inserted else { return nil }
            return ProfileV3PermissionOption(id: value, title: optionTitle(value))
        }
        guard !options.isEmpty else { return nil }
        let selected = [text(dto.value), text(dto.defaultValue)].compactMap { $0 }.first { values.contains($0) }
        return ProfileV3PermissionRow(
            id: key,
            title: text(dto.detail) ?? (isChild ? text(dto.label) : nil) ?? "",
            options: options,
            selectedOptionID: selected
        )
    }

    private static func optionTitle(_ value: String) -> String {
        switch value {
        case "on": return ProfileV3Strings.yes
        case "off": return ProfileV3Strings.no
        case "ask": return ProfileV3Strings.alwaysAsk
        case "always": return ProfileV3Strings.permissionAlways
        case "when_needed": return ProfileV3Strings.permissionWhenNeeded
        default:
            let words = value.replacingOccurrences(of: "_", with: " ")
            return words.prefix(1).uppercased() + words.dropFirst()
        }
    }
}
