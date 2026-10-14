import ATUIKit
import SwiftUI
import UniformTypeIdentifiers

struct ProfileV3ProgrammesView: View {
    private enum ScrollTarget: Hashable {
        case reorderHint
    }

    @ObservedObject var viewModel: ProfileV3ProgrammesViewModel
    @State private var width: CGFloat = 0
    @State private var revealsTiles = false
    @State private var tileTaps = 0
    @State private var passSwipes = 0
    @State private var draggingID: String?
    @State private var hoveredDropTargets: Set<ProfileV3ProgrammeDropTarget> = []
    @State private var isDemoSwapped = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var tileWidth: CGFloat {
        max(0, width - 2 * ProfileV3Theme.Sizes.screenHorizontalMargin)
    }

    var body: some View {
        ZStack(alignment: .top) {
            content
            header
        }
        .overlay(alignment: .bottom) { bottomBar }
        .background(Color(at: .pureWhite))
        .onDrop(of: [.text], delegate: dropDelegate(for: .screen))
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .sensoryFeedback(.impact(weight: .light), trigger: tileTaps)
        .sensoryFeedback(.impact(weight: .light), trigger: passSwipes)
        .sensoryFeedback(.selection, trigger: viewModel.listOrder) { _, order in !order.isEmpty }
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.removingIDs) { old, new in
            new.count > old.count
        }
        .sensoryFeedback(.error, trigger: viewModel.actionFailures)
        .task { await viewModel.load(reducesMotion: reduceMotion) }
        .task(id: viewModel.showsReorderHint) { await playReorderDemo() }
    }

    private var content: some View {
        ScrollViewReader { proxy in
            scroll
                .onChange(of: viewModel.showsReorderHint) { _, shows in
                    guard shows else { return }
                    withAnimation(ProfileV3Theme.Motion.reorderHint) {
                        proxy.scrollTo(ScrollTarget.reorderHint, anchor: nil)
                    }
                }
        }
    }

    private var scroll: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                tabs
                    .frame(maxWidth: .infinity)
                    .overlay {
                        Color.clear
                            .frame(height: ProfileV3Theme.Sizes.Collapse.tabSwipeHeight)
                            .contentShape(Rectangle())
                            .simultaneousGesture(passSwipe)
                    }
                    .padding(.top, ProfileV3Theme.Sizes.Programmes.tabTop)
                if let actionError = viewModel.actionError {
                    Button(action: viewModel.clearActionError) {
                        Text(actionError)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(ProfileV3Theme.Palette.error)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.top, ProfileV3Theme.Space.s16)
                    .accessibilityHint(ProfileV3Strings.close)
                }
                switch viewModel.phase {
                case .loading:
                    skeletons
                case .failed:
                    failed
                case .content(let overview):
                    overviewContent(overview)
                        .transition(.opacity.combined(with: .offset(y: ProfileV3Theme.Motion.contentSwitchOffset)))
                }
            }
            .padding(.bottom, ProfileV3Theme.Sizes.Programmes.bottomFade)
        }
    }

    private var header: some View {
        HStack {
            ProfileV3CircleIconButton.back(size: ProfileV3Theme.Sizes.navButton, action: viewModel.tapBack)
            Spacer()
        }
        .overlay {
            Text(viewModel.overview?.holderName ?? viewModel.pass.holderName)
                .typoGraphy(.H6InterMedium18)
                .foregroundStyle(Color(at: .pureBlack))
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.topBarInset)
        .padding(.top, ProfileV3Theme.Sizes.topBarTop)
        .frame(height: ProfileV3Theme.Sizes.topBarBackdropHeight, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(Color(at: .pureWhite).ignoresSafeArea(edges: .top))
    }

    private var tabs: some View {
        let pitch = ProfileV3Theme.Sizes.Collapse.tabWidth + ProfileV3Theme.Sizes.Programmes.tabSpacing
        let centre = CGFloat(viewModel.passes.count - 1) / 2
        return HStack(spacing: ProfileV3Theme.Sizes.Programmes.tabSpacing) {
            ForEach(viewModel.passes) { _ in
                ProfileV3CollapsedTab()
            }
        }
        .offset(x: (centre - CGFloat(viewModel.selectedPassIndex)) * pitch)
        .frame(width: ProfileV3Theme.Sizes.Collapse.tabWidth, height: ProfileV3Theme.Sizes.Collapse.tabHeight)
    }

    private var passSwipe: some Gesture {
        DragGesture(minimumDistance: ProfileV3Theme.Sizes.Collapse.tabSwipeMinimum)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                let delta = value.translation.width < 0 ? 1 : -1
                if viewModel.selectPass(offsetBy: delta, reducesMotion: reduceMotion) {
                    passSwipes += 1
                }
            }
    }

    private func overviewContent(_ overview: ProfileV3ProgrammeOverview) -> some View {
        VStack(spacing: 0) {
            summary(overview)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .simultaneousGesture(passSwipe)
                .padding(.top, ProfileV3Theme.Sizes.Programmes.headerTop)
            if overview.programmes.isEmpty {
                emptyState
            }
            if !overview.featured.isEmpty {
                featuredCarousel(overview.featured)
                    .padding(.top, ProfileV3Theme.Sizes.Programmes.cardsTop)
                    .profileV3ReorderShift(viewModel.showsReorderHint)
                if !overview.others.isEmpty {
                    ProfileV3DashedDivider()
                        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                        .padding(.vertical, ProfileV3Theme.Space.s40)
                        .profileV3ReorderShift(viewModel.showsReorderHint)
                }
            }
            programmeList(firstOrder: overview.featured.count)
                .padding(.top, overview.featured.isEmpty ? ProfileV3Theme.Sizes.Programmes.cardsTop : 0)
        }
        .onAppear { revealsTiles = true }
    }

    private func programmeList(firstOrder: Int) -> some View {
        LazyVStack(spacing: ProfileV3Theme.Sizes.Programmes.listSpacing) {
            ForEach(Array(viewModel.orderedOthers.enumerated()), id: \.element.id) { index, programme in
                tile(programme, width: nil, order: firstOrder + index)
                    .offset(y: reorderDemoOffset(at: index))
                    .opacity(isDragPlaceholder(programme) ? ProfileV3Theme.Opacity.reorderPlaceholder : 1)
                    .onDrag {
                        draggingID = programme.id
                        hoveredDropTargets.removeAll()
                        return NSItemProvider(object: programme.id as NSString)
                    }
                    .onDrop(of: [.text], delegate: dropDelegate(for: .programme(programme.id)))
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .profileV3ReorderShift(viewModel.showsReorderHint)
        .overlay(alignment: .topLeading) { reorderHint }
    }

    private var reorderHint: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                ProfileV3Vector.swipeVertical.image
                    .profileV3Icon(ProfileV3Theme.Icon.xl)
                    .foregroundStyle(Color(at: .pureBlack))
                    .accessibilityHidden(true)
                Text(ProfileV3Strings.reorderProgrammesHint)
                    .typoGraphy(.H5InterMedium20)
                    .foregroundStyle(Color(at: .pureBlack))
                    .frame(width: ProfileV3Theme.Sizes.Programmes.reorderHintTextWidth, alignment: .leading)
                    .padding(.top, ProfileV3Theme.Sizes.Programmes.reorderHintTextTop)
                ProfileV3PillButton(title: ProfileV3Strings.gotIt, size: .medium, action: viewModel.dismissReorderHint)
                    .padding(.top, ProfileV3Theme.Sizes.Programmes.reorderHintButtonTop)
            }
            .padding(.leading, ProfileV3Theme.Sizes.Programmes.reorderHintLeading)
            .padding(.top, ProfileV3Theme.Sizes.Programmes.reorderHintTop)
            .opacity(viewModel.showsReorderHint ? 1 : 0)
            .allowsHitTesting(viewModel.showsReorderHint)
            .accessibilityHidden(!viewModel.showsReorderHint)
            Color.clear
                .frame(height: ProfileV3Theme.Sizes.Programmes.bottomFade)
                .allowsHitTesting(false)
        }
        .id(ScrollTarget.reorderHint)
    }

    private func reorderDemoOffset(at index: Int) -> CGFloat {
        guard isDemoSwapped, index < 2 else { return 0 }
        let step = ProfileV3Theme.Sizes.Programmes.reorderStep
        return index == 0 ? step : -step
    }

    private func playReorderDemo() async {
        guard viewModel.showsReorderHint, !reduceMotion else {
            if isDemoSwapped {
                withAnimation(ProfileV3Theme.Motion.reorderHint) { isDemoSwapped = false }
            }
            return
        }
        try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.reorderHintSeconds))
        for _ in 0..<ProfileV3Theme.Motion.reorderDemoSwaps {
            for swapped in [true, false] {
                guard !Task.isCancelled else { return }
                withAnimation(ProfileV3Theme.Motion.reorderDemoMove) { isDemoSwapped = swapped }
                try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.reorderDemoCycleSeconds))
            }
        }
    }

    private func isDragPlaceholder(_ programme: ProfileV3LoyaltyProgramme) -> Bool {
        draggingID == programme.id && !hoveredDropTargets.isEmpty
    }

    private func dropDelegate(for target: ProfileV3ProgrammeDropTarget) -> ProfileV3ProgrammeDropDelegate {
        ProfileV3ProgrammeDropDelegate(
            target: target,
            draggingID: $draggingID,
            hoveredTargets: $hoveredDropTargets,
            onMove: viewModel.moveProgramme,
            onDrop: viewModel.commitOrder
        )
    }

    private var emptyState: some View {
        VStack(spacing: ProfileV3Theme.Space.s12) {
            Text(ProfileV3Strings.noProgrammesConnectedTitle)
                .typoGraphy(.H7InterMedium16)
                .foregroundStyle(Color(at: .pureBlack))
            Text(ProfileV3Strings.noProgrammesConnectedBody)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(ProfileV3Theme.Palette.emptyStateTitle)
                .frame(maxWidth: ProfileV3Theme.Sizes.emptyStateTextWidth)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, ProfileV3Theme.Sizes.Programmes.cardsTop)
        .accessibilityElement(children: .combine)
    }

    private func summary(_ overview: ProfileV3ProgrammeOverview) -> some View {
        VStack(spacing: 0) {
            Text(ProfileV3Strings.programmeCount(overview.connectedCount))
                .typoGraphy(.H2InterSemibold32)
                .foregroundStyle(Color(at: .pureBlack))
                .contentTransition(.numericText())
            Text(ProfileV3Strings.programmesConnected)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .neutralGrey600))
                .padding(.top, ProfileV3Theme.Sizes.Programmes.countToLabel)
            Text(overview.summary)
                .typoGraphy(.T1InterMedium11)
                .foregroundStyle(Color(at: .neutralGrey400))
                .padding(.top, ProfileV3Theme.Sizes.Programmes.labelToSummary)
            stats(overview)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: ProfileV3Theme.Sizes.Programmes.headerWidth)
    }

    @ViewBuilder
    private func stats(_ overview: ProfileV3ProgrammeOverview) -> some View {
        let points = overview.pointsLabel.nonEmpty
        let estimated = overview.estimatedValueLabel.nonEmpty
        if points != nil || estimated != nil {
            HStack(spacing: ProfileV3Theme.Space.s32) {
                if let points { stat(points, label: ProfileV3Strings.pointsMiles) }
                if let estimated { stat(estimated, label: ProfileV3Strings.estimatedValue) }
            }
            .padding(.top, ProfileV3Theme.Space.s30)
        }
    }

    private func stat(_ value: String, label: String) -> some View {
        VStack(spacing: ProfileV3Theme.Sizes.Programmes.statValueToLabel) {
            Text(value)
                .typoGraphy(.H5InterSemibold20)
                .foregroundStyle(Color(at: .pureBlack))
            Text(label)
                .typoGraphy(.T1InterMedium11)
                .foregroundStyle(Color(at: .neutralGrey400))
        }
        .accessibilityElement(children: .combine)
    }

    private func featuredCarousel(_ programmes: [ProfileV3LoyaltyProgramme]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: ProfileV3Theme.Space.s16) {
                ForEach(Array(programmes.enumerated()), id: \.element.id) { index, programme in
                    tile(programme, width: tileWidth, order: index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin, for: .scrollContent)
        .scrollClipDisabled()
    }

    private func tile(_ programme: ProfileV3LoyaltyProgramme, width: CGFloat?, order: Int) -> some View {
        ProfileV3ProgrammeTile(
            programme: programme,
            width: width,
            showsInsight: viewModel.showsInsights,
            pill: pill(for: programme),
            isFlipped: viewModel.flippedID == programme.id,
            onTap: {
                if viewModel.tapTile(programme) {
                    tileTaps += 1
                }
            },
            onAction: { viewModel.tapInsight(programme) },
            onRemove: { viewModel.remove(programme) }
        )
        .profileV3OnImpression { viewModel.trackProgramme(programme, index: order) }
        .profileV3EntryReveal(
            revealsTiles,
            scale: ProfileV3Theme.Motion.tileEntryScale,
            offsetY: ProfileV3Theme.Motion.tileEntryOffsetY
        )
        .animation(
            reduceMotion
                ? nil
                : ProfileV3Theme.Motion.tileEntry.delay(Double(order) * ProfileV3Theme.Motion.tileEntryStaggerSeconds),
            value: revealsTiles
        )
    }

    private func pill(for programme: ProfileV3LoyaltyProgramme) -> ProfileV3ProgrammeTile.Pill {
        if viewModel.isEditing {
            return .remove(isRemoving: viewModel.removingIDs.contains(programme.id))
        }
        guard viewModel.showsInsights else { return .none }
        return .insight(isLoading: viewModel.loadingInsightID == programme.id)
    }

    private var skeletons: some View {
        VStack(spacing: ProfileV3Theme.Space.s16) {
            ProfileV3SkeletonCard(height: ProfileV3Theme.Sizes.ProgrammeTile.height)
            ProfileV3SkeletonCard(height: ProfileV3Theme.Sizes.ProgrammeTile.height)
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, ProfileV3Theme.Sizes.Programmes.headerTop + ProfileV3Theme.Sizes.Programmes.cardsTop)
    }

    private var failed: some View {
        ProfileV3RetryPanel(message: ProfileV3Strings.loadFailed) {
            viewModel.retry(reducesMotion: reduceMotion)
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, ProfileV3Theme.Sizes.Programmes.headerTop + ProfileV3Theme.Sizes.Programmes.cardsTop)
    }

    private var bottomBar: some View {
        HStack {
            ProfileV3BarButton(
                title: ProfileV3Strings.connectMoreProgrammes,
                icon: ATIcon.SwiftUIImage.insertLink,
                action: viewModel.tapConnectMore
            )
            Spacer()
            ProfileV3BarButton(
                icon: viewModel.isEditing ? ATIcon.SwiftUIImage.check : ATIcon.SwiftUIImage.edit,
                accessibilityLabel: viewModel.isEditing
                    ? ProfileV3Strings.doneEditing
                    : ProfileV3Strings.editProgrammes,
                action: viewModel.tapEdit
            )
            .disabled(viewModel.overview?.programmes.isEmpty ?? true)
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.bottom, ProfileV3Theme.Sizes.Programmes.barBottom)
        .frame(maxWidth: .infinity)
        .frame(height: ProfileV3Theme.Sizes.Programmes.bottomFade, alignment: .bottom)
        .background(ProfileV3Theme.programmesBottomFadeGradient.ignoresSafeArea(edges: .bottom))
    }
}

