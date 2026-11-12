import ATUIKit
import SwiftUI

struct ProfileV3CityProfileView: View {
    @ObservedObject var viewModel: ProfileV3CityProfileViewModel

    var body: some View {
        NavigationStack {
            Group {
                if let content = viewModel.content {
                    ProfileV3CityProfileScreen(viewModel: viewModel, content: content)
                } else {
                    VStack(spacing: 0) {
                        ProfileV3CityProfileHeader(pin: nil, showsAdd: false, onBack: viewModel.close, onAdd: {})
                        ProfileV3LoadStateView(phase: viewModel.phase, retry: viewModel.load)
                    }
                }
            }
            .background(Color(at: .pureWhite))
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(item: $viewModel.search, onDismiss: viewModel.searchDidDismiss) { search in
            ProfileV3CitySearchSheet(model: search, onBack: { viewModel.search = nil }, onChoose: viewModel.choose)
        }
        .sheet(item: $viewModel.editor, onDismiss: viewModel.editorDidDismiss) { editor in
            ProfileV3CityPurposeSheetView(model: editor)
        }
        .profileV3TapToDismissKeyboard()
        .task { viewModel.loadIfNeeded() }
        .analyticsScreen(.cityProfileAgent)
    }
}

private struct ProfileV3CityProfileScreen: View {
    @ObservedObject var viewModel: ProfileV3CityProfileViewModel
    let content: ProfileV3CityProfile

    @State private var headerPin = ProfileV3HeaderPin()
    @State private var areTabsPinned = false

