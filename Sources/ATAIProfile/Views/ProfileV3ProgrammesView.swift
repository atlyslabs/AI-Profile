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
    @State private var demoTileHeights: [String: CGFloat] = [:]
    @State private var headerPin = ProfileV3HeaderPin()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var tileWidth: CGFloat {
        max(0, width - 2 * ProfileV3Theme.Sizes.screenHorizontalMargin)
    }

    private var defaultTileHeight: CGFloat {
        tileWidth / ProfileV3Theme.Sizes.Programme.artAspectRatio
    }

    var body: some View {
        ZStack(alignment: .top) {
            content
            ProfileV3HeaderFade(pin: headerPin)
                .padding(.top, ProfileV3Theme.Sizes.topBarBackdropHeight)
            header
        }
        .overlay(alignment: .bottom) { bottomBar }
        .background(Color(at: .pureWhite))
        .onDrop(of: [.text], delegate: dropDelegate(for: .screen))
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .sensoryFeedback(.impact(weight: .light), trigger: tileTaps)
        .sensoryFeedback(.impact(weight: .light), trigger: passSwipes)
        .sensoryFeedback(.selection, trigger: viewModel.listOrder) { _, order in !order.isEmpty }
        .sensoryFeedback(.selection, trigger: viewModel.selectedIDs)
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.deletions)
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
            .profileV3HeaderFadeAnchor(headerPin)
        }
        .profileV3ScrollOffset(headerPin.offsetBinding)
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
            if viewModel.isEditing {
                selectionList
                    .padding(.top, ProfileV3Theme.Sizes.Programmes.cardsTop)
                    .transition(.opacity)
            } else {
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
        }
        .onAppear { revealsTiles = true }
    }

    private var selectionList: some View {
        VStack(spacing: ProfileV3Theme.Sizes.Programmes.listSpacing) {
            ForEach(viewModel.editingProgrammes) { programme in
                selectableTile(programme)
            }
        }
    }

    private func selectableTile(_ programme: ProfileV3LoyaltyProgramme) -> some View {
        let isSelected = viewModel.selectedIDs.contains(programme.id)
        return Button {
            viewModel.toggleSelection(programme)
        } label: {
            HStack(spacing: ProfileV3Theme.Sizes.Programmes.checkboxGap) {
                ProfileV3CheckboxMark(isSelected: isSelected)
                ProfileV3ProgrammeTile(programme: programme, width: tileWidth)
                    .allowsHitTesting(false)
            }
            .padding(.leading, ProfileV3Theme.Sizes.Programmes.checkboxLeading)
            .frame(width: width, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isDeleting)
        .accessibilityLabel(programme.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func programmeList(firstOrder: Int) -> some View {
        LazyVStack(spacing: ProfileV3Theme.Sizes.Programmes.listSpacing) {
            ForEach(Array(viewModel.orderedOthers.enumerated()), id: \.element.id) { index, programme in
                tile(programme, width: nil, order: firstOrder + index)
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                        guard index < 2 else { return }
                        demoTileHeights[programme.id] = height
                    }
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
        let others = viewModel.orderedOthers
        guard isDemoSwapped, index < 2, others.count > 1 else { return 0 }
        let spacing = ProfileV3Theme.Sizes.Programmes.listSpacing
        let first = demoTileHeights[others[0].id] ?? defaultTileHeight
        let second = demoTileHeights[others[1].id] ?? defaultTileHeight
        return index == 0 ? second + spacing : -(first + spacing)
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
        Text(overview.summary)
            .typoGraphy(.T1InterMedium11)
            .foregroundStyle(Color(at: .neutralGrey400))
            .multilineTextAlignment(.center)
            .frame(maxWidth: ProfileV3Theme.Sizes.Programmes.headerWidth)
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
            onCopy: { viewModel.copiedNumber(of: programme) }
        )
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
        guard viewModel.showsInsights else { return .none }
        return .insight(isLoading: viewModel.loadingInsightID == programme.id)
    }

    private var skeletons: some View {
        VStack(spacing: ProfileV3Theme.Space.s16) {
            ProfileV3SkeletonCard(height: defaultTileHeight)
            ProfileV3SkeletonCard(height: defaultTileHeight)
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
        ZStack(alignment: .bottom) {
            if viewModel.isEditing {
                if !viewModel.selectedIDs.isEmpty {
                    ProfileV3ContinueButton(
                        title: ProfileV3Strings.deleteProgrammes(viewModel.selectedIDs.count),
                        tint: ProfileV3Theme.Palette.destructive,
                        isEnabled: !viewModel.isDeleting,
                        action: viewModel.tapDeleteSelected
                    )
                    .transition(.opacity.combined(with: .offset(y: ProfileV3Theme.Motion.insightRevealOffset)))
                }
            } else {
                HStack {
                    ProfileV3IconPillButton(
                        icon: ATIcon.SwiftUIImage.insertLink,
                        title: ProfileV3Strings.connectMoreProgrammes,
                        feedback: nil,
                        action: viewModel.tapConnectMore
                    )
                    Spacer()
                    ProfileV3IconPillButton(
                        icon: ATIcon.SwiftUIImage.edit,
                        iconOnlyWidth: ProfileV3Theme.Sizes.Programmes.editButtonWidth,
                        feedback: nil,
                        accessibilityLabel: ProfileV3Strings.editProgrammes,
                        action: viewModel.tapEdit
                    )
                    .disabled(viewModel.overview?.programmes.isEmpty ?? true)
                }
                .transition(.opacity)
            }
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

struct ProfileV3ProgrammesDeleteSheet: View {
    @ObservedObject var viewModel: ProfileV3ProgrammesViewModel
    let count: Int

    var body: some View {
        ProfileV3ConfirmationView.deleteProgrammes(
            count: count,
            isDeleting: viewModel.isDeleting,
            onBack: viewModel.cancelDelete,
            onConfirm: viewModel.confirmDelete
        )
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
