import Foundation

struct ProfileV3ContactSnapshot: Equatable {
    let email: String?
    let mobileNumber: String?
    let rendersMobile: Bool

    var rendered: String { (rendersMobile ? mobileNumber : email) ?? "" }
}

struct ProfileV3AgentResiduals: Equatable {
    static let empty = ProfileV3AgentResiduals()

    var saveAction: String?
    var lockScreenFieldKey: String?
    var passthrough: [String: ProfileV3AgentSubmissionValue] = [:]
    var contacts: [String: ProfileV3ContactSnapshot] = [:]
    var dateFormats: [String: ProfileV3AgentDateCodec.Format] = [:]
}

struct ProfileV3MappedAgentFlow {
    let flow: ProfileV3AgentFlow
    let agentID: String
    let residuals: ProfileV3AgentResiduals
}

final class ProfileV3AgentResidualStore: @unchecked Sendable {
    private struct Key: Hashable {
        let agentID: String
        let profileID: String?
    }

    private let lock = NSLock()
    private var storage: [Key: ProfileV3AgentResiduals] = [:]

    func record(_ residuals: ProfileV3AgentResiduals, agentID: String, profileID: String?) {
        lock.lock()
        storage[Key(agentID: agentID, profileID: profileID)] = residuals
        lock.unlock()
    }

    func residuals(agentID: String, profileID: String?) -> ProfileV3AgentResiduals {
        lock.lock()
        defer { lock.unlock() }
        return storage[Key(agentID: agentID, profileID: profileID)] ?? .empty
    }
}

enum ProfileV3AgentMapper: ProfileV3DTOReading {

    private struct Bounds {
        let range: ClosedRange<Double>
        let style: ProfileV3SliderField.Style
    }

    private static let medicalCardKind = "medical_card"
    private static let labelledSliderRange: ClosedRange<Double> = 0...100
    private static let preferenceSourcesRoute = "preference_sources"
    private static let viewSourceEmailsAction = "view_source_emails"

    static func flow(
        from dto: ProfileV3AgentScreenDTO,
        accountCountry: ProfileV3Country? = nil,
        holderName: String? = nil
    ) -> ProfileV3MappedAgentFlow {
        let apiAgentType = text(dto.save?.agentType) ?? text(dto.agentType) ?? text(dto.id)
        let agentType = apiAgentType ?? ""
        let agentID = ProfileV3AgentID(apiValue: agentType)?.rawValue ?? agentType
        let fields = dto.fields
        var residuals = ProfileV3AgentResiduals()
        residuals.saveAction = text(dto.save?.action)
        let flow = ProfileV3AgentFlow.preferences(
            form(
                from: dto,
                fields: fields,
                agentID: agentID,
                agentType: apiAgentType,
                accountCountry: accountCountry,
                holderName: holderName,
                residuals: &residuals
            )
        )
        return ProfileV3MappedAgentFlow(flow: flow, agentID: agentID, residuals: residuals)
    }

    private static func form(
        from dto: ProfileV3AgentScreenDTO,
        fields: [ProfileV3AgentFieldDTO],
        agentID: String,
        agentType: String?,
        accountCountry: ProfileV3Country?,
        holderName: String?,
        residuals: inout ProfileV3AgentResiduals
    ) -> ProfileV3AgentForm {
        var sections: [ProfileV3FormSection] = []
        if let passport = dto.passport {
            sections.append(ProfileV3PassportMapper.section(passport, accountCountry: accountCountry))
        } else if let empty = dto.passportEmpty {
            sections.append(
                ProfileV3PassportMapper.emptySection(empty, holderName: holderName, accountCountry: accountCountry)
            )
        }
        for field in fields {
            if field.inputKind == .baggageGrid {
                appendBaggageTab(from: field, agentType: agentType, to: &sections)
                continue
            }
            guard let section = section(from: field, agentType: agentType, residuals: &residuals) else { continue }
            sections.append(section)
        }
        let card = medicalCard(from: dto.card, fields: fields, residuals: &residuals)
        let agentTag = text(dto.title) ?? ""
        return ProfileV3AgentForm(
            agentID: agentID,
            agentTag: agentTag,
            foundCount: dto.found?.count?.intValue ?? 0,
            totalCount: dto.found?.total?.intValue ?? 0,
            noun: noun(for: agentID),
            summary: dto.insight?.text ?? "",
            sources: sources(from: dto.sources),
            medicalCard: card,
            household: household(from: dto.save?.household, fallbackEyebrow: agentTag),
            sections: sections
        )
    }