    nonisolated static let coordinateSpace = "ProfileV3CityProfileScreen"

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    carousel
                        .padding(.top, ProfileV3Theme.Sizes.Agent.backTop + ProfileV3Theme.Sizes.circleButton + Sizes.carouselTop)
                    if viewModel.isOnAddSlot || viewModel.selection == nil {
                        intro
                            .transition(.opacity)
                    } else if let city = viewModel.selectedCity, let form = viewModel.form {
                        ProfileV3CityPreferences(
                            city: city,
                            selectedTab: viewModel.selectedTab,
                            areTabsPinned: areTabsPinned,
                            form: form,
                            onEditTag: viewModel.editSelectedCity,
                            onSelectTab: viewModel.selectTab,
                            onTabsPinned: { areTabsPinned = $0 },
                            onSectionReached: viewModel.sectionReached
                        )
                        .id(city.id)
                        .transition(.opacity)
                    } else {
                        ProfileV3LoadStateView(phase: viewModel.selectedCityPhase, retry: viewModel.retryCity)
                            .frame(height: Sizes.cityLoadHeight)
                            .transition(.opacity)
                    }
                }
                .padding(.bottom, viewModel.form == nil ? Sizes.saveBarClearance : Sizes.preferencesBottom)
                .animation(ProfileV3Theme.Motion.contentFade, value: viewModel.selection)
                .profileV3ScrollOffsetAnchor(headerPin.offsetBinding)
            }
            .profileV3ScrollOffset(headerPin.offsetBinding)
            .scrollDismissesKeyboard(.interactively)
            .trackScrollDepth()
            .onChange(of: viewModel.scrollRequest) { _, request in
                guard let request else { return }
                withAnimation(ProfileV3Theme.Motion.citySectionScroll) {
                    proxy.scrollTo(request.anchorID, anchor: .top)
                }
            }
        }
        .coordinateSpace(.named(Self.coordinateSpace))
        .overlay(alignment: .top) {
            ProfileV3CityProfileHeader(
                pin: headerPin,
                showsAdd: !viewModel.isOnAddSlot,
                onBack: viewModel.close,
                onAdd: viewModel.startAdding,
                tabStrip: pinnedTabStrip
            )
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let form = viewModel.form {
                ProfileV3AgentSaveBar(viewModel: form)
            }
        }
        .background {
            if let form = viewModel.form {
                ProfileV3CityFormDestinations(form: form)
            }
        }
        .overlay {
            if let form = viewModel.form {
                ProfileV3CityRuleEditor(form: form)
            }
        }
        .background(Color(at: .pureWhite))
    }

    private var pinnedTabStrip: ProfileV3CityTabStrip? {
        guard areTabsPinned, viewModel.form != nil, let tabs = viewModel.selectedCity?.tabs, !tabs.isEmpty else {
            return nil
        }
        return ProfileV3CityTabStrip(tabs: tabs, selectedID: viewModel.selectedTab, onSelect: viewModel.selectTab)
    }

    private var carousel: some View {
        ProfileV3CentredCarousel(
            itemWidth: Sizes.window.width,
            height: Sizes.window.height,
            spacing: Sizes.windowSpacing,
            selection: $viewModel.selection,
            itemIDs: viewModel.slotIDs
        ) {
            ForEach(content.cities) { city in
                window(.city(code: city.code, name: city.name, imageURL: city.imageURL), id: city.id)
            }
            window(.add(label: content.add.label, detail: content.add.detail), id: ProfileV3CityProfileViewModel.addSlotID)
        }
    }

    private func window(_ window: ProfileV3CityWindow.Content, id: String) -> some View {
        ProfileV3CityWindow(content: window, isAnimating: viewModel.selection == id)
            .contentShape(Capsule())
            .scrollTransition(axis: .horizontal) { view, phase in
                view.scaleEffect(phase.isIdentity ? 1 : Sizes.windowSideScale)
            }
            .onTapGesture { tap(id) }
            .accessibilityAddTraits(viewModel.selection == id ? [.isButton, .isSelected] : .isButton)
            .accessibilityAction { tap(id) }
            .id(id)
    }

    private func tap(_ id: String) {
        guard viewModel.selection == id else {
            withAnimation(ProfileV3Theme.Motion.entry) { viewModel.select(id) }
            return
        }
        if id == ProfileV3CityProfileViewModel.addSlotID {
            viewModel.startAdding()
        }
    }

    private var intro: some View {
        VStack(spacing: 0) {
            Text(content.headline)
                .font(.Inter.get(size: Sizes.introTitleSize, weight: .medium))
                .tracking(Sizes.introTitleTracking)
                .foregroundStyle(Color(at: .pureBlack))
                .multilineTextAlignment(.center)
                .frame(maxWidth: Sizes.introTitleWidth)
                .padding(.top, Sizes.introTitleTop)
            if !content.samples.isEmpty {
                ProfileV3CityDeck(samples: content.samples)
                    .padding(.top, Sizes.introDeckTop)
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
}

private struct ProfileV3CityProfileHeader: View {
    let pin: ProfileV3HeaderPin?
    let showsAdd: Bool
    let onBack: () -> Void
    let onAdd: () -> Void
    var tabStrip: ProfileV3CityTabStrip?

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        let progress = tabStrip == nil ? pin?.progress ?? 0 : 1
        ZStack(alignment: .top) {
            ProfileV3FadeBand(
                solid: tabStrip == nil ? ProfileV3Theme.Sizes.Agent.stickyBarHeight : Sizes.pinnedTabsTop + Sizes.tabStripHeight,
                fade: tabStrip == nil ? ProfileV3Theme.Sizes.Agent.stickyFadeHeight : Sizes.pinnedTabsFade,
                blocksTouches: progress > 0
            )
            .opacity(Double(progress))
            .accessibilityHidden(true)
            ProfileV3AgentSheetChrome(control: .back(onBack), title: { ProfileV3TagLabel(text: ProfileV3Strings.cityProfile) })
            if showsAdd {
                HStack {
                    Spacer()
                    ProfileV3CityHeaderButton(
                        icon: ATIcon.SwiftUIImage.add,
                        accessibilityLabel: ProfileV3Strings.addCity,
                        isLime: true,
                        action: onAdd
                    )
                }
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, ProfileV3Theme.Sizes.Agent.backTop)
                .transition(.opacity)
            }
            if let tabStrip {
                tabStrip
                    .padding(.top, Sizes.pinnedTabsTop)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(ProfileV3Theme.Motion.contentFade, value: showsAdd)
    }
}

private struct ProfileV3CityFormDestinations: View {
    @ObservedObject var form: ProfileV3AgentFormViewModel

    var body: some View {
        Color.clear
            .navigationDestination(isPresented: showsPicker) {
                ProfileV3AgentOptionPicker(viewModel: form)
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .navigationDestination(isPresented: showsSources) {
                if let sources = form.sources, let section = form.sourcesSection {
                    ProfileV3SectionSourcesView(viewModel: sources, section: section, form: form, onBack: form.closeSources)
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                }
            }
    }

    private var showsPicker: Binding<Bool> {
        Binding(
            get: { form.pickerSectionID != nil && form.sources == nil },
            set: { if !$0 { form.closePicker() } }
        )
    }

    private var showsSources: Binding<Bool> {
        Binding(
            get: { form.sources != nil },
            set: { if !$0 { form.closeSources() } }
        )
    }
}

private struct ProfileV3CityRuleEditor: View {
    @ObservedObject var form: ProfileV3AgentFormViewModel

    var body: some View {
        if let customRules = form.customRules {
            ProfileV3CustomRuleEditorHost(model: customRules)
        }
    }
}

private struct ProfileV3CityPreferences: View {
    let city: ProfileV3City
    let selectedTab: String?
    let areTabsPinned: Bool
    @ObservedObject var form: ProfileV3AgentFormViewModel
    let onEditTag: () -> Void
    let onSelectTab: (String) -> Void
    let onTabsPinned: (Bool) -> Void
    let onSectionReached: (String, Bool) -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        let agentForm = form.form
        VStack(spacing: 0) {
            ProfileV3CityTagChip(
                label: city.purpose.label,
                iconURL: city.purpose.iconURL,
                editsPurpose: city.editsPurpose,
                onEdit: onEditTag
            )
            .padding(.top, Sizes.tagRowTop)
            if let found = city.found, found.count > 0 {
                foundHeading(found)
                    .padding(.top, Sizes.foundTop)
            }
            if let sources = city.sources {
                ProfileV3CitySourcesSummary(sources: sources)
                    .padding(.top, Sizes.sourcesTop)
            }
            let tabs = city.tabs
            if !tabs.isEmpty {
                ProfileV3CityTabStrip(tabs: tabs, selectedID: selectedTab, onSelect: onSelectTab)
                    .opacity(areTabsPinned ? 0 : 1)
                    .allowsHitTesting(!areTabsPinned)
                    .accessibilityHidden(areTabsPinned)
                    .onGeometryChange(for: Bool.self) { proxy in
                        proxy.frame(in: .named(ProfileV3CityProfileScreen.coordinateSpace)).minY <= Sizes.pinnedTabsTop
                    } action: { isPinned in
                        onTabsPinned(isPinned)
                    }
                    .onDisappear { onTabsPinned(false) }
                    .padding(.top, (city.sources == nil ? Sizes.tabsTopWithoutSources : Sizes.tabsTop) - Sizes.tabStripPadding)
            }
            VStack(spacing: Sizes.sectionSpacing) {
                ForEach(agentForm.sections.filter { !$0.isCustomRules }) { section in
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: Sizes.sectionScrollInset)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                            .id(ProfileV3CityProfileViewModel.sectionAnchorID(section.id))
                        ProfileV3CitySectionView(
                            section: section,
                            style: city.style(for: section.id),
                            form: form
                        )
                        .onGeometryChange(for: Bool.self) { proxy in
                            proxy.frame(in: .named(ProfileV3CityProfileScreen.coordinateSpace)).minY <= Sizes.sectionReachedLine
                        } action: { isReached in
                            onSectionReached(section.id, isReached)
                        }
                    }
                    .padding(.top, -Sizes.sectionScrollInset)
                }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, Sizes.sectionsTop - Sizes.tabStripPadding)
            if let customRules = form.customRules {
                ProfileV3CustomRulesSection(model: customRules)
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.top, ProfileV3Theme.Space.s32)
            }
        }
    }

    private func foundHeading(_ found: ProfileV3CityFound) -> some View {
        let fraction = "\(found.count)/\(found.total)"
        var text = AttributedString(found.label)
        text.foregroundColor = ProfileV3Theme.Palette.countryText.opacity(ProfileV3Theme.Opacity.cityFoundNoun)
        if let range = text.range(of: fraction) {
            text[text.startIndex..<range.upperBound].foregroundColor = ProfileV3Theme.Palette.countryText
        }
        return Text(text)
            .typoGraphy(.H6InterMedium18)
            .multilineTextAlignment(.center)
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
}

