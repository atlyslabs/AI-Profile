import Foundation

#if DEBUG
enum ProfileV3Fixtures {

    static let programmes: [ProfileV3LoyaltyProgramme] = [
        ProfileV3LoyaltyProgramme(
            id: "bonvoy",
            name: "Marriott Bonvoy",
            maskedNumber: "739154XXX",
            points: 23_545,
            logoURL: nil,
            artURL: URL(string: "https://media.atlys.com/b2c/ai-native/cards/loyalty/_fallback.png"),
            needsAttention: true,
            holderName: "alex r.",
            expiryLabel: "Expiring in Dec 2027"
        ),
        ProfileV3LoyaltyProgramme(
            id: "krisflyer",
            name: "KrisFlyer",
            maskedNumber: "739154XXX",
            points: 23_545,
            logoURL: nil,
            holderName: "alex r.",
            expiryLabel: "Expiring in Dec 2027"
        ),
        ProfileV3LoyaltyProgramme(
            id: "maharaja",
            name: "Maharaja Club",
            maskedNumber: "739154XXX",
            points: 23_545,
            logoURL: nil,
            holderName: "raj n.",
            expiryLabel: "Expiring in Dec 2027"
        )
    ]

    static let travellers: [ProfileV3Traveller] = [
        ProfileV3Traveller(
            id: "traveller-main",
            firstName: "Alex",
            lastName: "Rivera",
            passNumber: "6190001",
            passportNumber: "Z0000001",
            isMain: true,
            dialCode: "91",
            phoneDigits: "9000000001",
            regionISO: "IN"
        ),
        ProfileV3Traveller(
            id: "traveller-co",
            firstName: "Abhishek",
            lastName: "Sharma",
            passNumber: "6190002",
            isMain: false,
            dialCode: "91",
            phoneDigits: "9000000003",
            regionISO: "IN"
        )
    ]

    static let incompleteTraveller = ProfileV3Traveller(
        id: "traveller-incomplete",
        firstName: "Sam",
        lastName: "",
        passNumber: "6190003",
        isMain: false,
        dialCode: "91",
        phoneDigits: "",
        regionISO: "IN"
    )

    static let connectors: [ProfileV3Connector] = [
        ProfileV3Connector(
            id: "gmail",
            name: "gmail",
            icon: .remote(ProfileV3ConnectorArt.gmail.url),
            status: .connected
        ),
        ProfileV3Connector(id: "itr", name: "ITR connector", icon: .contract, status: .needsAttention)
    ]

    static let kycExpired = ProfileV3KYCStatus.expired(on: "23 Dec, 2027")
    static let kycComplete = ProfileV3KYCStatus.complete(validTill: "Jan 2027")

    static let worldPass = mainPass(kyc: kycExpired)

    static let notDonePass: ProfileV3WorldPass = {
        var pass = mainPass(kyc: .notStarted)
        pass.kycLine = ProfileV3KYCLine(title: "KYC NOT DONE", subtitle: nil)
        return pass
    }()

    static func mainPass(kyc: ProfileV3KYCStatus) -> ProfileV3WorldPass {
        ProfileV3WorldPass(
            id: "main",
            holderName: "alex r.",
            memberNumber: "6190001",
            kycStatus: kyc,
            visitedCountryCodes: ["IN", "AE", "US", "GB", "FR", "IT", "TH"],
            stats: travelStats(flights: 45, distance: 294_565, countries: 20, airports: 28, airlines: 28),
            tripsEntry: .pill(
                flags: ["MU", "JP", "IN", "AE", "US"],
                more: 3,
                next: ProfileV3Directive(go: "past_trips", profileID: "main"),
                add: ProfileV3Directive(go: "add_trip", profileID: "main")
            ),
            programmes: ProfileV3ProgrammeFixtures.extraProgrammes + programmes,
            connectedProgrammeCount: 6,
            programmesUpdate: .label("14 mins ago")
        )
    }