    private static func household(
        from dto: ProfileV3AgentHouseholdDTO?,
        fallbackEyebrow: String
    ) -> ProfileV3HouseholdPrompt? {
        guard let dto, let title = text(dto.title) else { return nil }
        let travellers = (dto.travelers ?? []).compactMap { traveller -> ProfileV3HouseholdPrompt.Traveller? in
            guard let id = text(traveller.profileID), let name = text(traveller.name) else { return nil }
            return ProfileV3HouseholdPrompt.Traveller(
                id: id,
                name: name,
                passNumber: text(traveller.passNumber) ?? "",
                isSelected: traveller.selected == true
            )
        }
        guard !travellers.isEmpty else { return nil }
        return ProfileV3HouseholdPrompt(
            eyebrow: text(dto.eyebrow) ?? fallbackEyebrow,
            iconURL: remoteURL(dto.icon),
            title: title,
            travellers: travellers,
            confirmLabel: text(dto.confirm?.label) ?? ProfileV3Strings.householdConfirm
        )
    }

    private static func section(
        from field: ProfileV3AgentFieldDTO,
        agentType: String?,
        residuals: inout ProfileV3AgentResiduals
    ) -> ProfileV3FormSection? {
        guard let control = control(from: field, residuals: &residuals) else { return nil }
        return ProfileV3FormSection(
            id: field.key,
            title: field.label ?? "",
            status: field.isFound ? .complete : .pending,
            control: control,
            note: note(from: field),
            source: source(from: field, agentType: agentType)
        )
    }

    private static func note(from field: ProfileV3AgentFieldDTO) -> ProfileV3FormNote? {
        guard let assist = text(field.assist) else { return nil }
        var note = ProfileV3FormNote(text: assist)
        if let link = field.assistLink,
           let run = text(link.text),
           assist.contains(run),
           let directive = link.next?.directive {
            note.link = ProfileV3FormNote.Link(text: run, directive: directive)
        }
        return note
    }

    private static func appendBaggageTab(
        from field: ProfileV3AgentFieldDTO,
        agentType: String?,
        to sections: inout [ProfileV3FormSection]
    ) {
        let tab = baggageTab(from: field, agentType: agentType)
        let groupID = text(field.group) ?? field.key
        guard let index = sections.firstIndex(where: { $0.id == groupID }),
              case .baggage(var group) = sections[index].control else {
            sections.append(
                ProfileV3FormSection(
                    id: groupID,
                    title: field.label ?? "",
                    status: tab.isFound ? .complete : .pending,
                    control: .baggage(ProfileV3BaggageField(tabs: [tab])),
                    note: note(from: field)
                )
            )
            return
        }
        group.tabs.append(tab)
        sections[index].control = .baggage(group)
        if tab.isFound {
            sections[index].status = .complete
        }
        if sections[index].note == nil {
            sections[index].note = note(from: field)
        }
    }

