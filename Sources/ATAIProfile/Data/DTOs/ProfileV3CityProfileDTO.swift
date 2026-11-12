import Foundation

struct ProfileV3CityProfilesDTO: Decodable, Equatable {
    let title: String?
    let headline: String?
    private let rawCities: [ProfileV3LossyDTO<ProfileV3CityPortholeDTO>]?
    private let rawAdd: ProfileV3LossyDTO<ProfileV3CityAddDTO>?
    private let rawSamples: [ProfileV3LossyDTO<ProfileV3CitySampleDTO>]?

    var cities: [ProfileV3CityPortholeDTO] { rawCities?.compactMap(\.value) ?? [] }
    var add: ProfileV3CityAddDTO? { rawAdd?.value }
    var samples: [ProfileV3CitySampleDTO] { rawSamples?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case title
        case headline
        case rawCities = "cities"
        case rawAdd = "add"
        case rawSamples = "samples"
    }
}

struct ProfileV3CityPortholeDTO: Decodable, Equatable {
    let id: String?
    let code: String?
    let name: String?
    let country: String?
    let countryCode: String?
    let imageURL: String?
    private let rawPurpose: ProfileV3LossyDTO<ProfileV3CityPurposeDTO>?
    private let rawNext: ProfileV3LossyDTO<ProfileV3CityNextDTO>?

    var purpose: ProfileV3CityPurposeDTO? { rawPurpose?.value }
    var next: ProfileV3CityNextDTO? { rawNext?.value }

    enum CodingKeys: String, CodingKey {
        case id
        case code
        case name
        case country
        case countryCode = "country_code"
        case imageURL = "image_url"
        case rawPurpose = "purpose"
        case rawNext = "next"
    }
}

struct ProfileV3CityNextDTO: Decodable, Equatable {
    let go: String?
    let cityID: String?
    let code: String?
    let fieldKey: String?

    enum CodingKeys: String, CodingKey {
        case go
        case cityID = "city_id"
        case code
        case fieldKey = "field_key"
    }
}

struct ProfileV3CityPurposeDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let iconURL: String?
    private let rawEdit: ProfileV3LossyDTO<ProfileV3CityPurposeEditDTO>?

    var edit: ProfileV3CityPurposeEditDTO? { rawEdit?.value }

    enum CodingKeys: String, CodingKey {
        case key
        case label
        case iconURL = "icon_url"
        case rawEdit = "edit"
    }
}

struct ProfileV3CityPurposeEditDTO: Decodable, Equatable {
    let next: ProfileV3CityNextDTO?
}

struct ProfileV3CityAddDTO: Decodable, Equatable {
    let label: String?
    let subtitle: String?
}

struct ProfileV3CitySampleDTO: Decodable, Equatable {
    let code: String?
    let name: String?
    let imageURL: String?
    private let rawPurpose: ProfileV3LossyDTO<ProfileV3CityPurposeDTO>?
    private let rawLines: [ProfileV3LossyDTO<String>]?

    var purpose: ProfileV3CityPurposeDTO? { rawPurpose?.value }
    var lines: [String] { rawLines?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case code
        case name
        case imageURL = "image_url"
        case rawPurpose = "purpose"
        case rawLines = "lines"
    }
}

struct ProfileV3CityPickerDTO: Decodable, Equatable {
    let title: String?
    let searchPlaceholder: String?
    let heading: String?
    let query: String?
    private let rawSearchEmpty: ProfileV3LossyDTO<ProfileV3CityEmptyDTO>?
    private let rawOffset: ProfileV3LossyDTO<ProfileV3ScalarDTO>?
    private let rawNextOffset: ProfileV3LossyDTO<ProfileV3ScalarDTO>?
    private let rawResults: [ProfileV3LossyDTO<ProfileV3CityPickerRowDTO>]?

