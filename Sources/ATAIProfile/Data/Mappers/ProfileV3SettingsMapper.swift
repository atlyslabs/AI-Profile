import Foundation

enum ProfileV3SettingsMapper: ProfileV3DTOReading {
    private static func concierge(_ dto: ProfileV3ConciergeDTO?) -> ProfileV3Concierge? {
        guard let dto, let url = remoteURL(dto.openURL), let label = text(dto.label) else { return nil }
        return ProfileV3Concierge(label: label, openURL: url)
    }

    static func menu(_ dto: ProfileV3SettingsMenuDTO) -> ProfileV3SettingsMenu {
        ProfileV3SettingsMenu(
            title: text(dto.title) ?? "",
            accountsLabel: text(dto.accountsCenter?.label) ?? "",
            accountsSubtitle: text(dto.accountsCenter?.sub) ?? "",
            accountsRows: (dto.accountsCenter?.rows ?? []).compactMap(row),
            rows: dto.rows.compactMap(row),
            accountsBadgeURL: remoteURL(dto.accountsCenter?.badge?.imageURL),
            concierge: concierge(dto.concierge)
        )
    }

    static func permissions(_ dto: ProfileV3PermissionsScreenDTO) -> ProfileV3Permissions? {
        let sections = dto.groups.compactMap(permissionSection)
        guard !sections.isEmpty else { return nil }
        return ProfileV3Permissions(title: text(dto.title) ?? "", sections: sections)
    }

    private static func permissionSection(_ dto: ProfileV3PermissionGroupDTO) -> ProfileV3PermissionSection? {
        guard let key = text(dto.key) else { return nil }
        let options = dto.options.compactMap(permissionOption)
        guard !options.isEmpty else { return nil }
        let selected = text(dto.options.first { $0.selected == true }?.value) ?? text(dto.selected)
        return ProfileV3PermissionSection(
            id: key,
            title: text(dto.title) ?? "",
            options: options,
            selectedOptionID: options.first { $0.id == selected }?.id
        )
    }

    private static func permissionOption(_ dto: ProfileV3PermissionOptionDTO) -> ProfileV3PermissionOption? {
        guard let value = text(dto.value), let title = text(dto.title) else { return nil }
        return ProfileV3PermissionOption(
            id: value,
            title: title,
            subtitle: text(dto.subtitle)
        )
    }

    static func deleteAccountReason(_ dto: ProfileV3DeleteAccountReasonDTO) -> ProfileV3DeleteAccountReason {
        ProfileV3DeleteAccountReason(
            title: text(dto.title) ?? "",
            subtitle: text(dto.subtitle) ?? "",
            placeholder: text(dto.field?.placeholder) ?? "",
            submitLabel: text(dto.submit?.label) ?? ""
        )
    }

    static func deleteAccountConfirm(_ dto: ProfileV3DeleteAccountConfirmDTO) -> ProfileV3DeleteAccountConfirm {
        let proceed = dto.actions.first { $0.key == "proceed" || $0.action == "delete_account" }
        let cancel = dto.actions.first { $0.key == "cancel" || $0.next?.go == "back" }
        return ProfileV3DeleteAccountConfirm(
            title: text(dto.title) ?? "",
            warning: text(dto.warning) ?? "",
            proceedLabel: text(proceed?.label) ?? "",
            cancelLabel: text(cancel?.label) ?? ""
        )
    }

    private static func row(_ dto: ProfileV3SettingsRowDTO) -> ProfileV3SettingsRowItem? {
        guard let directive = dto.next?.directive, let label = text(dto.label) else { return nil }
        return ProfileV3SettingsRowItem(
            key: dto.key,
            label: label,
            directive: directive,
            isDestructive: dto.style == "danger"
        )
    }
}
