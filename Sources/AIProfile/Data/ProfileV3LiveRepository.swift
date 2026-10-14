import Foundation

final class ProfileV3LiveRepository: ProfileV3Repository, @unchecked Sendable {
    private let client: ProfileV3NetworkClient
    private let store: ProfileV3BoardStore
    private let session: any ProfileV3SessionProviding
    private let account: any ProfileV3AccountHost
    private let agentResiduals = ProfileV3AgentResidualStore()

    init(
        client: ProfileV3NetworkClient,
        boardStore: ProfileV3BoardStore,
        session: any ProfileV3SessionProviding,
        account: any ProfileV3AccountHost
    ) {
        self.client = client
        self.store = boardStore
        self.session = session
        self.account = account
    }

    func loadBoard() async throws -> ProfileV3Board {
        try await store.board(reusingPending: false)
    }

    func loadLatestBoard() async throws -> ProfileV3Board {
        try await store.board(reusingPending: true)
    }

    @MainActor func cachedBoard() -> ProfileV3Board? {
        store.cachedBoard()
    }

    @MainActor private func accountCountry(for profileID: String?) -> ProfileV3Country? {
        guard profileID == nil || profileID == store.cachedBoard()?.mainProfile?.profileID else { return nil }
        return account.snapshot().passportNationality
    }

    func loadAgentFlow(agentID: String, profileID: String?) async throws -> ProfileV3AgentFlow {
        guard let agent = ProfileV3AgentID(rawValue: agentID) else {
            throw ProfileV3RepositoryError.agentNotFound
        }
        let endpoint = ProfileV3API.agent(type: agent, profileID: profileID)
        let dto: ProfileV3AgentScreenDTO = try await request(endpoint, action: "agent")
        let country = await accountCountry(for: profileID)
        let mapped = ProfileV3AgentMapper.flow(from: dto, accountCountry: country)
        agentResiduals.record(mapped.residuals, agentID: mapped.agentID, profileID: profileID)
        return mapped.flow
    }

    func saveAgentForm(_ form: ProfileV3AgentForm, profileID: String?) async throws {
        let residuals = agentResiduals.residuals(agentID: form.agentID, profileID: profileID)
        let body = try ProfileV3AgentSubmission.body(for: form, profileID: profileID, residuals: residuals)
        try await submit(body, action: "save_agent_preferences")
    }

    func loadSettings() async throws -> ProfileV3SettingsMenu {
        let dto: ProfileV3SettingsMenuDTO = try await request(ProfileV3API.settings, action: "settings")
        return ProfileV3SettingsMapper.menu(dto)
    }

    func loadEditField(_ field: ProfileV3ProfileField) async throws -> ProfileV3EditField {
        let dto: ProfileV3EditFieldScreenDTO = try await request(
            ProfileV3API.editField(field.rawValue),
            action: "edit_field"
        )
        guard let mapped = ProfileV3EditFieldMapper.field(dto) else {
            throw ProfileV3Error.server(code: "unknown_field", message: nil)
        }
        return mapped
    }

    func loadConnectors() async throws -> ProfileV3ConnectorsScreen {
        let dto: ProfileV3ConnectorsScreenDTO = try await request(
            ProfileV3API.connectors,
            action: "connectors"
        )
        return ProfileV3ConnectorsMapper.screen(dto)
    }

    func disconnectConnector(_ connector: ProfileV3ConnectorKey) async throws {
        let request = ProfileV3DisconnectConnectorRequest(connector: connector.rawValue)
        try await submit(try JSONEncoder().encode(request), action: "disconnect_connector")
    }

    func loadTerms(locale: String?) async throws -> ProfileV3Terms? {
        let dto: ProfileV3TermsScreenDTO = try await request(
            ProfileV3API.terms(locale: locale),
            action: "terms"
        )
        return ProfileV3TermsMapper.terms(dto)
    }

    func loadEditTravellers() async throws -> ProfileV3EditTravellersScreen {
        let dto: ProfileV3EditTravellersScreenDTO = try await request(
            ProfileV3API.editTravellers,
            action: "edit_travellers"
        )
        return ProfileV3TravellersMapper.editTravellers(dto)
    }

