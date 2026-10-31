import Foundation

#if DEBUG
struct ProfileV3FailingRepository: ProfileV3Repository {
    func loadBoard() async throws -> ProfileV3Board {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadAgentFlow(agentID _: String, profileID _: String?) async throws -> ProfileV3AgentFlow {
        throw ProfileV3RepositoryError.unavailable
    }

    func saveAgentForm(_: ProfileV3AgentForm, profileID _: String?, profileIDs _: [String]?) async throws -> String? {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadEditField(_: ProfileV3ProfileField) async throws -> ProfileV3EditField {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadAIConnector(_: String) async throws -> ProfileV3AIConnector {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadAIConnectorConnect(_: String) async throws -> ProfileV3AIConnectorConnect {
        throw ProfileV3RepositoryError.unavailable
    }

    func connectAIConnector(_: ProfileV3AIConnectorConnect.Submit, text _: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadConnectors() async throws -> ProfileV3ConnectorsScreen {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadLoyaltyEntry(
        programID _: String,
        programName _: String?,
        kind _: String?
    ) async throws -> ProfileV3LoyaltyEntryForm {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadProgrammeInsight(programID _: String, profileID _: String?) async throws -> ProfileV3ProgrammeInsight {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadProgrammeSources(programID _: String, profileID _: String?) async throws -> ProfileV3PreferenceSources {
        throw ProfileV3RepositoryError.unavailable
    }

    func saveProfileField(
        _: ProfileV3ProfileField,
        value _: ProfileV3ProfileFieldValue,
        profileID _: String?
    ) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadTravellerRelationship(profileID _: String) async throws -> ProfileV3EditField {
        throw ProfileV3RepositoryError.unavailable
    }

    func saveTravellerRelationship(_: String, profileID _: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPermissions() async throws -> ProfileV3Permissions {
        throw ProfileV3RepositoryError.unavailable
    }

    func savePermission(_: String, for _: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPastTrips(profileID _: String) async throws -> ProfileV3PastTripsScreen {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadAddTrip(profileID _: String) async throws -> ProfileV3AddTripScreen {
        throw ProfileV3RepositoryError.unavailable
    }

    func addPastTrips(_: ProfileV3BoardAction, countries _: [String]) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func deletePastTrip(_: ProfileV3BoardAction) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func acknowledgeLogout() async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func requestAccountDeletion() async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadDeleteAccountReason() async throws -> ProfileV3DeleteAccountReason {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadDeleteAccountConfirm() async throws -> ProfileV3DeleteAccountConfirm {
        throw ProfileV3RepositoryError.unavailable
    }

    func disconnectConnector(_: ProfileV3ConnectorKey) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func syncPhotoPlaces(_: ProfileV3PhotoPlacesUpload) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadConnectorControlPanel() async throws -> ProfileV3ConnectorControlPanel {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadAppAccess() async throws -> ProfileV3AppAccess {
        throw ProfileV3RepositoryError.unavailable
    }

    func saveAppCredentials(_: ProfileV3AppCredentials, appID _: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func addAppPassword(_: ProfileV3AppCredentials) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func disconnectApp(_: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadInstagramAccount() async throws -> ProfileV3InstagramAccount {
        throw ProfileV3RepositoryError.unavailable
    }

    func linkInstagram(username _: String) async throws -> String {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadVaultCredentials() async throws -> [ProfileV3VaultCredential] {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadVaultSites() async throws -> [ProfileV3VaultSite] {
        throw ProfileV3RepositoryError.unavailable
    }

    func saveVault(_: ProfileV3VaultDraft) async throws -> ProfileV3VaultWriteResult {
        throw ProfileV3RepositoryError.unavailable
    }

    func updateVault(id _: String, draft _: ProfileV3VaultDraft) async throws -> ProfileV3VaultWriteResult {
        throw ProfileV3RepositoryError.unavailable
    }

    func vaultCredential(id _: String, includeUsername _: Bool) async throws -> ProfileV3VaultCredential {
        throw ProfileV3RepositoryError.unavailable
    }

    func retestVaultCredential(id _: String) async throws -> ProfileV3VaultWriteResult {
        throw ProfileV3RepositoryError.unavailable
    }

    func deleteVaultCredential(id _: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func pauseVaultCredential(id _: String) async throws -> ProfileV3VaultWriteResult {
        throw ProfileV3RepositoryError.unavailable
    }

    func resumeVaultCredential(id _: String) async throws -> ProfileV3VaultWriteResult {
        throw ProfileV3RepositoryError.unavailable
    }

    func revealVaultPassword(id _: String, deviceName _: String) async throws -> String {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadCoupons() async throws -> ProfileV3CouponsSheet {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadCoupon(id _: String) async throws -> ProfileV3CouponDetail? {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadEditTravellers() async throws -> ProfileV3EditTravellersScreen {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadDeleteTravellerConfirm(profileID _: String) async throws -> ProfileV3DeleteTravellerConfirm {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadAddTraveller() async throws -> ProfileV3AddTravellerScreen {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadTerms(locale _: String?) async throws -> ProfileV3Terms? {
        throw ProfileV3RepositoryError.unavailable
    }

    func deleteTraveller(profileID _: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func saveTravellerDetails(
        profileID _: String,
        firstName _: String?,
        lastName _: String?,
        passportNumber _: String?
    ) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func addTraveller(_: ProfileV3AddTravellerSubmission) async throws -> String? {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadDisconnectConfirm(_: ProfileV3ConnectorKey) async throws -> ProfileV3DisconnectConfirm {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPreviousPassports(profileID _: String?) async throws -> ProfileV3PreviousPassports {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPassportScan(profileID _: String?) async throws -> ProfileV3PassportScan {
        throw ProfileV3RepositoryError.unavailable
    }

    func uploadPassportScan(_: ProfileV3PassportSide, data _: Data, profileID _: String?) async throws
        -> ProfileV3PassportScanResult {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPassportReason() async throws -> ProfileV3PassportReasonScreen {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadRidePicker(agentType _: String, profileID _: String?) async throws -> ProfileV3RidePicker {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadRideRegions() async throws -> ProfileV3RideRegions {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadTravelPersona(profileID _: String?) async throws -> ProfileV3TravelPersona {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPersonaTrait(_: String, profileID _: String?, page _: Int) async throws -> ProfileV3PersonaTrait {
        throw ProfileV3RepositoryError.unavailable
    }

    func submitPersonaAction(_: ProfileV3BoardAction, score _: Int?) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPassportHowUsed() async throws -> ProfileV3PassportHowUsed {
        throw ProfileV3RepositoryError.unavailable
    }

    func updatePassport(reason _: String, profileID _: String?) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPreferenceSources(_: ProfileV3SectionSource, profileID _: String?) async throws
        -> ProfileV3PreferenceSources {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadSettings() async throws -> ProfileV3SettingsMenu {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadBenefits(profileID _: String?) async throws -> ProfileV3BenefitsSheet {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadBenefit(id _: String) async throws -> ProfileV3Benefit? {
        throw ProfileV3RepositoryError.unavailable
    }

    func redeemBenefit(id _: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func scanProgrammes() -> AsyncThrowingStream<ProfileV3ProgrammeScanEvent, Error> {
        AsyncThrowingStream { $0.finish(throwing: ProfileV3RepositoryError.agentNotFound) }
    }

    func loadProgrammeCatalogue(query _: String?, kind _: String?, market _: String?) async throws -> ProfileV3ProgrammePicker {
        throw ProfileV3RepositoryError.unavailable
    }

    func addProgramme(_: ProfileV3ProgrammeSubmission, profileID _: String?) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func startKYCCapture(steps _: [String], profileID _: String?) async throws -> ProfileV3CaptureStep? {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadKYCCaptureState() async throws -> ProfileV3CaptureStep? {
        throw ProfileV3RepositoryError.unavailable
    }

    func answerKYCCapture(_: ProfileV3CaptureAnswer, stepID _: String) async throws -> ProfileV3CaptureStep? {
        throw ProfileV3RepositoryError.unavailable
    }

    func uploadKYCCaptureDocument(_: Data, stepID _: String) async throws -> ProfileV3CaptureStep? {
        throw ProfileV3RepositoryError.unavailable
    }

    func uploadKYCCaptureImage(
        _: ProfileV3CaptureImage,
        data _: Data,
        stepID _: String,
        residenceCountryCode _: String?
    ) async throws -> ProfileV3CaptureStep? {
        throw ProfileV3RepositoryError.unavailable
    }

    func uploadCoTravellerImage(_: ProfileV3CaptureImage, data _: Data, profileID _: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadProgrammes(passID _: String) async throws -> ProfileV3ProgrammeOverview {
        throw ProfileV3RepositoryError.unavailable
    }

    func removeProgramme(id _: String, name _: String, profileID _: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func reorderProgrammes(_: [String], profileID _: String, action _: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }
}
#endif