private enum ProfileV3ProgrammeDropTarget: Hashable {
    case screen
    case programme(String)
}

private struct ProfileV3ProgrammeDropDelegate: DropDelegate {
    let target: ProfileV3ProgrammeDropTarget
    @Binding var draggingID: String?
    @Binding var hoveredTargets: Set<ProfileV3ProgrammeDropTarget>
    let onMove: @MainActor (String, String) -> Void
    let onDrop: @MainActor () -> Void

    func validateDrop(info: DropInfo) -> Bool {
        draggingID != nil
    }

    func dropEntered(info: DropInfo) {
        hoveredTargets.insert(target)
        guard let draggingID, case .programme(let targetID) = target else { return }
        onMove(draggingID, targetID)
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        if !hoveredTargets.contains(target) {
            hoveredTargets.insert(target)
        }
        return DropProposal(operation: .move)
    }

    func dropExited(info: DropInfo) {
        hoveredTargets.remove(target)
    }

    func performDrop(info: DropInfo) -> Bool {
        hoveredTargets.removeAll()
        draggingID = nil
        onDrop()
        return true
    }
}

private extension View {
    func profileV3ReorderShift(_ isShifted: Bool) -> some View {
        offset(x: isShifted ? ProfileV3Theme.Sizes.Programmes.reorderShift : 0)
            .allowsHitTesting(!isShifted)
            .accessibilityHidden(isShifted)
    }
}