    private static func baggageTab(from field: ProfileV3AgentFieldDTO, agentType: String?) -> ProfileV3BaggageTab {
        let listed = Set(field.value?.list ?? [])
        let storedCounts = field.value?.counts ?? [:]
        var quantities: [String: Int] = [:]
        for option in field.options {
            guard let id = option.id else { continue }
            let isSelected = option.selected == true || listed.contains(id)
            guard option.countable == true else {
                if isSelected { quantities[id] = 1 }
                continue
            }
            let stored: Int = option.count?.intValue ?? storedCounts[id] ?? 0
            let quantity: Int = isSelected ? max(stored, 1) : stored
            if quantity > 0 {
                quantities[id] = quantity
            }
        }
        return ProfileV3BaggageTab(
            id: field.key,
            title: text(field.tab) ?? text(field.label) ?? field.key,
            items: field.options.compactMap(baggageItem(from:)),
            quantities: quantities,
            source: source(from: field, agentType: agentType),
            isFound: field.isFound
        )
    }

    private static func baggageItem(from option: ProfileV3AgentOptionDTO) -> ProfileV3BaggageItem? {
        guard let id = option.id else { return nil }
        return ProfileV3BaggageItem(
            id: id,
            title: option.displayLabel,
            detail: option.detail,
            imageURL: remoteURL(option.imageURL),
            isCountable: option.countable == true
        )
    }

    private static func carField(from field: ProfileV3AgentFieldDTO) -> ProfileV3CarField {
        let cars = field.options.compactMap(car(from:))
        let stored = text(field.value?.stringValue)
        let selection = field.selectedOptions.compactMap(\.id).first ?? cars.first { $0.id == stored }?.id
        return ProfileV3CarField(options: cars, selection: selection, detail: field.next?.directive)
    }

    static func ridePicker(_ dto: ProfileV3RidePickerScreenDTO) -> ProfileV3RidePicker {
        ProfileV3RidePicker(
            title: text(dto.title) ?? "",
            subtitle: text(dto.subtitle) ?? "",
            note: text(dto.note) ?? "",
            fieldKey: text(dto.fieldKey) ?? "car_pickup",
            options: dto.options.compactMap(rideOption(from:)),
            footer: text(dto.footer) ?? "",
            regions: dto.regions.compactMap { text($0)?.uppercased() }
        )
    }

    static func rideRegions(_ dto: ProfileV3RideRegionsScreenDTO) -> ProfileV3RideRegions {
        ProfileV3RideRegions(
            title: text(dto.title) ?? "",
            heading: text(dto.heading) ?? "",
            dividerLabel: text(dto.dividerLabel) ?? "",
            regions: dto.regions.enumerated().compactMap { index, region in
                guard let imageURL = remoteURL(region.imageURL) else { return nil }
                let aspect = region.imageAspect?.doubleValue.flatMap { $0 > 0 ? CGFloat($0) : nil }
                return ProfileV3RideRegions.Region(
                    id: "\(index)-\(text(region.country) ?? "")",
                    name: text(region.name) ?? "",
                    imageURL: imageURL,
                    aspectRatio: aspect ?? ProfileV3Theme.Sizes.RideRegions.fallbackAspect
                )
            }
        )
    }

    private static func rideOption(from dto: ProfileV3RideOptionDTO) -> ProfileV3RideOption? {
        guard let id = text(dto.value?.stringValue) else { return nil }
        return ProfileV3RideOption(
            id: id,
            name: text(dto.name) ?? id,
            brand: text(dto.brand),
            spec: text(dto.spec),
            imageURL: remoteURL(dto.imageURL) ?? ProfileV3CarArt.stage(id),
            isSelected: dto.selected == true
        )
    }

    private static func source(from field: ProfileV3AgentFieldDTO, agentType: String?) -> ProfileV3SectionSource? {
        guard let dto = field.source, let next = dto.next, next.go == preferenceSourcesRoute,
              let agentType = text(next.agentType) ?? agentType else { return nil }
        let icons = dto.icons.compactMap { icon in
            (remoteURL(icon.imageURL) ?? remoteURL(icon.key)).map { ProfileV3SourceIcon(url: $0) }
        }
        return ProfileV3SectionSource(
            icons: icons.isEmpty ? [ProfileV3SourceIcon(url: remoteURL(dto.icon))] : icons,
            count: dto.count?.intValue.flatMap { $0 > 0 ? $0 : nil },
            label: text(dto.label),
            agentType: agentType,
            fieldKey: text(next.fieldKey) ?? field.key
        )
    }