    static func travelStats(
        flights: Int?,
        distance: Int?,
        countries: Int?,
        airports: Int?,
        airlines: Int?
    ) -> [ProfileV3TravelStat] {
        let entries: [(ProfileV3TravelStat.Key, String, Int?)] = [
            (.flights, ProfileV3Strings.flights, flights),
            (.distance, ProfileV3Strings.distance, distance),
            (.countries, ProfileV3Strings.countries, countries),
            (.airports, ProfileV3Strings.airports, airports),
            (.airlines, ProfileV3Strings.airlines, airlines)
        ]
        return entries.map { key, label, value in
            ProfileV3TravelStat(key: key, label: label, value: value, unit: key == .distance ? "km" : nil)
        }
    }

    static let coTravellerPass = ProfileV3WorldPass(
        id: "co-traveller",
        holderName: "aisha k.",
        memberNumber: "6190002",
        kycStatus: .complete(validTill: "Mar 2027"),
        visitedCountryCodes: ["IN", "SG", "JP"],
        stats: travelStats(flights: 12, distance: 88_120, countries: 6, airports: 9, airlines: 5),
        tripsEntry: .add(
            label: ProfileV3Strings.addPastTrips,
            next: ProfileV3Directive(go: "add_trip", profileID: "co-traveller")
        )
    )

    static let worldPasses = [worldPass, coTravellerPass]

    static let lockedBenefit = ProfileV3Benefit(
        id: "flights-cashback-featured",
        title: "Flat 5% back on flights",
        subtitle: "Book flights in the app and get a flat 5% back in Atlys credits.",
        imageURL: nil,
        status: .locked,
        terms: ProfileV3Strings.flightCashbackTerms
    )

    static let activeBenefit = ProfileV3Benefit(
        id: "fast-track",
        title: "Fast track immigration",
        subtitle: "Global Entry-style expedited lanes at major airports.",
        imageURL: nil,
        status: .active(validTill: "Active till Jan 2027")
    )

    static let giftCardBenefit = ProfileV3Benefit(
        id: "gift-card",
        title: "$200 gift card",
        subtitle: "Book flights in the app and get a flat 5% back in Atlys credits.",
        imageURL: nil,
        status: .partiallyRedeemed(usage: "$80 used", validTill: "Active till Jan 2027", progress: 0.4)
    )

    static let partiallyRedeemedBenefit = ProfileV3Benefit(
        id: "baggage-protection",
        title: "$500 baggage protection",
        subtitle: "",
        imageURL: nil,
        status: .partiallyRedeemed(usage: "$80 used", validTill: "Active till Jan 2027", progress: 0.36),
        terms: "Enjoy 5% off on eligible flight bookings. The offer may apply only to selected airlines, "
            + "routes, travel dates or fare types and is subject to availability. Additional terms, "
            + "exclusions and booking conditions may apply."
    )

    static let depletedBenefit = partiallyRedeemedBenefit.withStatus(
        .partiallyRedeemed(usage: "$500 used", validTill: "Active till Jan 2027", progress: 1)
    )

    static let contactDetails = ProfileV3ContactDetails(
        email: "ada@example.com",
        phoneDigits: "9000000002",
        regionISO: "IN",
        dialCode: "91"
    )

    static let coupon = ProfileV3Coupon(
        id: "baggage_protection_500",
        title: "$500 baggage protection",
        usedLabel: "$80 used",
        activeLabel: "Active till Jan 2027",
        percentRedeemed: 0.16
    )

    static let coupons: [ProfileV3Coupon] = [
        coupon,
        ProfileV3Coupon(
            id: "gift_card_200",
            title: "$200 gift card",
            usedLabel: "$80 used",
            activeLabel: "Active till Jan 2027",
            percentRedeemed: 0.4
        )
    ]

    static let couponsSheet = ProfileV3CouponsSheet(
        title: "Coupons",
        subtitle: "Your WorldPass credits and covers",
        count: 2,
        coupons: coupons
    )

    static let couponDetail = ProfileV3CouponDetail(
        id: "baggage_protection_500",
        title: "$500 baggage protection",
        totalLimit: "$500",
        amountRedeemed: "$80",
        balance: "$420",
        usedLabel: "$80 used",
        percentRedeemed: 0.16,
        activeLabel: "Active till Jan 2027",
        termsTitle: "Terms & Conditions",
        terms: "Up to $500 for qualifying lost or delayed baggage, subject to documentation and limits.",
        redeemLabel: "Redeem",
        gotItLabel: "Got it"
    )

