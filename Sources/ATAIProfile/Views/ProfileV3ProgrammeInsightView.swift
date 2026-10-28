import ATUIKit
import SwiftUI

struct ProfileV3ProgrammeInsightView: View {
    let programme: ProfileV3LoyaltyProgramme
    let insight: ProfileV3ProgrammeInsight
    let onClose: () -> Void
    var onContinue: (() -> Void)?
    var onAction: (() -> Void)?
    var onOpenSources: (() -> Void)?
    var onCopyNumber: (() -> Void)?

    var body: some View {
        ZStack(alignment: .top) {
            Color(at: .pureWhite)
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ProfileV3ProgrammeTile(programme: programme, onCopy: onCopyNumber)
                        .padding(.top, ProfileV3Theme.Sizes.hubBarBottom + ProfileV3Theme.Sizes.Insight.cardTop)
                    HStack(alignment: .top, spacing: 0) {
                        bodyText
                            .frame(maxWidth: ProfileV3Theme.Sizes.Insight.bodyWidth, alignment: .leading)
                        Spacer(minLength: 0)
                        orb
                            .offset(y: ProfileV3Theme.Sizes.Insight.orbOffsetY)
                    }
                    .padding(.top, ProfileV3Theme.Space.s40)
                    ProfileV3SourcesPill(
                        icons: insight.detail.sourceIcons,
                        count: insight.detail.sourceCount,
                        action: onOpenSources
                    )
                    .padding(.top, ProfileV3Theme.Sizes.Insight.sourcesTop)
                }
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.bottom, hasActions
                    ? ProfileV3Theme.Sizes.Programmes.bottomFade
                    : ProfileV3Theme.Sizes.Programmes.barBottom)
            }
            .trackScroll(.programmeInsight, id: programme.id)
            ProfileV3CloseBar(action: onClose)
        }
        .overlay(alignment: .bottom) {
            if hasActions {
                actionBar
            }
        }
    }

    private var actionBar: some View {
        VStack(spacing: ProfileV3Theme.Sizes.insightActionSpacing) {
            if let title = secondaryActionTitle {
                ProfileV3ContinueButton(title: title, action: { onAction?() })
            }
            if let onContinue = continueAction {
                ProfileV3ContinueButton(title: insight.actionTitle, action: onContinue)
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.bottom, ProfileV3Theme.Sizes.Programmes.barBottom)
        .frame(maxWidth: .infinity)
        .frame(height: ProfileV3Theme.Sizes.Programmes.bottomFade, alignment: .bottom)
        .background(ProfileV3Theme.programmesBottomFadeGradient.ignoresSafeArea(edges: .bottom))
    }

    private var hasActions: Bool {
        continueAction != nil || secondaryActionTitle != nil
    }

    private var continueAction: (() -> Void)? {
        insight.actionTitle.isEmpty ? nil : onContinue
    }

    private var secondaryActionTitle: String? {
        guard onAction != nil else { return nil }
        return insight.action?.route().actionTitle
    }

    private var bodyText: some View {
        Text(insight.detail.body.reduce(into: AttributedString()) { text, segment in
            var run = AttributedString(segment.text)
            run.foregroundColor = segment.isEmphasised ? Color(at: .pureBlack) : Color(at: .neutralGrey800)
            text += run
        })
        .typoGraphy(.H7InterMedium16)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var orb: some View {
        ProfileV3AtlysOrb(ring: .still, metrics: .insight)
    }
}

#if DEBUG
#Preview("Programme insight") {
    let overview = ProfileV3ProgrammeFixtures.overview(for: ProfileV3Fixtures.worldPass)
    if let programme = overview.featured.first, let insight = programme.insight {
        ProfileV3ProgrammeInsightView(
            programme: programme,
            insight: insight,
            onClose: {},
            onContinue: {}
        )
    }
}

#Preview("Programme insight · with action") {
    let overview = ProfileV3ProgrammeFixtures.overview(for: ProfileV3Fixtures.worldPass)
    if let programme = overview.featured.first, let insight = programme.insight {
        ProfileV3ProgrammeInsightView(
            programme: programme,
            insight: ProfileV3ProgrammeInsight(
                summary: insight.summary,
                actionTitle: insight.actionTitle,
                detail: insight.detail,
                action: ProfileV3Directive(go: "benefits_sheet")
            ),
            onClose: {},
            onContinue: {},
            onAction: {}
        )
    }
}
#endif
