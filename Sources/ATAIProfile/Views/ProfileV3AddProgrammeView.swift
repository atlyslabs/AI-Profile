import ATUIKit
import SwiftUI

struct ProfileV3AddProgrammeView: View {
    enum Presentation {
        case fullScreen
        case loader
        case sheet
    }

    @ObservedObject var viewModel: ProfileV3AddProgrammeViewModel
    var presentation: Presentation = .fullScreen
    var maxHeight: CGFloat = ProfileV3Theme.Sizes.sheetFallbackHeight
    var bottomInset: CGFloat = 0
    @State private var sheetContentHeight: CGFloat = 0
    @State private var cardTaps = 0
    @State private var cardContinues = 0

    var body: some View {
        Group {
            switch presentation {
            case .fullScreen, .loader: fullScreenBody
            case .sheet: sheetBody
            }
        }
        .animation(ProfileV3Theme.Motion.contentFade, value: viewModel.stage)
        .sensoryFeedback(.impact(weight: .light), trigger: cardTaps)
        .sensoryFeedback(.impact(weight: .medium), trigger: cardContinues)
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.didAdd) { _, didAdd in didAdd }
        .sensoryFeedback(.impact(weight: .light), trigger: scanFoundCount) { old, new in new > old }
        .sensoryFeedback(.success, trigger: viewModel.stage) { _, stage in
            if case .found = stage { return true }
            return false
        }
        .sensoryFeedback(.error, trigger: viewModel.saveError) { _, error in error != nil }
        .profileV3TapToDismissKeyboard()
    }

    private var scanFoundCount: Int {
        if case .scanning(_, let foundCount) = viewModel.stage { return foundCount }
        return 0
    }

    private var drawsSheet: Bool { presentation == .fullScreen && viewModel.stage.isSheet }

    private var sheetContentFrameHeight: CGFloat? {
        guard sheetContentHeight > 0 else { return nil }
        return min(sheetContentHeight, max(0, maxHeight - bottomInset))
    }

    private var sheetBody: some View {
        panelContent
            .frame(maxWidth: .infinity, alignment: .top)
            .frame(height: sheetContentFrameHeight, alignment: .top)
            .profileV3KeyboardLift(bottomInset: bottomInset)
            .background(Color(at: .pureWhite))
            .task { await viewModel.start() }
    }

    private var fullScreenBody: some View {
        GeometryReader { proxy in
            let insets = proxy.safeAreaInsets
            let size = proxy.size
            let top = panelTop(insets: insets, size: size)
            let screenBottom = size.height + insets.bottom
            let radius = drawsSheet ? ProfileV3Theme.Sizes.sheetCornerRadius : 0
            ZStack(alignment: .top) {
                backdrop
                if viewModel.stage.isOverlay {
                    kycOverlay
                        .transition(.opacity)
                } else {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(Color(at: .pureWhite))
                        .frame(width: size.width, height: screenBottom - top)
                        .position(x: size.width / 2, y: top + (screenBottom - top) / 2)
                    if presentation == .fullScreen || !viewModel.stage.isSheet {
                        panelContent
                            .frame(width: size.width, height: size.height - top)
                            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
                            .position(x: size.width / 2, y: top + (size.height - top) / 2)
                    }
                }
                if viewModel.showsCloseButton {
                    ProfileV3CloseBar(action: viewModel.close)
                        .transition(.opacity)
                }
            }
            .animation(ProfileV3Theme.Motion.hero, value: top)
        }
        .task { await viewModel.start() }
    }

    private func panelTop(insets: EdgeInsets, size: CGSize) -> CGFloat {
        guard drawsSheet else { return -insets.top }
        guard sheetContentHeight > 0 else { return size.height }
        return max(ProfileV3Theme.Space.s28, size.height - sheetContentHeight)
    }

    @ViewBuilder
    private var backdrop: some View {
        switch viewModel.stage {
        case .kycRequired:
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(ProfileV3Theme.Palette.frostedBackdrop)
                .ignoresSafeArea()
        case .pick where drawsSheet, .details where drawsSheet:
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(ProfileV3Theme.Palette.sheetDim)
                .ignoresSafeArea()
        case .scanning, .found, .failed, .pick, .details:
            Color.clear
        }
    }

    @ViewBuilder
    private var panelContent: some View {
        switch viewModel.stage {
        case .scanning(let activity, let foundCount):
            scanning(activity: activity, foundCount: foundCount)
        case .found(let count):
            found(count: count)
        case .failed:
            failed
        case .pick:
            sheet(title: ProfileV3Strings.pickLoyaltyProgramme, onBack: nil) { pickContent }
        case .details:
            sheet(title: detailsTitle, onBack: viewModel.backToPick) { detailsContent }
        case .kycRequired:
            EmptyView()
        }
    }

    // MARK: - KYC required

    private var kycOverlay: some View {
        ProfileV3KYCRedirectOverlay(
            message: ProfileV3Strings.addProgrammeKYCRequired,
            centreToCopy: ProfileV3Theme.Sizes.AddProgramme.kycOrbToCopy,
            bottomSpace: ProfileV3Theme.Sizes.AddProgramme.kycBottom
        ) {
            ProfileV3AtlysOrb(ring: .scanning)
        }
    }

    // MARK: - Scanning / found / failed

    private func scanning(activity: String, foundCount: Int) -> some View {
        VStack(spacing: ProfileV3Theme.Sizes.AddProgramme.titleToStatus) {
            VStack(spacing: ProfileV3Theme.Sizes.AddProgramme.orbToTitle) {
                ProfileV3AtlysOrb(ring: .scanning)
                ProfileV3TwoToneTitle(
                    lead: ProfileV3Strings.scanningLead,
                    emphasis: ProfileV3Strings.scanningEmphasis,
                    style: .H5InterMedium20,
                    leadColor: Color(at: .neutralGrey500)
                )
            }
            VStack(spacing: ProfileV3Theme.Space.s14) {
                ProfileV3GradientStatusText(text: activity)
                HStack(spacing: ProfileV3Theme.Space.s12) {
                    HStack(spacing: ProfileV3Theme.Sizes.AddProgramme.sourceOverlap) {
                        sourceIcon(ProfileV3AgentArt.sourceGoogle.url)
                        sourceIcon(ProfileV3AgentArt.sourceEmail.url)
                    }
                    Text(ProfileV3Strings.foundProgrammesLine(foundCount))
                        .typoGraphy(.B2InterSemibold12)
                        .foregroundStyle(Color(at: .neutralGrey500))
                        .contentTransition(.numericText())
                        .animation(ProfileV3Theme.Motion.selection, value: foundCount)
                }
                .opacity(foundCount > 0 ? 1 : 0)
                .accessibilityHidden(foundCount == 0)
                .animation(ProfileV3Theme.Motion.selection, value: foundCount > 0)
            }
        }
        .frame(width: ProfileV3Theme.Sizes.AddProgramme.copyWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: ProfileV3Theme.Sizes.AddProgramme.scanningOffsetY)
        .transition(.opacity)
        .accessibilityElement(children: .combine)
    }

    private func sourceIcon(_ url: URL?) -> some View {
        ProfileV3RemoteImage(url: url, placeholder: .clear)
            .frame(width: ProfileV3Theme.Icon.md, height: ProfileV3Theme.Icon.md)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }

    private func found(count: Int) -> some View {
        VStack(spacing: ProfileV3Theme.Sizes.AddProgramme.titleToStatus) {
            ProfileV3AtlysOrb(ring: .found)
            VStack(spacing: 0) {
                Text(ProfileV3Strings.foundLead)
                    .foregroundStyle(Color(at: .neutralGrey500))
                Text(ProfileV3Strings.foundProgrammes(count))
                    .foregroundStyle(Color(at: .pureBlack))
            }
            .typoGraphy(.H5InterMedium20)
            .multilineTextAlignment(.center)
        }
        .frame(width: ProfileV3Theme.Sizes.AddProgramme.copyWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: ProfileV3Theme.Sizes.AddProgramme.foundOffsetY)
        .transition(.opacity)
        .accessibilityElement(children: .combine)
    }

    private var failed: some View {
        ProfileV3LoadStateView(phase: .failed, retry: viewModel.retry)
            .transition(.opacity)
    }

    // MARK: - Sheet

    private func sheet<Content: View>(
        title: String,
        onBack: (() -> Void)?,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let stack = VStack(spacing: 0) {
            ProfileV3SheetChrome(
                icon: ATIcon.SwiftUIImage.star,
                title: title,
                onBack: onBack,
                onClose: viewModel.close
            )
            ProfileV3StepIndicator(count: ProfileV3Theme.Counts.addProgrammeSteps, current: viewModel.stepIndex)
                .padding(.top, ProfileV3Theme.Space.s12)
            content()
        }
        .padding(.bottom, ProfileV3Theme.Space.s16)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { sheetContentHeight = $0 }

        let needsScroll = presentation != .sheet
            || (sheetContentHeight > 0 && sheetContentHeight + bottomInset > maxHeight)
        return Group {
            if needsScroll {
                ScrollView(showsIndicators: false) {
                    stack
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollDismissesKeyboard(.interactively)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                stack
            }
        }
        .transition(.opacity)
    }

    private var emptyState: some View {
        ProfileV3EmptyState(
            icon: ATIcon.SwiftUIImage.search,
            title: ProfileV3Strings.noProgrammesTitle,
            subtitle: viewModel.query.isEmpty
                ? ProfileV3Strings.noProgrammesInCategory
                : ProfileV3Strings.noProgrammesMatch,
            iconGap: ProfileV3Theme.Space.s8
        )
        .frame(width: ProfileV3Theme.Sizes.emptyStateTextWidth)
        .frame(maxWidth: .infinity)
        .frame(height: ProfileV3Theme.Sizes.Picker.cardHeight)
        .padding(.top, ProfileV3Theme.Sizes.AddProgramme.cardsTop)
    }

    private var pickContent: some View {
        VStack(spacing: 0) {
            SettingsSearchField(placeholder: ProfileV3Strings.search, text: $viewModel.query)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, ProfileV3Theme.Space.s40)
            if viewModel.filters.count > 1 {
                categoryChips
                    .padding(.top, ProfileV3Theme.Space.s24)
            }
            ZStack(alignment: .top) {
                if viewModel.isLoadingCatalogue {
                    catalogueLoader
                } else if viewModel.catalogueFailed {
                    catalogueFailed
                } else if viewModel.filteredCatalogue.isEmpty {
                    emptyState
                        .transition(.opacity)
                } else {
                    cardCarousel
                        .padding(.top, ProfileV3Theme.Sizes.AddProgramme.cardsTop)
                        .transition(.opacity)
                }
            }
            .animation(ProfileV3Theme.Motion.contentFade, value: viewModel.isLoadingCatalogue)
            ctaBar(error: nil) {
                ProfileV3ContinueButton(isEnabled: viewModel.canContinuePick, action: viewModel.continueFromPick)
            }
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ProfileV3Theme.Space.s12) {
                ForEach(viewModel.filters) { filter in
                    ProfileV3FilterChip(title: filter.label, isSelected: viewModel.isSelected(filter)) {
                        viewModel.selectFilter(filter)
                    }
                }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        }
    }

    private var catalogueLoader: some View {
        ProfileV3Spinner()
            .accessibilityLabel(ProfileV3Strings.loading)
            .frame(maxWidth: .infinity)
            .frame(height: ProfileV3Theme.Sizes.Picker.cardHeight)
            .padding(.top, ProfileV3Theme.Sizes.AddProgramme.cardsTop)
            .transition(.opacity)
    }

    private var catalogueFailed: some View {
        ProfileV3StatusPanel(
            title: ProfileV3Strings.loadFailedTitle,
            subtitle: ProfileV3Strings.loadFailedSubtitle,
            actionTitle: ProfileV3Strings.retry,
            action: viewModel.retry
        )
        .frame(maxWidth: .infinity)
        .frame(minHeight: ProfileV3Theme.Sizes.Picker.cardHeight)
        .padding(.top, ProfileV3Theme.Sizes.AddProgramme.cardsTop)
        .transition(.opacity)
    }

    private var cardCarousel: some View {
        ProfileV3CentredCarousel(
            itemWidth: ProfileV3Theme.Sizes.Picker.cardWidth,
            height: ProfileV3Theme.Sizes.Picker.cardHeight,
            spacing: ProfileV3Theme.Sizes.Picker.cardSpacing,
            selection: $viewModel.selectedItemID,
            revealOffset: ProfileV3Theme.Motion.entryOffsetY
        ) {
            ForEach(viewModel.filteredCatalogue) { item in
                Button {
                    if viewModel.selectItem(item.id) {
                        cardTaps += 1
                    } else if viewModel.canContinuePick {
                        cardContinues += 1
                        viewModel.continueFromPick()
                    }
                } label: {
                    ProfileV3ProgrammePickerCard(
                        item: item,
                        isSelected: viewModel.selectedItemID == item.id
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var detailsTitle: String {
        viewModel.entryForm?.title ?? ProfileV3Strings.enterDetails
    }

    private var detailsContent: some View {
        VStack(spacing: 0) {
            Text(viewModel.selectedItem?.name ?? "")
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .multilineTextAlignment(.center)
                .padding(.top, ProfileV3Theme.Space.s40)
            ZStack(alignment: .top) {
                if viewModel.entryForm != nil {
                    entryFields
                        .transition(.opacity)
                } else if viewModel.entryFormFailed {
                    entryFormFailed
                } else {
                    entryFormLoader
                }
            }
            .animation(ProfileV3Theme.Motion.contentFade, value: viewModel.entryForm)
            ctaBar(error: viewModel.saveError) {
                ProfileV3ContinueButton(
                    isLoading: viewModel.isSaving,
                    isEnabled: viewModel.canSubmit,
                    action: viewModel.submit
                )
            }
        }
    }

    private var entryFields: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.AddProgramme.fieldSpacing) {
            ForEach(viewModel.entryFields) { entry in
                if entry.key == ProfileV3LoyaltyEntryForm.Field.pointsKey {
                    field(label: entry.label, text: $viewModel.points, keyboard: .numberPad)
                } else {
                    field(label: entry.label, text: $viewModel.membershipNumber, keyboard: .asciiCapable)
                }
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, ProfileV3Theme.Sizes.AddProgramme.fieldsTop)
    }

    private var entryFormLoader: some View {
        ProfileV3Spinner()
            .accessibilityLabel(ProfileV3Strings.loading)
            .frame(maxWidth: .infinity)
            .padding(.top, ProfileV3Theme.Sizes.AddProgramme.fieldsTop)
            .transition(.opacity)
    }

    private var entryFormFailed: some View {
        ProfileV3StatusPanel(
            title: ProfileV3Strings.loadFailedTitle,
            subtitle: ProfileV3Strings.loadFailedSubtitle,
            actionTitle: ProfileV3Strings.retry,
            action: viewModel.retryEntryForm
        )
        .frame(maxWidth: .infinity)
        .padding(.top, ProfileV3Theme.Sizes.AddProgramme.fieldsTop)
        .transition(.opacity)
    }

    private func field(label: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s14) {
            ProfileV3TagLabel(text: label)
                .accessibilityHidden(true)
            ProfileV3UnderlinedField(
                placeholder: ProfileV3Strings.typeHere,
                accessibilityLabel: label,
                text: text,
                keyboard: keyboard,
                width: nil
            )
        }
    }

    private func ctaBar<Button: View>(error: String?, @ViewBuilder button: () -> Button) -> some View {
        VStack(spacing: ProfileV3Theme.Space.s12) {
            if let error {
                Text(error)
                    .typoGraphy(.T1InterBold11)
                    .foregroundStyle(ProfileV3Theme.Palette.error)
                    .multilineTextAlignment(.center)
            }
            button()
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, ProfileV3Theme.Space.s32)
    }
}

#if DEBUG
#Preview("Add programme · KYC pending") {
    ProfileV3AddProgrammeView(
        viewModel: ProfileV3AddProgrammeViewModel(requiresKYC: true, repository: ProfileV3MockRepository())
    )
}

#Preview("Add programme") {
    ProfileV3AddProgrammeView(
        viewModel: ProfileV3AddProgrammeViewModel(requiresKYC: false, repository: ProfileV3MockRepository())
    )
}

#Preview("Add programme · failed") {
    ProfileV3AddProgrammeView(
        viewModel: ProfileV3AddProgrammeViewModel(requiresKYC: false, repository: ProfileV3FailingRepository())
    )
}

#Preview("Add programme · picker sheet") {
    ProfileV3AddProgrammeView(viewModel: .preview(.pick), presentation: .sheet)
}

#Preview("Add programme · catalogue loading") {
    ProfileV3AddProgrammeView(viewModel: .preview(.pick, isLoadingCatalogue: true), presentation: .sheet)
}

#Preview("Add programme · no matches") {
    ProfileV3AddProgrammeView(viewModel: .preview(.pick, query: "Zephyr"), presentation: .sheet)
}

#Preview("Add programme · details") {
    ProfileV3AddProgrammeView(viewModel: .preview(.details, membershipNumber: "739154"), presentation: .sheet)
}

#Preview("Add programme · save failed") {
    ProfileV3AddProgrammeView(
        viewModel: .preview(.details, membershipNumber: "739154", saveError: ProfileV3Strings.addProgrammeFailed),
        presentation: .sheet
    )
}
#endif
