import Foundation

enum ProfileV3PermissionDefaults {
    static let rowKey = "permissions"
}

#if DEBUG
enum ProfileV3PermissionFixtures {
    static let permissions = ProfileV3Permissions(sections: [
        ProfileV3PermissionSection(id: "email", title: "Email", rows: [
            row("email", "Ayl will email hotels, airlines and others for you", options: ["on": "Yes", "ask": "Always ask"], selected: "ask"),
            row("email_cc", "Copy you on the emails Ayl sends", options: ["always": "Always", "when_needed": "When needed"], selected: "always")
        ]),
        ProfileV3PermissionSection(id: "call", title: "Call", rows: [
            row("call", "Ayl will call hotels, airlines and others for you", options: ["on": "Yes", "ask": "Always ask"], selected: "ask")
        ])
    ])

    private static func row(
        _ id: String,
        _ title: String,
        options: KeyValuePairs<String, String>,
        selected: String
    ) -> ProfileV3PermissionRow {
        ProfileV3PermissionRow(
            id: id,
            title: title,
            options: options.map { ProfileV3PermissionOption(id: $0.key, title: $0.value) },
            selectedOptionID: selected
        )
    }
}
#endif
