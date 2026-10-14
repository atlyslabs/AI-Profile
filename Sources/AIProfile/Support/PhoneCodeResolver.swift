import Foundation
import PhoneNumberKit

enum PhoneCodeResolver {
    struct ResolvedPhone: Equatable {
        var digits: String
        var regionISO: String
        var dialCode: String
    }

    private static let indiaRegion = "IN"

    nonisolated(unsafe) private static let kit = PhoneNumberKit()

    static func dialCode(forRegion isoCode: String) -> String? {
        let normalised = isoCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !normalised.isEmpty, let code = kit.countryCode(for: normalised) else { return nil }
        return "\(code)"
    }

    static func resolve(
        _ raw: String?,
        fallbackRegion: String = Locale.current.region?.identifier ?? indiaRegion
    ) -> ResolvedPhone {
        let fallback = normalisedRegion(fallbackRegion) ?? indiaRegion
        var region = fallback
        var digits = raw ?? ""
        if !digits.isEmpty, let parsed = try? kit.parse(digits) {
            region = parsed.regionID ?? region
            digits = String(parsed.nationalNumber)
        }
        return ResolvedPhone(
            digits: digits.filter(\.isNumber),
            regionISO: region,
            dialCode: dialCodeOrIndiaDefault(forRegion: region)
        )
    }

    static func isValidPhoneNumber(_ digits: String, withRegion regionISO: String) -> Bool {
        kit.isValidPhoneNumber(digits, withRegion: regionISO)
    }

    static func e164(digits: String, regionISO: String) -> String? {
        guard let parsed = try? kit.parse(digits, withRegion: regionISO) else { return nil }
        return kit.format(parsed, toType: .e164)
    }

    private static func dialCodeOrIndiaDefault(forRegion isoCode: String) -> String {
        if let code = dialCode(forRegion: isoCode) { return code }
        if let indiaCode = dialCode(forRegion: indiaRegion) { return indiaCode }
        return ""
    }

    private static func normalisedRegion(_ isoCode: String) -> String? {
        let normalised = isoCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return normalised.isEmpty ? nil : normalised
    }
}
