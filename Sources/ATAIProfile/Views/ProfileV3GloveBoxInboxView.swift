import ATUIKit
import SwiftUI

struct ProfileV3GloveBoxInboxView: View {
    let inbox: ProfileV3GloveBoxInbox
    let isCopied: Bool
    let copies: Int
    let onCopy: () -> Void
    let onOpen: (ProfileV3GloveBoxEmail) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var entranceStart = Date()
    @State private var isEntranceDone: Bool

    init(
        inbox: ProfileV3GloveBoxInbox,
        isCopied: Bool,
        copies: Int,
        animatesEntrance: Bool = true,
        onCopy: @escaping () -> Void,
        onOpen: @escaping (ProfileV3GloveBoxEmail) -> Void
    ) {
        self.inbox = inbox
        self.isCopied = isCopied
        self.copies = copies
        self.onCopy = onCopy
        self.onOpen = onOpen
        _isEntranceDone = State(initialValue: !animatesEntrance)
    }

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Motion = ProfileV3Theme.GloveBox.Motion
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        TimelineView(.animation(paused: isEntranceDone || reduceMotion)) { context in
            content(at: elapsed(at: context.date))
        }
        .task {
            guard !isEntranceDone else { return }
            if !reduceMotion {
                try? await Task.sleep(for: .seconds(Motion.duration))
            }
            isEntranceDone = true
        }
    }

    private func elapsed(at date: Date) -> Double {
        isEntranceDone || reduceMotion ? .infinity : date.timeIntervalSince(entranceStart)
    }

    private func content(at time: Double) -> some View {
        VStack(spacing: 0) {
            address(at: time)
                .padding(.top, Layout.addressTop)
                .zIndex(1)
            copyButton
                .reveal(Motion.copy, at: time)
                .padding(.top, Layout.copyTop)
            if !inbox.about.isEmpty {
                Text(inbox.about)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(Color(at: .pureBlack))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: Layout.aboutWidth)
                    .opacity(Palette.aboutOpacity)
                    .reveal(Motion.about, at: time)
                    .padding(.top, Layout.aboutTop)
            }
            forwarding
                .reveal(Motion.forwarding, at: time)
                .padding(.top, Layout.forwardingTop)
            sheet(at: time)
                .reveal(Motion.sheet, at: time)
                .padding(.top, Layout.sheetTop)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func address(at time: Double) -> some View {
        let drift = CGSize(width: Motion.blobX.value(at: time), height: Motion.blobY.value(at: time))
        return Text(inbox.address)
            .typoGraphy(.H5InterMedium20)
            .foregroundStyle(Color(at: .pureBlack))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, Layout.addressInset)
            .frame(maxWidth: Layout.addressWidth)
            .frame(height: Layout.addressHeight)
            .background {
                ZStack {
                    Color(at: .pureWhite)
                    ProfileV3GloveBoxBlobs(ellipse: Layout.addressBlob, drift: drift)
                        .opacity(Palette.addressBlobOpacity)
                    ProfileV3GloveBoxBlobs(ellipse: Layout.addressBlob, drift: CGSize(width: -drift.width, height: -drift.height))
                        .opacity(Palette.addressBlobOpacity)
                }
                .clipShape(Capsule())
            }
            .overlay(Capsule().strokeBorder(Color(at: .pureWhite), lineWidth: Layout.addressBorder))
            .shadow(
                color: Palette.addressShadow,
                radius: Layout.addressShadowRadius,
                x: Layout.addressShadowOffset.width,
                y: Layout.addressShadowOffset.height
            )
            .padding(.horizontal, Layout.addressInset)
            .opacity(Motion.addressOpacity.value(at: time))
            .scaleEffect(Motion.addressScale.value(at: time))
            .offset(x: Motion.addressX.value(at: time), y: Motion.addressY.value(at: time))
            .accessibilityAddTraits(.isStaticText)
    }

    private var copyButton: some View {
        Button(action: onCopy) {
            HStack(spacing: Layout.copySpacing) {
                (isCopied ? ATIcon.SwiftUIImage.check : ATIcon.SwiftUIImage.contentCopy)
                    .profileV3Icon(Layout.copyIcon)
                Text(isCopied ? ProfileV3Strings.gloveBoxCopied : ProfileV3Strings.gloveBoxCopy)
                    .typoGraphy(.B2InterSemibold12)
            }
            .foregroundStyle(Color(at: .pureBlack))
            .padding(.horizontal, ProfileV3Theme.Space.s12)
            .frame(height: Layout.copyHeight)
            .background(Capsule().fill(Color(at: .pureWhite)))
            .overlay(Capsule().strokeBorder(Palette.copyBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
            .shadow(color: Palette.copyShadow, radius: Layout.copyShadowRadius, y: Layout.copyShadowY)
            .contentShape(Capsule())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .sensoryFeedback(.success, trigger: copies)
        .accessibilityLabel(isCopied ? ProfileV3Strings.gloveBoxCopied : ProfileV3Strings.gloveBoxCopy)
    }

    @ViewBuilder
    private var forwarding: some View {
        if let forwardingAddress = inbox.forwardingAddress, !inbox.forwardingLabel.isEmpty {
            (Text(inbox.forwardingLabel)
                .foregroundStyle(Color(at: .pureBlack).opacity(Palette.forwardingLabelOpacity))
                + Text(" " + forwardingAddress)
                .foregroundStyle(Color(at: .pureBlack)))
                .typoGraphy(.B1InterMedium14)
                .multilineTextAlignment(.center)
                .frame(maxWidth: Layout.forwardingWidth)
                .opacity(Palette.forwardingOpacity)
        }
    }

    private func sheet(at time: Double) -> some View {
        Group {
            if inbox.emails.isEmpty {
                empty
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    emails(at: time)
                        .padding(.horizontal, Layout.sheetInset)
                        .padding(.top, Layout.sheetTitleTop)
                        .padding(.bottom, Layout.listBottom)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: Layout.sheetRadius,
                topTrailingRadius: Layout.sheetRadius,
                style: .continuous
            )
            .fill(Color(at: .pureWhite))
            .shadow(color: Palette.sheetShadow, radius: Layout.sheetShadowRadius, y: Layout.sheetShadowY)
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private func emails(at time: Double) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !inbox.recentTitle.isEmpty {
                Text(inbox.recentTitle)
                    .typoGraphy(.T1InterBold11)
                    .textCase(.uppercase)
                    .foregroundStyle(Color(at: .pureBlack).opacity(Palette.sectionTitleOpacity))
                    .accessibilityAddTraits(.isHeader)
            }
            VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                ForEach(Array(inbox.emails.enumerated()), id: \.element.id) { index, email in
                    VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                        if index > 0 {
                            ProfileV3DashedDivider()
                        }
                        ProfileV3GloveBoxEmailRow(email: email) { onOpen(email) }
                    }
                    .reveal(Motion.row(index), at: time)
                }
            }
            .padding(.top, Layout.listTop)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var empty: some View {
        VStack(spacing: Layout.emptySpacing) {
            ProfileV3GloveBoxArt.folder.image
                .resizable()
                .frame(width: Layout.folderWidth, height: Layout.folderHeight)
                .grayscale(1)
                .accessibilityHidden(true)
            VStack(spacing: Layout.emptyTextSpacing) {
                if !inbox.emptyTitle.isEmpty {
                    Text(inbox.emptyTitle)
                        .typoGraphy(.H6InterMedium18)
                        .foregroundStyle(Color(at: .pureBlack).opacity(Palette.emptyTitleOpacity))
                }
                if !inbox.emptyBody.isEmpty {
                    Text(inbox.emptyBody)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(ProfileV3Theme.GloveBox.emptyBodyGradient)
                        .opacity(Palette.emptyBodyOpacity)
                        .frame(maxWidth: Layout.emptyBodyWidth)
                }
            }
            .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
    }
}

struct ProfileV3GloveBoxEmailRow: View {
    let email: ProfileV3GloveBoxEmail
    let onTap: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: Layout.rowGap) {
                ProfileV3GloveBoxLogo(url: email.logoURL)
                VStack(alignment: .leading, spacing: Layout.rowTextSpacing) {
                    VStack(alignment: .leading, spacing: Layout.rowTitleSpacing) {
                        Text(email.sender)
                            .typoGraphy(.B1InterMedium14)
                            .foregroundStyle(Color(at: .pureBlack))
                        Text(email.summary)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(
                                Color(at: .pureBlack).opacity(ProfileV3Theme.GloveBox.Palette.summaryOpacity)
                            )
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .multilineTextAlignment(.leading)
                    ProfileV3GloveBoxMeta(email: email)
                        .fixedSize()
                }
                .frame(width: Layout.rowTextWidth, alignment: .leading)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityElement(children: .combine)
    }
}

struct ProfileV3GloveBoxLogo: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                ProfileV3RemoteImage(url: url, contentMode: .fill, placeholder: Color(at: .neutralGrey100))
                    .clipShape(Circle())
            } else {
                Color.clear
            }
        }
        .frame(width: ProfileV3Theme.GloveBox.Layout.logo, height: ProfileV3Theme.GloveBox.Layout.logo)
        .accessibilityHidden(true)
    }
}

