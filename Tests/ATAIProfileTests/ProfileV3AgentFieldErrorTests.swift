import ATCore
import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Agent text field hints and errors")
struct ProfileV3AgentFieldErrorTests {
    private static let gstMessage = "Enter a valid 15 character GST number."

    @Test func aServedPlaceholderShowsAsSentAndTheLabelStaysTheFallback() throws {
        let (form, residuals) = try Self.personal(gst: "27AAPFU0939F1ZV")
        let placeholders = form.sections.compactMap { section -> String? in
            guard case .text(let field) = section.control else { return nil }
            return field.placeholder
        }
        #expect(placeholders == ["designation", "15 character GST number"])

        let body = try ProfileV3AgentSubmission.body(for: form, profileID: nil, residuals: residuals)
        let values = (try JSONSerialization.jsonObject(with: body) as? [String: Any])?["values"] as? [String: Any]
        #expect(values?["gst_number"] as? String == "27AAPFU0939F1ZV")
        #expect(values?["designation"] as? String == "Founder")
    }

    @Test func a422KeepsTheEnvelopeCode() {
        ProfileV3ServerFailureBox.shared.store(ProfileV3ErrorEnvelope.parse(Data(
            #"{"error":{"code":"invalid_gst_number","message":"Enter a valid 15 character GST number."}}"#.utf8
        )))
        let error = ProfileV3APIErrorMapper.map(
            ATCoreError.server(ATCoreServerError(message: Self.gstMessage, statusCode: 422)),
            action: "save_agent_preferences"
        )
        #expect(error as? ProfileV3Error == .invalidRequest(code: "invalid_gst_number", message: Self.gstMessage))
        #expect(ProfileV3Error.message(for: error) == Self.gstMessage)
    }

    @Test(.timeLimit(.minutes(1)))
    func aRejectedGSTNumberShowsTheMessageUnderItsFieldUntilItIsEdited() async throws {
        let (form, _) = try Self.personal(gst: "")
        let repository = FieldErrorRepositoryStub(
            error: ProfileV3Error.invalidRequest(code: "invalid_gst_number", message: Self.gstMessage)
        )
        let viewModel = ProfileV3AgentFormViewModel(form: form, avatarURL: nil, repository: repository, onFinish: {})

        viewModel.setText("27AAPFU", in: "gst_number")
        viewModel.save()
        try await Self.waitUntil { viewModel.fieldErrors["gst_number"] != nil }
        #expect(viewModel.fieldErrors == ["gst_number": Self.gstMessage])
        #expect(viewModel.saveState == .idle)
        #expect(!viewModel.showsSaveError)
        #expect(viewModel.showsSaveBar)

        viewModel.setText("Founder & CEO", in: "designation")
        #expect(viewModel.fieldErrors == ["gst_number": Self.gstMessage])
        viewModel.setText("27AAPFU0939F1ZV", in: "gst_number")
        #expect(viewModel.fieldErrors.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func anErrorWithoutAFieldStillFailsTheSaveBar() async throws {
        let (form, _) = try Self.personal(gst: "")
        let repository = FieldErrorRepositoryStub(error: ProfileV3Error.invalidRequest(code: "kyc_invalid_request", message: "Nope"))
        let viewModel = ProfileV3AgentFormViewModel(form: form, avatarURL: nil, repository: repository, onFinish: {})

        viewModel.setText("27AAPFU", in: "gst_number")
        viewModel.save()
        try await Self.waitUntil { viewModel.saveState == .failed }
        #expect(viewModel.showsSaveError)
        #expect(viewModel.fieldErrors.isEmpty)
    }

    @Test func onlyAnInvalidCodeForATextFieldBelongsToAField() throws {
        let (form, _) = try Self.personal(gst: "")
        typealias Model = ProfileV3AgentFormViewModel
        let gst = Model.fieldError(
            for: ProfileV3Error.invalidRequest(code: "invalid_gst_number", message: Self.gstMessage),
            in: form
        )
        #expect(gst?.sectionID == "gst_number")
        #expect(gst?.message == Self.gstMessage)

        let misses: [Error] = [
            ProfileV3Error.invalidRequest(code: "invalid_trip_purpose", message: "x"),
            ProfileV3Error.invalidRequest(code: "invalid_pan_number", message: "x"),
            ProfileV3Error.invalidRequest(code: "kyc_invalid_request", message: "x"),
            ProfileV3Error.invalidRequest(code: "invalid_gst_number", message: nil),
            ProfileV3Error.invalidRequest(message: Self.gstMessage),
            ProfileV3Error.server(code: "invalid_gst_number", message: "x")
        ]
        for error in misses {
            let isMiss = Model.fieldError(for: error, in: form) == nil
            #expect(isMiss, "\(error)")
        }
    }

    private static func personal(gst: String) throws -> (form: ProfileV3AgentForm, residuals: ProfileV3AgentResiduals) {
        let json = #"""
        {"agent_type":"personal","fields":[
         {"key":"trip_purpose","label":"TRIP PURPOSE","input":"single_select",
          "options":[{"value":"leisure","label":"Leisure","selected":true},{"value":"business","label":"Business"}]},
         {"key":"designation","label":"DESIGNATION","input":"text","found":true,"value":"Founder"},
         {"key":"gst_number","label":"GST NUMBER","input":"text",
          "assist":"Agent will identify eligible business expenses and apply GST input tax credits wherever applicable.",
          "placeholder":"15 character GST number","found":true,"value":"\#(gst)"}]}
        """#
        let dto = try JSONDecoder().decode(ProfileV3AgentScreenDTO.self, from: Data(json.utf8))
        let mapped = ProfileV3AgentMapper.flow(from: dto)
        guard case .preferences(let form) = mapped.flow else { throw ProfileV3RepositoryError.unavailable }
        return (form, mapped.residuals)
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Swift.Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

private final class FieldErrorRepositoryStub: ProfileV3AgentRepository, @unchecked Sendable {
    private let error: Error

    init(error: Error) {
        self.error = error
    }

    func loadAgentFlow(agentID: String, profileID: String?) async throws -> ProfileV3AgentFlow {
        throw ProfileV3RepositoryError.unavailable
    }

    func saveAgentForm(_ form: ProfileV3AgentForm, profileID: String?, profileIDs: [String]?) async throws -> String? {
        throw error
    }

    func loadPreviousPassports(profileID: String?) async throws -> ProfileV3PreviousPassports {
        throw ProfileV3RepositoryError.unavailable
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
