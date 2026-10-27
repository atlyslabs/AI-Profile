import Foundation

struct ProfileV3AgentPassportDTO: Decodable, Equatable {
    let name: String?
    let title: String?
    let number: String?
    let issueDate: String?
    let expiryDate: String?
    let status: String?
    let verified: Bool?
    private let rawRescan: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?
    private let rawHowUsed: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?
    private let rawPrevious: ProfileV3LossyDTO<ProfileV3PassportPreviousDTO>?

    var rescan: ProfileV3DirectiveDTO? { rawRescan?.value }
    var howUsed: ProfileV3DirectiveDTO? { rawHowUsed?.value }
    var previous: ProfileV3PassportPreviousDTO? { rawPrevious?.value }

    enum CodingKeys: String, CodingKey {
        case name
        case title
        case number
        case issueDate = "issue_date"
        case expiryDate = "expiry_date"
        case status
        case verified
        case rawRescan = "rescan"
        case rawHowUsed = "how_used"
        case rawPrevious = "previous"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = container.lenientString(forKey: .name)
        title = container.lenientString(forKey: .title)
        number = container.lenientString(forKey: .number)
        issueDate = container.lenientString(forKey: .issueDate)
        expiryDate = container.lenientString(forKey: .expiryDate)
        status = container.lenientString(forKey: .status)
        verified = try? container.decodeIfPresent(Bool.self, forKey: .verified)
        rawRescan = try? container.decodeIfPresent(ProfileV3LossyDTO<ProfileV3DirectiveDTO>.self, forKey: .rawRescan)
        rawHowUsed = try? container.decodeIfPresent(ProfileV3LossyDTO<ProfileV3DirectiveDTO>.self, forKey: .rawHowUsed)
        rawPrevious = try? container.decodeIfPresent(
            ProfileV3LossyDTO<ProfileV3PassportPreviousDTO>.self,
            forKey: .rawPrevious
        )
    }
}

struct ProfileV3PassportPreviousDTO: Decodable, Equatable {
    let label: String?
    let title: String?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    var next: ProfileV3DirectiveDTO? { rawNext?.value }

    enum CodingKeys: String, CodingKey {
        case label
        case title
        case rawNext = "next"
    }
}

struct ProfileV3PassportLabelsDTO: Decodable, Equatable {
    let number: String?
    let issueDate: String?
    let expiryDate: String?

    enum CodingKeys: String, CodingKey {
        case number
        case issueDate = "issue_date"
        case expiryDate = "expiry_date"
    }
}

struct ProfileV3PreviousPassportsScreenDTO: Decodable, Equatable {
    let title: String?
    private let rawLabels: ProfileV3LossyDTO<ProfileV3PassportLabelsDTO>?
    private let rawPassports: [ProfileV3LossyDTO<ProfileV3AgentPassportDTO>]?

    var labels: ProfileV3PassportLabelsDTO? { rawLabels?.value }
    var passports: [ProfileV3AgentPassportDTO] { rawPassports?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case title
        case rawLabels = "labels"
        case rawPassports = "passports"
    }
}

struct ProfileV3PassportScanSideDTO: Decodable, Equatable {
    let title: String?
    let subtitle: String?
}

struct ProfileV3PassportScanScreenDTO: Decodable, Equatable {
    let title: String?
    private let rawHowUsed: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?
    private let rawFront: ProfileV3LossyDTO<ProfileV3PassportScanSideDTO>?
    private let rawBack: ProfileV3LossyDTO<ProfileV3PassportScanSideDTO>?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    var howUsed: ProfileV3DirectiveDTO? { rawHowUsed?.value }
    var front: ProfileV3PassportScanSideDTO? { rawFront?.value }
    var back: ProfileV3PassportScanSideDTO? { rawBack?.value }
    var next: ProfileV3DirectiveDTO? { rawNext?.value }

    enum CodingKeys: String, CodingKey {
        case title
        case rawHowUsed = "how_used"
        case rawFront = "front"
        case rawBack = "back"
        case rawNext = "next"
    }
}

struct ProfileV3PassportScanResponseDTO: Decodable, Equatable {
    let ok: Bool?
    let side: String?
    let backRequired: Bool?
    let nationality: String?
    private let rawPassport: ProfileV3LossyDTO<ProfileV3AgentPassportDTO>?

    var passport: ProfileV3AgentPassportDTO? { rawPassport?.value }

    enum CodingKeys: String, CodingKey {
        case ok
        case side
        case backRequired = "back_required"
        case nationality
        case rawPassport = "passport"
    }
}

struct ProfileV3PassportReasonOptionDTO: Decodable, Equatable {
    let value: String?
    let label: String?
}

struct ProfileV3PassportReasonSubmitDTO: Decodable, Equatable {
    let ctaTitle: String?

    enum CodingKeys: String, CodingKey {
        case ctaTitle = "cta_title"
    }
}

struct ProfileV3PassportReasonScreenDTO: Decodable, Equatable {
    let title: String?
    let subtitle: String?
    private let rawHowUsed: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?
    private let rawOptions: [ProfileV3LossyDTO<ProfileV3PassportReasonOptionDTO>]?
    private let rawSubmit: ProfileV3LossyDTO<ProfileV3PassportReasonSubmitDTO>?

    var howUsed: ProfileV3DirectiveDTO? { rawHowUsed?.value }
    var options: [ProfileV3PassportReasonOptionDTO] { rawOptions?.compactMap(\.value) ?? [] }
    var submit: ProfileV3PassportReasonSubmitDTO? { rawSubmit?.value }

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case rawHowUsed = "how_used"
        case rawOptions = "options"
        case rawSubmit = "submit"
    }
}

struct ProfileV3PassportHowUsedStepDTO: Decodable, Equatable {
    let icon: String?
    let title: String?
    let body: String?
}

struct ProfileV3PassportHowUsedScanDTO: Decodable, Equatable {
    let label: String?
    let next: ProfileV3DirectiveDTO?
}

struct ProfileV3PassportHowUsedScreenDTO: Decodable, Equatable {
    let title: String?
    private let rawSteps: [ProfileV3LossyDTO<ProfileV3PassportHowUsedStepDTO>]?
    private let rawScan: ProfileV3LossyDTO<ProfileV3PassportHowUsedScanDTO>?

    var steps: [ProfileV3PassportHowUsedStepDTO] { rawSteps?.compactMap(\.value) ?? [] }
    var scan: ProfileV3PassportHowUsedScanDTO? { rawScan?.value }

    enum CodingKeys: String, CodingKey {
        case title
        case rawSteps = "steps"
        case rawScan = "scan"
    }
}

struct ProfileV3UpdatePassportRequest: Encodable, Equatable {
    let action = "update_passport"
    let reason: String
    var profileID: String?

    enum CodingKeys: String, CodingKey {
        case action
        case reason
        case profileID = "profile_id"
    }
}
