import Foundation

struct ProfileV3TermsMarkDTO: Decodable, Equatable {
    let type: String?
}

struct ProfileV3TermsNodeDTO: Decodable, Equatable {
    let type: String?
    let text: String?
    let marks: [ProfileV3TermsMarkDTO]?
    let content: [ProfileV3TermsNodeDTO]?
}

struct ProfileV3TermsRichTextDTO: Decodable, Equatable {
    let type: String?
    let content: [ProfileV3TermsNodeDTO]?
}

struct ProfileV3TermsBlockDTO: Decodable, Equatable {
    let id: String?
    let type: String?
    let richText: ProfileV3TermsRichTextDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case richText = "rich_text"
    }
}

struct ProfileV3TermsScreenDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    private let rawBlocks: [ProfileV3LossyDTO<ProfileV3TermsBlockDTO>]?

    var blocks: [ProfileV3TermsBlockDTO] { rawBlocks?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case rawBlocks = "blocks"
    }
}
