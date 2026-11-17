import Foundation
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
@Suite("Settings redesign")
struct ProfileV3SettingsRedesignTests {
    @Test func theCardShowsTheFirstFourPartnerLogos() {
        let partners = ProfileV3Partners(
            title: "Partners",
            subtitle: "",
            pageSubtitle: "",
            partners: ["a", "b", "c", "d", "e", "f"].map { id in
                ProfileV3Partner(id: id, name: id.uppercased(), logoURL: id == "b" ? nil : URL(string: "https://example.com/\(id).png"))
            }
        )
        let names = partners.cardLogos.map(\.lastPathComponent)
        #expect(names == ["a.png", "c.png", "d.png", "e.png"])
    }

    @Test func partnersIsAFullHeightPage() {
        #expect(ProfileV3SettingsDestination.partners.isPage)
        #expect(ProfileV3SettingsDestination.partners.isFullHeight)
    }

    @Test(.timeLimit(.minutes(1)))
    func partnersOpenAsAPageAndTheirInfoOpensOutside() async throws {
        let router = RouterSpy()
        let viewModel = try await Self.loadedSettings()
        viewModel.router = router

        viewModel.tapPartners()
        #expect(viewModel.pagePath == [.partners])

        let partners = viewModel.menu?.partners?.partners ?? []
        let firstWithInfo = partners.first(where: Self.hasInfo)
        let withInfo = try #require(firstWithInfo)
        let infoURL = try #require(withInfo.infoURL)
        viewModel.openPartnerInfo(withInfo)
        viewModel.openPartnerInfo(ProfileV3Partner(id: "x", name: "No link"))
        #expect(router.openedURLs == [infoURL])
    }

    @Test(.timeLimit(.minutes(1)))
    func theNotificationsSwitchKeepsItsStateOnTheDevice() async throws {
        let viewModel = try await Self.loadedSettings()
        #expect(viewModel.menu?.notifications?.isOn == true)
        viewModel.setNotifications(false)
        #expect(viewModel.menu?.notifications?.isOn == false)
        viewModel.setNotifications(true)
        #expect(viewModel.menu?.notifications?.isOn == true)
    }

    @Test(.timeLimit(.minutes(1)))
    func aPickedPhotoShowsInTheAvatarAndBadDataIsIgnored() async throws {
        let viewModel = try await Self.loadedSettings()
        #expect(viewModel.photoUploadLabel == "Upload")

        viewModel.pickPhoto(Data("not an image".utf8))
        #expect(viewModel.pickedPhoto == nil)

        let png = UIGraphicsImageRenderer(size: CGSize(width: 2, height: 2)).pngData { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
        }
        viewModel.pickPhoto(png)
        #expect(viewModel.pickedPhoto != nil)
    }

    @Test func theLogoFliesInOnceAndRipplesAfterEveryFocus() {
        let start = Date(timeIntervalSince1970: 0)
        let first = ProfileV3PartnerLanding(startedAt: start, flies: true)

        let opening = first.pose(at: start)
        #expect(Self.close(opening.scale, 0.72))
        #expect(Self.close(opening.opacity, 0))
        #expect(Self.close(opening.blur, 7))
        #expect(Self.close(opening.offset.width, -165) && Self.close(opening.offset.height, 109))

        let settled = first.pose(at: start.addingTimeInterval(ProfileV3PartnerLanding.duration))
        #expect(Self.close(settled.scale, 1) && Self.close(settled.opacity, 1) && Self.close(settled.blur, 0))
        #expect(Self.close(settled.offset.width, 0) && Self.close(settled.offset.height, 0))
        #expect(Self.close(settled.ringOne.opacity, 0) && Self.close(settled.ringTwo.opacity, 0))

        let refocus = ProfileV3PartnerLanding(startedAt: start, flies: false)
        let landed = refocus.pose(at: start)
        #expect(Self.close(landed.scale, 1) && Self.close(landed.opacity, 1) && Self.close(landed.blur, 0))
        let rippling = refocus.pose(at: start.addingTimeInterval(1.564 - ProfileV3PartnerLanding.landed))
        #expect(Self.close(rippling.ringOne.opacity, 0.32))
        #expect(Self.close(rippling.ringTwo.opacity, 0))
    }

    private static func hasInfo(_ partner: ProfileV3Partner) -> Bool {
        partner.infoURL != nil
    }

    private static func close(_ value: CGFloat, _ expected: CGFloat) -> Bool {
        abs(value - expected) < 0.001
    }

    private static func close(_ value: Double, _ expected: Double) -> Bool {
        abs(value - expected) < 0.001
    }

    private static func loadedSettings() async throws -> ProfileV3SettingsViewModel {
        let viewModel = ProfileV3SettingsViewModel(deps: .preview(), repository: ProfileV3MockRepository(delay: .zero))
        viewModel.loadMenuIfNeeded()
        for _ in 0 ..< 300 where viewModel.menu == nil {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(viewModel.menu != nil)
        return viewModel
    }
}

private final class RouterSpy: ProfileV3SettingsRouter {
    private(set) var openedURLs: [URL] = []

    func presentConnectorOnboarding() {}
    func startConnectorCapture(_ step: String) {}
    func presentDisconnectEmail() {}
    func dismissDisconnectEmail() {}
    func presentDisconnectProgress() {}
    func dismissDisconnectProgress() {}
    func connectorDidDisconnect(_ connector: ProfileV3ConnectorKey) {}
    func presentSheet() {}
    func dismissSheet() {}
    func dismissSettings() {}
    func dismissSettingsThenRestart(after pendingWrites: Task<Void, Never>?) {}
    func restartAfterSaving(_ pendingWrites: Task<Void, Never>?) {}
    func presentCoupons() {}
    func presentInviteShare(_ invite: ProfileV3InviteCode) {}
    func presentLoyaltyProgrammes() {}
    func presentTermsOfService() {}
    func presentSupport() {}
    func openExternalURL(_ url: URL) { openedURLs.append(url) }
    #if DEBUG
    func presentCityProfile() {}
    #endif
    func showFlash(_ text: String, isSuccess: Bool) {}
    func travellerDidChange() {}
    func travellersDidChange() {}
    func performLogout() {}
}
