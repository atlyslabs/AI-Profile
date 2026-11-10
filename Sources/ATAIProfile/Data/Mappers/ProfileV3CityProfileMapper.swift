import Foundation

enum ProfileV3CityProfileMapper: ProfileV3DTOReading {
    static let agentType = "city"
    static let sourcesRoute = "city_preference_sources"
    static let saveAction = "save_city_preferences"

    static func profile(_ dto: ProfileV3CityProfilesDTO) -> ProfileV3CityProfile {
        ProfileV3CityProfile(
            title: text(dto.title) ?? "",
            cities: dto.cities.compactMap(porthole),
            add: ProfileV3CityAddSlot(label: text(dto.add?.label) ?? "", detail: text(dto.add?.subtitle) ?? ""),
            headline: text(dto.headline) ?? "",
            samples: dto.samples.compactMap(sample)
        )
    }

    static func porthole(_ dto: ProfileV3CityPortholeDTO) -> ProfileV3CityPorthole? {
        guard let id = text(dto.id) ?? text(dto.next?.cityID), let code = text(dto.code) else { return nil }
        return ProfileV3CityPorthole(
            id: id,
            code: code,
            name: text(dto.name) ?? code,
            country: text(dto.country),
            countryCode: text(dto.countryCode),
            imageURL: remoteURL(dto.imageURL),
            purpose: purpose(dto.purpose)
        )
    }

    static func picker(_ dto: ProfileV3CityPickerDTO) -> ProfileV3CityPicker {
        ProfileV3CityPicker(
            title: text(dto.title) ?? "",
            searchPlaceholder: text(dto.searchPlaceholder) ?? "",
            heading: text(dto.heading) ?? "",
            emptyTitle: text(dto.searchEmpty?.title) ?? "",
            emptySubtitle: text(dto.searchEmpty?.subtitle) ?? "",
            query: dto.query ?? "",
            offset: max(dto.offset ?? 0, 0),
            nextOffset: dto.nextOffset,
            results: dto.results.compactMap { row in
                guard let code = text(row.code) else { return nil }
                return ProfileV3CitySearchResult(
                    code: code,
                    name: text(row.name) ?? code,
                    country: text(row.country),
                    countryCode: text(row.countryCode)
                )
            }
        )
    }

    static func purposeSheet(_ dto: ProfileV3CityPurposeSheetDTO) -> ProfileV3CityPurposeSheet? {
        guard let code = text(dto.city?.code), let submit = dto.submit else { return nil }
        let options = dto.options.compactMap { option -> ProfileV3CityPurposeSheet.Option? in
            guard let key = text(option.key), let label = text(option.label) else { return nil }
            return ProfileV3CityPurposeSheet.Option(
                key: key,
                label: label,
                iconURL: remoteURL(option.iconURL),
                isDisabled: option.disabled == true,
                isSelected: option.selected == true,
                input: option.input.map { input in
                    ProfileV3CityPurposeSheet.Option.Input(
                        label: text(input.label) ?? "",
                        placeholder: text(input.placeholder) ?? "",
                        maxChars: input.maxChars.flatMap { $0 > 0 ? $0 : nil } ?? Int.max,
                        value: text(input.value)
                    )
                }
            )
        }
        guard !options.isEmpty else { return nil }
        return ProfileV3CityPurposeSheet(
            title: text(dto.title) ?? "",
            city: ProfileV3CityPurposeSheet.City(
                code: code,
                name: text(dto.city?.name) ?? code,
                countryCode: text(dto.city?.countryCode),
                imageURL: remoteURL(dto.city?.imageURL)
            ),
            options: options,
            usedLabels: dto.usedLabels.compactMap { text($0) },
            labelTaken: text(dto.labelTaken) ?? "",
            submitLabel: text(submit.label) ?? "",
            submit: ProfileV3PersonaMapper.action(submit.submit),
            delete: dto.delete.flatMap { delete in
                guard let label = text(delete.action.label), let confirm = delete.confirm else { return nil }
                return ProfileV3CityPurposeSheet.Delete(
                    label: label,
                    action: ProfileV3PersonaMapper.action(delete.action.submit),
                    confirm: ProfileV3CityDeleteConfirm(
                        title: text(confirm.title) ?? label,
                        message: text(confirm.body),
                        confirmLabel: text(confirm.confirmLabel) ?? label,
                        cancelLabel: text(confirm.cancelLabel) ?? ""
                    )
                )
            }
        )
    }