private struct ProfileV3CitySourcesSummary: View {
    let sources: ProfileV3CitySources

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        HStack(spacing: ProfileV3Theme.Space.s8) {
            HStack(spacing: Sizes.sourcesIconOverlap) {
                ForEach(Array(sources.icons.enumerated()), id: \.offset) { _, icon in
                    ProfileV3RemoteImage(url: icon.url, contentMode: .fit, placeholder: .clear)
                        .frame(width: Sizes.sourcesIcon, height: Sizes.sourcesIcon)
                        .background(Circle().fill(Color(at: .pureWhite)))
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(ProfileV3Theme.Palette.cardBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
                }
            }
            .accessibilityHidden(true)
            Text(sources.label)
                .typoGraphy(.B2InterSemibold12)
                .foregroundStyle(ProfileV3Theme.Palette.citySourcesText)
        }
        .accessibilityElement(children: .combine)
    }
}

struct ProfileV3CitySectionView: View {
    let section: ProfileV3FormSection
    let style: ProfileV3CitySectionStyle
    let form: ProfileV3AgentFormViewModel

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        ProfileV3CitySectionCard(icon: hasValue ? style.activeIconURL ?? style.iconURL : style.iconURL, isComplete: hasValue) {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, Sizes.cardTitleTop)
                if let subtitle = style.subtitle?.nonEmpty {
                    Text(subtitle)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: Sizes.noteWidth, alignment: .leading)
                        .padding(.top, ProfileV3Theme.Space.s8)
                }
                if let source = section.source {
                    ProfileV3SectionSourcesRow(source: source) { form.openSources(for: section.id) }
                        .padding(.top, Sizes.cardHeaderGap)
                }
                control
                    .disabled(isOptedOut)
                    .opacity(isOptedOut ? ProfileV3Theme.Opacity.disabled : 1)
                    .animation(ProfileV3Theme.Motion.selection, value: isOptedOut)
                if let optOut = chipField?.optOut {
                    ProfileV3CityOptOutRow(optOut: optOut) { form.setOptOut(!optOut.isOn, in: section.id) }
                        .padding(.top, Sizes.optOutTop)
                }
                if let note = section.note?.text.nonEmpty {
                    Text(note)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(ProfileV3Theme.tagGradient)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: Sizes.noteWidth, alignment: .leading)
                        .padding(.top, Sizes.cardNoteTop)
                }
            }
            .padding(.horizontal, Sizes.cardPadding)
        }
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
        HStack(spacing: ProfileV3Theme.Space.s8) {
            Text(section.title)
                .typoGraphy(.H7InterMedium16)
                .foregroundStyle(Color(at: .pureBlack))
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
        }
        .overlay(alignment: .trailing) {
            if picksMore {
                ProfileV3CityAddButton(accessibilityLabel: section.title) { form.openPicker(for: section.id) }
                    .padding(.trailing, Sizes.cardTrailingPadding - Sizes.cardPadding)
                    .disabled(isOptedOut)
            }
        }
    }

    @ViewBuilder
    private var control: some View {
        switch section.control {
        case .chips(let field):
            chips(field)
                .padding(.top, field.selection.isEmpty && hidesUnselected ? 0 : Sizes.cardContentTop)
        case .cards(let field):
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Sizes.classCardSpacing) {
                    ForEach(field.options) { option in
                        ProfileV3CityClassCard(option: option, isSelected: field.selection.contains(option.id)) {
                            form.toggleOption(option.id, in: section.id)
                        }
                    }
                }
                .padding(.horizontal, Sizes.cardPadding)
            }
            .padding(.horizontal, -Sizes.cardPadding)
            .padding(.top, Sizes.cardContentTop - ProfileV3Theme.Space.s8)
        case .slider, .text, .date, .passport, .cars, .baggage, .customRules:
            EmptyView()
        }
    }

    @ViewBuilder
    private func chips(_ field: ProfileV3ChipField) -> some View {
        switch style.layout {
        case .logos:
            if !field.selectedOptions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Sizes.logoChipSpacing) {
                        ForEach(field.selectedOptions) { option in
                            ProfileV3CityLogoChip(option: option, isSelected: true) {
                                form.toggleOption(option.id, in: section.id)
                            }
                        }
                    }
                    .padding(.horizontal, Sizes.cardPadding)
                    .padding(.vertical, ProfileV3Theme.Space.s4)
                }
                .padding(.horizontal, -Sizes.cardPadding)
            }
        case .rows:
            if !field.selectedOptions.isEmpty {
                VStack(spacing: Sizes.placeSpacing) {
                    ForEach(field.selectedOptions) { option in
                        ProfileV3CityPlaceRow(option: option) { form.openPicker(for: section.id) }
                    }
                }
            }
        case .grid, .tiles:
            ProfileV3CityOptionGrid(options: field.options) { option in
                ProfileV3CityOptionChip(
                    title: option.title,
                    isSelected: field.selection.contains(option.id),
                    orbURL: option.logoURL,
                    selectedOrbURL: option.selectedLogoURL,
                    orbID: option.id
                ) {
                    form.toggleOption(option.id, in: section.id)
                }
            }
        }
    }

    private var chipField: ProfileV3ChipField? {
        guard case .chips(let field) = section.control else { return nil }
        return field
    }

    private var hidesUnselected: Bool {
        style.layout == .logos || style.layout == .rows
    }

    private var picksMore: Bool {
        guard let field = chipField, field.picker != nil else { return false }
        return hidesUnselected
    }

    private var isOptedOut: Bool {
        chipField?.optOut?.isOn == true
    }

    private var hasValue: Bool {
        switch section.control {
        case .chips(let field): return !field.selection.isEmpty || field.optOut?.isOn == true
        case .cards(let field): return !field.selection.isEmpty
        case .slider, .text, .date, .passport, .cars, .baggage, .customRules: return section.status == .complete
        }
    }
}

#if DEBUG
#Preview("City profile") {
    ProfileV3CityProfileView(
        viewModel: ProfileV3CityProfileViewModel(profileID: nil, repository: ProfileV3MockRepository())
    )
}

#Preview("City profile · no cities") {
    ProfileV3CityProfileView(
        viewModel: ProfileV3CityProfileViewModel(
            profileID: nil,
            repository: ProfileV3MockRepository(cities: ProfileV3CityProfileStore(entries: []))
        )
    )
}

#Preview("City profile · failed") {
    ProfileV3CityProfileView(
        viewModel: ProfileV3CityProfileViewModel(profileID: nil, repository: ProfileV3FailingRepository())
    )
}
#endif
