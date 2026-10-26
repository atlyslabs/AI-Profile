import ATUIKit
import SwiftUI

struct ProfileV3ProgrammeTile: View {
    enum Pill: Equatable {
        case none
        case insight(isLoading: Bool)
        case remove(isRemoving: Bool)
    }

    let programme: ProfileV3LoyaltyProgramme
    var width: CGFloat?
    var showsInsight = false
    var pill: Pill = .none
    var isFlipped = false
    var onTap: (() -> Void)?
    var onAction: (() -> Void)?
    var onRemove: (() -> Void)?

    @State private var isCopied = false
    @State private var copies = 0
    @State private var artAspect: CGFloat?

    private var textInset: CGFloat { ProfileV3Theme.Space.s22 }

    private var pointsText: String {
        programme.points.formatted()
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.xxl, style: .continuous)
    }

    private var cardAspect: CGFloat {
        artAspect ?? programme.artAspect ?? ProfileV3Theme.Sizes.Programme.artAspectRatio
    }

    private var hasBottomRow: Bool {
        guard !isFlipped else { return false }
        switch pill {
        case .none: return false
        case .remove: return true
        case .insight: return insightTitle != nil
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            face
            if !isFlipped {
                bottomRow
            }
        }
        .aspectRatio(cardAspect, contentMode: .fit)
        .frame(width: width, height: width.map { $0 / cardAspect })
        .frame(maxWidth: width == nil ? .infinity : nil)
        .contentShape(shape)
        .contentShape(.dragPreview, shape)
    }

    private var bottomRow: some View {
        bottomPill
            .padding(.leading, ProfileV3Theme.Space.s20)
            .padding(.bottom, ProfileV3Theme.Sizes.ProgrammeTile.pillBottom)
    }

    private var cardFace: some View {
        front
            .profileV3Flip(isFlipped: isFlipped) { back }
    }

    @ViewBuilder
    private var face: some View {
        if let onTap {
            Button(action: onTap) { cardFace }
                .buttonStyle(.plain)
                .accessibilityLabel(programme.name)
                .accessibilityHint(ProfileV3Strings.programmeTileHint)
        } else {
            cardFace
        }
    }

    private var front: some View {
        ZStack(alignment: .topLeading) {
            shape.fill(ProfileV3Theme.Palette.programmeTileBack)
                .overlay { art }
            if hasInsight {
                ProfileV3ProgrammeDotGrid(color: shade.dots)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(.leading, ProfileV3Theme.Space.s24)
                    .padding(.bottom, ProfileV3Theme.Space.s10)
            }
            if !hasArt {
                ATIcon.SwiftUIImage.flight
                    .profileV3Icon(ProfileV3Theme.Sizes.ProgrammeTile.flight)
                    .foregroundStyle(ProfileV3Theme.Palette.programmeTileFlight)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, ProfileV3Theme.Space.s20)
                    .padding(.bottom, ProfileV3Theme.Space.s22)
                    .accessibilityHidden(true)
            }
            copy
        }
        .clipShape(shape)
    }

    private var copy: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: ProfileV3Theme.Space.s16) {
                if !hasArt || programme.isArtPlaceholder {
                    Text(programme.name)
                        .typoGraphy(.B2InterSemibold12)
                        .foregroundStyle(shade.primary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Text(ProfileV3Strings.points)
                    .typoGraphy(.T1InterBold11)
                    .textCase(.uppercase)
                    .foregroundStyle(shade.label)
                    .fixedSize()
            }
            HStack(alignment: .center, spacing: ProfileV3Theme.Space.s16) {
                if hasNumber || programme.tier != nil {
                    numberRow
                }
                Spacer(minLength: 0)
                Text(pointsText)
                    .typoGraphy(.H4InterSemibold24)
                    .foregroundStyle(shade.primary)
                    .fixedSize()
            }
            .padding(.top, ProfileV3Theme.Space.s6)
            if programme.expiryLabel != nil || programme.updatedLine != nil {
                HStack(alignment: .firstTextBaseline, spacing: ProfileV3Theme.Space.s12) {
                    if let expiry = programme.expiryLabel {
                        Text(expiry)
                            .typoGraphy(.T1InterMedium11)
                            .foregroundStyle(shade.faint)
                            .fixedSize()
                    }
                    Spacer(minLength: 0)
                    if let updated = programme.updatedLine {
                        Text(updated)
                            .typoGraphy(.T1InterMedium11)
                            .foregroundStyle(shade.secondary)
                            .multilineTextAlignment(.trailing)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, ProfileV3Theme.Space.s6)
            }
            if let insight = insightText, showsInsight {
                Text(insight)
                    .typoGraphy(.T1InterMedium11)
                    .foregroundStyle(shade.number)
                    .frame(maxWidth: ProfileV3Theme.Sizes.ProgrammeTile.insightWidth, alignment: .topLeading)
                    .padding(.top, ProfileV3Theme.Space.s20)
                    .layoutPriority(-1)
                    .transition(.opacity.combined(with: .offset(y: ProfileV3Theme.Motion.insightRevealOffset)))
            }
        }
        .padding(.top, ProfileV3Theme.Space.s24)
        .padding(.horizontal, textInset)
        .padding(.bottom, hasBottomRow ? ProfileV3Theme.Sizes.ProgrammeTile.bottomRowReserve : ProfileV3Theme.Space.s20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .shadow(
            color: hasArt ? shade.shadow : .clear,
            radius: ProfileV3Theme.Shadow.artTextRadius,
            y: ProfileV3Theme.Shadow.artTextY
        )
    }

    private var hasArt: Bool { programme.artURL != nil }

    private var shade: ProfileV3Theme.CardShade { .resolve(programme.textOverlay) }

    private var hasNumber: Bool { programme.displayNumber != nil }

    private var numberRow: some View {
        HStack(spacing: 0) {
            if let tier = programme.tier {
                tierLabel(tier)
            }
            if let number = programme.displayNumber {
                Text(number)
                    .font(Font.Inter.get(size: ProfileV3Theme.Typography.programmeNumberSize, weight: .bold))
                    .tracking(ProfileV3Theme.Typography.programmeNumberTracking)
                    .textCase(.uppercase)
                    .foregroundStyle(shade.number)
                    .lineLimit(1)
            }
            if let number = programme.membershipNumber {
                Button { copy(number) } label: {
                    (isCopied ? ATIcon.SwiftUIImage.check : ATIcon.SwiftUIImage.contentCopy)
                        .profileV3Icon(ProfileV3Theme.Icon.md)
                        .foregroundStyle(shade.primary)
                        .padding(ProfileV3Theme.Sizes.ProgrammeTile.copyHitInset)
                        .contentShape(Rectangle())
                        .padding(-ProfileV3Theme.Sizes.ProgrammeTile.copyHitInset)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    isCopied ? ProfileV3Strings.membershipNumberCopied : ProfileV3Strings.copyMembershipNumber
                )
                .padding(.leading, ProfileV3Theme.Sizes.ProgrammeTile.copyGap)
            }
        }
        .sensoryFeedback(.success, trigger: copies)
        .task(id: copies) {
            guard copies > 0 else { return }
            try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.copiedResetSeconds))
            guard !Task.isCancelled else { return }
            withAnimation(ProfileV3Theme.Motion.selection) { isCopied = false }
        }
    }

    private func tierLabel(_ tier: String) -> some View {
        HStack(spacing: ProfileV3Theme.Space.s10) {
            Text(tier)
                .typoGraphy(.T1InterBold11)
                .foregroundStyle(shade.primary)
                .lineLimit(1)
            if hasNumber {
                Rectangle()
                    .fill(shade.divider)
                    .frame(
                        width: ProfileV3Theme.Stroke.hairline,
                        height: ProfileV3Theme.Sizes.ProgrammeTile.tierDividerHeight
                    )
                    .accessibilityHidden(true)
            }
        }
        .padding(.trailing, hasNumber ? ProfileV3Theme.Sizes.ProgrammeTile.copyGap : 0)
    }

    private func copy(_ number: String) {
        UIPasteboard.general.string = number
        withAnimation(ProfileV3Theme.Motion.selection) { isCopied = true }
        copies += 1
    }

    private var hasInsight: Bool {
        programme.insight != nil || programme.insightDirective != nil
    }

    private var insightText: String? {
        if let summary = programme.insight?.summary, !summary.isEmpty { return summary }
        guard let line = programme.pointsLine?.trimmingCharacters(in: .whitespacesAndNewlines),
              !line.isEmpty else { return nil }
        return line
    }

    private var insightTitle: String? {
        hasInsight ? ProfileV3Strings.viewInsight : nil
    }

    @ViewBuilder
    private var bottomPill: some View {
        switch pill {
        case .remove(let isRemoving):
            ProfileV3ProgrammeTilePill(
                title: ProfileV3Strings.removeProgramme,
                isLoading: isRemoving,
                shade: shade,
                action: { onRemove?() }
            )
            .transition(.opacity.combined(with: .offset(y: ProfileV3Theme.Motion.insightRevealOffset)))
        case .insight(let isLoading):
            if let title = insightTitle {
                ProfileV3ProgrammeTilePill(
                    title: title,
                    showsChevron: true,
                    isLoading: isLoading,
                    shade: shade,
                    action: { onAction?() }
                )
                .transition(.opacity.combined(with: .offset(y: ProfileV3Theme.Motion.insightRevealOffset)))
            }
        case .none:
            EmptyView()
        }
    }

    private var back: some View {
        ZStack {
            shape.fill(ProfileV3Theme.Palette.programmeTileBack)
            RadialGradient(
                colors: [glowColor.opacity(ProfileV3Theme.Opacity.programmeTileBackGlow), glowColor.opacity(0)],
                center: .center,
                startRadius: 0,
                endRadius: ProfileV3Theme.Sizes.ProgrammeTile.backGlowRadius
            )
            VStack(spacing: ProfileV3Theme.Space.s12) {
                Text(programme.holderName ?? programme.name)
                    .typoGraphy(.H5InterSemibold20)
                    .foregroundStyle(Color(at: .pureWhite))
                if let number = programme.displayNumber {
                    Text(number)
                        .typoGraphy(.T1InterBold11)
                        .textCase(.uppercase)
                        .foregroundStyle(ProfileV3Theme.Palette.programmeTileBackNumber)
                }
            }
        }
        .clipShape(shape)
    }

    @ViewBuilder
    private var art: some View {
        if let url = programme.artURL {
            ProfileV3RemoteImage(url: url, contentMode: .fill, placeholder: .clear) { image in
                guard image.size.width > 0, image.size.height > 0 else { return }
                artAspect = image.size.width / image.size.height
            }
        }
    }

    private var glowColor: Color { ProfileV3Theme.Palette.programmeTileBackGlow }
}

