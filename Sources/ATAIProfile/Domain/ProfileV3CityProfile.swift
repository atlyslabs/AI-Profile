import Foundation

struct ProfileV3CityProfile: Equatable {
    var cities: [ProfileV3City]
    var tags: [ProfileV3CityTagOption]
    var addSlot: ProfileV3CityAddSlot
    var intro: ProfileV3CityIntro
    var purpose: ProfileV3CityPurpose
    var continueLabel: String
    var deleteConfirm: ProfileV3CityDeleteConfirm

    func city(id: String?) -> ProfileV3City? {
        cities.first { $0.id == id }
    }

    func tag(id: String?) -> ProfileV3CityTagOption? {
        tags.first { $0.id == id }
    }

    func taggedCount(_ tagID: String, excluding cityID: String? = nil) -> Int {
        cities.filter { $0.tag.id == tagID && $0.id != cityID }.count
    }

    func tagLabel(for city: ProfileV3City) -> String {
        if let purpose = city.tag.purpose?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty {
            return purpose
        }
        guard let option = tag(id: city.tag.id) else { return "" }
        let count = taggedCount(option.id)
        return count > 1 ? ProfileV3Strings.cityTagCount(option.label, count) : option.label
    }
}

struct ProfileV3City: Identifiable, Equatable {
    let id: String
    let code: String
    let name: String
    var country: String?
    var imageURL: URL?
    var tag: ProfileV3CityTag
    var form: ProfileV3AgentForm
    var styles: [String: ProfileV3CitySectionStyle] = [:]
    var sources: ProfileV3SectionSource?
    var isUpdating = false

    func style(for sectionID: String) -> ProfileV3CitySectionStyle {
        styles[sectionID] ?? ProfileV3CitySectionStyle()
    }

    var tabs: [ProfileV3CitySectionStyle.Tab] {
        form.sections.compactMap { section in
            styles[section.id]?.tab.map { ProfileV3CitySectionStyle.Tab(sectionID: section.id, title: $0.title, icon: $0.icon) }
        }
    }
}

struct ProfileV3CityTag: Equatable, Sendable {
    let id: String
    var purpose: String?
}

struct ProfileV3CityTagOption: Identifiable, Equatable {
    let id: String
    let label: String
    var icon: String?
    var asksPurpose = false
}

struct ProfileV3CitySectionStyle: Equatable {
    enum Layout: Equatable {
        case logos
        case grid
        case cards
        case places
        case slider
    }

    struct Tab: Identifiable, Equatable {
        var sectionID = ""
        let title: String
        var icon: String?

        var id: String { sectionID }
    }

    var layout = Layout.grid
    var icon: String?
    var tab: Tab?
    var subtitle: String?
}

struct ProfileV3CityAddSlot: Equatable {
    let label: String
    let detail: String
}

struct ProfileV3CityIntro: Equatable {
    struct Sample: Identifiable, Equatable {
        let id: String
        let code: String
        let name: String
        var imageURL: URL?
        let tag: String
        var tagIcon: String?
        var highlights: [String]
    }

    let title: String
    var samples: [Sample]
}

struct ProfileV3CityPurpose: Equatable {
    let label: String
    let placeholder: String
    let saveLabel: String
}

struct ProfileV3CityDeleteConfirm: Equatable {
    let title: String
    let confirmLabel: String
    let cancelLabel: String
}

struct ProfileV3CitySearchResult: Identifiable, Equatable {
    let id: String
    let code: String
    let name: String
    var country: String?
    var imageURL: URL?
    var logoURL: URL?
}

extension ProfileV3CitySearchResult {
    var option: ProfileV3ChipOption {
        ProfileV3ChipOption(id: id, title: "\(name) (\(code))", logoURL: logoURL ?? imageURL, subtitle: country)
    }
}
