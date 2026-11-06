import Foundation

#if DEBUG
enum ProfileV3CityProfileFixtures {
    static let agentType = ProfileV3CityProfileMapper.agentType

    static let agent = ProfileV3Agent(
        id: agentType,
        name: "city profile",
        summary: "Knows how you travel in each city.",
        avatarURL: nil,
        isActive: false,
        hasData: false,
        foundCount: 0,
        totalCount: 0,
        next: ProfileV3Directive(go: ProfileV3Directive.cityProfileRoute),
        activate: nil
    )

    static let iconBase = "https://media.atlys.com/b2c/ai-native/icons/city"
    static let youIcon = URL(string: "https://media.atlys.com/b2c/ai-native/icons/kyc/you.png?v=1")

    static let catalogue = [
        city("BOM", "Mumbai", "India", country: "IN"),
        city("DEL", "Delhi", "India", country: "IN"),
        city("BLR", "Bengaluru", "India", country: "IN"),
        city("DXB", "Dubai", "United Arab Emirates", country: "AE"),
        city("BKK", "Bangkok", "Thailand", country: "TH"),
        city("HKT", "Phuket", "Thailand", country: "TH"),
        city("SIN", "Singapore", "Singapore", country: "SG"),
        city("LON", "London", "United Kingdom", country: "GB"),
        city("PAR", "Paris", "France", country: "FR"),
        city("NYC", "New York", "United States", country: "US"),
        city("TYO", "Tokyo", "Japan", country: "JP"),
        city("IST", "Istanbul", "Türkiye", country: "TR"),
        city("DPS", "Bali", "Indonesia", country: "ID"),
        city("KUL", "Kuala Lumpur", "Malaysia", country: "MY"),
        city("MLE", "Mal\u{E9}", "Maldives", country: "MV")
    ]

    static let purposeKeys = ["home", "work", "leisure", "other"]

    static func purpose(_ key: String, label: String? = nil) -> ProfileV3CityPurpose {
        let names = ["home": "Home", "work": "Work", "leisure": "Leisure", "other": "Other"]
        let shown = key == "other" ? label?.nonEmpty ?? "Other" : names[key] ?? "Other"
        return ProfileV3CityPurpose(key: key, label: shown, iconURL: URL(string: "\(iconBase)/purpose-\(key).png"))
    }

    static let samples = [
        ProfileV3CitySample(
            code: "BOM",
            name: "Mumbai",
            imageURL: ProfileV3DestinationArt.url(for: "IN"),
            purpose: purpose("home"),
            lines: ["Always book late night flights", "No airport pick-up needed"]
        ),
        ProfileV3CitySample(
            code: "DXB",
            name: "Dubai",
            imageURL: ProfileV3DestinationArt.url(for: "AE"),
            purpose: purpose("work"),
            lines: ["Preferred stay: JW Marriott Marquis", "Always book Emirates"]
        ),
        ProfileV3CitySample(
            code: "HKT",
            name: "Phuket",
            imageURL: ProfileV3DestinationArt.url(for: "TH"),
            purpose: purpose("leisure"),
            lines: ["Airport pick-up: a large car for the family", "Vegetarian Asian flight meal"]
        )
    ]

