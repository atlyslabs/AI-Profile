import Foundation

struct ProfileV3DirectiveDTO: Decodable, Equatable {
    let go: String
    let profileID: String?
    let agentType: String?
    let benefitID: String?
    let connector: String?
    let programID: String?
    let programName: String?
    let kind: String?
    let field: String?
    let fieldKey: String?
    let reason: String?
    let trait: String?
    private let rawSteps: ProfileV3LossyDTO<[String]>?
    private let rawPage: ProfileV3LossyDTO<ProfileV3ScalarDTO>?
    private let rawPrompt: ProfileV3LossyDTO<String>?

    var steps: [String] { rawSteps?.value ?? [] }
    var page: Int? { rawPage?.value?.intValue }
    var prompt: String? { rawPrompt?.value }

    enum CodingKeys: String, CodingKey {
        case go
        case profileID = "profile_id"
        case agentType = "agent_type"
        case benefitID = "benefit_id"
        case connector
        case programID = "program_id"
        case programName = "program_name"
        case kind
        case field
        case fieldKey = "field_key"
        case reason
        case trait
        case rawSteps = "steps"
        case rawPage = "page"
        case rawPrompt = "prompt"
    }

    var directive: ProfileV3Directive {
        ProfileV3Directive(
            go: go,
            profileID: profileID,
            agentType: agentType,
            benefitID: benefitID,
            connector: connector,
            programID: programID,
            programName: programName,
            kind: kind,
            field: field,
            fieldKey: fieldKey,
            reason: reason,
            steps: steps,
            trait: trait,
            page: page,
            prompt: prompt
        )
    }
}

struct ProfileV3NavCTADTO: Decodable, Equatable {
    let label: String
    let next: ProfileV3DirectiveDTO
    let icon: String?
    let style: String?
}

struct ProfileV3OfferCardDTO: Decodable, Equatable {
    let id: String
    let title: String
    let body: String
    let imageURL: String?
    let art: String?
    let next: ProfileV3DirectiveDTO?
    let activate: ProfileV3NavCTADTO?
    let usage: String?
    let validTill: String?
    let progress: ProfileV3ScalarDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case imageURL = "image_url"
        case art
        case next
        case activate
        case usage
        case validTill = "valid_till"
        case progress
    }
}

struct ProfileV3ProgrammeRowDTO: Decodable, Equatable {
    let id: String
    let name: String
    let kind: String?
    let points: ProfileV3ScalarDTO?
    let expiry: String?
    let last4: String?
    let art: String?
    let artPlaceholder: Bool?
    let textOverlay: String?
    let imageURL: String?
    let pointsLine: String?
    let membershipNumber: String?
    let lastUpdatedAt: String?
    let tier: String?
    let updatedLine: String?
    let artAspect: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case kind
        case points
        case expiry
        case last4
        case art
        case artPlaceholder = "art_placeholder"
        case textOverlay = "text_overlay"
        case imageURL = "image_url"
        case pointsLine = "points_line"
        case membershipNumber = "membership_number"
        case lastUpdatedAt = "last_updated_at"
        case tier
        case updatedLine = "updated_line"
        case artAspect = "art_aspect"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let id = container.lenientString(forKey: .id), let name = container.lenientString(forKey: .name) else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "missing id or name")
        }
        self.id = id
        self.name = name
        kind = container.lenientString(forKey: .kind)
        points = (try? container.decodeIfPresent(ProfileV3ScalarDTO.self, forKey: .points)) ?? nil
        expiry = container.lenientString(forKey: .expiry)
        last4 = container.lenientString(forKey: .last4)
        art = container.lenientString(forKey: .art)
        artPlaceholder = (try? container.decodeIfPresent(Bool.self, forKey: .artPlaceholder)) ?? nil
        textOverlay = container.lenientString(forKey: .textOverlay)
        imageURL = container.lenientString(forKey: .imageURL)
        pointsLine = container.lenientString(forKey: .pointsLine)
        membershipNumber = container.lenientString(forKey: .membershipNumber)
        lastUpdatedAt = container.lenientString(forKey: .lastUpdatedAt)
        tier = container.lenientString(forKey: .tier)
        updatedLine = container.lenientString(forKey: .updatedLine)
        artAspect = ((try? container.decodeIfPresent(ProfileV3ScalarDTO.self, forKey: .artAspect)) ?? nil)?.doubleValue
    }
}

struct ProfileV3LabelDTO: Decodable, Equatable {
    let label: String?
}

extension KeyedDecodingContainer {
    func lenientString(forKey key: Key) -> String? {
        guard let scalar = (try? decodeIfPresent(ProfileV3ScalarDTO.self, forKey: key)) ?? nil else { return nil }
        return scalar.stringValue
    }
}

enum ProfileV3ScalarDTO: Decodable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) { self = .bool(value); return }
        if let value = try? container.decode(Int.self) { self = .int(value); return }
        if let value = try? container.decode(Double.self) { self = .double(value); return }
        if let value = try? container.decode(String.self) { self = .string(value); return }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "unsupported scalar")
    }

    var intValue: Int? {
        switch self {
        case .int(let value):
            return value
        case .double(let value):
            return Self.integer(value)
        case .string(let value):
            let number = Self.numberText(value)
            return Int(number) ?? Double(number).flatMap(Self.integer)
        case .bool:
            return nil
        }
    }

    var doubleValue: Double? {
        switch self {
        case .int(let value): return Double(value)
        case .double(let value): return value.isFinite ? value : nil
        case .string(let value): return Double(Self.numberText(value)).flatMap { $0.isFinite ? $0 : nil }
        case .bool: return nil
        }
    }

    var stringValue: String? {
        switch self {
        case .string(let value): return value
        case .int(let value): return String(value)
        case .double(let value): return Int(exactly: value).map(String.init) ?? String(value)
        case .bool: return nil
        }
    }

    private static func numberText(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: "")
    }

    private static func integer(_ value: Double) -> Int? {
        guard value.isFinite else { return nil }
        return Int(exactly: value.rounded(.towardZero))
    }

    var boolValue: Bool? {
        if case .bool(let value) = self { return value }
        return nil
    }
}
