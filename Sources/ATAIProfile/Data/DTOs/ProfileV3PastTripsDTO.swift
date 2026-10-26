import Foundation

struct ProfileV3BoardSubmitRequest: Encodable, Equatable {
    let action: ProfileV3BoardAction
    var extras: [String: ProfileV3ScalarDTO] = [:]

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ProfileV3AnyCodingKey.self)
        for (key, value) in action.fields where extras[key] == nil {
            try container.encode(value, forKey: ProfileV3AnyCodingKey(key))
        }
        for (key, value) in extras {
            try container.encode(value, forKey: ProfileV3AnyCodingKey(key))
        }
    }
}

struct ProfileV3TripNextDTO: Decodable, Equatable {
    let label: String?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    var next: ProfileV3DirectiveDTO? { rawNext?.value }

    enum CodingKeys: String, CodingKey {
        case label
        case rawNext = "next"
    }
}

struct ProfileV3TripsPillDTO: Decodable, Equatable {
    private let rawFlags: [ProfileV3LossyDTO<String>]?
    let more: ProfileV3ScalarDTO?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?
    private let rawAdd: ProfileV3LossyDTO<ProfileV3TripNextDTO>?

    var flags: [String] { rawFlags?.compactMap(\.value) ?? [] }
    var next: ProfileV3DirectiveDTO? { rawNext?.value }
    var add: ProfileV3DirectiveDTO? { rawAdd?.value?.next }

    enum CodingKeys: String, CodingKey {
        case rawFlags = "flags"
        case more
        case rawNext = "next"
        case rawAdd = "add"
    }
}

struct ProfileV3TripActionDTO: Decodable, Equatable {
    let label: String?
    private let rawSubmit: ProfileV3LossyDTO<ProfileV3BoardActionDTO>?

    var submit: ProfileV3BoardActionDTO? { rawSubmit?.value }

    enum CodingKeys: String, CodingKey {
        case label
        case rawSubmit = "submit"
    }
}

struct ProfileV3PastTripDTO: Decodable, Equatable {
    let tripID: ProfileV3ScalarDTO?
    let code: String?
    let name: String?
    let imageURL: String?
    let month: ProfileV3ScalarDTO?
    let year: ProfileV3ScalarDTO?
    let monthLabel: String?
    private let rawEdit: ProfileV3LossyDTO<ProfileV3TripActionDTO>?
    private let rawDelete: ProfileV3LossyDTO<ProfileV3TripActionDTO>?

    var edit: ProfileV3TripActionDTO? { rawEdit?.value }
    var delete: ProfileV3TripActionDTO? { rawDelete?.value }

    enum CodingKeys: String, CodingKey {
        case tripID = "trip_id"
        case code
        case name
        case imageURL = "image_url"
        case month
        case year
        case monthLabel = "month_label"
        case rawEdit = "edit"
        case rawDelete = "delete"
    }
}

struct ProfileV3TripYearMonthDTO: Decodable, Equatable {
    let year: ProfileV3ScalarDTO?
    let month: ProfileV3ScalarDTO?
}

struct ProfileV3TripMonthDTO: Decodable, Equatable {
    let value: ProfileV3ScalarDTO?
    let label: String?
}

struct ProfileV3TripDurationDTO: Decodable, Equatable {
    let title: String?
    let yearLabel: String?
    let monthLabel: String?
    private let rawYears: [ProfileV3LossyDTO<ProfileV3ScalarDTO>]?
    private let rawMonths: [ProfileV3LossyDTO<ProfileV3TripMonthDTO>]?
    private let rawMax: ProfileV3LossyDTO<ProfileV3TripYearMonthDTO>?
    private let rawDefault: ProfileV3LossyDTO<ProfileV3TripYearMonthDTO>?
    let ctaLabel: String?

    var years: [ProfileV3ScalarDTO] { rawYears?.compactMap(\.value) ?? [] }
    var months: [ProfileV3TripMonthDTO] { rawMonths?.compactMap(\.value) ?? [] }
    var max: ProfileV3TripYearMonthDTO? { rawMax?.value }
    var defaultValue: ProfileV3TripYearMonthDTO? { rawDefault?.value }

    enum CodingKeys: String, CodingKey {
        case title
        case yearLabel = "year_label"
        case monthLabel = "month_label"
        case rawYears = "years"
        case rawMonths = "months"
        case rawMax = "max"
        case rawDefault = "default"
        case ctaLabel = "cta_label"
    }
}

struct ProfileV3TripDeleteConfirmDTO: Decodable, Equatable {
    let title: String?
    let confirmLabel: String?
    let cancelLabel: String?

    enum CodingKeys: String, CodingKey {
        case title
        case confirmLabel = "confirm_label"
        case cancelLabel = "cancel_label"
    }
}

struct ProfileV3PastTripsScreenDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    private let rawTrips: [ProfileV3LossyDTO<ProfileV3PastTripDTO>]?
    private let rawAdd: ProfileV3LossyDTO<ProfileV3TripNextDTO>?
    private let rawDuration: ProfileV3LossyDTO<ProfileV3TripDurationDTO>?
    private let rawDeleteConfirm: ProfileV3LossyDTO<ProfileV3TripDeleteConfirmDTO>?

    var trips: [ProfileV3PastTripDTO] { rawTrips?.compactMap(\.value) ?? [] }
    var add: ProfileV3DirectiveDTO? { rawAdd?.value?.next }
    var duration: ProfileV3TripDurationDTO? { rawDuration?.value }
    var deleteConfirm: ProfileV3TripDeleteConfirmDTO? { rawDeleteConfirm?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case rawTrips = "trips"
        case rawAdd = "add"
        case rawDuration = "duration"
        case rawDeleteConfirm = "delete_confirm"
    }
}

struct ProfileV3TripCountryDTO: Decodable, Equatable {
    let code: String?
    let name: String?
}

struct ProfileV3TripCountryStepDTO: Decodable, Equatable {
    let title: String?
    let searchPlaceholder: String?
    let ctaLabel: String?
    private let rawCountries: [ProfileV3LossyDTO<ProfileV3TripCountryDTO>]?

    var countries: [ProfileV3TripCountryDTO] { rawCountries?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case title
        case searchPlaceholder = "search_placeholder"
        case ctaLabel = "cta_label"
        case rawCountries = "countries"
    }
}

struct ProfileV3AddTripScreenDTO: Decodable, Equatable {
    let type: String?
    private let rawCountry: ProfileV3LossyDTO<ProfileV3TripCountryStepDTO>?
    private let rawDuration: ProfileV3LossyDTO<ProfileV3TripDurationDTO>?
    private let rawSubmit: ProfileV3LossyDTO<ProfileV3BoardActionDTO>?

    var country: ProfileV3TripCountryStepDTO? { rawCountry?.value }
    var duration: ProfileV3TripDurationDTO? { rawDuration?.value }
    var submit: ProfileV3BoardActionDTO? { rawSubmit?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case rawCountry = "country"
        case rawDuration = "duration"
        case rawSubmit = "submit"
    }
}
