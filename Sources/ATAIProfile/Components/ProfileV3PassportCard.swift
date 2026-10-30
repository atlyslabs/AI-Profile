import ATUIKit
import PostHog
import SwiftUI

struct ProfileV3PassportCard: View {
    enum Content: Equatable {
        case upload(ProfileV3PassportEmptyState)
        case details(ProfileV3Passport)
        case back(ProfileV3Passport)
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
        card
            .profileV3PassportPageEdges()
            .accessibilityElement(children: .contain)
    }

    private var card: some View {
        ZStack(alignment: .topLeading) {
            glow
            if !isBackPage {
                countryStrip
            }
            guilloche
            holder
            statusBadge
            cardContent
        }
        .frame(height: Sizes.cardHeight, alignment: .top)
        .background {
            ZStack {
                ProfileV3Theme.Palette.passportCard
                if isBackPage {
                    ProfileV3Theme.passportBackShade
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.sm, style: .continuous))
    }

    private var isBackPage: Bool {
        if case .back = content { return true }
        return false
    }

    @ViewBuilder
    private var holder: some View {
        let name = Text(holderName)
            .typoGraphy(.B1InterMedium14)
            .foregroundStyle(Color(at: .pureBlack))
        switch content {
        case .upload:
            name
                .lineLimit(1)
                .padding(.horizontal, Sizes.contentInset)
                .frame(maxWidth: .infinity)
                .padding(.top, Sizes.emptyNameTop)
        case .details:
            name
                .padding(.leading, Sizes.contentInset)
                .padding(.top, Sizes.nameTop)
        case .back:
            EmptyView()
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        switch content {
        case .upload(let emptyState):
            uploadPrompt(emptyState)
        case .details(let passport):
            VStack(alignment: .leading, spacing: 0) {
                fields(for: passport)
            }
            .opacity(passport.status == .expired ? ProfileV3Theme.Opacity.passportExpired : 1)
            .padding(.horizontal, Sizes.contentInset)
            .padding(.top, Sizes.fieldsTop)
        case .back(let passport):
            backRows(passport.back.rows(labels: labels))
                .opacity(passport.status == .expired ? ProfileV3Theme.Opacity.passportExpired : 1)
                .padding(.leading, Sizes.backLeading)
                .padding(.trailing, Sizes.backTrailing)
                .padding(.top, Sizes.backTop)
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
        .opacity(ProfileV3Theme.Opacity.passportGlow)
        .padding(.top, Sizes.glowTop)
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }

    private var glowTint: Color {
        switch content {
        case .upload:
            return ProfileV3Theme.Palette.passportGlowUpload
        case .details(let passport), .back(let passport):
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
                    .profileV3MonoLabel()
            }
            .lineLimit(1)
            .minimumScaleFactor(ProfileV3Theme.Typography.passportCountryMinScale)
            .foregroundStyle(Color(at: .pureBlack))
            .opacity(ProfileV3Theme.Opacity.passportStrip)
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
            .opacity(ProfileV3Theme.Opacity.passportGuilloche)
            .offset(x: origin.x, y: origin.y)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private func uploadPrompt(_ emptyState: ProfileV3PassportEmptyState) -> some View {
        VStack(spacing: Sizes.promptSpacing) {
            VStack(spacing: Sizes.promptTitleSpacing) {
                if !emptyState.title.isEmpty {
                    Text(emptyState.title)
                        .typoGraphy(.H7InterMedium16)
                        .foregroundStyle(ProfileV3Theme.Palette.passportPromptTitle)
                        .frame(maxWidth: Sizes.promptTitleWidth, minHeight: Sizes.promptTitleLineHeight)
                }
                if !emptyState.body.isEmpty {
                    Text(emptyState.body)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                        .frame(width: Sizes.promptWidth)
                }
            }
            if !emptyState.ctaLabel.isEmpty {
                ProfileV3ContinueButton(
                    title: emptyState.ctaLabel,
                    icon: ProfileV3Vector.iosShare.image,
                    iconSize: ProfileV3Theme.Icon.lg,
                    horizontalPadding: Sizes.promptButtonPadding,
                    action: { onUpload?() }
                )
                .fixedSize()
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, Sizes.promptTop)
    }

    @ViewBuilder
    private func fields(for passport: ProfileV3Passport) -> some View {
        labelled(labels.number, value: passport.number)
            .postHogMask()
        HStack(alignment: .top, spacing: Sizes.dateSpacing) {
            labelled(labels.issueDate, value: passport.issuedOn)
            labelled(labels.expiryDate, value: passport.expiresOn)
        }
        .padding(.top, Sizes.datesTop)
    }

    private func backRows(_ rows: [ProfileV3PassportBackRow]) -> some View {
        VStack(alignment: .leading, spacing: Sizes.backRowSpacing) {
            ForEach(rows) { row in
                VStack(alignment: .leading, spacing: Sizes.backLineSpacing) {
                    Text(row.label)
                        .font(Font.Inter.get(size: ProfileV3Theme.Typography.passportBackLabelSize, weight: .bold))
                        .tracking(ProfileV3Theme.Typography.passportBackLabelTracking)
                        .textCase(.uppercase)
                        .foregroundStyle(Color(at: .pureBlack))
                        .opacity(ProfileV3Theme.Opacity.passportBackLabel)
                        .lineLimit(1)
                        .frame(height: Sizes.backLabelHeight)
                    ForEach(Array(row.lines.enumerated()), id: \.offset) { _, line in
                        VStack(alignment: .leading, spacing: Sizes.backValueToDivider) {
                            Text(line)
                                .typoGraphy(.B2InterMedium12)
                                .foregroundStyle(Color(at: .pureBlack))
                                .lineLimit(1)
                                .minimumScaleFactor(ProfileV3Theme.Typography.passportBackValueMinScale)
                                .frame(maxWidth: .infinity, minHeight: Sizes.backValueHeight, alignment: .leading)
                            ProfileV3DashedDivider()
                        }
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(([row.label] + row.lines.filter { !$0.isEmpty }).joined(separator: ", "))
            }
        }
        .postHogMask()
    }

    private func labelled(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Sizes.labelSpacing) {
            if !label.isEmpty {
                ProfileV3TagLabel(text: label)
            }
            Text(value)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureBlack))
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
                        : ProfileV3Theme.Palette.warmGrey
                )
            )
    }
}

struct ProfileV3PassportPages: View {
    let holderName: String
    let countryName: String
    var countryNativeName: String?
    var labels: ProfileV3PassportLabels = .card
    let content: ProfileV3PassportCard.Content
    var showsStatusBadge = false
    var showsBackPage = ProfileV3FeatureFlags.isPassportBackPageEnabled
    var onUpload: (() -> Void)?

    var body: some View {
        if let backPage {
            ProfileV3PassportPagesRow {
                card(content)
            } back: {
                card(.back(backPage))
            }
        } else {
            card(content)
        }
    }

    private var backPage: ProfileV3Passport? {
        guard showsBackPage, case .details(let passport) = content, !passport.back.isEmpty,
              !passport.back.rows(labels: labels).isEmpty else { return nil }
        return passport
    }

    private func card(_ content: ProfileV3PassportCard.Content) -> ProfileV3PassportCard {
        ProfileV3PassportCard(
            holderName: holderName,
            countryName: countryName,
            countryNativeName: countryNativeName,
            labels: labels,
            content: content,
            showsStatusBadge: showsStatusBadge,
            onUpload: onUpload
        )
    }
}

struct ProfileV3PassportPagesRow<Front: View, Back: View>: View {
    @ViewBuilder let front: Front
    @ViewBuilder let back: Back

    private typealias Sizes = ProfileV3Theme.Sizes.Passport

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: Sizes.pageSpacing) {
                page(ProfileV3Strings.passportFrontPage) { front }
                page(ProfileV3Strings.passportBackPage) { back }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin, for: .scrollContent)
        .padding(.horizontal, -ProfileV3Theme.Sizes.screenHorizontalMargin)
    }

    private func page(_ label: String, @ViewBuilder card: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Sizes.pageLabelSpacing) {
            ProfileV3TagLabel(text: label)
                .opacity(ProfileV3Theme.Opacity.passportPageLabel)
                .accessibilityAddTraits(.isHeader)
            card()
        }
        .containerRelativeFrame(.horizontal) { width, _ in min(width, Sizes.cardWidth) }
    }
}

private struct ProfileV3PassportPageEdges: ViewModifier {
    private typealias Sizes = ProfileV3Theme.Sizes.Passport

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            edge(Sizes.lowerPageEdge)
            edge(Sizes.upperPageEdge)
            content
        }
        .frame(maxWidth: Sizes.cardWidth)
        .frame(height: Sizes.cardHeight + Sizes.pageEdgeDrop, alignment: .top)
    }

    private func edge(_ insets: EdgeInsets) -> some View {
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
}

private extension View {
    func profileV3PassportPageEdges() -> some View {
        modifier(ProfileV3PassportPageEdges())
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
                content: .upload(ProfileV3PassportFixtures.emptyState),
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
