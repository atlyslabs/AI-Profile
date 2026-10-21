import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Glove box")
struct ProfileV3GloveBoxTests {
    private typealias Motion = ProfileV3Theme.GloveBox.Motion

    @Test func theAddressPopsInThenRisesIntoPlace() {
        #expect(Motion.addressOpacity.value(at: 0) == 0)
        #expect(Motion.addressScale.value(at: 0) == 1.26)
        #expect(abs(Motion.addressY.value(at: 0.7) - 272.5) < 0.001)
        #expect(Motion.addressY.value(at: 1.48) == 0)
        #expect(Motion.addressScale.value(at: .infinity) == 1)
        #expect(Motion.addressX.value(at: .infinity) == 0)
        #expect(Motion.addressOpacity.value(at: .infinity) == 1)
    }

    @Test func revealsFadeUpInOrderAndRest() {
        #expect(Motion.copy.progress(at: Motion.copy.start) == 0)
        #expect(Motion.copy.offset(at: 0) == 7)
        #expect(Motion.copy.progress(at: Motion.copy.end) == 1)
        #expect(Motion.sheet.offset(at: .infinity) == 0)
        #expect(Motion.row(2).start > Motion.row(1).start)
        #expect(Motion.row(1).start > Motion.firstRow.start)
        #expect(Motion.blobX.value(at: .infinity) == 0)
        #expect(Motion.blobY.value(at: .infinity) == 0)
    }

    @Test func theIntroButtonReportsItsAction() {
        let viewModel = ProfileV3GloveBoxViewModel(gloveBox: ProfileV3GloveBoxFixtures.Start.unlock.gloveBox)
        var actions: [ProfileV3GloveBoxIntro.Action] = []
        viewModel.onIntroAction = { actions.append($0) }
        viewModel.tapIntroAction()
        viewModel.show(.intro(ProfileV3GloveBoxFixtures.activateNow))
        viewModel.tapIntroAction()
        #expect(actions == [.completeKYC, .activate])
    }

    @Test func copyingMarksTheAddressCopiedOnlyOnTheInbox() {
        let intro = ProfileV3GloveBoxViewModel(gloveBox: ProfileV3GloveBoxFixtures.Start.unlock.gloveBox)
        intro.copyAddress()
        #expect(!intro.isCopied)
        #expect(intro.copies == 0)
        let inbox = ProfileV3GloveBoxViewModel(gloveBox: ProfileV3GloveBoxFixtures.Start.inbox.gloveBox)
        inbox.copyAddress()
        #expect(inbox.isCopied)
        #expect(inbox.copies == 1)
    }

    @Test func anEmailOpensAndClosesItsDetail() {
        let viewModel = ProfileV3GloveBoxViewModel(gloveBox: ProfileV3GloveBoxFixtures.Start.inbox.gloveBox)
        var followUps: [String] = []
        viewModel.onFollowUp = { followUps.append($0.id) }
        let email = ProfileV3GloveBoxFixtures.emails[0]
        viewModel.open(email)
        #expect(viewModel.openEmail == email)
        viewModel.tapFollowUp()
        viewModel.closeEmail()
        #expect(viewModel.openEmail == nil)
        #expect(followUps == [email.id])
    }
}
