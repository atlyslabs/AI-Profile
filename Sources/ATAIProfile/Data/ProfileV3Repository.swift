import Foundation

enum ProfileV3RepositoryError: Error {
    case agentNotFound
    case unavailable
}

protocol ProfileV3BoardRepository: Sendable {
    func loadBoard() async throws -> ProfileV3Board
    func loadLatestBoard() async throws -> ProfileV3Board
    @MainActor func cachedBoard() -> ProfileV3Board?
    func loadBenefits(profileID: String?) async throws -> ProfileV3BenefitsSheet
    func loadBenefit(id: String) async throws -> ProfileV3Benefit?
    func redeemBenefit(id: String) async throws
    func loadCoupons() async throws -> ProfileV3CouponsSheet
    func loadCoupon(id: String) async throws -> ProfileV3CouponDetail?
}

protocol ProfileV3AgentRepository: Sendable {
    func loadAgentFlow(agentID: String, profileID: String?) async throws -> ProfileV3AgentFlow
    func saveAgentForm(
        _ form: ProfileV3AgentForm,
        profileID: String?,
        profileIDs: [String]?
    ) async throws -> String?
    func loadPassportHistory(profileID: String?) async throws -> [ProfileV3Passport]
    func loadPassportScan(profileID: String?) async throws -> ProfileV3PassportScan
    func uploadPassportScan(_ side: ProfileV3PassportSide, data: Data, profileID: String?) async throws
        -> ProfileV3PassportField?
    func loadPassportReason() async throws -> ProfileV3PassportReasonScreen
    func loadPassportHowUsed() async throws -> ProfileV3PassportHowUsed
    func updatePassport(reason: String, profileID: String?) async throws
    func loadPreferenceSources(_ source: ProfileV3SectionSource, profileID: String?) async throws
        -> ProfileV3PreferenceSources
    func loadRidePicker(agentType: String, profileID: String?) async throws -> ProfileV3RidePicker
    func loadRideRegions() async throws -> ProfileV3RideRegions
}

protocol ProfileV3LoyaltyRepository: Sendable {
    func scanProgrammes() -> AsyncThrowingStream<ProfileV3ProgrammeScanEvent, Error>
    func loadProgrammeCatalogue(query: String?, kind: String?) async throws -> ProfileV3ProgrammePicker
    func loadLoyaltyEntry(
        programID: String,
        programName: String?,
        kind: String?
    ) async throws -> ProfileV3LoyaltyEntryForm
    func loadProgrammeInsight(programID: String, profileID: String?) async throws -> ProfileV3ProgrammeInsight
    func loadProgrammeSources(programID: String, profileID: String?) async throws -> ProfileV3PreferenceSources
    func addProgramme(_ submission: ProfileV3ProgrammeSubmission, profileID: String?) async throws
    func loadProgrammes(passID: String) async throws -> ProfileV3ProgrammeOverview
    func removeProgramme(id: String, name: String, profileID: String) async throws
    func reorderProgrammes(_ order: [String], profileID: String, action: String) async throws
}

protocol ProfileV3KYCCaptureRepository: Sendable {
    func startKYCCapture(steps: [String], profileID: String?) async throws -> ProfileV3CaptureStep?
    func loadKYCCaptureState() async throws -> ProfileV3CaptureStep?
    func answerKYCCapture(_ answer: ProfileV3CaptureAnswer, stepID: String) async throws -> ProfileV3CaptureStep?
    func uploadKYCCaptureImage(
        _ image: ProfileV3CaptureImage,
        data: Data,
        stepID: String,
        residenceCountryCode: String?
    ) async throws -> ProfileV3CaptureStep?
    func uploadKYCCaptureDocument(_ data: Data, stepID: String) async throws -> ProfileV3CaptureStep?
    func uploadCoTravellerImage(_ image: ProfileV3CaptureImage, data: Data, profileID: String) async throws
}

