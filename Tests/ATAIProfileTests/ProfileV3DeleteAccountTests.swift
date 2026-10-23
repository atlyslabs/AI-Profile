import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Delete account")
struct ProfileV3DeleteAccountTests {
    @Test func theReasonScreenComesFromTheServer() throws {
        let dto = try JSONDecoder().decode(ProfileV3DeleteAccountReasonDTO.self, from: Data(#"""
        {"type":"delete_account_reason","title":"Tell us why you want to delete your ayl account",
         "subtitle":"It helps us improve.",
         "field":{"key":"reason","input":"long_text","placeholder":"Enter your reason here"},
         "submit":{"label":"Delete account","style":"danger","next":{"go":"delete_confirm"}}}
        """#.utf8))
        let screen = ProfileV3SettingsMapper.deleteAccountReason(dto)
        #expect(screen == ProfileV3DeleteAccountReason(
            title: "Tell us why you want to delete your ayl account",
            subtitle: "It helps us improve.",
            placeholder: "Enter your reason here",
            submitLabel: "Delete account"
        ))
        #expect(dto.submit?.next?.directive.route() == .deleteAccountConfirm)
    }

    @Test func theConfirmScreenComesFromTheServer() throws {
        let dto = try JSONDecoder().decode(ProfileV3DeleteAccountConfirmDTO.self, from: Data(#"""
        {"type":"delete_account_confirm","title":"Are you sure you want to delete your ayl account?",
         "warning":"This removes your data.",
         "actions":[{"key":"cancel","label":"Don't delete","next":{"go":"back"}},
                    {"key":"proceed","label":"Proceed to delete","style":"danger","action":"delete_account"}]}
        """#.utf8))
        #expect(ProfileV3SettingsMapper.deleteAccountConfirm(dto) == ProfileV3DeleteAccountConfirm(
            title: "Are you sure you want to delete your ayl account?",
            warning: "This removes your data.",
            proceedLabel: "Proceed to delete",
            cancelLabel: "Don't delete"
        ))
    }

    @Test func deleteAccountAndDeleteConfirmAreSeparateRoutes() {
        #expect(ProfileV3Directive(go: "delete_account").route() == .deleteAccount)
        #expect(ProfileV3Directive(go: "delete_confirm").route() == .deleteAccountConfirm)
    }

    @Test(.timeLimit(.minutes(1)))
    func proceedRunsTheNativeDeletionWithTheReason() async throws {
        let record = DeletionRecord()
        let model = ProfileV3AccountSettingsModel(
            deps: Self.deps(record),
            repository: ProfileV3MockRepository(delay: .zero)
        )
        let navigator = PathNavigator()
        model.navigator = navigator

        model.tapDeleteAccount()
        #expect(navigator.path == [.deleteAccount])
        try await Self.waitUntil { model.deleteReason != nil && model.deleteConfirm != nil }

        model.submitDeletionReason("Too many emails")
        #expect(navigator.path == [.deleteAccount, .deleteAccountConfirm])
        #expect(record.reasons.isEmpty)

        model.confirmDeletion()
        try await Self.waitUntil { model.isAccountDeletionRequested }
        #expect(record.reasons == ["Too many emails"])
        #expect(record.marked)
    }

    private static func deps(_ record: DeletionRecord) -> ProfileV3SettingsDependencies {
        ProfileV3SettingsDependencies(
            currentFirstName: { nil },
            currentResidence: { .india },
            currentCitizenship: { .india },
            currentCurrencyCountry: { .india },
            currentContact: { ProfileV3Fixtures.contactDetails },
            saveResidence: { _ in true },
            pushResidenceToServer: { _ in },
            saveCitizenship: { _ in true },
            saveCurrencyCountry: { _ in },
            saveContact: { _ in .success },
            logAccountDeletionReason: { record.reasons.append($0) },
            accountDeletionRequested: { false },
            markAccountDeletionRequested: { record.marked = true },
            storedTraveller: { _ in nil }
        )
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 400 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

@MainActor
private final class DeletionRecord {
    var reasons: [String] = []
    var marked = false
}

@MainActor
private final class PathNavigator: ProfileV3SettingsNavigating {
    var path: [ProfileV3SettingsDestination] = []
}
