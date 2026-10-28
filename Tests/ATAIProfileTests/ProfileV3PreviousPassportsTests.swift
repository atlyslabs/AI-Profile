import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Previous passports")
struct ProfileV3PreviousPassportsTests {
    @Test func theCardOffersPreviousPassportsOnlyWhenServed() throws {
        let served = try Self.passport(#"""
        {"name":"mohak n.","title":"भारत गणराज्य  REPUBLIC OF INDIA","number":"64FGGSB05",
         "issue_date":"2026-01-01","expiry_date":"2036-01-01","status":"active",
         "previous":{"label":"VIEW PREVIOUS","title":"PREVIOUS PASSPORTS",
                     "next":{"go":"passport_previous","profile_id":"p2"}}}
        """#)
        let previous = try #require(ProfileV3PassportMapper.field(served, accountCountry: nil).previous)
        #expect(previous.label == "VIEW PREVIOUS")
        #expect(previous.title == "PREVIOUS PASSPORTS")
        #expect(previous.next.route() == .passportPrevious(profileID: "p2"))

        let main = try Self.passport(#"{"previous":{"label":"VIEW PREVIOUS","next":{"go":"passport_previous"}}}"#)
        #expect(ProfileV3PassportMapper.field(main, accountCountry: nil).previous?.next.route() == .passportPrevious(profileID: nil))

        for json in [
            #"{"number":"64FGGSB05"}"#,
            #"{"previous":{"next":{"go":"passport_previous"}}}"#,
            #"{"previous":{"label":"VIEW PREVIOUS"}}"#,
            #"{"previous":{"label":"VIEW PREVIOUS","next":{"go":"passport_update"}}}"#,
            #"{"previous":"VIEW PREVIOUS"}"#
        ] {
            #expect(ProfileV3PassportMapper.field(try Self.passport(json), accountCountry: nil).previous == nil)
        }
    }

    @Test func previousPassportsKeepTheServerOrderLabelsAndEachRowsOwnDetails() throws {
        let screen = ProfileV3PassportMapper.previousPassports(try Self.screen(#"""
        {"type":"passport_previous","title":"PREVIOUS PASSPORTS",
         "labels":{"number":"PASSPORT NUMBER","issue_date":"ISSUE DATE","expiry_date":"EXPIRY DATE"},
         "passports":[
           {"title":"भारत गणराज्य  REPUBLIC OF INDIA","name":"mohak n.","number":"Z1234567",
            "issue_date":"2024-03-01","expiry_date":"2034-02-28","status":"active"},
           {"title":"भारत गणराज्य  REPUBLIC OF INDIA","name":"mohak nair","number":"K7654321",
            "issue_date":"2014-03-01","expiry_date":"2024-02-28","status":"expired"},
           {"number":"X0000001","status":"expired"}
         ]}
        """#), accountCountry: nil)

        #expect(screen.title == "PREVIOUS PASSPORTS")
        #expect(screen.labels == ProfileV3PassportLabels(
            number: "PASSPORT NUMBER",
            issueDate: "ISSUE DATE",
            expiryDate: "EXPIRY DATE"
        ))
        #expect(screen.passports.map(\.number) == ["Z1234567", "K7654321", "X0000001"])
        #expect(screen.passports.map(\.status) == [.active, .expired, .expired])
        #expect(Set(screen.passports.map(\.id)).count == 3)
        let current = try #require(screen.passports.first)
        #expect(current.holderName == "mohak n.")
        #expect(current.countryName == "REPUBLIC OF INDIA")
        #expect(current.countryNativeName == "भारत गणराज्य")
        #expect(current.issuedOn == "01/03/2024")
        #expect(current.expiresOn == "28/02/2034")
        #expect(screen.passports[1].holderName == "mohak nair")
        let bare = screen.passports[2]
        #expect(bare.holderName.isEmpty)
        #expect(bare.countryName.isEmpty)
        #expect(bare.issuedOn.isEmpty)

        let empty = ProfileV3PassportMapper.previousPassports(try Self.screen(#"{"passports":[]}"#), accountCountry: nil)
        #expect(empty.passports.isEmpty)
        #expect(empty.labels == ProfileV3PassportLabels(number: "", issueDate: "", expiryDate: ""))
    }

    @Test func aRowWithoutAPrintedTitleTakesANonIndianAccountCountry() throws {
        let dto = try Self.screen(#"{"passports":[{"number":"1","status":"active"}]}"#)
        let american = ProfileV3PassportMapper.previousPassports(
            dto,
            accountCountry: ProfileV3Country(code: "US", name: "United States")
        )
        #expect(american.passports.first?.countryName == "UNITED STATES")
        let indian = ProfileV3PassportMapper.previousPassports(dto, accountCountry: .india)
        #expect(indian.passports.first?.countryName == "")
        #expect(indian.passports.first?.countryNativeName == nil)
    }

    @Test func theEndpointNamesTheTravellerOnlyWhenTheDirectiveDoes() {
        #expect(ProfileV3API.passportPrevious(profileID: nil).path == "/api/gmail-connector/kyc/v2/board/passport/previous")
        guard case .requestPlain = ProfileV3API.passportPrevious(profileID: nil).task else {
            Issue.record("Expected no query for the account main")
            return
        }
        guard case .requestParameters(let parameters, _) = ProfileV3API.passportPrevious(profileID: "p2").task else {
            Issue.record("Expected a profile_id query")
            return
        }
        #expect(parameters["profile_id"] as? String == "p2")
    }

    @Test(.timeLimit(.minutes(1)))
    func viewPreviousLoadsThePassportsOfTheServedTraveller() async throws {
        let repository = PreviousPassportsStub()
        let viewModel = ProfileV3AgentFormViewModel(
            form: Self.form(previous: ProfileV3PassportPrevious(
                label: "VIEW PREVIOUS",
                title: "PREVIOUS PASSPORTS",
                next: ProfileV3Directive(go: "passport_previous", profileID: "p2")
            )),
            avatarURL: nil,
            profileID: "p2",
            repository: repository,
            onFinish: {}
        )

        viewModel.tapViewPreviousPassports()
        #expect(viewModel.showsPreviousPassports)
        #expect(viewModel.previousPassportsPhase == .loading)
        #expect(viewModel.previousPassportsTitle == "PREVIOUS PASSPORTS")
        try await waitUntil { viewModel.previousPassportsPhase == .loaded }

        #expect(repository.requestedProfileIDs == ["p2"])
        #expect(viewModel.previousPassports?.passports.count == 2)
        #expect(viewModel.previousPassportsTitle == "Older passports")
    }

    @Test func withoutAServedEntryViewPreviousDoesNothing() {
        let repository = PreviousPassportsStub()
        let viewModel = ProfileV3AgentFormViewModel(
            form: Self.form(previous: nil),
            avatarURL: nil,
            repository: repository,
            onFinish: {}
        )
        viewModel.tapViewPreviousPassports()
        #expect(!viewModel.showsPreviousPassports)
        #expect(repository.requestedProfileIDs.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func replacingThePassportReloadsTheFormSoViewPreviousAppears() async throws {
        let repository = PreviousPassportsStub(refreshed: Self.form(previous: ProfileV3PassportFixtures.previousEntry))
        var scans: [ProfileV3PassportScanRequest] = []
        let viewModel = ProfileV3AgentFormViewModel(
            form: Self.form(previous: nil),
            avatarURL: nil,
            repository: repository,
            presentPassportScan: { scans.append($0) },
            onFinish: {}
        )
        #expect(viewModel.passportField?.previous == nil)

        viewModel.startPassportUpdate()
        try await waitUntil { !scans.isEmpty }
        scans[0].onFinish(nil, true)
        let reason = try #require(viewModel.passportReason)
        reason.selection = ProfileV3PassportChangeReason.lost.rawValue
        reason.submit()
        try await waitUntil { viewModel.passportField?.previous != nil }

        #expect(repository.reasons == ["lost"])
        #expect(viewModel.passportReason == nil)
        #expect(viewModel.passportField?.previous == ProfileV3PassportFixtures.previousEntry)
    }

    private static func form(previous: ProfileV3PassportPrevious?) -> ProfileV3AgentForm {
        var form = ProfileV3AgentFixtures.personal
        form.sections = [ProfileV3FormSection(
            id: "passport",
            title: "PASSPORT DETAILS",
            status: .complete,
            control: .passport(ProfileV3PassportField(
                holderName: "mohak n.",
                countryName: "REPUBLIC OF INDIA",
                passport: ProfileV3PassportFixtures.active,
                previous: previous,
                rescan: ProfileV3PassportFixtures.rescan
            ))
        )]
        return form
    }

    private static func passport(_ json: String) throws -> ProfileV3AgentPassportDTO {
        try JSONDecoder().decode(ProfileV3AgentPassportDTO.self, from: Data(json.utf8))
    }

    private static func screen(_ json: String) throws -> ProfileV3PreviousPassportsScreenDTO {
        try JSONDecoder().decode(ProfileV3PreviousPassportsScreenDTO.self, from: Data(json.utf8))
    }

    private func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

private final class PreviousPassportsStub: ProfileV3AgentRepository, @unchecked Sendable {
    private let lock = NSLock()
    private let refreshed: ProfileV3AgentForm?
    private var _requestedProfileIDs: [String?] = []
    private var _reasons: [String] = []

    init(refreshed: ProfileV3AgentForm? = nil) {
        self.refreshed = refreshed
    }

    var requestedProfileIDs: [String?] { lock.withLock { _requestedProfileIDs } }
    var reasons: [String] { lock.withLock { _reasons } }

    func loadAgentFlow(agentID: String, profileID: String?) async throws -> ProfileV3AgentFlow {
        guard let refreshed else { throw ProfileV3RepositoryError.unavailable }
        return .preferences(refreshed)
    }

    func saveAgentForm(_ form: ProfileV3AgentForm, profileID: String?, profileIDs: [String]?) async throws -> String? {
        nil
    }

    func loadPreviousPassports(profileID: String?) async throws -> ProfileV3PreviousPassports {
        lock.withLock { _requestedProfileIDs.append(profileID) }
        return ProfileV3PreviousPassports(
            title: "Older passports",
            labels: ProfileV3PassportLabels(number: "NUMBER", issueDate: "ISSUED", expiryDate: "EXPIRES"),
            passports: Array(ProfileV3PassportFixtures.history.prefix(2))
        )
    }

    func loadPassportScan(profileID: String?) async throws -> ProfileV3PassportScan { .fallback }

    func uploadPassportScan(_ side: ProfileV3PassportSide, data: Data, profileID: String?) async throws
        -> ProfileV3PassportScanResult {
        ProfileV3PassportScanResult(field: nil, backRequired: nil)
    }

    func loadPassportReason() async throws -> ProfileV3PassportReasonScreen { .fallback }

    func loadPassportHowUsed() async throws -> ProfileV3PassportHowUsed {
        throw ProfileV3RepositoryError.unavailable
    }

    func updatePassport(reason: String, profileID: String?) async throws {
        lock.withLock { _reasons.append(reason) }
    }

    func loadPreferenceSources(_ source: ProfileV3SectionSource, profileID: String?) async throws
        -> ProfileV3PreferenceSources {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadRidePicker(agentType: String, profileID: String?) async throws -> ProfileV3RidePicker {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadRideRegions() async throws -> ProfileV3RideRegions {
        throw ProfileV3RepositoryError.unavailable
    }
}
