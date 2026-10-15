import ATUIKit
import SwiftUI

struct ProfileV3ProgrammePickerCard: View {
    let item: ProfileV3ProgrammeCatalogueItem
    let isSelected: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            artwork
            if item.cardImageURL == nil {
                Text(item.name)
                    .typoGraphy(.H7InterSemibold16)
                    .foregroundStyle(Color(at: .pureWhite))
                    .multilineTextAlignment(.leading)
                    .padding(ProfileV3Theme.Sizes.Picker.cardNamePadding)
            }
        }
        .frame(width: ProfileV3Theme.Sizes.Picker.cardWidth, height: ProfileV3Theme.Sizes.Picker.cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.lg, style: .continuous))
        .scaleEffect(isSelected ? 1 : ProfileV3Theme.Sizes.Picker.cardSideScale)
        .animation(ProfileV3Theme.Motion.selection, value: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
