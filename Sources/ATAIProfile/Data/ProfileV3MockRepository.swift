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
    private let persona: ProfileV3PersonaStore
    private let appAccess: ProfileV3AppAccessStore
    private let vault: ProfileV3VaultStore
    private let gloveBox: ProfileV3GloveBoxStore
    private let customRules: ProfileV3CustomRulesStore
    private let settingsCitizenship: String?

    init(
        delay: Duration = .milliseconds(600),
        session: ProfileV3SessionStore = .shared,
        pastTrips: ProfileV3PastTripsStore = ProfileV3PastTripsStore(
            tripsByProfile: ProfileV3PastTripsFixtures.byProfile
        ),
        persona: ProfileV3PersonaStore = ProfileV3PersonaStore(),
        appAccess: ProfileV3AppAccessStore = ProfileV3AppAccessStore(),
        vault: ProfileV3VaultStore = ProfileV3VaultStore(),
        gloveBox: ProfileV3GloveBoxStore = ProfileV3GloveBoxStore(),
        customRules: ProfileV3CustomRulesStore = ProfileV3CustomRulesStore(),
        settingsCitizenship: String? = nil
    ) {
        self.delay = delay
        self.session = session
        self.pastTrips = pastTrips
        self.persona = persona
        self.appAccess = appAccess
        self.vault = vault
        self.gloveBox = gloveBox
        self.customRules = customRules
        self.settingsCitizenship = settingsCitizenship
    }

    func loadAppAccess() async throws -> ProfileV3AppAccess {
        try await Task.sleep(for: delay)
        return appAccess.snapshot()
    }

    func saveAppCredentials(_ credentials: ProfileV3AppCredentials, appID: String) async throws {
        try await Task.sleep(for: delay)
        try appAccess.connect(appID, credentials: credentials)
    }

    func addAppPassword(_ credentials: ProfileV3AppCredentials) async throws {
        try await Task.sleep(for: delay)
        appAccess.addPassword(credentials)
    }

    func disconnectApp(_ appID: String) async throws {
        try await Task.sleep(for: delay)
        appAccess.disconnect(appID)
    }

    func loadVaultCredentials() async throws -> [ProfileV3VaultCredential] {
        try await Task.sleep(for: delay)
        return vault.list()
    }

    func loadVaultSites() async throws -> [ProfileV3VaultSite] {
        ProfileV3VaultFixtures.sites
    }

    func saveVault(_ draft: ProfileV3VaultDraft) async throws -> ProfileV3VaultWriteResult {
        try await Task.sleep(for: delay)
        return try vault.save(draft)
    }

    func updateVault(id: String, draft: ProfileV3VaultDraft) async throws -> ProfileV3VaultWriteResult {
        try await Task.sleep(for: delay)
        return try vault.update(id: id, draft: draft)
    }

    func vaultCredential(id: String, includeUsername: Bool) async throws -> ProfileV3VaultCredential {
        try await Task.sleep(for: delay)
        return try vault.credential(id: id, includeUsername: includeUsername)
    }

    func retestVaultCredential(id: String) async throws -> ProfileV3VaultWriteResult {
        throw ProfileV3Error.notImplemented(action: "vault_retest")
    }

    func deleteVaultCredential(id: String) async throws {
        try await Task.sleep(for: delay)
        vault.delete(id: id)
    }

    func pauseVaultCredential(id: String) async throws -> ProfileV3VaultWriteResult {
        throw ProfileV3Error.notImplemented(action: "vault_pause")
    }

    func resumeVaultCredential(id: String) async throws -> ProfileV3VaultWriteResult {
        throw ProfileV3Error.notImplemented(action: "vault_resume")
    }

    func revealVaultPassword(id: String, deviceName _: String) async throws -> String {
        try await Task.sleep(for: delay)
        return try vault.password(id: id)
    }

    func loadTravelPersona(profileID: String?) async throws -> ProfileV3TravelPersona {
        try await Task.sleep(for: delay)
        return ProfileV3PersonaFixtures.persona(persona, profileID: profileID)
    }

    func loadPersonaTrait(_ trait: String, profileID: String?, page _: Int) async throws -> ProfileV3PersonaTrait {
        try await Task.sleep(for: delay)
        guard let screen = ProfileV3PersonaFixtures.trait(trait, store: persona, profileID: profileID) else {
            throw ProfileV3Error.server(code: "unknown_trait", message: nil)
        }
        return screen
    }

    func submitPersonaAction(_ action: ProfileV3BoardAction, score: Int?) async throws {
        try await Task.sleep(for: delay)
        guard let trait = action.fields["trait"]?.stringValue else {
            throw ProfileV3Error.invalidRequest(message: nil)
        }
        let sourceID = action.fields["source_id"]?.stringValue
        switch action.name {
        case "set_persona_score":
            guard let score else { throw ProfileV3Error.invalidRequest(message: nil) }
            persona.setScore(score, for: trait)
        case "ignore_persona_source":
            persona.setIgnored(true, sourceID: sourceID, trait: trait)
        case "unignore_persona_source":
            persona.setIgnored(false, sourceID: sourceID, trait: trait)
        case "ignore_all_persona_sources":
            persona.setIgnored(true, sourceID: nil, trait: trait)
        case "unignore_all_persona_sources":
            persona.setIgnored(false, sourceID: nil, trait: trait)
        default:
            throw ProfileV3Error.invalidRequest(message: nil)
        }
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

    func saveAgentForm(
        _ form: ProfileV3AgentForm,
        profileID _: String?,
        profileIDs _: [String]?
    ) async throws -> String? {
        try await Task.sleep(for: delay)
        session.updateFlow(id: form.agentID, .preferences(form))
        return ProfileV3Strings.agentPreferencesUpdated
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

    func loadPreviousPassports(profileID _: String?) async throws -> ProfileV3PreviousPassports {
        try await Task.sleep(for: delay)
        return ProfileV3PassportFixtures.previous
    }

    func loadPassportScan(profileID _: String?) async throws -> ProfileV3PassportScan {
        try await Task.sleep(for: delay)
        return ProfileV3PassportFixtures.scan
    }

    func uploadPassportScan(_: ProfileV3PassportSide, data _: Data, profileID _: String?) async throws
        -> ProfileV3PassportScanResult {
        try await Task.sleep(for: delay)
        return ProfileV3PassportScanResult(field: ProfileV3PassportFixtures.field, backRequired: true)
    }

    func loadPassportReason() async throws -> ProfileV3PassportReasonScreen {
        try await Task.sleep(for: delay)
        return ProfileV3PassportFixtures.reason
    }

    func loadRidePicker(agentType _: String, profileID _: String?) async throws -> ProfileV3RidePicker {
        try await Task.sleep(for: delay)
        return ProfileV3AgentFixtures.ridePicker
    }

    func loadRideRegions() async throws -> ProfileV3RideRegions {
        try await Task.sleep(for: delay)
        return ProfileV3AgentFixtures.rideRegions
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
        var menu = ProfileV3Fixtures.settingsMenu
        menu.citizenshipCode = settingsCitizenship
        return menu
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
            maskedNumber: ProfileV3ProgrammeCatalogue.masked(submission.membershipNumber ?? ""),
            points: submission.points ?? 0,
            logoURL: submission.item.logoURL,
            artURL: submission.item.cardImageURL,
            membershipNumber: submission.membershipNumber?.nonEmpty
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
        return ProfileV3LoyaltyEntryForm.mock(programID: programID, programName: programName, kind: kind)
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

    func loadPastTrips(profileID: String) async throws -> ProfileV3PastTripsScreen {
        try await Task.sleep(for: delay)
        return ProfileV3PastTripsFixtures.screen(await pastTrips.trips(profileID: profileID), profileID: profileID)
    }

    func loadAddTrip(profileID: String) async throws -> ProfileV3AddTripScreen {
        try await Task.sleep(for: delay)
        return ProfileV3PastTripsFixtures.addScreen(profileID: profileID)
    }

    func addPastTrips(_ submit: ProfileV3BoardAction, countries: [String]) async throws {
        try await Task.sleep(for: delay)
        let profileID = submit.fields["profile_id"]?.stringValue ?? ""
        for country in countries {
            await pastTrips.add(ProfileV3PastTripDraft(countryCode: country), profileID: profileID)
        }
    }

    func deletePastTrip(_ submit: ProfileV3BoardAction) async throws {
        try await Task.sleep(for: delay)
        guard let id = submit.fields["trip_id"]?.stringValue,
              let profileID = submit.fields["profile_id"]?.stringValue else {
            throw ProfileV3RepositoryError.unavailable
        }
        await pastTrips.remove(id: id, profileID: profileID)
    }

    func acknowledgeLogout() async throws {
        try await Task.sleep(for: delay)
    }

    func requestAccountDeletion() async throws {
        try await Task.sleep(for: delay)
    }

    func loadDeleteAccountReason() async throws -> ProfileV3DeleteAccountReason {
        try await Task.sleep(for: delay)
        return ProfileV3Fixtures.deleteAccountReason
    }

    func loadDeleteAccountConfirm() async throws -> ProfileV3DeleteAccountConfirm {
        try await Task.sleep(for: delay)
        return ProfileV3Fixtures.deleteAccountConfirm
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

extension ProfileV3MockRepository: ProfileV3CustomRulesRepository {
    func loadCustomRules(agentID: String, profileID: String?) async throws -> [ProfileV3CustomRule] {
        customRules.rules(owner: "mock", agentID: agentID, profileID: profileID)
    }

    func saveCustomRule(_ rule: ProfileV3CustomRule, agentID: String, profileID: String?) async throws {
        customRules.save(rule, owner: "mock", agentID: agentID, profileID: profileID)
    }

    func deleteCustomRule(id: String, agentID: String, profileID: String?) async throws {
        customRules.delete(id: id, owner: "mock", agentID: agentID, profileID: profileID)
    }
}

extension ProfileV3MockRepository: ProfileV3GloveBoxRepository {
    func loadGloveBoxCard() async throws -> ProfileV3GloveBoxAccount {
        try await Task.sleep(for: delay)
        return gloveBox.snapshot()
    }

    func createGloveBoxAddress() async throws -> ProfileV3GloveBoxAccount {
        try await Task.sleep(for: delay)
        return gloveBox.update { $0.address = ProfileV3GloveBoxFixtures.email.address }
    }

    func setGloveBoxForwardingPaused(_ paused: Bool) async throws -> ProfileV3GloveBoxAccount {
        try await Task.sleep(for: delay)
        return gloveBox.update { $0.forwardingPaused = paused }
    }

    func addGloveBoxForwardingAddress(_ email: String) async throws -> ProfileV3GloveBoxAccount {
        try await Task.sleep(for: delay)
        return gloveBox.update { $0.pendingEmail = email }
    }

    func loadGloveBoxMessages(cursor _: String?) async throws -> ProfileV3GloveBoxInboxPage {
        try await Task.sleep(for: delay)
        return ProfileV3GloveBoxInboxPage(emails: ProfileV3GloveBoxFixtures.emails, nextCursor: nil)
    }

    func loadGloveBoxMessage(_ listed: ProfileV3GloveBoxEmail) async throws -> ProfileV3GloveBoxEmail {
        try await Task.sleep(for: delay)
        return listed
    }

    func loadGloveBoxAttachment(messageID _: String, index _: Int) async throws -> Data {
        throw ProfileV3Error.notImplemented(action: "glovebox_attachment")
    }
}

extension ProfileV3LoyaltyEntryForm {
    static func mock(programID: String, programName: String?, kind: String?) -> ProfileV3LoyaltyEntryForm {
        let points = Field(key: Field.pointsKey, label: ProfileV3Strings.pointsMiles, isRequired: false)
        let membership = Field(key: Field.membershipNumberKey, label: ProfileV3Strings.membershipNumber, isRequired: true)
        let isCard = kind == ProfileV3LoyaltyMapper.kind(for: .creditCards)
        return ProfileV3LoyaltyEntryForm(
            programID: programID,
            programName: programName,
            kind: kind,
            title: "Enter details",
            submitLabel: nil,
            fields: isCard ? [points] : [membership, points]
        )
    }
}
#endif
