import Foundation

enum ProfileV3CouponsMapper: ProfileV3DTOReading {

    static func sheet(_ dto: ProfileV3CouponsSheetDTO) -> ProfileV3CouponsSheet {
        let coupons = dto.coupons.compactMap(coupon)
        return ProfileV3CouponsSheet(
            title: text(dto.title) ?? "",
            subtitle: text(dto.subtitle) ?? "",
            count: dto.count?.intValue ?? coupons.count,
            coupons: coupons
        )
    }

    static func coupon(_ dto: ProfileV3CouponCardDTO) -> ProfileV3Coupon? {
        guard let id = text(dto.id) else { return nil }
        return ProfileV3Coupon(
            id: id,
            title: text(dto.title) ?? "",
            usedLabel: text(dto.usedLabel) ?? "",
            activeLabel: text(dto.activeLabel) ?? "",
            percentRedeemed: fraction(dto.percentRedeemed ?? dto.progress?.percent),
            imageURL: remoteURL(dto.imageURL) ?? remoteURL(dto.art),
            next: dto.next?.directive
        )
    }

    static func detail(_ dto: ProfileV3CouponDetailDTO) -> ProfileV3CouponDetail? {
        guard let id = text(dto.id) else { return nil }
        return ProfileV3CouponDetail(
            id: id,
            title: text(dto.title) ?? "",
            imageURL: remoteURL(dto.imageURL) ?? remoteURL(dto.art),
            totalLimit: text(dto.totalLimit?.label) ?? "",
            amountRedeemed: text(dto.amountRedeemed?.label) ?? "",
            balance: text(dto.balance?.label) ?? "",
            usedLabel: text(dto.amountRedeemed?.label).map(ProfileV3Strings.couponUsed) ?? "",
            percentRedeemed: fraction(dto.percentRedeemed),
            activeLabel: text(dto.activeLabel) ?? "",
            termsTitle: text(dto.termsTitle) ?? "",
            terms: text(dto.terms) ?? "",
            redeemLabel: text(dto.redeem?.label),
            gotItLabel: text(dto.gotIt?.label) ?? ""
        )
    }
}