private struct ProfileV3BarButton: View {
    var title: String?
    let icon: Image
    var accessibilityLabel: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfileV3Theme.Sizes.Save.buttonSpacing) {
                icon
                    .profileV3Icon(ProfileV3Theme.Sizes.Save.buttonIcon)
                if let title {
                    Text(title)
                        .typoGraphy(.B1InterSemibold14)
                }
            }
            .foregroundStyle(Color(at: .pureBlack))
            .padding(.leading, title == nil ? 0 : ProfileV3Theme.Sizes.Save.buttonLeading)
            .padding(.trailing, title == nil ? 0 : ProfileV3Theme.Sizes.Save.buttonTrailing)
            .frame(width: title == nil ? ProfileV3Theme.Sizes.Programmes.editButtonWidth : nil)
            .frame(height: ProfileV3Theme.Sizes.Save.buttonHeight)
            .profileV3CapsuleChrome()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel ?? title ?? "")
    }
}

#if DEBUG
#Preview("Programmes") {
    ProfileV3ProgrammesView(
        viewModel: ProfileV3ProgrammesViewModel(
            pass: ProfileV3Fixtures.worldPass,
            passes: ProfileV3Fixtures.worldPasses,
            repository: ProfileV3MockRepository(delay: .milliseconds(200))
        )
    )
}

