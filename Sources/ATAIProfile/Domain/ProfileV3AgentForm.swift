import Foundation

enum ProfileV3AgentFlow: Equatable {
    case preferences(ProfileV3AgentForm)
}

struct ProfileV3HouseholdPrompt: Equatable, Sendable {
    var eyebrow: String
    var iconURL: URL?
    var title: String
    var travellers: [Traveller]
    var confirmLabel: String

    struct Traveller: Identifiable, Equatable, Sendable {
        let id: String
        var name: String
        var passNumber: String
        var isSelected: Bool
    }
}

struct ProfileV3AgentForm: Equatable {
    let agentID: String
    let agentTag: String
    let foundCount: Int
    let totalCount: Int
    let noun: String
    let summary: String
    let sources: ProfileV3FormSources
    var medicalCard: ProfileV3MedicalCard?
    var household: ProfileV3HouseholdPrompt?
    var sections: [ProfileV3FormSection]
}

struct ProfileV3SourceIcon: Equatable {
    var url: URL? = nil
}

struct ProfileV3FormSources: Equatable {
    let icons: [ProfileV3SourceIcon]
    let count: Int
    var label: String? = nil
}

struct ProfileV3FormSection: Identifiable, Equatable {
    enum Status: Equatable {
        case complete
        case pending
    }

    let id: String
    let title: String
    var status: Status?
    var control: ProfileV3FormControl
    var note: ProfileV3FormNote?
    var source: ProfileV3SectionSource?
}

struct ProfileV3SectionSource: Equatable {
    let icons: [ProfileV3SourceIcon]
    var count: Int? = nil
    var label: String? = nil
    let agentType: String
    let fieldKey: String
}

struct ProfileV3PreferenceSources: Equatable {
    let title: String
    let steps: [ProfileV3SourceStep]
}

struct ProfileV3SourceStep: Identifiable, Equatable {
    let id: Int
    let iconURL: URL?
    let title: String
    let body: String
    var viewsEmails = false
}

struct ProfileV3FormNote: Equatable {
    enum Icon: Equatable {
        case agent
        case sources
    }

    struct Link: Equatable {
        let text: String
        let directive: ProfileV3Directive
    }

    let text: String
    var icon: Icon = .agent
    var link: Link?
}

enum ProfileV3FormControl: Equatable {
    case chips(ProfileV3ChipField)
    case cards(ProfileV3CardField)
    case slider(ProfileV3SliderField)
    case text(ProfileV3TextFieldValue)
    case date(ProfileV3DateField)
    case passport(ProfileV3PassportField)
    case cars(ProfileV3CarField)
    case baggage(ProfileV3BaggageField)
}

struct ProfileV3CarField: Equatable {
    let options: [ProfileV3CarOption]
    var selection: String?
    var detail: ProfileV3Directive?

    var selectedCar: ProfileV3CarOption? { options.first { $0.id == selection } }
}

struct ProfileV3RideOption: Identifiable, Equatable {
    let id: String
    let name: String
    var brand: String?
    var spec: String?
    var imageURL: URL?
    var isSelected = false
}

struct ProfileV3RidePicker: Equatable {
    let title: String
    let subtitle: String
    let note: String
    let fieldKey: String
    let options: [ProfileV3RideOption]
    let footer: String
    var regions: [String] = []

    func isEligible(region: String?) -> Bool {
        guard !regions.isEmpty, let region else { return true }
        return regions.contains { $0.caseInsensitiveCompare(region) == .orderedSame }
    }
}

struct ProfileV3RideRegions: Equatable {
    struct Region: Identifiable, Equatable {
        let id: String
        let name: String
        let imageURL: URL?
        let aspectRatio: CGFloat
    }

    let title: String
    let heading: String
    let dividerLabel: String
    let regions: [Region]
}

struct ProfileV3BaggageItem: Identifiable, Equatable {
    let id: String
    let title: String
    var detail: String?
    var imageURL: URL?
    var isCountable = false
}

struct ProfileV3BaggageTab: Identifiable, Equatable {
    let id: String
    let title: String
    let items: [ProfileV3BaggageItem]
    var quantities: [String: Int]
    var source: ProfileV3SectionSource?
    var isFound = false

    var hasSelection: Bool { quantities.values.contains { $0 > 0 } }

    func quantity(of itemID: String) -> Int { quantities[itemID] ?? 0 }

    mutating func setQuantity(_ quantity: Int, of itemID: String) {
        quantities[itemID] = quantity > 0 ? quantity : nil
    }
}

struct ProfileV3BaggageField: Equatable {
    var tabs: [ProfileV3BaggageTab]

    var hasSelection: Bool { tabs.contains(where: \.hasSelection) }

    func tab(id: String?) -> ProfileV3BaggageTab? {
        tabs.first { $0.id == id } ?? tabs.first
    }

    mutating func updateTab(id: String?, _ change: (inout ProfileV3BaggageTab) -> Void) {
        guard let target = tab(id: id)?.id, let index = tabs.firstIndex(where: { $0.id == target }) else { return }
        change(&tabs[index])
    }
}

