import Foundation
import UIKit
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Glove box")
struct ProfileV3GloveBoxTests {
    private typealias Motion = ProfileV3Theme.GloveBox.Motion
    private typealias Fixtures = ProfileV3GloveBoxFixtures

    @Test func theWarmingGlowBreathesThroughItsKeyframesAndLoops() {
        let glow = Motion.glowRadius
        #expect(glow.value(at: 0) == 100)
        #expect(glow.value(at: 1.5) == 88)
        #expect(glow.value(at: 3) == 96)
        #expect(glow.value(at: 4.5) == 85)
        #expect(glow.value(at: Motion.glowLoop) == 100)
        #expect(glow.value(at: 0.75) < 100)
        #expect(glow.value(at: 0.75) > 88)
    }

    @Test func theWarmingTitleFadesAndRisesInOnce() {
        #expect(Motion.titleFade.value(at: 0) == 0)
        #expect(Motion.titleRise.value(at: 0) == 16)
        #expect(Motion.titleFade.value(at: 0.65) == 1)
        #expect(Motion.titleRise.value(at: Motion.titleDuration) == 0)
        #expect(Motion.titleFade.value(at: .infinity) == 1)
        #expect(Motion.titleRise.value(at: .infinity) == 0)
    }

    @Test func theHomeSheetAndListRowsSettleInOrder() {
        #expect(Motion.sheet.offset(at: 0) == 464)
        #expect(Motion.sheet.progress(at: Motion.sheet.start) == 0)
        #expect(Motion.sheet.progress(at: .infinity) == 1)
        #expect(Motion.row(1).start > Motion.row(0).start)
        #expect(Motion.row(0).offset(at: 0) == 16)
        #expect(Motion.listDuration(rows: 3) == Motion.row(2).end)
        #expect(Motion.listDuration(rows: 0) == Motion.row(0).end)
    }