    var searchEmpty: ProfileV3CityEmptyDTO? { rawSearchEmpty?.value }
    var offset: Int? { rawOffset?.value?.intValue }
    var nextOffset: Int? { rawNextOffset?.value?.intValue }
    var results: [ProfileV3CityPickerRowDTO] { rawResults?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case title
        case searchPlaceholder = "search_placeholder"
        case heading
        case query = "q"
        case rawSearchEmpty = "search_empty"
        case rawOffset = "offset"
        case rawNextOffset = "next_offset"
        case rawResults = "results"
    }
}

struct ProfileV3CityEmptyDTO: Decodable, Equatable {
    let title: String?
    let subtitle: String?
}

struct ProfileV3CityPickerRowDTO: Decodable, Equatable {
    let code: String?
    let name: String?
    let country: String?
    let countryCode: String?

    enum CodingKeys: String, CodingKey {
        case code
        case name
        case country
        case countryCode = "country_code"
    }
}

struct ProfileV3CityPurposeSheetDTO: Decodable, Equatable {
    let title: String?
    let labelTaken: String?
    private let rawCity: ProfileV3LossyDTO<ProfileV3CityPortholeDTO>?
    private let rawOptions: [ProfileV3LossyDTO<ProfileV3CityPurposeOptionDTO>]?
    private let rawUsedLabels: [ProfileV3LossyDTO<String>]?
    private let rawSubmit: ProfileV3LossyDTO<ProfileV3PersonaActionDTO>?
    private let rawDelete: ProfileV3LossyDTO<ProfileV3CityDeleteDTO>?

    var city: ProfileV3CityPortholeDTO? { rawCity?.value }
    var options: [ProfileV3CityPurposeOptionDTO] { rawOptions?.compactMap(\.value) ?? [] }
    var usedLabels: [String] { rawUsedLabels?.compactMap(\.value) ?? [] }
    var submit: ProfileV3PersonaActionDTO? { rawSubmit?.value }
    var delete: ProfileV3CityDeleteDTO? { rawDelete?.value }

    enum CodingKeys: String, CodingKey {
        case title
        case labelTaken = "label_taken"
        case rawCity = "city"
        case rawOptions = "options"
        case rawUsedLabels = "used_labels"
        case rawSubmit = "submit"
        case rawDelete = "delete"
    }
}

struct ProfileV3CityPurposeOptionDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let iconURL: String?
    let disabled: Bool?
    let selected: Bool?
    private let rawInput: ProfileV3LossyDTO<ProfileV3CityPurposeInputDTO>?

    var input: ProfileV3CityPurposeInputDTO? { rawInput?.value }

    enum CodingKeys: String, CodingKey {
        case key
        case label
        case iconURL = "icon_url"
        case disabled
        case selected
        case rawInput = "input"
    }
}

struct ProfileV3CityPurposeInputDTO: Decodable, Equatable {
    let label: String?
    let placeholder: String?
    let value: String?
    private let rawMaxChars: ProfileV3LossyDTO<ProfileV3ScalarDTO>?

    var maxChars: Int? { rawMaxChars?.value?.intValue }

    enum CodingKeys: String, CodingKey {
        case label
        case placeholder
        case value
        case rawMaxChars = "max_chars"
    }
}

struct ProfileV3CityDeleteDTO: Decodable, Equatable {
    let action: ProfileV3PersonaActionDTO
    let iconURL: String?
    let confirm: ProfileV3CityDeleteConfirmDTO?

    enum CodingKeys: String, CodingKey {
        case iconURL = "icon_url"
        case confirm
    }

    init(from decoder: Decoder) throws {
        action = try ProfileV3PersonaActionDTO(from: decoder)
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        iconURL = try? container?.decodeIfPresent(String.self, forKey: .iconURL)
        confirm = try? container?.decodeIfPresent(ProfileV3CityDeleteConfirmDTO.self, forKey: .confirm)
    }
}

struct ProfileV3CityDeleteConfirmDTO: Decodable, Equatable {
    let title: String?
    let body: String?
    let confirmLabel: String?
    let cancelLabel: String?
    let iconURL: String?

    enum CodingKeys: String, CodingKey {
        case title
        case body
        case confirmLabel = "confirm_label"
        case cancelLabel = "cancel_label"
        case iconURL = "icon_url"
    }
}

