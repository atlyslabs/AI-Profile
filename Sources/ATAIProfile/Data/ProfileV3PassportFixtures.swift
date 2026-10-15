import Foundation

#if DEBUG
enum ProfileV3PassportFixtures {
    static let active = ProfileV3Passport(
        id: "passport-active",
        holderName: "alex r.",
        number: "64FGGSB05",
        countryName: ProfileV3Strings.passportCountryIndia,
        countryNativeName: ProfileV3Strings.passportCountryIndiaNative,
        issuedOn: "01/01/2026",
        expiresOn: "01/01/2026",
        status: .active
    )

    static let history: [ProfileV3Passport] = [
        active,
        ProfileV3Passport(
            id: "passport-2019",
            holderName: "alex r.",
            number: "64FGGSB05",
            countryName: ProfileV3Strings.passportCountryIndia,
            countryNativeName: ProfileV3Strings.passportCountryIndiaNative,
            issuedOn: "01/01/2026",
            expiresOn: "01/01/2026",
            status: .expired
        ),
        ProfileV3Passport(
            id: "passport-2011",
            holderName: "alex r.",
            number: "64FGGSB05",
            countryName: ProfileV3Strings.passportCountryIndia,
            countryNativeName: ProfileV3Strings.passportCountryIndiaNative,
            issuedOn: "01/01/2026",
            expiresOn: "01/01/2026",
            status: .expired
        )
    ]

    static let rescan = ProfileV3Directive(go: ProfileV3PassportRoute.update)
    static let howUsedDirective = ProfileV3Directive(go: ProfileV3PassportRoute.howUsed)

    static let field = ProfileV3PassportField(
        holderName: active.holderName,
        countryName: active.countryName,
        countryNativeName: active.countryNativeName,
        passport: active,
        rescan: rescan,
        howUsed: howUsedDirective
    )

    static let scan = ProfileV3PassportScan(
        title: "Scan your passport",
        howUsed: howUsedDirective,
        front: ProfileV3PassportScanPage(title: "Front Page", subtitle: "Line up the page inside the frame"),
        back: ProfileV3PassportScanPage(title: "Back Page", subtitle: "Line up the page inside the frame"),
        next: ProfileV3Directive(go: ProfileV3PassportRoute.reason)
    )

    static let reason = ProfileV3PassportReasonScreen(
        title: "What happened to your old passport",
        subtitle: "Please specify reason for a new passport",
        howUsed: howUsedDirective,
        options: ProfileV3PassportReasonScreen.fallback.options,
        ctaTitle: "Update passport"
    )

    static let howUsed = ProfileV3PassportHowUsed(
        title: "WHERE THIS GOES TO WORK",
        steps: [
            ProfileV3PassportHowUsedStep(
                id: 0,
                icon: "grading",
                title: "Fills every form",
                body: "Your passport details pre-fill every visa application, so you never type them again."
            ),
            ProfileV3PassportHowUsedStep(
                id: 1,
                icon: "access_time",
                title: "Watches embassy slots",
                body: "We track appointment availability for the countries you plan to visit."
            ),
            ProfileV3PassportHowUsedStep(
                id: 2,
                icon: "autorenew",
                title: "Expiry & Renewal Tracking",
                body: "We remind you well before your passport needs renewing."
            )
        ],
        scanLabel: "Scan",
        scan: rescan
    )
}
#endif
