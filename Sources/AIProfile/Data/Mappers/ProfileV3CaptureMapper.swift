import Foundation

enum ProfileV3CaptureMapper: ProfileV3DTOReading {
    static func step(_ dto: ProfileV3CaptureStepDTO?) -> ProfileV3CaptureStep? {
        guard let dto, let type = text(dto.type) else { return nil }
        return ProfileV3CaptureStep(
            id: dto.id ?? "",
            type: type,
            title: text(dto.title),
            subtitle: text(dto.subtitle),
            passportFront: copy(dto.passportFront),
            passportBack: copy(dto.passportBack),
            connectorState: dto.state.flatMap(ProfileV3CaptureStep.ConnectorState.init(rawValue:)),
            pollAfterMilliseconds: dto.pollAfterMs,
            cardTitle: text(dto.cardTitle),
            cardSubtitle: text(dto.cardSubtitle),
            connectCTA: text(dto.connectCTA),
            lookingFor: dto.lookingFor.compactMap(lookingFor),
            userImageURL: remoteURL(dto.userImage),
            icons: dto.icons.compactMap { item in
                text(item.icon).map { ProfileV3CaptureIcon(icon: $0, label: text(item.label)) }
            },
            errorMessage: text(dto.error),
            skippable: dto.skippable ?? false,
            skipCTA: text(dto.skipCTA),
            findings: dto.findings.map(findings)
        )
    }

    private static func findings(_ dto: ProfileV3CaptureFindingsDTO) -> ProfileV3CaptureFindings {
        ProfileV3CaptureFindings(
            title: text(dto.title),
            stats: dto.stats.compactMap { stat in
                guard let label = text(stat.label), let value = text(stat.value) else { return nil }
                return ProfileV3CaptureStat(label: label, value: value)
            }
        )
    }

    private static func lookingFor(_ dto: ProfileV3CaptureLookingForDTO) -> ProfileV3CaptureLookingFor? {
        guard let title = text(dto.title) ?? text(dto.label) else { return nil }
        return ProfileV3CaptureLookingFor(icon: text(dto.icon), title: title, body: text(dto.body))
    }

    private static func copy(_ dto: ProfileV3CaptureSideDTO?) -> ProfileV3CaptureCopy? {
        guard let dto, text(dto.title) != nil || text(dto.subtitle) != nil else { return nil }
        return ProfileV3CaptureCopy(title: text(dto.title), subtitle: text(dto.subtitle))
    }
}

struct ProfileV3CaptureBody: Equatable {
    let data: Data
    let contentType: String
}

enum ProfileV3CaptureEncoder {
    static func start(steps: [String], profileID: String?) throws -> Data {
        var body: [String: Any] = ["steps": steps]
        if let profileID { body["profile_id"] = profileID }
        return try JSONSerialization.data(withJSONObject: body, options: [])
    }

    static func answer(_ answer: ProfileV3CaptureAnswer, stepID: String) throws -> ProfileV3CaptureBody {
        let payload: [String: Any]
        switch answer {
        case .gmailAuthCode(let code): payload = ["server_auth_code": code]
        case .passportDone: payload = ["action": "done"]
        case .itrCredentials(let pan, let password): payload = ["path": "connect", "pan": pan, "password": password]
        case .skipped: payload = ["skipped": true]
        case .connectorAcknowledged: payload = ["connected": true]
        }
        let data = try JSONSerialization.data(withJSONObject: ["step_id": stepID, "payload": payload], options: [])
        return ProfileV3CaptureBody(data: data, contentType: "application/json")
    }

    static func image(
        _ image: ProfileV3CaptureImage,
        data: Data,
        stepID: String,
        residenceCountryCode: String?
    ) throws -> ProfileV3CaptureBody {
        var payload: [String: Any] = [:]
        switch image {
        case .passportFront: payload["side"] = "passport_front"
        case .passportBack: payload["side"] = "passport_back"
        case .selfie: break
        }
        if let residenceCountryCode { payload["residence_country_code"] = residenceCountryCode }
        return try multipart(
            metadata: ["step_id": stepID, "payload": payload],
            partName: "file",
            fileName: fileName(for: image),
            data: data
        )
    }

    static func document(_ data: Data, stepID: String) throws -> ProfileV3CaptureBody {
        try multipart(
            metadata: ["step_id": stepID, "payload": ["path": "upload"]],
            partName: "file",
            fileName: "itr.pdf",
            mimeType: "application/pdf",
            data: data
        )
    }

    static func coTraveller(
        _ image: ProfileV3CaptureImage,
        data: Data,
        profileID: String
    ) throws -> ProfileV3CaptureBody {
        try multipart(
            metadata: ["profile_id": profileID],
            partName: coTravellerPartName(for: image),
            fileName: fileName(for: image),
            data: data
        )
    }

    private static func coTravellerPartName(for image: ProfileV3CaptureImage) -> String {
        switch image {
        case .passportFront: return "passportFront"
        case .passportBack: return "passportBack"
        case .selfie: return "selfie"
        }
    }

    private static func fileName(for image: ProfileV3CaptureImage) -> String {
        switch image {
        case .passportFront: return "passport_front.jpg"
        case .passportBack: return "passport_back.jpg"
        case .selfie: return "selfie.jpg"
        }
    }

    private static func multipart(
        metadata: [String: Any],
        partName: String,
        fileName: String,
        mimeType: String = "image/jpeg",
        data: Data
    ) throws -> ProfileV3CaptureBody {
        let boundary = ProfileV3Multipart.generateBoundary()
        let metadataJSON = try JSONSerialization.data(withJSONObject: metadata, options: [])
        let body = ProfileV3Multipart.buildBody(
            boundary: boundary,
            fields: [
                ProfileV3Multipart.Field(name: "metadata", value: String(decoding: metadataJSON, as: UTF8.self))
            ],
            files: [
                ProfileV3Multipart.FileField(name: partName, fileName: fileName, mimeType: mimeType, data: data)
            ]
        )
        return ProfileV3CaptureBody(data: body, contentType: "multipart/form-data; boundary=\(boundary)")
    }
}