    static func form(_ values: Values = Values()) -> ProfileV3AgentForm {
        ProfileV3AgentForm(
            agentID: agentType,
            agentTag: "City profile",
            foundCount: values.foundCount,
            totalCount: cardKeys.count,
            noun: "",
            summary: "",
            sources: ProfileV3FormSources(icons: [], count: 0),
            sections: [
                chips(
                    "airlines", "Preferred airlines",
                    options: airlines,
                    selected: values.airlines,
                    picker: ProfileV3OptionPicker(title: "+Add preferred airlines", catalogue: airlines)
                ),
                ProfileV3FormSection(
                    id: "class",
                    title: "Class",
                    status: values.cabin.isEmpty ? .pending : .complete,
                    control: .cards(ProfileV3CardField(
                        options: ["Economy", "Premium economy", "Business", "First class"].map {
                            ProfileV3CardOption(id: $0, code: $0, detail: "")
                        },
                        selection: Set(values.cabin),
                        allowsMultiple: true
                    )),
                    note: flightNote
                ),
                chips(
                    "seat", "Seat selection",
                    options: titled(["Window", "Middle", "Aisle", "Extra legroom", "Cheapest"]),
                    selected: values.seat,
                    optOut: ProfileV3OptOut(title: "Always avoid non-reclining seats", isOn: values.avoidNonReclining, key: "avoid_non_reclining")
                ),
                chips(
                    "timings", "Preferred flight timings",
                    options: ["Early morning", "Morning", "Afternoon", "Evening", "Night", "Late night"].map { title in
                        let slug = title.lowercased().replacingOccurrences(of: " ", with: "-")
                        return ProfileV3ChipOption(id: title, title: title, logoURL: URL(string: "\(iconBase)/timing-\(slug).png"))
                    },
                    selected: values.timings
                ),
                chips(
                    "pickup", "Airport pick-up",
                    options: [ProfileV3ChipOption(id: "private", title: "Private"), ProfileV3ChipOption(id: "public", title: "Public")],
                    selected: values.pickup,
                    optOut: ProfileV3OptOut(title: "No need to book airport pick-up in this city", isOn: values.noPickup, key: "no_pickup"),
                    note: "Your agent uses these preferences to book the right airport pick-up for you."
                ),
                hotels(values.hotels, noStay: values.noStay),
                ProfileV3AgentFixtures.customRulesSection(values.customRules)
            ]
        )
    }

    struct Values: Equatable {
        var airlines: [String] = []
        var cabin: [String] = []
        var seat: [String] = []
        var timings: [String] = []
        var pickup: [String] = []
        var hotels: [String] = []
        var avoidNonReclining = false
        var noPickup = false
        var noStay = false
        var customRules: [String] = []

        var foundCount: Int {
            [airlines, cabin, seat, timings, pickup, hotels].filter { !$0.isEmpty }.count
        }
    }

    static let airlines = [
        ProfileV3ChipOption(id: "emirates", title: "Emirates", logoURL: ProfileV3AgentFixtures.emiratesSourceIcon),
        ProfileV3ChipOption(id: "singapore-airlines", title: "Singapore Airlines"),
        ProfileV3ChipOption(
            id: "etihad",
            title: "Etihad",
            logoURL: URL(string: "https://media.atlys.com/b2c/ai-native/loyalty/flights/etihad_guest.png")
        ),
        ProfileV3ChipOption(id: "thai-airways", title: "Thai Airways"),
        ProfileV3ChipOption(id: "turkish-airlines", title: "Turkish Airlines"),
        ProfileV3ChipOption(id: "qatar-airways", title: "Qatar Airways"),
        ProfileV3ChipOption(id: "air-india", title: "Air India")
    ]

    static let filled = Values(
        airlines: ["emirates", "singapore-airlines"],
        cabin: ["Premium economy"],
        seat: ["Aisle"],
        timings: ["Early morning", "Evening"],
        hotels: ["Taj Lands End", "Trident Nariman Point"],
        noPickup: true,
        customRules: ["Book the 7am Rajdhani when flights are over \u{20B9}12K"]
    )

    static let cardKeys = ["airlines", "class", "seat", "timings", "pickup", "hotels"]

    static let styles: [String: ProfileV3CitySectionStyle] = [
        "airlines": style("airlines", .logos, "The airlines you like to fly to this city"),
        "class": style("class", .tiles, "How you like to fly here"),
        "seat": style("seat", .grid, "Where you like to sit on these flights"),
        "timings": style("timings", .grid, "When you like to fly in and out"),
        "pickup": style("pickup", .grid, "How you get from the airport"),
        "hotels": style("hotels", .rows, "Where you like to stay in this city", maxItems: 20, maxChars: 120)
    ]

    static let tabs = zip(cardKeys, ["Airlines", "Class", "Seat", "Timings", "Pick-up", "Hotels"]).map { key, title in
        ProfileV3CityTab(sectionID: key, title: title, iconURL: URL(string: "\(iconBase)/\(key)-off.png"))
    }

