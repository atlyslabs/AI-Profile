import Foundation

struct ProfileV3TravellerRowDTO: Decodable, Equatable {
    let profileID: String?
    let name: String?
    let passNumber: String?
    let passportNumber: String?
    let mobileNumber: String?
    let citizenshipCountryCode: String?
    let relationship: String?
    let isMain: Bool?
    private let rawBadge: ProfileV3LossyDTO<ProfileV3TravellerBadgeDTO>?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    var badge: ProfileV3TravellerBadgeDTO? { rawBadge?.value }
    var next: ProfileV3DirectiveDTO? { rawNext?.value }

    enum CodingKeys: String, CodingKey {
        case profileID = "profile_id"
        case name
        case passNumber = "pass_number"
        case passportNumber = "passport_number"
        case mobileNumber = "mobile_number"
        case citizenshipCountryCode = "citizenship_country_code"
        case relationship
        case isMain = "is_main"
        case rawBadge = "badge"
        case rawNext = "next"
    }
}

struct ProfileV3TravellerBadgeDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case key
        case label
        case imageURL = "image_url"
    }
}

struct ProfileV3RelationshipPickerDTO: Decodable, Equatable {
    let title: String?
    private let rawOptions: [ProfileV3LossyDTO<ProfileV3AddTravellerOptionDTO>]?

    var options: [ProfileV3AddTravellerOptionDTO] { rawOptions?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case title
        case rawOptions = "options"
    }
}

struct ProfileV3EditTravellersScreenDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    let worldpassLabel: String?
    let worldpassIcon: String?
    private let rawTravellers: [ProfileV3LossyDTO<ProfileV3TravellerRowDTO>]?
    private let rawAdd: ProfileV3LossyDTO<ProfileV3NavCTADTO>?
    private let rawRelationshipPicker: ProfileV3LossyDTO<ProfileV3RelationshipPickerDTO>?

    var travellers: [ProfileV3TravellerRowDTO] { rawTravellers?.compactMap(\.value) ?? [] }
    var add: ProfileV3NavCTADTO? { rawAdd?.value }
    var relationshipPicker: ProfileV3RelationshipPickerDTO? { rawRelationshipPicker?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case worldpassLabel = "worldpass_label"
        case worldpassIcon = "worldpass_icon"
        case rawTravellers = "travellers"
        case rawAdd = "add"
        case rawRelationshipPicker = "relationship_picker"
    }
}

struct ProfileV3DeleteTravellerActionDTO: Decodable, Equatable {
    let label: String?
    let style: String?
    let action: String?
    let profileID: String?
    let next: ProfileV3DirectiveDTO?

    enum CodingKeys: String, CodingKey {
        case label
        case style
        case action
        case profileID = "profile_id"
        case next
    }
}

struct ProfileV3DeleteTravellerConfirmScreenDTO: Decodable, Equatable {
    let type: String?
    let name: String?
    let title: String?
    let body: String?
    private let rawProceed: ProfileV3LossyDTO<ProfileV3DeleteTravellerActionDTO>?
    private let rawCancel: ProfileV3LossyDTO<ProfileV3DeleteTravellerActionDTO>?

    var proceed: ProfileV3DeleteTravellerActionDTO? { rawProceed?.value }
    var cancel: ProfileV3DeleteTravellerActionDTO? { rawCancel?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case name
        case title
        case body
        case rawProceed = "proceed"
        case rawCancel = "cancel"
    }
}

struct ProfileV3AddTravellerOptionDTO: Decodable, Equatable {
    let value: String?
    let title: String?
    let isMinor: Bool?

    enum CodingKeys: String, CodingKey {
        case value
        case title
        case isMinor = "is_minor"
    }
}

struct ProfileV3AddTravellerFieldDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let input: String?
    let required: Bool?
    private let rawOptions: [ProfileV3LossyDTO<ProfileV3AddTravellerOptionDTO>]?

    var options: [ProfileV3AddTravellerOptionDTO] { rawOptions?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case key
        case label
        case input
        case required
        case rawOptions = "options"
    }
}

struct ProfileV3AddTravellerScreenDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    let subtitle: String?
    private let rawFields: [ProfileV3LossyDTO<ProfileV3AddTravellerFieldDTO>]?
    private let rawSubmit: ProfileV3LossyDTO<ProfileV3LabelDTO>?

    var fields: [ProfileV3AddTravellerFieldDTO] { rawFields?.compactMap(\.value) ?? [] }
    var submit: ProfileV3LabelDTO? { rawSubmit?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case subtitle
        case rawFields = "fields"
        case rawSubmit = "submit"
    }
}

struct ProfileV3DeleteTravellerRequest: Encodable, Equatable {
    let action = "delete_traveler"
    let profileID: String

    enum CodingKeys: String, CodingKey {
        case action
        case profileID = "profile_id"
    }
}

struct ProfileV3TravellerEditRequest: Encodable, Equatable {
    let userID: String
    let travellerID: String
    let firstName: String?
    let lastName: String?
    let passportNumber: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case travellerID = "traveller_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case passportNumber = "passport_number"
    }
}

struct ProfileV3AddTravellerResponseDTO: Decodable, Equatable {
    let profileID: String?

    enum CodingKeys: String, CodingKey {
        case profileID = "profile_id"
    }
}

struct ProfileV3AddTravellerRequest: Encodable, Equatable {
    let action = "add_traveler"
    let firstName: String
    let lastName: String?
    let relationship: String?
    let mobileNumber: String?
    let passportNumber: String?
    let citizenship: String?

    enum CodingKeys: String, CodingKey {
        case action
        case firstName = "first_name"
        case lastName = "last_name"
        case relationship
        case mobileNumber = "mobile_number"
        case passportNumber = "passport_number"
        case citizenship
    }
}