    static func preferenceSources(_ dto: ProfileV3PreferenceSourcesDTO) -> ProfileV3PreferenceSources? {
        let steps = dto.steps.enumerated().compactMap { index, step -> ProfileV3SourceStep? in
            guard let title = text(step.title) else { return nil }
            return ProfileV3SourceStep(
                id: index,
                iconURL: remoteURL(step.icon),
                title: title,
                body: text(step.body) ?? "",
                viewsEmails: step.view?.action == viewSourceEmailsAction
            )
        }
        guard let title = text(dto.title), !steps.isEmpty else { return nil }
        return ProfileV3PreferenceSources(title: title, steps: steps)
    }

    private static func control(
        from field: ProfileV3AgentFieldDTO,
        residuals: inout ProfileV3AgentResiduals
    ) -> ProfileV3FormControl? {
        switch field.inputKind {
        case .singleSelect, .multiSelect, .singleSelectAdd, .multiSelectAdd, .chips:
            return showsAsCards(field) ? .cards(cards(from: field)) : .chips(chips(from: field))
        case .slider:
            return .slider(slider(from: field))
        case .text:
            return .text(
                ProfileV3TextFieldValue(value: field.value?.stringValue ?? "", placeholder: placeholder(for: field))
            )
        case .date:
            return date(from: field, residuals: &residuals)
        case .contact:
            let snapshot = contact(from: field)
            residuals.contacts[field.key] = snapshot
            return .text(
                ProfileV3TextFieldValue(
                    value: snapshot.rendered,
                    placeholder: placeholder(for: field),
                    keyboard: snapshot.rendersMobile ? .phone : .text
                )
            )
        case .toggle:
            residuals.passthrough[field.key] = field.value?.boolValue.map(ProfileV3AgentSubmissionValue.bool) ?? .null
            return nil
        case .carPickup:
            return .cars(carField(from: field))
        case .customRules:
            return .customRules(customRules(from: field))
        case .baggageGrid, .none:
            return nil
        }
    }

    private static func customRules(from field: ProfileV3AgentFieldDTO) -> ProfileV3CustomRulesField {
        let editor = field.editor
        let confirm = field.deleteConfirm
        return ProfileV3CustomRulesField(
            rules: (field.value?.list ?? []).compactMap { text($0) },
            addLabel: text(field.addLabel) ?? "",
            editor: ProfileV3CustomRulesField.Editor(
                addTitle: text(editor?.addTitle) ?? "",
                editTitle: text(editor?.editTitle) ?? "",
                noteLabel: text(editor?.noteLabel) ?? "",
                saveLabel: text(editor?.saveLabel) ?? "",
                savedToast: text(editor?.savedToast) ?? "",
                maxCharacters: positive(editor?.maxChars) ?? ProfileV3Theme.Counts.customRuleMaxCharacters
            ),
            deleteConfirm: ProfileV3CustomRulesField.DeleteConfirm(
                title: text(confirm?.title) ?? "",
                confirmLabel: text(confirm?.confirmLabel) ?? "",
                cancelLabel: text(confirm?.cancelLabel) ?? ""
            ),
            maxRules: positive(field.maxRules) ?? ProfileV3Theme.Counts.customRuleMaxRules
        )
    }

    private static func positive(_ scalar: ProfileV3ScalarDTO?) -> Int? {
        guard let value = scalar?.intValue, value > 0 else { return nil }
        return value
    }

