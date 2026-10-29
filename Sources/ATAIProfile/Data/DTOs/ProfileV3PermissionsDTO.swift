import Foundation

struct ProfileV3PermissionsDTO: Decodable, Equatable {
    private let rawPermissions: [ProfileV3LossyDTO<ProfileV3PermissionDTO>]?

    var permissions: [ProfileV3PermissionDTO] { rawPermissions?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case rawPermissions = "permissions"
    }
}

struct ProfileV3PermissionDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let detail: String?
    let parentKey: String?
    private let rawOptions: [ProfileV3LossyDTO<String>]?
    private let rawValue: ProfileV3LossyDTO<String>?
    private let rawDefault: ProfileV3LossyDTO<String>?

    var options: [String] { rawOptions?.compactMap(\.value) ?? [] }
    var value: String? { rawValue?.value }
    var defaultValue: String? { rawDefault?.value }

    enum CodingKeys: String, CodingKey {
        case key
        case label
        case detail = "description"
        case parentKey = "parent_key"
        case rawOptions = "options"
        case rawValue = "value"
        case rawDefault = "default"
    }
}

struct ProfileV3UpdatePermissionRequest: Encodable, Equatable {
    let value: String
}
