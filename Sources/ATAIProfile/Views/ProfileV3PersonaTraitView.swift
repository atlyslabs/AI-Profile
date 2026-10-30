import ATUIKit
import SwiftUI

struct ProfileV3PersonaTraitView: View {
    @ObservedObject var viewModel: ProfileV3PersonaTraitViewModel
    var avatarURL: URL?
    let onBack: () -> Void

    @State private var headerPin = ProfileV3HeaderPin()

    var body: some View {
        ZStack(alignment: .top) {
            if let trait = viewModel.content {
                ScrollView(showsIndicators: false) {
                    ProfileV3PersonaTraitContent(trait: trait, viewModel: viewModel, avatarURL: avatarURL)
                        .profileV3ScrollOffsetAnchor(headerPin.offsetBinding)
                }
                .profileV3ScrollOffset(headerPin.offsetBinding)
            } else {
                ProfileV3LoadStateView(phase: viewModel.phase, retry: viewModel.load)
                    .padding(.top, ProfileV3AgentSheetHeader.height(showsOrb: false))
            }
            ProfileV3AgentStickyHeader(tag: "", pin: headerPin, onBack: onBack)
        }
        .profileV3BottomToast(viewModel.toast, isError: true)
        .background(Color(at: .pureWhite))
    }

}

struct ProfileV3PersonaTraitContent: View {
    let trait: ProfileV3PersonaTrait
    @ObservedObject var viewModel: ProfileV3PersonaTraitViewModel
    var avatarURL: URL?

    private typealias Persona = ProfileV3Theme.Sizes.Persona

    var body: some View {
        loaded(trait)
    }

