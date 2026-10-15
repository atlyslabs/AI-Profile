import Foundation

struct ProfileV3Coupon: Identifiable, Equatable {
    let id: String
    let title: String
    let usedLabel: String
    let activeLabel: String
    let percentRedeemed: Double
    var imageURL: URL?
    var next: ProfileV3Directive?

    var isDepleted: Bool { percentRedeemed >= 1 }

    var pendingDetail: ProfileV3CouponDetail {
        ProfileV3CouponDetail(
            id: id,
            title: title,
            imageURL: imageURL,
            totalLimit: "",
            amountRedeemed: "",
            balance: "",
            usedLabel: usedLabel,
            percentRedeemed: percentRedeemed,
            activeLabel: activeLabel,
            termsTitle: ProfileV3Strings.termsAndConditions,
            terms: "",
            redeemLabel: nil,
            gotItLabel: ProfileV3Strings.gotIt
        )
    }
}

struct ProfileV3CouponsSheet: Equatable {
    static let empty = ProfileV3CouponsSheet(title: "", subtitle: "", count: 0, coupons: [])

    let title: String
    let subtitle: String
    let count: Int
    let coupons: [ProfileV3Coupon]
}

struct ProfileV3CouponDetail: Equatable {
    let id: String
    let title: String
    var imageURL: URL?
    let totalLimit: String
    let amountRedeemed: String
    let balance: String
    let usedLabel: String
    let percentRedeemed: Double
    let activeLabel: String
    let termsTitle: String
    let terms: String
    var redeemLabel: String?
    let gotItLabel: String

    var isDepleted: Bool { percentRedeemed >= 1 }
}