    @Test func anEmptyAddressStaysEligibleAndAnInboxMapsTheMessage() throws {
        let empty = try JSONDecoder().decode(ProfileV3GloveBoxCardDTO.self, from: Data(#"{"address":null,"eligible":true}"#.utf8))
        let account = ProfileV3GloveBoxMapper.account(empty)
        #expect(account.hasAddress == false)
        #expect(account.eligible)

        let card = try JSONDecoder().decode(
            ProfileV3GloveBoxCardDTO.self,
            from: Data(#"""
            {"address":"sarvajit.4821@ayl.email","previous_addresses":[],
             "forwarding":null,"forwarding_pending":{"email":"me@example.org","expires_at":"2026-10-23T10:49:28Z"},
             "custom_address_available":true}
            """#.utf8)
        )
        let pending = ProfileV3GloveBoxMapper.account(card)
        let section = ProfileV3GloveBoxMapper.section(account: pending, emails: [], hasMore: false)
        #expect(section.address == "sarvajit.4821@ayl.email")
        #expect(section.forwardingLabel == ProfileV3GloveBoxCopy.waitingToConfirm)
        #expect(section.forwardingAddress == "me@example.org")

        let page = try JSONDecoder().decode(
            ProfileV3GloveBoxMessagesDTO.self,
            from: Data(#"""
            {"items":[{"id":"8f2c1e4a-1111-4111-8111-111111111111","from_name":"IndiGo",
              "sender_domain":"goindigo.in","subject":"Your booking is confirmed",
              "received_at":"2026-10-16T08:30:00Z","to_address":"sarvajit.4821@ayl.email",
              "to_previous_address":true,"status":"forwarded","has_attachments":false}],
             "next_cursor":"cursor"}
            """#.utf8)
        )
        let email = try #require(ProfileV3GloveBoxMapper.page(page).emails.first)
        #expect(email.sender == "IndiGo")
        #expect(email.summary == "Your booking is confirmed")
        #expect(email.delivery == .forwarded)
        #expect(email.meta?.glyphs == [.tick, .mail])
        #expect(email.meta?.label == ProfileV3GloveBoxCopy.oldAddress)
        #expect(email.meta?.dateLabel == "16 Oct, 2026")
        #expect(ProfileV3GloveBoxMapper.page(page).nextCursor == "cursor")

        let detail = ProfileV3GloveBoxMapper.detail(
            try JSONDecoder().decode(
                ProfileV3GloveBoxMessageDTO.self,
                from: Data(#"""
                {"id":"8f2c1e4a-1111-4111-8111-111111111111","from_name":"IndiGo",
                 "subject":"Your booking is confirmed","received_at":"2026-10-16T08:30:00Z",
                 "to_previous_address":true,"status":"forwarded","html":"<p>Hello<br>there</p>","text":null,
                 "attachments":[{"filename":"ticket.pdf","content_type":"application/pdf","size":10,
                   "url":"/gateway/jaqen/v1/messages/id/attachments/1"}]}
                """#.utf8)
            ),
            listItem: email
        )
        #expect(detail.note == "Hello\nthere")
        #expect(detail.attachments.map(\.filename) == ["ticket.pdf"])
        #expect(detail.attachments.map(\.index) == [1])
    }

    @Test func inboxRowsReadTheStatusAttentionFooterAndSenderLogo() throws {
        let page = try JSONDecoder().decode(
            ProfileV3GloveBoxMessagesDTO.self,
            from: Data(#"""
            {"items":[
              {"id":"a","from_name":"Emirates","subject":"Your flight now leaves 40 min later",
               "received_at":"2026-10-16T08:30:00Z","status":"forwarded","attention":null,"action":null,
               "sender_logo_url":"https://logos.example/emirates.png"},
              {"id":"b","from_name":"Marriott Dubai","subject":"Free upgrade available",
               "received_at":"2026-10-16T08:30:00Z","status":"handled",
               "attention":{"type":"payment_due","title":"Payment due","detail":"Pay AED 420 by 14 Oct to keep the room."},
               "action":"Added to trip","sender_logo_url":null},
              {"id":"c","from_name":"VFS Global","subject":"Booking confirmed","status":"added_to_thread",
               "attention":"needs a look","action":{"label":"Calendar updated"},"sender_logo_url":"/gateway/jaqen/v1/logos/vfs"},
              {"id":"d","from_name":" ","sender_domain":"goindigo.in","subject":"Receipt","status":"not_forwarded"},
              {"id":"e","from_name":"Air India","subject":"Check in now","status":null}
            ],"next_cursor":null}
            """#.utf8)
        )
        let emails = ProfileV3GloveBoxMapper.page(page).emails
        try #require(emails.count == 5)

        #expect(emails[0].delivery == .forwarded)
        #expect(emails[0].meta == ProfileV3GloveBoxMeta(glyphs: [.tick], label: ProfileV3GloveBoxCopy.sentToInbox, dateLabel: "16 Oct, 2026"))
        #expect(emails[0].logoURL?.absoluteString == "https://logos.example/emirates.png")
        #expect(emails[0].attention == nil)
        #expect(emails[0].badge == nil)

        #expect(emails[1].attention == ProfileV3GloveBoxEmail.Attention(title: "Payment due", detail: "Pay AED 420 by 14 Oct to keep the room."))
        #expect(emails[1].meta == ProfileV3GloveBoxMeta(glyphs: [.tick], label: "Added to trip", dateLabel: "16 Oct, 2026"))
        #expect(emails[1].logoURL == nil)
        #expect(emails[1].initials == "MD")

        #expect(emails[2].attention == nil)
        #expect(emails[2].meta == ProfileV3GloveBoxMeta(glyphs: [.tick], label: ProfileV3GloveBoxCopy.inTheThread))
        #expect(emails[2].logoURL == nil)
        #expect(emails[2].initials == "VG")

        #expect(emails[3].sender == "goindigo.in")
        #expect(emails[3].delivery == .notForwarded)
        #expect(emails[3].meta == nil)
        #expect(emails[3].initials == "G")

        #expect(emails[4].delivery == nil)
        #expect(emails[4].meta == nil)
        #expect(emails[4].initials == "AI")
    }

    @Test func anUntitledAttentionAndALogolessSenderFallBack() throws {
        let page = try JSONDecoder().decode(
            ProfileV3GloveBoxMessagesDTO.self,
            from: Data(#"""
            {"items":[
              {"id":"a","from_name":"Emirates","attention":{"type":"payment_due"}},
              {"id":"b","from_name":"Emirates","attention":{}}
            ]}
            """#.utf8)
        )
        let emails = ProfileV3GloveBoxMapper.page(page).emails
        #expect(emails.first?.attention == ProfileV3GloveBoxEmail.Attention(title: ProfileV3GloveBoxCopy.needsAttention))
        #expect(emails.last?.attention == nil)

        #expect(ProfileV3GloveBoxEmail(id: "x", sender: "booking@marriott.com", summary: "").initials == "M")
        #expect(ProfileV3GloveBoxEmail(id: "x", sender: "The Ritz-Carlton, Dubai", summary: "").initials == "TR")
        #expect(ProfileV3GloveBoxEmail(id: "x", sender: "  ", summary: "").initials.isEmpty)
    }

    @Test func notForwardedEmailsExplainTheForwardingStateOnceOnTheSection() {
        let held = ProfileV3GloveBoxEmail(id: "held", sender: "Emirates", summary: "", delivery: .notForwarded)
        let sent = ProfileV3GloveBoxEmail(id: "sent", sender: "Emirates", summary: "", delivery: .forwarded)
        func notice(_ account: ProfileV3GloveBoxAccount, _ emails: [ProfileV3GloveBoxEmail]) -> String? {
            ProfileV3GloveBoxMapper.section(account: account, emails: emails, hasMore: false).forwardingNotice
        }
        let paused = ProfileV3GloveBoxAccount(address: "me@ayl.email", forwardingEmail: "me@example.org", forwardingPaused: true)
        let pending = ProfileV3GloveBoxAccount(address: "me@ayl.email", pendingEmail: "me@example.org")
        let none = ProfileV3GloveBoxAccount(address: "me@ayl.email")
        let active = ProfileV3GloveBoxAccount(address: "me@ayl.email", forwardingEmail: "me@example.org")
        #expect(notice(paused, [sent, held]) == ProfileV3GloveBoxCopy.notForwardedPaused)
        #expect(notice(pending, [held]) == ProfileV3GloveBoxCopy.notForwardedPending)
        #expect(notice(none, [held]) == ProfileV3GloveBoxCopy.notForwardedNoAddress)
        #expect(notice(active, [held]) == nil)
        #expect(notice(paused, [sent]) == nil)
    }

    @Test func anOpenedEmailKeepsItsRowHeaderAndFillsWhatTheRowLacked() throws {
        let rows = try JSONDecoder().decode(
            ProfileV3GloveBoxMessagesDTO.self,
            from: Data(#"""
            {"items":[{"id":"a","from_name":"Emirates","subject":"Flight change","received_at":"2026-10-16T08:30:00Z",
              "status":"forwarded","attention":{"type":"document","title":"Send your passport"},
              "sender_logo_url":"https://logos.example/emirates.png"}]}
            """#.utf8)
        )
        let row = try #require(ProfileV3GloveBoxMapper.page(rows).emails.first)
        let body = try JSONDecoder().decode(
            ProfileV3GloveBoxMessageDTO.self,
            from: Data(#"{"id":"a","from_name":"Emirates","subject":"Flight change","received_at":"2026-10-16T08:30:00Z","text":"Body"}"#.utf8)
        )
        let opened = ProfileV3GloveBoxMapper.detail(body, listItem: row)
        #expect(opened.logoURL == row.logoURL)
        #expect(opened.attention == row.attention)
        #expect(opened.delivery == .forwarded)
        #expect(opened.meta == row.meta)
        #expect(opened.note == "Body")

        let full = try JSONDecoder().decode(
            ProfileV3GloveBoxMessageDTO.self,
            from: Data(#"""
            {"id":"b","from_name":"VFS Global","subject":"Booking","status":"handled",
             "attention":{"title":"Pay the fee","detail":"INR 1,200 due before the slot."},
             "sender_logo_url":"https://logos.example/vfs.png","text":"Body"}
            """#.utf8)
        )
        let filled = ProfileV3GloveBoxMapper.detail(full, listItem: ProfileV3GloveBoxEmail(id: "b", sender: "VFS Global", summary: "Booking"))
        #expect(filled.logoURL?.absoluteString == "https://logos.example/vfs.png")
        #expect(filled.delivery == .handled)
        #expect(filled.meta == ProfileV3GloveBoxMeta(glyphs: [.tick], label: ProfileV3GloveBoxCopy.handledForYou))
        #expect(filled.attention == ProfileV3GloveBoxEmail.Attention(title: "Pay the fee", detail: "INR 1,200 due before the slot."))
    }

    @Test func aLongNoteWrapsBesideTheOrbOnlyAndAttachmentsKnowTheirKind() {
        let body = String(repeating: "Visa: apply by October 25 and keep a copy of the hotel booking. ", count: 10)
        let width: CGFloat = 342
        let orb = CGSize(width: 84, height: 68)
        func height(_ text: String, width: CGFloat, exclusion: CGSize) -> CGFloat {
            let view = ProfileV3FlowingTextView()
            view.configure(text: text, style: .H7InterMedium16, color: .black, exclusion: exclusion)
            return view.fittingHeight(for: width)
        }
        let flowing = height(body, width: width, exclusion: orb)
        #expect(flowing < height(body, width: width - orb.width, exclusion: .zero))
        #expect(flowing > height(body, width: width, exclusion: .zero))
        #expect(height("Hi", width: width, exclusion: orb) == orb.height)

        #expect(ProfileV3GloveBoxAttachment(index: 0, filename: "ayl.png", contentType: "image/png").isImage)
        #expect(ProfileV3GloveBoxAttachment(index: 1, filename: "confirmation.pdf", contentType: "application/pdf").isImage == false)
    }

    @Test func theIntroButtonReportsItsAction() {
        let viewModel = ProfileV3GloveBoxViewModel(gloveBox: Fixtures.Start.unlock.gloveBox)
        var actions: [ProfileV3GloveBoxIntro.Action] = []
        viewModel.onIntroAction = { actions.append($0) }
        viewModel.tapIntroAction()
        viewModel.show(.intro(Fixtures.warmingUp))
        viewModel.tapIntroAction()
        viewModel.show(.home(Fixtures.home))
        viewModel.tapIntroAction()
        #expect(actions == [.completeKYC, .activate])
    }

    @Test func copyingNeedsTheHomeAndACopyableValue() {
        let intro = ProfileV3GloveBoxViewModel(gloveBox: Fixtures.Start.unlock.gloveBox)
        intro.copy(.address)
        #expect(intro.copied == nil)
        #expect(intro.copies == 0)

        let sample = ProfileV3GloveBoxViewModel(gloveBox: Fixtures.Start.homeSample.gloveBox)
        sample.copy(.number)
        sample.copy(.tripNumber)
        #expect(sample.copied == nil)
        #expect(sample.copies == 0)

        let home = ProfileV3GloveBoxViewModel(gloveBox: Fixtures.Start.home.gloveBox)
        home.copy(.address)
        #expect(home.copied == .address)
        home.copy(.tripNumber)
        #expect(home.copied == .tripNumber)
        #expect(home.copies == 2)
    }

    @Test func listsAndDetailsStackAndUnwind() {
        let viewModel = ProfileV3GloveBoxViewModel(gloveBox: Fixtures.Start.home.gloveBox)
        var followUps: [String] = []
        viewModel.onFollowUp = { followUps.append($0.id) }
        let email = Fixtures.emails[0]

        viewModel.tapFollowUp()
        viewModel.openList(.emails)
        viewModel.tapFollowUp()
        viewModel.open(.email(email))
        #expect(viewModel.sheets == [.list(.emails), .detail(.email(email))])
        viewModel.tapFollowUp()
        viewModel.back()
        #expect(viewModel.sheets == [.list(.emails)])
        viewModel.open(.call(Fixtures.calls[0]))
        viewModel.dismissSheets()
        #expect(viewModel.sheets.isEmpty)
        #expect(followUps == ["email-\(email.id)"])
    }

    @Test func closingTheSheetWindowClearsTheStack() {
        let viewModel = ProfileV3GloveBoxViewModel(gloveBox: Fixtures.Start.home.gloveBox)
        viewModel.openList(.calls)
        viewModel.open(.call(Fixtures.calls[0]))
        viewModel.sheetsDidClose()
        #expect(viewModel.sheets.isEmpty)
        viewModel.openList(.emails)
        #expect(viewModel.sheets == [.list(.emails)])
    }

    @Test func sheetsOnlyOpenOnTheHome() {
        let viewModel = ProfileV3GloveBoxViewModel(gloveBox: Fixtures.Start.warmingUp.gloveBox)
        viewModel.openList(.calls)
        viewModel.open(.transaction(Fixtures.transactions[0]))
        #expect(viewModel.sheets.isEmpty)
    }

    @Test func sampleEntriesCarryTheSampleLabel() {
        let sample = ProfileV3GloveBoxViewModel(gloveBox: Fixtures.Start.homeSample.gloveBox)
        #expect(sample.sampleLabel(for: .email(Fixtures.emails[0])) == "Sample")
        #expect(sample.sampleLabel(for: .call(Fixtures.calls[0])) == "Sample")
        #expect(sample.sampleLabel(for: .transaction(Fixtures.transactions[0])) == nil)

        let home = ProfileV3GloveBoxViewModel(gloveBox: Fixtures.Start.home.gloveBox)
        #expect(home.sampleLabel(for: .email(Fixtures.emails[0])) == nil)
    }

    @Test func choosingHowToPayAndLinkingACardUpdateTheCard() {
        let viewModel = ProfileV3GloveBoxViewModel(gloveBox: Fixtures.Start.homeSample.gloveBox)
        var addCardTaps = 0
        viewModel.onAddCard = { addCardTaps += 1 }

        viewModel.selectPayOption("link")
        #expect(viewModel.home?.card.selectedPayOptionID == "link")
        #expect(viewModel.home?.card.linkedCard == nil)
        viewModel.tapAddCard()
        viewModel.linkCard(Fixtures.hdfc)
        #expect(viewModel.home?.card.linkedCard == Fixtures.hdfc)
        #expect(addCardTaps == 1)
    }

    @Test func theCardNoticeShowsUntilClosedOrTheStageChanges() {
        let viewModel = ProfileV3GloveBoxViewModel(gloveBox: Fixtures.Start.home.gloveBox)
        viewModel.showCardNotice()
        #expect(viewModel.showsCardNotice)
        viewModel.hideCardNotice()
        #expect(!viewModel.showsCardNotice)
        viewModel.showCardNotice()
        viewModel.openList(.transactions)
        viewModel.show(.home(Fixtures.sampleHome))
        #expect(!viewModel.showsCardNotice)
        #expect(viewModel.sheets.isEmpty)
    }

    @Test func theSampleHomeShowsPreviewsWithoutViewAll() {
        let sample = Fixtures.sampleHome
        #expect(sample.email.emails.count == 2)
        #expect(sample.email.viewAllTitle == nil)
        #expect(sample.phone.calls.count == 1)
        #expect(sample.phone.headline != nil)
        #expect(sample.phone.number.isCopyable == false)
        #expect(sample.phone.badge?.tone == .pending)
        #expect(sample.card.transactions.isEmpty)
        #expect(sample.card.linkedCard == nil)
        #expect(Fixtures.home.card.viewAllTitle != nil)
    }

    @Test func anEmptyInboxShowsSampleEmailsUntilARealOneArrives() {
        let account = ProfileV3GloveBoxAccount(address: "priya@trips.atlys.com", forwardingEmail: "priya@gmail.com", eligible: true)
        let empty = ProfileV3GloveBoxMapper.section(account: account, emails: [], hasMore: false)
        #expect(empty.sampleLabel == ProfileV3GloveBoxCopy.sample)
        #expect(empty.emails == ProfileV3GloveBoxSamples.emails)
        #expect(empty.viewAllTitle == nil)
        #expect(empty.forwardingNotice == nil)

        let real = ProfileV3GloveBoxEmail(id: "m1", sender: "IndiGo", summary: "Your web check-in is open")
        let filled = ProfileV3GloveBoxMapper.section(account: account, emails: [real], hasMore: false)
        #expect(filled.sampleLabel == nil)
        #expect(filled.emails == [real])

        let home = ProfileV3GloveBoxMapper.home(email: filled)
        #expect(home.phone.calls == ProfileV3GloveBoxSamples.calls)
        #expect(home.phone.sampleLabel == ProfileV3GloveBoxCopy.sample)
        #expect(home.card.transactions == ProfileV3GloveBoxSamples.transactions)
        #expect(home.card.sampleLabel == ProfileV3GloveBoxCopy.sample)
    }

    @Test(.timeLimit(.minutes(1)))
    func sampleEntriesNeverReachTheServerAndStaySamples() async throws {
        let repository = EmptyInboxStub()
        let viewModel = ProfileV3GloveBoxViewModel(repository: repository)
        while viewModel.home == nil { try await Task.sleep(for: .milliseconds(10)) }
        let home = try #require(viewModel.home)
        #expect(home.email.sampleLabel == ProfileV3GloveBoxCopy.sample)
        #expect(viewModel.sampleLabel(for: .transaction(home.card.transactions[0])) == ProfileV3GloveBoxCopy.sample)

        viewModel.open(.email(home.email.emails[0]))
        try await Task.sleep(for: .milliseconds(50))
        #expect(repository.openedMessages == 0)
        viewModel.dismissSheets()

        viewModel.toggleForwarding()
        while viewModel.isUpdatingForwarding { try await Task.sleep(for: .milliseconds(10)) }
        #expect(viewModel.home?.email.forwardingPaused == true)
        #expect(viewModel.home?.email.sampleLabel == ProfileV3GloveBoxCopy.sample)
        #expect(viewModel.home?.email.emails == ProfileV3GloveBoxSamples.emails)
    }

    @Test(.timeLimit(.minutes(1)))
    func withoutKYCTheIntroIsLockedAndAsksForKYC() async throws {
        let repository = EmptyInboxStub(account: ProfileV3GloveBoxAccount(eligible: true))
        let viewModel = ProfileV3GloveBoxViewModel(repository: repository, isKYCComplete: { false })
        var actions: [ProfileV3GloveBoxIntro.Action] = []
        viewModel.onIntroAction = { actions.append($0) }
        while viewModel.isResolvingScreen { try await Task.sleep(for: .milliseconds(10)) }

        guard case .intro(let intro) = viewModel.gloveBox.stage else {
            Issue.record("expected the intro")
            return
        }
        #expect(intro.title == ProfileV3GloveBoxCopy.unlockTitle)
        #expect(intro.subtitle == ProfileV3GloveBoxCopy.unlockSubtitle)
        #expect(intro.status == .locked)
        #expect(intro.statusLabel == ProfileV3GloveBoxCopy.activateButton)
        #expect(intro.actionTitle == ProfileV3GloveBoxCopy.completeKYC)

        viewModel.tapIntroAction()
        try await Task.sleep(for: .milliseconds(50))
        #expect(actions == [.completeKYC])
        #expect(repository.createdAddresses == 0)
    }

    @Test(.timeLimit(.minutes(1)))
    func withKYCTheIntroOffersToActivate() async throws {
        let repository = EmptyInboxStub(account: ProfileV3GloveBoxAccount(eligible: true))
        let viewModel = ProfileV3GloveBoxViewModel(repository: repository, isKYCComplete: { true })
        while viewModel.isResolvingScreen { try await Task.sleep(for: .milliseconds(10)) }

        guard case .intro(let intro) = viewModel.gloveBox.stage else {
            Issue.record("expected the intro")
            return
        }
        #expect(intro.title == ProfileV3GloveBoxCopy.activateTitle)
        #expect(intro.action == .activate)

        viewModel.tapIntroAction()
        while repository.createdAddresses == 0 { try await Task.sleep(for: .milliseconds(10)) }
    }
}

private final class EmptyInboxStub: ProfileV3GloveBoxRepository, @unchecked Sendable {
    private let lock = NSLock()
    private var account: ProfileV3GloveBoxAccount
    private var _openedMessages = 0
    private var _createdAddresses = 0

    init(account: ProfileV3GloveBoxAccount = ProfileV3GloveBoxAccount(
        address: "priya@trips.atlys.com",
        forwardingEmail: "priya@gmail.com",
        eligible: true
    )) {
        self.account = account
    }

    var openedMessages: Int { lock.withLock { _openedMessages } }
    var createdAddresses: Int { lock.withLock { _createdAddresses } }

    func loadGloveBoxCard() async throws -> ProfileV3GloveBoxAccount {
        lock.withLock { account }
    }

    func createGloveBoxAddress() async throws -> ProfileV3GloveBoxAccount {
        lock.withLock {
            _createdAddresses += 1
            return account
        }
    }

    func setGloveBoxForwardingPaused(_ paused: Bool) async throws -> ProfileV3GloveBoxAccount {
        lock.withLock {
            account.forwardingPaused = paused
            return account
        }
    }

    func addGloveBoxForwardingAddress(_ email: String) async throws -> ProfileV3GloveBoxAccount {
        lock.withLock { account }
    }

    func loadGloveBoxMessages(cursor _: String?) async throws -> ProfileV3GloveBoxInboxPage {
        ProfileV3GloveBoxInboxPage(emails: [], nextCursor: nil)
    }

    func loadGloveBoxMessage(_ listed: ProfileV3GloveBoxEmail) async throws -> ProfileV3GloveBoxEmail {
        lock.withLock { _openedMessages += 1 }
        return listed
    }

    func loadGloveBoxAttachment(messageID _: String, index _: Int) async throws -> Data {
        Data()
    }
}
