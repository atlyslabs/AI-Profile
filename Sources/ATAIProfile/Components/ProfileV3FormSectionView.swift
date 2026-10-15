import ATUIKit
import SwiftUI

struct ProfileV3FormSectionView: View {
    let section: ProfileV3FormSection
    var agentAvatarURL: URL?
    let onToggleOption: (String) -> Void
    let onSliderChange: (Double) -> Void
    let onOptOut: (Bool) -> Void
    let onTextChange: @MainActor (String) -> Void
    var onDateChange: ((Date) -> Void)?
    var onAdd: (() -> Void)?
    var onOpenSources: (() -> Void)?
    var onUploadPassport: (() -> Void)?
    var onViewPreviousPassports: (() -> Void)?
    var selectedTabID: String?
    var onSelectTab: ((String) -> Void)?
    var onSelectCar: ((String) -> Void)?
    var onToggleBaggage: ((String) -> Void)?
    var onStepBaggage: ((String, Int) -> Void)?

    @State private var sliderPreview: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s8) {
                ProfileV3SectionHeader(
                    title: section.title,
                    status: statusKind,
                    trailing: trailing?.value,
                    trailingDetail: trailing?.detail,
                    onTrailingTap: passportField?.hasHistory == true ? onViewPreviousPassports : nil
                )
                if let source = section.source(selectedTab: selectedTabID), let onOpenSources {
                    ProfileV3SectionSourcesRow(iconURL: source.iconURL, action: onOpenSources)
                }
                if showsNoteAsSubtitle, let note = section.note {
                    Text(note.text)
                        .typoGraphy(.B2InterSemibold12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                        .frame(maxWidth: ProfileV3Theme.Sizes.Car.subtitleWidth, alignment: .leading)
                        .padding(.top, ProfileV3Theme.Sizes.Car.subtitleTop - ProfileV3Theme.Space.s8)
                }
            }
            control
                .padding(.top, showsNoteAsSubtitle ? ProfileV3Theme.Sizes.Car.carouselTop : ProfileV3Theme.Space.s24)
            if !showsNoteAsSubtitle, let note = section.note {
                ProfileV3AINoteLine(text: note.text, icon: noteIcon(for: note))
                    .padding(.top, ProfileV3Theme.Space.s24)
            }
            ProfileV3DashedDivider()
                .padding(.top, ProfileV3Theme.Space.s24)
        }
    }

    private var showsNoteAsSubtitle: Bool {
        if case .cars = section.control { return true }
        return false
    }

    @ViewBuilder
    private var control: some View {
        switch section.control {
        case .chips(let field):
            ProfileV3OptionChipGroup(
                options: field.visibleOptions(limit: ProfileV3Theme.Counts.chipInlineLimit),
                selection: field.selection,
                onAdd: field.remainingOptions(limit: ProfileV3Theme.Counts.chipInlineLimit).isEmpty ? nil : onAdd,
                onToggle: onToggleOption
            )
        case .cards(let field):
            ProfileV3OptionCardGrid(options: field.options, selection: field.selection, onToggle: onToggleOption)
        case .slider(let field):
            VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.sliderRulerSpacing) {
                ProfileV3PreferenceSlider(
                    field: field,
                    label: section.title,
                    onPreview: { preview in
                        if sliderPreview != preview { sliderPreview = preview }
                    },
                    onChange: onSliderChange
                )
                if let optOut = field.optOut {
                    ProfileV3CheckboxRow(title: optOut.title, isOn: optOut.isOn) { onOptOut(!optOut.isOn) }
                }
            }
        case .passport(let field):
            VStack(spacing: ProfileV3Theme.Sizes.Passport.controlSpacing) {
                ProfileV3PassportCard(
                    holderName: field.holderName,
                    countryName: field.countryName,
                    countryNativeName: field.countryNativeName,
                    content: field.passport.map(ProfileV3PassportCard.Content.details) ?? .upload,
                    onUpload: onUploadPassport
                )
                if field.passport != nil {
                    ProfileV3PillButton(
                        title: ProfileV3Strings.uploadNewPassport,
                        size: .medium,
                        tint: Color(at: .pureBlack),
                        titleTint: Color(at: .pureWhite),
                        action: { onUploadPassport?() }
                    )
                }
            }
            .frame(maxWidth: .infinity)
        case .text(let field):
            ProfileV3UnderlinedField(
                placeholder: field.placeholder,
                accessibilityLabel: section.title,
                text: Binding(get: { field.value }, set: onTextChange),
                keyboard: field.keyboard == .phone ? .phonePad : .default
            )
        case .date(let field):
            ProfileV3DateInput(
                placeholder: field.placeholder,
                accessibilityLabel: section.title,
                date: field.value,
                onChange: { onDateChange?($0) }
            )
        case .cars(let field):
            ProfileV3CarCarousel(field: field) { onSelectCar?($0) }
        case .baggage(let field):
            ProfileV3BaggagePicker(
                field: field,
                selectedTabID: selectedTabID,
                onSelectTab: { onSelectTab?($0) },
                onToggle: { onToggleBaggage?($0) },
                onStep: { onStepBaggage?($0, $1) }
            )
        }
    }

    private var passportField: ProfileV3PassportField? {
        guard case .passport(let field) = section.control else { return nil }
        return field
    }

    private var statusKind: ProfileV3StatusDot.Kind? {
        switch section.status {
        case .complete: return .complete
        case .pending: return .pending
        case nil: return nil
        }
    }

    private var trailing: (value: String, detail: String?)? {
        if case .passport(let field) = section.control {
            return field.hasHistory ? (ProfileV3Strings.viewPrevious, nil) : nil
        }
        guard case .slider(let field) = section.control else { return nil }
        return field.previewing(sliderPreview).readout
    }

    private func noteIcon(for note: ProfileV3FormNote) -> ProfileV3AINoteLine.Icon {
        switch note.icon {
        case .agent: return .agent(agentAvatarURL)
        case .sources: return .sparkle
        }
    }
}

#if DEBUG
#Preview("Form sections") {
    ScrollView {
        VStack(spacing: ProfileV3Theme.Space.s32) {
            ForEach(ProfileV3AgentFixtures.flight.sections.prefix(3)) { section in
                ProfileV3FormSectionView(
                    section: section,
                    agentAvatarURL: ProfileV3PlaceholderArt.agentFlight.url,
                    onToggleOption: { _ in },
                    onSliderChange: { _ in },
                    onOptOut: { _ in },
                    onTextChange: { _ in },
                    onAdd: {}
                )
            }
        }
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
    .background(Color(at: .pureWhite))
}
#endif
