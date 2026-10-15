import ATUIKit
import SwiftUI

struct ProfileV3TravellerCardLip: View {
    var body: some View {
        RoundedRectangle(cornerRadius: ProfileV3Theme.Sizes.Traveller.cardLipHeight, style: .continuous)
            .fill(ProfileV3Theme.Palette.travellerCardLip)
            .frame(
                width: ProfileV3Theme.Sizes.Traveller.cardLipWidth,
                height: ProfileV3Theme.Sizes.Traveller.cardLipHeight
            )
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Traveller card lip") {
    ProfileV3TravellerCardLip()
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}
#endif