    private static func date(
        from field: ProfileV3AgentFieldDTO,
        residuals: inout ProfileV3AgentResiduals
    ) -> ProfileV3FormControl {
        let placeholder = placeholder(for: field)
        let hidesYear = text(field.format) == "dd_mm"
        guard let raw = text(field.value?.stringValue) else {
            return .date(ProfileV3DateField(value: nil, placeholder: placeholder, hidesYear: hidesYear))
        }
        guard let parsed = ProfileV3AgentDateCodec.parse(raw) else {
            return .text(ProfileV3TextFieldValue(value: raw, placeholder: placeholder, isDate: true))
        }
        residuals.dateFormats[field.key] = parsed.format
        let date = hidesYear ? Self.pinnedToAnniversaryYear(parsed.date) : parsed.date
        return .date(ProfileV3DateField(value: date, placeholder: placeholder, hidesYear: hidesYear))
    }

    private static func pinnedToAnniversaryYear(_ date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent
        var parts = calendar.dateComponents([.month, .day], from: date)
        parts.year = 2000
        parts.hour = 12
        return calendar.date(from: parts) ?? date
    }

    private static func showsAsCards(_ field: ProfileV3AgentFieldDTO) -> Bool {
        guard field.inputKind == .singleSelect || field.inputKind == .multiSelect else { return false }
        return field.options.contains { $0.detail != nil }
    }

    private static func cards(from field: ProfileV3AgentFieldDTO) -> ProfileV3CardField {
        ProfileV3CardField(
            options: field.options.compactMap(cardOption(from:)),
            selection: Set(preselectedIDs(of: field)),
            allowsMultiple: field.allowsMultiple
        )
    }

    private static func cardOption(from option: ProfileV3AgentOptionDTO) -> ProfileV3CardOption? {
        guard let id = option.id else { return nil }
        return ProfileV3CardOption(id: id, code: option.displayLabel, detail: option.detail ?? "")
    }

    private static func preselectedIDs(of field: ProfileV3AgentFieldDTO) -> [String] {
        let selected = field.selectedOptions.compactMap(\.id)
        return field.allowsMultiple ? selected : Array(selected.prefix(1))
    }

    private static func chips(from field: ProfileV3AgentFieldDTO) -> ProfileV3ChipField {
        let options = field.options.compactMap(chipOption(from:))
        let preselected = preselectedIDs(of: field)
        let picker = field.offersAdd
            ? ProfileV3OptionPicker(title: pickerTitle(for: field), catalogue: options)
            : nil
        return ProfileV3ChipField(
            options: options,
            selection: Set(preselected),
            allowsMultiple: field.allowsMultiple,
            picker: picker,
            preselectedIDs: preselected
        )
    }

    private static func chipOption(from option: ProfileV3AgentOptionDTO) -> ProfileV3ChipOption? {
        guard let id = option.id else { return nil }
        return ProfileV3ChipOption(
            id: id,
            title: option.displayLabel,
            logoURL: remoteURL(option.imageURL)
        )
    }

    private static func slider(from field: ProfileV3AgentFieldDTO) -> ProfileV3SliderField {
        let bounds = bounds(for: field)
        let raw = field.value?.doubleValue
        let value = raw.map { min(max($0, bounds.range.lowerBound), bounds.range.upperBound) }
            ?? (bounds.range.lowerBound + bounds.range.upperBound) / 2
        let optOut = field.ratherNotSay == true
            ? ProfileV3OptOut(title: ProfileV3Strings.ratherNotSay, isOn: raw == nil)
            : nil
        return ProfileV3SliderField(
            value: value,
            range: bounds.range,
            step: sliderStep(for: field),
            style: bounds.style,
            format: sliderFormat(for: field),
            optOut: optOut
        )
    }

    private static func sliderFormat(for field: ProfileV3AgentFieldDTO) -> ProfileV3SliderField.ValueFormat? {
        if text(field.display) == "ft_in" { return .feetAndInches }
        return text(field.unit).map(ProfileV3SliderField.ValueFormat.unit)
    }

