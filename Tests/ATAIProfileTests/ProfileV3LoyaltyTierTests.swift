import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Loyalty tier")
struct ProfileV3LoyaltyTierTests {
    @Test func theFormCarriesTheTierOptionsAndTheMonthPlaceholder() throws {
        let form = try Self.form(edit: false)
        let tier = try #require(form.field("tier"))
        #expect(tier.options.map(\.value) == ["Silver", "Gold", "unknown"])
        #expect(tier.options.map(\.label) == ["Silver", "Gold", "I don't know"])
        #expect(form.field("tier_valid_until")?.placeholder == "MM/YY")
    }

    @Test func theMonthFormatsAsItIsTypedAndMustNotBePast() throws {
        #expect(ProfileV3MonthYear.formatted("1") == "1")
        #expect(ProfileV3MonthYear.formatted("12") == "12")
        #expect(ProfileV3MonthYear.formatted("122") == "12/2")
        #expect(ProfileV3MonthYear.formatted("12/278") == "12/27")
        #expect(ProfileV3MonthYear.formatted("a1b2") == "12")

        let now = try #require(ISO8601DateFormatter().date(from: "2026-11-15T10:00:00Z"))
        #expect(ProfileV3MonthYear.isCurrentOrLater("11/26", now: now))
        #expect(ProfileV3MonthYear.isCurrentOrLater("01/27", now: now))
        #expect(!ProfileV3MonthYear.isCurrentOrLater("10/26", now: now))
        #expect(!ProfileV3MonthYear.isCurrentOrLater("13/27", now: now))
        #expect(!ProfileV3MonthYear.isCurrentOrLater("00/27", now: now))
        #expect(!ProfileV3MonthYear.isCurrentOrLater("12/2", now: now))
    }

    @Test(.timeLimit(.minutes(1)))
    func addingSendsThePickedTierAndMonth() async throws {
        let (viewModel, repository) = try await Self.adding()
        #expect(viewModel.entryFields.map(\.key) == ["membership_number", "points", "tier", "tier_valid_until"])
        viewModel.membershipNumber = "739154"
        viewModel.tier = "Gold"
        let month = try Self.month(offsetBy: 12)
        viewModel.tierValidUntil = month.replacingOccurrences(of: "/", with: "") + "9"
        #expect(viewModel.canSubmit)

        viewModel.submit()
        try await Self.waitUntil { viewModel.didSave }
        let submission = try #require(await repository.submissions.first)
        #expect(submission.tier == "Gold")
        #expect(submission.tierValidUntil == month)
        let json = try Self.json(ProfileV3LoyaltyMapper.addProgrammeRequest(submission, profileID: "p1"))
        #expect(json["tier"] as? String == "Gold")
        #expect(json["tier_valid_until"] as? String == month)
    }

    @Test(.timeLimit(.minutes(1)))
    func aMonthGoesOnlyWithAPickedTier() async throws {
        let (viewModel, repository) = try await Self.adding()
        viewModel.membershipNumber = "739154"
        viewModel.tierValidUntil = try Self.month(offsetBy: 3)
        viewModel.submit()
        try await Self.waitUntil { !viewModel.isSaving }

        viewModel.tier = "unknown"
        viewModel.submit()
        try await Self.waitUntil { await repository.submissions.count == 2 }
        let submissions = await repository.submissions
        #expect(submissions[0].tier == nil)
        #expect(submissions[0].tierValidUntil == nil)
        #expect(submissions[1].tier == "unknown")
        #expect(submissions[1].tierValidUntil == nil)
        let json = try Self.json(ProfileV3LoyaltyMapper.addProgrammeRequest(submissions[0], profileID: "p1"))
        #expect(json["tier"] == nil)
        #expect(json["tier_valid_until"] == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func aBadOrPastMonthBlocksSavingOnlyWhenItWouldBeSent() async throws {
        let (viewModel, _) = try await Self.adding()
        viewModel.membershipNumber = "739154"
        viewModel.tier = "Gold"
        viewModel.tierValidUntil = "13/40"
        #expect(viewModel.tierValidUntilError == ProfileV3Strings.tierValidUntilInvalid)
        #expect(!viewModel.canSubmit)
        viewModel.tierValidUntil = try Self.month(offsetBy: -1)
        #expect(viewModel.tierValidUntilError == ProfileV3Strings.tierValidUntilInvalid)
        #expect(!viewModel.canSubmit)
        viewModel.tierValidUntil = "12/2"
        #expect(viewModel.tierValidUntilError == nil)
        #expect(!viewModel.canSubmit)
        viewModel.tierValidUntil = try Self.month(offsetBy: 0)
        #expect(viewModel.tierValidUntilError == nil)
        #expect(viewModel.canSubmit)

        viewModel.tierValidUntil = try Self.month(offsetBy: -1)
        viewModel.tier = "unknown"
        #expect(viewModel.tierValidUntilError == nil)
        #expect(viewModel.canSubmit)
    }

