import Foundation

#if DEBUG
enum ProfileV3CityProfileFixtures {
    static let agentType = "city_profile"

    static let agent = ProfileV3Agent(
        id: agentType,
        name: "City profile",
        summary: "added 2 cuisines for upcoming trip",
        avatarURL: nil,
        isActive: false,
        hasData: false,
        foundCount: 0,
        totalCount: 0,
        next: ProfileV3Directive(go: agentType),
        activate: ProfileV3Directive(go: agentType)
    )

    static let tags = [
        ProfileV3CityTagOption(id: "home", label: "Home", icon: "home"),
        ProfileV3CityTagOption(id: "work", label: "Work", icon: "work"),
        ProfileV3CityTagOption(id: "leisure", label: "Leisure", icon: "golf_course"),
        ProfileV3CityTagOption(id: "other", label: "Other", icon: "edit", asksPurpose: true)
    ]

    static let catalogue = [
        city("BOM", "Mumbai", "India", country: "IN"),
        city("DEL", "Delhi", "India", country: "IN"),
        city("BLR", "Bengaluru", "India", country: "IN"),
        city("DXB", "Dubai", "United Arab Emirates", country: "AE"),
        city("BKK", "Bangkok", "Thailand", country: "TH"),
        city("HKT", "Phuket", "Thailand", country: "TH"),
        city("SIN", "Singapore", "Singapore", country: "SG"),
        city("LHR", "London", "United Kingdom", country: "GB"),
        city("CDG", "Paris", "France", country: "FR"),
        city("JFK", "New York", "United States", country: "US"),
        city("NRT", "Tokyo", "Japan", country: "JP"),
        city("IST", "Istanbul", "Turkey", country: "TR"),
        city("DPS", "Bali", "Indonesia", country: "ID"),
        city("KUL", "Kuala Lumpur", "Malaysia", country: "MY"),
        city("MLE", "Mal\u{E9}", "Maldives", country: "MV")
    ]

    static var profile: ProfileV3CityProfile {
        ProfileV3CityProfile(
            cities: [
                makeCity(catalogue[0], tag: ProfileV3CityTag(id: "home"), filled: true),
                makeCity(catalogue[4], tag: ProfileV3CityTag(id: "leisure"), filled: true)
            ],
            tags: tags,
            addSlot: ProfileV3CityAddSlot(label: "Add", detail: "Frequent destination"),
            intro: intro,
            purpose: ProfileV3CityPurpose(label: "Purpose of visit*", placeholder: "Parent\u{2019}s home", saveLabel: "Save"),
            continueLabel: "Continue",
            deleteConfirm: ProfileV3CityDeleteConfirm(
                title: "Are you sure you want to delete city profile",
                confirmLabel: "Delete city profile",
                cancelLabel: "Keep city profile"
            )
        )
    }

    static var empty: ProfileV3CityProfile {
        var profile = profile
        profile.cities = []
        return profile
    }

    static let intro = ProfileV3CityIntro(
        title: "Your travel style, tailored to the city you\u{2019}re in.",
        samples: [
            ProfileV3CityIntro.Sample(
                id: "BOM",
                code: "BOM",
                name: "Mumbai",
                imageURL: ProfileV3DestinationArt.url(for: "IN"),
                tag: "Home",
                tagIcon: "home",
                highlights: ["Always book late night flights", "No airport pick up needed"]
            ),
            ProfileV3CityIntro.Sample(
                id: "DXB",
                code: "DXB",
                name: "Dubai",
                imageURL: ProfileV3DestinationArt.url(for: "AE"),
                tag: "Work",
                tagIcon: "work",
                highlights: ["Preferred stay: JW Marriott, Marquis", "Always book Emirates, no check in bags"]
            ),
            ProfileV3CityIntro.Sample(
                id: "HKT",
                code: "HKT",
                name: "Phuket",
                imageURL: ProfileV3DestinationArt.url(for: "TH"),
                tag: "Leisure",
                tagIcon: "golf_course",
                highlights: ["Airport Pick up - Grab XL - 12 seats", "Vegetarian asian flight meal"]
            )
        ]
    )

