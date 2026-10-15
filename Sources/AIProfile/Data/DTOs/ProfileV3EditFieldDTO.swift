import Foundation

struct ProfileV3EditFieldContactDTO: Decodable, Equatable {
    let email: String?
    let mobileNumber: String?

    enum CodingKeys: String, CodingKey {
        case email
        case mobileNumber = "mobile_number"
    }
}

enum ProfileV3EditFieldCurrentDTO: Decodable, Equatable {
    case code(String)
    case contact(ProfileV3EditFieldContactDTO)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .code(value)
            return
        }
        if let value = try? container.decode(ProfileV3EditFieldContactDTO.self) {
            self = .contact(value)
            return
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "unsupported current")
    }

    var code: String? {
        if case .code(let value) = self { return value }
        return nil
    }

    var contact: ProfileV3EditFieldContactDTO? {
        if case .contact(let value) = self { return value }
        return nil
    }
}

struct ProfileV3EditFieldSubmitDTO: Decodable, Equatable {
    let label: String?
    let action: String?
    let field: String?
    let profileID: String?

    enum CodingKeys: String, CodingKey {
        case label
        case action
        case field
        case profileID = "profile_id"
    }
}

struct ProfileV3EditFieldOptionDTO: Decodable, Equatable {
    let value: String?
    let title: String?
    let label: String?
    let selected: Bool?
}

struct ProfileV3EditFieldScreenDTO: Decodable, Equatable {
    let type: String?
    let field: String?
    let title: String?
    let input: String?
    let subtitle: String?
    private let rawCurrent: ProfileV3LossyDTO<ProfileV3EditFieldCurrentDTO>?
    private let rawSubmit: ProfileV3LossyDTO<ProfileV3EditFieldSubmitDTO>?
    private let rawOptions: [ProfileV3LossyDTO<ProfileV3EditFieldOptionDTO>]?

    var current: ProfileV3EditFieldCurrentDTO? { rawCurrent?.value }
    var submit: ProfileV3EditFieldSubmitDTO? { rawSubmit?.value }
    var options: [ProfileV3EditFieldOptionDTO] { rawOptions?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case type
        case field
        case title
        case input
        case subtitle
        case rawCurrent = "current"
        case rawSubmit = "submit"
        case rawOptions = "options"
    }
}
