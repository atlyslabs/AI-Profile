import Foundation

struct ProfileV3AIConnectorBenefitDTO: Decodable, Equatable {
    let title: String?
    let body: String?
}

struct ProfileV3AIConnectorLinkDTO: Decodable, Equatable {
    let label: String?
    let url: String?
}

struct ProfileV3AIConnectorDisclaimerDTO: Decodable, Equatable {
    let text: String?
    private let rawLinks: [ProfileV3LossyDTO<ProfileV3AIConnectorLinkDTO>]?

    var links: [ProfileV3AIConnectorLinkDTO] { rawLinks?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case text
        case rawLinks = "links"
    }
}

struct ProfileV3AIConnectorCTADTO: Decodable, Equatable {
    let label: String?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    var next: ProfileV3DirectiveDTO? { rawNext?.value }

    enum CodingKeys: String, CodingKey {
        case label
        case rawNext = "next"
    }
}

struct ProfileV3AIConnectorScreenDTO: Decodable, Equatable {
    let type: String?
    let connector: String?
    let eyebrow: String?
    let title: String?
    let imageURL: String?
    let subtitle: String?
    private let rawBenefits: [ProfileV3LossyDTO<ProfileV3AIConnectorBenefitDTO>]?
    private let rawDisclaimers: [ProfileV3LossyDTO<ProfileV3AIConnectorDisclaimerDTO>]?
    private let rawCTA: ProfileV3LossyDTO<ProfileV3AIConnectorCTADTO>?

    var benefits: [ProfileV3AIConnectorBenefitDTO] { rawBenefits?.compactMap(\.value) ?? [] }
    var disclaimers: [ProfileV3AIConnectorDisclaimerDTO] { rawDisclaimers?.compactMap(\.value) ?? [] }
    var cta: ProfileV3AIConnectorCTADTO? { rawCTA?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case connector
        case eyebrow
        case title
        case imageURL = "image_url"
        case subtitle
        case rawBenefits = "benefits"
        case rawDisclaimers = "disclaimers"
        case rawCTA = "cta"
    }
}

struct ProfileV3AIConnectorPromptDTO: Decodable, Equatable {
    let text: String?
    let copyLabel: String?
    let copiedLabel: String?

    enum CodingKeys: String, CodingKey {
        case text
        case copyLabel = "copy_label"
        case copiedLabel = "copied_label"
    }
}

struct ProfileV3AIConnectorInputDTO: Decodable, Equatable {
    let key: String?
    let placeholder: String?
}

struct ProfileV3AIConnectorSubmitDTO: Decodable, Equatable {
    let label: String?
    let action: String?
    let connector: String?
}

struct ProfileV3AIConnectorStepDTO: Decodable, Equatable {
    let label: String?
    let title: String?
    let body: String?
    private let rawPrompt: ProfileV3LossyDTO<ProfileV3AIConnectorPromptDTO>?
    private let rawInput: ProfileV3LossyDTO<ProfileV3AIConnectorInputDTO>?
    private let rawSubmit: ProfileV3LossyDTO<ProfileV3AIConnectorSubmitDTO>?

    var prompt: ProfileV3AIConnectorPromptDTO? { rawPrompt?.value }
    var input: ProfileV3AIConnectorInputDTO? { rawInput?.value }
    var submit: ProfileV3AIConnectorSubmitDTO? { rawSubmit?.value }

    enum CodingKeys: String, CodingKey {
        case label
        case title
        case body
        case rawPrompt = "prompt"
        case rawInput = "input"
        case rawSubmit = "submit"
    }
}

struct ProfileV3AIConnectorConnectScreenDTO: Decodable, Equatable {
    let type: String?
    let connector: String?
    let eyebrow: String?
    let title: String?
    let imageURL: String?
    private let rawSteps: [ProfileV3LossyDTO<ProfileV3AIConnectorStepDTO>]?

    var steps: [ProfileV3AIConnectorStepDTO] { rawSteps?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case type
        case connector
        case eyebrow
        case title
        case imageURL = "image_url"
        case rawSteps = "steps"
    }
}
