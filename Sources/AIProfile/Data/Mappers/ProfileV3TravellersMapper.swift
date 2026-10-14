import Foundation

enum ProfileV3TravellersMapper: ProfileV3DTOReading {

    static func editTravellers(_ dto: ProfileV3EditTravellersScreenDTO) -> ProfileV3EditTravellersScreen {
        ProfileV3EditTravellersScreen(
            title: text(dto.title) ?? ProfileV3Strings.editTravellers,
            travellers: dto.travellers.compactMap(row),
            addLabel: text(dto.add?.label) ?? ProfileV3Strings.addTraveller,
            worldPassLabel: text(dto.worldpassLabel) ?? ProfileV3Strings.worldPass,
            worldPassIconURL: remoteURL(dto.worldpassIcon),
            relationshipPicker: dto.relationshipPicker.flatMap(relationshipPicker)
        )
    }

    private static func relationshipPicker(_ dto: ProfileV3RelationshipPickerDTO) -> ProfileV3RelationshipPicker? {
        let options = dto.options.compactMap(option)
        guard !options.isEmpty else { return nil }
        return ProfileV3RelationshipPicker(title: text(dto.title) ?? "", options: options)
    }

    private static func row(_ dto: ProfileV3TravellerRowDTO) -> ProfileV3TravellerRow? {
        guard let id = text(dto.profileID) else { return nil }
        return ProfileV3TravellerRow(
            id: id,
            name: text(dto.name) ?? "",
            passNumber: text(dto.passNumber) ?? "",
            passportNumber: text(dto.passportNumber),
            mobileNumber: text(dto.mobileNumber),
            citizenshipCode: text(dto.citizenshipCountryCode)?.uppercased(),
            relationship: dto.isMain == true ? nil : text(dto.relationship),
            isMain: dto.isMain ?? false,
            badgeImageURL: remoteURL(dto.badge?.imageURL),
            isDeletable: dto.next != nil
        )
    }

    static func deleteConfirm(
        _ dto: ProfileV3DeleteTravellerConfirmScreenDTO,
        fallbackProfileID: String
    ) -> ProfileV3DeleteTravellerConfirm {
        ProfileV3DeleteTravellerConfirm(
            profileID: text(dto.proceed?.profileID) ?? fallbackProfileID,
            name: text(dto.name) ?? "",
            title: text(dto.title) ?? ProfileV3Strings.deleteTravellerTitle,
            body: text(dto.body) ?? "",
            proceedLabel: text(dto.proceed?.label) ?? ProfileV3Strings.proceedToDelete,
            cancelLabel: text(dto.cancel?.label) ?? ProfileV3Strings.dontDelete
        )
    }

    static func addTraveller(_ dto: ProfileV3AddTravellerScreenDTO) -> ProfileV3AddTravellerScreen {
        ProfileV3AddTravellerScreen(
            title: text(dto.title) ?? ProfileV3Strings.addTraveller,
            subtitle: text(dto.subtitle) ?? "",
            fields: dto.fields.compactMap(field),
            submitLabel: text(dto.submit?.label) ?? ProfileV3Strings.addTraveller
        )
    }

    private static func field(_ dto: ProfileV3AddTravellerFieldDTO) -> ProfileV3AddTravellerField? {
        guard let key = text(dto.key) else { return nil }
        let input = ProfileV3AddTravellerField.Input(rawValue: text(dto.input) ?? "") ?? .text
        return ProfileV3AddTravellerField(
            key: key,
            label: text(dto.label) ?? "",
            input: input,
            isRequired: dto.required ?? false,
            options: dto.options.compactMap(option)
        )
    }

    private static func option(_ dto: ProfileV3AddTravellerOptionDTO) -> ProfileV3AddTravellerOption? {
        guard let value = text(dto.value) else { return nil }
        return ProfileV3AddTravellerOption(
            value: value,
            title: text(dto.title) ?? value,
            isMinor: dto.isMinor ?? false
        )
    }

}