struct ProfileV3CityScreenDTO: Decodable, Equatable {
    let cityID: String?
    let title: String?
    private let rawCity: ProfileV3LossyDTO<ProfileV3CityPortholeDTO>?
    private let rawCities: [ProfileV3LossyDTO<ProfileV3CityPortholeDTO>]?
    private let rawPurpose: ProfileV3LossyDTO<ProfileV3CityPurposeDTO>?
    private let rawFound: ProfileV3LossyDTO<ProfileV3CityFoundDTO>?
    private let rawSources: ProfileV3LossyDTO<ProfileV3CitySourcesDTO>?
    private let rawTabs: [ProfileV3LossyDTO<ProfileV3CityTabDTO>]?
    private let rawFields: [ProfileV3LossyDTO<ProfileV3CityCardDTO>]?
    private let rawCustomRules: ProfileV3LossyDTO<ProfileV3AgentFieldDTO>?
    private let rawSave: ProfileV3LossyDTO<ProfileV3BoardActionDTO>?

    var city: ProfileV3CityPortholeDTO? { rawCity?.value }
    var cities: [ProfileV3CityPortholeDTO] { rawCities?.compactMap(\.value) ?? [] }
    var purpose: ProfileV3CityPurposeDTO? { rawPurpose?.value }
    var found: ProfileV3CityFoundDTO? { rawFound?.value }
    var sources: ProfileV3CitySourcesDTO? { rawSources?.value }
    var tabs: [ProfileV3CityTabDTO] { rawTabs?.compactMap(\.value) ?? [] }
    var fields: [ProfileV3CityCardDTO] { rawFields?.compactMap(\.value) ?? [] }
    var customRules: ProfileV3AgentFieldDTO? { rawCustomRules?.value }
    var save: ProfileV3BoardActionDTO? { rawSave?.value }

    enum CodingKeys: String, CodingKey {
        case cityID = "city_id"
        case title
        case rawCity = "city"
        case rawCities = "cities"
        case rawPurpose = "purpose"
        case rawFound = "found"
        case rawSources = "sources"
        case rawTabs = "tabs"
        case rawFields = "fields"
        case rawCustomRules = "custom_rules"
        case rawSave = "save"
    }
}

struct ProfileV3CityFoundDTO: Decodable, Equatable {
    let count: ProfileV3ScalarDTO?
    let total: ProfileV3ScalarDTO?
    let label: String?
}

struct ProfileV3CitySourcesDTO: Decodable, Equatable {
    let count: ProfileV3ScalarDTO?
    let label: String?
    private let rawIcons: [ProfileV3LossyDTO<ProfileV3AgentSourceDTO>]?

    var icons: [ProfileV3AgentSourceDTO] { rawIcons?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case count
        case label
        case rawIcons = "icons"
    }
}

struct ProfileV3CityTabDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let iconURL: String?

    enum CodingKeys: String, CodingKey {
        case key
        case label
        case iconURL = "icon_url"
    }
}

struct ProfileV3CityCardDTO: Decodable, Equatable {
    let field: ProfileV3AgentFieldDTO
    let subtitle: String?
    let footer: String?
    let layout: String?
    private let rawIcon: ProfileV3LossyDTO<ProfileV3CityCardIconDTO>?
    private let rawAdd: ProfileV3LossyDTO<ProfileV3CityCardAddDTO>?
    private let rawOptOut: ProfileV3LossyDTO<ProfileV3CityOptOutDTO>?
    private let rawTab: ProfileV3LossyDTO<ProfileV3CityTabDTO>?
    private let rawOptionArt: [ProfileV3LossyDTO<ProfileV3CityOptionArtDTO>]?
    private let rawMaxItems: ProfileV3LossyDTO<ProfileV3ScalarDTO>?
    private let rawMaxChars: ProfileV3LossyDTO<ProfileV3ScalarDTO>?

