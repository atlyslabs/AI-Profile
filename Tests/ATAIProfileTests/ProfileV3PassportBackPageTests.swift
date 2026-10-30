import Foundation
import SwiftUI
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
@Suite("Passport back page", .serialized)
struct ProfileV3PassportBackPageTests {
    @Test func theCardCarriesItsBackPageDetailsAndTheirLabels() throws {
        let field = try Self.field(#"""
        {"agent_type":"personal","passport":{
          "name":"CHOTA BACHA","number":"F9090906","status":"active","title":"भारत गणराज्य   REPUBLIC OF INDIA",
          "issue_date":"May 15, 2024","expiry_date":"May 14, 2034","verified":true,
          "father":" Vindo Sharma ","mother":"Vindo Sharma",
          "address":["Village- Betalon, Post-Mangalpur","  ","District-Bankpura,PS-INDUS","Wet Bengal, PIN-722305","Extra line"],
          "labels":{"number":"PASSPORT NUMBER","issue_date":"ISSUE DATE","expiry_date":"EXPIRY DATE",
                    "father":"FATHER","mother":"MOTHER","spouse":"SPOUSE","address":"ADDRESS"},
          "rescan":{"profile_id":"8372cf0a","go":"passport_update"}}}
        """#)
        let passport = try #require(field.passport)
        #expect(field.labels == ProfileV3PassportFixtures.labels)
        #expect(passport.back == ProfileV3PassportBack(
            father: "Vindo Sharma",
            mother: "Vindo Sharma",
            address: ["Village- Betalon, Post-Mangalpur", "District-Bankpura,PS-INDUS", "Wet Bengal, PIN-722305"]
        ))
        #expect(passport.back.rows(labels: field.labels) == [
            ProfileV3PassportBackRow(id: "father", label: "FATHER", lines: ["Vindo Sharma"]),
            ProfileV3PassportBackRow(id: "mother", label: "MOTHER", lines: ["Vindo Sharma"]),
            ProfileV3PassportBackRow(id: "spouse", label: "SPOUSE", lines: [""]),
            ProfileV3PassportBackRow(
                id: "address",
                label: "ADDRESS",
                lines: ["Village- Betalon, Post-Mangalpur", "District-Bankpura,PS-INDUS", "Wet Bengal, PIN-722305"]
            )
        ])
    }

    @Test func withoutBackDetailsThereIsNoBackPageAndTheFrontKeepsItsClientLabels() throws {
        let bare = try Self.field(#"{"agent_type":"personal","passport":{"number":"F9090906","father":"  ","address":[]}}"#)
        #expect(bare.passport?.back.isEmpty == true)
        #expect(bare.labels == .card)
        #expect(bare.passport?.back.rows(labels: bare.labels).isEmpty == true)

        let oneLine = try Self.field(#"""
        {"agent_type":"personal","passport":{"number":"F9090906","spouse":"Priya","address":"Flat 2\nPune 411001",
         "labels":{"number":"PASSPORT NO.","spouse":"SPOUSE","address":"ADDRESS"}}}
        """#)
        #expect(oneLine.passport?.back == ProfileV3PassportBack(spouse: "Priya", address: ["Flat 2", "Pune 411001"]))
        #expect(oneLine.labels.number == "PASSPORT NO.")
        #expect(oneLine.labels.issueDate == ProfileV3Strings.passportIssueDate)
        #expect(oneLine.passport?.back.rows(labels: oneLine.labels).map(\.id) == ["spouse", "address"])
    }

    @Test func eachPreviousPassportCarriesItsOwnBackPage() throws {
        let dto = try JSONDecoder().decode(ProfileV3PreviousPassportsScreenDTO.self, from: Data(#"""
        {"type":"passport_previous","title":"PREVIOUS PASSPORTS",
         "labels":{"number":"PASSPORT NUMBER","issue_date":"ISSUE DATE","expiry_date":"EXPIRY DATE",
                   "father":"FATHER","mother":"MOTHER","spouse":"SPOUSE","address":"ADDRESS"},
         "passports":[
          {"number":"F9090906","status":"active","father":"Vindo Sharma","address":["Wet Bengal, PIN-722305"]},
          {"number":"A1234567","status":"expired"}
         ]}
        """#.utf8))
        let screen = ProfileV3PassportMapper.previousPassports(dto, accountCountry: nil)
        #expect(screen.labels == ProfileV3PassportFixtures.labels)
        #expect(screen.passports.map(\.back) == [
            ProfileV3PassportBack(father: "Vindo Sharma", address: ["Wet Bengal, PIN-722305"]),
            ProfileV3PassportBack()
        ])
    }

    @Test(arguments: [(width: CGFloat(440), card: CGFloat(380)), (width: 393, card: 333)])
    func frontAndBackSitSideBySideAndScrollSideways(width: CGFloat, card: CGFloat) async throws {
        let margin = ProfileV3Theme.Sizes.screenHorizontalMargin
        let host = UIHostingController(rootView:
            ProfileV3PassportPagesRow {
                Color.gray.frame(height: ProfileV3Theme.Sizes.Passport.cardHeight)
            } back: {
                Color.gray.frame(height: ProfileV3Theme.Sizes.Passport.cardHeight)
            }
            .padding(.horizontal, margin)
        )
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: 600))
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        try await Self.waitUntil { Self.scrollViews(in: host.view).contains { $0.contentSize.width > 0 } }
        let row = try #require(Self.scrollViews(in: host.view).first)
        #expect(row.bounds.width == width)
        let spacing = ProfileV3Theme.Sizes.Passport.pageSpacing
        let inset = row.adjustedContentInset
        let scrollable = row.contentSize.width + inset.left + inset.right
        #expect(abs(scrollable - (2 * card + spacing + 2 * margin)) < 1, "\(row.contentSize) \(inset)")
    }

    @Test(.timeLimit(.minutes(1)))
    func theBackPageShowsOnlyWhenThePassportHasOne() async throws {
        #expect(ProfileV3FeatureFlags.isPassportBackPageEnabled)
        var withoutBack = ProfileV3PassportFixtures.field
        withoutBack.passport?.back = ProfileV3PassportBack()
        let cases: [(field: ProfileV3PassportField, showsBackPage: Bool, scrolls: Bool)] = [
            (ProfileV3PassportFixtures.field, true, true),
            (withoutBack, true, false),
            (ProfileV3PassportFixtures.field, false, false),
            (ProfileV3PassportFixtures.emptyField, true, false)
        ]
        for entry in cases {
            let section = ProfileV3FormSection(
                id: "passport", title: "PASSPORT DETAILS", status: .complete, control: .passport(entry.field)
            )
            var view = ProfileV3FormSectionView(
                section: section,
                onToggleOption: { _ in }, onSliderChange: { _ in }, onOptOut: { _ in }, onTextChange: { _ in }
            )
            view.showsPassportBackPage = entry.showsBackPage
            let host = UIHostingController(rootView: view.padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin))
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
            window.rootViewController = host
            window.makeKeyAndVisible()
            defer { window.isHidden = true }

            try await Task.sleep(for: .milliseconds(300))
            host.view.layoutIfNeeded()
            #expect(!Self.scrollViews(in: host.view).isEmpty == entry.scrolls, "\(entry.showsBackPage) \(entry.scrolls)")
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func aScanThatSendsNoLabelsKeepsTheBackLabelsAndDropsTheOldBackPage() async throws {
        var scanned = ProfileV3PassportFixtures.field
        scanned.labels = .card
        scanned.passport?.back = ProfileV3PassportBack()
        let repository = ScanStub(result: scanned)
        var form = ProfileV3AgentFixtures.personal
        form.sections = [ProfileV3FormSection(
            id: ProfileV3PassportMapper.sectionID,
            title: ProfileV3Strings.passportDetails,
            status: .complete,
            control: .passport(ProfileV3PassportFixtures.field)
        )]
        var scans: [ProfileV3PassportScanRequest] = []
        let viewModel = ProfileV3AgentFormViewModel(
            form: form,
            avatarURL: nil,
            repository: repository,
            presentPassportScan: { scans.append($0) },
            onFinish: {}
        )

        viewModel.startPassportUpdate()
        try await Self.waitUntil { !scans.isEmpty }
        let result = try await scans[0].upload(.front, Data([0x01]))
        scans[0].onFinish(result.field, false)

        #expect(viewModel.passportField?.labels == ProfileV3PassportFixtures.labels)
        #expect(viewModel.passportField?.passport?.back.isEmpty == true)
    }

    private static func field(_ json: String) throws -> ProfileV3PassportField {
        let dto = try JSONDecoder().decode(ProfileV3AgentScreenDTO.self, from: Data(json.utf8))
        guard case .preferences(let form) = ProfileV3AgentMapper.flow(from: dto).flow,
              case .passport(let field)? = form.sections.first?.control else {
            throw ProfileV3RepositoryError.unavailable
        }
        return field
    }

    private static func scrollViews(in view: UIView) -> [UIScrollView] {
        var found: [UIScrollView] = []
        if let scrollView = view as? UIScrollView { found.append(scrollView) }
        for subview in view.subviews { found += scrollViews(in: subview) }
        return found
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 100 where !condition() {
            try await Task.sleep(for: .milliseconds(50))
        }
        #expect(condition())
    }
}

private final class ScanStub: ProfileV3AgentRepository, @unchecked Sendable {
    private let result: ProfileV3PassportField

    init(result: ProfileV3PassportField) {
        self.result = result
    }

    func loadAgentFlow(agentID: String, profileID: String?) async throws -> ProfileV3AgentFlow {
        throw ProfileV3RepositoryError.unavailable
    }

    func saveAgentForm(_ form: ProfileV3AgentForm, profileID: String?, profileIDs: [String]?) async throws -> String? {
        nil
    }

    func loadPreviousPassports(profileID: String?) async throws -> ProfileV3PreviousPassports {
        throw ProfileV3RepositoryError.unavailable
    }

    func loadPassportScan(profileID: String?) async throws -> ProfileV3PassportScan { ProfileV3PassportFixtures.scan }

    func uploadPassportScan(_ side: ProfileV3PassportSide, data: Data, profileID: String?) async throws
        -> ProfileV3PassportScanResult {
        ProfileV3PassportScanResult(field: result, backRequired: false)
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