    static let sources = [
        ProfileV3SourceIcon(url: ProfileV3AgentFixtures.gmailSourceIcon),
        ProfileV3SourceIcon(url: ProfileV3AgentFixtures.emiratesSourceIcon)
    ]

    static let styles: [String: ProfileV3CitySectionStyle] = [
        "preferred_airlines": ProfileV3CitySectionStyle(layout: .logos, icon: "flight", tab: .init(title: "Airlines", icon: "flight")),
        "cabin_class": ProfileV3CitySectionStyle(layout: .cards, icon: "airplane_ticket", tab: .init(title: "Class", icon: "airplane_ticket")),
        "seat_preference": ProfileV3CitySectionStyle(
            icon: "airline_seat_recline_extra",
            tab: .init(title: "Seat", icon: "airline_seat_recline_extra")
        ),
        "dietary_style": ProfileV3CitySectionStyle(icon: "restaurant", tab: .init(title: "Dietary style", icon: "restaurant")),
        "flight_timings": ProfileV3CitySectionStyle(icon: "flight_takeoff", tab: .init(title: "Timings", icon: "flight_takeoff")),
        "time_value_per_hour": ProfileV3CitySectionStyle(
            layout: .slider,
            icon: "payments",
            tab: .init(title: "Fast or affordable", icon: "payments"),
            subtitle: "Set how much you\u{2019}re willing to pay to save time in transit."
        ),
        "airport_pickup": ProfileV3CitySectionStyle(icon: "hail", tab: .init(title: "Pick up", icon: "hail")),
        "preferred_hotels": ProfileV3CitySectionStyle(
            layout: .places,
            icon: "hotel",
            tab: .init(title: "Hotels", icon: "hotel"),
            subtitle: "Your usual hotels. Your kind of neighborhood. Your agent keeps track."
        )
    ]

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

    static func makeCity(_ result: ProfileV3CitySearchResult, tag: ProfileV3CityTag, filled: Bool) -> ProfileV3City {
        let form = form(code: result.code, filled: filled)
        return ProfileV3City(
            id: result.id,
            code: result.code,
            name: result.name,
            country: result.country,
            imageURL: result.imageURL,
            tag: tag,
            form: form,
            styles: styles,
            sources: filled ? source("city") : nil,
            isUpdating: !filled
        )
    }

