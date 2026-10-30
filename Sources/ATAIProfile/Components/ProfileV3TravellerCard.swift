import ATUIKit
import SwiftUI

struct ProfileV3TravellerCard: View {
    let traveller: ProfileV3TravellerRow
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ProfileV3TravellerCardShell(passNumber: traveller.passNumber) {
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
            } trailing: {
                ATIcon.SwiftUIImage.chevronRight
                    .profileV3Icon(ProfileV3Theme.Icon.lg)
                    .foregroundStyle(Color(at: .pureWhite))
            }
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(traveller.name)
    }
}

struct ProfileV3TravellerCardShell<Title: View, Trailing: View>: View {
    let passNumber: String
    @ViewBuilder let title: Title
    @ViewBuilder let trailing: Trailing

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.xxl, style: .continuous)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            shape
                .fill(ProfileV3Theme.Palette.travellerCard)
            VStack(alignment: .leading, spacing: 0) {
                title
                Spacer(minLength: 0)
                ProfileV3PassNumber(number: passNumber)
            }
            .padding(.leading, ProfileV3Theme.Space.s30)
            .padding(.vertical, ProfileV3Theme.Space.s22)
            trailing
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .padding(.trailing, ProfileV3Theme.Space.s30)
        }
        .frame(height: ProfileV3Theme.Sizes.Traveller.cardHeight)
        .shadow(
            color: ProfileV3Theme.Palette.shadow,
            radius: ProfileV3Theme.Shadow.cardRadius,
            y: ProfileV3Theme.Shadow.cardY
        )
        .contentShape(shape)
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
