import Foundation

struct ProfileV3SettingsDependencies {
    let currentFirstName: () -> String?
    let currentResidence: () -> ProfileV3Country?
    let currentCitizenship: () -> ProfileV3Country?
    let currentCurrencyCountry: () -> ProfileV3Country?
    let currentContact: () -> ProfileV3ContactDetails
    let saveResidence: (ProfileV3Country) -> Bool
    let pushResidenceToServer: @Sendable (String) async -> Void
    let saveCitizenship: (ProfileV3Country) -> Bool
    let saveCurrencyCountry: (ProfileV3Country) -> Void
    let saveContact: (ProfileV3ContactDetails) async -> ContactUpdateOutcome
    let logAccountDeletionReason: (String) -> Void
    let accountDeletionRequested: () -> Bool
    let markAccountDeletionRequested: () -> Void
    let storedTraveller: (String) -> ProfileV3StoredTraveller?
}
