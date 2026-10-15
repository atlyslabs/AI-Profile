import ATUIKit
import Foundation

extension LoginCountryOption {
    static let profileV3Options: [LoginCountryOption] = ATCountry.allCases
        .compactMap { country in
            PhoneCodeResolver.dialCode(forRegion: country.rawValue).map {
                LoginCountryOption(country: country, dialCode: "+\($0)")
            }
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

    static func matching(regionISO: String, dialCode: String) -> LoginCountryOption {
        let expectedDialCode = "+\(dialCode)"
        let match = profileV3Options.first { $0.country.rawValue == regionISO && $0.dialCode == expectedDialCode }
        if let match {
            return match
        }
        if let country = ATCountry(isoCode: regionISO) {
            return LoginCountryOption(country: country, dialCode: expectedDialCode)
        }
        return .india
    }

    static func isValidPhone(digits: String, regionISO: String) -> Bool {
        digits.allSatisfy { $0.isASCII && $0.isNumber }
            && phoneDigitRange(for: ATCountry(isoCode: regionISO)).contains(digits.count)
            && PhoneCodeResolver.isValidPhoneNumber(digits, withRegion: regionISO)
    }
}

extension ProfileV3AddTravellerSubmission {
    var phoneOption: LoginCountryOption {
        LoginCountryOption.matching(regionISO: regionISO, dialCode: dialCode)
    }

    var isPhoneValid: Bool {
        phoneDigits.isEmpty || LoginCountryOption.isValidPhone(digits: phoneDigits, regionISO: regionISO)
    }

    mutating func selectDial(_ option: LoginCountryOption) {
        regionISO = option.country.rawValue
        dialCode = option.dialCode.replacingOccurrences(of: "+", with: "")
    }
}

extension ProfileV3ContactDetails {
    var phoneOption: LoginCountryOption {
        LoginCountryOption.matching(regionISO: regionISO, dialCode: dialCode)
    }

    var isPhoneValid: Bool {
        phoneOption.phoneDigitRange.contains(phoneDigits.count)
    }

    mutating func sanitisePhoneDigits() {
        let digits = String(phoneDigits.filter(\.isNumber).prefix(phoneOption.phoneDigitRange.upperBound))
        if digits != phoneDigits { phoneDigits = digits }
    }

    mutating func selectDial(_ option: LoginCountryOption) {
        regionISO = option.country.rawValue
        dialCode = option.dialCode.replacingOccurrences(of: "+", with: "")
        phoneDigits = String(phoneDigits.prefix(option.phoneDigitRange.upperBound))
    }
}

extension ProfileV3Traveller {
    var phoneOption: LoginCountryOption {
        LoginCountryOption.matching(regionISO: regionISO, dialCode: dialCode)
    }

    var isPhoneValid: Bool {
        phoneDigits.isEmpty || LoginCountryOption.isValidPhone(digits: phoneDigits, regionISO: regionISO)
    }

    mutating func selectDial(_ option: LoginCountryOption) {
        regionISO = option.country.rawValue
        dialCode = option.dialCode.replacingOccurrences(of: "+", with: "")
    }
}
