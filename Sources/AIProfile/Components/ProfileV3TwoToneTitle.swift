import ATUIKit
import SwiftUI

struct ProfileV3TwoToneTitle: View {
    let lead: String
    let emphasis: String
    var style: TypographyStyle = .H6InterMedium18
    var leadColor = Color(at: .neutralGrey400)

    var body: some View {
        Text("\(Text(lead).foregroundStyle(leadColor))\(Text(emphasis).foregroundStyle(Color(at: .pureBlack)))")
            .typoGraphy(style)
            .multilineTextAlignment(.center)
    }
}

#if DEBUG
#Preview("Two-tone titles") {
    VStack(spacing: ProfileV3Theme.Space.s32) {
        ProfileV3TwoToneTitle(
            lead: ProfileV3Strings.agentsHeadingLead,
            emphasis: ProfileV3Strings.agentsHeadingEmphasis
        )
        ProfileV3TwoToneTitle(lead: "Found ", emphasis: "6/8 flight preferences", style: .H5InterMedium20)
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
