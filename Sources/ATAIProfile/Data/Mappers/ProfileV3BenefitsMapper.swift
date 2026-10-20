import Foundation

enum ProfileV3BenefitsMapper: ProfileV3DTOReading {

    static func sheet(_ dto: ProfileV3BenefitsSheetDTO) -> ProfileV3BenefitsSheet {
        let offers = dto.offers.map(offer)
        return ProfileV3BenefitsSheet(
            title: text(dto.title) ?? "",
            subtitle: text(dto.subtitle) ?? "",
            count: dto.count?.intValue ?? offers.count,
            learnMoreLabel: text(dto.learnMore?.label) ?? "",
            learnMore: dto.learnMore?.next.directive,
            offers: offers
        )
    }

    static func detail(_ dto: ProfileV3BenefitDetailDTO) -> ProfileV3Benefit? {
        guard let id = dto.id, !id.isEmpty else { return nil }
        return ProfileV3Benefit(
            id: id,
            title: dto.title ?? "",
            subtitle: "",
            imageURL: remoteURL(dto.imageURL) ?? remoteURL(dto.art),
            status: usageStatus(
                usage: dto.usage,
                validTill: dto.validTill,
                progress: dto.progress ?? dto.percentRedeemed
            ),
            terms: text(dto.terms),
            termsTitle: text(dto.termsTitle),
            iconState: dto.iconState
        )
    }

    static func offer(_ dto: ProfileV3OfferCardDTO) -> ProfileV3Benefit {
        ProfileV3Benefit(
            id: dto.id,
            title: dto.title,
            subtitle: dto.body,
            imageURL: remoteURL(dto.imageURL) ?? remoteURL(dto.art),
            status: offerStatus(dto)
        )
    }

    private static func offerStatus(_ dto: ProfileV3OfferCardDTO) -> ProfileV3Benefit.Status {
        guard dto.activate == nil else { return .locked }
        return usageStatus(usage: dto.usage, validTill: dto.validTill, progress: dto.progress)
    }

    private static func usageStatus(
        usage: String?,
        validTill: String?,
        progress: ProfileV3ScalarDTO?
    ) -> ProfileV3Benefit.Status {
        let validTill = text(validTill) ?? ""
        guard let usage = text(usage) else { return .active(validTill: validTill) }
        return .partiallyRedeemed(usage: usage, validTill: validTill, progress: fraction(progress))
    }
}
