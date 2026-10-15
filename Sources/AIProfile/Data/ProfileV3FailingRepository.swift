import Foundation

#if DEBUG
struct ProfileV3FailingRepository: ProfileV3Repository {
    func loadBoard() async throws -> ProfileV3Board {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadAgentFlow(agentID _: String, profileID _: String?) async throws -> ProfileV3AgentFlow {
        throw ProfileV3RepositoryError.unavailable
    }

    func saveAgentForm(_: ProfileV3AgentForm, profileID _: String?) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadEditField(_: ProfileV3ProfileField) async throws -> ProfileV3EditField {
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

    func savePermission(_: String, in _: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPastTrips(profileID _: String) async throws -> [ProfileV3PastTrip] {
        throw ProfileV3RepositoryError.unavailable
    }

    func addPastTrip(_: ProfileV3PastTripDraft, profileID _: String) async throws -> ProfileV3PastTrip {
        throw ProfileV3RepositoryError.unavailable
    }

    func updatePastTrip(
        id _: String,
        with _: ProfileV3PastTripDraft,
        profileID _: String
    ) async throws -> ProfileV3PastTrip {
        throw ProfileV3RepositoryError.unavailable
    }

    func deletePastTrip(id _: String, profileID _: String) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func acknowledgeLogout() async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func requestAccountDeletion() async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func disconnectConnector(_: ProfileV3ConnectorKey) async throws {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadConnectorControlPanel() async throws -> ProfileV3ConnectorControlPanel {
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

    func loadPassportHistory(profileID _: String?) async throws -> [ProfileV3Passport] {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPassportScan(profileID _: String?) async throws -> ProfileV3PassportScan {
        throw ProfileV3RepositoryError.unavailable
    }

    func uploadPassportScan(_: ProfileV3PassportSide, data _: Data, profileID _: String?) async throws
        -> ProfileV3PassportField? {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPassportReason() async throws -> ProfileV3PassportReasonScreen {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadRidePicker(agentType _: String, profileID _: String?) async throws -> ProfileV3RidePicker {
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

    func loadProgrammeCatalogue(query _: String?, kind _: String?) async throws -> ProfileV3ProgrammePicker {
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