    static func city(_ dto: ProfileV3CityScreenDTO, cityID: String) -> ProfileV3City? {
        guard let code = text(dto.city?.code) else { return nil }
        let id = text(dto.cityID) ?? cityID
        let name = text(dto.city?.name) ?? code
        let scope = ProfileV3PlaceSearchScope(city: name, countryCode: text(dto.city?.countryCode))
        var sections: [ProfileV3FormSection] = []
        var styles: [String: ProfileV3CitySectionStyle] = [:]
        var cardTabs: [ProfileV3CityTab] = []
        for card in dto.fields {
            guard let mapped = section(card, scope: scope) else { continue }
            sections.append(mapped.section)
            styles[mapped.section.id] = mapped.style
            if let tab = card.tab, let title = text(tab.label) {
                cardTabs.append(ProfileV3CityTab(sectionID: mapped.section.id, title: title, iconURL: remoteURL(tab.iconURL)))
            }
        }
        if let rules = dto.customRules, rules.inputKind == .customRules {
            sections.append(ProfileV3FormSection(
                id: rules.key,
                title: rules.label ?? "",
                status: rules.isFound ? .complete : .pending,
                control: .customRules(ProfileV3AgentMapper.customRules(from: rules))
            ))
        }
        let sectionIDs = Set(sections.map(\.id))
        let tabs = dto.tabs.compactMap { tab -> ProfileV3CityTab? in
            guard let key = text(tab.key), sectionIDs.contains(key), let title = text(tab.label) else { return nil }
            return ProfileV3CityTab(sectionID: key, title: title, iconURL: remoteURL(tab.iconURL))
        }
        let found = dto.found.flatMap { found -> ProfileV3CityFound? in
            guard let label = text(found.label) else { return nil }
            return ProfileV3CityFound(count: found.count?.intValue ?? 0, total: found.total?.intValue ?? 0, label: label)
        }
        let sourceIcons = (dto.sources?.icons ?? []).compactMap(icon)
        let sources = dto.sources.flatMap { sources -> ProfileV3CitySources? in
            guard let label = text(sources.label), let count = sources.count?.intValue, count > 0 else { return nil }
            return ProfileV3CitySources(count: count, label: label, icons: sourceIcons)
        }
        return ProfileV3City(
            id: id,
            code: code,
            name: name,
            country: text(dto.city?.country),
            countryCode: scope.countryCode,
            imageURL: remoteURL(dto.city?.imageURL),
            purpose: purpose(dto.purpose),
            editsPurpose: dto.purpose?.edit?.next?.go != nil,
            found: found,
            sources: sources,
            tabs: tabs.isEmpty ? cardTabs : tabs,
            form: ProfileV3AgentForm(
                agentID: agentType,
                agentTag: text(dto.title) ?? "",
                foundCount: found?.count ?? 0,
                totalCount: found?.total ?? 0,
                noun: "",
                summary: "",
                sources: ProfileV3FormSources(icons: sourceIcons, count: sources?.count ?? 0, label: sources?.label),
                sections: sections
            ),
            styles: styles,
            save: dto.save.map(ProfileV3PersonaMapper.action),
            cities: dto.cities.compactMap(porthole)
        )
    }

    static func cityID(fromWrite data: Data) -> String? {
        text((try? JSONDecoder().decode(ProfileV3CityWriteDTO.self, from: data))?.cityID)
    }

    private static func purpose(_ dto: ProfileV3CityPurposeDTO?) -> ProfileV3CityPurpose {
        ProfileV3CityPurpose(
            key: text(dto?.key) ?? "",
            label: text(dto?.label) ?? "",
            iconURL: remoteURL(dto?.iconURL)
        )
    }

    private static func sample(_ dto: ProfileV3CitySampleDTO) -> ProfileV3CitySample? {
        guard let code = text(dto.code) else { return nil }
        return ProfileV3CitySample(
            code: code,
            name: text(dto.name) ?? code,
            imageURL: remoteURL(dto.imageURL),
            purpose: purpose(dto.purpose),
            lines: dto.lines.compactMap { text($0) }
        )
    }

    private static func section(
        _ card: ProfileV3CityCardDTO,
        scope: ProfileV3PlaceSearchScope
    ) -> (section: ProfileV3FormSection, style: ProfileV3CitySectionStyle)? {
        let field = card.field
        let layout = layout(of: card)
        let control: ProfileV3FormControl
        if field.input == freeListInput {
            control = .chips(freeList(card, scope: scope))
        } else if field.inputKind?.allowsMultiple != nil || field.inputKind == .chips {
            if layout == .tiles {
                control = .cards(tiles(card))
            } else {
                var chips = ProfileV3AgentMapper.chips(from: field)
                let art = optionArt(card)
                chips.options = chips.options.map { option in
                    var option = option
                    option.selectedLogoURL = remoteURL(art[option.id]?.selectedImageURL)
                    return option
                }
                chips.optOut = optOut(card)
                control = .chips(chips)
            }
        } else {
            return nil
        }
        let section = ProfileV3FormSection(
            id: field.key,
            title: field.label ?? "",
            status: field.isFound ? .complete : .pending,
            control: control,
            note: text(card.footer).map { ProfileV3FormNote(text: $0) },
            source: source(field)
        )
        let style = ProfileV3CitySectionStyle(
            layout: layout,
            iconURL: remoteURL(card.icon?.inactiveURL),
            activeIconURL: remoteURL(card.icon?.activeURL),
            subtitle: text(card.subtitle),
            maxItems: card.maxItems,
            maxChars: card.maxChars
        )
        return (section, style)
    }

