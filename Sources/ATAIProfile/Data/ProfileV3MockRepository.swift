import Foundation

#if DEBUG
final class ProfileV3SessionStore: @unchecked Sendable {
    static let shared = ProfileV3SessionStore()

    private let lock = NSLock()
    private var _homes: [String: ProfileV3Home]
    private var _flows = ProfileV3AgentFixtures.flows
    private let mainPassID = ProfileV3Fixtures.worldPass.id

    init(homes: [String: ProfileV3Home] = ProfileV3Fixtures.homesByPass) {
        _homes = homes
    }

    var home: ProfileV3Home {
        get { home(for: nil) }
        set { updateHomes { id, home in id == mainPassID ? newValue : home } }
    }

    func home(for passID: String?) -> ProfileV3Home {
        lock.lock()
        defer { lock.unlock() }
        return _homes[passID ?? mainPassID] ?? _homes[mainPassID] ?? ProfileV3Fixtures.home
    }

    func updateHomes(_ transform: (String, ProfileV3Home) -> ProfileV3Home) {
        lock.lock()
        let snapshot = _homes
        lock.unlock()
        let updated = Dictionary(uniqueKeysWithValues: snapshot.map { ($0.key, transform($0.key, $0.value)) })
        lock.lock()
        _homes = updated
        lock.unlock()
    }

    var flows: [String: ProfileV3AgentFlow] {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _flows
        }
        set {
            lock.lock()
            _flows = newValue
            lock.unlock()
        }
    }

    func updateFlow(id: String, _ flow: ProfileV3AgentFlow) {
        lock.lock()
        _flows[id] = flow
        lock.unlock()
    }

    private var _relationships: [String: String] = [:]

    var relationships: [String: String] {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _relationships
        }
        set {
            lock.lock()
            _relationships = newValue
            lock.unlock()
        }
    }
}

struct ProfileV3MockRepository: ProfileV3Repository {
    var delay: Duration = .milliseconds(600)
    private let session: ProfileV3SessionStore
    private let pastTrips: ProfileV3PastTripsStore

    init(
        delay: Duration = .milliseconds(600),
        session: ProfileV3SessionStore = .shared,
        pastTrips: ProfileV3PastTripsStore = ProfileV3PastTripsStore(
            tripsByProfile: ProfileV3PastTripsFixtures.byProfile
        )
    ) {
        self.delay = delay
        self.session = session
        self.pastTrips = pastTrips
    }

    func loadBoard() async throws -> ProfileV3Board {
        try await Task.sleep(for: delay)
        let passes = session.home(for: nil).worldPasses
        return ProfileV3Board(
            profiles: passes.map { pass in
                ProfileV3ProfileBoard(
                    profileID: pass.id,
                    isMain: pass.id == passes.first?.id,
                    name: pass.holderName,
                    pass: pass,
                    home: session.home(for: pass.id)
                )
            }
        )
    }

    func loadAgentFlow(agentID: String, profileID _: String?) async throws -> ProfileV3AgentFlow {
        try await Task.sleep(for: delay)
        guard let flow = session.flows[agentID] else { throw ProfileV3RepositoryError.agentNotFound }
        return flow
    }

    func saveAgentForm(_ form: ProfileV3AgentForm, profileID _: String?) async throws {
        try await Task.sleep(for: delay)
        session.updateFlow(id: form.agentID, .preferences(form))
    }

    func loadEditField(_ field: ProfileV3ProfileField) async throws -> ProfileV3EditField {
        try await Task.sleep(for: delay)
        return ProfileV3Fixtures.editField(field.rawValue)
    }

    func loadConnectors() async throws -> ProfileV3ConnectorsScreen {
        try await Task.sleep(for: delay)
        return ProfileV3Fixtures.connectorsScreen
    }

    func disconnectConnector(_: ProfileV3ConnectorKey) async throws {
        try await Task.sleep(for: delay)
    }

    func syncPhotoPlaces(_: ProfileV3PhotoPlacesUpload) async throws {
        try await Task.sleep(for: delay)
    }

    func loadConnectorControlPanel() async throws -> ProfileV3ConnectorControlPanel {
        try await Task.sleep(for: delay)
        return ProfileV3Fixtures.connectorControlPanel
    }