    var icon: ProfileV3CityCardIconDTO? { rawIcon?.value }
    var add: ProfileV3CityCardAddDTO? { rawAdd?.value }
    var optOut: ProfileV3CityOptOutDTO? { rawOptOut?.value }
    var tab: ProfileV3CityTabDTO? { rawTab?.value }
    var optionArt: [ProfileV3CityOptionArtDTO] { rawOptionArt?.compactMap(\.value) ?? [] }
    var maxItems: Int? { rawMaxItems?.value?.intValue }
    var maxChars: Int? { rawMaxChars?.value?.intValue }

    enum CodingKeys: String, CodingKey {
        case subtitle
        case footer
        case layout
        case rawIcon = "icon"
        case rawAdd = "add"
        case rawOptOut = "optout"
        case rawTab = "tab"
        case rawOptionArt = "options"
        case rawMaxItems = "max_items"
        case rawMaxChars = "max_chars"
    }

    init(from decoder: Decoder) throws {
        field = try ProfileV3AgentFieldDTO(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        subtitle = try? container.decodeIfPresent(String.self, forKey: .subtitle)
        footer = try? container.decodeIfPresent(String.self, forKey: .footer)
        layout = try? container.decodeIfPresent(String.self, forKey: .layout)
        rawIcon = try? container.decodeIfPresent(ProfileV3LossyDTO<ProfileV3CityCardIconDTO>.self, forKey: .rawIcon)
        rawAdd = try? container.decodeIfPresent(ProfileV3LossyDTO<ProfileV3CityCardAddDTO>.self, forKey: .rawAdd)
        rawOptOut = try? container.decodeIfPresent(ProfileV3LossyDTO<ProfileV3CityOptOutDTO>.self, forKey: .rawOptOut)
        rawTab = try? container.decodeIfPresent(ProfileV3LossyDTO<ProfileV3CityTabDTO>.self, forKey: .rawTab)
        rawOptionArt = try? container.decodeIfPresent(
            [ProfileV3LossyDTO<ProfileV3CityOptionArtDTO>].self,
            forKey: .rawOptionArt
        )
        rawMaxItems = try? container.decodeIfPresent(ProfileV3LossyDTO<ProfileV3ScalarDTO>.self, forKey: .rawMaxItems)
        rawMaxChars = try? container.decodeIfPresent(ProfileV3LossyDTO<ProfileV3ScalarDTO>.self, forKey: .rawMaxChars)
    }
}

struct ProfileV3CityCardIconDTO: Decodable, Equatable {
    let activeURL: String?
    let inactiveURL: String?

    enum CodingKeys: String, CodingKey {
        case activeURL = "active_url"
        case inactiveURL = "inactive_url"
    }
}

struct ProfileV3CityCardAddDTO: Decodable, Equatable {
    let search: String?
}

struct ProfileV3CityOptOutDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let value: Bool?
}

struct ProfileV3CityOptionArtDTO: Decodable, Equatable {
    let value: ProfileV3ScalarDTO?
    let imageURL: String?
    let selectedImageURL: String?

    enum CodingKeys: String, CodingKey {
        case value
        case imageURL = "image_url"
        case selectedImageURL = "selected_image_url"
    }
}

struct ProfileV3CityWriteDTO: Decodable, Equatable {
    let cityID: String?

    enum CodingKeys: String, CodingKey {
        case cityID = "city_id"
    }
}

struct ProfileV3CitySubmitRequest: Encodable, Equatable {
    let action: ProfileV3BoardAction
    var purpose: String?
    var label: String?
    var values: [String: ProfileV3AgentSubmissionValue]?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ProfileV3AnyCodingKey.self)
        let own: Set<String> = ["purpose", "label", "values", "icon_url"]
        for (key, value) in action.fields where !own.contains(key) {
            try container.encode(value, forKey: ProfileV3AnyCodingKey(key))
        }
        if let purpose {
            try container.encode(purpose, forKey: ProfileV3AnyCodingKey("purpose"))
        }
        if let label {
            try container.encode(label, forKey: ProfileV3AnyCodingKey("label"))
        }
        if let values {
            try container.encode(values, forKey: ProfileV3AnyCodingKey("values"))
        }
    }
}
