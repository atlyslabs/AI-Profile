import ATUIKit
import SwiftUI

struct ProfileV3AgentFormView: View {
    @ObservedObject var viewModel: ProfileV3AgentFormViewModel
    @State private var headerPin = ProfileV3HeaderPin()

    private var form: ProfileV3AgentForm { viewModel.form }

    var body: some View {
        NavigationStack {
            content
                .navigationDestination(isPresented: showsPicker) {
                    ProfileV3AgentOptionPicker(viewModel: viewModel)
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                }
                .navigationDestination(isPresented: showsSources) {
                    sectionSources
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                }
                .fullScreenCover(isPresented: $viewModel.showsPreviousPassports) {
                    previousPassports
                }
                .sheet(item: $viewModel.rideRegions) { regions in
                    ProfileV3RideRegionsView(viewModel: regions)
                        .presentationCornerRadius(ProfileV3Theme.Sizes.Agent.sheetCornerRadius)
                        .presentationDragIndicator(.hidden)
                }
                .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(isPresented: showsPassportReason) {
            passportReason
        }
        .sheet(item: $viewModel.airportPickup) { pickup in
            ProfileV3AirportPickupView(viewModel: pickup)
                .presentationDetents([.large])
                .presentationCornerRadius(ProfileV3Theme.Sizes.Agent.sheetCornerRadius)
                .presentationDragIndicator(.hidden)
        }
        .sheet(item: householdSheet) { _ in
            ProfileV3HouseholdApplySheet(viewModel: viewModel)
                .presentationCornerRadius(ProfileV3Theme.Sizes.Agent.sheetCornerRadius)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(viewModel.householdApply?.phase == .saving)
        }
        .onDisappear { viewModel.cancelPendingWork() }
        .sensoryFeedback(.success, trigger: viewModel.saveState) { _, state in state == .saved }
        .sensoryFeedback(.error, trigger: viewModel.saveState) { _, state in state == .failed }
    }

    private var foundTitle: String {
        ProfileV3Strings.preferencesFound(form.foundCount, of: form.totalCount, noun: form.noun)
    }

    private var showsPicker: Binding<Bool> {
        Binding(
            get: { viewModel.pickerSectionID != nil && viewModel.sources == nil },
            set: { if !$0 { viewModel.closePicker() } }
        )
    }

    private var showsPassportReason: Binding<Bool> {
        Binding(
            get: { viewModel.passportReason != nil },
            set: { if !$0 { viewModel.closePassportReason() } }
        )
    }

    @ViewBuilder
    private var passportReason: some View {
        if let reason = viewModel.passportReason {
            ProfileV3PassportReasonView(
                viewModel: reason,
                avatarURL: viewModel.avatarURL,
                onBack: viewModel.closePassportReason,
                onHowUsed: viewModel.openPassportHowUsed
            )
            .sheet(item: $viewModel.passportHowUsed, onDismiss: viewModel.passportHowUsedDismissed) { howUsed in
                ProfileV3PassportHowUsedSheet(viewModel: howUsed, onScan: viewModel.scanFromPassportHowUsed)
            }
        }
    }

    private var headerOffset: Binding<CGFloat> {
        Binding(get: { headerPin.offset }, set: { headerPin.offset = $0 })
    }

    private var householdSheet: Binding<ProfileV3HouseholdApplySession?> {
        Binding(
            get: { viewModel.householdApply },
            set: { if $0 == nil { viewModel.closeHousehold() } }
        )
    }

    private var showsSources: Binding<Bool> {
        Binding(
            get: { viewModel.sources != nil },
            set: { if !$0 { viewModel.closeSources() } }
        )
    }

    @ViewBuilder
    private var sectionSources: some View {
        if let sources = viewModel.sources {
            ProfileV3SectionSourcesView(viewModel: sources, form: viewModel, onBack: viewModel.closeSources)
        }
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ProfileV3AvatarOrb(imageURL: viewModel.avatarURL, size: ProfileV3Theme.Sizes.Agent.orbLarge)
                    .padding(.top, ProfileV3Theme.Sizes.Agent.orbTop)
                ProfileV3TwoToneTitle(
                    lead: ProfileV3Strings.found,
                    emphasis: foundTitle,
                    style: .H5InterMedium20
                )
                .frame(width: ProfileV3Theme.Sizes.Agent.titleWidth)
                .padding(.top, ProfileV3Theme.Space.s16)
                Text(form.summary)
                    .typoGraphy(.B2InterSemibold12)
                    .foregroundStyle(Color(at: .neutralGrey400))
                    .multilineTextAlignment(.center)
                    .frame(width: ProfileV3Theme.Sizes.Agent.summaryWidth)
                    .padding(.top, ProfileV3Theme.Sizes.Agent.summaryTop)
                if ProfileV3FeatureFlags.isAgentSourcesPillEnabled,
                   form.sources.count > 0 || !form.sources.icons.isEmpty {
                    ProfileV3SourcesPill(
                        icons: form.sources.icons,
                        count: form.sources.count,
                        label: form.sources.label
                    )
                    .padding(.top, ProfileV3Theme.Space.s24)
                }
                sections
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.top, ProfileV3Theme.Space.s50)
            }
            .profileV3ScrollOffsetAnchor(headerOffset)
        }
        .profileV3ScrollOffset(headerOffset)
        .overlay(alignment: .top) {
            ProfileV3AgentStickyHeader(tag: form.agentTag, pin: headerPin, onBack: viewModel.tapBack)
        }
        .scrollDismissesKeyboard(.interactively)
        .profileV3AgentSaveBar(viewModel)
        .background(Color(at: .pureWhite))
    }

    private var sections: some View {
        VStack(spacing: ProfileV3Theme.Space.s32) {
            if let card = form.liveMedicalCard {
                ProfileV3MedicalCardView(
                    card: card,
                    showsOnLockScreen: Binding(
                        get: { viewModel.form.medicalCard?.showsOnLockScreen ?? false },
                        set: viewModel.setShowsOnLockScreen
                    )
                )
            }
            ForEach(form.sections) { section in
                ProfileV3FormSectionView(
                    section: section,
                    agentAvatarURL: viewModel.avatarURL,
                    onToggleOption: { viewModel.toggleOption($0, in: section.id) },
                    onSliderChange: { viewModel.setSliderValue($0, in: section.id) },
                    onOptOut: { viewModel.setOptOut($0, in: section.id) },
                    onTextChange: { viewModel.setText($0, in: section.id) },
                    onDateChange: { viewModel.setDate($0, in: section.id) },
                    onAdd: { viewModel.openPicker(for: section.id) },
                    onOpenSources: { viewModel.openSources(for: section.id) },
                    onUploadPassport: { viewModel.startPassportUpdate() },
                    onViewPreviousPassports: viewModel.tapViewPreviousPassports,
                    selectedTabID: viewModel.selectedTabs[section.id],
                    onSelectTab: { viewModel.selectTab($0, in: section.id) },
                    onSelectCar: { viewModel.selectCar($0, in: section.id) },
                    onToggleBaggage: { viewModel.toggleBaggage($0, in: section.id) },
                    onStepBaggage: { viewModel.stepBaggage($0, by: $1, in: section.id) },
                    onOpenNoteLink: viewModel.openNoteLink
                )
                .equatable()
            }
        }
    }

    private var previousPassports: some View {
        ProfileV3PreviousPassportsView(
            title: viewModel.previousPassportsTitle,
            screen: viewModel.previousPassports,
            phase: viewModel.previousPassportsPhase,
            onBack: { viewModel.showsPreviousPassports = false },
            onRetry: viewModel.loadPreviousPassports
        )
    }
}