    func loadCoupons() async throws -> ProfileV3CouponsSheet {
        try await Task.sleep(for: delay)
        return ProfileV3Fixtures.couponsSheet
    }

    func loadCoupon(id: String) async throws -> ProfileV3CouponDetail? {
        try await Task.sleep(for: delay)
        return id == ProfileV3Fixtures.depletedCouponDetail.id
            ? ProfileV3Fixtures.depletedCouponDetail
            : ProfileV3Fixtures.couponDetail
    }

    func loadEditTravellers() async throws -> ProfileV3EditTravellersScreen {
        try await Task.sleep(for: delay)
        var screen = ProfileV3Fixtures.editTravellers
        for (profileID, value) in session.relationships {
            screen.setRelationship(value, for: profileID)
        }
        return screen
    }

    func loadTravellerRelationship(profileID: String) async throws -> ProfileV3EditField {
        try await Task.sleep(for: delay)
        let current = session.relationships[profileID]
            ?? ProfileV3Fixtures.editTravellers.travellers.first { $0.id == profileID }?.relationship
        return ProfileV3Fixtures.relationshipField(profileID: profileID, selected: current)
    }

    func saveTravellerRelationship(_ value: String, profileID: String) async throws {
        try await Task.sleep(for: delay)
        session.relationships[profileID] = value
    }

    func loadDeleteTravellerConfirm(profileID: String) async throws -> ProfileV3DeleteTravellerConfirm {
        try await Task.sleep(for: delay)
        return ProfileV3Fixtures.deleteTravellerConfirm(profileID)
    }

    func loadAddTraveller() async throws -> ProfileV3AddTravellerScreen {
        try await Task.sleep(for: delay)
        return ProfileV3Fixtures.addTraveller
    }

    func loadTerms(locale _: String?) async throws -> ProfileV3Terms? {
        try await Task.sleep(for: delay)
        return ProfileV3TermsContent.terms
    }

    func saveTravellerDetails(
        profileID _: String,
        firstName _: String?,
        lastName _: String?,
        passportNumber _: String?
    ) async throws {
        try await Task.sleep(for: delay)
    }

    func deleteTraveller(profileID _: String) async throws {
        try await Task.sleep(for: delay)
    }

    func addTraveller(_: ProfileV3AddTravellerSubmission) async throws -> String? {
        try await Task.sleep(for: delay)
        return UUID().uuidString
    }

    func loadDisconnectConfirm(_ connector: ProfileV3ConnectorKey) async throws -> ProfileV3DisconnectConfirm {
        try await Task.sleep(for: delay)
        return ProfileV3Fixtures.disconnectConfirm(connector)
    }

    func loadPassportHistory(profileID _: String?) async throws -> [ProfileV3Passport] {
        try await Task.sleep(for: delay)
        return ProfileV3PassportFixtures.history
    }

    func loadPassportScan(profileID _: String?) async throws -> ProfileV3PassportScan {
        try await Task.sleep(for: delay)
        return ProfileV3PassportFixtures.scan
    }

    func uploadPassportScan(_: ProfileV3PassportSide, data _: Data, profileID _: String?) async throws
        -> ProfileV3PassportField? {
        try await Task.sleep(for: delay)
        return ProfileV3PassportFixtures.field
    }

    func loadPassportReason() async throws -> ProfileV3PassportReasonScreen {
        try await Task.sleep(for: delay)
        return ProfileV3PassportFixtures.reason
    }

    func loadRidePicker(agentType _: String, profileID _: String?) async throws -> ProfileV3RidePicker {
        try await Task.sleep(for: delay)
        return ProfileV3AgentFixtures.ridePicker
    }

    func loadPassportHowUsed() async throws -> ProfileV3PassportHowUsed {
        try await Task.sleep(for: delay)
        return ProfileV3PassportFixtures.howUsed
    }

    func updatePassport(reason _: String, profileID _: String?) async throws {
        try await Task.sleep(for: delay)
    }

