import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Passport empty state")
struct ProfileV3PassportEmptyStateTests {
    @Test func anAgentWithoutAPassportShowsTheServedPlaceholder() throws {
        let form = try Self.form(#"""
        {"type":"agent","id":"agent_personal","agent_type":"personal","title":"PERSONAL AGENT",
         "fields":[{"key":"preferred_name","label":"PREFERRED NAME","input":"text","value":"Test"}],
         "passport_empty":{"title":"Upload passport",
                           "body":"Your details are ready whenever you need a visa. No forms, no retyping.",
                           "cta_label":"Upload"}}
        """#, accountCountry: .india, holderName: "mohak n.")

        let section = try #require(form.sections.first)
        #expect(section.id == ProfileV3PassportMapper.sectionID)
        #expect(section.title == ProfileV3Strings.passportDetails)
        #expect(section.status == .pending)
        guard case .passport(let field) = section.control else {
            Issue.record("Expected the passport card first")
            return
        }
        #expect(field.passport == nil)
        #expect(field.rescan == nil)
        #expect(field.previous == nil)
        #expect(field.emptyState == ProfileV3PassportEmptyState(
            title: "Upload passport",
            body: "Your details are ready whenever you need a visa. No forms, no retyping.",
            ctaLabel: "Upload"
        ))
        #expect(field.holderName == "mohak n.")
        #expect(field.countryName == ProfileV3Strings.passportCountryIndia)
        #expect(field.countryNativeName == ProfileV3Strings.passportCountryIndiaNative)
        #expect(form.sections.map(\.id) == ["passport", "preferred_name"])
    }

    @Test func aPassportOnFileWinsAndWithNeitherThereIsNoCard() throws {
        let both = try Self.form(#"""
        {"agent_type":"personal","passport":{"name":"mohak n.","number":"64FGGSB05","status":"active"},
         "passport_empty":{"title":"Upload passport","body":"Body","cta_label":"Upload"}}
        """#)
        guard case .passport(let field) = both.sections.first?.control else {
            Issue.record("Expected the passport card")
            return
        }
        #expect(field.passport?.number == "64FGGSB05")
        #expect(field.emptyState == nil)

        let neither = try Self.form(#"{"agent_type":"personal","fields":[]}"#)
        #expect(neither.sections.isEmpty)

        let unreadable = try Self.form(#"{"agent_type":"personal","passport_empty":"Upload passport"}"#)
        #expect(unreadable.sections.isEmpty)
    }

    @Test func missingCopyStaysEmptyAndUnknownTravellersShowNoNameOrCountry() throws {
        let form = try Self.form(#"""
        {"agent_type":"personal","passport_empty":{"title":"  ","body":null}}
        """#)
        guard case .passport(let field) = form.sections.first?.control else {
            Issue.record("Expected the passport card")
            return
        }
        #expect(field.emptyState == ProfileV3PassportEmptyState(title: "", body: "", ctaLabel: ""))
        #expect(field.holderName.isEmpty)
        #expect(field.countryName.isEmpty)
        #expect(field.countryNativeName == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func uploadingAFirstPassportScansForThisTravellerAndSkipsTheReasonStep() async throws {
        let repository = PassportUploadStub()
        var scans: [ProfileV3PassportScanRequest] = []
        let viewModel = ProfileV3AgentFormViewModel(
            form: Self.emptyForm,
            avatarURL: nil,
            profileID: "p2",
            repository: repository,
            presentPassportScan: { scans.append($0) },
            onFinish: {}
        )

        viewModel.startPassportUpdate()
        try await Self.waitUntil { !scans.isEmpty }
        let scan = try #require(scans.first)
        let result = try await scan.upload(.front, Data([0x01]))
        scan.onFinish(result.field, true)

        #expect(repository.scanProfileIDs == ["p2"])
        #expect(repository.uploadProfileIDs == ["p2"])
        #expect(viewModel.passportReason == nil)
        try await Self.waitUntil { repository.reloads == 1 }
        #expect(viewModel.passportField?.passport == ProfileV3PassportFixtures.active)
    }

    @Test(.timeLimit(.minutes(1)))
    func replacingAPassportStillScansForItsCardsTravellerAndAsksWhy() async throws {
        let repository = PassportUploadStub()
        var scans: [ProfileV3PassportScanRequest] = []
        var form = Self.emptyForm
        form.sections[0].control = .passport(ProfileV3PassportFixtures.field)
        let viewModel = ProfileV3AgentFormViewModel(
            form: form,
            avatarURL: nil,
            profileID: "p2",
            repository: repository,
            presentPassportScan: { scans.append($0) },
            onFinish: {}
        )

        viewModel.startPassportUpdate()
        try await Self.waitUntil { !scans.isEmpty }
        scans[0].onFinish(nil, true)

        #expect(repository.scanProfileIDs == [nil])
        #expect(viewModel.passportReason != nil)
        #expect(repository.reloads == 0)
    }

    private static var emptyForm: ProfileV3AgentForm {
        var form = ProfileV3AgentFixtures.personal
        form.sections = [ProfileV3FormSection(
            id: ProfileV3PassportMapper.sectionID,
            title: ProfileV3Strings.passportDetails,
            status: .pending,
            control: .passport(ProfileV3PassportFixtures.emptyField)
        )]
        return form
    }

    private static func form(
        _ json: String,
        accountCountry: ProfileV3Country? = nil,
        holderName: String? = nil
    ) throws -> ProfileV3AgentForm {
        let dto = try JSONDecoder().decode(ProfileV3AgentScreenDTO.self, from: Data(json.utf8))
        let flow = ProfileV3AgentMapper.flow(from: dto, accountCountry: accountCountry, holderName: holderName).flow
        guard case .preferences(let form) = flow else { throw ProfileV3RepositoryError.unavailable }
        return form
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

private final class PassportUploadStub: ProfileV3AgentRepository, @unchecked Sendable {
    private let lock = NSLock()
    private var _scanProfileIDs: [String?] = []
    private var _uploadProfileIDs: [String?] = []
    private var _reloads = 0

    var scanProfileIDs: [String?] { lock.withLock { _scanProfileIDs } }
    var uploadProfileIDs: [String?] { lock.withLock { _uploadProfileIDs } }
    var reloads: Int { lock.withLock { _reloads } }

    func loadAgentFlow(agentID: String, profileID: String?) async throws -> ProfileV3AgentFlow {
        lock.withLock { _reloads += 1 }
        throw ProfileV3RepositoryError.unavailable
    }

    func saveAgentForm(_ form: ProfileV3AgentForm, profileID: String?, profileIDs: [String]?) async throws -> String? {
        nil
    }

    func loadPreviousPassports(profileID: String?) async throws -> ProfileV3PreviousPassports {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPassportScan(profileID: String?) async throws -> ProfileV3PassportScan {
        lock.withLock { _scanProfileIDs.append(profileID) }
        return ProfileV3PassportFixtures.scan
    }

    func uploadPassportScan(_ side: ProfileV3PassportSide, data: Data, profileID: String?) async throws
        -> ProfileV3PassportScanResult {
        lock.withLock { _uploadProfileIDs.append(profileID) }
        return ProfileV3PassportScanResult(field: ProfileV3PassportFixtures.field, backRequired: false)
    }

    func loadPassportReason() async throws -> ProfileV3PassportReasonScreen { .fallback }

    func loadPassportHowUsed() async throws -> ProfileV3PassportHowUsed {
        throw ProfileV3RepositoryError.unavailable
    }

    func updatePassport(reason: String, profileID: String?) async throws {}

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