    func loadDeleteTravellerConfirm(profileID: String) async throws -> ProfileV3DeleteTravellerConfirm {
        let dto: ProfileV3DeleteTravellerConfirmScreenDTO = try await request(
            ProfileV3API.deleteTravellerConfirm(profileID: profileID),
            action: "delete_traveller_confirm"
        )
        return ProfileV3TravellersMapper.deleteConfirm(dto, fallbackProfileID: profileID)
    }

    func loadAddTraveller() async throws -> ProfileV3AddTravellerScreen {
        let dto: ProfileV3AddTravellerScreenDTO = try await request(
            ProfileV3API.addTraveller,
            action: "add_traveller"
        )
        return ProfileV3TravellersMapper.addTraveller(dto)
    }

    func deleteTraveller(profileID: String) async throws {
        let request = ProfileV3DeleteTravellerRequest(profileID: profileID)
        try await submit(try JSONEncoder().encode(request), action: "delete_traveler")
    }

    func saveTravellerDetails(
        profileID: String,
        firstName: String?,
        lastName: String?,
        passportNumber: String?
    ) async throws {
        guard let userID = session.currentUserID else { throw ProfileV3Error.unauthorized }
        let edit = ProfileV3TravellerEditRequest(
            userID: userID,
            travellerID: profileID,
            firstName: firstName,
            lastName: lastName,
            passportNumber: passportNumber
        )
        let body = try JSONEncoder().encode(edit)
        try await ProfileV3APIErrorMapper.withUnauthorizedRetry(action: "edit_traveler") {
            try await client.perform(.editProfile(body: body))
        }
        await store.invalidate()
    }

    func addTraveller(_ submission: ProfileV3AddTravellerSubmission) async throws -> String? {
        let request = ProfileV3AddTravellerRequest(
            firstName: submission.firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: submission.lastName.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty,
            relationship: submission.relationship,
            mobileNumber: submission.mobileNumber,
            passportNumber: submission.passportNumberValue,
            citizenship: submission.citizenship?.code
        )
        let body = try JSONEncoder().encode(request)
        let response: ProfileV3AddTravellerResponseDTO = try await self.request(
            ProfileV3API.submit(body: body),
            action: "add_traveler"
        )
        await store.invalidate()
        return response.profileID?.nonEmpty
    }

    func loadCoupons() async throws -> ProfileV3CouponsSheet {
        let dto: ProfileV3CouponsSheetDTO = try await request(ProfileV3API.coupons, action: "coupons")
        return ProfileV3CouponsMapper.sheet(dto)
    }

    func loadCoupon(id: String) async throws -> ProfileV3CouponDetail? {
        let dto: ProfileV3CouponDetailDTO = try await request(
            ProfileV3API.coupon(id: id),
            action: "coupon_detail"
        )
        return ProfileV3CouponsMapper.detail(dto)
    }

    func loadConnectorControlPanel() async throws -> ProfileV3ConnectorControlPanel {
        let dto: ProfileV3ConnectorControlPanelScreenDTO = try await request(
            ProfileV3API.connectorControlPanel,
            action: "connector_control_panel"
        )
        return ProfileV3ConnectorsMapper.controlPanel(dto)
    }

    func loadDisconnectConfirm(_ connector: ProfileV3ConnectorKey) async throws -> ProfileV3DisconnectConfirm {
        let dto: ProfileV3DisconnectConfirmScreenDTO = try await request(
            ProfileV3API.disconnectConfirm(connector: connector),
            action: "disconnect_confirm"
        )
        return ProfileV3ConnectorsMapper.disconnectConfirm(dto, fallback: connector)
    }

    func loadPassportHistory(profileID _: String?) async throws -> [ProfileV3Passport] {
        throw ProfileV3Error.notImplemented(action: "passport_history")
    }

    func loadPassportScan(profileID: String?) async throws -> ProfileV3PassportScan {
        let dto: ProfileV3PassportScanScreenDTO = try await request(
            ProfileV3API.passportUpdate(profileID: profileID),
            action: "passport_update"
        )
        return ProfileV3PassportMapper.scan(dto)
    }