protocol ProfileV3AppAccessRepository: Sendable {
    func loadAppAccess() async throws -> ProfileV3AppAccess
    func saveAppCredentials(_ credentials: ProfileV3AppCredentials, appID: String) async throws
    func addAppPassword(_ credentials: ProfileV3AppCredentials) async throws
    func disconnectApp(_ appID: String) async throws
    func loadVaultCredentials() async throws -> [ProfileV3VaultCredential]
    func loadVaultSites() async throws -> [ProfileV3VaultSite]
    func saveVault(_ draft: ProfileV3VaultDraft) async throws -> ProfileV3VaultWriteResult
    func updateVault(id: String, draft: ProfileV3VaultDraft) async throws -> ProfileV3VaultWriteResult
    func vaultCredential(id: String, includeUsername: Bool) async throws -> ProfileV3VaultCredential
    func retestVaultCredential(id: String) async throws -> ProfileV3VaultWriteResult
    func deleteVaultCredential(id: String) async throws
    func pauseVaultCredential(id: String) async throws -> ProfileV3VaultWriteResult
    func resumeVaultCredential(id: String) async throws -> ProfileV3VaultWriteResult
    func revealVaultPassword(id: String, deviceName: String) async throws -> String
}

protocol ProfileV3SettingsRepository: ProfileV3AppAccessRepository {
    func loadSettings() async throws -> ProfileV3SettingsMenu
    func loadEditField(_ field: ProfileV3ProfileField) async throws -> ProfileV3EditField
    func saveProfileField(
        _ field: ProfileV3ProfileField,
        value: ProfileV3ProfileFieldValue,
        profileID: String?
    ) async throws
    func loadConnectors() async throws -> ProfileV3ConnectorsScreen
    func loadConnectorControlPanel() async throws -> ProfileV3ConnectorControlPanel
    func loadDisconnectConfirm(_ connector: ProfileV3ConnectorKey) async throws -> ProfileV3DisconnectConfirm
    func disconnectConnector(_ connector: ProfileV3ConnectorKey) async throws
    func loadEditTravellers() async throws -> ProfileV3EditTravellersScreen
    func loadTravellerRelationship(profileID: String) async throws -> ProfileV3EditField
    func saveTravellerRelationship(_ value: String, profileID: String) async throws
    func loadDeleteTravellerConfirm(profileID: String) async throws -> ProfileV3DeleteTravellerConfirm
    func loadAddTraveller() async throws -> ProfileV3AddTravellerScreen
    func deleteTraveller(profileID: String) async throws
    func saveTravellerDetails(
        profileID: String,
        firstName: String?,
        lastName: String?,
        passportNumber: String?
    ) async throws
    func addTraveller(_ submission: ProfileV3AddTravellerSubmission) async throws -> String?
    func loadTerms(locale: String?) async throws -> ProfileV3Terms?
    func acknowledgeLogout() async throws
    func requestAccountDeletion() async throws
    func loadPermissions() async throws -> ProfileV3Permissions
    func savePermission(_ optionID: String, in sectionID: String) async throws
}

protocol ProfileV3PastTripsRepository: Sendable {
    func loadPastTrips(profileID: String) async throws -> ProfileV3PastTripsScreen
    func loadAddTrip(profileID: String) async throws -> ProfileV3AddTripScreen
    func addPastTrip(_ submit: ProfileV3BoardAction, country: String, year: Int, month: Int) async throws
    func editPastTrip(_ submit: ProfileV3BoardAction, year: Int, month: Int) async throws
    func deletePastTrip(_ submit: ProfileV3BoardAction) async throws
}

protocol ProfileV3PersonaRepository: Sendable {
    func loadTravelPersona(profileID: String?) async throws -> ProfileV3TravelPersona
    func loadPersonaTrait(_ trait: String, profileID: String?, page: Int) async throws -> ProfileV3PersonaTrait
    func submitPersonaAction(_ action: ProfileV3BoardAction, score: Int?) async throws
}

typealias ProfileV3HubRepository = ProfileV3BoardRepository & ProfileV3PastTripsRepository

typealias ProfileV3Repository = ProfileV3BoardRepository
    & ProfileV3AgentRepository
    & ProfileV3LoyaltyRepository
    & ProfileV3KYCCaptureRepository
    & ProfileV3SettingsRepository
    & ProfileV3PastTripsRepository
    & ProfileV3PersonaRepository

extension ProfileV3BoardRepository {
    func loadLatestBoard() async throws -> ProfileV3Board {
        try await loadBoard()
    }

    @MainActor func cachedBoard() -> ProfileV3Board? { nil }
}
