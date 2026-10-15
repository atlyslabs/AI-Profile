import Foundation

enum ProfileV3PermissionDefaults {
    static let rowKey = "permissions"

    static let permissions = ProfileV3Permissions(
        title: ProfileV3Strings.permissions,
        sections: [
            section(id: "connector_defaults", title: ProfileV3Strings.connectorDefaults, selected: askSome),
            section(id: "web_access_defaults", title: ProfileV3Strings.webAccessDefaults, selected: alwaysAsk)
        ]
    )

    private static let askSome = "ask_some"
    private static let alwaysAsk = "always_ask"

    private static func section(id: String, title: String, selected: String) -> ProfileV3PermissionSection {
        ProfileV3PermissionSection(
            id: id,
            title: title,
            options: [
                ProfileV3PermissionOption(
                    id: askSome,
                    title: ProfileV3Strings.askForSomeActions,
                    subtitle: ProfileV3Strings.askForSomeActionsDetail
                ),
                ProfileV3PermissionOption(
                    id: alwaysAsk,
                    title: ProfileV3Strings.alwaysAsk,
                    subtitle: ProfileV3Strings.alwaysAskDetail
                )
            ],
            selectedOptionID: selected
        )
    }
}