    static func screen(
        id: String,
        result: ProfileV3CitySearchResult,
        purpose: ProfileV3CityPurpose,
        form: ProfileV3AgentForm,
        cities: [ProfileV3CityPorthole]
    ) -> ProfileV3City {
        var form = form
        let scope = ProfileV3PlaceSearchScope(city: result.name, countryCode: result.countryCode)
        for index in form.sections.indices {
            guard case .chips(var field) = form.sections[index].control, field.picker?.typedEntry != nil else { continue }
            field.picker?.typedEntry?.search = scope
            form.sections[index].control = .chips(field)
        }
        let found = form.sections.filter { cardKeys.contains($0.id) && hasValue($0) }.count
        let sourced = form.sections.filter { $0.source != nil }.count
        return ProfileV3City(
            id: id,
            code: result.code,
            name: result.name,
            country: result.country,
            countryCode: result.countryCode,
            imageURL: ProfileV3DestinationArt.url(for: result.countryCode ?? ""),
            purpose: purpose,
            found: ProfileV3CityFound(count: found, total: cardKeys.count, label: "Found \(found)/\(cardKeys.count) preferences"),
            sources: sourced == 0 ? nil : ProfileV3CitySources(
                count: sourced,
                label: sourced == 1 ? "1 source" : "\(sourced) sources",
                icons: [ProfileV3SourceIcon(url: youIcon)]
            ),
            tabs: tabs,
            form: form,
            styles: styles,
            save: ProfileV3BoardAction(fields: [
                "label": .string("save changes"),
                "action": .string(ProfileV3CityProfileMapper.saveAction),
                "city_id": .string(id)
            ]),
            cities: cities
        )
    }

    static func hasValue(_ section: ProfileV3FormSection) -> Bool {
        switch section.control {
        case .chips(let field): return !field.selection.isEmpty
        case .cards(let field): return !field.selection.isEmpty
        default: return false
        }
    }

    private static let flightNote = ProfileV3FormNote(text: "Your agent uses these preferences to prioritize the right flights for you.")

    private static func style(
        _ key: String,
        _ layout: ProfileV3CitySectionStyle.Layout,
        _ subtitle: String,
        maxItems: Int? = nil,
        maxChars: Int? = nil
    ) -> ProfileV3CitySectionStyle {
        ProfileV3CitySectionStyle(
            layout: layout,
            iconURL: URL(string: "\(iconBase)/\(key)-off.png"),
            activeIconURL: URL(string: "\(iconBase)/\(key)-on.png"),
            subtitle: subtitle,
            maxItems: maxItems,
            maxChars: maxChars
        )
    }

    private static func hotels(_ names: [String], noStay: Bool) -> ProfileV3FormSection {
        let options = names.map { ProfileV3ChipOption(id: $0, title: $0, place: .hotel) }
        return ProfileV3FormSection(
            id: "hotels",
            title: "Preferred hotels",
            status: names.isEmpty ? .pending : .complete,
            control: .chips(ProfileV3ChipField(
                options: options,
                selection: Set(names),
                picker: ProfileV3OptionPicker(
                    title: "+Add preferred hotels",
                    catalogue: options,
                    typedEntry: ProfileV3OptionPicker.TypedEntry(maxItems: 20, maxChars: 120, place: .hotel)
                ),
                preselectedIDs: names,
                optOut: ProfileV3OptOut(title: "Do not book stay in this city", isOn: noStay, key: "no_stay")
            )),
            note: ProfileV3FormNote(text: "Your agent uses these preferences to find the right stay for you.")
        )
    }

    private static func city(_ code: String, _ name: String, _ countryName: String, country: String) -> ProfileV3CitySearchResult {
        ProfileV3CitySearchResult(code: code, name: name, country: countryName, countryCode: country)
    }

    private static func titled(_ titles: [String]) -> [ProfileV3ChipOption] {
        titles.map { ProfileV3ChipOption(id: $0, title: $0) }
    }

    private static func chips(
        _ id: String,
        _ title: String,
        options: [ProfileV3ChipOption],
        selected: [String] = [],
        picker: ProfileV3OptionPicker? = nil,
        optOut: ProfileV3OptOut? = nil,
        note: String? = nil
    ) -> ProfileV3FormSection {
        ProfileV3FormSection(
            id: id,
            title: title,
            status: selected.isEmpty ? .pending : .complete,
            control: .chips(ProfileV3ChipField(
                options: options,
                selection: Set(selected),
                picker: picker,
                preselectedIDs: selected,
                optOut: optOut
            )),
            note: note.map { ProfileV3FormNote(text: $0) } ?? flightNote
        )
    }
}