    @Test(.timeLimit(.minutes(1)))
    func aNewTierKeepsTheSavedMonthAndANewMonthResendsTheTier() async throws {
        let saved = try Self.month(offsetBy: 6)
        let (changingTier, first) = try await Self.editing(tier: "Gold", validUntil: saved)
        #expect(changingTier.tier == "Gold")
        #expect(changingTier.tierValidUntil == saved)
        #expect(!changingTier.canSubmit)
        changingTier.tier = "Silver"
        changingTier.submit()
        try await Self.waitUntil { changingTier.didSave }
        let tierEdit = try #require(await first.edits.first)
        #expect(tierEdit.tier == "Silver")
        #expect(tierEdit.tierValidUntil == saved)
        #expect(tierEdit.membershipNumber == nil)
        #expect(tierEdit.points == nil)

        let later = try Self.month(offsetBy: 9)
        let (changingMonth, second) = try await Self.editing(tier: "Gold", validUntil: saved)
        changingMonth.tierValidUntil = later
        changingMonth.submit()
        try await Self.waitUntil { changingMonth.didSave }
        let monthEdit = try #require(await second.edits.first)
        #expect(monthEdit.tier == "Gold")
        #expect(monthEdit.tierValidUntil == later)
        let json = try Self.json(ProfileV3LoyaltyMapper.editProgrammeRequest(monthEdit, profileID: "p1"))
        #expect(json["tier"] as? String == "Gold")
        #expect(json["tier_valid_until"] as? String == later)
        #expect(json["points"] == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func iDontKnowClearsTheTierAndAPastSavedMonthMattersOnlyWhenTheTierIsSent() async throws {
        let (clearing, first) = try await Self.editing(tier: "Gold", validUntil: try Self.month(offsetBy: 6))
        clearing.tier = "unknown"
        clearing.submit()
        try await Self.waitUntil { clearing.didSave }
        let cleared = try #require(await first.edits.first)
        #expect(cleared.tier == "unknown")
        #expect(cleared.tierValidUntil == nil)

        let (expired, second) = try await Self.editing(tier: "Gold", validUntil: try Self.month(offsetBy: -2))
        expired.points = "500"
        #expect(expired.tierValidUntilError == nil)
        #expect(expired.canSubmit)
        expired.tier = "Silver"
        #expect(expired.tierValidUntilError == ProfileV3Strings.tierValidUntilInvalid)
        #expect(!expired.canSubmit)
        expired.tierValidUntil = ""
        #expect(expired.canSubmit)
        expired.submit()
        try await Self.waitUntil { expired.didSave }
        let fixed = try #require(await second.edits.first)
        #expect(fixed.tier == "Silver")
        #expect(fixed.tierValidUntil == nil)
        #expect(fixed.points == .set("500"))
    }

    @Test(.timeLimit(.minutes(1)))
    func aTierWithoutOptionsIsLeftOutWithItsMonth() async throws {
        var form = try Self.form(edit: true)
        form.fields = form.fields.map { field in
            guard field.key == "tier" else { return field }
            return ProfileV3LoyaltyEntryForm.Field(key: field.key, label: field.label, isRequired: false)
        }
        let viewModel = ProfileV3AddProgrammeViewModel(editing: Self.programme, profileID: "p1", repository: TierStub(form: form))
        await viewModel.start()
        try await Self.waitUntil { viewModel.entryForm != nil }
        #expect(viewModel.entryFields.map(\.key) == ["membership_number", "points"])
    }

    private static let programme = ProfileV3LoyaltyProgramme(
        id: "maharaja",
        name: "Maharaja Club",
        maskedNumber: "",
        points: 0,
        logoURL: nil,
        category: .flights
    )

