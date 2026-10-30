import ATUIKit
import SwiftUI

struct ProfileV3TwoToneTitle: View {
    let lead: String
    let emphasis: String
    var style: TypographyStyle = .H6InterMedium18
    var leadColor = Color(at: .neutralGrey400)

    var body: some View {
        title
            .typoGraphy(style)
            .multilineTextAlignment(.center)
    }

    private var title: Text {
        let emphasisText = Text(emphasis).foregroundStyle(Color(at: .pureBlack))
        guard lead.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty != nil else { return emphasisText }
        return Text("\(Text(lead).foregroundStyle(leadColor))\(emphasisText)")
    }
}

struct ProfileV3FoundHeading: View {
    let lead: String
    let emphasis: String
    let summary: String
    var summaryWidth = ProfileV3Theme.Sizes.Agent.summaryWidth

    private typealias Agent = ProfileV3Theme.Sizes.Agent

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3TwoToneTitle(lead: lead, emphasis: emphasis, style: .H5InterMedium20)
                .frame(width: Agent.titleWidth)
            if !summary.isEmpty {
                Text(summary)
                    .typoGraphy(.B2InterSemibold12)
                    .foregroundStyle(Color(at: .neutralGrey400))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: summaryWidth)
                    .padding(.top, Agent.summaryTop)
            }
        }
        .padding(.top, ProfileV3Theme.Space.s16)
    }
}

extension ProfileV3FoundHeading {
    init(label: String, summary: String, summaryWidth: CGFloat = ProfileV3Theme.Sizes.Agent.summaryWidth) {
        if let space = label.firstIndex(of: " ") {
            self.init(
                lead: String(label[...space]),
                emphasis: String(label[label.index(after: space)...]),
                summary: summary,
                summaryWidth: summaryWidth
            )
        } else {
            self.init(lead: "", emphasis: label, summary: summary, summaryWidth: summaryWidth)
        }
    }
}

#if DEBUG
#Preview("Two-tone titles") {
    VStack(spacing: ProfileV3Theme.Space.s32) {
        ProfileV3TwoToneTitle(
            lead: ProfileV3Strings.agentsHeadingLead,
            emphasis: "your travel preferences"
        )
        ProfileV3TwoToneTitle(lead: "Found ", emphasis: "6/8 flight preferences", style: .H5InterMedium20)
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
