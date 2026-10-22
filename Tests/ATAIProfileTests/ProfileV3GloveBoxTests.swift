import Foundation
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
}