final class ProfileV3CityProfileStore: @unchecked Sendable {
    struct Entry: Equatable {
        let id: String
        let code: String
        var purpose: String
        var label: String?
        var form: ProfileV3AgentForm
    }

    static let shared = ProfileV3CityProfileStore()
    static let latency: Duration = .milliseconds(500)
    static let pageSize = 20

    private let lock = NSLock()
    private var entries: [Entry]
    private var nextID: Int
    private let catalogue: [ProfileV3CitySearchResult]

    init(
        entries: [Entry] = ProfileV3CityProfileStore.sampleEntries,
        catalogue: [ProfileV3CitySearchResult] = ProfileV3CityProfileFixtures.catalogue
    ) {
        self.entries = entries
        self.catalogue = catalogue
        nextID = entries.count + 1
    }

    static let sampleEntries = [
        Entry(id: "c1", code: "BOM", purpose: "home", form: ProfileV3CityProfileFixtures.form(ProfileV3CityProfileFixtures.filled)),
        Entry(id: "c2", code: "BKK", purpose: "leisure", form: ProfileV3CityProfileFixtures.form())
    ]

    func profile() -> ProfileV3CityProfile {
        lock.withLock {
            ProfileV3CityProfile(
                title: "City profile",
                cities: portholes(),
                add: ProfileV3CityAddSlot(label: "ADD", detail: "Frequent destination"),
                headline: "Your travel style, tailored to the city you\u{2019}re in.",
                samples: ProfileV3CityProfileFixtures.samples
            )
        }
    }

    func city(_ cityID: String) throws -> ProfileV3City {
        try lock.withLock {
            guard let entry = entries.first(where: { $0.id == cityID }), let result = result(entry.code) else {
                throw ProfileV3Error.server(code: "unknown_city", message: "This city profile isn\u{2019}t there anymore.")
            }
            return ProfileV3CityProfileFixtures.screen(
                id: entry.id,
                result: result,
                purpose: ProfileV3CityProfileFixtures.purpose(entry.purpose, label: entry.label),
                form: entry.form,
                cities: portholes()
            )
        }
    }

    func picker(_ query: String, offset: Int, pageSize: Int = ProfileV3CityProfileStore.pageSize) -> ProfileV3CityPicker {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let matches = trimmed.isEmpty ? catalogue : catalogue.filter { result in
            [result.name, result.code, result.country ?? ""].contains { $0.localizedCaseInsensitiveContains(trimmed) }
        }
        let start = min(max(offset, 0), matches.count)
        let end = min(start + pageSize, matches.count)
        return ProfileV3CityPicker(
            title: "+ City profile",
            searchPlaceholder: "Search",
            heading: trimmed.isEmpty ? "POPULAR CITIES" : "",
            emptyTitle: "No city found",
            emptySubtitle: "Try the city\u{2019}s name or its 3-letter code.",
            query: query,
            offset: start,
            nextOffset: end < matches.count ? end : nil,
            results: Array(matches[start..<end])
        )
    }

    func purposeSheet(code: String, cityID: String?) throws -> ProfileV3CityPurposeSheet {
        try lock.withLock {
            let editing = cityID.flatMap { id in entries.first { $0.id == id } }
            guard let result = result(editing?.code ?? code) else {
                throw ProfileV3Error.server(code: "unknown_city_code", message: "Pick a city from the list.")
            }
            let others = entries.filter { $0.id != editing?.id }
            let taken = Set(others.map(\.purpose).filter { $0 != "other" })
            let options = ProfileV3CityProfileFixtures.purposeKeys.map { key -> ProfileV3CityPurposeSheet.Option in
                let purpose = ProfileV3CityProfileFixtures.purpose(key)
                return ProfileV3CityPurposeSheet.Option(
                    key: key,
                    label: purpose.label,
                    iconURL: purpose.iconURL,
                    isDisabled: taken.contains(key),
                    isSelected: editing?.purpose == key,
                    input: key == "other"
                        ? .init(label: "Purpose", placeholder: "e.g. Visiting parents", maxChars: 30, value: editing?.purpose == "other" ? editing?.label : nil)
                        : nil
                )
            }
            let submit: ProfileV3BoardAction
            var delete: ProfileV3CityPurposeSheet.Delete?
            if let editing {
                submit = ProfileV3BoardAction(fields: ["action": .string("update_city_purpose"), "city_id": .string(editing.id)])
                delete = ProfileV3CityPurposeSheet.Delete(
                    label: "Delete city profile",
                    action: ProfileV3BoardAction(fields: ["action": .string("delete_city_profile"), "city_id": .string(editing.id)]),
                    confirm: ProfileV3CityDeleteConfirm(
                        title: "Delete \(result.name)?",
                        message: "Your preferences for this city will be removed.",
                        confirmLabel: "Delete",
                        cancelLabel: "Cancel"
                    )
                )
            } else {
                submit = ProfileV3BoardAction(fields: ["action": .string("create_city_profile"), "code": .string(result.code)])
            }
            return ProfileV3CityPurposeSheet(
                title: result.name.uppercased(),
                city: .init(code: result.code, name: result.name, countryCode: result.countryCode, imageURL: ProfileV3DestinationArt.url(for: result.countryCode ?? "")),
                options: options,
                usedLabels: others.compactMap { $0.purpose == "other" ? $0.label : nil },
                labelTaken: "You already use this for another city.",
                submitLabel: editing == nil ? "Continue" : "Save",
                submit: submit,
                delete: delete
            )
        }
    }

