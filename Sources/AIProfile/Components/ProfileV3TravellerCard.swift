import ATUIKit
import SwiftUI

struct ProfileV3TravellerCard: View {
    let traveller: ProfileV3TravellerRow
    var worldPassLabel = ProfileV3Strings.worldPass
    var worldPassIconURL: URL?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(
                    cornerRadius: ProfileV3Theme.Radius.xxl,
                    style: .continuous
                )
                .fill(ProfileV3Theme.Palette.travellerCard)
                VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s20) {
                    HStack(spacing: ProfileV3Theme.Space.s8) {
                        Text(traveller.name)
                            .typoGraphy(.H7InterMedium16)
                            .foregroundStyle(Color(at: .pureWhite))
                        if let badge = traveller.badgeImageURL {
                            ProfileV3RemoteImage(url: badge, contentMode: .fit, placeholder: .clear)
                                .frame(height: ProfileV3Theme.Sizes.Accounts.badgeHeight)
                                .fixedSize(horizontal: true, vertical: false)
                                .accessibilityHidden(true)
                        }
                    }
                    VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s6) {
                        worldPassCaption
                        ProfileV3PassNumber(number: traveller.passNumber)
                    }
                }
                .padding(.leading, ProfileV3Theme.Space.s30)
                .padding(.top, ProfileV3Theme.Space.s22)
                ATIcon.SwiftUIImage.chevronRight
                    .profileV3Icon(ProfileV3Theme.Icon.lg)
                    .foregroundStyle(Color(at: .pureWhite))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .padding(.trailing, ProfileV3Theme.Space.s30)
            }
            .frame(height: ProfileV3Theme.Sizes.Traveller.cardHeight)
            .shadow(
                color: ProfileV3Theme.Palette.shadow,
                radius: ProfileV3Theme.Shadow.cardRadius,
                y: ProfileV3Theme.Shadow.cardY
            )
            .contentShape(
                RoundedRectangle(
                    cornerRadius: ProfileV3Theme.Radius.xxl,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(traveller.name)
    }

    @ViewBuilder
    private var worldPassCaption: some View {
        if let label = worldPassLabel.nonEmpty {
            HStack(spacing: ProfileV3Theme.Space.s4) {
                if let worldPassIconURL {
                    ProfileV3RemoteImage(url: worldPassIconURL, contentMode: .fit, placeholder: .clear)
                        .frame(width: ProfileV3Theme.Icon.sm, height: ProfileV3Theme.Icon.sm)
                }
                Text(label)
                    .typoGraphy(.T1InterMedium11)
                    .textCase(.uppercase)
                    .lineLimit(1)
            }
            .foregroundStyle(Color(at: .pureWhite))
            .opacity(ProfileV3Theme.Opacity.worldPassSubtitle)
            .accessibilityHidden(true)
        }
    }
}

#if DEBUG
#Preview("Traveller card") {
    VStack(spacing: ProfileV3Theme.Sizes.Traveller.cardSpacing) {
        ProfileV3TravellerCard(traveller: ProfileV3Fixtures.editTravellers.travellers[0], action: {})
        ProfileV3TravellerCard(traveller: ProfileV3Fixtures.editTravellers.travellers[1], action: {})
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