    private static func sliderStep(for field: ProfileV3AgentFieldDTO) -> Double {
        guard let step = number(field.step), step > 0 else { return 1 }
        return step
    }

    private static func bounds(for field: ProfileV3AgentFieldDTO) -> Bounds {
        let captions = [text(field.low), text(field.mid), text(field.high)].compactMap { $0 }
        let style: ProfileV3SliderField.Style = text(field.unit) != nil || captions.isEmpty
            ? .ruler
            : .labels(captions)
        if let low = number(field.min), let high = number(field.max), high > low {
            return Bounds(range: low...high, style: style)
        }
        if let low = number(field.low), let high = number(field.high), high > low {
            return Bounds(range: low...high, style: .ruler)
        }
        return Bounds(range: labelledSliderRange, style: style)
    }

    private static func contact(from field: ProfileV3AgentFieldDTO) -> ProfileV3ContactSnapshot {
        if let contact = field.value?.contact {
            let mobile = text(contact.mobileNumber)
            return ProfileV3ContactSnapshot(
                email: text(contact.email), mobileNumber: mobile, rendersMobile: mobile != nil
            )
        }
        guard let raw = text(field.value?.stringValue) else {
            return ProfileV3ContactSnapshot(email: nil, mobileNumber: nil, rendersMobile: true)
        }
        let isPhone = !raw.contains("@") && raw.contains { $0.isNumber }
        return ProfileV3ContactSnapshot(
            email: isPhone ? nil : raw, mobileNumber: isPhone ? raw : nil, rendersMobile: isPhone
        )
    }

    private static func medicalCard(
        from card: ProfileV3AgentCardDTO?,
        fields: [ProfileV3AgentFieldDTO],
        residuals: inout ProfileV3AgentResiduals
    ) -> ProfileV3MedicalCard? {
        guard let card, card.kind == nil || card.kind == medicalCardKind else { return nil }
        let show = card.show ?? []
        let rows = medicalRows(show, fields: fields)
        let persistsLock = card.lockToggle?.persist ?? true
        residuals.lockScreenFieldKey = persistsLock
            ? medicalFieldKey(show, fields: fields, keywords: ["lock"]) { $0.inputKind == .toggle }
            : nil
        return ProfileV3MedicalCard(
            holderName: text(card.name) ?? text(card.holderName) ?? row(rows, ["name"]) ?? "",
            countryCode: text(card.countryCode) ?? row(rows, ["country", "nation"]) ?? "",
            dateOfBirth: medicalDate(text(card.dob) ?? row(rows, ["dob", "birth"])),
            bloodGroup: row(rows, ["blood"]) ?? "",
            emergencyContact: row(rows, ["emergency"]) ?? "",
            organDonor: row(rows, ["organ", "donor"]).map(yesNo) ?? "",
            showsOnLockScreen: row(rows, ["lock"]) == "true",
            lockToggleTitle: text(card.lockToggle?.label),
            rendersLockToggle: residuals.lockScreenFieldKey != nil,
            bloodGroupSectionID: medicalFieldKey(show, fields: fields, keywords: ["blood"]),
            emergencyContactSectionID: medicalFieldKey(show, fields: fields, keywords: ["emergency"]),
            organDonorSectionID: medicalFieldKey(show, fields: fields, keywords: ["organ", "donor"])
        )
    }

    private static func medicalDate(_ raw: String?) -> String {
        guard let raw else { return "" }
        guard let parsed = ProfileV3AgentDateCodec.parse(raw) else { return raw }
        return ProfileV3AgentDateCodec.string(from: parsed.date, format: .dotted)
    }

    private static func yesNo(_ raw: String) -> String {
        switch raw.lowercased() {
        case "true", "yes": return ProfileV3Strings.yes
        case "false", "no": return ProfileV3Strings.no
        default: return raw
        }
    }