struct ProfileV3GloveBoxMeta: View {
    let email: ProfileV3GloveBoxEmail

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        if email.needsAttention {
            HStack(spacing: Layout.metaSpacing) {
                ProfileV3GloveBoxArt.attention.image
                    .profileV3Icon(Layout.glyph)
                    .foregroundStyle(Color(at: .pureBlack))
                Text(email.statusLabel)
                    .typoGraphy(.T1InterMedium11)
                    .foregroundStyle(ProfileV3Theme.GloveBox.attentionGradient)
            }
            .opacity(Palette.attentionOpacity)
        } else {
            HStack(spacing: Layout.metaSpacing) {
                ForEach(Array(email.glyphs.enumerated()), id: \.offset) { _, glyph in
                    image(for: glyph)
                        .profileV3Icon(Layout.glyph)
                }
                if !email.statusLabel.isEmpty {
                    Text(email.statusLabel)
                        .typoGraphy(.T1InterMedium11)
                }
                if let dateLabel = email.dateLabel {
                    Text(ProfileV3Strings.gloveBoxDated(dateLabel))
                        .typoGraphy(.T1InterMedium11)
                }
            }
            .foregroundStyle(Color(at: .pureBlack).opacity(Palette.metaOpacity))
        }
    }

    private func image(for glyph: ProfileV3GloveBoxEmail.Glyph) -> Image {
        switch glyph {
        case .mail: return ATIcon.SwiftUIImage.mail
        case .seen: return ATIcon.SwiftUIImage.visibility
        case .calendar: return ATIcon.SwiftUIImage.calendarToday
        case .done: return ATIcon.SwiftUIImage.doneAll
        }
    }
}

private extension View {
    func reveal(_ reveal: ProfileV3Reveal, at time: Double) -> some View {
        let progress = reveal.progress(at: time)
        return opacity(progress)
            .offset(y: reveal.offset(at: time))
    }
}
