import Foundation

#if DEBUG
enum ProfileV3ProgrammeFixtures {

    static let extraProgrammes: [ProfileV3LoyaltyProgramme] = [
        ProfileV3LoyaltyProgramme(
            id: "ihg",
            name: "IHG One Rewards",
            maskedNumber: "882031XXX",
            points: 41_200,
            logoURL: nil,
            membershipNumber: "882031457",
            holderName: "alex r.",
            expiryLabel: "No expiry",
            tier: "SILVER",
            updatedLine: "Updated last email dated 24 Jun, 2:30 pm"
        ),
        ProfileV3LoyaltyProgramme(
            id: "aeroplan",
            name: "Aeroplan",
            maskedNumber: "551209XXX",
            points: 15_000,
            logoURL: nil,
            membershipNumber: "551209836",
            holderName: "alex r.",
            expiryLabel: "Expiring in 74 days",
            updatedLine: "Updated 24 Jun, 2:30 pm"
        ),
        ProfileV3LoyaltyProgramme(
            id: "skywards",
            name: "Emirates Skywards",
            maskedNumber: "930417XXX",
            points: 68_310,
            logoURL: nil,
            membershipNumber: "930417262",
            holderName: "alex r.",
            expiryLabel: "Expiring in Mar 2028"
        )
    ]

    static let insights: [String: ProfileV3ProgrammeInsight] = [
        "ihg": ProfileV3ProgrammeInsight(
            summary: "You have 50,000 Chase points. I found a 70% transfer bonus to IHG \u{2014} "
                + "turning them into 85,000 points.",
            actionTitle: "View flights",
            detail: ProfileV3ProgrammeInsightDetail(
                body: [
                    ProfileV3TextSegment(
                        text: "You have 50,000 Chase Ultimate Rewards points. There\u{2019}s currently a "
                    ),
                    ProfileV3TextSegment(text: "70% transfer bonus to IHG One Rewards,", isEmphasised: true),
                    ProfileV3TextSegment(
                        text: " so I can turn them into 85,000 IHG points instead of the usual 50,000."
                    )
                ],
                sourceIcons: ProfileV3AgentFixtures.sources.icons,
                sourceCount: 3,
                sources: ProfileV3Directive(go: "loyalty_sources", programID: "ihg")
            )
        ),
        "aeroplan": ProfileV3ProgrammeInsight(
            summary: "Your 15,000 Aeroplan miles expire in 74 days. We found three trips in your upcoming "
                + "travel calendar where they could be used.",
            actionTitle: "View flights",
            detail: ProfileV3ProgrammeInsightDetail(
                body: [
                    ProfileV3TextSegment(text: "Your "),
                    ProfileV3TextSegment(text: "15,000 Aeroplan miles expire in 74 days.", isEmphasised: true),
                    ProfileV3TextSegment(
                        text: " Three trips in your upcoming travel calendar could use them before they lapse."
                    )
                ],
                sourceIcons: ProfileV3AgentFixtures.sources.icons,
                sourceCount: 2
            )
        )
    ]

    static let sources = ProfileV3PreferenceSources(
        title: "IHG One Rewards",
        steps: [
            ProfileV3SourceStep(
                id: 0,
                iconURL: ProfileV3AgentFixtures.gmailSourceIcon,
                title: "Connected Gmail",
                body: "Found your IHG account and a balance of 50,000 points in your inbox"
            ),
            ProfileV3SourceStep(
                id: 1,
                iconURL: nil,
                title: "Loyalty knowledge",
                body: "IHG points are worth about \u{20B9}0.42 each, so your balance is about \u{20B9}21,000"
            ),
            ProfileV3SourceStep(
                id: 2,
                iconURL: nil,
                title: "Transfer opportunity",
                body: "Chase Ultimate Rewards has a 70% transfer bonus to IHG right now"
            )
        ]
    )

    static func overview(for pass: ProfileV3WorldPass?) -> ProfileV3ProgrammeOverview {
        let programmes = (pass?.programmes ?? []).map { programme in
            var programme = programme
            programme.insight = insights[programme.id]
            return programme
        }
        return ProfileV3ProgrammeOverview(
            passID: pass?.id ?? ProfileV3Fixtures.worldPass.id,
            holderName: pass?.holderName ?? "",
            programmes: programmes,
            summary: ProfileV3Strings.programmesSummary(statements: programmes.count)
        )
    }
}
#endif