private struct ProfileV3ProgrammeTilePill: View {
    let title: String
    var showsChevron = false
    var isLoading = false
    var shade: ProfileV3Theme.CardShade = .light
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfileV3Theme.Sizes.ProgrammeTile.pillSpacing) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(shade.primary)
                        .frame(
                            width: ProfileV3Theme.Icon.md,
                            height: ProfileV3Theme.Icon.md
                        )
                }
                Text(title)
                    .typoGraphy(.B2InterSemibold12)
                    .foregroundStyle(shade.primary)
                if showsChevron {
                    ATIcon.SwiftUIImage.chevronRight
                        .profileV3Icon(ProfileV3Theme.Icon.md)
                        .foregroundStyle(shade.primary)
                }
            }
            .padding(.leading, ProfileV3Theme.Space.s12)
            .padding(
                .trailing,
                showsChevron
                    ? ProfileV3Theme.Space.s6
                    : ProfileV3Theme.Space.s12
            )
            .frame(height: ProfileV3Theme.Control.compact)
            .profileV3CapsuleChrome(
                fill: shade.pill,
                border: shade.pillBorder,
                lineWidth: ProfileV3Theme.Stroke.fine,
                shadowRadius: 0,
                shadowY: 0
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .accessibilityLabel(title)
    }
}

