import ATUIKit
import PostHog
import SwiftUI

struct ProfileV3PassportCard: View {
    enum Content: Equatable {
        case upload
        case details(ProfileV3Passport)
    }

    let holderName: String
    let countryName: String
    var countryNativeName: String?
    var labels: ProfileV3PassportLabels = .card
    let content: Content
    var showsStatusBadge = false
    var onUpload: (() -> Void)?

    private typealias Sizes = ProfileV3Theme.Sizes.Passport

    var body: some View {
        ZStack(alignment: .top) {
            pageEdge(Sizes.lowerPageEdge)
            pageEdge(Sizes.upperPageEdge)
            card
        }
        .frame(maxWidth: Sizes.cardWidth)
        .frame(height: Sizes.cardHeight + Sizes.pageEdgeDrop, alignment: .top)
        .accessibilityElement(children: .contain)
    }

    private var card: some View {
        ZStack(alignment: .topLeading) {
            glow
            countryStrip
            guilloche
            Text(holderName)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureBlack))
                .padding(.leading, Sizes.contentInset)
                .padding(.top, Sizes.nameTop)
            statusBadge
            cardContent
        }
        .frame(height: Sizes.cardHeight, alignment: .top)
        .background(ProfileV3Theme.Palette.passportCard)
        .clipShape(RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.sm, style: .continuous))
    }

    private func pageEdge(_ insets: EdgeInsets) -> some View {
        let shape = UnevenRoundedRectangle(
            bottomLeadingRadius: Sizes.pageEdgeHeight,
            bottomTrailingRadius: Sizes.pageEdgeHeight
        )
        return shape
            .fill(Color(at: .pureWhite))
            .overlay(shape.fill(ProfileV3Theme.passportPageEdgeShade))
            .frame(height: Sizes.pageEdgeHeight)
            .padding(insets)
            .accessibilityHidden(true)
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
            .padding(.horizontal, Sizes.contentInset)
            .padding(.top, Sizes.fieldsTop)
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        if showsStatusBadge, case .details(let passport) = content {
            badge(passport.status)
                .padding(.top, Sizes.badgeTop)
                .padding(.trailing, Sizes.badgeTrailing)
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
        .frame(height: Sizes.glowHeight)
        .opacity(ProfileV3Theme.Motion.passportGlowOpacity)
        .padding(.top, Sizes.glowTop)
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
            HStack(spacing: Sizes.stripSpacing) {
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
            .frame(height: Sizes.stripHeight)
            .padding(.horizontal, Sizes.contentInset)
            .frame(maxWidth: .infinity)
            Rectangle()
                .fill(ProfileV3Theme.Palette.passportStripDivider)
                .frame(height: ProfileV3Theme.Stroke.hairline)
        }
        .accessibilityHidden(true)
    }

    private var guilloche: some View {
        let size = Sizes.guillocheSize
        let origin = Sizes.guillocheOrigin
        return ProfileV3RemoteImage(url: ProfileV3PlaceholderArt.passportGuilloche.url, placeholder: .clear)
            .frame(width: size, height: size)
            .opacity(ProfileV3Theme.Motion.passportGuillocheOpacity)
            .offset(x: origin.x, y: origin.y)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private var uploadPrompt: some View {
        VStack(spacing: Sizes.promptSpacing) {
            VStack(spacing: Sizes.promptTitleSpacing) {
                Text(ProfileV3Strings.uploadPassport)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(ProfileV3Theme.Palette.passportPromptTitle)
                Text(ProfileV3Strings.uploadPassportBlurb)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey400))
                    .frame(width: Sizes.promptWidth)
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
        .padding(.top, Sizes.promptTop)
    }

    @ViewBuilder
    private func fields(for passport: ProfileV3Passport) -> some View {
        labelled(labels.number, value: passport.number)
            .postHogMask()
        HStack(alignment: .top, spacing: Sizes.dateSpacing) {
            labelled(labels.issueDate, value: passport.issuedOn, showsCalendar: passport.status == .active)
            labelled(labels.expiryDate, value: passport.expiresOn, showsCalendar: passport.status == .active)
        }
        .padding(.top, Sizes.datesTop)
    }

    private func labelled(_ label: String, value: String, showsCalendar: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: Sizes.labelSpacing) {
            if !label.isEmpty {
                ProfileV3TagLabel(text: label)
            }
            HStack(spacing: ProfileV3Theme.Space.s8) {
                Text(value)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(Color(at: .pureBlack))
                Spacer(minLength: 0)
                if showsCalendar {
                    ATIcon.SwiftUIImage.calendarToday
                        .profileV3Icon(ProfileV3Theme.Icon.md)
                        .foregroundStyle(Color(at: .neutralGrey800))
                }
            }
            .frame(maxWidth: .infinity, minHeight: ProfileV3Theme.Icon.lg, alignment: .leading)
            ProfileV3DashedDivider()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label.isEmpty ? value : "\(label), \(value)")
    }

    private func badge(_ status: ProfileV3Passport.Status) -> some View {
        Text(status.label)
            .typoGraphy(.T1InterBold11)
            .foregroundStyle(
                status == .active ? Color(at: .pureBlack) : ProfileV3Theme.Palette.passportBadgeExpiredText
            )
            .frame(
                width: Sizes.badgeWidth,
                height: Sizes.badgeHeight
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
