import Foundation

public struct ProfileV3AccountSnapshot: Equatable, Sendable {
    public var firstName: String?
    public var residenceCode: String?
    public var citizenship: ProfileV3Country?
    public var passportNationality: ProfileV3Country?
    public var email: String
    public var phone: String?
    public var storedEmail: String?
    public var storedPhone: String?
    public var selectedTravellerID: String?

    public init(
        firstName: String?,
        residenceCode: String?,
        citizenship: ProfileV3Country?,
        passportNationality: ProfileV3Country?,
        email: String,
        phone: String?,
        storedEmail: String?,
        storedPhone: String?,
        selectedTravellerID: String?
    ) {
        self.firstName = firstName
        self.residenceCode = residenceCode
        self.citizenship = citizenship
        self.passportNationality = passportNationality
        self.email = email
        self.phone = phone
        self.storedEmail = storedEmail
        self.storedPhone = storedPhone
        self.selectedTravellerID = selectedTravellerID
    }
}

@MainActor
public protocol ProfileV3AccountHost: AnyObject, Sendable {
    func snapshot() -> ProfileV3AccountSnapshot

    func storedTraveller(id: String) -> ProfileV3StoredTraveller?

    func saveResidence(code: String) -> Bool

    func saveCitizenship(_ country: ProfileV3Country) -> Bool

    func isContactTaken(email: String, phone: String) async -> Bool

    func applySavedContact(email: String?, phone: String?)

    func travellerProfileDidChange()
}
