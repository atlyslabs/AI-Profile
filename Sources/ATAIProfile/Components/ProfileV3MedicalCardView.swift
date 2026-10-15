import ATUIKit
import SwiftUI

struct ProfileV3MedicalCardView: View {
    let card: ProfileV3MedicalCard
    @Binding var showsOnLockScreen: Bool

    private typealias Metrics = ProfileV3Theme.Sizes.MedicalCard

    private var rows: [(String, String)] {
        [
            (ProfileV3Strings.dateOfBirth, card.dateOfBirth),
            (ProfileV3Strings.bloodGroup, card.bloodGroup),
            (ProfileV3Strings.emergencyContact, card.emergencyContact),
            (ProfileV3Strings.organDonor, card.organDonor)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s20) {
            HStack(spacing: Metrics.flagSpacing) {
                Text(card.holderName)
                    .typoGraphy(.H6InterMedium18)
                    .foregroundStyle(Color(at: .pureWhite))
                    .fixedSize(horizontal: false, vertical: true)
                if let country = ATCountry(isoCode: card.countryCode) {
                    ATCountryFlagView(country: country)
                        .frame(width: Metrics.flag, height: Metrics.flag)
                        .clipShape(Circle())
                }
            }
            VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s16) {
                ForEach(rows, id: \.0) { row in
                    HStack(alignment: .firstTextBaseline, spacing: ProfileV3Theme.Space.s12) {
                        Text(row.0)
                            .foregroundStyle(ProfileV3Theme.Palette.medicalCardLabel)
                            .frame(minWidth: labelWidth, alignment: .leading)
                        Text(row.1.isEmpty ? ProfileV3Strings.medicalEmptyValue : row.1)
                            .foregroundStyle(Color(at: .pureWhite))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .typoGraphy(.T1InterBold11)
                    .textCase(.uppercase)
                }
            }
            if card.rendersLockToggle {
                Capsule()
                    .fill(ProfileV3Theme.Palette.medicalCardDivider)
                    .frame(height: ProfileV3Theme.Stroke.hairline)
                ProfileV3ToggleRow(
                    title: card.lockToggleTitle ?? ProfileV3Strings.openMedicalCardWhenLocked,
                    isOn: $showsOnLockScreen,
                    titleColor: ProfileV3Theme.Palette.medicalCardCaption,
                    tint: ProfileV3Theme.Palette.medicalCardDivider
                )
            }
        }
        .padding(Metrics.padding)
        .frame(
            maxWidth: .infinity,
            minHeight: card.rendersLockToggle ? Metrics.height : Metrics.compactHeight,
            alignment: .topLeading
        )
        .background { decoration }
        .clipShape(shape)
    }

    private var decoration: some View {
        shape.fill(ProfileV3Theme.Palette.medicalCard)
            .overlay(alignment: .topTrailing) {
                ProfileV3RemoteImage(url: ProfileV3AgentArt.caduceus.url, contentMode: .fit, placeholder: .clear)
                    .frame(width: Metrics.emblem, height: Metrics.emblem)
                    .offset(x: Metrics.emblemBleed)
                    .padding(.top, Metrics.emblemTop)
            }
            .overlay(alignment: .topTrailing) {
                LinearGradient(
                    colors: [ProfileV3Theme.Palette.medicalCard.opacity(0), ProfileV3Theme.Palette.medicalCard],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: Metrics.emblemFadeWidth, height: Metrics.emblemFadeHeight)
                .padding(.top, Metrics.emblemFadeTop)
            }
            .overlay(alignment: .topLeading) {
                Rectangle()
                    .fill(Color(at: .pureWhite))
                    .frame(width: Metrics.sheenWidth, height: Metrics.sheenHeight)
                    .blur(radius: Metrics.sheenBlur)
                    .opacity(ProfileV3Theme.Opacity.medicalSheen)
                    .rotationEffect(.degrees(Metrics.sheenAngle))
                    .offset(
                        x: Metrics.sheenCentre.x - Metrics.sheenWidth / 2,
                        y: Metrics.sheenCentre.y - Metrics.sheenHeight / 2
                    )
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private var labelWidth: CGFloat {
        Metrics.valueLeading - Metrics.padding - ProfileV3Theme.Space.s12
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.xxl, style: .continuous)
    }
}

#if DEBUG
#Preview("Medical card") {
    ProfileV3MedicalCardPreview()
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}

private struct ProfileV3MedicalCardPreview: View {
    @State private var showsOnLockScreen = true

    var body: some View {
        ProfileV3MedicalCardView(
            card: ProfileV3AgentFixtures.medical.medicalCard!,
            showsOnLockScreen: $showsOnLockScreen
        )
    }
}
#endif
