import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Citizenship lock")
struct ProfileV3CitizenshipLockTests {
    @Test func theSettingsMenuCarriesTheMainTravellersCitizenship() throws {
        #expect(try Self.menu(#"{"title":"Settings","citizenship_country_code":"in"}"#).citizenshipCode == "IN")
        #expect(try Self.menu(#"{"title":"Settings","citizenship_country_code":null}"#).citizenshipCode == nil)
        #expect(try Self.menu(#"{"title":"Settings"}"#).citizenshipCode == nil)
        let mistyped = try Self.menu(#"{"title":"Settings","citizenship_country_code":7}"#)
        #expect(mistyped.title == "Settings")
        #expect(mistyped.citizenshipCode == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func aCitizenshipFromSettingsLocksTheRow() async throws {
        let viewModel = try await Self.loadedSettings(citizenship: "IN")
        let fields = viewModel.fields
        #expect(fields.isCitizenshipLocked)
        #expect(fields.passportCitizenship?.code == "IN")
        #expect(fields.citizenshipIconCode == "IN")

        fields.open(.citizenship)
        #expect(fields.citizenshipLockTrigger == 1)
        #expect(!viewModel.path.contains(.citizenship))
    }

    @Test(.timeLimit(.minutes(1)))
    func withoutACitizenshipTheEditorOpens() async throws {
        let viewModel = try await Self.loadedSettings(citizenship: nil)
        let fields = viewModel.fields
        #expect(!fields.isCitizenshipLocked)
        #expect(fields.citizenshipIconCode == nil)

        fields.open(.citizenship)
        #expect(fields.citizenshipLockTrigger == 0)
        #expect(viewModel.path.contains(.citizenship))
    }

    @Test func anUnlistedCodeStillLocks() {
        let fields = ProfileV3ProfileFieldsModel(
            deps: .preview(),
            repository: ProfileV3MockRepository(delay: .zero),
            profileID: nil
        )
        fields.applyCitizenship(code: "XQ")
        #expect(fields.isCitizenshipLocked)
        #expect(fields.passportCitizenship?.code == "XQ")
        fields.applyCitizenship(code: nil)
        #expect(!fields.isCitizenshipLocked)
    }

    private static func loadedSettings(citizenship: String?) async throws -> ProfileV3SettingsViewModel {
        let viewModel = ProfileV3SettingsViewModel(
            deps: .preview(),
            repository: ProfileV3MockRepository(delay: .zero, settingsCitizenship: citizenship)
        )
        viewModel.loadMenuIfNeeded()
        for _ in 0 ..< 200 where viewModel.menu == nil {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(viewModel.menu != nil)
        return viewModel
    }

    private static func menu(_ json: String) throws -> ProfileV3SettingsMenu {
        ProfileV3SettingsMapper.menu(try JSONDecoder().decode(ProfileV3SettingsMenuDTO.self, from: Data(json.utf8)))
    }
}
