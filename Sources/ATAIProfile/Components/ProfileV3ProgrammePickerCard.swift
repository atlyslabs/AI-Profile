import ATUIKit
import SwiftUI

struct ProfileV3ProgrammePickerCard: View {
    let item: ProfileV3ProgrammeCatalogueItem
    let isSelected: Bool

    private typealias Picker = ProfileV3Theme.Sizes.Picker

    var body: some View {
        VStack(spacing: Picker.nameTop) {
            card
            Text(item.name)
                .typoGraphy(isSelected ? .B1InterSemibold14 : .B2InterSemibold12)
                .foregroundStyle(Color(at: .pureBlack).opacity(isSelected ? 1 : Picker.sideNameOpacity))
                .multilineTextAlignment(.center)
                .lineLimit(Picker.nameLines)
                .frame(width: Picker.nameWidth)
                .offset(y: isSelected ? 0 : -Picker.sideNameLift)
        }
        .frame(height: Picker.carouselHeight, alignment: .top)
        .animation(ProfileV3Theme.Motion.selection, value: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var card: some View {
        ZStack(alignment: .bottomLeading) {
            artwork
            if item.cardImageURL == nil || item.isArtPlaceholder {
                Text(item.name)
                    .typoGraphy(.H7InterSemibold16)
                    .foregroundStyle(nameColor)
                    .multilineTextAlignment(.leading)
                    .padding(Picker.cardNamePadding)
            }
        }
        .frame(width: Picker.cardWidth, height: Picker.cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.lg, style: .continuous))
        .scaleEffect(isSelected ? 1 : Picker.cardSideScale)
    }

    private var nameColor: Color {
        guard item.cardImageURL != nil else { return Color(at: .pureWhite) }
        return ProfileV3Theme.CardShade.resolve(item.textOverlay).primary
    }

    @ViewBuilder
    private var artwork: some View {
        if let url = item.cardImageURL {
            ProfileV3RemoteImage(
                url: url,
                contentMode: .fill,
                placeholder: ProfileV3Theme.Palette.programmeTileBack,
                rotatesLandscapeToPortrait: true
            )
        } else {
            ProfileV3Theme.Palette.programmeTileBack
        }
    }
}

#if DEBUG
#Preview("Programme picker cards") {
    HStack(spacing: ProfileV3Theme.Sizes.Picker.cardSpacing) {
        ProfileV3ProgrammePickerCard(item: ProfileV3ProgrammeCatalogue.all[0], isSelected: true)
        ProfileV3ProgrammePickerCard(item: ProfileV3ProgrammeCatalogue.all[2], isSelected: false)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
