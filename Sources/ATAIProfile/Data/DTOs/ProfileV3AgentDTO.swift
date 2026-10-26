import Foundation

enum ProfileV3AgentInput: String, Equatable {
    case singleSelect = "single_select"
    case multiSelect = "multi_select"
    case singleSelectAdd = "single_select_add"
    case multiSelectAdd = "multi_select_add"
    case chips
    case slider
    case carPickup = "car_pickup"
    case text
    case contact
    case date
    case toggle
    case baggageGrid = "baggage_grid"

    var allowsMultiple: Bool? {
        switch self {
        case .multiSelect, .multiSelectAdd: return true
        case .singleSelect, .singleSelectAdd: return false
        default: return nil
        }
    }

    var offersAdd: Bool? {
        switch self {
        case .singleSelectAdd, .multiSelectAdd: return true
        case .singleSelect, .multiSelect: return false
        default: return nil
        }
    }
}

struct ProfileV3AgentScreenDTO: Decodable, Equatable {
    let type: String?
    let id: String?
    let agentType: String?
    let title: String?
    let icon: String?
    let subtitle: String?
    private let rawFound: ProfileV3LossyDTO<ProfileV3AgentFoundDTO>?
    private let rawSources: ProfileV3LossyDTO<ProfileV3AgentSourcesDTO>?
    private let rawSave: ProfileV3LossyDTO<ProfileV3AgentSaveDTO>?
    private let rawInsight: ProfileV3LossyDTO<ProfileV3AgentInsightDTO>?
    private let rawCard: ProfileV3LossyDTO<ProfileV3AgentCardDTO>?
    private let rawPassport: ProfileV3LossyDTO<ProfileV3AgentPassportDTO>?
    private let rawFields: [ProfileV3LossyDTO<ProfileV3AgentFieldDTO>]?

    var found: ProfileV3AgentFoundDTO? { rawFound?.value }
    var sources: ProfileV3AgentSourcesDTO? { rawSources?.value }
    var save: ProfileV3AgentSaveDTO? { rawSave?.value }
    var insight: ProfileV3AgentInsightDTO? { rawInsight?.value }
    var card: ProfileV3AgentCardDTO? { rawCard?.value }
    var passport: ProfileV3AgentPassportDTO? { rawPassport?.value }
    var fields: [ProfileV3AgentFieldDTO] { rawFields?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case type
        case id
        case agentType = "agent_type"
        case title
        case icon
        case subtitle
        case rawFound = "found"
        case rawSources = "sources"
        case rawSave = "save"
        case rawInsight = "insight"
        case rawCard = "card"
        case rawPassport = "passport"
        case rawFields = "fields"
    }
}

struct ProfileV3AgentFoundDTO: Decodable, Equatable {
    let count: ProfileV3ScalarDTO?
    let total: ProfileV3ScalarDTO?
}

struct ProfileV3AgentSourcesDTO: Decodable, Equatable {
    let show: Bool?
    let count: ProfileV3ScalarDTO?
    let label: String?
    private let rawIcons: [ProfileV3LossyDTO<ProfileV3AgentSourceDTO>]?

    var icons: [ProfileV3AgentSourceDTO] { rawIcons?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case show
        case count
        case label
        case rawIcons = "icons"
    }
}

struct ProfileV3AgentSaveDTO: Decodable, Equatable {
    let action: String?
    let agentType: String?
    let household: ProfileV3AgentHouseholdDTO?

    enum CodingKeys: String, CodingKey {
        case action
        case agentType = "agent_type"
        case household
    }
}

struct ProfileV3AgentHouseholdDTO: Decodable, Equatable {
    let eyebrow: String?
    let icon: String?
    let title: String?
    let travelers: [ProfileV3AgentHouseholdTravellerDTO]?
    let confirm: ProfileV3AgentHouseholdConfirmDTO?
}

struct ProfileV3AgentHouseholdTravellerDTO: Decodable, Equatable {
    let profileID: String?
    let name: String?
    let passNumber: String?
    let selected: Bool?

    enum CodingKeys: String, CodingKey {
        case profileID = "profile_id"
        case name
        case passNumber = "pass_number"
        case selected
    }
}

