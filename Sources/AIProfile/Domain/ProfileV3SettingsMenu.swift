import Foundation

struct ProfileV3SettingsRowItem: Identifiable, Equatable {
    let key: String
    let label: String
    let directive: ProfileV3Directive
    var isDestructive = false

    var id: String { key }
    var route: ProfileV3Route { directive.route() }
    var isDanger: Bool { isDestructive || route == .deleteAccount }
}

struct ProfileV3Concierge: Equatable {
    let label: String
    let openURL: URL
}

struct ProfileV3SettingsMenu: Equatable {
    let title: String
    let accountsLabel: String
    let accountsSubtitle: String
    let accountsRows: [ProfileV3SettingsRowItem]
    let rows: [ProfileV3SettingsRowItem]
    var accountsBadgeURL: URL?
    var concierge: ProfileV3Concierge?

    var accountRows: [ProfileV3SettingsRowItem] {
        accountsRows.filter { $0.route != .connectors }
    }

    var listRows: [ProfileV3SettingsRowItem] {
        rows.filter { !$0.isDanger }
    }

    var dangerRows: [ProfileV3SettingsRowItem] {
        rows.filter(\.isDanger)
    }
}