    private static func medicalRows(
        _ show: [String],
        fields: [ProfileV3AgentFieldDTO]
    ) -> [(key: String, value: String)] {
        var seen = Set<String>()
        return show.compactMap { entry in
            let key = normalize(entry)
            guard !key.isEmpty, seen.insert(key).inserted else { return nil }
            return (key, medicalField(entry, fields: fields).map(rowValue(of:)) ?? "")
        }
    }

    private static func medicalField(
        _ entry: String,
        fields: [ProfileV3AgentFieldDTO]
    ) -> ProfileV3AgentFieldDTO? {
        let key = normalize(entry)
        guard !key.isEmpty else { return nil }
        return fields.first { normalize($0.key) == key }
            ?? fields.first { normalize($0.key).contains(key) || key.contains(normalize($0.key)) }
    }

    private static func medicalFieldKey(
        _ show: [String],
        fields: [ProfileV3AgentFieldDTO],
        keywords: [String],
        where matches: (ProfileV3AgentFieldDTO) -> Bool = { _ in true }
    ) -> String? {
        for entry in show where keywords.contains(where: { normalize(entry).contains($0) }) {
            if let field = medicalField(entry, fields: fields), matches(field) { return field.key }
        }
        return nil
    }

    private static func rowValue(of field: ProfileV3AgentFieldDTO) -> String {
        switch field.inputKind {
        case .chips, .singleSelect, .multiSelect, .singleSelectAdd, .multiSelectAdd:
            return field.selectedOptions.map(\.displayLabel).joined(separator: ", ")
        case .toggle:
            return field.value?.boolValue.map { $0 ? "true" : "false" } ?? ""
        case .contact:
            return contact(from: field).rendered
        default:
            return field.value?.stringValue ?? ""
        }
    }

    private static func row(_ rows: [(key: String, value: String)], _ keywords: [String]) -> String? {
        for keyword in keywords {
            let match = rows.first { $0.key == keyword && !$0.value.isEmpty }
                ?? rows.first { $0.key.contains(keyword) && !$0.value.isEmpty }
            if let match { return match.value }
        }
        return nil
    }

    private static func sources(from dto: ProfileV3AgentSourcesDTO?) -> ProfileV3FormSources {
        guard dto?.show == true else { return ProfileV3FormSources(icons: [], count: 0) }
        let icons = (dto?.icons ?? []).map(sourceIcon)
        return ProfileV3FormSources(
            icons: icons,
            count: dto?.count?.intValue ?? icons.count,
            label: text(dto?.label)
        )
    }

    static func sourceIcon(_ dto: ProfileV3AgentSourceDTO) -> ProfileV3SourceIcon {
        ProfileV3SourceIcon(url: remoteURL(dto.imageURL))
    }

    private static func car(from option: ProfileV3AgentOptionDTO) -> ProfileV3CarOption? {
        guard let id = option.id else { return nil }
        return ProfileV3CarOption(
            id: id,
            name: option.displayLabel,
            imageURL: remoteURL(option.imageURL),
            stageImageURL: ProfileV3CarArt.stage(id)
        )
    }

    private static func noun(for agentID: String) -> String {
        agentID.replacingOccurrences(of: "-", with: " ")
    }

    private static func placeholder(for field: ProfileV3AgentFieldDTO) -> String {
        (text(field.label) ?? "").lowercased()
    }

    private static func pickerTitle(for field: ProfileV3AgentFieldDTO) -> String {
        text(field.label).map(ProfileV3Strings.addOption) ?? ""
    }

    private static func number(_ scalar: ProfileV3ScalarDTO?) -> Double? {
        guard let scalar, scalar.boolValue == nil, let raw = scalar.stringValue else { return nil }
        return Double(raw)
    }

    private static func text(_ scalar: ProfileV3ScalarDTO?) -> String? {
        text(scalar?.stringValue)
    }

    private static func normalize(_ value: String) -> String {
        value.lowercased().filter { $0.isLetter || $0.isNumber }
    }
}