struct ProfileV3AgentHouseholdConfirmDTO: Decodable, Equatable {
    let label: String?
}

struct ProfileV3AgentSaveResponseDTO: Decodable, Equatable {
    let doneLabel: String?

    enum CodingKeys: String, CodingKey {
        case doneLabel = "done_label"
    }
}

struct ProfileV3AgentSourceDTO: Decodable, Equatable {
    let key: String?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case key
        case imageURL = "image_url"
    }

    init(from decoder: Decoder) throws {
        if let raw = try? decoder.singleValueContainer().decode(String.self) {
            key = raw
            imageURL = nil
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
    }
}

struct ProfileV3AgentLockToggleDTO: Decodable, Equatable {
    let label: String?
    let key: String?
    let persist: Bool?
}

struct ProfileV3AgentCardDTO: Decodable, Equatable {
    let kind: String?
    let show: [String]?
    let holderName: String?
    let countryCode: String?
    let name: String?
    let dob: String?
    let source: ProfileV3AgentSourceDTO?
    let lockToggle: ProfileV3AgentLockToggleDTO?

    enum CodingKeys: String, CodingKey {
        case kind
        case show
        case holderName = "holder_name"
        case countryCode = "country_code"
        case name
        case dob
        case source
        case lockToggle = "lock_toggle"
    }
}

struct ProfileV3AgentInsightDTO: Decodable, Equatable {
    let text: String

    enum CodingKeys: String, CodingKey {
        case text
        case body
        case summary
        case title
    }

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(), let value = try? single.decode(String.self) {
            text = value
            return
        }
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            text = ""
            return
        }
        let candidates: [String?] = [
            try? container.decodeIfPresent(String.self, forKey: .text),
            try? container.decodeIfPresent(String.self, forKey: .body),
            try? container.decodeIfPresent(String.self, forKey: .summary),
            try? container.decodeIfPresent(String.self, forKey: .title)
        ]
        text = candidates.compactMap { $0 }.first ?? ""
    }
}

struct ProfileV3AgentFieldDTO: Decodable, Equatable {
    let key: String
    let label: String?
    let input: String?
    let assist: String?
    let select: String?
    let low: ProfileV3ScalarDTO?
    let mid: ProfileV3ScalarDTO?
    let high: ProfileV3ScalarDTO?
    let min: ProfileV3ScalarDTO?
    let max: ProfileV3ScalarDTO?
    let step: ProfileV3ScalarDTO?
    let unit: String?
    let display: String?
    let format: String?
    let ratherNotSay: Bool?
    let value: ProfileV3AgentValueDTO?
    let note: String?
    let group: String?
    let tab: String?
    private let rawOptions: [ProfileV3LossyDTO<ProfileV3AgentOptionDTO>]?
    private let rawSource: ProfileV3LossyDTO<ProfileV3FieldSourceDTO>?
    private let rawFound: ProfileV3LossyDTO<Bool>?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?
    private let rawAssistLink: ProfileV3LossyDTO<ProfileV3AssistLinkDTO>?

    enum CodingKeys: String, CodingKey {
        case key
        case label
        case input
        case assist
        case rawAssistLink = "assist_link"
        case select
        case rawOptions = "options"
        case rawSource = "source"
        case rawFound = "found"
        case rawNext = "next"
        case low
        case mid
        case high
        case min
        case max
        case step
        case unit
        case display
        case format
        case ratherNotSay = "rather_not_say"
        case value
        case note
        case group
        case tab
    }

    var options: [ProfileV3AgentOptionDTO] { rawOptions?.compactMap(\.value) ?? [] }

    var source: ProfileV3FieldSourceDTO? { rawSource?.value }

    var next: ProfileV3DirectiveDTO? { rawNext?.value }

    var assistLink: ProfileV3AssistLinkDTO? { rawAssistLink?.value }

    var isFound: Bool { rawFound?.value == true }

    var inputKind: ProfileV3AgentInput? { input.flatMap(ProfileV3AgentInput.init(rawValue:)) }

    var allowsMultiple: Bool { inputKind?.allowsMultiple ?? (select?.lowercased() != "single") }

    var offersAdd: Bool { inputKind?.offersAdd ?? false }

