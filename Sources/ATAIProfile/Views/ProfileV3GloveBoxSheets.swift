import ATUIKit
import SwiftUI

struct ProfileV3GloveBoxSheetStack: View {
    @ObservedObject var viewModel: ProfileV3GloveBoxViewModel
    var bottomInset: CGFloat = 0

    @State private var shown: ProfileV3GloveBoxViewModel.Sheet?

    var body: some View {
        ZStack(alignment: .top) {
            if let sheet = viewModel.sheets.last ?? shown, let home = viewModel.home {
                ProfileV3GloveBoxSheet(sheet: sheet, home: home, viewModel: viewModel, bottomInset: bottomInset)
                    .id(sheet.id)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(at: .pureWhite))
        .onChange(of: viewModel.sheets.last, initial: true) { _, sheet in
            if let sheet {
                shown = sheet
            }
        }
    }
}

struct ProfileV3GloveBoxSheet: View {
    let sheet: ProfileV3GloveBoxViewModel.Sheet
    let home: ProfileV3GloveBoxHome
    @ObservedObject var viewModel: ProfileV3GloveBoxViewModel
    var bottomInset: CGFloat = 0

    var body: some View {
        switch sheet {
        case .list(let section):
            ProfileV3GloveBoxListSheet(section: section, home: home, viewModel: viewModel, bottomInset: bottomInset)
        case .detail(let entry):
            ProfileV3GloveBoxDetailSheet(
                entry: entry,
                sampleLabel: viewModel.sampleLabel(for: entry),
                bottomInset: bottomInset,
                openingAttachmentID: viewModel.openingAttachmentID,
                onBack: viewModel.back,
                onFollowUp: viewModel.tapFollowUp,
                onOpenAttachment: { attachment in
                    if case .email(let email) = entry {
                        viewModel.openAttachment(attachment, messageID: email.id)
                    }
                }
            )
        case .comingSoon:
            ProfileV3GloveBoxComingSoonSheet(
                message: ProfileV3GloveBoxCopy.cardLinkComingSoon,
                bottomInset: bottomInset,
                onBack: viewModel.back
            )
        }
    }
}

struct ProfileV3GloveBoxComingSoonSheet: View {
    let message: String
    var bottomInset: CGFloat = 0
    let onBack: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetGrabber()
            ProfileV3CircleIconButton.back(action: onBack)
                .padding(.top, Layout.detailBackTop)
                .padding(.leading, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .frame(maxWidth: .infinity, alignment: .leading)
            Canvas { context, size in
                ProfileV3GloveBoxDial.draw(
                    ProfileV3GloveBoxArt.dialCreditCard.image,
                    centre: CGPoint(x: size.width / 2, y: Layout.comingSoonDial / 2),
                    diameter: Layout.comingSoonDial,
                    in: context
                )
            }
            .frame(width: Layout.comingSoonDial, height: Layout.comingSoonDial + Layout.dialShadowDrop * 2)
            .padding(.top, Layout.comingSoonArtTop)
            .accessibilityHidden(true)
            Text(ProfileV3Strings.comingSoon)
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .accessibilityAddTraits(.isHeader)
                .padding(.top, Layout.comingSoonTitleTop)
            if !message.isEmpty {
                Text(message)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.accessSubtitle))
                    .frame(maxWidth: Layout.comingSoonBodyWidth)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Layout.comingSoonBodyTop)
            }
            Color.clear
                .frame(height: Layout.comingSoonBottom + bottomInset)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

struct ProfileV3GloveBoxListSheet: View {
    let section: ProfileV3GloveBoxViewModel.Section
    let home: ProfileV3GloveBoxHome
    @ObservedObject var viewModel: ProfileV3GloveBoxViewModel
    let bottomInset: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appearedAt = Date()
    @State private var isRevealDone: Bool