#Preview("Programmes · loading") {
    ProfileV3ProgrammesView(
        viewModel: ProfileV3ProgrammesViewModel(
            pass: ProfileV3Fixtures.worldPass,
            passes: ProfileV3Fixtures.worldPasses,
            repository: ProfileV3MockRepository(delay: .seconds(60))
        )
    )
}

#Preview("Programmes · failed") {
    ProfileV3ProgrammesView(
        viewModel: ProfileV3ProgrammesViewModel(
            pass: ProfileV3Fixtures.worldPass,
            passes: ProfileV3Fixtures.worldPasses,
            repository: ProfileV3FailingRepository()
        )
    )
}

#Preview("Programmes · empty") {
    ProfileV3ProgrammesView(
        viewModel: ProfileV3ProgrammesViewModel(
            pass: ProfileV3Fixtures.coTravellerPass,
            passes: ProfileV3Fixtures.worldPasses,
            repository: ProfileV3MockRepository(delay: .milliseconds(200))
        )
    )
}

#Preview("Programmes · editing") {
    ProfileV3ProgrammesView(viewModel: .preview(isEditing: true))
}

#Preview("Programmes · reorder hint") {
    ProfileV3ProgrammesView(viewModel: .preview(showsReorderHint: true))
}

#Preview("Programmes · refresh failed") {
    ProfileV3ProgrammesView(viewModel: .preview(repository: ProfileV3FailingRepository()))
}
#endif
