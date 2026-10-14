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
    func saveAgentForm(_ form: ProfileV3AgentForm, profileID: String?) async throws
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

protocol ProfileV3SettingsRepository: Sendable {
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
    func loadPastTrips(profileID: String) async throws -> [ProfileV3PastTrip]
    func addPastTrip(_ draft: ProfileV3PastTripDraft, profileID: String) async throws -> ProfileV3PastTrip
    func updatePastTrip(
        id: String,
        with draft: ProfileV3PastTripDraft,
        profileID: String
    ) async throws -> ProfileV3PastTrip
    func deletePastTrip(id: String, profileID: String) async throws
}

typealias ProfileV3HubRepository = ProfileV3BoardRepository & ProfileV3PastTripsRepository

typealias ProfileV3Repository = ProfileV3BoardRepository
    & ProfileV3AgentRepository
    & ProfileV3LoyaltyRepository
    & ProfileV3KYCCaptureRepository
    & ProfileV3SettingsRepository
    & ProfileV3PastTripsRepository

extension ProfileV3BoardRepository {
    func loadLatestBoard() async throws -> ProfileV3Board {
        try await loadBoard()
    }

    @MainActor func cachedBoard() -> ProfileV3Board? { nil }
}
