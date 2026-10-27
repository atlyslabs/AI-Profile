import Foundation
import Testing
@testable import ATAIProfile

@Suite("Hub KYC notch")
struct ProfileV3HubNotchTests {
    private typealias Collapse = ProfileV3Theme.Sizes.Collapse

    @Test func aFlingBackHidesTheNotchInTheSameUpdate() {
        let scroll = ProfileV3HubScroll()
        scroll.offset = Collapse.distance + 200
        scroll.kycTagBottom = Collapse.backdropSolidBottom - 40
        #expect(scroll.notchReveal == 1)

        scroll.offset = Collapse.distance / 2
        scroll.kycTagBottom = Collapse.backdropFadeBottom + 120
        #expect(scroll.collapse == 0.5)
        #expect(scroll.notchReveal == 0)
    }

    @Test func theNotchCrossFadesWithTheTagGoingUnderTheBackdrop() {
        let scroll = ProfileV3HubScroll()
        scroll.offset = Collapse.distance
        scroll.kycTagBottom = Collapse.backdropFadeBottom
        #expect(scroll.notchReveal == 0)
        scroll.kycTagBottom = (Collapse.backdropFadeBottom + Collapse.backdropSolidBottom) / 2
        #expect(abs(scroll.notchReveal - 0.5) < 0.001)
        scroll.kycTagBottom = Collapse.backdropSolidBottom
        #expect(scroll.notchReveal == 1)
    }

    @Test func aHiddenTagStillWaitsForTheCardToFold() {
        let scroll = ProfileV3HubScroll()
        scroll.kycTagBottom = Collapse.backdropSolidBottom - 40
        #expect(scroll.notchReveal == 0)
        scroll.offset = Collapse.distance / 2
        #expect(scroll.notchReveal == 0)
        scroll.offset = Collapse.distance * (ProfileV3Theme.Motion.collapseTabFadeStart + 1) / 2
        #expect(abs(scroll.notchReveal - 0.5) < 0.001)
    }

    @Test func withoutAKYCTagThereIsNoNotch() {
        let scroll = ProfileV3HubScroll()
        scroll.offset = Collapse.distance + 200
        #expect(scroll.collapse == 1)
        #expect(scroll.notchReveal == 0)
    }
}
