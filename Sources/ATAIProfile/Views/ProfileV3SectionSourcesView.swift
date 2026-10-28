import ATUIKit
import SwiftUI

struct ProfileV3SectionSourcesView: View {
    @ObservedObject var viewModel: ProfileV3PreferenceSourcesViewModel
    @ObservedObject var form: ProfileV3AgentFormViewModel
    let onBack: () -> Void

    private typealias Sources = ProfileV3Theme.Sizes.Sources

    @State private var headerPin = ProfileV3HeaderPin()

    private var section: ProfileV3FormSection {
        form.form.sections.first { $0.id == viewModel.section.id } ?? viewModel.section
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if let content = viewModel.content {
                ScrollView(showsIndicators: false) {
                    loaded(content)
                        .profileV3HeaderFadeAnchor(headerPin)
                }
                .profileV3HeaderFade(headerPin)
            } else {
                ProfileV3LoadStateView(phase: viewModel.phase, retry: viewModel.load)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .profileV3AgentSaveBar(form)
        .navigationDestination(isPresented: showsPicker) {
            ProfileV3AgentOptionPicker(viewModel: form)
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var showsPicker: Binding<Bool> {
        Binding(
            get: { form.pickerSectionID != nil },
            set: { if !$0 { form.closePicker() } }
        )
    }

    private func loaded(_ content: ProfileV3PreferenceSources) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(content.title)
                .typoGraphy(.H6InterMedium18)
                .foregroundStyle(Color(at: .pureBlack))
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, Sources.titleTop)
            if hasOptions {
                control
                    .padding(.top, Sources.chipsTop)
            }
            ProfileV3DashedDivider()
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, Sources.dividerTop)
            steps(content.steps)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, Sources.stepsTop)
                .padding(.bottom, Sources.bottomPadding)
        }
    }

    private var header: some View {
        ZStack(alignment: .top) {
            ProfileV3SheetGrabber(
                width: ProfileV3Theme.Sizes.Agent.sheetGrabberWidth,
                color: Color(at: .neutralGrey200),
                top: ProfileV3Theme.Space.s10
            )
            ZStack {
                HStack {
                    ProfileV3CircleIconButton.back(action: onBack)
                    Spacer()
                }
                ProfileV3TagLabel(text: section.title)
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Sizes.Agent.backTop)
        }
        .frame(maxWidth: .infinity)
    }

    private var hasOptions: Bool {
        switch section.control {
        case .chips, .cards: return true
        case .slider, .text, .date, .passport, .cars, .baggage: return false
        }
    }

    @ViewBuilder
    private var control: some View {
        switch section.control {
        case .chips(let field):
            chipsRow(
                options: field.visibleOptions(limit: ProfileV3Theme.Counts.chipInlineLimit),
                selection: field.selection,
                showsAdd: !field.remainingOptions(limit: ProfileV3Theme.Counts.chipInlineLimit).isEmpty
            )
        case .cards(let field):
            chipsRow(
                options: field.options.map { ProfileV3ChipOption(id: $0.id, title: $0.code) },
                selection: field.selection,
                showsAdd: false
            )
        case .slider, .text, .date, .passport, .cars, .baggage:
            EmptyView()
        }
    }

    private func chipsRow(options: [ProfileV3ChipOption], selection: Set<String>, showsAdd: Bool) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ProfileV3Theme.Space.s12) {
                ForEach(options) { option in
                    ProfileV3Chip(
                        title: option.title,
                        isSelected: selection.contains(option.id),
                        leadingImageURL: option.logoURL,
                        action: { toggle(option.id) }
                    )
                }
                if showsAdd {
                    ProfileV3Chip(title: ProfileV3Strings.addChip, isSelected: false, action: openPicker)
                }
            }
        }
        .contentMargins(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin, for: .scrollContent)
        .scrollClipDisabled()
    }

    private func toggle(_ optionID: String) {
        form.toggleOption(optionID, in: section.id)
    }

    private func openPicker() {
        form.openPicker(for: section.id)
    }

    private func steps(_ steps: [ProfileV3SourceStep]) -> some View {
        VStack(spacing: Sources.stepGap) {
            ForEach(steps) { step in
                VStack(spacing: Sources.stepGap) {
                    ProfileV3SourceStepRow(step: step)
                    ProfileV3DashedDivider()
                        .padding(.leading, Sources.tile + Sources.tileSpacing)
                }
            }
        }
    }
}

#if DEBUG
#Preview("Section sources") {
    let section = ProfileV3AgentFixtures.flight.sections[0]
    let viewModel = ProfileV3PreferenceSourcesViewModel(
        section: section,
        source: section.source ?? ProfileV3SectionSource(icons: [], agentType: "flight", fieldKey: section.id),
        profileID: nil,
        repository: ProfileV3MockRepository()
    )
    ProfileV3SectionSourcesView(
        viewModel: viewModel,
        form: .preview(ProfileV3AgentFixtures.flight, avatarURL: nil, saveState: .idle),
        onBack: {}
    )
    .task { viewModel.load() }
}
#endif