    static let depletedCouponDetail = ProfileV3CouponDetail(
        id: "gift_card_200",
        title: "$200 gift card",
        totalLimit: "$200",
        amountRedeemed: "$200",
        balance: "$0",
        usedLabel: "$200 used",
        percentRedeemed: 1,
        activeLabel: "Active till Jan 2027",
        termsTitle: "Terms & Conditions",
        terms: "Redeemable against Atlys bookings until the validity date.",
        redeemLabel: nil,
        gotItLabel: "Got it"
    )

    static let redeemedBenefit = ProfileV3Benefit(
        id: "flight-credits",
        title: "$50 flight credits",
        subtitle: "Your Atlys fee and full government fee come back on rejection. It\u{2019}s automatic.",
        imageURL: nil,
        status: .redeemed(on: "Redeemed on 27 Jan")
    )

    static let benefits: [ProfileV3Benefit] = [
        lockedBenefit,
        giftCardBenefit,
        ProfileV3Benefit(
            id: "visas-minutes",
            title: "Visas approved in minutes",
            subtitle: "Your documents are in your vault. File in minutes, with no re-uploads.",
            imageURL: nil,
            status: .locked
        ),
        ProfileV3Benefit(
            id: "slot-priority",
            title: "Slot priority at every embassy",
            subtitle: "Get priority access to visa appointment slots across embassies.",
            imageURL: nil,
            status: .locked
        ),
        ProfileV3Benefit(
            id: "fees-refunded",
            title: "Visa fees, refunded",
            subtitle: "Your Atlys fee and full government fee come back on rejection. It\u{2019}s automatic.",
            imageURL: nil,
            status: .locked
        ),
        redeemedBenefit,
        activeBenefit,
        ProfileV3Benefit(
            id: "hotels-cashback",
            title: "Flat 10% off on hotels",
            subtitle: "Book stays in the app and get a flat 10% back in Atlys credits.",
            imageURL: nil,
            status: .locked
        )
    ]

    static let giftCards: [ProfileV3Benefit] = [
        giftCardBenefit,
        ProfileV3Benefit(
            id: "hotel-credit",
            title: "$100 hotel credit",
            subtitle: "Twice-yearly hotel credit at select hotels, on top of your flat 10%.",
            imageURL: nil,
            status: .partiallyRedeemed(usage: "$25 used", validTill: "Active till Mar 2027", progress: 0.25)
        )
    ]

    static let agents: [ProfileV3Agent] = [
        ProfileV3Agent(
            id: ProfileV3AgentID.flight.rawValue,
            name: "flight",
            summary: "Updated 2 preferences basis 2 recent trips...",
            avatarURL: nil,
            isActive: false,
            foundCount: 6,
            totalCount: 8
        ),
        ProfileV3Agent(
            id: ProfileV3AgentID.stay.rawValue,
            name: "Stay",
            summary: "Stays that match your style and benefits.",
            avatarURL: nil,
            isActive: true,
            foundCount: 3,
            totalCount: 8
        ),
        ProfileV3Agent(
            id: ProfileV3AgentID.airportLogistics.rawValue,
            name: "airport logistics",
            summary: "Every airport detail, already sorted.",
            avatarURL: nil,
            isActive: true,
            foundCount: 5,
            totalCount: 6
        ),
        ProfileV3Agent(
            id: ProfileV3AgentID.food.rawValue,
            name: "food",
            summary: "added 2 cuisines for upcoming trip",
            avatarURL: nil,
            isActive: false,
            foundCount: 2,
            totalCount: 5
        ),
        ProfileV3Agent(
            id: ProfileV3AgentID.medical.rawValue,
            name: "medical",
            summary: "Travel with important information ready.",
            avatarURL: nil,
            isActive: false,
            hasData: false,
            foundCount: 6,
            totalCount: 8
        ),
        ProfileV3Agent(
            id: ProfileV3AgentID.itinerary.rawValue,
            name: "itinerary",
            summary: "Plans built around how you travel.",
            avatarURL: nil,
            isActive: true,
            foundCount: 1,
            totalCount: 4
        ),
        ProfileV3Agent(
            id: ProfileV3AgentID.personal.rawValue,
            name: "personal",
            summary: "Less explaining, more personalised travel.",
            avatarURL: nil,
            isActive: true,
            foundCount: 4,
            totalCount: 7
        )
    ]