    private static func form(edit: Bool, tier: String? = nil, validUntil: String? = nil) throws -> ProfileV3LoyaltyEntryForm {
        var tierField: [String: Any] = [
            "key": "tier", "label": "TIER", "required": false, "input": "single_select",
            "options": [
                ["value": "Silver", "label": "Silver"],
                ["value": "Gold", "label": "Gold"],
                ["value": "Gold", "label": "Gold again"],
                ["value": "unknown", "label": "I don't know"]
            ]
        ]
        var monthField: [String: Any] = [
            "key": "tier_valid_until", "label": "TIER VALID UNTIL", "required": false,
            "input": "month_year", "placeholder": "MM/YY"
        ]
        if let tier { tierField["value"] = tier }
        if let validUntil { monthField["value"] = validUntil }
        let fields: [[String: Any]] = [
            ["key": "membership_number", "label": "MEMBERSHIP NUMBER", "required": !edit, "input": "text"],
            ["key": "points", "label": "POINTS/MILES", "required": false, "input": "text"],
            tierField,
            monthField
        ]
        let screen: [String: Any] = [
            "type": "loyalty_enter_details",
            "title": edit ? "EDIT DETAILS" : "ENTER DETAILS",
            "program_id": "maharaja",
            "program_name": "Maharaja Club",
            "fields": fields,
            "submit": [
                "label": edit ? "Save" : "Continue",
                "action": edit ? "edit_loyalty_program" : "add_loyalty_program",
                "program_id": "maharaja",
                "kind": "flights"
            ]
        ]
        let dto = try JSONDecoder().decode(
            ProfileV3LoyaltyEnterScreenDTO.self,
            from: JSONSerialization.data(withJSONObject: screen)
        )
        return ProfileV3LoyaltyMapper.entryForm(dto, programID: "maharaja", programName: nil, kind: nil)
    }

    private static func adding() async throws -> (ProfileV3AddProgrammeViewModel, TierStub) {
        let repository = TierStub(form: try form(edit: false))
        let viewModel = ProfileV3AddProgrammeViewModel(requiresKYC: false, profileID: "p1", repository: repository)
        await viewModel.start()
        try await waitUntil { !viewModel.isLoadingCatalogue }
        viewModel.continueFromPick()
        try await waitUntil { viewModel.entryForm != nil }
        return (viewModel, repository)
    }

    private static func editing(tier: String, validUntil: String) async throws -> (ProfileV3AddProgrammeViewModel, TierStub) {
        let repository = TierStub(form: try form(edit: true, tier: tier, validUntil: validUntil))
        let viewModel = ProfileV3AddProgrammeViewModel(editing: programme, profileID: "p1", repository: repository)
        await viewModel.start()
        try await waitUntil { viewModel.entryForm != nil }
        return (viewModel, repository)
    }

    private static func month(offsetBy months: Int) throws -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let date = try #require(calendar.date(byAdding: .month, value: months, to: Date()))
        let parts = calendar.dateComponents([.year, .month], from: date)
        let month = try #require(parts.month)
        let year = try #require(parts.year)
        return String(format: "%02d/%02d", month, year % 100)
    }

    private static func json(_ request: some Encodable) throws -> [String: Any] {
        let body = try JSONEncoder().encode(request)
        return try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
    }

    private static func waitUntil(_ condition: () async -> Bool) async throws {
        for _ in 0 ..< 400 where !(await condition()) {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(await condition())
    }
}

private actor TierStub: ProfileV3LoyaltyRepository {
    private let mock = ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore())
    private let form: ProfileV3LoyaltyEntryForm
    private(set) var submissions: [ProfileV3ProgrammeSubmission] = []
    private(set) var edits: [ProfileV3ProgrammeEdit] = []

    init(form: ProfileV3LoyaltyEntryForm) {
        self.form = form
    }

    nonisolated func scanProgrammes() -> AsyncThrowingStream<ProfileV3ProgrammeScanEvent, Error> {
        mock.scanProgrammes()
    }

    func loadProgrammeCatalogue(query: String?, kind: String?, market: String?) async throws -> ProfileV3ProgrammePicker {
        try await mock.loadProgrammeCatalogue(query: query, kind: kind, market: market)
    }

    func loadLoyaltyEntry(programID _: String, programName _: String?, kind _: String?) async throws -> ProfileV3LoyaltyEntryForm {
        form
    }

    func loadProgrammeInsight(programID: String, profileID: String?) async throws -> ProfileV3ProgrammeInsight {
        try await mock.loadProgrammeInsight(programID: programID, profileID: profileID)
    }

    func loadProgrammeSources(programID: String, profileID: String?) async throws -> ProfileV3PreferenceSources {
        try await mock.loadProgrammeSources(programID: programID, profileID: profileID)
    }

    func addProgramme(_ submission: ProfileV3ProgrammeSubmission, profileID _: String?) async throws {
        submissions.append(submission)
    }

    func loadProgrammeEdit(programID _: String, profileID _: String?) async throws -> ProfileV3LoyaltyEntryForm {
        form
    }

    func editProgramme(_ edit: ProfileV3ProgrammeEdit, profileID _: String?) async throws {
        edits.append(edit)
    }

    func loadProgrammes(passID: String) async throws -> ProfileV3ProgrammeOverview {
        try await mock.loadProgrammes(passID: passID)
    }

    func removeProgramme(id _: String, name _: String, profileID _: String) async throws {}

    func reorderProgrammes(_: [String], profileID _: String, action _: String) async throws {}
}