    func uploadPassportScan(_ side: ProfileV3PassportSide, data: Data, profileID: String?) async throws
        -> ProfileV3PassportField? {
        let body = ProfileV3PassportScanEncoder.body(side: side, data: data, profileID: profileID)
        let country = await accountCountry(for: profileID)
        let dto: ProfileV3PassportScanResponseDTO = try await request(
            ProfileV3API.passportScan(body: body.data, contentType: body.contentType),
            action: "passport_scan"
        )
        await store.invalidate()
        guard dto.ok != false else { throw ProfileV3Error.server(code: nil, message: nil) }
        return dto.passport.map { ProfileV3PassportMapper.field($0, accountCountry: country) }
    }

    func loadRidePicker(agentType: String, profileID: String?) async throws -> ProfileV3RidePicker {
        let dto: ProfileV3RidePickerScreenDTO = try await request(
            ProfileV3API.ridePicker(agentType: agentType, profileID: profileID),
            action: "ride_picker"
        )
        return ProfileV3AgentMapper.ridePicker(dto)
    }

    func loadPassportReason() async throws -> ProfileV3PassportReasonScreen {
        let dto: ProfileV3PassportReasonScreenDTO = try await request(
            ProfileV3API.passportReason,
            action: "passport_reason"
        )
        return ProfileV3PassportMapper.reason(dto)
    }

    func loadPassportHowUsed() async throws -> ProfileV3PassportHowUsed {
        let dto: ProfileV3PassportHowUsedScreenDTO = try await request(
            ProfileV3API.passportHowUsed,
            action: "passport_how_used"
        )
        guard let howUsed = ProfileV3PassportMapper.howUsed(dto) else { throw ProfileV3RepositoryError.unavailable }
        return howUsed
    }

    func updatePassport(reason: String, profileID: String?) async throws {
        let request = ProfileV3UpdatePassportRequest(reason: reason, profileID: profileID)
        try await submit(try JSONEncoder().encode(request), action: "update_passport")
    }

    func loadPreferenceSources(_ source: ProfileV3SectionSource, profileID: String?) async throws
        -> ProfileV3PreferenceSources {
        let endpoint = ProfileV3API.preferenceSources(
            agentType: source.agentType,
            fieldKey: source.fieldKey,
            profileID: profileID
        )
        let dto: ProfileV3PreferenceSourcesDTO = try await request(endpoint, action: "preference_sources")
        guard let sources = ProfileV3AgentMapper.preferenceSources(dto) else {
            throw ProfileV3RepositoryError.unavailable
        }
        return sources
    }

    func loadBenefits(profileID: String?) async throws -> ProfileV3BenefitsSheet {
        let endpoint = ProfileV3API.benefits(profileID: profileID)
        let dto: ProfileV3BenefitsSheetDTO = try await request(endpoint, action: "benefits")
        return ProfileV3BenefitsMapper.sheet(dto)
    }

    func loadBenefit(id: String) async throws -> ProfileV3Benefit? {
        let dto: ProfileV3BenefitDetailDTO = try await request(ProfileV3API.benefit(id: id), action: "benefit")
        return ProfileV3BenefitsMapper.detail(dto)
    }

    func loadProgrammeCatalogue(query: String?, kind: String?) async throws -> ProfileV3ProgrammePicker {
        let endpoint = ProfileV3API.loyaltyCatalogue(query: query, kind: kind)
        let dto: ProfileV3LoyaltyPickScreenDTO = try await request(endpoint, action: "loyalty_catalogue")
        return ProfileV3LoyaltyMapper.picker(dto)
    }

    func loadLoyaltyEntry(
        programID: String,
        programName: String?,
        kind: String?
    ) async throws -> ProfileV3LoyaltyEntryForm {
        let endpoint = ProfileV3API.loyaltyEnter(
            programID: programID,
            programName: programName,
            kind: kind
        )
        let dto: ProfileV3LoyaltyEnterScreenDTO = try await request(endpoint, action: "loyalty_enter_details")
        return ProfileV3LoyaltyMapper.entryForm(dto, programID: programID, programName: programName, kind: kind)
    }

    func saveProfileField(
        _ field: ProfileV3ProfileField,
        value: ProfileV3ProfileFieldValue,
        profileID: String?
    ) async throws {
        let request = ProfileV3EditProfileFieldRequest(
            field: field.rawValue,
            value: value,
            profileID: field.isAccountScoped ? nil : profileID
        )
        try await submit(try JSONEncoder().encode(request), action: "edit_profile_field")
    }

