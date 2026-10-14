import AIProfile

@MainActor
final class VDCProfileV3AccountHost: ProfileV3AccountHost {
    func snapshot() -> ProfileV3AccountSnapshot {
        let user = UserData.currentUser
        return ProfileV3AccountSnapshot(
            firstName: user?.userProfile?.mainTravellerProfileData?.firstName,
            residenceCode: Locale.current.avRegionCode,
            citizenship: Self.country(user?.citizenshipDeduced),
            passportNationality: Self.country(Self.passportCountry(user?.passport)),
            email: user?.email ?? user?.user.email ?? "",
            phone: user?.phoneNumber?.nonEmpty ?? user?.user.phoneNumber?.nonEmpty,
            storedEmail: user?.email,
            storedPhone: user?.phoneNumber,
            selectedTravellerID: user?.selectedUserProfile
        )
    }

    func storedTraveller(id: String) -> ProfileV3StoredTraveller? {
        let profiles = UserData.currentUser?.userProfile
        let travellers = [profiles?.mainTravellerProfileData].compactMap { $0 }
            + (profiles?.coTravellerProfileData ?? [])
        return travellers.first { $0.travellerID == id }.map {
            ProfileV3StoredTraveller(
                firstName: $0.firstName ?? "",
                lastName: $0.lastName ?? "",
                email: $0.email?.nonEmpty,
                citizenshipCode: $0.citizenshipCountryCode?.nonEmpty
            )
        }
    }

    func saveResidence(code: String) -> Bool {
        guard let user = UserData.currentUser else { return false }
        user.userOverriddenRegionCode = code
        user.syncUserDataToDb()
        NotificationCenter.default.post(name: UserDataNotifications.citizenshipResidenceUpdated, object: nil)
        return true
    }

    func saveCitizenship(_ country: ProfileV3Country) -> Bool {
        guard let user = UserData.currentUser else { return false }
        user.citizenship = Country(countryCode: country.code)
        user.citizenshipCountryCode = country.code
        user.syncUserDataToDb()
        NotificationCenter.default.post(name: UserDataNotifications.citizenshipResidenceUpdated, object: nil)
        return true
    }

    func isContactTaken(email: String, phone: String) async -> Bool {
        await withCheckedContinuation { continuation in
            APIManager.sharedInstance.mergeAccounts(phone: phone, email: email) { token in
                continuation.resume(returning: token != nil)
            }
        }
    }

    func applySavedContact(email: String?, phone: String?) {
        guard let user = UserData.currentUser else { return }
        user.email = email
        user.phoneNumber = phone
        user.syncUserDataToDb()
        NotificationCenter.default.post(name: UserDataNotifications.UserDataCacheUpdated, object: nil)
    }

    func travellerProfileDidChange() {
        NotificationCenter.default.post(
            name: UserDataNotifications.ProfileUpdatedNotification,
            object: nil,
            userInfo: [UserDataNotifications.showsConfirmationKey: false]
        )
    }

    private static func country(_ value: Country?) -> ProfileV3Country? {
        guard let value else { return nil }
        return ProfileV3Country(code: value.countryCode, name: value.rawValue)
    }

    private static func passportCountry(_ passport: PassportData?) -> Country? {
        guard let passport else { return nil }
        if let name = passport.nationality, let country = Country(rawValue: name) { return country }
        return passport.nationalityCountryCode.flatMap { Country(countryCode: $0) }
    }
}
