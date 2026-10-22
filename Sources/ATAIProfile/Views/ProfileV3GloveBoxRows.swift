import ATUIKit
import SwiftUI

struct ProfileV3GloveBoxEmailRow: View {
    let email: ProfileV3GloveBoxEmail
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ProfileV3GloveBoxRowLayout(logoURL: email.logoURL, title: email.sender, summary: email.summary) {
                if let attention = email.attention, !attention.isEmpty {
                    ProfileV3GloveBoxAttention(label: attention)
                }
                if let meta = email.meta {
                    ProfileV3GloveBoxMetaLine(meta: meta)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityElement(children: .combine)
    }
}

struct ProfileV3GloveBoxCallRow: View {
    let call: ProfileV3GloveBoxCall
    var pillFill: Color = Color(at: .pureWhite)
    var pillWidth: CGFloat?
    var insetsPill = true
    let onTap: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Layout.callPillTop) {
                ProfileV3GloveBoxRowLayout(logoURL: call.logoURL, title: call.title, summary: call.summary) {
                    if let meta = call.meta {
                        ProfileV3GloveBoxMetaLine(meta: meta)
                    }
                }
                ProfileV3GloveBoxAudioPill(recording: call.recording, fill: pillFill, waveGroups: pillWidth == nil ? 2 : 1)
                    .frame(maxWidth: pillWidth ?? .infinity, alignment: .leading)
                    .padding(.leading, insetsPill ? Layout.logo + Layout.rowGap : 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityElement(children: .combine)
    }
}

struct ProfileV3GloveBoxTransactionRow: View {
    let transaction: ProfileV3GloveBoxTransaction
    let onTap: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: Layout.transactionGap) {
                VStack(alignment: .leading, spacing: Layout.transactionTextSpacing) {
                    Text(transaction.title)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(Color(at: .pureBlack))
                        .fixedSize(horizontal: false, vertical: true)
                    if !transaction.summary.isEmpty {
                        Text(transaction.summary)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(Color(at: .pureBlack).opacity(Palette.summaryOpacity))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                ProfileV3GloveBoxAmount(transaction: transaction)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityElement(children: .combine)
    }
}

struct ProfileV3GloveBoxAmount: View {
    let transaction: ProfileV3GloveBoxTransaction

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        VStack(alignment: .trailing, spacing: Layout.transactionTextSpacing) {
            Text(transaction.amount)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureBlack))
            switch transaction.outcome {
            case .approved:
                Text(transaction.outcomeLabel)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(ProfileV3Theme.GloveBox.approvedGradient)
            case .blocked:
                ProfileV3GloveBoxAttention(label: transaction.outcomeLabel, spacing: Layout.blockedSpacing)
            }
        }
        .fixedSize()
    }
}

private struct ProfileV3GloveBoxRowLayout<Status: View>: View {
    let logoURL: URL?
    let title: String
    let summary: String
    @ViewBuilder let status: Status

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        HStack(alignment: .top, spacing: Layout.rowGap) {
            ProfileV3GloveBoxLogo(url: logoURL)
            VStack(alignment: .leading, spacing: Layout.rowTextSpacing) {
                VStack(alignment: .leading, spacing: Layout.rowTitleSpacing) {
                    Text(title)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(Color(at: .pureBlack))
                        .fixedSize(horizontal: false, vertical: true)
                    if !summary.isEmpty {
                        Text(summary)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(
                                Color(at: .pureBlack).opacity(ProfileV3Theme.GloveBox.Palette.summaryOpacity)
                            )
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .multilineTextAlignment(.leading)
                status
            }
            .frame(maxWidth: Layout.rowTextWidth, alignment: .leading)
            Spacer(minLength: 0)
        }
    }
}

struct ProfileV3GloveBoxLogo: View {
    let url: URL?
    var size = ProfileV3Theme.GloveBox.Layout.logo