    func saveTravellerRelationship(_ value: String, profileID: String) async throws {
        let request = ProfileV3EditProfileFieldRequest(
            field: ProfileV3AddTravellerField.relationshipKey,
            value: .code(value),
            profileID: profileID
        )
        try await submit(try JSONEncoder().encode(request), action: "edit_profile_field")
    }

    func loadPermissions() async throws -> ProfileV3Permissions {
        let dto: ProfileV3PermissionsScreenDTO = try await request(ProfileV3API.permissions, action: "permissions")
        guard let permissions = ProfileV3SettingsMapper.permissions(dto) else {
            throw ProfileV3RepositoryError.unavailable
        }
        return permissions
    }

    func savePermission(_ optionID: String, in sectionID: String) async throws {
        let request = ProfileV3SavePermissionsRequest(updates: [sectionID: optionID])
        try await submit(try JSONEncoder().encode(request), action: "save_permissions")
    }

    func loadPastTrips(profileID: String) async throws -> [ProfileV3PastTrip] {
        await ProfileV3PastTripsStore.shared.trips(profileID: profileID)
    }

    func addPastTrip(_ draft: ProfileV3PastTripDraft, profileID: String) async throws -> ProfileV3PastTrip {
        await ProfileV3PastTripsStore.shared.add(draft, profileID: profileID)
    }

    func updatePastTrip(
        id: String,
        with draft: ProfileV3PastTripDraft,
        profileID: String
    ) async throws -> ProfileV3PastTrip {
        try await ProfileV3PastTripsStore.shared.update(id: id, with: draft, profileID: profileID)
    }

    func deletePastTrip(id: String, profileID: String) async throws {
        await ProfileV3PastTripsStore.shared.remove(id: id, profileID: profileID)
    }

    func acknowledgeLogout() async throws {
        try await submit(try JSONEncoder().encode(ProfileV3LogoutRequest()), action: "logout")
    }

    func requestAccountDeletion() async throws {
        let body = try JSONEncoder().encode(ProfileV3SlackAlertRequest.accountDeletion)
        let response: ProfileV3SlackAlertResponseDTO = try await request(
            ProfileV3API.slackAlert(body: body),
            action: "account_deletion"
        )
        guard response.success != false else { throw ProfileV3Error.server(code: nil, message: nil) }
    }

    func loadProgrammeInsight(programID: String, profileID: String?) async throws -> ProfileV3ProgrammeInsight {
        let endpoint = ProfileV3API.loyaltyInsight(programID: programID, profileID: profileID)
        let dto: ProfileV3ProgrammeInsightScreenDTO = try await request(endpoint, action: "program_insight")
        return ProfileV3LoyaltyMapper.insight(dto)
    }

    func loadProgrammeSources(programID: String, profileID: String?) async throws -> ProfileV3PreferenceSources {
        let endpoint = ProfileV3API.loyaltySources(programID: programID, profileID: profileID)
        let dto: ProfileV3PreferenceSourcesDTO = try await request(endpoint, action: "loyalty_sources")
        guard let sources = ProfileV3AgentMapper.preferenceSources(dto) else {
            throw ProfileV3RepositoryError.unavailable
        }
        return sources
    }

    func addProgramme(_ submission: ProfileV3ProgrammeSubmission, profileID: String?) async throws {
        guard let profileID else {
            throw ProfileV3Error.invalidRequest(message: nil)
        }
        let request = ProfileV3LoyaltyMapper.addProgrammeRequest(submission, profileID: profileID, kind: nil)
        try await submit(try JSONEncoder().encode(request), action: "add_loyalty_program")
    }

    func loadProgrammes(passID: String) async throws -> ProfileV3ProgrammeOverview {
        let endpoint = ProfileV3API.loyaltyPage(profileID: passID)
        let dto: ProfileV3ProgrammesPageScreenDTO = try await request(endpoint, action: "programs_page")
        return ProfileV3LoyaltyMapper.overview(dto, profileID: passID)
    }

