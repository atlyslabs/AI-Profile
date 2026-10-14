import Foundation

struct ProfileV3CaptureEnvelopeDTO: Decodable, Equatable {
    private let rawNextStep: ProfileV3LossyDTO<ProfileV3CaptureStepDTO>?
    private let rawError: ProfileV3LossyDTO<ProfileV3CaptureErrorDTO>?

    var nextStep: ProfileV3CaptureStepDTO? { rawNextStep?.value }
    var error: ProfileV3CaptureErrorDTO? { rawError?.value }

    enum CodingKeys: String, CodingKey {
        case rawNextStep = "next_step"
        case rawError = "error"
    }
}

struct ProfileV3CaptureStepDTO: Decodable, Equatable {
    let id: String?
    let type: String?
    let title: String?
    let subtitle: String?
    private let rawPassportFront: ProfileV3LossyDTO<ProfileV3CaptureSideDTO>?
    private let rawPassportBack: ProfileV3LossyDTO<ProfileV3CaptureSideDTO>?
    let state: String?
    private let rawPollAfterMs: ProfileV3LossyDTO<Int>?
    let cardTitle: String?
    let cardSubtitle: String?
    let connectCTA: String?
    private let rawLookingFor: [ProfileV3LossyDTO<ProfileV3CaptureLookingForDTO>]?
    let userImage: String?
    private let rawIcons: [ProfileV3LossyDTO<ProfileV3CaptureIconDTO>]?
    private let rawError: ProfileV3LossyDTO<ProfileV3CaptureStepErrorDTO>?
    let skippable: Bool?
    let skipCTA: String?
    private let rawData: ProfileV3LossyDTO<ProfileV3CaptureFindingsDTO>?

    var passportFront: ProfileV3CaptureSideDTO? { rawPassportFront?.value }
    var passportBack: ProfileV3CaptureSideDTO? { rawPassportBack?.value }
    var pollAfterMs: Int? { rawPollAfterMs?.value }
    var lookingFor: [ProfileV3CaptureLookingForDTO] { rawLookingFor?.compactMap(\.value) ?? [] }
    var icons: [ProfileV3CaptureIconDTO] { rawIcons?.compactMap(\.value) ?? [] }
    var error: String? { rawError?.value?.message }
    var findings: ProfileV3CaptureFindingsDTO? { rawData?.value }

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case subtitle
        case rawPassportFront = "passport_front"
        case rawPassportBack = "passport_back"
        case state
        case rawPollAfterMs = "poll_after_ms"
        case cardTitle = "card_title"
        case cardSubtitle = "card_subtitle"
        case connectCTA = "connect_cta"
        case rawLookingFor = "looking_for"
        case userImage = "user_image"
        case rawIcons = "icons"
        case rawError = "error"
        case skippable
        case skipCTA = "skip_cta"
        case rawData = "data"
    }
}

struct ProfileV3CaptureFindingsDTO: Decodable, Equatable {
    let title: String?
    private let rawStats: [ProfileV3LossyDTO<ProfileV3CaptureStatDTO>]?

    var stats: [ProfileV3CaptureStatDTO] { rawStats?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case title
        case rawStats = "stats"
    }
}

struct ProfileV3CaptureStatDTO: Decodable, Equatable {
    let label: String?
    let value: String?
}

struct ProfileV3CaptureSideDTO: Decodable, Equatable {
    let title: String?
    let subtitle: String?
}

struct ProfileV3CaptureLookingForDTO: Decodable, Equatable {
    let icon: String?
    let title: String?
    let body: String?
    let label: String?
}

struct ProfileV3CaptureIconDTO: Decodable, Equatable {
    let icon: String?
    let label: String?
}

struct ProfileV3CaptureStepErrorDTO: Decodable, Equatable {
    let message: String?

    enum CodingKeys: String, CodingKey { case message }

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(), let message = try? single.decode(String.self) {
            self.message = message.isEmpty ? nil : message
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
}

struct ProfileV3CaptureErrorDTO: Decodable, Equatable {
    let code: String?
    let message: String?
}

struct ProfileV3CoTravellerUploadDTO: Decodable, Equatable {
    private let rawError: ProfileV3LossyDTO<ProfileV3CaptureErrorDTO>?

    var error: ProfileV3CaptureErrorDTO? { rawError?.value }

    enum CodingKeys: String, CodingKey {
        case rawError = "error"
    }
}