extension ProfileV3FormSection {
    func source(selectedTab tabID: String?) -> ProfileV3SectionSource? {
        guard case .baggage(let field) = control else { return source }
        return field.tab(id: tabID)?.source
    }
}

struct ProfileV3ChipOption: Identifiable, Hashable {
    let id: String
    let title: String
    var logoURL: URL?
}

struct ProfileV3ChipField: Equatable {
    var options: [ProfileV3ChipOption]
    var selection: Set<String>
    var allowsMultiple = true
    var picker: ProfileV3OptionPicker?
    var preselectedIDs: [String] = []

    func visibleOptions(limit: Int) -> [ProfileV3ChipOption] {
        guard picker != nil else { return options }
        return orderedOptions.count > limit ? selectedOptions : orderedOptions
    }

    func remainingOptions(limit: Int) -> [ProfileV3ChipOption] {
        let shown = Set(visibleOptions(limit: limit).map(\.id))
        return orderedOptions.filter { !shown.contains($0.id) }
    }

    var selectedOptions: [ProfileV3ChipOption] {
        orderedOptions.filter { selection.contains($0.id) }
    }

    var allOptions: [ProfileV3ChipOption] { orderedOptions }

    private var orderedOptions: [ProfileV3ChipOption] {
        var seen = Set<String>()
        let all = (options + (picker?.catalogue ?? [])).filter { seen.insert($0.id).inserted }
        let preselected = Set(preselectedIDs)
        return all.filter { preselected.contains($0.id) } + all.filter { !preselected.contains($0.id) }
    }
}

struct ProfileV3OptionPicker: Equatable {
    let title: String
    var catalogue: [ProfileV3ChipOption]
}

struct ProfileV3CardOption: Identifiable, Equatable {
    let id: String
    let code: String
    let detail: String
}

struct ProfileV3CardField: Equatable {
    var options: [ProfileV3CardOption]
    var selection: Set<String>
    var allowsMultiple = false
}

struct ProfileV3SliderField: Equatable {
    enum Style: Equatable {
        case ruler
        case labels([String])
    }

    enum ValueFormat: Equatable {
        case unit(String)
        case centimetres
        case feetAndInches
        case levels([String])
    }

    var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    var style: Style = .ruler
    var format: ValueFormat?
    var optOut: ProfileV3OptOut?

    var fraction: Double {
        guard range.upperBound > range.lowerBound else { return 0 }
        return (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    func value(atFraction fraction: Double) -> Double {
        let raw = range.lowerBound + min(max(fraction, 0), 1) * (range.upperBound - range.lowerBound)
        guard step > 0, range.upperBound > range.lowerBound else { return range.lowerBound }
        let stepped = ((raw - range.lowerBound) / step).rounded() * step + range.lowerBound
        return min(max(stepped, range.lowerBound), range.upperBound)
    }
}

struct ProfileV3OptOut: Equatable {
    let title: String
    var isOn: Bool
}

struct ProfileV3TextFieldValue: Equatable {
    enum Keyboard: Equatable {
        case phone
        case text
    }

    var value: String
    let placeholder: String
    var keyboard: Keyboard = .text
    var isDate = false
}

struct ProfileV3DateField: Equatable {
    var value: Date?
    let placeholder: String
    var hidesYear = false
}

struct ProfileV3MedicalCard: Equatable {
    let holderName: String
    let countryCode: String
    let dateOfBirth: String
    var bloodGroup: String
    var emergencyContact: String
    var organDonor: String
    var showsOnLockScreen: Bool
    var lockToggleTitle: String? = nil
    var rendersLockToggle = true
    var bloodGroupSectionID: String? = nil
    var emergencyContactSectionID: String? = nil
    var organDonorSectionID: String? = nil
}

extension ProfileV3AgentForm {
    var liveMedicalCard: ProfileV3MedicalCard? {
        guard var card = medicalCard else { return nil }
        card.bloodGroup = liveValue(of: card.bloodGroupSectionID) ?? card.bloodGroup
        card.emergencyContact = liveValue(of: card.emergencyContactSectionID) ?? card.emergencyContact
        card.organDonor = liveValue(of: card.organDonorSectionID) ?? card.organDonor
        return card
    }

    private func liveValue(of sectionID: String?) -> String? {
        guard let sectionID, let section = sections.first(where: { $0.id == sectionID }) else { return nil }
        switch section.control {
        case .chips(let field):
            return field.selectedOptions.map(\.title).joined(separator: ", ")
        case .text(let field):
            return field.value.trimmingCharacters(in: .whitespacesAndNewlines)
        case .cards, .slider, .date, .passport, .cars, .baggage:
            return nil
        }
    }
}

struct ProfileV3CarOption: Identifiable, Equatable {
    let id: String
    let name: String
    var imageURL: URL?
    var stageImageURL: URL?
}
