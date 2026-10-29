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
            concierge: concierge(dto.concierge),
            citizenshipCode: text(dto.citizenshipCountryCode)?.uppercased()
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