    private func loaded(_ trait: ProfileV3PersonaTrait) -> some View {
        VStack(spacing: 0) {
            scoreCard(trait)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, ProfileV3AgentSheetHeader.height(showsOrb: false) + Persona.detailTop)
            calculationHeader(trait)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, Persona.calculationTop)
            rows(trait)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, Persona.rowsTop)
        }
        .padding(.bottom, Persona.bottom)
    }

    private func scoreCard(_ trait: ProfileV3PersonaTrait) -> some View {
        VStack(spacing: 0) {
            Text(trait.title)
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(ProfileV3Theme.Palette.personaInk)
                .padding(.top, Persona.detailNameTop)
            Text("\(trait.score)")
                .typoGraphy(.D2InterMedium40)
                .foregroundStyle(ProfileV3Theme.Palette.personaInk)
                .contentTransition(.numericText())
                .padding(.top, Persona.detailScoreTop)
            if !trait.subtitle.isEmpty {
                Text(trait.subtitle)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey400))
                    .multilineTextAlignment(.center)
                    .frame(width: Persona.detailSubtitleWidth)
                    .padding(.top, Persona.detailSubtitleTop)
            }
            Spacer(minLength: ProfileV3Theme.Space.s24)
            scale(trait.scale)
                .padding(.bottom, Persona.scaleBottom)
        }
        .frame(maxWidth: .infinity, minHeight: Persona.detailCardHeight)
        .background(ProfileV3BoxGradientCard(gradient: ProfileV3Theme.personaCardGradient, cornerRadius: Persona.cardRadius))
        .accessibilityElement(children: .combine)
    }

    private func scale(_ scale: ProfileV3PersonaTrait.Scale) -> some View {
        let fill = Persona.scaleWidth * CGFloat(scale.fraction)
        return VStack(spacing: Persona.scaleLabelsTop) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(ProfileV3Theme.Palette.sliderTrack)
                    .frame(height: ProfileV3Theme.Sizes.sliderTrackHeight)
                Capsule()
                    .fill(ProfileV3Theme.personaScaleFill)
                    .frame(width: fill, height: ProfileV3Theme.Sizes.sliderTrackHeight)
                ProfileV3PersonaArt.scaleMidpoint.image
                    .resizable()
                    .frame(width: Persona.scaleMidpoint, height: Persona.scaleMidpoint)
                    .position(x: Persona.scaleWidth / 2, y: Persona.scaleKnob / 2)
                ProfileV3PersonaArt.scaleKnob.image
                    .resizable()
                    .frame(width: Persona.scaleKnob, height: Persona.scaleKnob)
                    .position(x: fill, y: Persona.scaleKnob / 2)
            }
            .frame(width: Persona.scaleWidth, height: Persona.scaleKnob)
            scaleLabels(scale)
                .frame(width: Persona.scaleWidth)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(scale.labels.joined(separator: ", "))
        .accessibilityValue("\(scale.value)")
    }

    @ViewBuilder
    private func scaleLabels(_ scale: ProfileV3PersonaTrait.Scale) -> some View {
        let active = scale.activeLabelIndex
        ZStack {
            ForEach(Array(scale.labels.enumerated()), id: \.offset) { index, label in
                Text(label)
                    .typoGraphy(.B2InterSemibold12)
                    .foregroundStyle(index == active ? Color(at: .neutralGrey800) : Color(at: .neutralGrey400))
                    .frame(maxWidth: .infinity, alignment: labelAlignment(index, count: scale.labels.count))
            }
        }
    }

    private func labelAlignment(_ index: Int, count: Int) -> Alignment {
        if index == 0 { return .leading }
        if index == count - 1 { return .trailing }
        return .center
    }

    private func calculationHeader(_ trait: ProfileV3PersonaTrait) -> some View {
        HStack(alignment: .top, spacing: ProfileV3Theme.Space.s16) {
            Text(trait.calculationTitle)
                .typoGraphy(.H7InterMedium16)
                .foregroundStyle(Color(at: .backgroundDarkTheme))
                .frame(width: Persona.calculationTitleWidth, alignment: .leading)
            Spacer(minLength: 0)
            if viewModel.isEditable, let bulk = trait.bulk {
                actionPill(bulk, id: ProfileV3PersonaTraitViewModel.bulkID)
            }
            ProfileV3RemoteImage(url: avatarURL, placeholder: Color(at: .neutralGrey200))
                .frame(width: Persona.calculationOrb, height: Persona.calculationOrb)
                .clipShape(Circle())
                .accessibilityHidden(true)
        }
    }

    private func rows(_ trait: ProfileV3PersonaTrait) -> some View {
        LazyVStack(spacing: Persona.rowGap) {
            ForEach(Array(trait.rows.enumerated()), id: \.element.id) { index, row in
                rowView(row, connectsBelow: index < trait.rows.count - 1)
            }
            if trait.nextPage != nil {
                ProfileV3PagingFooter(
                    hasFailed: viewModel.loadMoreFailed,
                    page: trait.rows.count,
                    loadMore: viewModel.loadMore,
                    retry: viewModel.retryLoadMore
                )
            }
            if let start = trait.startingPoint {
                startingPointRow(start)
            }
        }
    }

    private func rowView(_ row: ProfileV3PersonaTrait.Row, connectsBelow: Bool) -> some View {
        HStack(alignment: .top, spacing: Persona.rowSpacing) {
            VStack(spacing: 0) {
                icon(row.kind == .gmail ? .gmail : .edited)
                    .opacity(row.isIgnored ? ProfileV3Theme.Opacity.personaIgnored : 1)
                if connectsBelow {
                    ProfileV3PersonaConnector()
                        .padding(.top, Persona.connectorTop)
                        .padding(.bottom, Persona.connectorBottom - Persona.rowGap)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            VStack(alignment: .leading, spacing: Persona.rowGap) {
                HStack(alignment: .top, spacing: ProfileV3Theme.Space.s12) {
                    VStack(alignment: .leading, spacing: Persona.rowSubtitleTop) {
                        Text(row.title)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(ProfileV3Theme.tagGradient)
                        if !row.subtitle.isEmpty {
                            Text(row.subtitle)
                                .typoGraphy(.T1InterRegular11)
                                .foregroundStyle(Color(at: .neutralGrey600))
                                .frame(maxWidth: Persona.rowSubtitleWidth, alignment: .leading)
                        }
                    }
                    .opacity(row.isIgnored ? ProfileV3Theme.Opacity.personaIgnored : 1)
                    Spacer(minLength: 0)
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(row.deltaLabel)
                            .typoGraphy(.B1InterSemibold14)
                            .foregroundStyle(deltaColor(row))
                            .strikethrough(row.isIgnored)
                        Spacer(minLength: ProfileV3Theme.Space.s12)
                        if viewModel.isEditable, let action = row.action {
                            actionPill(action, id: row.id)
                        }
                    }
                }
                .frame(minHeight: Persona.rowMinHeight, alignment: .top)
                ProfileV3DashedDivider()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .contain)
    }

    private func startingPointRow(_ start: ProfileV3PersonaTrait.StartingPoint) -> some View {
        HStack(alignment: .top, spacing: Persona.rowSpacing) {
            icon(.flag)
            VStack(alignment: .leading, spacing: Persona.rowSubtitleTop) {
                Text(start.title)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(ProfileV3Theme.tagGradient)
                if !start.subtitle.isEmpty {
                    Text(start.subtitle)
                        .typoGraphy(.T1InterRegular11)
                        .foregroundStyle(Color(at: .neutralGrey600))
                }
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private func icon(_ art: ProfileV3PersonaArt) -> some View {
        Circle()
            .fill(ProfileV3Theme.Palette.sourceTile)
            .frame(width: Persona.rowIcon, height: Persona.rowIcon)
            .overlay {
                art.image
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: art == .gmail ? Persona.rowGmailGlyph.width : Persona.rowGlyph,
                        height: art == .gmail ? Persona.rowGmailGlyph.height : Persona.rowGlyph
                    )
            }
            .accessibilityHidden(true)
    }

    private func deltaColor(_ row: ProfileV3PersonaTrait.Row) -> Color {
        if row.isIgnored { return Color(at: .neutralGrey400) }
        return row.delta > 0 ? Color(at: .accentEmerald500) : Color(at: .neutralGrey800)
    }

    private func actionPill(_ action: ProfileV3PersonaTrait.Action, id: String) -> some View {
        let isBusy = viewModel.busyActionIDs.contains(id)
        return Button { viewModel.perform(action, id: id) } label: {
            Text(action.label)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .backgroundDarkTheme))
                .padding(.horizontal, Persona.pillHorizontal)
                .padding(.vertical, Persona.pillVertical)
                .profileV3Outlined(Capsule(), border: ProfileV3Theme.Palette.personaPillBorder)
                .contentShape(Capsule())
        }
        .buttonStyle(.profileV3Pressable)
        .disabled(isBusy)
        .opacity(isBusy ? ProfileV3Theme.Opacity.disabled : 1)
    }
}

private struct ProfileV3PersonaConnector: View {
    var body: some View {
        ProfileV3DashedRule(
            color: ProfileV3Theme.Palette.dashedRule,
            dash: ProfileV3Theme.Sizes.Persona.connectorDash,
            axis: .vertical
        )
        .frame(maxHeight: .infinity)
    }
}

#if DEBUG
#Preview("Persona trait") {
    let viewModel = ProfileV3PersonaTraitViewModel(traitID: "adventure", profileID: "main", repository: ProfileV3MockRepository())
    viewModel.load()
    return ProfileV3PersonaTraitView(viewModel: viewModel, avatarURL: ProfileV3PlaceholderArt.agentPersonal.url, onBack: {})
}
#endif
