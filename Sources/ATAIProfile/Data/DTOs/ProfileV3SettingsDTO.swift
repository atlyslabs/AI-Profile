import Foundation

struct ProfileV3SettingsMenuDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    private let rawAccountsCenter: ProfileV3LossyDTO<ProfileV3AccountsCenterDTO>?
    private let rawRows: [ProfileV3LossyDTO<ProfileV3SettingsRowDTO>]?
    private let rawConcierge: ProfileV3LossyDTO<ProfileV3ConciergeDTO>?

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case rawAccountsCenter = "accounts_center"
        case rawRows = "rows"
        case rawConcierge = "contact_concierge"
    }

    var accountsCenter: ProfileV3AccountsCenterDTO? { rawAccountsCenter?.value }
    var concierge: ProfileV3ConciergeDTO? { rawConcierge?.value }
    var rows: [ProfileV3SettingsRowDTO] { (rawRows ?? []).compactMap(\.value) }
}

struct ProfileV3SettingsBadgeDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case key
        case label
        case imageURL = "image_url"
    }
}

struct ProfileV3ConciergeDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let icon: String?
    let openURL: String?

    enum CodingKeys: String, CodingKey {
        case key
        case label
        case icon
        case openURL = "open_url"
    }
}

struct ProfileV3AccountsCenterDTO: Decodable, Equatable {
    let label: String?
    let sub: String?
    private let rawRows: [ProfileV3LossyDTO<ProfileV3SettingsRowDTO>]?
    private let rawBadge: ProfileV3LossyDTO<ProfileV3SettingsBadgeDTO>?

    enum CodingKeys: String, CodingKey {
        case label
        case sub
        case rawRows = "rows"
        case rawBadge = "badge"
    }

    var rows: [ProfileV3SettingsRowDTO] { (rawRows ?? []).compactMap(\.value) }
    var badge: ProfileV3SettingsBadgeDTO? { rawBadge?.value }
}

struct ProfileV3SettingsRowDTO: Decodable, Equatable {
    let key: String
    let label: String?
    let style: String?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    enum CodingKeys: String, CodingKey {
        case key
        case label
        case style
        case rawNext = "next"
    }

    var next: ProfileV3DirectiveDTO? { rawNext?.value }
}

struct ProfileV3PermissionOptionDTO: Decodable, Equatable {
    let value: String?
    let title: String?
    let subtitle: String?
    let selected: Bool?
}

struct ProfileV3PermissionGroupDTO: Decodable, Equatable {
    let key: String?
    let title: String?
    private let rawOptions: [ProfileV3LossyDTO<ProfileV3PermissionOptionDTO>]?
    private let rawSelected: ProfileV3LossyDTO<String>?

    var options: [ProfileV3PermissionOptionDTO] { rawOptions?.compactMap(\.value) ?? [] }
    var selected: String? { rawSelected?.value }

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case rawOptions = "options"
        case rawSelected = "selected"
    }
}

struct ProfileV3PermissionsScreenDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    private let rawGroups: [ProfileV3LossyDTO<ProfileV3PermissionGroupDTO>]?

    var groups: [ProfileV3PermissionGroupDTO] { rawGroups?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case rawGroups = "groups"
    }
}

struct ProfileV3SavePermissionsRequest: Encodable, Equatable {
    let action = "save_permissions"
    let updates: [String: String]
}
