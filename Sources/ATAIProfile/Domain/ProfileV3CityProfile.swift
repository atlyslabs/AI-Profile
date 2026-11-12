import Foundation

struct ProfileV3CityProfile: Equatable {
    var title: String
    var cities: [ProfileV3CityPorthole]
    var add: ProfileV3CityAddSlot
    var headline: String
    var samples: [ProfileV3CitySample]

    func city(id: String?) -> ProfileV3CityPorthole? {
        cities.first { $0.id == id }
    }
}

struct ProfileV3CityPorthole: Identifiable, Equatable {
    let id: String
    let code: String
    let name: String
    var country: String?
    var countryCode: String?
    var imageURL: URL?
    var purpose: ProfileV3CityPurpose
}

struct ProfileV3CityPurpose: Equatable {
    let key: String
    let label: String
    var iconURL: URL?
}

struct ProfileV3CityAddSlot: Equatable {
    let label: String
    let detail: String
}

struct ProfileV3CitySample: Identifiable, Equatable {
    let code: String
    let name: String
    var imageURL: URL?
    var purpose: ProfileV3CityPurpose
    var lines: [String]

    var id: String { code }
}

struct ProfileV3City: Identifiable, Equatable {
    let id: String
    let code: String
    let name: String
    var country: String?
    var countryCode: String?
    var imageURL: URL?
    var purpose: ProfileV3CityPurpose
    var editsPurpose = true
    var found: ProfileV3CityFound?
    var sources: ProfileV3CitySources?
    var tabs: [ProfileV3CityTab] = []
    var form: ProfileV3AgentForm
    var styles: [String: ProfileV3CitySectionStyle] = [:]
    var save: ProfileV3BoardAction?
    var cities: [ProfileV3CityPorthole] = []

    func style(for sectionID: String) -> ProfileV3CitySectionStyle {
        styles[sectionID] ?? ProfileV3CitySectionStyle()
    }
}

struct ProfileV3CityFound: Equatable {
    let count: Int
    let total: Int
    let label: String
}

struct ProfileV3CitySources: Equatable {
    let count: Int
    let label: String
    var icons: [ProfileV3SourceIcon]
}

struct ProfileV3CityTab: Identifiable, Equatable {
    let sectionID: String
    let title: String
    var iconURL: URL?

    var id: String { sectionID }
}

struct ProfileV3CitySectionStyle: Equatable {
    enum Layout: Equatable {
        case logos
        case grid
        case tiles
        case rows
    }

    var layout = Layout.grid
    var iconURL: URL?
    var activeIconURL: URL?
    var subtitle: String?
    var maxItems: Int?
    var maxChars: Int?
}

struct ProfileV3CityPicker: Equatable {
    let title: String
    let searchPlaceholder: String
    let heading: String
    let emptyTitle: String
    let emptySubtitle: String
    let query: String
    let offset: Int
    let nextOffset: Int?
    var results: [ProfileV3CitySearchResult]
}

struct ProfileV3CitySearchResult: Identifiable, Equatable {
    let code: String
    let name: String
    var country: String?
    var countryCode: String?

    var id: String { Self.key(code: code, name: name, countryCode: countryCode) }
    var title: String { code.isEmpty ? name : "\(name) (\(code))" }

    static func key(code: String, name: String, countryCode: String?) -> String {
        guard code.isEmpty else { return code }
        let folded = name.split(whereSeparator: \.isWhitespace).joined(separator: " ")
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
        return "\(folded)|\((countryCode ?? "").uppercased())"
    }
}

struct ProfileV3CityPurposeSheet: Equatable {
    struct City: Equatable {
        let code: String
        let name: String
        var countryCode: String?
        var imageURL: URL?
    }

    struct Option: Identifiable, Equatable {
        struct Input: Equatable {
            let label: String
            let placeholder: String
            let maxChars: Int
            var value: String?
        }

        let key: String
        let label: String
        var iconURL: URL?
        var isDisabled = false
        var isSelected = false
        var input: Input?

        var id: String { key }
    }

    struct Delete: Equatable {
        let label: String
        let action: ProfileV3BoardAction
        let confirm: ProfileV3CityDeleteConfirm
        var iconURL: URL?
    }

    let title: String
    let city: City
    var options: [Option]
    var usedLabels: [String]
    let labelTaken: String
    let submitLabel: String
    let submit: ProfileV3BoardAction
    var delete: Delete?

    var isEditing: Bool { delete != nil }

    func option(key: String?) -> Option? {
        options.first { $0.key == key }
    }

    func isLabelUsed(_ label: String) -> Bool {
        let folded = Self.folded(label)
        return !folded.isEmpty && usedLabels.contains { Self.folded($0) == folded }
    }

    static func folded(_ label: String) -> String {
        label.split(whereSeparator: \.isWhitespace).joined(separator: " ").lowercased()
    }
}

struct ProfileV3CityDeleteConfirm: Equatable {
    let title: String
    var message: String?
    let confirmLabel: String
    let cancelLabel: String
    var iconURL: URL?
}
