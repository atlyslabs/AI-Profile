import Foundation

struct ProfileV3GloveBoxCardDTO: Decodable, Equatable {
    let address: String?
    let previousAddresses: [String]?
    let forwarding: Forwarding?
    let forwardingPending: Pending?
    let eligible: Bool?

    struct Forwarding: Decodable, Equatable {
        let email: String?
        let paused: Bool?
    }

    struct Pending: Decodable, Equatable {
        let email: String?
        let expiresAt: String?

        enum CodingKeys: String, CodingKey {
            case email
            case expiresAt = "expires_at"
        }
    }

    enum CodingKeys: String, CodingKey {
        case address
        case previousAddresses = "previous_addresses"
        case forwarding
        case forwardingPending = "forwarding_pending"
        case eligible
    }
}

struct ProfileV3GloveBoxMessagesDTO: Decodable, Equatable {
    let items: [ProfileV3GloveBoxMessageItemDTO]
    let nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case items
        case nextCursor = "next_cursor"
    }
}

struct ProfileV3GloveBoxAttentionDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    let detail: String?
}

struct ProfileV3GloveBoxMessageItemDTO: Decodable, Equatable {
    let id: String
    let fromName: String?
    let senderDomain: String?
    let senderLogoURL: String?
    let subject: String?
    let receivedAt: String?
    let toPreviousAddress: Bool?
    let status: String?
    private let rawAttention: ProfileV3LossyDTO<ProfileV3GloveBoxAttentionDTO>?
    private let rawAction: ProfileV3LossyDTO<String>?

    var attention: ProfileV3GloveBoxAttentionDTO? { rawAttention?.value }
    var action: String? { rawAction?.value }

    enum CodingKeys: String, CodingKey {
        case id
        case fromName = "from_name"
        case senderDomain = "sender_domain"
        case senderLogoURL = "sender_logo_url"
        case subject
        case receivedAt = "received_at"
        case toPreviousAddress = "to_previous_address"
        case status
        case rawAttention = "attention"
        case rawAction = "action"
    }
}

struct ProfileV3GloveBoxMessageDTO: Decodable, Equatable {
    let id: String
    let fromName: String?
    let senderLogoURL: String?
    let subject: String?
    let receivedAt: String?
    let toPreviousAddress: Bool?
    let status: String?
    let html: String?
    let text: String?
    let attachments: [ProfileV3GloveBoxAttachmentDTO]?
    private let rawAttention: ProfileV3LossyDTO<ProfileV3GloveBoxAttentionDTO>?
    private let rawAction: ProfileV3LossyDTO<String>?

    var attention: ProfileV3GloveBoxAttentionDTO? { rawAttention?.value }
    var action: String? { rawAction?.value }

    enum CodingKeys: String, CodingKey {
        case id
        case fromName = "from_name"
        case senderLogoURL = "sender_logo_url"
        case subject
        case receivedAt = "received_at"
        case toPreviousAddress = "to_previous_address"
        case status
        case html
        case text
        case attachments
        case rawAttention = "attention"
        case rawAction = "action"
    }
}

struct ProfileV3GloveBoxAttachmentDTO: Decodable, Equatable {
    let filename: String?
    let contentType: String?
    let size: Int?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case filename
        case contentType = "content_type"
        case size
        case url
    }
}

final class ProfileV3GloveBoxClient: @unchecked Sendable {
    private let client: ProfileV3NetworkClient

    init(client: ProfileV3NetworkClient) {
        self.client = client
    }

    func card() async throws -> ProfileV3GloveBoxAccount {
        ProfileV3GloveBoxMapper.account(try await client.request(.gloveBoxMe, action: "glove_box_me"))
    }

    func create() async throws -> ProfileV3GloveBoxAccount {
        ProfileV3GloveBoxMapper.account(try await client.request(.gloveBoxCreate, action: "glove_box_create"))
    }

    func setPaused(_ paused: Bool) async throws -> ProfileV3GloveBoxAccount {
        let body = try JSONEncoder().encode(PauseBody(paused: paused))
        return ProfileV3GloveBoxMapper.account(try await client.request(.gloveBoxForwarding(body: body), action: "glove_box_forwarding"))
    }

    func addForwardingAddress(_ email: String) async throws -> ProfileV3GloveBoxAccount {
        let body = try JSONEncoder().encode(EmailBody(email: email))
        return ProfileV3GloveBoxMapper.account(
            try await client.request(.gloveBoxForwardingAddress(body: body), action: "glove_box_forwarding_address")
        )
    }

    func messages(cursor: String?) async throws -> ProfileV3GloveBoxInboxPage {
        let dto: ProfileV3GloveBoxMessagesDTO = try await client.request(
            .gloveBoxMessages(limit: ProfileV3GloveBoxMapper.pageSize, cursor: cursor),
            action: "glove_box_messages"
        )
        return ProfileV3GloveBoxMapper.page(dto)
    }

    func message(id: String) async throws -> ProfileV3GloveBoxMessageDTO {
        try await client.request(.gloveBoxMessage(id: id), action: "glove_box_message")
    }

    func attachment(messageID: String, index: Int) async throws -> Data {
        try await client.requestData(.gloveBoxAttachment(messageID: messageID, index: index), action: "glove_box_attachment")
    }

    private struct PauseBody: Encodable {
        let paused: Bool
    }

    private struct EmailBody: Encodable {
        let email: String
    }
}
