import ATUIKit
import SwiftUI

struct ProfileV3AgentGridCard: View {
    let agent: ProfileV3Agent
    var isKYCComplete = true
    let onActivate: () -> Void

    private var needsActivation: Bool { agent.activate != nil }
    private var showsActivate: Bool { !isKYCComplete || needsActivation }
    private var showsGlow: Bool { showsActivate && !agent.hasData }

    private var orbState: ProfileV3AvatarOrb.State {
        guard agent.hasData else { return .invite }
        return agent.isActive && isKYCComplete ? .active : .locked
    }

    var body: some View {
        Button(action: onActivate) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: ProfileV3Theme.Space.s8) {
                    title
                    ProfileV3AvatarOrb(
                        imageURL: agent.avatarURL
                            ?? agent.agentID.flatMap { ProfileV3PlaceholderArt.agent($0).url },
                        state: orbState
                    )
                }
                Spacer(minLength: ProfileV3Theme.Space.s8)
                Text(agent.summary)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey600).opacity(ProfileV3Theme.Opacity.cardSubtitle))
                    .lineLimit(ProfileV3Theme.Sizes.Agent.summaryLineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)
                if showsActivate {
                    Spacer()
                        .frame(height: ProfileV3Theme.Space.s18)
                    ProfileV3ActivatePill(showsBolt: true)
                }
            }
            .multilineTextAlignment(.leading)
            .padding(.top, ProfileV3Theme.Sizes.Agent.cardPaddingTop)
            .padding(.leading, ProfileV3Theme.Sizes.Agent.cardPaddingLeading)
            .padding(.trailing, ProfileV3Theme.Sizes.Agent.cardPaddingTrailing)
            .padding(.bottom, ProfileV3Theme.Sizes.Agent.cardPaddingBottom)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background {
                if showsGlow {
                    glow
                }
            }
            .profileV3Card()
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(agent.displayName)
        .accessibilityHint(agent.summary)
    }

    private var title: some View {
        ViewThatFits(in: .horizontal) {
            wrappedTitle(.H7InterMedium16)
            wrappedTitle(.B1InterMedium14)
            wrappedTitle(.B2InterMedium12)
            Text(agent.displayName)
                .typoGraphy(.B2InterMedium12)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(Color(at: .pureBlack))
    }

    private func wrappedTitle(_ style: TypographyStyle) -> some View {
        ZStack(alignment: .topLeading) {
            Text(agent.displayName.split(whereSeparator: \.isWhitespace).joined(separator: "\n"))
                .typoGraphy(style)
                .fixedSize()
                .frame(height: 0)
                .hidden()
            Text(agent.displayName)
                .typoGraphy(style)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minWidth: 0, idealWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
    }

    private var glow: some View {
        RadialGradient(
            colors: [
                ProfileV3Theme.Palette.glowPink.opacity(ProfileV3Theme.Opacity.agentGlowCore),
                ProfileV3Theme.Palette.agentGlowPeach.opacity(ProfileV3Theme.Opacity.agentGlowEdge),
                .clear
            ],
            center: ProfileV3Theme.Sizes.Agent.glowCentre,
            startRadius: 0,
            endRadius: ProfileV3Theme.Sizes.Agent.glowEndRadius
        )
    }
}

#if DEBUG
#Preview("Agent grid card") {
    HStack(spacing: ProfileV3Theme.Space.s16) {
        ProfileV3AgentGridCard(agent: ProfileV3Fixtures.agents[0]) {}
        ProfileV3AgentGridCard(agent: ProfileV3Fixtures.agents[1]) {}
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
