import ATUIKit
import SwiftUI

struct ProfileV3KYCRedirectView: View {
    enum Subject {
        case agent(ProfileV3Agent)
        case benefit(ProfileV3Benefit)
    }

    let subject: Subject
    let onClose: () -> Void
    let onRedirect: () -> Void
    var status: String?

    @State private var didClose = false

    var body: some View {
        ZStack(alignment: .top) {
            overlay
            ProfileV3CloseBar {
                didClose = true
                onClose()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(ProfileV3Theme.Palette.frostedBackdrop)
                .ignoresSafeArea()
        }
        .task {
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.kycRedirectMilliseconds))
            guard !Task.isCancelled, !didClose else { return }
            onRedirect()
        }
    }

    private var overlay: some View {
        ProfileV3KYCRedirectOverlay(
            message: message,
            centreToCopy: ProfileV3Theme.Sizes.KYCRedirect.cardToCopy,
            copyToStatus: ProfileV3Theme.Sizes.KYCRedirect.copyToStatus,
            bottomSpace: ProfileV3Theme.Sizes.KYCRedirect.bottom,
            status: status ?? ""
        ) {
            subjectCard
                .allowsHitTesting(false)
        }
    }

    private var message: String {
        switch subject {
        case .agent: return ProfileV3Strings.agentKYCRequired
        case .benefit: return ProfileV3Strings.benefitKYCRequired
        }
    }

    @ViewBuilder
    private var subjectCard: some View {
        switch subject {
        case .agent(let agent):
            ProfileV3AgentGridCard(agent: agent, isKYCComplete: false) {}
                .frame(
                    width: ProfileV3Theme.Sizes.KYCRedirect.cardSize,
                    height: ProfileV3Theme.Sizes.KYCRedirect.cardSize
                )
        case .benefit(let benefit):
            ProfileV3BenefitCard(benefit: benefit)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        }
    }
}

#if DEBUG
#Preview("Agent KYC redirect") {
    ProfileV3KYCRedirectView(subject: .agent(ProfileV3Fixtures.agents[1]), onClose: {}, onRedirect: {})
}

#Preview("Benefit KYC redirect") {
    ProfileV3KYCRedirectView(subject: .benefit(ProfileV3Fixtures.lockedBenefit), onClose: {}, onRedirect: {})
}
#endif