    func scanProgrammes() -> AsyncThrowingStream<ProfileV3ProgrammeScanEvent, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish(throwing: ProfileV3Error.notImplemented(action: "scan_programmes"))
        }
    }

    func redeemBenefit(id: String) async throws {
        throw ProfileV3Error.notImplemented(action: "redeem_benefit")
    }

    func startKYCCapture(steps: [String], profileID: String?) async throws -> ProfileV3CaptureStep? {
        let body = try ProfileV3CaptureEncoder.start(steps: steps, profileID: profileID)
        return try await capture(ProfileV3API.captureStart(body: body), action: "capture_start")
    }

    func loadKYCCaptureState() async throws -> ProfileV3CaptureStep? {
        try await capture(ProfileV3API.captureState, action: "capture_state")
    }

    func answerKYCCapture(_ answer: ProfileV3CaptureAnswer, stepID: String) async throws -> ProfileV3CaptureStep? {
        let body = try ProfileV3CaptureEncoder.answer(answer, stepID: stepID)
        let endpoint = ProfileV3API.captureAnswer(body: body.data, contentType: body.contentType)
        return try await capture(endpoint, action: "capture_answer")
    }

    func uploadKYCCaptureImage(
        _ image: ProfileV3CaptureImage,
        data: Data,
        stepID: String,
        residenceCountryCode: String?
    ) async throws -> ProfileV3CaptureStep? {
        let body = try ProfileV3CaptureEncoder.image(
            image,
            data: data,
            stepID: stepID,
            residenceCountryCode: residenceCountryCode
        )
        let endpoint = ProfileV3API.captureAnswer(body: body.data, contentType: body.contentType)
        do {
            return try await capture(endpoint, action: "capture_answer_file")
        } catch {
            throw ProfileV3APIErrorMapper.mapCaptureUpload(error, image: image)
        }
    }

    func uploadKYCCaptureDocument(_ data: Data, stepID: String) async throws -> ProfileV3CaptureStep? {
        let body = try ProfileV3CaptureEncoder.document(data, stepID: stepID)
        let endpoint = ProfileV3API.captureAnswer(body: body.data, contentType: body.contentType)
        return try await capture(endpoint, action: "capture_answer_file")
    }

    func uploadCoTravellerImage(_ image: ProfileV3CaptureImage, data: Data, profileID: String) async throws {
        let body = try ProfileV3CaptureEncoder.coTraveller(image, data: data, profileID: profileID)
        let endpoint = ProfileV3API.coTraveller(body: body.data, contentType: body.contentType)
        do {
            let dto: ProfileV3CoTravellerUploadDTO = try await request(endpoint, action: "co_traveler")
            await store.invalidate()
            try throwIfFailed(dto.error)
        } catch {
            throw ProfileV3APIErrorMapper.mapCaptureUpload(error, image: image)
        }
    }

    private func capture(_ endpoint: ProfileV3API, action: String) async throws -> ProfileV3CaptureStep? {
        let dto: ProfileV3CaptureEnvelopeDTO = try await request(endpoint, action: action)
        await store.invalidate()
        try throwIfFailed(dto.error)
        return ProfileV3CaptureMapper.step(dto.nextStep)
    }

    private func throwIfFailed(_ error: ProfileV3CaptureErrorDTO?) throws {
        guard let error, error.code != nil || error.message != nil else { return }
        throw ProfileV3Error.server(code: error.code, message: error.message)
    }

    func removeProgramme(id: String, name: String, profileID: String) async throws {
        let request = ProfileV3RemoveProgrammeRequest(
            profileID: profileID,
            programName: name,
            programID: id.isEmpty ? nil : id
        )
        try await submit(try JSONEncoder().encode(request), action: "remove_loyalty_program")
    }

    func reorderProgrammes(_ order: [String], profileID: String, action: String) async throws {
        let request = ProfileV3ReorderProgrammesRequest(action: action, profileID: profileID, order: order)
        try await submit(try JSONEncoder().encode(request), action: action)
    }

    private func request<T: Decodable>(_ endpoint: ProfileV3API, action: String) async throws -> T {
        try await ProfileV3APIErrorMapper.withUnauthorizedRetry(action: action) {
            try await client.request(endpoint)
        }
    }

    private func submit(_ body: Data, action: String) async throws {
        try await ProfileV3APIErrorMapper.withUnauthorizedRetry(action: action) {
            try await client.perform(.submit(body: body))
        }
        await store.invalidate()
    }
}
