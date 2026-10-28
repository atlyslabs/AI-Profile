import ATUIKit
import SwiftUI

struct ProfileV3AgentsHeader: View {
    let updatedAt: String
    var heading: String?
    var headingEmphasis: String?

    var body: some View {
        VStack(spacing: ProfileV3Theme.Space.s24) {
            ProfileV3TwoToneTitle(lead: lead, emphasis: emphasis)
                .frame(maxWidth: ProfileV3Theme.Sizes.agentsHeadingMaxWidth)
            if !updatedAt.isEmpty {
                Text(ProfileV3Strings.updatedOn(updatedAt))
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey400))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var lead: String {
        guard let heading = heading?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty else { return "" }
        return heading.hasSuffix(" ") ? heading : heading + " "
    }

    private var emphasis: String {
        headingEmphasis ?? ""
    }
}

struct ProfileV3AgentGrid: View {
    let agents: [ProfileV3Agent]
    var isKYCComplete = true
    let onActivate: (ProfileV3Agent) -> Void

    private static let columns = [
        GridItem(.flexible(), spacing: ProfileV3Theme.Space.s16),
        GridItem(.flexible(), spacing: ProfileV3Theme.Space.s16)
    ]

    var body: some View {
        LazyVGrid(columns: Self.columns, spacing: ProfileV3Theme.Space.s18) {
            ForEach(agents.indexed) { row in
                let agent = row.element
                ProfileV3AgentGridCard(agent: agent, isKYCComplete: isKYCComplete) {
                    onActivate(agent)
                }
                .trackSection(.agentTile, id: agent.id, at: row.index + 1)
            }
        }
    }
}

#if DEBUG
#Preview("Agents section") {
    ScrollView {
        VStack(spacing: ProfileV3Theme.Space.s32) {
            ProfileV3AgentsHeader(updatedAt: ProfileV3Fixtures.home.agentsUpdatedAt)
            ProfileV3AgentGrid(agents: ProfileV3Fixtures.agents) { _ in }
        }
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
    .background(Color(at: .pureWhite))
}
#endif