#if DEBUG
#Preview("Flight agent form") {
    ProfileV3AgentFormView(
        viewModel: ProfileV3AgentFormViewModel(
            form: ProfileV3AgentFixtures.flight,
            avatarURL: ProfileV3PlaceholderArt.agentFlight.url,
            repository: ProfileV3MockRepository(),
            onFinish: {}
        )
    )
}

#Preview("Flight agent form · saving") {
    ProfileV3AgentFormView(
        viewModel: .preview(
            ProfileV3AgentFixtures.flight,
            avatarURL: ProfileV3PlaceholderArt.agentFlight.url,
            saveState: .saving
        )
    )
}

#Preview("Flight agent form · saved") {
    ProfileV3AgentFormView(
        viewModel: .preview(
            ProfileV3AgentFixtures.flight,
            avatarURL: ProfileV3PlaceholderArt.agentFlight.url,
            saveState: .saved
        )
    )
}

#Preview("Flight agent form · save failed") {
    ProfileV3AgentFormView(
        viewModel: .preview(
            ProfileV3AgentFixtures.flight,
            avatarURL: ProfileV3PlaceholderArt.agentFlight.url,
            saveState: .failed
        )
    )
}

#Preview("Medical agent form") {
    ProfileV3AgentFormView(
        viewModel: ProfileV3AgentFormViewModel(
            form: ProfileV3AgentFixtures.medical,
            avatarURL: ProfileV3PlaceholderArt.agentMedical.url,
            repository: ProfileV3MockRepository(),
            onFinish: {}
        )
    )
}
#endif
