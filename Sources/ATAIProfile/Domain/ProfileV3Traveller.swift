import Foundation

struct ProfileV3Traveller: Identifiable, Equatable {
    let id: String
    var firstName: String
    var lastName: String
    var passNumber: String
    var passportNumber = ""
    var isMain: Bool
    var dialCode: String
    var phoneDigits: String
    var regionISO: String

    var displayName: String {
        let full = [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
        return full.isEmpty ? ProfileV3Strings.travellerFallbackName : full
    }

    var shortName: String { Self.shortName(firstName: firstName, lastName: lastName) }

    static func shortName(firstName: String, lastName: String) -> String {
        guard !firstName.isEmpty else { return lastName.isEmpty ? ProfileV3Strings.travellerFallbackName : lastName }
        return initialled(firstName, lastName: lastName)
    }

    static func shortName(fullName: String) -> String {
        let parts = fullName.split(whereSeparator: \.isWhitespace)
        guard let first = parts.first else { return fullName }
        return initialled(String(first), lastName: parts.dropFirst().first.map(String.init) ?? "")
    }

    private static func initialled(_ firstName: String, lastName: String) -> String {
        guard let initial = lastName.first else { return firstName.lowercased() }
        return "\(firstName.lowercased()) \(String(initial).lowercased())."
    }

    var mobileNumber: String {
        ProfileV3ContactDetails.mobileNumber(dialCode: dialCode, digits: phoneDigits) ?? ""
    }

    var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
            && !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    static let empty = ProfileV3Traveller(
        id: "",
        firstName: "",
        lastName: "",
        passNumber: "",
        isMain: false,
        dialCode: "",
        phoneDigits: "",
        regionISO: ""
    )

    init(row: ProfileV3TravellerRow) {
        let parts = row.name.split(separator: " ", maxSplits: 1).map(String.init)
        let phone = PhoneCodeResolver.resolve(row.mobileNumber)
        id = row.id
        firstName = parts.first ?? ""
        lastName = parts.count > 1 ? parts[1] : ""
        passNumber = row.passNumber
        passportNumber = row.passportNumber ?? ""
        isMain = row.isMain
        dialCode = phone.dialCode
        phoneDigits = phone.digits
        regionISO = phone.regionISO
    }

    init(
        id: String,
        firstName: String,
        lastName: String,
        passNumber: String,
        passportNumber: String = "",
        isMain: Bool,
        dialCode: String,
        phoneDigits: String,
        regionISO: String
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.passNumber = passNumber
        self.passportNumber = passportNumber
        self.isMain = isMain
        self.dialCode = dialCode
        self.phoneDigits = phoneDigits
        self.regionISO = regionISO
    }
}

public struct ProfileV3StoredTraveller: Equatable, Sendable {
    public let firstName: String
    public let lastName: String
    public let email: String?
    public var citizenshipCode: String?

    public init(firstName: String, lastName: String, email: String?, citizenshipCode: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.citizenshipCode = citizenshipCode
    }

    func matches(_ name: String) -> Bool {
        Self.normalized("\(firstName) \(lastName)") == Self.normalized(name)
    }

    private static func normalized(_ name: String) -> String {
        name.split(whereSeparator: \.isWhitespace).joined(separator: " ").lowercased()
    }
}

enum ProfileV3PassportNumber {
    static func isValid(_ number: String, citizenship: ProfileV3Country?) -> Bool {
        let trimmed = number.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        return ProfileV3FieldValidation.isValidPassportNumber(trimmed, nationality: citizenship?.name)
    }

    static func error(for number: String, citizenship: ProfileV3Country?) -> String? {
        guard !isValid(number, citizenship: citizenship) else { return nil }
        return citizenship == .india ? ProfileV3Strings.indianPassportInvalid : ProfileV3Strings.passportInvalid
    }
}
