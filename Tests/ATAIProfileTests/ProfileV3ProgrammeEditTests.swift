import Foundation
import Moya
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Programme edit")
struct ProfileV3ProgrammeEditTests {
    @Test func theEditFormHasItsOwnRouteAndKeepsSlashesInTheID() {
        let endpoint = ProfileV3API.loyaltyEdit(programID: "au-small-finance-bank/au-bank-lit-credit-card", profileID: "p1")
        #expect(endpoint.path == "/api/gmail-connector/kyc/v2/board/loyalty/edit/au-small-finance-bank/au-bank-lit-credit-card")
        #expect(endpoint.method == .get)
        guard case .requestParameters(let parameters, _) = endpoint.task else {
            Issue.record("expected query parameters")
            return
        }
        #expect(parameters["profile_id"] as? String == "p1")
    }

    @Test func theEditFormCarriesTheSavedValues() throws {
        let form = try Self.editForm()
        #expect(form.title == "EDIT DETAILS")
        #expect(form.submitLabel == "Save")
        #expect(form.programID == "maharaja")
        #expect(form.programName == "Maharaja Club")
        #expect(form.kind == "flights")
        #expect(form.field("membership_number")?.value == "739154")
        #expect(form.field("membership_number")?.isRequired == false)
        #expect(form.field("points")?.value == "12000")
        #expect(form.field("tier")?.value == "Gold")
        #expect(form.field("tier_valid_until")?.value == nil)

        let numeric = try JSONDecoder().decode(
            ProfileV3LoyaltyFieldDTO.self,
            from: Data(#"{"key":"points","value":12000}"#.utf8)
        )
        #expect(numeric.value == "12000")
    }

    @Test func theSaveSendsOnlyTheChangedFieldsAndNullClearsOne() throws {
        let edit = ProfileV3ProgrammeEdit(
            programID: "au-small-finance-bank/au-bank-lit-credit-card",
            programName: "AU LIT",
            kind: "credit_cards",
            membershipNumber: .clear,
            points: .set("15000")
        )
        let json = try Self.json(ProfileV3LoyaltyMapper.editProgrammeRequest(edit, profileID: "p1"))
        #expect(json["action"] as? String == "edit_loyalty_program")
        #expect(json["program_id"] as? String == "au-small-finance-bank/au-bank-lit-credit-card")
        #expect(json["profile_id"] as? String == "p1")
        #expect(json["program_name"] as? String == "AU LIT")
        #expect(json["kind"] as? String == "credit_cards")
        #expect(json["membership_number"] is NSNull)
        #expect(json["points"] as? String == "15000")

        let numberOnly = ProfileV3ProgrammeEdit(programID: "maharaja", membershipNumber: .set("739155"))
        let sent = try Self.json(ProfileV3LoyaltyMapper.editProgrammeRequest(numberOnly, profileID: "p1"))
        #expect(sent.keys.sorted() == ["action", "membership_number", "profile_id", "program_id"])
    }

    @Test(.timeLimit(.minutes(1)))
    func editingPrefillsTheFormAndSavesOnlyWhatChanged() async throws {
        let (viewModel, repository, router) = try Self.editing()
        #expect(viewModel.stage == .details)
        #expect(viewModel.detailsName == "Maharaja Club")

        await viewModel.start()
        try await Self.waitUntil { viewModel.entryForm != nil }
        #expect(await repository.loadedIDs == ["Maharaja Club"])
        #expect(await repository.loadedProfileIDs == ["p1"])
        #expect(viewModel.membershipNumber == "739154")
        #expect(viewModel.points == "12000")
        #expect(viewModel.tier == "Gold")
        #expect(viewModel.tierValidUntil.isEmpty)
        #expect(viewModel.entryFields.map(\.key) == ["membership_number", "points", "tier", "tier_valid_until"])
        #expect(viewModel.submitTitle == "Save")
        #expect(!viewModel.canSubmit)

        viewModel.points = "15,000"
        #expect(viewModel.canSubmit)
        viewModel.points = "12000"
        #expect(!viewModel.canSubmit)

        viewModel.points = "15000"
        viewModel.submit()
        try await Self.waitUntil { viewModel.didSave }
        #expect(await repository.edits == [
            ProfileV3ProgrammeEdit(programID: "maharaja", programName: "Maharaja Club", kind: "flights", points: .set("15000"))
        ])
        #expect(await repository.savedProfileIDs == ["p1"])
        #expect(router.saves == 1)
        #expect(router.dismissals == 1)
    }

    @Test(.timeLimit(.minutes(1)))
    func clearingTheMembershipNumberIsAllowedAndSendsNull() async throws {
        let (viewModel, repository, _) = try Self.editing()
        await viewModel.start()
        try await Self.waitUntil { viewModel.entryForm != nil }

        viewModel.membershipNumber = "  "
        #expect(viewModel.canSubmit)
        viewModel.submit()
        try await Self.waitUntil { viewModel.didSave }
        #expect(await repository.edits.first?.membershipNumber == .clear)
        #expect(await repository.edits.first?.points == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func aFailedLoadRetriesAndAFailedSaveKeepsTheSheetOpen() async throws {
        let (viewModel, repository, router) = try Self.editing(failingLoads: 1)
        await viewModel.start()
        try await Self.waitUntil { viewModel.entryFormFailed }
        viewModel.retryEntryForm()
        try await Self.waitUntil { viewModel.entryForm != nil }
        #expect(await repository.loadedIDs.count == 2)

        await repository.failSaves()
        viewModel.points = "1"
        viewModel.submit()
        try await Self.waitUntil { !viewModel.isSaving && viewModel.saveError != nil }
        #expect(viewModel.saveError == ProfileV3Strings.saveFailed)
        #expect(!viewModel.didSave)
        #expect(router.saves == 0)
        #expect(router.dismissals == 0)
    }

    @Test(.timeLimit(.minutes(1)))
    func theEditPillOpensTheFormOnlyInEditMode() async throws {
        let (viewModel, router, _) = try await Self.programmes()
        let programme = try #require(viewModel.editingProgrammes.first)

        viewModel.tapEditProgramme(programme)
        #expect(router.edited.isEmpty)
        viewModel.tapEdit()
        viewModel.tapEditProgramme(programme)
        #expect(router.edited == [programme.id])
    }

    @Test(.timeLimit(.minutes(1)))
    func aReloadDropsTheSelectionOfAProgrammeThatIsGone() async throws {
        let (viewModel, _, session) = try await Self.programmes()
        let programmes = viewModel.editingProgrammes
        try #require(programmes.count >= 2)
        viewModel.tapEdit()
        viewModel.toggleSelection(programmes[0])
        viewModel.toggleSelection(programmes[1])

        let passID = ProfileV3Fixtures.worldPass.id
        session.updateHomes { _, home in home.removingProgramme(id: programmes[0].id, fromPassID: passID) }
        await viewModel.reload()
        #expect(viewModel.selectedIDs == [programmes[1].id])
    }

    @Test func theMockAppliesAnEdit() async throws {
        let repository = ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore())
        let passID = ProfileV3Fixtures.worldPass.id
        let overview = try await repository.loadProgrammes(passID: passID)
        let programme = try #require(overview.programmes.first)

        let form = try await repository.loadProgrammeEdit(programID: programme.id, profileID: passID)
        let allOptional = form.fields.allSatisfy { !$0.isRequired }
        #expect(allOptional)
        try await repository.editProgramme(
            ProfileV3ProgrammeEdit(programID: programme.id, points: .set("4242"), tier: "Gold"),
            profileID: passID
        )
        let reloaded = try await repository.loadProgrammes(passID: passID)
        let edited = reloaded.programmes.first { $0.id == programme.id }
        #expect(edited?.points == 4242)
        #expect(edited?.tier == "GOLD")
    }

    private static let editJSON = #"""
    {"type":"loyalty_enter_details","title":"EDIT DETAILS","program_id":"maharaja","program_name":"Maharaja Club",
     "fields":[
       {"key":"membership_number","label":"MEMBERSHIP NUMBER","required":false,"input":"text","value":"739154"},
       {"key":"points","label":"POINTS / MILES","required":false,"input":"text","value":"12000"},
       {"key":"tier","label":"TIER","required":false,"input":"single_select","value":"Gold",
        "options":[{"value":"Silver","label":"Silver"},{"value":"Gold","label":"Gold"},
                   {"value":"unknown","label":"I don't know"}]},
       {"key":"tier_valid_until","label":"VALID UNTIL","required":false,"input":"month_year",
        "placeholder":"MM/YY","value":""}
     ],
     "submit":{"label":"Save","action":"edit_loyalty_program","program_id":"maharaja",
               "program_name":"Maharaja Club","kind":"flights"}}
    """#

    private static let programme = ProfileV3LoyaltyProgramme(
        id: "Maharaja Club",
        name: "Maharaja Club",
        maskedNumber: "",
        points: 12000,
        logoURL: nil,
        membershipNumber: "739154",
        category: .flights
    )

    private static func editForm() throws -> ProfileV3LoyaltyEntryForm {
        let dto = try JSONDecoder().decode(ProfileV3LoyaltyEnterScreenDTO.self, from: Data(editJSON.utf8))
        return ProfileV3LoyaltyMapper.entryForm(dto, programID: programme.id, programName: nil, kind: nil)
    }

    private static func editing(
        failingLoads: Int = 0
    ) throws -> (ProfileV3AddProgrammeViewModel, EditStub, EditRouterSpy) {
        let repository = EditStub(form: try editForm(), failingLoads: failingLoads)
        let router = EditRouterSpy()
        let viewModel = ProfileV3AddProgrammeViewModel(
            editing: programme,
            profileID: "p1",
            repository: repository,
            onSaved: { router.saves += 1 }
        )
        viewModel.router = router
        return (viewModel, repository, router)
    }

    private static func programmes() async throws -> (ProfileV3ProgrammesViewModel, EditProgrammesRouterSpy, ProfileV3SessionStore) {
        let session = ProfileV3SessionStore()
        let router = EditProgrammesRouterSpy()
        let viewModel = ProfileV3ProgrammesViewModel(
            pass: ProfileV3Fixtures.worldPass,
            passes: [ProfileV3Fixtures.worldPass],
            repository: ProfileV3MockRepository(delay: .zero, session: session),
            hints: ProfileV3HubHints(defaults: UserDefaults(suiteName: "profileV3.edit.\(UUID().uuidString)") ?? .standard)
        )
        viewModel.router = router
        await viewModel.load(reducesMotion: true)
        try #require(viewModel.overview != nil)
        return (viewModel, router, session)
    }

    private static func json(_ request: some Encodable) throws -> [String: Any] {
        let body = try JSONEncoder().encode(request)
        return try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Swift.Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

@MainActor
private final class EditRouterSpy: ProfileV3AddProgrammeRouter {
    var saves = 0
    private(set) var dismissals = 0

    func redirectToKYC() {}
    func dismissAddProgramme() { dismissals += 1 }
}

@MainActor
private final class EditProgrammesRouterSpy: ProfileV3ProgrammesRouter {
    private(set) var edited: [String] = []

    func goBack() {}
    func openInsight(for _: ProfileV3LoyaltyProgramme) {}
    func openAddProgramme() {}
    func openEditProgramme(_ programme: ProfileV3LoyaltyProgramme) { edited.append(programme.id) }
    func openInsightAction(_: ProfileV3Directive) {}
    func programmesChanged() {}
    func passChanged(to _: ProfileV3WorldPass) {}
    func presentDeleteConfirmation() {}
    func dismissDeleteConfirmation() {}
}

private actor EditStub: ProfileV3LoyaltyRepository {
    private let mock = ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore())
    private let form: ProfileV3LoyaltyEntryForm
    private var failingLoads: Int
    private var failsSaves = false
    private(set) var loadedIDs: [String] = []
    private(set) var loadedProfileIDs: [String?] = []
    private(set) var edits: [ProfileV3ProgrammeEdit] = []
    private(set) var savedProfileIDs: [String?] = []

    init(form: ProfileV3LoyaltyEntryForm, failingLoads: Int) {
        self.form = form
        self.failingLoads = failingLoads
    }

    func failSaves() {
        failsSaves = true
    }

    nonisolated func scanProgrammes() -> AsyncThrowingStream<ProfileV3ProgrammeScanEvent, Error> {
        mock.scanProgrammes()
    }

    func loadProgrammeCatalogue(query: String?, kind: String?, market: String?) async throws -> ProfileV3ProgrammePicker {
        try await mock.loadProgrammeCatalogue(query: query, kind: kind, market: market)
    }

    func loadLoyaltyEntry(programID: String, programName: String?, kind: String?) async throws -> ProfileV3LoyaltyEntryForm {
        try await mock.loadLoyaltyEntry(programID: programID, programName: programName, kind: kind)
    }

    func loadProgrammeInsight(programID: String, profileID: String?) async throws -> ProfileV3ProgrammeInsight {
        try await mock.loadProgrammeInsight(programID: programID, profileID: profileID)
    }

    func loadProgrammeSources(programID: String, profileID: String?) async throws -> ProfileV3PreferenceSources {
        try await mock.loadProgrammeSources(programID: programID, profileID: profileID)
    }

    func addProgramme(_: ProfileV3ProgrammeSubmission, profileID _: String?) async throws {}

    func loadProgrammeEdit(programID: String, profileID: String?) async throws -> ProfileV3LoyaltyEntryForm {
        loadedIDs.append(programID)
        loadedProfileIDs.append(profileID)
        if failingLoads > 0 {
            failingLoads -= 1
            throw ProfileV3RepositoryError.unavailable
        }
        return form
    }

    func editProgramme(_ edit: ProfileV3ProgrammeEdit, profileID: String?) async throws {
        if failsSaves { throw ProfileV3Error.server(code: "loyalty_edit_failed", message: nil) }
        edits.append(edit)
        savedProfileIDs.append(profileID)
    }

    func loadProgrammes(passID: String) async throws -> ProfileV3ProgrammeOverview {
        try await mock.loadProgrammes(passID: passID)
    }

    func removeProgramme(id _: String, name _: String, profileID _: String) async throws {}

    func reorderProgrammes(_: [String], profileID _: String, action _: String) async throws {}
}
