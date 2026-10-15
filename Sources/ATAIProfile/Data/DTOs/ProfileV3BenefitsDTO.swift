import Foundation

struct ProfileV3BenefitsSheetDTO: Decodable, Equatable {
    let title: String?
    let subtitle: String?
    let count: ProfileV3ScalarDTO?
    private let rawLearnMore: ProfileV3LossyDTO<ProfileV3NavCTADTO>?
    private let rawOffers: [ProfileV3LossyDTO<ProfileV3OfferCardDTO>]?

    var learnMore: ProfileV3NavCTADTO? { rawLearnMore?.value }
    var offers: [ProfileV3OfferCardDTO] { rawOffers?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case count
        case rawLearnMore = "learn_more"
        case rawOffers = "offers"
    }
}

struct ProfileV3BenefitDetailDTO: Decodable, Equatable {
    let id: String?
    let imageURL: String?
    let art: String?
    let title: String?
    let termsTitle: String?
    let terms: String?
    let usage: String?
    let validTill: String?
    let progress: ProfileV3ScalarDTO?
    let percentRedeemed: ProfileV3ScalarDTO?
    let iconState: String?

    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "image_url"
        case art
        case title
        case termsTitle = "terms_title"
        case terms
        case usage
        case validTill = "valid_till"
        case progress
        case percentRedeemed = "percent_redeemed"
        case iconState = "icon_state"
    }
}
