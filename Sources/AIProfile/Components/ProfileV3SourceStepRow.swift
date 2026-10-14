import ATUIKit
import SwiftUI

struct ProfileV3SourceStepRow: View {
    let step: ProfileV3SourceStep

    private typealias Sources = ProfileV3Theme.Sizes.Sources

    var body: some View {
        HStack(alignment: .top, spacing: Sources.tileSpacing) {
            ProfileV3RemoteImage(url: step.iconURL, contentMode: .fit, placeholder: .clear)
                .frame(width: Sources.connectorGlyph, height: Sources.connectorGlyph)
                .frame(width: Sources.tile, height: Sources.tile)
                .background(Circle().fill(ProfileV3Theme.Palette.sourceTile))
            VStack(alignment: .leading, spacing: Sources.textSpacing) {
                Text(step.title)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(ProfileV3Theme.tagGradient)
                if !step.body.isEmpty {
                    Text(step.body)
                        .font(Font.Inter.get(size: ProfileV3Theme.Typography.sourceStepDetailSize, weight: .regular))
                        .lineSpacing(Sources.detailLineSpacing)
                        .foregroundStyle(Color(at: .neutralGrey600))
                }
                if step.viewsEmails {
                    HStack(spacing: Sources.evidenceSpacing) {
                        ATIcon.SwiftUIImage.mail.profileV3Icon(Sources.evidenceIcon)
                        ATIcon.SwiftUIImage.removeRedEye.profileV3Icon(Sources.evidenceIcon)
                    }
                    .foregroundStyle(Color(at: .neutralGrey900))
                    .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: Sources.textColumnWidth, alignment: .leading)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Source steps") {
    VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s24) {
        ForEach(ProfileV3AgentFixtures.airlineSources.steps) { ProfileV3SourceStepRow(step: $0) }
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
