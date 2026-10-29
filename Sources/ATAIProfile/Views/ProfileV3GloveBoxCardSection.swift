import ATUIKit
import PostHog
import SwiftUI

struct ProfileV3GloveBoxCardSectionView: View {
    let section: ProfileV3GloveBoxCardSection
    let showsNotice: Bool
    let onTapCard: () -> Void
    let onCloseNotice: () -> Void
    let onSelectOption: (String) -> Void
    let onAddCard: () -> Void
    let onOpen: (ProfileV3GloveBoxTransaction) -> Void
    let onViewAll: () -> Void
    var showsTransactions = ProfileV3FeatureFlags.isGloveBoxCardTransactionsEnabled

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        ProfileV3GloveBoxSectionCard(
            icon: ATIcon.SwiftUIImage.creditCard,
            title: section.title,
            badge: section.badge,
            viewAllTitle: showsTransactions && !section.transactions.isEmpty ? section.viewAllTitle : nil,
            onViewAll: onViewAll
        ) {
            Button(action: onTapCard) {
                ProfileV3GloveBoxVirtualCard(card: section.card)
            }
            .buttonStyle(.profileV3Pressable(.selection))
            .padding(.top, Layout.cardTop)
            if !section.stats.isEmpty {
                stats
                    .padding(.top, Layout.statsTop)
            }
            if !section.facts.isEmpty {
                facts
                    .padding(.top, Layout.factsTop)
            }
            if !section.payOptions.isEmpty {
                ProfileV3DashedDivider()
                    .padding(.top, Layout.payDividerTop)
                if !section.payTitle.isEmpty {
                    Text(section.payTitle)
                        .typoGraphy(.T1InterBold11)
                        .textCase(.uppercase)
                        .foregroundStyle(Color(at: .pureBlack).opacity(Palette.sectionTitleOpacity))
                        .accessibilityAddTraits(.isHeader)
                        .padding(.top, Layout.payTitleTop)
                }
                if !section.payBody.isEmpty {
                    Text(section.payBody)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(Color(at: .pureBlack).opacity(Palette.aboutOpacity))
                        .frame(maxWidth: Layout.payBodyWidth, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Layout.payBodyTop)
                }
                VStack(spacing: Layout.optionSpacing) {
                    ForEach(section.payOptions) { option in
                        payOption(option)
                    }
                }
                .padding(.top, Layout.optionsTop)
            }
            if showsTransactions {
                ProfileV3DashedDivider()
                    .padding(.top, section.payOptions.isEmpty ? Layout.payDividerTop : Layout.transactionsDividerTop)
                transactions
                    .padding(.top, Layout.transactionsTop)
            }
        }
        .overlay(alignment: .top) {
            if showsNotice, !section.protectedNotice.isEmpty {
                notice
                    .padding(.top, Layout.noticeTop)
                    .padding(.horizontal, Layout.noticeInset)
                    .transition(.opacity)
            }
        }
    }

    private var stats: some View {
        HStack(spacing: Layout.statSpacing) {
            ForEach(section.stats) { stat in
                VStack(alignment: .leading, spacing: Layout.statTextSpacing) {
                    Text(stat.value)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(Color(at: .pureBlack))
                    Text(stat.label)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .pureBlack).opacity(Palette.summaryOpacity))
                }
                .padding(Layout.statPadding)
                .frame(maxWidth: .infinity, minHeight: Layout.statHeight, alignment: .topLeading)
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.statRadius, style: .continuous)
                        .strokeBorder(Palette.sectionBorder, lineWidth: ProfileV3Theme.Stroke.hairline)
                )
                .accessibilityElement(children: .combine)
            }
        }
    }

    private var facts: some View {
        VStack(spacing: Layout.factSpacing) {
            ForEach(section.facts) { fact in
                HStack(alignment: .firstTextBaseline, spacing: ProfileV3Theme.Space.s16) {
                    Text(fact.label)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(Color(at: .pureBlack).opacity(Palette.factOpacity))
                    Spacer(minLength: 0)
                    Text(fact.value)
                        .typoGraphy(.B1InterSemibold14)
                        .foregroundStyle(Color(at: .pureBlack))
                        .multilineTextAlignment(.trailing)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func payOption(_ option: ProfileV3GloveBoxCardSection.PayOption) -> some View {
        let isSelected = option.id == section.selectedPayOptionID
        return VStack(alignment: .leading, spacing: 0) {
            Button {
                onSelectOption(option.id)
            } label: {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: Layout.optionTextSpacing) {
                        Text(option.title)
                            .typoGraphy(.B1InterSemibold14)
                            .foregroundStyle(Color(at: .pureBlack))
                        Text(option.body)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(Color(at: .pureBlack).opacity(Palette.summaryOpacity))
                            .frame(maxWidth: Layout.optionBodyWidth, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    ProfileV3RadioMark(isSelected: isSelected, size: Layout.radio, tint: Palette.control)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.profileV3Pressable(.selection))
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            if option.kind == .link {
                if let linkedCard = section.linkedCard {
                    linked(linkedCard)
                        .padding(.top, Layout.chipTop)
                } else {
                    addCard
                        .padding(.top, Layout.addCardTop)
                    if !section.secureNote.isEmpty {
                        Text(section.secureNote)
                            .typoGraphy(.T1InterMedium11)
                            .foregroundStyle(ProfileV3Theme.GloveBox.secureNoteGradient)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: Layout.secureNoteWidth)
                            .frame(maxWidth: .infinity)
                            .padding(.top, Layout.secureNoteTop)
                    }
                }
            }
        }
        .padding(Layout.optionPadding)
        .overlay(
            RoundedRectangle(cornerRadius: Layout.optionRadius, style: .continuous)
                .strokeBorder(Palette.sectionBorder, lineWidth: ProfileV3Theme.Stroke.hairline)
        )
    }

    private func linked(_ card: ProfileV3GloveBoxCardSection.LinkedCard) -> some View {
        VStack(alignment: .leading, spacing: Layout.addButtonTop) {
            HStack(spacing: Layout.chipSpacing) {
                Group {
                    if card.logoURL != nil {
                        ProfileV3GloveBoxLogo(url: card.logoURL, size: Layout.chipLogo)
                    } else {
                        ATIcon.SwiftUIImage.creditCard
                            .profileV3Icon(Layout.chipLogo)
                            .foregroundStyle(Palette.dialIcon)
                    }
                }
                .accessibilityHidden(true)
                Text(card.label)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(Palette.chipText)
                    .lineLimit(1)
            }
            .padding(.leading, Layout.chipLeading)
            .padding(.trailing, Layout.chipTrailing)
            .frame(height: Layout.chipHeight)
            .background(Capsule().fill(Color(at: .pureWhite)))
            .overlay(Capsule().strokeBorder(Palette.sectionBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
            .padding(.leading, Layout.chipInset)
            HStack {
                Spacer(minLength: 0)
                Button(action: onAddCard) {
                    ATIcon.SwiftUIImage.add
                        .profileV3Icon(Layout.addIcon)
                        .foregroundStyle(Color(at: .pureWhite))
                        .frame(width: Layout.addButton, height: Layout.addButton)
                        .background(Circle().fill(Color(at: .pureBlack)))
                        .contentShape(Circle())
                }
                .buttonStyle(.profileV3Pressable(.impact(weight: .medium)))
                .accessibilityLabel(section.addCardTitle)
            }
        }
    }

    private var addCard: some View {
        Button(action: onAddCard) {
            Text(section.addCardTitle)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .pureWhite))
                .frame(maxWidth: .infinity)
                .frame(height: Layout.addCardHeight)
                .background {
                    Color(at: .pureBlack)
                        .overlay(alignment: .top) {
                            ProfileV3GloveBoxArt.addCardGlow.image
                                .resizable()
                                .frame(width: Layout.addCardGlow.width, height: Layout.addCardGlow.height)
                                .opacity(Palette.addCardGlowOpacity)
                                .blur(radius: Layout.addCardGlowBlur)
                                .offset(x: Layout.addCardGlowOffset.width, y: Layout.addCardGlowOffset.height)
                                .accessibilityHidden(true)
                        }
                        .clipShape(Capsule())
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.profileV3Pressable(.impact(weight: .medium)))
        .accessibilityLabel(section.addCardTitle)
    }

    @ViewBuilder
    private var transactions: some View {
        let rows = Array(section.transactions.prefix(Layout.transactionPreviewLimit))
        if rows.isEmpty {
            ProfileV3GloveBoxPreviewCard(padding: EdgeInsets()) {
                empty
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: Layout.emptyHeight)
            }
        } else {
            ProfileV3GloveBoxPreviewCard(sampleLabel: section.sampleLabel, padding: transactionsPadding) {
                VStack(spacing: Layout.rowSpacing) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, transaction in
                        if index > 0 {
                            ProfileV3GloveBoxRowDivider()
                        }
                        ProfileV3GloveBoxTransactionRow(transaction: transaction) { onOpen(transaction) }
                    }
                }
            }
        }
    }

    private var transactionsPadding: EdgeInsets {
        var padding = Layout.transactionsPadding
        if section.sampleLabel != nil { padding.top += Layout.sampleClearance }
        return padding
    }

    private var empty: some View {
        VStack(spacing: Layout.emptySpacing) {
            ProfileV3GloveBoxArt.emptyCard.image
                .resizable()
                .frame(width: Layout.emptyIcon.width, height: Layout.emptyIcon.height)
                .grayscale(1)
                .opacity(Palette.emptyIconOpacity)
                .accessibilityHidden(true)
            VStack(spacing: Layout.emptyTextSpacing) {
                if !section.emptyTitle.isEmpty {
                    Text(section.emptyTitle)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(Color(at: .pureBlack).opacity(Palette.emptyTitleOpacity))
                }
                if !section.emptyBody.isEmpty {
                    Text(section.emptyBody)
                        .typoGraphy(.T1InterMedium11)
                        .foregroundStyle(ProfileV3Theme.GloveBox.emptyBodyGradient)
                        .opacity(Palette.emptyBodyOpacity)
                        .frame(maxWidth: Layout.emptyBodyWidth)
                }
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, ProfileV3Theme.Space.s16)
        .accessibilityElement(children: .combine)
    }

    private var notice: some View {
        let shape = RoundedRectangle(cornerRadius: Layout.noticeRadius, style: .continuous)
        return HStack(spacing: ProfileV3Theme.Space.s8) {
            Text(section.protectedNotice)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Palette.noticeText)
                .lineLimit(1)
            Spacer(minLength: 0)
            Button(action: onCloseNotice) {
                ProfileV3GloveBoxArt.closeSmall.image
                    .profileV3Icon(Layout.noticeClose)
                    .foregroundStyle(Palette.noticeText)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.profileV3Pressable(.selection))
            .accessibilityLabel(ProfileV3Strings.close)
        }
        .padding(.leading, Layout.noticeLeading)
        .padding(.trailing, Layout.noticeTrailing)
        .frame(height: Layout.noticeHeight)
        .frame(maxWidth: .infinity)
        .background {
            Palette.notice
                .overlay(alignment: .top) {
                    ProfileV3GloveBoxArt.noticeGlow.image
                        .resizable()
                        .frame(width: Layout.noticeGlow.width, height: Layout.noticeGlow.height)
                        .blur(radius: Layout.noticeGlowBlur)
                        .offset(x: Layout.noticeGlowOffset.width, y: Layout.noticeGlowOffset.height)
                        .accessibilityHidden(true)
                }
                .clipShape(shape)
        }
    }
}

struct ProfileV3GloveBoxVirtualCard: View {
    let card: ProfileV3GloveBoxCardSection.Card

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        GeometryReader { proxy in
            art
                .scaleEffect(proxy.size.width / Layout.cardSize.width, anchor: .topLeading)
        }
        .aspectRatio(Layout.cardSize.width / Layout.cardSize.height, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(card.holder)
        .accessibilityValue(card.lastFour)
        .postHogMask()
    }

    private var art: some View {
        ZStack(alignment: .topLeading) {
            Palette.card
            Rectangle()
                .fill(ProfileV3Theme.GloveBox.cardWash)
                .frame(width: Layout.cardWash.width, height: Layout.cardWash.height)
                .offset(x: Layout.cardWash.minX, y: Layout.cardWash.minY)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Palette.cardLight, Palette.cardLight.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: Layout.cardLightRadius
                    )
                )
                .frame(width: Layout.cardLightRadius * 2, height: Layout.cardLightRadius * 2)
                .opacity(Palette.cardLightOpacity)
                .blur(radius: Layout.cardBlobBlur)
                .position(Layout.cardLightCentre)
            Ellipse()
                .fill(EllipticalGradient(colors: [Palette.cardShade, Palette.cardShade.opacity(0)]))
                .frame(width: Layout.cardShadeSize.width, height: Layout.cardShadeSize.height)
                .rotationEffect(Layout.cardShadeAngle)
                .blur(radius: Layout.cardBlobBlur)
                .position(Layout.cardShadeCentre)
            ProfileV3GloveBoxArt.cardGlobe.image
                .resizable()
                .frame(width: Layout.cardGlobeSize, height: Layout.cardGlobeSize)
                .scaleEffect(x: -1, y: 1)
                .opacity(Palette.cardGlobeOpacity)
                .position(Layout.cardGlobeCentre)
            ProfileV3GloveBoxArt.aylMark.image
                .resizable()
                .foregroundStyle(Color(at: .pureWhite))
                .frame(width: Layout.cardMark.width, height: Layout.cardMark.height)
                .offset(x: Layout.cardMark.minX, y: Layout.cardMark.minY)
            HStack(spacing: Layout.cardNumberGap) {
                HStack(spacing: Layout.cardGroupSpacing) {
                    ForEach(0..<Layout.cardMaskedGroups, id: \.self) { _ in
                        ProfileV3GloveBoxArt.cardDigits.image
                            .resizable()
                            .frame(width: Layout.cardDigits.width, height: Layout.cardDigits.height)
                    }
                }
                Text(card.lastFour)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(Color(at: .pureWhite))
            }
            .offset(x: Layout.cardInset, y: Layout.cardNumberTop)
            ForEach(Array(zip(Layout.cardColumns, [card.expiryLabel, card.cvcLabel, card.nameLabel])), id: \.0) { column, label in
                Text(label)
                    .typoGraphy(.T1InterMedium11)
                    .foregroundStyle(Color(at: .pureWhite).opacity(Palette.cardLabelOpacity))
                    .offset(x: column, y: Layout.cardLabelsTop)
            }
            ProfileV3GloveBoxArt.cardExpiry.image
                .resizable()
                .frame(width: Layout.cardExpiry.width, height: Layout.cardExpiry.height)
                .offset(x: Layout.cardExpiry.minX, y: Layout.cardExpiry.minY)
            ProfileV3GloveBoxArt.cardCVC.image
                .resizable()
                .frame(width: Layout.cardCVC.width, height: Layout.cardCVC.height)
                .offset(x: Layout.cardCVC.minX, y: Layout.cardCVC.minY)
            Text(card.holder)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureWhite))
                .lineLimit(1)
                .offset(x: Layout.cardColumns[2], y: Layout.cardValuesTop)
        }
        .frame(width: Layout.cardSize.width, height: Layout.cardSize.height, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous))
    }
}