    static func form(code: String, filled: Bool) -> ProfileV3AgentForm {
        let places = places(for: code)
        return ProfileV3AgentForm(
            agentID: agentType,
            agentTag: "City profile",
            foundCount: filled ? 6 : 0,
            totalCount: 8,
            noun: "flight",
            summary: "",
            sources: ProfileV3FormSources(icons: filled ? sources : [], count: filled ? 3 : 0),
            sections: [
                chips(
                    "preferred_airlines", "Preferred Airlines",
                    options: Array(airlines.prefix(2)),
                    selected: filled ? ["emirates", "singapore-airlines"] : [],
                    picker: ProfileV3OptionPicker(title: "+Add preferred airlines", catalogue: airlines),
                    note: flightNote,
                    source: filled ? source("preferred_airlines") : nil
                ),
                ProfileV3FormSection(
                    id: "cabin_class",
                    title: "Class",
                    status: filled ? .complete : .pending,
                    control: .cards(ProfileV3CardField(
                        options: [
                            ProfileV3CardOption(id: "economy", code: "Economy", detail: ""),
                            ProfileV3CardOption(id: "premium_economy", code: "Premium Economy", detail: ""),
                            ProfileV3CardOption(id: "business", code: "Business", detail: ""),
                            ProfileV3CardOption(id: "first", code: "First", detail: "")
                        ],
                        selection: filled ? ["premium_economy"] : []
                    )),
                    note: ProfileV3FormNote(text: flightNote),
                    source: filled ? source("cabin_class") : nil
                ),
                chips(
                    "seat_preference", "Seat selection",
                    options: titled(["Window", "Aisle", "Extra Leg room", "Cheapest"]),
                    optOut: "Always avoid non-reclining seats",
                    note: flightNote
                ),
                chips(
                    "dietary_style", "Dietary style",
                    options: titled(["Vegetarian", "Vegan", "Jain", "Halal"]),
                    selected: filled ? ["vegetarian"] : [],
                    note: flightNote,
                    source: filled ? source("dietary_style") : nil
                ),
                chips(
                    "flight_timings", "Preferred flight timings",
                    options: [
                        ProfileV3ChipOption(id: "early_morning", title: "Early morning"),
                        ProfileV3ChipOption(id: "morning", title: "Morning"),
                        ProfileV3ChipOption(id: "noon", title: "Noon"),
                        ProfileV3ChipOption(id: "evening", title: "Evening"),
                        ProfileV3ChipOption(id: "night", title: "Night"),
                        ProfileV3ChipOption(id: "late_night", title: "Late night")
                    ],
                    selected: filled ? ["early_morning", "morning", "evening"] : [],
                    note: flightNote,
                    source: filled ? source("flight_timings") : nil
                ),
                ProfileV3FormSection(
                    id: "time_value_per_hour",
                    title: "Fast or affordable",
                    status: filled ? .complete : .pending,
                    control: .slider(ProfileV3SliderField(
                        value: 100,
                        range: 0...200,
                        step: 10,
                        format: .money(symbol: "$", unit: "/hour"),
                        isSet: filled
                    )),
                    note: ProfileV3FormNote(text: flightNote),
                    source: filled ? source("time_value_per_hour") : nil
                ),
                chips(
                    "airport_pickup", "Airport Pick up",
                    options: titled(["Private", "Public"]),
                    allowsMultiple: false,
                    optOut: "No need to book airport pick-up in this city",
                    note: flightNote
                ),
                chips(
                    "preferred_hotels", "Preferred Hotels",
                    options: Array(places.prefix(2)),
                    selected: filled ? Array(places.prefix(2)).map(\.id) : [],
                    picker: ProfileV3OptionPicker(title: "Add preferred hotel", catalogue: places, listLabel: "Popular locations"),
                    optOut: "Do not book stay in this city",
                    note: "Your agent uses these preferences to prioritize the right stays for you."
                ),
                ProfileV3AgentFixtures.customRulesSection(filled ? ["Book the 7am Rajdhani when flights are over \u{20B9}12K"] : [])
            ]
        )
    }

    private static let flightNote = "Your agent uses these preferences to prioritize the right flights for you."

    private static func places(for code: String) -> [ProfileV3ChipOption] {
        switch code {
        case "BOM":
            return [
                ProfileV3ChipOption(id: "taj-lands-end", title: "Taj Lands End", subtitle: "Bandra West", place: .hotel),
                ProfileV3ChipOption(id: "bandra-west", title: "Bandra West", subtitle: "Location", place: .location),
                ProfileV3ChipOption(id: "colaba", title: "Colaba", subtitle: "South Mumbai", place: .location),
                ProfileV3ChipOption(id: "lower-parel", title: "Lower Parel", subtitle: "Central Mumbai", place: .location),
                ProfileV3ChipOption(id: "trident-nariman", title: "Trident Nariman Point", subtitle: "South Mumbai", place: .hotel)
            ]
        case "DEL":
            return [
                ProfileV3ChipOption(id: "fairleys", title: "Fairleys Hotel and Resort, Chattarpur", subtitle: "Central Delhi", place: .hotel),
                ProfileV3ChipOption(id: "chhatarpur-farm-road", title: "Chhatarpur Farm Road", subtitle: "Location", place: .location),
                ProfileV3ChipOption(id: "hauz-khas", title: "Hauz Khas", subtitle: "South Delhi", place: .location),
                ProfileV3ChipOption(id: "connaught-place", title: "Connaught Place", subtitle: "Central Delhi", place: .location)
            ]
        default:
            return [
                ProfileV3ChipOption(id: "\(code.lowercased())-old-town", title: "Old Town", subtitle: "Location", place: .location),
                ProfileV3ChipOption(id: "\(code.lowercased())-marriott", title: "Marriott", subtitle: "City centre", place: .hotel),
                ProfileV3ChipOption(id: "\(code.lowercased())-airport", title: "Near the airport", subtitle: "Location", place: .location),
                ProfileV3ChipOption(id: "\(code.lowercased())-hyatt", title: "Hyatt Regency", subtitle: "Business district", place: .hotel)
            ]
        }
    }