private struct ProfileV3ProgrammeDotGrid: View {
    let color: Color

    var body: some View {
        let rows = ProfileV3Theme.Counts.programmeTileDotRows
        let columns = ProfileV3Theme.Counts.programmeTileDotColumns
        let pitch = ProfileV3Theme.Sizes.ProgrammeTile.dotPitch
        let rowPitch = ProfileV3Theme.Sizes.ProgrammeTile.dotRowPitch
        let dot = ProfileV3Theme.Sizes.ProgrammeTile.dot
        Canvas { context, _ in
            for row in 0..<rows {
                for column in 0..<columns {
                    let horizontal = 1 - Double(column) / Double(columns)
                    let floor = ProfileV3Theme.Opacity.programmeTileDotFloor
                    let vertical = floor + (1 - floor) * Double(row + 1) / Double(rows)
                    let rect = CGRect(x: CGFloat(column) * pitch, y: CGFloat(row) * rowPitch, width: dot, height: dot)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(
                            color.opacity(ProfileV3Theme.Opacity.programmeTileDotPeak * horizontal * vertical)
                        )
                    )
                }
            }
        }
        .frame(width: CGFloat(columns) * pitch, height: CGFloat(rows - 1) * rowPitch + dot)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#if DEBUG
private struct ProfileV3ProgrammeTilePreview: View {
    @State private var isFlipped = false

    var body: some View {
        VStack(spacing: ProfileV3Theme.Space.s20) {
            ProfileV3ProgrammeTile(
                programme: ProfileV3ProgrammeFixtures.overview(for: ProfileV3Fixtures.worldPass).featured[0],
                showsInsight: true,
                pill: .insight(isLoading: false),
                isFlipped: isFlipped,
                onTap: { withAnimation(ProfileV3Theme.Motion.flip) { isFlipped.toggle() } },
                onAction: {}
            )
            ProfileV3ProgrammeTile(
                programme: ProfileV3Fixtures.programmes[0],
                pill: .remove(isRemoving: false),
                onRemove: {}
            )
        }
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
    }
}

#Preview("Programme tile") {
    ProfileV3ProgrammeTilePreview()
}
#endif