    var selectedOptions: [ProfileV3AgentOptionDTO] {
        let listed = Set(value?.list ?? [])
        let single = value?.stringValue ?? value?.boolValue.map { $0 ? "yes" : "no" }
        return options.filter { option in
            if option.selected == true { return true }
            guard let id = option.id else { return false }
            return listed.contains(id) || id == single
        }
    }
}

struct ProfileV3AgentOptionDTO: Decodable, Equatable {
    let value: ProfileV3ScalarDTO?
    let label: String?
    let sub: String?
    let selected: Bool?
    let imageURL: String?
    let countable: Bool?
    let count: ProfileV3ScalarDTO?

    enum CodingKeys: String, CodingKey {
        case value
        case code
        case optionID = "id"
        case label
        case name
        case sub
        case detail
        case description
        case selected
        case imageURL = "image_url"
        case countable
        case count
    }

    init(from decoder: Decoder) throws {
        if let code = try? decoder.singleValueContainer().decode(String.self) {
            value = .string(code)
            label = code
            sub = nil
            selected = nil
            imageURL = nil
            countable = nil
            count = nil
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decodeIfPresent(ProfileV3ScalarDTO.self, forKey: .value)
            ?? container.decodeIfPresent(ProfileV3ScalarDTO.self, forKey: .code)
            ?? container.decodeIfPresent(ProfileV3ScalarDTO.self, forKey: .optionID)
        label = try container.decodeIfPresent(String.self, forKey: .label)
            ?? container.decodeIfPresent(String.self, forKey: .name)
        sub = try container.decodeIfPresent(String.self, forKey: .sub)
            ?? container.decodeIfPresent(String.self, forKey: .detail)
            ?? container.decodeIfPresent(String.self, forKey: .description)
        selected = try container.decodeIfPresent(Bool.self, forKey: .selected)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        countable = try container.decodeIfPresent(Bool.self, forKey: .countable)
        count = try container.decodeIfPresent(ProfileV3ScalarDTO.self, forKey: .count)
    }

    var id: String? {
        if let raw = value?.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty {
            return raw
        }
        let named = (label ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return named.isEmpty ? nil : named
    }

    var detail: String? {
        let trimmed = (sub ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var displayLabel: String {
        let trimmed = (label ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? (id ?? "") : trimmed
    }
}

struct ProfileV3ContactDTO: Decodable, Equatable {
    let email: String?
    let mobileNumber: String?

    enum CodingKeys: String, CodingKey {
        case email
        case mobileNumber = "mobile_number"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        email = try? container.decodeIfPresent(String.self, forKey: .email)
        mobileNumber = try? container.decodeIfPresent(String.self, forKey: .mobileNumber)
    }
}

struct ProfileV3AgentValueItemDTO: Decodable, Equatable {
    let value: String
    let count: Int?

    enum CodingKeys: String, CodingKey {
        case value
        case count
    }

    init(from decoder: Decoder) throws {
        if let scalar = try? ProfileV3ScalarDTO(from: decoder), let value = scalar.stringValue {
            self.value = value
            count = nil
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let value = try container.decode(ProfileV3ScalarDTO.self, forKey: .value).stringValue else {
            throw DecodingError.dataCorruptedError(forKey: .value, in: container, debugDescription: "Missing value")
        }
        self.value = value
        count = (try? container.decodeIfPresent(ProfileV3ScalarDTO.self, forKey: .count))?.intValue
    }
}

enum ProfileV3AgentValueDTO: Decodable, Equatable {
    case scalar(ProfileV3ScalarDTO)
    case contact(ProfileV3ContactDTO)
    case list([ProfileV3AgentValueItemDTO])

    init(from decoder: Decoder) throws {
        if let contact = try? ProfileV3ContactDTO(from: decoder) {
            self = .contact(contact)
            return
        }
        if let scalar = try? ProfileV3ScalarDTO(from: decoder) {
            self = .scalar(scalar)
            return
        }
        let items = try [ProfileV3LossyDTO<ProfileV3AgentValueItemDTO>](from: decoder)
        self = .list(items.compactMap(\.value))
    }

    var list: [String]? {
        guard case .list(let items) = self else { return nil }
        return items.map(\.value)
    }

    var counts: [String: Int] {
        guard case .list(let items) = self else { return [:] }
        let pairs = items.compactMap { item in item.count.map { (item.value, $0) } }
        return Dictionary(pairs, uniquingKeysWith: { first, _ in first })
    }

    var scalar: ProfileV3ScalarDTO? {
        guard case .scalar(let value) = self else { return nil }
        return value
    }

    var contact: ProfileV3ContactDTO? {
        guard case .contact(let value) = self else { return nil }
        return value
    }

    var stringValue: String? { scalar?.stringValue }

    var boolValue: Bool? { scalar?.boolValue }

    var doubleValue: Double? {
        guard let scalar, scalar.boolValue == nil, let text = scalar.stringValue else { return nil }
        return Double(text)
    }
}

struct ProfileV3FieldSourceDTO: Decodable, Equatable {
    let icon: String?
    let count: ProfileV3ScalarDTO?
    let label: String?
    let next: ProfileV3DirectiveDTO?
    private let rawIcons: [ProfileV3LossyDTO<ProfileV3AgentSourceDTO>]?

    var icons: [ProfileV3AgentSourceDTO] { rawIcons?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case icon
        case count
        case label
        case next
        case rawIcons = "icons"
    }
}

struct ProfileV3PreferenceSourcesDTO: Decodable, Equatable {
    let title: String?
    private let rawSteps: [ProfileV3LossyDTO<ProfileV3SourceStepDTO>]?

    enum CodingKeys: String, CodingKey {
        case title
        case rawSteps = "steps"
    }

    var steps: [ProfileV3SourceStepDTO] { rawSteps?.compactMap(\.value) ?? [] }
}

struct ProfileV3SourceStepDTO: Decodable, Equatable {
    let icon: String?
    let title: String?
    let body: String?
    private let rawView: ProfileV3LossyDTO<ProfileV3SourceViewDTO>?

    enum CodingKeys: String, CodingKey {
        case icon
        case title
        case body
        case rawView = "view"
    }

    var view: ProfileV3SourceViewDTO? { rawView?.value }
}

struct ProfileV3SourceViewDTO: Decodable, Equatable {
    let action: String?
}

struct ProfileV3RideOptionDTO: Decodable, Equatable {
    let value: ProfileV3ScalarDTO?
    let name: String?
    let brand: String?
    let spec: String?
    let imageURL: String?
    let selected: Bool?

    enum CodingKeys: String, CodingKey {
        case value
        case name
        case brand
        case spec
        case imageURL = "image_url"
        case selected
    }
}

struct ProfileV3AssistLinkDTO: Decodable, Equatable {
    let text: String?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    var next: ProfileV3DirectiveDTO? { rawNext?.value }

    enum CodingKeys: String, CodingKey {
        case text
        case rawNext = "next"
    }
}

struct ProfileV3RideRegionDTO: Decodable, Equatable {
    let country: String?
    let name: String?
    let imageURL: String?
    let imageAspect: ProfileV3ScalarDTO?

    enum CodingKeys: String, CodingKey {
        case country
        case name
        case imageURL = "image_url"
        case imageAspect = "image_aspect"
    }
}

struct ProfileV3RideRegionsScreenDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    let heading: String?
    let dividerLabel: String?
    private let rawRegions: [ProfileV3LossyDTO<ProfileV3RideRegionDTO>]?

    var regions: [ProfileV3RideRegionDTO] { rawRegions?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case heading
        case dividerLabel = "divider_label"
        case rawRegions = "regions"
    }
}

struct ProfileV3RidePickerScreenDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    let subtitle: String?
    let note: String?
    let fieldKey: String?
    let footer: String?
    private let rawOptions: [ProfileV3LossyDTO<ProfileV3RideOptionDTO>]?
    private let rawRegions: [ProfileV3LossyDTO<String>]?

    var options: [ProfileV3RideOptionDTO] { rawOptions?.compactMap(\.value) ?? [] }
    var regions: [String] { rawRegions?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case subtitle
        case note
        case footer
        case fieldKey = "field_key"
        case rawOptions = "options"
        case rawRegions = "regions"
    }
}
