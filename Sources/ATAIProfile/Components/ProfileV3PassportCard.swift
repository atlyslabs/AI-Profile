import ATUIKit
import SwiftUI

struct ProfileV3PassportCard: View {
    enum Content: Equatable {
        case upload
        case details(ProfileV3Passport)
    }

    let holderName: String
    let countryName: String
    var countryNativeName: String?
    let content: Content
    var showsStatusBadge = false
    var onUpload: (() -> Void)?

    var body: some View {
        ZStack(alignment: .topLeading) {
            glow
            countryStrip
            guilloche
            Text(holderName)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureBlack))
                .padding(.leading, ProfileV3Theme.Sizes.Passport.contentInset)
                .padding(.top, ProfileV3Theme.Sizes.Passport.nameTop)
            statusBadge
            cardContent
        }
        .frame(maxWidth: ProfileV3Theme.Sizes.Passport.cardWidth)
        .frame(height: ProfileV3Theme.Sizes.Passport.cardHeight, alignment: .top)
        .background {
            ZStack {
                ProfileV3Theme.Palette.passportCard
                ProfileV3Theme.passportHeaderShade
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.sm, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var cardContent: some View {
        switch content {
        case .upload:
            uploadPrompt
        case .details(let passport):
            VStack(alignment: .leading, spacing: 0) {
                fields(for: passport)
            }
            .opacity(passport.status == .expired ? ProfileV3Theme.Motion.passportExpiredOpacity : 1)
            .padding(.horizontal, ProfileV3Theme.Sizes.Passport.contentInset)
            .padding(.top, ProfileV3Theme.Sizes.Passport.fieldsTop)
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        if showsStatusBadge, case .details(let passport) = content {
            badge(passport.status)
                .padding(.top, ProfileV3Theme.Sizes.Passport.badgeTop)
                .padding(.trailing, ProfileV3Theme.Sizes.Passport.badgeTrailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var glow: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: glowTint, location: 0.5),
                .init(color: .clear, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: ProfileV3Theme.Sizes.Passport.glowHeight)
        .opacity(ProfileV3Theme.Motion.passportGlowOpacity)
        .padding(.top, ProfileV3Theme.Sizes.Passport.glowTop)
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }

    private var glowTint: Color {
        switch content {
        case .upload:
            return ProfileV3Theme.Palette.passportGlowUpload
        case .details(let passport):
            return passport.status == .expired
                ? ProfileV3Theme.Palette.passportGlowExpired
                : ProfileV3Theme.Palette.passportGlowActive
        }
    }

    private var countryStrip: some View {
        VStack(spacing: 0) {
            HStack(spacing: ProfileV3Theme.Sizes.Passport.stripSpacing) {
                if let countryNativeName {
                    Text(countryNativeName)
                        .typoGraphy(.H7InterMedium16)
                }
                Text(countryName)
                    .font(
                        .system(size: ProfileV3Theme.Typography.passportCountrySize, weight: .bold, design: .monospaced)
                    )
                    .tracking(ProfileV3Theme.Typography.passportCountryTracking)
            }
            .lineLimit(1)
            .minimumScaleFactor(ProfileV3Theme.Typography.passportCountryMinScale)
            .foregroundStyle(Color(at: .pureBlack))
            .opacity(ProfileV3Theme.Motion.passportStripOpacity)
            .frame(height: ProfileV3Theme.Sizes.Passport.stripHeight)
            .padding(.horizontal, ProfileV3Theme.Sizes.Passport.contentInset)
            .frame(maxWidth: .infinity)
            Rectangle()
                .fill(ProfileV3Theme.Palette.passportStripDivider)
                .frame(height: ProfileV3Theme.Stroke.hairline)
        }
        .accessibilityHidden(true)
    }

    private var guilloche: some View {
        let size = ProfileV3Theme.Sizes.Passport.guillocheSize
        let origin = ProfileV3Theme.Sizes.Passport.guillocheOrigin
        return ProfileV3RemoteImage(url: ProfileV3PlaceholderArt.passportGuilloche.url, placeholder: .clear)
            .frame(width: size, height: size)
            .opacity(ProfileV3Theme.Motion.passportGuillocheOpacity)
            .offset(x: origin.x, y: origin.y)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private var uploadPrompt: some View {
        VStack(spacing: ProfileV3Theme.Sizes.Passport.promptSpacing) {
            VStack(spacing: ProfileV3Theme.Sizes.Passport.promptTitleSpacing) {
                Text(ProfileV3Strings.uploadPassport)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(ProfileV3Theme.Palette.passportPromptTitle)
                Text(ProfileV3Strings.uploadPassportBlurb)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey400))
                    .frame(width: ProfileV3Theme.Sizes.Passport.promptWidth)
            }
            ProfileV3ContinueButton(
                title: ProfileV3Strings.upload,
                icon: ATIcon.SwiftUIImage.iOS_share,
                action: { onUpload?() }
            )
            .fixedSize()
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, ProfileV3Theme.Sizes.Passport.promptTop)
    }

    @ViewBuilder
    private func fields(for passport: ProfileV3Passport) -> some View {
        labelled(ProfileV3Strings.passportNumber, value: passport.number)
        HStack(alignment: .top, spacing: ProfileV3Theme.Sizes.Passport.dateSpacing) {
            labelled(ProfileV3Strings.passportIssueDate, value: passport.issuedOn)
            labelled(ProfileV3Strings.passportExpiryDate, value: passport.expiresOn)
        }
        .padding(.top, ProfileV3Theme.Sizes.Passport.datesTop)
    }

    private func labelled(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Passport.labelSpacing) {
            ProfileV3TagLabel(text: label)
            Text(value)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureBlack))
                .frame(maxWidth: .infinity, minHeight: ProfileV3Theme.Icon.lg, alignment: .leading)
            ProfileV3DashedDivider()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value)")
    }

    private func badge(_ status: ProfileV3Passport.Status) -> some View {
        Text(status.label)
            .typoGraphy(.T1InterBold11)
            .foregroundStyle(
                status == .active ? Color(at: .pureBlack) : ProfileV3Theme.Palette.passportBadgeExpiredText
            )
            .frame(
                width: ProfileV3Theme.Sizes.Passport.badgeWidth,
                height: ProfileV3Theme.Sizes.Passport.badgeHeight
            )
            .background(
                Capsule().fill(
                    status == .active
                        ? ProfileV3Theme.Palette.passportBadgeActive
                        : ProfileV3Theme.Palette.passportBadgeExpired
                )
            )
    }
}

#if DEBUG
#Preview("Passport card") {
    ScrollView {
        VStack(spacing: ProfileV3Theme.Space.s20) {
            ProfileV3PassportCard(
                holderName: "alex r.",
                countryName: ProfileV3Strings.passportCountryIndia,
                countryNativeName: ProfileV3Strings.passportCountryIndiaNative,
                content: .upload,
                onUpload: {}
            )
            ProfileV3PassportCard(
                holderName: "alex r.",
                countryName: ProfileV3Strings.passportCountryIndia,
                countryNativeName: ProfileV3Strings.passportCountryIndiaNative,
                content: .details(ProfileV3PassportFixtures.active)
            )
            ProfileV3PassportCard(
                holderName: "alex r.",
                countryName: ProfileV3Strings.passportCountryIndia,
                countryNativeName: ProfileV3Strings.passportCountryIndiaNative,
                content: .details(ProfileV3PassportFixtures.history[1]),
                showsStatusBadge: true
            )
        }
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
    .background(Color(at: .pureWhite))
}
#endif
