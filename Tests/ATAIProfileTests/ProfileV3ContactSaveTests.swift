import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Contact save")
struct ProfileV3ContactSaveTests {
    @Test func theHostsSelectedTravellerIsUsedWhenItHasOne() async {
        let id = await ProfileV3SettingsDependencies.travellerID(
            account: ContactAccountHost(travellerID: "host-traveller"),
            board: ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore())
        )
        #expect(id == "host-traveller")
    }

    @Test func aHostWithoutATravellerFallsBackToTheBoardsMainProfile() async throws {
        let board = ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore())
        let main = try #require(try await board.loadBoard().mainProfile?.profileID)

        let id = await ProfileV3SettingsDependencies.travellerID(account: ContactAccountHost(travellerID: nil), board: board)
        #expect(id == main)
    }

    @Test func noTravellerAndNoBoardLeavesTheSaveWithoutATraveller() async {
        let id = await ProfileV3SettingsDependencies.travellerID(account: ContactAccountHost(travellerID: " "), board: nil)
        #expect(id == nil)
    }
}

@MainActor
private final class ContactAccountHost: ProfileV3AccountHost {
    private let travellerID: String?

    init(travellerID: String?) {
        self.travellerID = travellerID
    }

    func snapshot() -> ProfileV3AccountSnapshot {
        ProfileV3AccountSnapshot(
            firstName: nil,
            residenceCode: nil,
            citizenship: nil,
            passportNationality: nil,
            email: "",
            phone: nil,
            storedEmail: nil,
            storedPhone: nil,
            selectedTravellerID: travellerID
        )
    }

    func storedTraveller(id _: String) -> ProfileV3StoredTraveller? { nil }
    func saveResidence(code _: String) -> Bool { true }
    func saveCitizenship(_: ProfileV3Country) -> Bool { true }
    func isContactTaken(email _: String, phone _: String) async -> Bool { false }
    func applySavedContact(email _: String?, phone _: String?) {}
    func travellerProfileDidChange() {}
}