    func loadPreferenceSources(_: ProfileV3SectionSource, profileID _: String?) async throws
        -> ProfileV3PreferenceSources {
        try await Task.sleep(for: delay)
        return ProfileV3AgentFixtures.airlineSources
    }

    func loadSettings() async throws -> ProfileV3SettingsMenu {
        try await Task.sleep(for: delay)
        return ProfileV3Fixtures.settingsMenu
    }

    func loadBenefits(profileID _: String?) async throws -> ProfileV3BenefitsSheet {
        try await Task.sleep(for: delay)
        let offers = ProfileV3Fixtures.giftCards + ProfileV3BenefitCatalogue.all
        return ProfileV3BenefitsSheet(count: offers.count, offers: offers)
    }

    func loadBenefit(id: String) async throws -> ProfileV3Benefit? {
        try await Task.sleep(for: delay)
        return ProfileV3BenefitCatalogue.all.first { $0.id == id }
    }

    func redeemBenefit(id: String) async throws {
        try await Task.sleep(for: delay)
        session.updateHomes { _, home in home.markingBenefitRedeemed(id: id, on: ProfileV3Strings.redeemedJustNow) }
    }

    func scanProgrammes() -> AsyncThrowingStream<ProfileV3ProgrammeScanEvent, Error> {
        let step = Duration.milliseconds(ProfileV3Theme.Motion.scanStepMilliseconds)
        let total = ProfileV3ProgrammeCatalogue.mockFoundCount
        let settle = delay
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    continuation.yield(.searching(activity: ProfileV3Strings.goingThroughEmails, foundCount: 0))
                    for found in 1...total {
                        try await Task.sleep(for: step)
                        continuation.yield(.searching(activity: ProfileV3Strings.goingThroughEmails, foundCount: found))
                    }
                    try await Task.sleep(for: settle)
                    continuation.yield(.finished(foundCount: total))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func loadProgrammeCatalogue(query _: String?, kind _: String?) async throws -> ProfileV3ProgrammePicker {
        try await Task.sleep(for: delay)
        return ProfileV3ProgrammePicker(
            items: ProfileV3ProgrammeCatalogue.all,
            filters: ProfileV3ProgrammeCategory.allCases.map {
                ProfileV3ProgrammeFilter(label: $0.title, category: $0)
            }
        )
    }

    func addProgramme(_ submission: ProfileV3ProgrammeSubmission, profileID: String?) async throws {
        try await Task.sleep(for: delay)
        let programme = ProfileV3LoyaltyProgramme(
            id: "\(submission.item.id)-\(UUID().uuidString.prefix(8))",
            name: submission.item.name,
            maskedNumber: ProfileV3ProgrammeCatalogue.masked(submission.membershipNumber),
            points: submission.points ?? 0,
            logoURL: submission.item.logoURL,
            artURL: submission.item.cardImageURL,
            membershipNumber: submission.membershipNumber.nonEmpty
        )
        if let passID = profileID ?? session.home.worldPass?.id {
            session.updateHomes { _, home in home.addingProgramme(programme, toPassID: passID) }
        }
    }

    func startKYCCapture(steps: [String], profileID _: String?) async throws -> ProfileV3CaptureStep? {
        try await Task.sleep(for: delay)
        if steps == [ProfileV3CaptureStepKey.itr] {
            return ProfileV3Fixtures.itrCaptureStep
        }
        let mainPassID = ProfileV3Fixtures.worldPass.id
        session.updateHomes { id, home in
            home.withKYCStatus(ProfileV3Fixtures.kycComplete, forPassID: mainPassID, appliesToHome: id == mainPassID)
        }
        return nil
    }

    func loadKYCCaptureState() async throws -> ProfileV3CaptureStep? {
        nil
    }

    func answerKYCCapture(_ answer: ProfileV3CaptureAnswer, stepID _: String) async throws -> ProfileV3CaptureStep? {
        try await Task.sleep(for: delay)
        if case .itrCredentials = answer {
            return ProfileV3Fixtures.itrCompletedCaptureStep
        }
        return nil
    }

    func uploadKYCCaptureDocument(_: Data, stepID _: String) async throws -> ProfileV3CaptureStep? {
        try await Task.sleep(for: delay)
        return ProfileV3Fixtures.itrCompletedCaptureStep
    }

    func uploadKYCCaptureImage(
        _: ProfileV3CaptureImage,
        data _: Data,
        stepID _: String,
        residenceCountryCode _: String?
    ) async throws -> ProfileV3CaptureStep? {
        try await Task.sleep(for: delay)
        return nil
    }

    func uploadCoTravellerImage(_: ProfileV3CaptureImage, data _: Data, profileID _: String) async throws {
        try await Task.sleep(for: delay)
    }

    func loadLoyaltyEntry(
        programID: String,
        programName: String?,
        kind: String?
    ) async throws -> ProfileV3LoyaltyEntryForm {
        try await Task.sleep(for: delay)
        return ProfileV3LoyaltyEntryForm(
            programID: programID,
            programName: programName,
            kind: kind,
            title: ProfileV3Strings.enterDetails,
            submitLabel: nil,
            fields: [
                .init(
                    key: ProfileV3LoyaltyEntryForm.Field.membershipNumberKey,
                    label: ProfileV3Strings.membershipNumber,
                    isRequired: true
                ),
                .init(
                    key: ProfileV3LoyaltyEntryForm.Field.pointsKey,
                    label: ProfileV3Strings.pointsMiles,
                    isRequired: false
                )
            ]
        )
    }

    func loadProgrammeInsight(programID: String, profileID _: String?) async throws -> ProfileV3ProgrammeInsight {
        try await Task.sleep(for: delay)
        let all = ProfileV3ProgrammeFixtures.overview(for: ProfileV3Fixtures.worldPass).programmes
        guard let insight = all.first(where: { $0.id == programID })?.insight ?? all.first?.insight else {
            throw ProfileV3RepositoryError.unavailable
        }
        return insight
    }

    func loadProgrammeSources(programID _: String, profileID _: String?) async throws -> ProfileV3PreferenceSources {
        try await Task.sleep(for: delay)
        return ProfileV3ProgrammeFixtures.sources
    }

    func saveProfileField(
        _: ProfileV3ProfileField,
        value _: ProfileV3ProfileFieldValue,
        profileID _: String?
    ) async throws {
        try await Task.sleep(for: delay)
    }

    func loadPermissions() async throws -> ProfileV3Permissions {
        try await Task.sleep(for: delay)
        return ProfileV3PermissionDefaults.permissions
    }

    func savePermission(_: String, in _: String) async throws {
        try await Task.sleep(for: delay)
    }

    func loadPastTrips(profileID: String) async throws -> [ProfileV3PastTrip] {
        try await Task.sleep(for: delay)
        return await pastTrips.trips(profileID: profileID)
    }

    func addPastTrip(_ draft: ProfileV3PastTripDraft, profileID: String) async throws -> ProfileV3PastTrip {
        try await Task.sleep(for: delay)
        return await pastTrips.add(draft, profileID: profileID)
    }

    func updatePastTrip(
        id: String,
        with draft: ProfileV3PastTripDraft,
        profileID: String
    ) async throws -> ProfileV3PastTrip {
        try await Task.sleep(for: delay)
        return try await pastTrips.update(id: id, with: draft, profileID: profileID)
    }

    func deletePastTrip(id: String, profileID: String) async throws {
        try await Task.sleep(for: delay)
        await pastTrips.remove(id: id, profileID: profileID)
    }

    func acknowledgeLogout() async throws {
        try await Task.sleep(for: delay)
    }

    func requestAccountDeletion() async throws {
        try await Task.sleep(for: delay)
    }

    func loadProgrammes(passID: String) async throws -> ProfileV3ProgrammeOverview {
        try await Task.sleep(for: delay)
        let pass = session.home(for: passID).worldPasses.first { $0.id == passID }
        return ProfileV3ProgrammeFixtures.overview(for: pass)
    }

    func removeProgramme(id: String, name _: String, profileID: String) async throws {
        try await Task.sleep(for: delay)
        session.updateHomes { _, home in home.removingProgramme(id: id, fromPassID: profileID) }
    }

    func reorderProgrammes(_: [String], profileID _: String, action _: String) async throws {
        try await Task.sleep(for: delay)
    }
}
#endif
