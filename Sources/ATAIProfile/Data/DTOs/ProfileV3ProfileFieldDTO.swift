import Foundation

enum ProfileV3ProfileFieldValue: Equatable {
    case code(String)
    case contact(email: String?, mobileNumber: String)
}

struct ProfileV3EditProfileFieldRequest: Encodable, Equatable {
    let field: String
    let value: ProfileV3ProfileFieldValue
    let profileID: String?

    private enum CodingKeys: String, CodingKey {
        case action
        case field
        case value
        case profileID = "profile_id"
    }

    private enum ContactKeys: String, CodingKey {
        case email
        case mobileNumber = "mobile_number"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("edit_profile_field", forKey: .action)
        try container.encode(field, forKey: .field)
        try container.encodeIfPresent(profileID, forKey: .profileID)
        switch value {
        case .code(let code):
            try container.encode(code, forKey: .value)
        case .contact(let email, let mobileNumber):
            var contact = container.nestedContainer(keyedBy: ContactKeys.self, forKey: .value)
            try contact.encodeIfPresent(email, forKey: .email)
            try contact.encode(mobileNumber, forKey: .mobileNumber)
        }
    }
}

struct ProfileV3LogoutRequest: Encodable, Equatable {
    let action = "logout"
}

struct ProfileV3SlackAlertRequest: Encodable, Equatable {
    static let accountDeletion = Self(alertType: "ACCOUNT_DELETION_REQUEST")

    let alertType: String

    enum CodingKeys: String, CodingKey {
        case alertType = "alert_type"
    }
}

struct ProfileV3SlackAlertResponseDTO: Decodable, Equatable {
    let success: Bool?
}