    static let relationshipOptions: [ProfileV3AddTravellerOption] = [
        ProfileV3AddTravellerOption(value: "spouse", title: "Spouse"),
        ProfileV3AddTravellerOption(value: "child", title: "Child", isMinor: true),
        ProfileV3AddTravellerOption(value: "parent", title: "Parent"),
        ProfileV3AddTravellerOption(value: "sibling", title: "Sibling"),
        ProfileV3AddTravellerOption(value: "friend", title: "Friend")
    ]

    static let editTravellers = ProfileV3EditTravellersScreen(
        title: ProfileV3Strings.editTravellers,
        travellers: travellers.map { traveller in
            ProfileV3TravellerRow(
                id: traveller.id,
                name: traveller.displayName,
                passNumber: traveller.passNumber,
                relationship: traveller.isMain ? nil : "sibling",
                relationshipEntry: traveller.isMain
                    ? nil
                    : ProfileV3RelationshipEntry(label: "Relationship", profileID: traveller.id),
                isMain: traveller.isMain,
                isDeletable: !traveller.isMain
            )
        },
        addLabel: ProfileV3Strings.addTraveller
    )

    static func relationshipField(profileID: String, selected: String?) -> ProfileV3EditField {
        ProfileV3EditField(
            field: ProfileV3AddTravellerField.relationshipKey,
            title: "Relationship",
            input: .singleSelect,
            submitLabel: ProfileV3Strings.confirmEdit,
            currentCode: selected,
            options: relationshipOptions.map {
                ProfileV3EditField.Option(value: $0.value, title: $0.title, isSelected: $0.value == selected)
            },
            submitProfileID: profileID
        )
    }

    static func deleteTravellerConfirm(_ profileID: String) -> ProfileV3DeleteTravellerConfirm {
        ProfileV3DeleteTravellerConfirm(
            profileID: profileID,
            name: travellers.first { $0.id == profileID }?.displayName ?? "",
            title: ProfileV3Strings.deleteTravellerTitle,
            body: "Their passport, visas and saved documents will be removed from your account.",
            proceedLabel: ProfileV3Strings.proceedToDelete,
            cancelLabel: ProfileV3Strings.dontDelete
        )
    }

    static let addTraveller = ProfileV3AddTravellerScreen(
        title: ProfileV3Strings.addTraveller,
        subtitle: "",
        fields: [
            ProfileV3AddTravellerField(key: "first_name", label: "First name", input: .text, isRequired: true),
            ProfileV3AddTravellerField(key: "last_name", label: "Last name", input: .text),
            ProfileV3AddTravellerField(key: "mobile_number", label: "Number", input: .text),
            ProfileV3AddTravellerField(key: "passport_number", label: "Passport number", input: .text),
            ProfileV3AddTravellerField(key: "citizenship", label: "Citizenship", input: .countryPicker)
        ],
        submitLabel: ProfileV3Strings.addTraveller
    )

    static let connectorControlPanel = ProfileV3ConnectorControlPanel(
        title: ProfileV3Strings.connectors,
        cards: [
            ProfileV3ConnectorCard(
                key: .gmail,
                headline: ProfileV3Strings.connectorDeckTitle("Gmail"),
                body: ProfileV3Strings.connectorDeckGmailBlurb,
                isConnected: true,
                disconnectHint: ProfileV3Strings.connectorDeckHint,
                connectLabel: nil
            ),
            ProfileV3ConnectorCard(
                key: .itr,
                headline: ProfileV3Strings.connectorDeckTitle("ITR"),
                body: ProfileV3Strings.connectorDeckITRBlurb,
                isConnected: false,
                disconnectHint: ProfileV3Strings.connectorDeckHint,
                connectLabel: ProfileV3Strings.connectOtherEmails
            )
        ]
    )