    private static func city(_ code: String, _ name: String, _ countryName: String, country: String) -> ProfileV3CitySearchResult {
        ProfileV3CitySearchResult(
            id: code,
            code: code,
            name: name,
            country: countryName,
            imageURL: ProfileV3DestinationArt.url(for: country)
        )
    }

    private static func source(_ fieldKey: String) -> ProfileV3SectionSource {
        ProfileV3SectionSource(icons: sources, count: 3, agentType: agentType, fieldKey: fieldKey)
    }

    private static func titled(_ titles: [String]) -> [ProfileV3ChipOption] {
        titles.map { ProfileV3ChipOption(id: $0.lowercased().replacingOccurrences(of: " ", with: "_"), title: $0) }
    }

    private static func chips(
        _ id: String,
        _ title: String,
        options: [ProfileV3ChipOption],
        selected: [String] = [],
        allowsMultiple: Bool = true,
        picker: ProfileV3OptionPicker? = nil,
        optOut: String? = nil,
        note: String,
        source: ProfileV3SectionSource? = nil
    ) -> ProfileV3FormSection {
        ProfileV3FormSection(
            id: id,
            title: title,
            status: selected.isEmpty ? .pending : .complete,
            control: .chips(ProfileV3ChipField(
                options: options,
                selection: Set(selected),
                allowsMultiple: allowsMultiple,
                picker: picker,
                optOut: optOut.map { ProfileV3OptOut(title: $0, isOn: false) }
            )),
            note: ProfileV3FormNote(text: note),
            source: source
        )
    }
}

final class ProfileV3CityProfileStore: @unchecked Sendable {
    static let shared = ProfileV3CityProfileStore()
    static let latency: Duration = .milliseconds(500)

    private let lock = NSLock()
    private var profile: ProfileV3CityProfile
    private let catalogue: [ProfileV3CitySearchResult]

    init(
        profile: ProfileV3CityProfile = ProfileV3CityProfileFixtures.profile,
        catalogue: [ProfileV3CitySearchResult] = ProfileV3CityProfileFixtures.catalogue
    ) {
        self.profile = profile
        self.catalogue = catalogue
    }

    func snapshot() -> ProfileV3CityProfile {
        lock.withLock { profile }
    }

    func search(_ query: String) -> [ProfileV3CitySearchResult] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return catalogue }
        return catalogue.filter { result in
            [result.name, result.code, result.country ?? ""].contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    func add(_ cityID: String, tag: ProfileV3CityTag) throws -> ProfileV3CityProfile {
        guard let result = catalogue.first(where: { $0.id == cityID }) else {
            throw ProfileV3Error.invalidRequest(message: nil)
        }
        return try mutate { profile in
            guard profile.city(id: cityID) == nil else {
                throw ProfileV3Error.server(code: "city_exists", message: nil)
            }
            profile.cities.append(ProfileV3CityProfileFixtures.makeCity(result, tag: tag, filled: false))
        }
    }

    func updateTag(_ cityID: String, tag: ProfileV3CityTag) throws -> ProfileV3CityProfile {
        try mutate { profile in
            guard let index = profile.cities.firstIndex(where: { $0.id == cityID }) else {
                throw ProfileV3Error.invalidRequest(message: nil)
            }
            profile.cities[index].tag = tag
        }
    }

    func delete(_ cityID: String) -> ProfileV3CityProfile {
        (try? mutate { $0.cities.removeAll { $0.id == cityID } }) ?? snapshot()
    }

    func save(_ form: ProfileV3AgentForm, cityID: String) throws {
        _ = try mutate { profile in
            guard let index = profile.cities.firstIndex(where: { $0.id == cityID }) else {
                throw ProfileV3Error.invalidRequest(message: nil)
            }
            profile.cities[index].form = form
            profile.cities[index].isUpdating = false
        }
    }

    private func mutate(_ change: (inout ProfileV3CityProfile) throws -> Void) throws -> ProfileV3CityProfile {
        try lock.withLock {
            var draft = profile
            try change(&draft)
            profile = draft
            return draft
        }
    }
}
#endif