    init(
        section: ProfileV3GloveBoxViewModel.Section,
        home: ProfileV3GloveBoxHome,
        viewModel: ProfileV3GloveBoxViewModel,
        bottomInset: CGFloat = 0,
        revealsRows: Bool = true
    ) {
        self.section = section
        self.home = home
        self.viewModel = viewModel
        self.bottomInset = bottomInset
        _isRevealDone = State(initialValue: !revealsRows)
    }

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Motion = ProfileV3Theme.GloveBox.Motion
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3BackTagHeader(title: title, top: Layout.listPadding.top, onBack: viewModel.back)
            content
        }
        .frame(maxWidth: .infinity)
        .task {
            guard !isRevealDone else { return }
            if !reduceMotion {
                try? await Task.sleep(for: .seconds(Motion.listDuration(rows: rowCount)))
            }
            isRevealDone = true
        }
    }

    private var title: String {
        switch section {
        case .emails: return home.email.listTitle
        case .calls: return home.phone.listTitle
        case .transactions: return home.card.listTitle
        }
    }

    private var rowCount: Int {
        switch section {
        case .emails: return home.email.emails.count
        case .calls: return home.phone.calls.count
        case .transactions: return home.card.transactions.count
        }
    }

    private var content: some View {
        TimelineView(.animation(paused: isRevealDone || reduceMotion)) { context in
            rows(at: isRevealDone || reduceMotion ? .infinity : context.date.timeIntervalSince(appearedAt))
        }
        .padding(.horizontal, Layout.listPadding.leading)
        .padding(.top, section == .emails ? Layout.emailListHeaderGap : Layout.listHeaderGap)
        .padding(.bottom, Layout.listPadding.bottom + bottomInset)
    }

    @ViewBuilder
    private func rows(at time: Double) -> some View {
        switch section {
        case .emails:
            LazyVStack(alignment: .leading, spacing: Layout.rowSpacing) {
                ForEach(Array(home.email.emails.enumerated()), id: \.element.id) { index, email in
                    VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                        if index > 0 {
                            ProfileV3GloveBoxRowDivider()
                        }
                        ProfileV3GloveBoxEmailRow(email: email) { viewModel.open(.email(email)) }
                    }
                    .revealed(Motion.row(index), at: time)
                }
                if viewModel.hasMoreEmails {
                    if viewModel.emailPagingFailed {
                        ProfileV3PillButton(title: ProfileV3GloveBoxCopy.tryAgain, action: viewModel.retryLoadMoreEmails)
                            .frame(maxWidth: .infinity)
                    } else {
                        ProfileV3Spinner()
                            .frame(maxWidth: .infinity)
                            .id(home.email.emails.count)
                            .onAppear(perform: viewModel.loadMoreEmails)
                    }
                }
            }
        case .calls:
            VStack(alignment: .leading, spacing: 0) {
                if let trip = home.phone.trip {
                    tripCard(trip)
                        .padding(.bottom, Layout.callsListTop)
                }
                VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                    ForEach(Array(home.phone.calls.enumerated()), id: \.element.id) { index, call in
                        VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                            if index > 0 {
                                ProfileV3GloveBoxRowDivider()
                            }
                            ProfileV3GloveBoxCallRow(call: call, pillFill: Palette.preview, insetsPill: false) {
                                viewModel.open(.call(call))
                            }
                        }
                        .revealed(Motion.row(index), at: time)
                    }
                }
            }
        case .transactions:
            VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                ForEach(Array(home.card.transactions.enumerated()), id: \.element.id) { index, transaction in
                    VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                        ProfileV3GloveBoxTransactionRow(transaction: transaction) {
                            viewModel.open(.transaction(transaction))
                        }
                        ProfileV3GloveBoxRowDivider()
                    }
                    .revealed(Motion.row(index), at: time)
                }
            }
        }
    }

    private func tripCard(_ trip: ProfileV3GloveBoxPhoneSection.Trip) -> some View {
        let shape = RoundedRectangle(cornerRadius: Layout.callsCardRadius, style: .continuous)
        return HStack(alignment: .top, spacing: ProfileV3Theme.Space.s8) {
            VStack(alignment: .leading, spacing: Layout.callsCardSpacing) {
                Text(trip.label)
                    .typoGraphy(.T1InterBold11)
                    .textCase(.uppercase)
                    .foregroundStyle(Color(at: .pureBlack).opacity(Palette.sectionTitleOpacity))
                ProfileV3GloveBoxCopyValue(
                    value: trip.number.value,
                    countryCode: trip.number.countryCode,
                    isCopyable: trip.number.isCopyable,
                    isCopied: viewModel.copied == .tripNumber,
                    spacing: Layout.copyGap,
                    onCopy: { viewModel.copy(.tripNumber) }
                )
            }
            Spacer(minLength: 0)
            if let badge = trip.badge {
                ProfileV3GloveBoxBadgeView(badge: badge)
            }
        }
        .padding(Layout.callsCardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(shape.fill(Palette.preview))
        .overlay(shape.strokeBorder(Palette.sectionBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
    }
}

struct ProfileV3GloveBoxDetailSheet: View {
    let entry: ProfileV3GloveBoxViewModel.Entry
    var sampleLabel: String?
    var bottomInset: CGFloat = 0
    var openingAttachmentID: String?
    let onBack: () -> Void
    let onFollowUp: () -> Void
    var onOpenAttachment: (ProfileV3GloveBoxAttachment) -> Void = { _ in }

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProfileV3SheetGrabber()
            ProfileV3CircleIconButton.back(action: onBack)
                .padding(.top, Layout.detailBackTop)
                .padding(.leading, ProfileV3Theme.Sizes.screenHorizontalMargin)
            Group {
                header
                    .padding(.top, Layout.detailHeaderTop)
                ProfileV3DashedDivider()
                    .padding(.top, Layout.detailDividerTop)
                if let note, !note.isEmpty {
                    ProfileV3FlowingText(
                        text: note,
                        trailingExclusion: CGSize(
                            width: ProfileV3AtlysOrb.Metrics.insight.ringOuter + Layout.detailNoteOrbGap,
                            height: ProfileV3AtlysOrb.Metrics.insight.ringOuter
                        ),
                        besideWidth: Layout.detailNoteWidth
                    )
                    .overlay(alignment: .topTrailing) {
                        ProfileV3AtlysOrb(ring: .still, metrics: .insight)
                    }
                    .padding(.top, Layout.detailNoteTop)
                }
                if case .email(let email) = entry, !email.attachments.isEmpty {
                    ProfileV3FlowLayout(horizontalSpacing: Layout.attachmentSpacing, verticalSpacing: Layout.attachmentRowSpacing) {
                        ForEach(email.attachments) { attachment in
                            attachmentChip(attachment, isOpening: openingAttachmentID == "\(email.id)-\(attachment.index)")
                        }
                    }
                    .padding(.top, note?.isEmpty == false ? Layout.detailAttachmentsTop : Layout.detailNoteTop)
                }
            }
            .padding(.horizontal, Layout.detailInset)
            if sampleLabel == nil, let followUpTitle, !followUpTitle.isEmpty {
                ProfileV3ContinueButton(title: followUpTitle, action: onFollowUp)
                    .profileV3CTABar(top: Layout.detailCTATop, bottom: ProfileV3Theme.Sizes.ctaBarBottom + bottomInset)
            } else {
                Color.clear
                    .frame(height: Layout.detailEmptyBottom + bottomInset)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func attachmentChip(_ attachment: ProfileV3GloveBoxAttachment, isOpening: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: Layout.attachmentRadius, style: .continuous)
        return Button { onOpenAttachment(attachment) } label: {
            HStack(spacing: Layout.attachmentIconGap) {
                ZStack {
                    if isOpening {
                        ProgressView()
                            .controlSize(.mini)
                    } else {
                        (attachment.isImage ? ATIcon.SwiftUIImage.image : ATIcon.SwiftUIImage.attachFile)
                            .profileV3Icon(Layout.attachmentIcon)
                    }
                }
                .frame(width: Layout.attachmentIcon, height: Layout.attachmentIcon)
                Text(attachment.filename)
                    .typoGraphy(.B2InterSemibold12)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .foregroundStyle(Color(at: .neutralGrey700))
            .padding(Layout.attachmentPadding)
            .background(shape.fill(Palette.preview))
            .overlay(shape.strokeBorder(Palette.sectionBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
            .contentShape(shape)
        }
        .buttonStyle(.profileV3Pressable)
        .disabled(openingAttachmentID != nil)
        .accessibilityLabel(attachment.filename)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: ProfileV3Theme.Space.s16) {
            VStack(alignment: .leading, spacing: Layout.detailBlockSpacing) {
                VStack(alignment: .leading, spacing: Layout.detailTitleSpacing) {
                    Text(title)
                        .typoGraphy(.H6InterMedium18)
                        .foregroundStyle(Color(at: .pureBlack))
                        .frame(maxWidth: Layout.detailTitleWidth, alignment: .leading)
                    if !summary.isEmpty {
                        Text(summary)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(Color(at: .pureBlack).opacity(Palette.summaryOpacity))
                            .frame(maxWidth: Layout.rowTextWidth, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                status
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 0) {
                trailingTop
                Spacer(minLength: ProfileV3Theme.Space.s16)
                if let sampleLabel, !sampleLabel.isEmpty {
                    ProfileV3GloveBoxSampleTag(label: sampleLabel)
                } else if let badge, !badge.isEmpty {
                    ProfileV3GloveBoxBadgeView(badge: ProfileV3GloveBoxBadge(label: badge, tone: .live))
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var status: some View {
        switch entry {
        case .email(let email):
            if email.attention != nil || email.meta != nil {
                VStack(alignment: .leading, spacing: Layout.rowTextSpacing) {
                    if let attention = email.attention {
                        VStack(alignment: .leading, spacing: Layout.rowTitleSpacing) {
                            ProfileV3GloveBoxAttention(label: attention.title)
                            if let detail = attention.detail {
                                Text(detail)
                                    .typoGraphy(.B2InterMedium12)
                                    .foregroundStyle(Color(at: .pureBlack).opacity(Palette.attentionOpacity))
                                    .frame(maxWidth: Layout.rowTextWidth, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    if let meta = email.meta {
                        ProfileV3GloveBoxMetaLine(meta: meta)
                    }
                }
            }
        case .call(let call):
            VStack(alignment: .leading, spacing: Layout.detailBlockSpacing) {
                if let meta = call.meta {
                    ProfileV3GloveBoxMetaLine(meta: meta)
                }
                ProfileV3GloveBoxAudioPill(recording: call.recording, fill: Palette.preview, waveGroups: 2)
                    .frame(maxWidth: Layout.audioDetailWidth)
            }
        case .transaction:
            EmptyView()
        }
    }

    @ViewBuilder
    private var trailingTop: some View {
        switch entry {
        case .email(let email):
            ProfileV3GloveBoxLogo(url: email.logoURL, initials: email.initials)
        case .call(let call):
            ProfileV3GloveBoxLogo(url: call.logoURL)
        case .transaction(let transaction):
            ProfileV3GloveBoxAmount(transaction: transaction)
        }
    }

    private var title: String {
        switch entry {
        case .email(let email): return email.sender
        case .call(let call): return call.title
        case .transaction(let transaction): return transaction.title
        }
    }

    private var summary: String {
        switch entry {
        case .email(let email): return email.summary
        case .call(let call): return call.summary
        case .transaction(let transaction): return transaction.summary
        }
    }

    private var badge: String? {
        switch entry {
        case .email(let email): return email.badge
        case .call(let call): return call.badge
        case .transaction: return nil
        }
    }

    private var note: String? {
        switch entry {
        case .email(let email): return email.note
        case .call(let call): return call.note
        case .transaction(let transaction): return transaction.note
        }
    }

    private var followUpTitle: String? {
        switch entry {
        case .email(let email): return email.followUpTitle
        case .call(let call): return call.followUpTitle
        case .transaction(let transaction): return transaction.followUpTitle
        }
    }
}

private extension View {
    func revealed(_ reveal: ProfileV3Reveal, at time: Double) -> some View {
        opacity(reveal.progress(at: time))
            .offset(y: reveal.offset(at: time))
    }
}
