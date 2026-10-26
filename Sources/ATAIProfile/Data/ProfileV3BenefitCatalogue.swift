import Foundation

#if DEBUG
enum ProfileV3BenefitCatalogue {

    static let all: [ProfileV3Benefit] = [
        benefit(
            id: "visas-minutes",
            title: "Visas approved in minutes",
            subtitle: "Your documents are in your vault. File in minutes, with no re-uploads."
        ),
        benefit(
            id: "slot-priority",
            title: "Slot priority at every embassy",
            subtitle: "Get priority access to visa appointment slots across embassies"
        ),
        benefit(
            id: "slot-calendar",
            title: "24/7 slot calendar analysis",
            subtitle: "24/7 slot monitoring, with new openings grabbed instantly."
        ),
        benefit(
            id: "zero-forms",
            title: "0 forms filled by you",
            subtitle: "Forms filled by you, everything filed from your vault"
        ),
        benefit(
            id: "fees-refunded",
            title: "Visa fees, refunded",
            subtitle: refundSubtitle
        ),
        benefit(
            id: "trip-covered",
            title: "Flights & hotels, covered",
            subtitle: "If a rejection kills the trip, eligible flight and hotel costs are covered."
        ),
        benefit(
            id: "flights-cashback",
            title: "Flat 5% back on flights",
            subtitle: "Book flights in the app and get a flat 5% back in Atlys credits. No hidden fees.",
            terms: ProfileV3Strings.flightCashbackTerms
        ),
        benefit(
            id: "flight-credits",
            title: "$50 flight credits",
            subtitle: refundSubtitle
        ),
        benefit(
            id: "fast-track",
            title: "Fast track immigration",
            subtitle: expeditedSubtitle
        ),
        benefit(
            id: "transfers-discount",
            title: "Flat 15% off on transfers",
            subtitle: "Airport transfers included + $20 credit on eligible spends"
        ),
        benefit(
            id: "emergency-hotline",
            title: "Emergency hotline",
            subtitle: expeditedSubtitle
        ),
        benefit(
            id: "passport-lost",
            title: "Passport lost? handled.",
            subtitle: expeditedSubtitle
        ),
        benefit(
            id: "flight-delay",
            title: "$200 flight delay protection",
            subtitle: expeditedSubtitle
        ),
        benefit(
            id: "baggage-protection",
            title: "$500 baggage protection",
            subtitle: expeditedSubtitle
        ),
        benefit(
            id: "medical-cover",
            title: "$50,000 medical cover",
            subtitle: expeditedSubtitle
        ),
        benefit(
            id: "hotels-cashback",
            title: "Flat 10% off on hotels",
            subtitle: "Book stays in the app and get a flat 10% back in Atlys credits"
        ),
        benefit(
            id: "hotel-credit",
            title: "Flat 10% off on hotels",
            subtitle: "Twice-yearly hotel credit at select hotels, on top of your flat 10%"
        ),
        benefit(
            id: "zero-forex",
            title: "0 forex",
            subtitle: "Spend abroad at the real rate. No markup, no hidden fees."
        )
    ]

    private static let refundSubtitle =
        "Your Atlys fee and full government fee come back on rejection. It\u{2019}s automatic"
    private static let expeditedSubtitle = "Global Entry\u{2013}style expedited lanes at major airports"

    private static func benefit(
        id: String,
        title: String,
        subtitle: String,
        terms: String = "Available to active World Pass members. Eligibility, exclusions and booking conditions may apply."
    ) -> ProfileV3Benefit {
        ProfileV3Benefit(
            id: id,
            title: title,
            subtitle: subtitle,
            imageURL: nil,
            status: .locked,
            terms: terms
        )
    }
}
#endif
