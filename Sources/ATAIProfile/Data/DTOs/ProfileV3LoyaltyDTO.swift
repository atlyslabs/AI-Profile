import Foundation

struct ProfileV3ReorderProgrammesRequest: Encodable, Equatable {
    let action: String
    let profileID: String
    let order: [String]

    enum CodingKeys: String, CodingKey {
        case action
        case profileID = "profile_id"
        case order
    }
}

struct ProfileV3RemoveProgrammeRequest: Encodable, Equatable {
    let action = "remove_loyalty_program"
    let profileID: String
    let programName: String
    let programID: String?

    enum CodingKeys: String, CodingKey {
        case action
        case profileID = "profile_id"
        case programName = "program_name"
        case programID = "program_id"
    }
}

struct ProfileV3LoyaltyRowDTO: Decodable, Equatable {
    let row: ProfileV3ProgrammeRowDTO
    let next: ProfileV3DirectiveDTO?

    enum CodingKeys: String, CodingKey {
        case next
    }

    init(from decoder: Decoder) throws {
        row = try ProfileV3ProgrammeRowDTO(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        next = try? container.decodeIfPresent(ProfileV3DirectiveDTO.self, forKey: .next)
    }
}

struct ProfileV3LoyaltyPickScreenDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    private let rawFilters: [ProfileV3LossyDTO<String>]?
    private let rawPrograms: [ProfileV3LossyDTO<ProfileV3LoyaltyRowDTO>]?
    private let rawMarket: ProfileV3LossyDTO<ProfileV3LoyaltyMarketDTO>?

    var filters: [String] { rawFilters?.compactMap(\.value) ?? [] }
    var programs: [ProfileV3LoyaltyRowDTO] { rawPrograms?.compactMap(\.value) ?? [] }
    var market: ProfileV3LoyaltyMarketDTO? { rawMarket?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case rawFilters = "filters"
        case rawPrograms = "programs"
        case rawMarket = "market"
    }
}

struct ProfileV3LoyaltyMarketDTO: Decodable, Equatable {
    let selected: String?
    private let rawOptions: [ProfileV3LossyDTO<ProfileV3LoyaltyMarketOptionDTO>]?
    private let rawChips: [ProfileV3LossyDTO<String>]?

    var options: [ProfileV3LoyaltyMarketOptionDTO] { rawOptions?.compactMap(\.value) ?? [] }
    var chips: [String] { rawChips?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case selected
        case rawOptions = "options"
        case rawChips = "chips"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selected = container.lenientString(forKey: .selected)
        rawOptions = try? container.decodeIfPresent([ProfileV3LossyDTO<ProfileV3LoyaltyMarketOptionDTO>].self, forKey: .rawOptions)
        rawChips = try? container.decodeIfPresent([ProfileV3LossyDTO<String>].self, forKey: .rawChips)
    }
}

struct ProfileV3LoyaltyMarketOptionDTO: Decodable, Equatable {
    let value: String?
    let label: String?
}

struct ProfileV3LoyaltyFieldDTO: Decodable, Equatable {
    let key: String
    let label: String?
    let required: Bool?
    let input: String?
}

struct ProfileV3LoyaltySubmitDTO: Decodable, Equatable {
    let label: String?
    let action: String?
    let programID: String?
    let programName: String?
    let kind: String?

    enum CodingKeys: String, CodingKey {
        case label
        case action
        case programID = "program_id"
        case programName = "program_name"
        case kind
    }
}

struct ProfileV3LoyaltyEnterScreenDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    let programID: String?
    let programName: String?
    private let rawFields: [ProfileV3LossyDTO<ProfileV3LoyaltyFieldDTO>]?
    private let rawSubmit: ProfileV3LossyDTO<ProfileV3LoyaltySubmitDTO>?

    var fields: [ProfileV3LoyaltyFieldDTO] { rawFields?.compactMap(\.value) ?? [] }
    var submit: ProfileV3LoyaltySubmitDTO? { rawSubmit?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case programID = "program_id"
        case programName = "program_name"
        case rawFields = "fields"
        case rawSubmit = "submit"
    }
}

struct ProfileV3ProgrammesPageScreenDTO: Decodable, Equatable {
    let type: String?
    let name: String?
    let subtitle: String?
    private let rawPrograms: [ProfileV3LossyDTO<ProfileV3LoyaltyRowDTO>]?
    private let rawAdd: ProfileV3LossyDTO<ProfileV3NavCTADTO>?
    private let rawReorder: ProfileV3LossyDTO<ProfileV3LoyaltySubmitDTO>?

    var programs: [ProfileV3LoyaltyRowDTO] { rawPrograms?.compactMap(\.value) ?? [] }
    var add: ProfileV3NavCTADTO? { rawAdd?.value }
    var reorder: ProfileV3LoyaltySubmitDTO? { rawReorder?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case name
        case subtitle
        case rawPrograms = "programs"
        case rawAdd = "add"
        case rawReorder = "reorder"
    }
}

struct ProfileV3ProgrammeSourcesDTO: Decodable, Equatable {
    let count: ProfileV3ScalarDTO?
    let show: Bool?
    let label: String?
    private let rawIcons: [ProfileV3LossyDTO<ProfileV3AgentSourceDTO>]?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    var icons: [ProfileV3AgentSourceDTO] { rawIcons?.compactMap(\.value) ?? [] }
    var next: ProfileV3DirectiveDTO? { rawNext?.value }

    enum CodingKeys: String, CodingKey {
        case count
        case show
        case label
        case rawIcons = "icons"
        case rawNext = "next"
    }
}

struct ProfileV3ProgrammeInsightScreenDTO: Decodable, Equatable {
    let type: String?
    let insight: String?
    private let rawSources: ProfileV3LossyDTO<ProfileV3ProgrammeSourcesDTO>?
    private let rawContinue: ProfileV3LossyDTO<ProfileV3NavCTADTO>?
    private let rawAction: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    var sources: ProfileV3ProgrammeSourcesDTO? { rawSources?.value }
    var continueCTA: ProfileV3NavCTADTO? { rawContinue?.value }
    var action: ProfileV3DirectiveDTO? { rawAction?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case insight
        case rawSources = "sources"
        case rawContinue = "continue"
        case rawAction = "action"
    }
}

struct ProfileV3AddLoyaltyProgrammeRequest: Encodable, Equatable {
    let action = "add_loyalty_program"
    let programID: String
    let profileID: String
    let programName: String?
    let kind: String?
    let membershipNumber: String?
    let points: String?

    enum CodingKeys: String, CodingKey {
        case action
        case programID = "program_id"
        case profileID = "profile_id"
        case programName = "program_name"
        case kind
        case membershipNumber = "membership_number"
        case points
    }
}
