import Foundation

struct ProfileV3TravellerRow: Identifiable, Equatable {
    let id: String
    let name: String
    let passNumber: String
    var passportNumber: String?
    var mobileNumber: String?
    var citizenshipCode: String?
    var relationship: String?
    var relationshipEntry: ProfileV3RelationshipEntry?
    let isMain: Bool
    var badgeImageURL: URL?
    var isDeletable = false

    var citizenship: ProfileV3Country? { citizenshipCode.flatMap { ProfileV3Country(code: $0) } }
}

struct ProfileV3RelationshipEntry: Equatable {
    let label: String
    let profileID: String

    static func title(for value: String) -> String {
        let spaced = value.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: "-", with: " ")
        return spaced.prefix(1).uppercased() + spaced.dropFirst()
    }
}

struct ProfileV3EditTravellersScreen: Equatable {
    let title: String
    var travellers: [ProfileV3TravellerRow]
    let addLabel: String

    mutating func setRelationship(_ value: String?, for profileID: String) {
        guard let index = travellers.firstIndex(where: { $0.id == profileID }) else { return }
        travellers[index].relationship = value
    }
}

struct ProfileV3DeleteTravellerConfirm: Equatable {
    let profileID: String
    let name: String
    let title: String
    let body: String
    let proceedLabel: String
    let cancelLabel: String
}

struct ProfileV3AddTravellerOption: Identifiable, Equatable {
    let value: String
    let title: String
    var isMinor = false

    var id: String { value }
}

struct ProfileV3AddTravellerField: Identifiable, Equatable {
    static let firstNameKey = "first_name"
    static let lastNameKey = "last_name"
    static let passportNumberKey = "passport_number"
    static let mobileNumberKey = "mobile_number"
    static let citizenshipKey = "citizenship"
    static let relationshipKey = "relationship"

    static let dedicatedKeys: Set<String> = [passportNumberKey, mobileNumberKey, citizenshipKey]

    enum Input: String, Equatable {
        case text
        case singleSelect = "single_select"
        case countryPicker = "country_picker"
    }

    let key: String
    let label: String
    let input: Input
    var isRequired = false
    var options: [ProfileV3AddTravellerOption] = []

    var id: String { key }
}

struct ProfileV3AddTravellerScreen: Equatable {
    let title: String
    let subtitle: String
    let fields: [ProfileV3AddTravellerField]
    let submitLabel: String

    func field(_ key: String) -> ProfileV3AddTravellerField? {
        fields.first { $0.key == key }
    }
}

struct ProfileV3AddTravellerSubmission: Equatable {
    var firstName = ""
    var lastName = ""
    var selections: [String: String] = [:]
    var regionISO = ""
    var dialCode = ""
    var phoneDigits = ""
    var passportNumber = ""
    var citizenship: ProfileV3Country?
    var otherText: [String: String] = [:]

    var relationship: String? { selections[ProfileV3AddTravellerField.relationshipKey] }

    var mobileNumber: String? {
        ProfileV3ContactDetails.mobileNumber(dialCode: dialCode, digits: phoneDigits)
    }

    var shortName: String {
        ProfileV3Traveller.shortName(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    subscript(text key: String) -> String {
        get {
            switch key {
            case ProfileV3AddTravellerField.firstNameKey: return firstName
            case ProfileV3AddTravellerField.lastNameKey: return lastName
            case ProfileV3AddTravellerField.passportNumberKey: return passportNumber
            default: return otherText[key] ?? ""
            }
        }
        set {
            switch key {
            case ProfileV3AddTravellerField.firstNameKey: firstName = newValue
            case ProfileV3AddTravellerField.lastNameKey: lastName = newValue
            case ProfileV3AddTravellerField.passportNumberKey: passportNumber = newValue
            default: otherText[key] = newValue
            }
        }
    }

    var passportNumberValue: String? {
        passportNumber.trimmingCharacters(in: .whitespacesAndNewlines).uppercased().nonEmpty
    }

    func value(for field: ProfileV3AddTravellerField) -> String? {
        switch field.key {
        case ProfileV3AddTravellerField.mobileNumberKey: return mobileNumber
        case ProfileV3AddTravellerField.citizenshipKey: return citizenship?.code
        default: break
        }
        switch field.input {
        case .singleSelect: return selections[field.key]
        case .text, .countryPicker: return self[text: field.key]
        }
    }

    mutating func toggle(_ option: ProfileV3AddTravellerOption, in field: ProfileV3AddTravellerField) {
        selections[field.key] = selections[field.key] == option.value ? nil : option.value
    }

    func canSubmit(fields: [ProfileV3AddTravellerField]) -> Bool {
        let required = fields.filter(\.isRequired)
        guard !required.isEmpty else { return canSubmit }
        return required.allSatisfy { field in
            !(value(for: field) ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var canSubmit: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var passportError: String? {
        ProfileV3PassportNumber.error(for: passportNumber, citizenship: citizenship)
    }
}
