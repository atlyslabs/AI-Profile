import SwiftUI
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
@Suite("KYC onboarding presentation", .serialized)
struct ProfileV3OnboardingPresentationTests {
    @Test(.timeLimit(.minutes(1)))
    func theHubsOwnSurfaceRunsOnboardingOverTheTabBar() async throws {
        let (window, tabs, navCon) = Self.tabbedNavigation()
        defer { window.isHidden = true }
        let kyc = OnboardingHostSpy()
        var outcome: ProfileV3FlowOutcome?
        var wasCoveredWhenReported: Bool?

        ProfileV3OnboardingLauncher.start(.fullScreen, using: kyc, on: navCon) { result in
            outcome = result
            wasCoveredWhenReported = tabs.presentedViewController != nil
        }

        let container = try #require(kyc.navigationControllers.first)
        #expect(container !== navCon)
        #expect(navCon.viewControllers.count == 1)
        #expect(container.modalPresentationStyle == .fullScreen)
        #expect(container.presentingViewController === tabs)
        try await Self.waitUntil { !container.isBeingPresented }

        kyc.finish(.completed)
        try await Self.waitUntil { outcome != nil }
        #expect(outcome == .completed)
        #expect(wasCoveredWhenReported == false)
        #expect(tabs.presentedViewController == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func aFlowThatClosesItsOwnContainerIsReportedOnce() async throws {
        let (window, tabs, navCon) = Self.tabbedNavigation()
        defer { window.isHidden = true }
        let kyc = OnboardingHostSpy()
        var outcomes: [ProfileV3FlowOutcome] = []

        ProfileV3OnboardingLauncher.start(.fullScreen, using: kyc, on: navCon) { outcomes.append($0) }
        let container = try #require(kyc.navigationControllers.first)
        try await Self.waitUntil { !container.isBeingPresented }

        kyc.finishByClosingTheContainer(.cancelled)
        try await Self.waitUntil { !outcomes.isEmpty }
        try await Task.sleep(for: .milliseconds(300))
        #expect(outcomes == [.cancelled])
        #expect(tabs.presentedViewController == nil)
    }

    @Test func aHostThatGivesUpAtOncePresentsNothing() {
        let (window, tabs, navCon) = Self.tabbedNavigation()
        defer { window.isHidden = true }
        let kyc = OnboardingHostSpy(finishesAtOnce: true)
        var outcomes: [ProfileV3FlowOutcome] = []

        ProfileV3OnboardingLauncher.start(.fullScreen, using: kyc, on: navCon) { outcomes.append($0) }

        #expect(outcomes == [.cancelled])
        #expect(tabs.presentedViewController == nil)
    }

    @Test func aHostsOwnNavigationControllerKeepsThePush() {
        let navCon = UINavigationController(rootViewController: UIViewController())
        let kyc = OnboardingHostSpy()
        var outcome: ProfileV3FlowOutcome?

        ProfileV3OnboardingLauncher.start(.push, using: kyc, on: navCon) { outcome = $0 }

        #expect(kyc.navigationControllers.first === navCon)
        #expect(navCon.viewControllers.count == 2)
        #expect(navCon.presentedViewController == nil)
        kyc.finish(.cancelled)
        #expect(outcome == .cancelled)
    }

    private static func tabbedNavigation() -> (UIWindow, UITabBarController, UINavigationController) {
        let navCon = UINavigationController(rootViewController: UIViewController())
        let tabs = UITabBarController()
        tabs.viewControllers = [navCon, UIViewController()]
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        return (window, tabs, navCon)
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 100 where !condition() {
            try await Task.sleep(for: .milliseconds(50))
        }
        #expect(condition())
    }
}

@MainActor
private final class OnboardingHostSpy: ProfileV3KYCHost {
    private let finishesAtOnce: Bool
    private(set) var navigationControllers: [UINavigationController] = []
    private var completion: (@MainActor (ProfileV3FlowOutcome) -> Void)?

    init(finishesAtOnce: Bool = false) {
        self.finishesAtOnce = finishesAtOnce
    }

    func startOnboarding(
        on navigationController: UINavigationController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) {
        navigationControllers.append(navigationController)
        guard !finishesAtOnce else {
            completion(.cancelled)
            return
        }
        navigationController.pushViewController(UIViewController(), animated: false)
        self.completion = completion
    }

    func finish(_ outcome: ProfileV3FlowOutcome) {
        completion?(outcome)
    }

    func finishByClosingTheContainer(_ outcome: ProfileV3FlowOutcome) {
        let completion = completion
        navigationControllers.last?.dismiss(animated: true) { completion?(outcome) }
    }

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

    func itrConnectView(
        _ screen: ProfileV3KYC.ITRConnectScreen,
        actions: ProfileV3KYC.ITRConnectActions
    ) -> AnyView {
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

    func track(_ event: ProfileV3KYC.Event) {}
}