    static func disconnectConfirm(
        _ connector: ProfileV3ConnectorKey,
        isConsentRequired: Bool = true
    ) -> ProfileV3DisconnectConfirm {
        ProfileV3DisconnectConfirm(
            connector: connector,
            title: ProfileV3Strings.disconnectConfirmTitle,
            warning: ProfileV3Strings.disconnectConfirmBody,
            losses: ProfileV3Strings.disconnectLosses,
            detailIntro: ProfileV3Strings.disconnectTermsIntro,
            detailLosses: ProfileV3Strings.disconnectTermsItems,
            detailParagraphs: ProfileV3Strings.disconnectTermsClosing,
            consentLabel: ProfileV3Strings.disconnectConsent,
            isConsentRequired: isConsentRequired,
            confirmTitle: ProfileV3Strings.disconnectEmail,
            cancelTitle: ProfileV3Strings.dontDisconnect
        )
    }

    static let connectorsScreen = ProfileV3ConnectorsScreen(
        title: ProfileV3Strings.connectors,
        blurb: ProfileV3Strings.connectorsAccessNote,
        connectors: connectors,
        controlPanel: ProfileV3Directive(go: "connector_control_panel")
    )

    static func editField(_ field: String) -> ProfileV3EditField {
        switch field {
        case "contact":
            return ProfileV3EditField(
                field: field,
                title: ProfileV3Strings.contactInfo,
                input: .contactForm,
                currentContact: ProfileV3ContactDetails(
                    email: "ada@example.com",
                    phoneDigits: "9000000002",
                    regionISO: "IN",
                    dialCode: "91"
                )
            )
        case "currency":
            return ProfileV3EditField(
                field: field,
                title: ProfileV3Strings.currency,
                input: .currencyPicker,
                currentCode: ProfileV3Country.india.code
            )
        case "citizenship":
            return ProfileV3EditField(
                field: field,
                title: ProfileV3Strings.citizenship,
                input: .countryPicker,
                currentCode: ProfileV3Country.india.code
            )
        default:
            return ProfileV3EditField(
                field: field,
                title: ProfileV3Strings.countryOfResidence,
                input: .countryPicker,
                currentCode: ProfileV3Country.india.code
            )
        }
    }

    static let settingsMenu = ProfileV3SettingsMenu(
        title: ProfileV3Strings.settings,
        accountsLabel: ProfileV3Strings.accountsCenter,
        accountsSubtitle: ProfileV3Strings.accountsCenterSubtitle,
        accountsRows: [
            settingsRow("residence", ProfileV3Strings.countryOfResidence, go: "edit_field", field: "residence"),
            settingsRow("citizenship", ProfileV3Strings.citizenship, go: "edit_field", field: "citizenship"),
            settingsRow("contact", ProfileV3Strings.contactInfo, go: "edit_field", field: "contact"),
            settingsRow("currency", ProfileV3Strings.currency, go: "edit_field", field: "currency"),
            settingsRow("connectors", ProfileV3Strings.connectors, go: "connectors")
        ],
        rows: [
            settingsRow("permissions", ProfileV3Strings.permissions, go: "permissions"),
            settingsRow("edit_traveler", ProfileV3Strings.editTraveller, go: "edit_traveler"),
            settingsRow("coupons", ProfileV3Strings.coupons, go: "coupons"),
            settingsRow("loyalty_programs", ProfileV3Strings.loyaltyProgrammes, go: "loyalty_add"),
            settingsRow("terms", ProfileV3Strings.termsOfService, go: "terms"),
            settingsRow("logout", ProfileV3Strings.logout, go: "logout_confirm"),
            settingsRow("delete_account", ProfileV3Strings.deleteAccount, go: "delete_account", isDestructive: true)
        ]
    )

    private static func settingsRow(
        _ key: String,
        _ label: String,
        go: String,
        field: String? = nil,
        isDestructive: Bool = false
    ) -> ProfileV3SettingsRowItem {
        ProfileV3SettingsRowItem(
            key: key,
            label: label,
            directive: ProfileV3Directive(go: go, field: field),
            isDestructive: isDestructive
        )
    }