    func submit(_ action: ProfileV3BoardAction, purpose: String, label: String?) throws -> String {
        try lock.withLock {
            let cityID = action.fields["city_id"]?.stringValue
            let others = entries.filter { $0.id != cityID }
            let trimmed = label?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
            if purpose == "other" {
                guard let trimmed else { throw ProfileV3Error.invalidRequest(message: "Type a purpose.") }
                let folded = ProfileV3CityPurposeSheet.folded(trimmed)
                if others.contains(where: { $0.purpose == "other" && $0.label.map(ProfileV3CityPurposeSheet.folded) == folded }) {
                    throw ProfileV3Error.conflict(code: "label_taken", message: "You already use \u{201C}\(trimmed)\u{201D} for another city.")
                }
            } else if others.contains(where: { $0.purpose == purpose }) {
                throw ProfileV3Error.conflict(code: "purpose_taken", message: "You already have a \(purpose) city. Pick another purpose.")
            }
            switch action.name {
            case "update_city_purpose":
                guard let index = entries.firstIndex(where: { $0.id == cityID }) else {
                    throw ProfileV3Error.server(code: "unknown_city", message: "This city profile isn\u{2019}t there anymore.")
                }
                entries[index].purpose = purpose
                entries[index].label = purpose == "other" ? trimmed : nil
                return entries[index].id
            default:
                guard let code = action.fields["code"]?.stringValue, result(code) != nil else {
                    throw ProfileV3Error.invalidRequest(message: "Pick a city from the list.")
                }
                let id = "c\(nextID)"
                nextID += 1
                entries.insert(
                    Entry(id: id, code: code, purpose: purpose, label: purpose == "other" ? trimmed : nil, form: ProfileV3CityProfileFixtures.form()),
                    at: 0
                )
                return id
            }
        }
    }

    func delete(_ action: ProfileV3BoardAction) {
        lock.withLock {
            entries.removeAll { $0.id == action.fields["city_id"]?.stringValue }
        }
    }

    func save(_ form: ProfileV3AgentForm, cityID: String) throws {
        try lock.withLock {
            guard let index = entries.firstIndex(where: { $0.id == cityID }) else {
                throw ProfileV3Error.server(code: "unknown_city", message: "This city profile isn\u{2019}t there anymore.")
            }
            entries[index].form = form
        }
    }

    func snapshot() -> [Entry] {
        lock.withLock { entries }
    }

    private func portholes() -> [ProfileV3CityPorthole] {
        entries.compactMap { entry in
            guard let result = result(entry.code) else { return nil }
            return ProfileV3CityPorthole(
                id: entry.id,
                code: result.code,
                name: result.name,
                country: result.country,
                countryCode: result.countryCode,
                imageURL: ProfileV3DestinationArt.url(for: result.countryCode ?? ""),
                purpose: ProfileV3CityProfileFixtures.purpose(entry.purpose, label: entry.label)
            )
        }
    }

    private func result(_ code: String) -> ProfileV3CitySearchResult? {
        catalogue.first { $0.code == code }
    }
}
#endif
