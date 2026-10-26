import Foundation

struct ProfileV3AnyCodingKey: CodingKey {
    let stringValue: String
    var intValue: Int? { nil }

    init(_ stringValue: String) {
        self.stringValue = stringValue
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue _: Int) {
        nil
    }
}

extension ProfileV3ScalarDTO: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        }
    }
}

struct ProfileV3BoardActionDTO: Decodable, Equatable {
    let fields: [String: ProfileV3ScalarDTO]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ProfileV3AnyCodingKey.self)
        var fields: [String: ProfileV3ScalarDTO] = [:]
        for key in container.allKeys {
            if let value = try? container.decode(ProfileV3ScalarDTO.self, forKey: key) {
                fields[key.stringValue] = value
            }
        }
        self.fields = fields
    }
}

struct ProfileV3PersonaActionDTO: Decodable, Equatable {
    let label: String?
    let submit: ProfileV3BoardActionDTO

    enum CodingKeys: String, CodingKey {
        case label
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        label = try? container.decodeIfPresent(String.self, forKey: .label)
        submit = try ProfileV3BoardActionDTO(from: decoder)
    }
}

struct ProfileV3PersonaPointDTO: Decodable, Equatable {
    let trait: String
    let name: String?
    let score: ProfileV3ScalarDTO?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?
    private let rawSubmit: ProfileV3LossyDTO<ProfileV3BoardActionDTO>?

    var next: ProfileV3DirectiveDTO? { rawNext?.value }
    var submit: ProfileV3BoardActionDTO? { rawSubmit?.value }

    enum CodingKeys: String, CodingKey {
        case trait
        case name
        case score
        case rawNext = "next"
        case rawSubmit = "submit"
    }
}

struct ProfileV3PersonaProfileDTO: Decodable, Equatable {
    let title: String?
    let min: ProfileV3ScalarDTO?
    let max: ProfileV3ScalarDTO?
    private let rawTraits: [ProfileV3LossyDTO<ProfileV3PersonaPointDTO>]?

    var traits: [ProfileV3PersonaPointDTO] { rawTraits?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case title
        case min
        case max
        case rawTraits = "traits"
    }
}

struct ProfileV3PersonaScreenDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    let icon: String?
    let foundLabel: String?
    let subtitle: String?
    private let rawProfile: ProfileV3LossyDTO<ProfileV3PersonaProfileDTO>?

    var profile: ProfileV3PersonaProfileDTO? { rawProfile?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case icon
        case foundLabel = "found_label"
        case subtitle
        case rawProfile = "profile"
    }
}

struct ProfileV3PersonaScaleDTO: Decodable, Equatable {
    let min: ProfileV3ScalarDTO?
    let max: ProfileV3ScalarDTO?
    let value: ProfileV3ScalarDTO?
    private let rawLabels: [ProfileV3LossyDTO<String>]?

    var labels: [String] { rawLabels?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case min
        case max
        case value
        case rawLabels = "labels"
    }
}

struct ProfileV3PersonaRowDTO: Decodable, Equatable {
    let id: ProfileV3ScalarDTO?
    let kind: String?
    let title: String?
    let subtitle: String?
    let delta: ProfileV3ScalarDTO?
    let deltaLabel: String?
    let ignored: Bool?
    private let rawButton: ProfileV3LossyDTO<ProfileV3PersonaActionDTO>?

    var button: ProfileV3PersonaActionDTO? { rawButton?.value }

    enum CodingKeys: String, CodingKey {
        case id
        case kind
        case title
        case subtitle
        case delta
        case deltaLabel = "delta_label"
        case ignored
        case rawButton = "button"
    }
}

struct ProfileV3PersonaStartingPointDTO: Decodable, Equatable {
    let title: String?
    let subtitle: String?
}

struct ProfileV3PersonaCalculationDTO: Decodable, Equatable {
    let title: String?
    private let rawItems: [ProfileV3LossyDTO<ProfileV3PersonaRowDTO>]?
    private let rawBulk: ProfileV3LossyDTO<ProfileV3PersonaActionDTO>?
    private let rawNextPage: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?
    private let rawStartingPoint: ProfileV3LossyDTO<ProfileV3PersonaStartingPointDTO>?

    var items: [ProfileV3PersonaRowDTO] { rawItems?.compactMap(\.value) ?? [] }
    var bulk: ProfileV3PersonaActionDTO? { rawBulk?.value }
    var nextPage: ProfileV3DirectiveDTO? { rawNextPage?.value }
    var startingPoint: ProfileV3PersonaStartingPointDTO? { rawStartingPoint?.value }

    enum CodingKeys: String, CodingKey {
        case title
        case rawItems = "items"
        case rawBulk = "bulk"
        case rawNextPage = "next_page"
        case rawStartingPoint = "starting_point"
    }
}

struct ProfileV3PersonaTraitScreenDTO: Decodable, Equatable {
    let type: String?
    let trait: String?
    let title: String?
    let score: ProfileV3ScalarDTO?
    let subtitle: String?
    private let rawScale: ProfileV3LossyDTO<ProfileV3PersonaScaleDTO>?
    private let rawCalculation: ProfileV3LossyDTO<ProfileV3PersonaCalculationDTO>?

    var scale: ProfileV3PersonaScaleDTO? { rawScale?.value }
    var calculation: ProfileV3PersonaCalculationDTO? { rawCalculation?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case trait
        case title
        case score
        case subtitle
        case rawScale = "scale"
        case rawCalculation = "calculation"
    }
}

struct ProfileV3PersonaSubmitRequest: Encodable, Equatable {
    let action: ProfileV3BoardAction
    var score: Int?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ProfileV3AnyCodingKey.self)
        for (key, value) in action.fields where key != "score" {
            try container.encode(value, forKey: ProfileV3AnyCodingKey(key))
        }
        if let score {
            try container.encode(score, forKey: ProfileV3AnyCodingKey("score"))
        }
    }
}