    static let home = ProfileV3Home(
        worldPasses: worldPasses,
        kycStatus: kycExpired,
        featuredBenefit: lockedBenefit,
        benefits: ProfileV3BenefitCatalogue.all,
        giftCards: giftCards,
        viewAllBenefitsLabel: ProfileV3Strings.viewAllBenefits(ProfileV3BenefitCatalogue.all.count),
        agents: agents,
        agentsUpdatedAt: "2:00pm, 24 Jun",
        kycProgress: ProfileV3KYCProgress(done: 4, total: 6),
        featuredCoupon: coupon,
        viewAllCouponsLabel: "View all 2 coupons"
    )

    private static let coTravellerAgentIDs: Set<ProfileV3AgentID> = [.stay, .food, .itinerary]

    static let coTravellerHome = ProfileV3Home(
        worldPasses: worldPasses,
        kycStatus: coTravellerPass.kycStatus,
        featuredBenefit: activeBenefit,
        benefits: Array(ProfileV3BenefitCatalogue.all.prefix(8)),
        giftCards: Array(giftCards.suffix(1)),
        viewAllBenefitsLabel: ProfileV3Strings.viewAllBenefits(8),
        agents: agents.filter { agent in
            guard let id = agent.agentID else { return false }
            return coTravellerAgentIDs.contains(id)
        },
        agentsUpdatedAt: "9:30am, 2 Jul"
    )

    static let homesByPass: [String: ProfileV3Home] = [
        worldPass.id: home,
        coTravellerPass.id: coTravellerHome
    ]

    static let homeKYCComplete = ProfileV3Home(
        worldPasses: [mainPass(kyc: kycComplete), coTravellerPass],
        kycStatus: kycComplete,
        featuredBenefit: lockedBenefit,
        benefits: ProfileV3BenefitCatalogue.all,
        giftCards: giftCards,
        viewAllBenefitsLabel: ProfileV3Strings.viewAllBenefits(ProfileV3BenefitCatalogue.all.count),
        agents: agents,
        agentsUpdatedAt: "2:00pm, 24 Jun"
    )

    static let kycCapture = ProfileV3KYCCapture(
        profileID: worldPass.id,
        route: .session,
        steps: [ProfileV3CaptureStepKey.gmailConnect, ProfileV3CaptureStepKey.passport, ProfileV3CaptureStepKey.selfie]
    )

    static let gmailCaptureStep = ProfileV3CaptureStep(
        id: "gmail-connect",
        type: ProfileV3CaptureStepKey.gmailConnect,
        title: "Find your trips",
        cardTitle: "Connect Gmail",
        cardSubtitle: "Read-only access to travel emails",
        lookingFor: [
            ProfileV3CaptureLookingFor(icon: nil, title: "Flight bookings", body: "Tickets and itineraries"),
            ProfileV3CaptureLookingFor(icon: nil, title: "Hotel stays", body: "Confirmations and receipts")
        ]
    )

    static let itrCaptureStep = ProfileV3CaptureStep(
        id: "itr",
        type: ProfileV3CaptureStepKey.itr,
        title: "One last step, connect your accounts",
        cardTitle: "Income Tax Return",
        cardSubtitle: "Confirms income and travel history",
        lookingFor: [
            ProfileV3CaptureLookingFor(icon: nil, title: "Filing history", body: "Assessment years on record"),
            ProfileV3CaptureLookingFor(icon: nil, title: "Declared income", body: "Used to prefill applications")
        ],
        skippable: true
    )

    static let itrCompletedCaptureStep: ProfileV3CaptureStep = {
        var step = itrCaptureStep
        step.connectorState = .completed
        step.findings = ProfileV3CaptureFindings(
            title: "WHAT I FOUND:",
            stats: [
                ProfileV3CaptureStat(label: "Assessment years", value: "3"),
                ProfileV3CaptureStat(label: "Latest filing", value: "AY 2025-26")
            ]
        )
        return step
    }()

    static let homeKYCNotDone = ProfileV3Home(
        worldPasses: [notDonePass, coTravellerPass],
        kycStatus: .notStarted,
        featuredBenefit: lockedBenefit,
        benefits: ProfileV3BenefitCatalogue.all,
        giftCards: giftCards,
        viewAllBenefitsLabel: ProfileV3Strings.viewAllBenefits(ProfileV3BenefitCatalogue.all.count),
        agents: agents,
        agentsUpdatedAt: "2:00pm, 24 Jun"
    )
}
#endif
