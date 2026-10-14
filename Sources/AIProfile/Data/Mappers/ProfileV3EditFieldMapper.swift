import Foundation

enum ProfileV3EditFieldMapper {
    static func field(_ dto: ProfileV3EditFieldScreenDTO) -> ProfileV3EditField? {
        let field = (dto.field ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !field.isEmpty else { return nil }
        return ProfileV3EditField(
            field: field,
            title: dto.title ?? "",
            input: input(dto.input, field: field),
            subtitle: dto.subtitle,
            submitLabel: dto.submit?.label,
            currentCode: dto.current?.code,
            currentContact: contact(dto.current?.contact)
        )
    }

    private static func input(_ raw: String?, field: String) -> ProfileV3EditField.Input {
        let normalised = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let parsed = ProfileV3EditField.Input(rawValue: normalised) { return parsed }
        switch field.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "contact": return .contactForm
        case "currency": return .currencyPicker
        default: return .countryPicker
        }
    }

    private static func contact(_ dto: ProfileV3EditFieldContactDTO?) -> ProfileV3ContactDetails? {
        guard let dto, dto.email != nil || dto.mobileNumber != nil else { return nil }
        let phone = PhoneCodeResolver.resolve(dto.mobileNumber)
        return ProfileV3ContactDetails(
            email: dto.email ?? "",
            phoneDigits: phone.digits,
            regionISO: phone.regionISO,
            dialCode: phone.dialCode
        )
    }
}