    private static let freeListInput = "free_list"
    private static let hotelSearch = "client_hotels"

    private static func layout(of card: ProfileV3CityCardDTO) -> ProfileV3CitySectionStyle.Layout {
        switch text(card.layout) {
        case "chips_with_icon": return text(card.add?.search) == nil ? .grid : .logos
        case "tiles": return .tiles
        case "rows": return .rows
        default: return card.field.input == freeListInput ? .rows : .grid
        }
    }

    private static func optionArt(_ card: ProfileV3CityCardDTO) -> [String: ProfileV3CityOptionArtDTO] {
        Dictionary(
            card.optionArt.compactMap { art in art.value?.stringValue.map { ($0, art) } },
            uniquingKeysWith: { first, _ in first }
        )
    }

    private static func tiles(_ card: ProfileV3CityCardDTO) -> ProfileV3CardField {
        let art = optionArt(card)
        let field = card.field
        return ProfileV3CardField(
            options: field.options.compactMap { option in
                guard let id = option.id else { return nil }
                return ProfileV3CardOption(
                    id: id,
                    code: option.displayLabel,
                    detail: "",
                    imageURL: remoteURL(art[id]?.imageURL),
                    selectedImageURL: remoteURL(art[id]?.selectedImageURL)
                )
            },
            selection: Set(ProfileV3AgentMapper.preselectedIDs(of: field)),
            allowsMultiple: field.allowsMultiple
        )
    }

    private static func freeList(_ card: ProfileV3CityCardDTO, scope: ProfileV3PlaceSearchScope) -> ProfileV3ChipField {
        var seen = Set<String>()
        let names = (card.field.value?.list ?? []).compactMap { text($0) }.filter {
            seen.insert(ProfileV3CityPurposeSheet.folded($0)).inserted
        }
        let searchesHotels = text(card.add?.search) == hotelSearch
        let place: ProfileV3ChipOption.Place? = searchesHotels ? .hotel : nil
        let options = names.map { ProfileV3ChipOption(id: $0, title: $0, place: place) }
        return ProfileV3ChipField(
            options: options,
            selection: Set(names),
            allowsMultiple: true,
            picker: ProfileV3OptionPicker(
                title: text(card.field.label).map(ProfileV3Strings.addOption) ?? "",
                catalogue: options,
                typedEntry: ProfileV3OptionPicker.TypedEntry(
                    maxItems: card.maxItems.flatMap { $0 > 0 ? $0 : nil } ?? Int.max,
                    maxChars: card.maxChars.flatMap { $0 > 0 ? $0 : nil } ?? Int.max,
                    place: place,
                    search: searchesHotels ? scope : nil
                )
            ),
            preselectedIDs: names,
            optOut: optOut(card)
        )
    }

    private static func optOut(_ card: ProfileV3CityCardDTO) -> ProfileV3OptOut? {
        guard let dto = card.optOut, let key = text(dto.key), let title = text(dto.label) else { return nil }
        return ProfileV3OptOut(title: title, isOn: dto.value == true, key: key)
    }

    private static func source(_ field: ProfileV3AgentFieldDTO) -> ProfileV3SectionSource? {
        guard let dto = field.source, let next = dto.next, next.go == sourcesRoute else { return nil }
        return ProfileV3SectionSource(
            icons: dto.icons.compactMap(icon),
            count: dto.count?.intValue.flatMap { $0 > 0 ? $0 : nil },
            label: text(dto.label),
            agentType: agentType,
            fieldKey: text(next.fieldKey) ?? field.key
        )
    }

    private static func icon(_ dto: ProfileV3AgentSourceDTO) -> ProfileV3SourceIcon? {
        (remoteURL(dto.imageURL) ?? remoteURL(dto.key)).map { ProfileV3SourceIcon(url: $0) }
    }
}

enum ProfileV3CitySubmission {
    static func values(for form: ProfileV3AgentForm) -> [String: ProfileV3AgentSubmissionValue] {
        var values: [String: ProfileV3AgentSubmissionValue] = [:]
        for section in form.sections {
            switch section.control {
            case .chips(let field):
                let order = (field.options + (field.picker?.catalogue ?? [])).map(\.id)
                values[section.id] = .list(ordered(field.selection, by: order))
                if let optOut = field.optOut, let key = optOut.key {
                    values[key] = .bool(optOut.isOn)
                }
            case .cards(let field):
                values[section.id] = .list(ordered(field.selection, by: field.options.map(\.id)))
            case .customRules(let field):
                values[section.id] = .list(field.rules)
            case .slider, .text, .date, .passport, .cars, .baggage:
                continue
            }
        }
        return values
    }

    private static func ordered(_ selection: Set<String>, by order: [String]) -> [String] {
        var seen = Set<String>()
        var ids = order.filter { selection.contains($0) && seen.insert($0).inserted }
        ids.append(contentsOf: selection.subtracting(ids).sorted())
        return ids
    }
}
