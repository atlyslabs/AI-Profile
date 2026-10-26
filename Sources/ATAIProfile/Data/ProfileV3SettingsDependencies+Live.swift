import Foundation

extension ProfileV3SettingsDependencies {
    private static let preferredCurrencyKey = "accountSettings.preferredCurrencyCountryCode"

    private static func accountDeletionRequestedKey(userID: String?) -> String {
        "profileV3.accountDeletionRequested.\(userID ?? "")"
    }

    static func live(
        account: any ProfileV3AccountHost,
        session: any ProfileV3SessionProviding,
        client: ProfileV3NetworkClient
    ) -> Self {
        Self(
            currentFirstName: {
                MainActor.assumeIsolated { account.snapshot().firstName }
            },
            currentResidence: {
                MainActor.assumeIsolated {
                    account.snapshot().residenceCode.flatMap { ProfileV3Country(code: $0) }
                }
            },
            currentCitizenship: {
                MainActor.assumeIsolated { account.snapshot().citizenship }
            },
            currentCurrencyCountry: {
                let stored = UserDefaults.standard.string(forKey: Self.preferredCurrencyKey)
                let fallback = MainActor.assumeIsolated { account.snapshot().residenceCode }
                return (stored ?? fallback).flatMap { ProfileV3Country(code: $0) }
            },
            currentContact: {
                let snapshot = MainActor.assumeIsolated { account.snapshot() }
                let phone = PhoneCodeResolver.resolve(snapshot.phone)
                return ProfileV3ContactDetails(
                    email: snapshot.email,
                    phoneDigits: phone.digits,
                    regionISO: phone.regionISO,
                    dialCode: phone.dialCode
                )
            },
            saveResidence: { country in
                MainActor.assumeIsolated { account.saveResidence(code: country.code) }
            },
            pushResidenceToServer: { countryCode in
                let travellerID = await MainActor.run { account.snapshot().selectedTravellerID }
                guard let userID = session.currentUserID, let travellerID else { return }
                let request = ProfileV3ResidenceUpdateRequest(
                    userID: userID,
                    travellerID: travellerID,
                    residenceCountryCode: countryCode
                )
                guard let body = try? JSONEncoder().encode(request) else { return }
                try? await Self.editProfile(body, client: client)
            },
            saveCitizenship: { country in
                MainActor.assumeIsolated { account.saveCitizenship(country) }
            },
            saveCurrencyCountry: { country in
                UserDefaults.standard.set(country.code, forKey: Self.preferredCurrencyKey)
            },
            saveContact: { details in
                let snapshot = await MainActor.run { account.snapshot() }
                let email = details.email.nonEmpty
                let phone = Self.e164(details)
                guard email != snapshot.storedEmail || phone != snapshot.storedPhone else { return .success }
                if let email, let phone, await account.isContactTaken(email: email, phone: phone) {
                    return .duplicateEmail
                }
                guard let userID = session.currentUserID, let travellerID = snapshot.selectedTravellerID else {
                    return .failure
                }
                guard await Self.pushContact(
                    email: email,
                    phone: phone,
                    userID: userID,
                    travellerID: travellerID,
                    client: client
                ) else { return .failure }
                await MainActor.run { account.applySavedContact(email: email, phone: phone) }
                return .success
            },
            logAccountDeletionReason: { reason in
                ProfileV3Analytics.accountDeletionReasonSubmitted(reason: reason)
            },
            accountDeletionRequested: {
                UserDefaults.standard.bool(forKey: Self.accountDeletionRequestedKey(userID: session.currentUserID))
            },
            markAccountDeletionRequested: {
                UserDefaults.standard.set(true, forKey: Self.accountDeletionRequestedKey(userID: session.currentUserID))
            },
            storedTraveller: { travellerID in
                MainActor.assumeIsolated { account.storedTraveller(id: travellerID) }
            }
        )
    }

    private static func e164(_ details: ProfileV3ContactDetails) -> String? {
        guard !details.phoneDigits.isEmpty else { return nil }
        return PhoneCodeResolver.e164(digits: details.phoneDigits, regionISO: details.regionISO)
            ?? details.mobileNumber
    }

    private static func pushContact(
        email: String?,
        phone: String?,
        userID: String,
        travellerID: String,
        client: ProfileV3NetworkClient
    ) async -> Bool {
        guard email != nil || phone != nil else { return false }
        let request = ProfileV3ContactUpdateRequest(
            userID: userID,
            travellerID: travellerID,
            email: email,
            mobileNumber: phone
        )
        guard let body = try? JSONEncoder().encode(request) else { return false }
        do {
            try await editProfile(body, client: client)
            return true
        } catch {
            return false
        }
    }

    private static func editProfile(_ body: Data, client: ProfileV3NetworkClient) async throws {
        try await ProfileV3APIErrorMapper.withUnauthorizedRetry(action: "edit_profile") {
            try await client.perform(.editProfile(body: body))
        }
    }

    #if DEBUG
    static func preview(
        firstName: String? = "mohak",
        isAccountDeletionRequested: Bool = false
    ) -> Self {
        Self(
            currentFirstName: { firstName },
            currentResidence: { .india },
            currentCitizenship: { .india },
            currentCurrencyCountry: { .india },
            currentContact: { ProfileV3Fixtures.contactDetails },
            saveResidence: { _ in true },
            pushResidenceToServer: { _ in },
            saveCitizenship: { _ in true },
            saveCurrencyCountry: { _ in },
            saveContact: { _ in .success },
            logAccountDeletionReason: { _ in },
            accountDeletionRequested: { isAccountDeletionRequested },
            markAccountDeletionRequested: {},
            storedTraveller: { _ in nil }
        )
    }
    #endif
}

private struct ProfileV3ResidenceUpdateRequest: Encodable {
    let userID: String
    let travellerID: String
    let residenceCountryCode: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case travellerID = "traveller_id"
        case residenceCountryCode = "residence_country_code"
    }
}

private struct ProfileV3ContactUpdateRequest: Encodable {
    let userID: String
    let travellerID: String
    let email: String?
    let mobileNumber: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case travellerID = "traveller_id"
        case email
        case mobileNumber = "mobile_number"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userID, forKey: .userID)
        try container.encode(travellerID, forKey: .travellerID)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(mobileNumber, forKey: .mobileNumber)
    }
}
