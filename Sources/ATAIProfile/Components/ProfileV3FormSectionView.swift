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
    var onOpenNoteLink: ((ProfileV3Directive) -> Void)?

    @State private var sliderPreview: Double?

    private static let noteLinkURL = URL(string: "profilev3-note-link://open")!

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s8) {
                ProfileV3SectionHeader(
                    title: section.title,
                    status: statusKind,
                    trailing: trailing?.value,
                    trailingDetail: trailing?.detail,
                    onTrailingTap: passportField?.previous != nil ? onViewPreviousPassports : nil
                )
                if let source = section.source(selectedTab: selectedTabID), let onOpenSources {
                    ProfileV3SectionSourcesRow(source: source, action: onOpenSources)
                }
                if showsNoteAsSubtitle, let note = section.note {
                    Text(Self.attributed(note))
                        .typoGraphy(.B2InterSemibold12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                        .tint(Color(at: .neutralGrey800))
                        .environment(\.openURL, OpenURLAction { _ in
                            if let link = note.link { onOpenNoteLink?(link.directive) }
                            return .handled
                        })
                        .frame(maxWidth: ProfileV3Theme.Sizes.Car.subtitleWidth, alignment: .leading)
                        .padding(.top, ProfileV3Theme.Sizes.Car.subtitleTop - ProfileV3Theme.Space.s8)
                }
            }
            control
                .padding(.top, controlTop)
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

    private var controlTop: CGFloat {
        switch section.control {
        case .cars: return ProfileV3Theme.Sizes.Car.carouselTop
        case .passport: return ProfileV3Theme.Sizes.Passport.sectionTop
        default: return ProfileV3Theme.Space.s24
        }
    }

    private static func attributed(_ note: ProfileV3FormNote) -> AttributedString {
        var text = AttributedString(note.text)
        if let link = note.link, let range = text.range(of: link.text) {
            text[range].link = noteLinkURL
            text[range].underlineStyle = .single
        }
        return text
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
                        tint: Color(at: .neutralGrey800),
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
                keyboard: field.keyboard == .phone ? .phonePad : .default,
                growsWithContent: !field.isDate
            )
        case .date(let field):
            ProfileV3DateInput(
                placeholder: field.placeholder,
                accessibilityLabel: section.title,
                date: field.value,
                hidesYear: field.hidesYear,
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
            return field.previous.map { ($0.label, nil) }
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
