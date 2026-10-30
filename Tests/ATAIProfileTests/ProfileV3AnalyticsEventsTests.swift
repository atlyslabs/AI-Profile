import Foundation
import SwiftUI
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
struct ProfileV3AnalyticsEventsTests {
    @Test func agentNamesFollowTheSpec() {
        #expect(ProfileV3Analytics.agentName("flight") == "flight_agent")
        #expect(ProfileV3Analytics.agentName("stay") == "stay_agent")
        #expect(ProfileV3Analytics.agentName("airport-logistics") == "airport_logistics_agent")
        #expect(ProfileV3Analytics.agentName("airport_logistics") == "airport_logistics_agent")
        #expect(ProfileV3Analytics.agentName("personal") == "personal_info_agent")
        #expect(ProfileV3Analytics.agentName("travel_persona") == "travel_person_agent")
        #expect(ProfileV3Analytics.agentName("concierge") == "concierge_agent")
    }

    @Test func benefitScreensAreNamedFromTheBenefitID() {
        let names = [
            "slot_priority": "aiSlotPriorityBenefit",
            "slot-calendar": "aiProfileBenefit",
            "fast_track_immigration": "aiFTIBenefit",
            "airport_hotline": "aiAirportHotlineBenefit",
            "zero_forex": "aiForexBenefit",
            "transfers-discount": "aiTransfersBenefit",
            "esim": "aiEsimBenefit",
            "activities": "aiActivityBenefit",
            "ayl_cash": "aiAylCashBenefit",
            "super_car": "aiSuperCarBenefit",
            "hotel_credit": "aiHotelCreditBenefit",
            "hotels-cashback": "aiHotelBenefit",
            "flight_delay_200": "aiInsuranceBenefit",
            "baggage_protection_500": "aiInsuranceBenefit",
            "flight_credit_50": "aiFlightBenefit",
            "gift_card_200": "aiProfileBenefit",
            "visas_approved_minutes": "aiProfileBenefit"
        ]
        for (id, name) in names {
            #expect(ProfileV3Analytics.benefitScreenName(id) == name, "\(id)")
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func hubEventsCarryTheTravellerTheyAreAbout() async throws {
        let recorder = AnalyticsRecorder()
        try await ProfileV3Analytics.$scopedReporter.withValue(recorder) {
            let viewModel = ProfileV3HubViewModel(repository: ProfileV3MockRepository(delay: .zero))
            await viewModel.loadIfNeeded()
            let passes = try #require(viewModel.home?.worldPasses)
            try #require(passes.count > 1)
            let traveller = passes[1]

            viewModel.selectPass(id: traveller.id)
            viewModel.tapWorldPass(traveller, showingBenefits: false)
            viewModel.tapWorldPass(traveller, showingBenefits: true)
            viewModel.tapAddProgramme()
            let agents = try #require(viewModel.home?.agents)
            let agent = try #require(agents.last)
            viewModel.tapAgent(agent)
            viewModel.tapViewAllBenefits()
            while recorder.named("profile_benefits_screen_viewed").isEmpty {
                try await Task.sleep(for: .milliseconds(10))
            }

            let switched = try #require(recorder.named("profile_pass_switched").first)
            #expect(switched.string("travellerId") == traveller.id)
            #expect(switched.string("direction") == "next")
            #expect(switched.parameters["passId"] == nil)

            let taps = recorder.named("profile_worldpass_tapped")
            #expect(taps.map { $0.string("tapOn") } == ["profile", "benefits"])
            #expect(taps.first?.string("travellerName") == traveller.holderName)

            let connect = try #require(recorder.named("profile_card_connect_clicked").first)
            #expect(connect.string("actionSource") == "card")
            #expect(connect.string("travellerId") == traveller.id)

            let clicked = try #require(recorder.named("profile_agent_clicked").first)
            #expect(clicked.string("travellerId") == traveller.id)
            #expect(clicked.parameters["agentIndex"] as? Int == agents.count - 1)
            #expect(clicked.string("agentName") == ProfileV3Analytics.agentName(agent.id))

            #expect(recorder.named("profile_view_benefits_clicked").first?.string("travellerId") == traveller.id)
            let screen = try #require(recorder.named("profile_benefits_screen_viewed").first)
            #expect(screen.parameters["benefitList"] as? [String] == viewModel.allBenefits.map(\.title))
            #expect(recorder.names.allSatisfy { !$0.hasSuffix("_viewed") || $0 == "profile_benefits_screen_viewed" })
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func theLoyaltyPickerReportsEachNewQuarterOnceAndTheDetailsEntered() async throws {
        let recorder = AnalyticsRecorder()
        try await ProfileV3Analytics.$scopedReporter.withValue(recorder) {
            let viewModel = ProfileV3AddProgrammeViewModel(
                requiresKYC: false,
                profileID: "main",
                repository: ProfileV3MockRepository(delay: .zero)
            )
            await viewModel.start()
            try await Self.waitForCatalogue(viewModel)
            let items = viewModel.filteredCatalogue
            try #require(items.count >= 8)
            viewModel.selectItem(items[1].id)
            #expect(recorder.named("profile_connector_program_card_scrolled").map { $0.string("slideDepthPercentage") } == ["25"])
            for item in items.dropFirst() { viewModel.selectItem(item.id) }
            for item in items.reversed() { viewModel.selectItem(item.id) }

            let scrolls = recorder.named("profile_connector_program_card_scrolled")
            #expect(scrolls.map { $0.string("slideDepthPercentage") } == ["25", "50", "75", "100"])
            #expect(scrolls.allSatisfy { $0.string("connectorType") == "all" && $0.string("travellerId") == "main" })

            let cards = try #require(viewModel.filters.first { $0.category == .creditCards })
            viewModel.selectFilter(cards)
            #expect(recorder.named("profile_connector_card_type_selected").last?.string("connectorType") == "cards")
            try await Self.waitForCatalogue(viewModel)
            let card = try #require(viewModel.selectedItem)
            viewModel.continueFromPick()
            #expect(recorder.named("profile_loyalty_card_clicked").last?.string("cardName") == card.name)
            #expect(recorder.named("profile_loyalty_card_clicked").last?.string("connectorType") == "cards")
            #expect(recorder.named("profile_connector_card_detail_screen_viewed").last?.string("connectorType") == "cards")

            while viewModel.entryForm == nil { try await Task.sleep(for: .milliseconds(10)) }
            viewModel.points = "1,200"
            viewModel.submit()
            let entered = try #require(recorder.named("profile_connector_card_details_entered").last)
            let details = try #require(entered.parameters["loyaltyDetails"] as? [String: Any])
            #expect(details["points"] as? Int == 1200)
            #expect(details["membership_number"] == nil)
            while viewModel.isSaving { try await Task.sleep(for: .milliseconds(10)) }
            #expect(viewModel.didAdd)
            #expect(recorder.named("profile_programme_selected").isEmpty)
            #expect(recorder.named("profile_programme_added").isEmpty)
            viewModel.close()
        }
    }

    @Test func connectedProgrammesKeepTheirCategory() throws {
        let row = try JSONDecoder().decode(
            ProfileV3ProgrammeRowDTO.self,
            from: Data(#"{"id":"ihg","name":"IHG One Rewards","kind":"hotels","points":1200}"#.utf8)
        )
        let programme = ProfileV3LoyaltyMapper.programme(row)
        #expect(programme.category == .hotels)
        #expect(ProfileV3Analytics.connectorType(.creditCards) == "cards")
        #expect(ProfileV3Analytics.connectorType(.travelPasses) == "travel_passes")
    }

    @Test(.timeLimit(.minutes(1)))
    func theProgrammesPageReportsCardActions() async throws {
        let recorder = AnalyticsRecorder()
        try await ProfileV3Analytics.$scopedReporter.withValue(recorder) {
            let pass = ProfileV3Fixtures.worldPass
            let viewModel = ProfileV3ProgrammesViewModel(
                pass: pass,
                passes: [pass],
                repository: ProfileV3MockRepository(delay: .zero),
                hints: Self.freshHints()
            )
            await viewModel.load(reducesMotion: true)
            let programme = try #require(viewModel.overview?.programmes.first { $0.insight != nil })

            viewModel.tapConnectMore()
            viewModel.tapEdit()
            viewModel.copiedNumber(of: programme)
            viewModel.tapInsight(programme)
            viewModel.toggleSelection(programme)
            viewModel.tapDeleteSelected()
            viewModel.confirmDelete()

            let cardEvents = recorder.names.filter { $0.hasPrefix("profile_connector_") || $0 == "profile_card_connect_clicked" }
            #expect(cardEvents == [
                "profile_card_connect_clicked",
                "profile_connector_card_edit_clicked",
                "profile_connector_card_number_copied",
                "profile_connector_card_view_insight_clicked",
                "profile_connector_card_insight_viewed",
                "profile_connector_card_remove_clicked"
            ])
            #expect(recorder.named("profile_card_connect_clicked").first?.string("actionSource") == "connect_more")
            let insight = try #require(recorder.named("profile_connector_card_insight_viewed").first)
            #expect(insight.string("cardName") == programme.name)
            #expect(insight.string("insightShown")?.isEmpty == false)
            #expect(recorder.named("profile_programme_viewed").isEmpty)
            #expect(recorder.named("profile_programme_edit_toggled").isEmpty)
        }
    }

    @Test func settingsRowsReportTheirOwnEvents() {
        let recorder = AnalyticsRecorder()
        ProfileV3Analytics.$scopedReporter.withValue(recorder) {
            let viewModel = ProfileV3SettingsViewModel(
                deps: .preview(),
                repository: ProfileV3MockRepository(delay: .zero),
                profileID: "main"
            )
            viewModel.isAccountExpanded = true
            viewModel.isAccountExpanded = false
            for field in ["residence", "citizenship", "currency", "contact"] {
                viewModel.tap(Self.row(ProfileV3Directive(go: "edit_field", field: field)))
            }
            for go in ["permissions", "coupons", "terms", "logout"] {
                viewModel.tap(Self.row(ProfileV3Directive(go: go)))
            }
            viewModel.tapInformationAccess()
            viewModel.tapAppAccess()
            viewModel.tapBack()
        }

        #expect(recorder.names.filter { $0 != "profile_cta_clicked" } == [
            "settings_account_center_tapped",
            "settings_account_center_tapped",
            "settings_residence_clicked",
            "settings_citizenship_clicked",
            "settings_currency_clicked",
            "settings_contact_info_clicked",
            "settings_permission_clicked",
            "screen_view",
            "settings_coupons_clicked",
            "settings_terms_clicked",
            "settings_logout_clicked",
            "settings_connector_clicked",
            "screen_view",
            "settings_connector_clicked",
            "settings_back_clicked"
        ])
        #expect(recorder.named("settings_account_center_tapped").map { $0.string("actionType") } == ["open", "close"])
        #expect(recorder.named("settings_connector_clicked").map { $0.string("connectorName") } == ["information", "app"])
        let connectors = recorder.named("screen_view").first { $0.string("screenName") == "aiProfileConnectors" }
        #expect(connectors?.string("travellerId") == "main")
        #expect(recorder.named("profile_settings_row_clicked").isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func theCredentialStoreReportsEachStepOfAddingALogin() async throws {
        let recorder = AnalyticsRecorder()
        try await ProfileV3Analytics.$scopedReporter.withValue(recorder) {
            let settings = ProfileV3SettingsViewModel(
                deps: .preview(),
                repository: ProfileV3MockRepository(delay: .zero),
                profileID: "main"
            )
            settings.tapCredentialStore()
            settings.credentialStore.cancelReads()

            let repository = ProfileV3MockRepository(delay: .zero)
            let store = ProfileV3CredentialStoreModel(repository: repository, unlock: { .unlocked })
            store.tapAdd()
            while store.sites == nil { try await Task.sleep(for: .milliseconds(10)) }
            let site = try #require(store.sites?.first)
            store.pick(site)
            let editor = try #require(store.editor)
            #expect(editor.openWebsite() != nil)
            editor.credentials.username = "ada@example.com"
            editor.credentials.password = "secret"
            editor.submit()
            while editor.phase != .saved { try await Task.sleep(for: .milliseconds(10)) }
            store.pickOtherWebsite(" www.Example.org/login ")

            let saved = ProfileV3VaultFixtures.entries[0].credential
            #expect(ProfileV3AppCredentialsViewModel(mode: .vaultEdit(saved), origin: .page, repository: repository).openWebsite() != nil)
            let app = ProfileV3AppCredentialsViewModel(mode: .newPassword, origin: .page, repository: repository)
            app.credentials.website = "abc.com"
            #expect(app.openWebsite() != nil)
        }

        let vault = recorder.events.filter { $0.name.hasPrefix("pass_vault_") }
        #expect(vault.map(\.name) == [
            "pass_vault_clicked",
            "pass_vault_add_credentials_clicked",
            "pass_vault_website_selected",
            "pass_vault_website_clicked",
            "pass_vault_credentials_added",
            "pass_vault_website_selected",
            "pass_vault_website_clicked"
        ])
        #expect(vault[0].string("actionSource") == "settings")
        for event in vault[2...4] {
            #expect(event.string("website") == "singaporeair.com")
            #expect(event.string("cardName") == "Singapore Airlines KrisFlyer")
        }
        #expect(vault[4].string("emailAdded") == "ada@example.com")
        #expect(vault[5].string("website") == "example.org")
        #expect(vault[5].string("cardName") == "other_website")
        #expect(vault[6].string("website") == "hdfcbank.in")
        #expect(vault[6].string("cardName") == "myhdfcbank.com")
    }

    @Test func theGloveBoxReportsOpeningAndEachItemTouched() {
        let recorder = AnalyticsRecorder()
        ProfileV3Analytics.$scopedReporter.withValue(recorder) {
            let settings = ProfileV3SettingsViewModel(
                deps: .preview(),
                repository: ProfileV3MockRepository(delay: .zero),
                profileID: "main"
            )
            settings.tapGloveBox()

            let issued = Self.gloveBox(ProfileV3GloveBoxFixtures.home)
            issued.openList(.emails)
            issued.open(.call(ProfileV3GloveBoxFixtures.calls[0]))
            issued.showCardNotice()

            let pending = Self.gloveBox(ProfileV3GloveBoxMapper.home(email: ProfileV3GloveBoxFixtures.email))
            pending.open(.email(ProfileV3GloveBoxFixtures.emails[0]))
            pending.copy(.number)
            pending.open(.call(ProfileV3GloveBoxFixtures.calls[0]))
            pending.tapAddCard()
        }

        #expect(recorder.named("glove_box_opened").count == 1)
        let items = recorder.named("glove_box_item_clicked").map { event in
            "\(event.string("itemType") ?? "")=\(event.parameters["activated"] as? Bool == true)"
        }
        #expect(items == ["mail=true", "phone=true", "card=true", "mail=true", "phone=false", "card=false"])
    }

    @Test(.timeLimit(.minutes(1)))
    func settingsUpdatesSendTheOldAndNewValues() async throws {
        let recorder = AnalyticsRecorder()
        try await ProfileV3Analytics.$scopedReporter.withValue(recorder) {
            let repository = ProfileV3MockRepository(delay: .zero)
            let fields = ProfileV3ProfileFieldsModel(deps: .preview(), repository: repository, profileID: "main")
            fields.selectResidence(ProfileV3Country(code: "AE", name: "United Arab Emirates"))
            var contact = ProfileV3Fixtures.contactDetails
            contact.email = "grace@example.com"
            _ = await fields.saveContact(contact)

            let permissions = ProfileV3PermissionsSettingsModel(repository: repository)
            permissions.load()
            while permissions.permissions == nil { try await Task.sleep(for: .milliseconds(10)) }
            permissions.select("on", in: "email")
            permissions.select("when_needed", in: "email_cc")

            while recorder.named("settings_residence_updated").isEmpty
                || recorder.named("settings_permission_changed").count < 2 {
                try await Task.sleep(for: .milliseconds(10))
            }

            let residence = try #require(recorder.named("settings_residence_updated").first)
            #expect(residence.string("newResidence") == "AE")
            #expect(residence.string("oldResidence") == "IN")

            let updated = try #require(recorder.named("settings_contact_info_updated").first)
            #expect((updated.parameters["newContactInfo"] as? [String: String])?["email"] == "grace@example.com")
            #expect((updated.parameters["oldContactInfo"] as? [String: String])?["email"] == "ada@example.com")
            #expect((updated.parameters["newContactInfo"] as? [String: String])?["phone"] == "+919000000002")

            let changes = recorder.named("settings_permission_changed").map { event in
                "\(event.string("oldPermission") ?? "")>\(event.string("newPermission") ?? "")"
            }
            #expect(Set(changes) == ["ask>on", "always>when_needed"])
            #expect(Set(recorder.named("settings_permission_changed").compactMap { $0.string("source") }) == ["action"])
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func agentEditsReportTheirSectionAndASaveReportsEachTraveller() async throws {
        let recorder = AnalyticsRecorder()
        try await ProfileV3Analytics.$scopedReporter.withValue(recorder) {
            var form = ProfileV3AgentFixtures.medical
            form.household = ProfileV3HouseholdPrompt(
                eyebrow: "",
                iconURL: nil,
                title: "Apply to",
                travellers: [
                    ProfileV3HouseholdPrompt.Traveller(id: "main", name: "Me", passNumber: "", isSelected: true),
                    ProfileV3HouseholdPrompt.Traveller(id: "co", name: "Sam", passNumber: "", isSelected: true)
                ],
                confirmLabel: "Apply"
            )
            let viewModel = ProfileV3AgentFormViewModel(
                form: form,
                avatarURL: nil,
                profileID: "main",
                repository: ProfileV3MockRepository(delay: .zero),
                onFinish: {}
            )
            guard case .chips(let blood) = form.sections.first(where: { $0.id == "blood-type" })?.control else {
                Issue.record("expected the blood type chips")
                return
            }
            let oldBlood = try #require(blood.selection.first)
            let newBlood = try #require(blood.allOptions.first { !blood.selection.contains($0.id) })

            viewModel.toggleOption(newBlood.id, in: "blood-type")
            viewModel.setText("+91 9000000009", in: "emergency-contact")
            viewModel.setText("+91 9000000099", in: "emergency-contact")
            viewModel.commitText(in: "emergency-contact")
            viewModel.commitText(in: "emergency-contact")

            let changes = recorder.named("profile_agent_preference_changed")
            #expect(changes.map { $0.string("sectionName") } == ["blood-type", "emergency-contact"])
            #expect(changes.first?.string("changedValue") == newBlood.id)
            #expect(changes.last?.string("changedValue") == "+91 9000000099")
            #expect(changes.allSatisfy { $0.string("agentName") == "medical_agent" && $0.string("travellerId") == "main" })

            viewModel.save()
            viewModel.confirmHousehold()
            while viewModel.saveState == .saving { await Task.yield() }
            #expect(viewModel.saveState == .saved)
            viewModel.cancelPendingWork()

            let saves = recorder.named("profile_agent_form_saved")
            #expect(saves.map { $0.string("travellerId") } == ["main", "co"])
            let changed = try #require(saves.first?.parameters["changedSections"] as? [String: Any])
            let old = try #require(saves.first?.parameters["oldSections"] as? [String: Any])
            #expect(Set(changed.keys) == ["blood-type", "emergency-contact"])
            #expect(changed["blood-type"] as? String == newBlood.id)
            #expect(old["blood-type"] as? String == oldBlood)
            #expect(old["emergency-contact"] as? String == "+91 9000000002")
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func aFailedAgentSaveNamesTheAgentAndTraveller() async {
        let recorder = AnalyticsRecorder()
        await ProfileV3Analytics.$scopedReporter.withValue(recorder) {
            let viewModel = ProfileV3AgentFormViewModel(
                form: ProfileV3AgentFixtures.flight,
                avatarURL: nil,
                profileID: "co",
                repository: ProfileV3FailingRepository(),
                onFinish: {}
            )
            viewModel.save()
            while viewModel.saveState == .saving { await Task.yield() }
        }
        let failure = recorder.named("profile_agent_form_save_failed").first
        #expect(failure?.string("travellerId") == "co")
        #expect(failure?.string("agentName") == "flight_agent")
        #expect(recorder.named("profile_agent_form_saved").isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func travellerEventsCarryTheirDetails() async throws {
        let recorder = AnalyticsRecorder()
        try await ProfileV3Analytics.$scopedReporter.withValue(recorder) {
            let travellers = ProfileV3TravellersSettingsModel(
                deps: .preview(),
                repository: ProfileV3MockRepository(delay: .zero),
                currentContact: { ProfileV3Fixtures.contactDetails }
            )
            travellers.load()
            while travellers.rows.isEmpty { try await Task.sleep(for: .milliseconds(10)) }
            let row = try #require(travellers.rows.first { !$0.isMain } ?? travellers.rows.first)
            travellers.select(row)
            travellers.editingTraveller.firstName = "Renamed"
            travellers.confirmEdit()
            while recorder.named("settings_traveller_saved").isEmpty && recorder.named("settings_traveller_save_failed").isEmpty {
                try await Task.sleep(for: .milliseconds(10))
            }
        }
        #expect(recorder.named("settings_traveller_clicked").count == 1)
        #expect(recorder.named("profile_traveller_clicked").isEmpty)
        let saved = try #require(recorder.named("settings_traveller_saved").first)
        let old = try #require(saved.parameters["oldDetails"] as? [String: String])
        let new = try #require(saved.parameters["newDetails"] as? [String: String])
        #expect(new["name"]?.hasPrefix("Renamed") == true)
        #expect(old["name"] != new["name"])
    }

    @Test(.timeLimit(.minutes(1)))
    func kycUploadsReachTheHostOncePerPhoto() async throws {
        let host = RecordingKYCHost()
        let capture = ProfileV3KYCCapture(profileID: "co", route: .coTraveller, steps: ["passport", "selfie"])
        let viewModel = ProfileV3KYCCaptureViewModel(
            capture: capture,
            repository: ProfileV3MockRepository(delay: .zero),
            kyc: host,
            isCoTraveller: true,
            onFinish: { _ in }
        )
        try await viewModel.uploadPassport(.passportFront, data: Data(), residenceCountryCode: nil)
        try await viewModel.uploadPassport(.passportBack, data: Data(), residenceCountryCode: nil)
        #expect(await viewModel.uploadSelfie(Data()) == nil)

        #expect(host.uploads == [.passportFront, .passportBack, .selfie].map { photo in
            ProfileV3KYC.PhotoUpload(
                photo: photo,
                travellerID: "co",
                isCoTraveller: true,
                flow: .capture,
                actionSource: "profile"
            )
        })
    }

    @Test(.timeLimit(.minutes(1)))
    func aPassportRescanReportsEachUploadedSide() async throws {
        var reported: [ProfileV3PassportSide] = []
        var request: ProfileV3PassportScanRequest?
        let viewModel = ProfileV3AgentFormViewModel(
            form: ProfileV3AgentFixtures.personal,
            avatarURL: nil,
            profileID: "main",
            repository: ProfileV3MockRepository(delay: .zero),
            presentPassportScan: { request = $0 },
            onPassportUploaded: { side, _ in reported.append(side) },
            onFinish: {}
        )
        viewModel.startPassportUpdate()
        while request == nil { try await Task.sleep(for: .milliseconds(10)) }
        let scan = try #require(request)
        _ = try await scan.upload(.front, Data())
        #expect(reported == [.front])
    }

    private static func row(_ directive: ProfileV3Directive) -> ProfileV3SettingsRowItem {
        ProfileV3SettingsRowItem(key: directive.field ?? directive.go, label: directive.go, directive: directive)
    }

    private static func waitForCatalogue(_ viewModel: ProfileV3AddProgrammeViewModel) async throws {
        while viewModel.isLoadingCatalogue || viewModel.filteredCatalogue.isEmpty {
            try await Task.sleep(for: .milliseconds(10))
        }
    }

    private static func gloveBox(_ home: ProfileV3GloveBoxHome) -> ProfileV3GloveBoxViewModel {
        ProfileV3GloveBoxViewModel(gloveBox: ProfileV3GloveBox(title: "", stage: .home(home)))
    }

    private static func freshHints() -> ProfileV3HubHints {
        ProfileV3HubHints(defaults: UserDefaults(suiteName: "profileV3.hints.\(UUID().uuidString)") ?? .standard)
    }
}

private final class AnalyticsRecorder: ProfileV3AnalyticsReporting, @unchecked Sendable {
    struct Event {
        let name: String
        let parameters: [String: Any]

        func string(_ key: String) -> String? { parameters[key] as? String }
    }

    private let lock = NSLock()
    private var recorded: [Event] = []

    var events: [Event] { lock.withLock { recorded } }
    var names: [String] { events.map(\.name) }

    func named(_ name: String) -> [Event] { events.filter { $0.name == name } }

    func logEvent(_ name: String, asScreenView: Bool, parameters: [String: Any]) {
        lock.withLock { recorded.append(Event(name: name, parameters: parameters)) }
    }
}

@MainActor
private final class RecordingKYCHost: ProfileV3KYCHost {
    private(set) var uploads: [ProfileV3KYC.PhotoUpload] = []

    func startOnboarding(
        on navigationController: UINavigationController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) {}

    func presentMinimalCapture(
        from presenter: UIViewController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) {}

    func gmailConnectView(
        _ screen: ProfileV3KYC.GmailConnectScreen,
        actions: ProfileV3KYC.GmailConnectActions
    ) -> AnyView {
        AnyView(EmptyView())
    }

    func itrConnectView(_ screen: ProfileV3KYC.ITRConnectScreen, actions: ProfileV3KYC.ITRConnectActions) -> AnyView {
        AnyView(EmptyView())
    }

    func passportCaptureView(
        _ screen: ProfileV3KYC.PassportCaptureScreen,
        actions: ProfileV3KYC.PassportCaptureActions
    ) -> AnyView {
        AnyView(EmptyView())
    }

    func selfieCaptureView(
        _ screen: ProfileV3KYC.SelfieCaptureScreen,
        actions: ProfileV3KYC.SelfieCaptureActions
    ) -> AnyView {
        AnyView(EmptyView())
    }

    func authorizeGmail() async -> String? { nil }

    func track(_ event: ProfileV3KYC.Event) {
        if case .photoUploaded(let upload) = event { uploads.append(upload) }
    }
}