    var body: some View {
        Group {
            if let url {
                ProfileV3RemoteImage(url: url, contentMode: .fill, placeholder: Color(at: .neutralGrey100))
                    .clipShape(Circle())
            } else {
                Color.clear
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct ProfileV3GloveBoxMetaLine: View {
    let meta: ProfileV3GloveBoxMeta

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        HStack(spacing: Layout.metaSpacing) {
            ForEach(Array(meta.glyphs.enumerated()), id: \.offset) { _, glyph in
                image(for: glyph)
                    .profileV3Icon(Layout.glyph)
                    .foregroundStyle(Color(at: .pureBlack).opacity(Palette.metaIconOpacity))
            }
            Group {
                if !meta.label.isEmpty {
                    Text(meta.label)
                }
                if let dateLabel = meta.dateLabel {
                    Text(ProfileV3Strings.gloveBoxDated(dateLabel))
                }
            }
            .typoGraphy(.T1InterMedium11)
            .foregroundStyle(Color(at: .pureBlack).opacity(Palette.metaOpacity))
        }
        .fixedSize()
    }

    private func image(for glyph: ProfileV3GloveBoxGlyph) -> Image {
        switch glyph {
        case .mail: return ATIcon.SwiftUIImage.mail
        case .seen: return ATIcon.SwiftUIImage.visibility
        case .calendar: return ATIcon.SwiftUIImage.calendarToday
        case .done: return ATIcon.SwiftUIImage.doneAll
        }
    }
}

struct ProfileV3GloveBoxAttention: View {
    let label: String
    var spacing = ProfileV3Theme.GloveBox.Layout.metaSpacing

    var body: some View {
        HStack(spacing: spacing) {
            ProfileV3GloveBoxArt.attention.image
                .profileV3Icon(ProfileV3Theme.GloveBox.Layout.glyph)
                .foregroundStyle(ProfileV3Theme.GloveBox.Palette.icon)
            Text(label)
                .typoGraphy(.T1InterMedium11)
                .foregroundStyle(ProfileV3Theme.GloveBox.attentionGradient)
        }
        .opacity(ProfileV3Theme.GloveBox.Palette.attentionOpacity)
        .fixedSize()
    }
}

struct ProfileV3GloveBoxAudioPill: View {
    let recording: ProfileV3GloveBoxCall.Recording
    var fill: Color = Color(at: .pureWhite)
    var waveGroups = 1

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        HStack(spacing: Layout.audioGap) {
            switch recording {
            case let .audio(duration, speed):
                ATIcon.SwiftUIImage.playCircleOutline
                    .profileV3Icon(Layout.audioPlay)
                    .foregroundStyle(Color(at: .pureBlack))
                ProfileV3GloveBoxWaveform(groups: waveGroups)
                Spacer(minLength: 0)
                HStack(spacing: Layout.audioMetaSpacing) {
                    Text(speed)
                        .foregroundStyle(Color(at: .pureBlack))
                    Text(duration)
                        .foregroundStyle(Palette.audioMeta)
                }
                .typoGraphy(.B2InterSemibold12)
                .fixedSize()
            case .missing(let message):
                ATIcon.SwiftUIImage.playCircleOutline
                    .profileV3Icon(Layout.audioPlay)
                    .foregroundStyle(Palette.audioMeta)
                Text(message)
                    .typoGraphy(.B2InterSemibold12)
                    .foregroundStyle(Palette.audioMeta)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
        }
        .padding(Layout.audioPadding)
        .background(Capsule().fill(fill))
    }
}

struct ProfileV3GloveBoxWaveform: View {
    var groups = 1

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        HStack(spacing: Layout.waveGroupGap) {
            ForEach(0..<groups, id: \.self) { _ in
                HStack(spacing: Layout.wavePitch - Layout.waveBar) {
                    ForEach(Array(Layout.waveBars.enumerated()), id: \.offset) { _, height in
                        Capsule()
                            .fill(ProfileV3Theme.GloveBox.Palette.icon)
                            .frame(width: Layout.waveBar, height: height)
                    }
                }
            }
        }
        .frame(height: Layout.waveHeight)
        .accessibilityHidden(true)
    }
}

struct ProfileV3GloveBoxBadgeView: View {
    let badge: ProfileV3GloveBoxBadge

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Layout.badgeRadius, style: .continuous)
        switch badge.tone {
        case .live:
            Text(badge.label)
                .typoGraphy(.T1InterBold11)
                .textCase(.uppercase)
                .foregroundStyle(Color(at: .pureWhite))
                .padding(.leading, Layout.badgeLeading)
                .padding(.trailing, Layout.badgeTrailing)
                .frame(minWidth: Layout.badgeMinWidth)
                .frame(height: Layout.badgeHeight)
                .background(shape.fill(ProfileV3Theme.GloveBox.liveBadgeGradient))
                .fixedSize()
        case .pending:
            Text(badge.label)
                .typoGraphy(.T1InterBold11)
                .textCase(.uppercase)
                .foregroundStyle(Palette.pendingBadge.opacity(Palette.pendingBadgeOpacity))
                .padding(.horizontal, Layout.pendingBadgeInset)
                .frame(height: Layout.badgeHeight)
                .background(shape.fill(Palette.preview))
                .fixedSize()
        }
    }
}

struct ProfileV3GloveBoxSampleTag: View {
    let label: String

    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        Text(label)
            .typoGraphy(.B2InterMedium12)
            .foregroundStyle(Palette.sampleText)
            .padding(ProfileV3Theme.GloveBox.Layout.sampleInset)
            .background(Capsule().fill(Palette.sample))
            .opacity(Palette.sampleOpacity)
            .fixedSize()
    }
}

