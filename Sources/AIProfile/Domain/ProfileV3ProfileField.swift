import Foundation

enum ProfileV3ProfileField: String, CaseIterable {
    case residence
    case citizenship
    case contact
    case currency

    var isAccountScoped: Bool { self == .currency }
}

enum ContactUpdateOutcome: Equatable {
    case success
    case duplicateEmail
    case failure
}

struct ProfileV3ContactDetails: Equatable {
    var email: String
    var phoneDigits: String
    var regionISO: String
    var dialCode: String

    var mobileNumber: String {
        Self.mobileNumber(dialCode: dialCode, digits: phoneDigits) ?? ""
    }

    static func mobileNumber(dialCode: String, digits: String) -> String? {
        digits.isEmpty ? nil : "+\(dialCode)\(digits)"
    }
}
