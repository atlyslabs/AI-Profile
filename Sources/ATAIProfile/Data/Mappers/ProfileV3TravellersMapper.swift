import Foundation

enum ProfileV3TravellersMapper: ProfileV3DTOReading {

    static func editTravellers(_ dto: ProfileV3EditTravellersScreenDTO) -> ProfileV3EditTravellersScreen {
        ProfileV3EditTravellersScreen(
            title: text(dto.title) ?? ProfileV3Strings.editTravellers,
            travellers: dto.travellers.compactMap(row),
            addLabel: text(dto.add?.label) ?? ProfileV3Strings.addTraveller
        )
    }

    private static func row(_ dto: ProfileV3TravellerRowDTO) -> ProfileV3TravellerRow? {
        guard let id = text(dto.profileID) else { return nil }
        let isMain = dto.isMain ?? false
        return ProfileV3TravellerRow(
            id: id,
            name: text(dto.name) ?? "",
            passNumber: text(dto.passNumber) ?? "",
            passportNumber: text(dto.passportNumber),
            mobileNumber: text(dto.mobileNumber),
            citizenshipCode: text(dto.citizenshipCountryCode)?.uppercased(),
            relationship: isMain ? nil : text(dto.relationship),
            relationshipEntry: isMain ? nil : relationshipEntry(dto.editRelationship, rowID: id),
            isMain: isMain,
            badgeImageURL: remoteURL(dto.badge?.imageURL),
            isDeletable: dto.next != nil
        )
    }

    private static func relationshipEntry(_ cta: ProfileV3NavCTADTO?, rowID: String) -> ProfileV3RelationshipEntry? {
        guard let cta, cta.next.go == "edit_field" else { return nil }
        let field = text(cta.next.field) ?? ProfileV3AddTravellerField.relationshipKey
        guard field == ProfileV3AddTravellerField.relationshipKey else { return nil }
        return ProfileV3RelationshipEntry(
            label: text(cta.label) ?? ProfileV3RelationshipEntry.title(for: field),
            profileID: text(cta.next.profileID) ?? rowID
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