struct ProfileV3GloveBoxViewAll: View {
    let title: String
    let action: () -> Void

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.viewAllSpacing) {
                Text(title)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(Color(at: .pureBlack))
                ATIcon.SwiftUIImage.chevronRight
                    .profileV3Icon(Layout.viewAllIcon)
                    .foregroundStyle(ProfileV3Theme.GloveBox.Palette.control)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

struct ProfileV3GloveBoxCopyValue: View {
    let value: String
    var countryCode: String?
    var isCopyable = true
    var isCopied = false
    var spacing = ProfileV3Theme.GloveBox.Layout.valueSpacing
    var onCopy: () -> Void = {}

    private typealias Layout = ProfileV3Theme.GloveBox.Layout

    var body: some View {
        HStack(spacing: spacing) {
            HStack(spacing: Layout.valueSpacing) {
                if let countryCode, let country = ATCountry(isoCode: countryCode) {
                    ATCountryFlagView(country: country)
                        .frame(width: Layout.flag, height: Layout.flag)
                        .clipShape(Circle())
                        .accessibilityHidden(true)
                }
                Text(value)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(Color(at: .pureBlack))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            if isCopyable {
                Button(action: onCopy) {
                    (isCopied ? ATIcon.SwiftUIImage.check : ATIcon.SwiftUIImage.contentCopy)
                        .profileV3Icon(Layout.copyIcon)
                        .foregroundStyle(ProfileV3Theme.GloveBox.Palette.icon)
                        .padding(Layout.copyHitInset)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.profileV3Pressable(.selection))
                .padding(-Layout.copyHitInset)
                .accessibilityLabel(isCopied ? ProfileV3Strings.gloveBoxCopied : ProfileV3Strings.gloveBoxCopy)
            }
        }
    }
}

struct ProfileV3GloveBoxPreviewCard<Content: View>: View {
    var sampleLabel: String?
    var padding = ProfileV3Theme.GloveBox.Layout.previewPadding
    @ViewBuilder let content: Content

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Layout.previewRadius, style: .continuous)
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(shape.fill(Palette.preview))
            .overlay(shape.strokeBorder(Palette.sectionBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
            .overlay(alignment: .topTrailing) {
                if let sampleLabel, !sampleLabel.isEmpty {
                    ProfileV3GloveBoxSampleTag(label: sampleLabel)
                        .padding(.top, Layout.sampleTop)
                        .padding(.trailing, Layout.sampleTrailing)
                }
            }
    }
}

struct ProfileV3GloveBoxRowDivider: View {
    var inset: CGFloat = 0

    var body: some View {
        ProfileV3DashedDivider()
            .padding(.leading, inset)
    }
}
