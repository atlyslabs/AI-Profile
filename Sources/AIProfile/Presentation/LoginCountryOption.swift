import ATUIKit
import Foundation

struct LoginCountryOption: Identifiable, Equatable {
    let country: ATCountry
    let dialCode: String

    var id: String { country.rawValue }
    var name: String { country.name }

    static let india = LoginCountryOption(country: .india, dialCode: "+91")

    var phoneDigitRange: ClosedRange<Int> {
        Self.phoneDigitRange(for: country)
    }

    static func phoneDigitRange(for country: ATCountry?) -> ClosedRange<Int> {
        switch country {
        case .india:
            return 10...10
        default:
            return 7...15
        }
    }
}
