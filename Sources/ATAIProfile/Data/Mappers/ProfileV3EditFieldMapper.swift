import Foundation

enum ProfileV3EditFieldMapper: ProfileV3DTOReading {
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
            currentContact: contact(dto.current?.contact),
            options: dto.options.compactMap(option),
            submitProfileID: text(dto.submit?.profileID)
        )
    }

    private static func input(_ raw: String?, field: String) -> ProfileV3EditField.Input {
        let normalised = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let parsed = ProfileV3EditField.Input(rawValue: normalised) { return parsed }
        switch field.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "contact": return .contactForm
        case "currency": return .currencyPicker
        case ProfileV3AddTravellerField.relationshipKey: return .singleSelect
        default: return .countryPicker
        }
    }

    private static func option(_ dto: ProfileV3EditFieldOptionDTO) -> ProfileV3EditField.Option? {
        guard let value = text(dto.value), let title = text(dto.title) ?? text(dto.label) else { return nil }
        return ProfileV3EditField.Option(
            value: value,
            title: title,
            isSelected: dto.selected ?? false
        )
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
