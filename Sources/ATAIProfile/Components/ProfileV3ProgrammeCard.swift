import ATUIKit
import SwiftUI

struct ProfileV3ProgrammeCard: View {
    let programme: ProfileV3LoyaltyProgramme
    let width: CGFloat

    private typealias Layout = ProfileV3Theme.Sizes.Programme

    @State private var artAspect: CGFloat?

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.md, style: .continuous)
    }

    private var height: CGFloat {
        guard programme.artURL != nil else { return Layout.cardHeight }
        return width / (artAspect ?? Layout.artAspectRatio)
    }

    private var numberInset: CGFloat {
        programme.artURL == nil ? Layout.contentInset : width * Layout.artLogoInset
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            shape.fill(ProfileV3Theme.Palette.programmeTileBack)
                .overlay { art }
                .clipShape(shape)
            content
        }
        .frame(width: width, height: height)
        .overlay(alignment: .leading) {
            if programme.needsAttention {
                Circle()
                    .fill(ProfileV3Theme.Palette.slotDot)
                    .frame(width: ProfileV3Theme.Sizes.BackFace.slotDot, height: ProfileV3Theme.Sizes.BackFace.slotDot)
                    .offset(x: -ProfileV3Theme.Sizes.BackFace.slotDot, y: -height / 4)
            }
        }
    }

    private var content: some View {
        HStack(alignment: .top, spacing: ProfileV3Theme.Space.s8) {
            VStack(alignment: .leading, spacing: Layout.numberGap) {
                logo
                    .frame(height: Layout.logoHeight, alignment: .leading)
                Text(programme.maskedNumber)
                    .typoGraphy(.T1InterBold11)
                    .textCase(.uppercase)
                    .foregroundStyle(shade.number)
            }
            .padding(.top, Layout.logoTop)
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: Layout.pointsLabelGap) {
                Text(programme.points.formatted())
                    .typoGraphy(.H7InterSemibold16)
                    .foregroundStyle(shade.primary)
                Text(ProfileV3Strings.points)
                    .typoGraphy(.T1InterMedium11)
                    .foregroundStyle(shade.secondary)
            }
            .padding(.top, Layout.pointsTop)
        }
        .padding(.leading, numberInset)
        .padding(.trailing, Layout.contentInset)
        .shadow(
            color: programme.artURL == nil ? .clear : shade.shadow,
            radius: ProfileV3Theme.Shadow.artTextRadius,
            y: ProfileV3Theme.Shadow.artTextY
        )
    }

    private var shade: ProfileV3Theme.CardShade { .resolve(programme.textOverlay) }

    @ViewBuilder
    private var art: some View {
        if let url = programme.artURL {
            ProfileV3RemoteImage(url: url, contentMode: .fill, placeholder: .clear) { image in
                guard image.size.height > 0 else { return }
                artAspect = image.size.width / image.size.height
            }
        }
    }

    @ViewBuilder
    private var logo: some View {
        if programme.artURL != nil {
            Color.clear
        } else if let url = programme.logoURL {
            ProfileV3RemoteImage(url: url, contentMode: .fit, placeholder: .clear)
                .frame(maxWidth: Layout.logoMaxWidth, alignment: .leading)
        } else {
            Text(programme.name)
                .typoGraphy(.B2InterSemibold12)
                .foregroundStyle(Color(at: .pureWhite))
                .lineLimit(1)
        }
    }
}

#if DEBUG
#Preview("Programme cards") {
    VStack(spacing: ProfileV3Theme.Space.s16) {
        ForEach(ProfileV3Fixtures.programmes) { programme in
            ProfileV3ProgrammeCard(programme: programme, width: 225)
        }
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
