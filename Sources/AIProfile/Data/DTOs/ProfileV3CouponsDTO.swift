import Foundation

struct ProfileV3CouponProgressDTO: Decodable, Equatable {
    let used: ProfileV3ScalarDTO?
    let total: ProfileV3ScalarDTO?
    let percent: ProfileV3ScalarDTO?
}

struct ProfileV3CouponCardDTO: Decodable, Equatable {
    let id: String?
    let title: String?
    let imageURL: String?
    let art: String?
    let usedLabel: String?
    let activeLabel: String?
    let percentRedeemed: ProfileV3ScalarDTO?
    let progress: ProfileV3CouponProgressDTO?
    private let rawNext: ProfileV3LossyDTO<ProfileV3DirectiveDTO>?

    var next: ProfileV3DirectiveDTO? { rawNext?.value }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageURL = "image_url"
        case art
        case usedLabel = "used_label"
        case activeLabel = "active_label"
        case percentRedeemed = "percent_redeemed"
        case progress
        case rawNext = "next"
    }
}

struct ProfileV3CouponsSectionDTO: Decodable, Equatable {
    let kind: String?
    private let rawFeatured: ProfileV3LossyDTO<ProfileV3CouponCardDTO>?
    private let rawViewAll: ProfileV3LossyDTO<ProfileV3NavCTADTO>?

    var featured: ProfileV3CouponCardDTO? { rawFeatured?.value }
    var viewAll: ProfileV3NavCTADTO? { rawViewAll?.value }

    enum CodingKeys: String, CodingKey {
        case kind
        case rawFeatured = "featured"
        case rawViewAll = "view_all"
    }
}

struct ProfileV3CouponsSheetDTO: Decodable, Equatable {
    let type: String?
    let title: String?
    let subtitle: String?
    let count: ProfileV3ScalarDTO?
    private let rawCoupons: [ProfileV3LossyDTO<ProfileV3CouponCardDTO>]?

    var coupons: [ProfileV3CouponCardDTO] { rawCoupons?.compactMap(\.value) ?? [] }

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case subtitle
        case count
        case rawCoupons = "coupons"
    }
}

struct ProfileV3CouponAmountDTO: Decodable, Equatable {
    let label: String?
}

struct ProfileV3CouponActionDTO: Decodable, Equatable {
    let label: String?
    let action: String?
    let next: ProfileV3DirectiveDTO?
}

struct ProfileV3CouponDetailDTO: Decodable, Equatable {
    let type: String?
    let id: String?
    let imageURL: String?
    let art: String?
    let title: String?
    let totalLimit: ProfileV3CouponAmountDTO?
    let amountRedeemed: ProfileV3CouponAmountDTO?
    let balance: ProfileV3CouponAmountDTO?
    let percentRedeemed: ProfileV3ScalarDTO?
    let activeLabel: String?
    let termsTitle: String?
    let terms: String?
    private let rawRedeem: ProfileV3LossyDTO<ProfileV3CouponActionDTO>?
    private let rawGotIt: ProfileV3LossyDTO<ProfileV3CouponActionDTO>?

    var redeem: ProfileV3CouponActionDTO? { rawRedeem?.value }
    var gotIt: ProfileV3CouponActionDTO? { rawGotIt?.value }

    enum CodingKeys: String, CodingKey {
        case type
        case id
        case imageURL = "image_url"
        case art
        case title
        case totalLimit = "total_limit"
        case amountRedeemed = "amount_redeemed"
        case balance
        case percentRedeemed = "percent_redeemed"
        case activeLabel = "active_label"
        case termsTitle = "terms_title"
        case terms
        case rawRedeem = "redeem"
        case rawGotIt = "got_it"
    }
}
