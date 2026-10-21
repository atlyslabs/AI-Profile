import Observation
import SwiftUI
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
@Suite("Carousel selection", .serialized)
struct ProfileV3CarouselSelectionTests {
    @Test(.timeLimit(.minutes(1)))
    func theCentredCardSurvivesASwitchToAnotherTab() async throws {
        let probe = ProfileV3CarouselProbe()
        let tabs = UITabBarController()
        tabs.viewControllers = [Self.host(probe), UIViewController()]
        let window = try await Self.show(tabs, centring: "c", probe: probe)
        defer { window.isHidden = true }

        tabs.selectedIndex = 1
        try await Task.sleep(for: .milliseconds(300))
        tabs.selectedIndex = 0
        try await Task.sleep(for: .milliseconds(500))

        #expect(probe.selection == "c")
        #expect(probe.centredID == "c")
    }

    @Test(.timeLimit(.minutes(1)))
    func theCentredCardSurvivesAPushOverIt() async throws {
        let probe = ProfileV3CarouselProbe()
        let navigation = UINavigationController(rootViewController: Self.host(probe))
        let window = try await Self.show(navigation, centring: "c", probe: probe)
        defer { window.isHidden = true }

        navigation.pushViewController(UIViewController(), animated: false)
        try await Task.sleep(for: .milliseconds(300))
        navigation.popViewController(animated: false)
        try await Task.sleep(for: .milliseconds(500))

        #expect(probe.selection == "c")
        #expect(probe.centredID == "c")
    }

    @Test(.timeLimit(.minutes(1)))
    func theCarouselComesBackOnASelectionMadeWhileItWasAway() async throws {
        let probe = ProfileV3CarouselProbe()
        let tabs = UITabBarController()
        tabs.viewControllers = [Self.host(probe), UIViewController()]
        let window = try await Self.show(tabs, centring: "c", probe: probe)
        defer { window.isHidden = true }

        tabs.selectedIndex = 1
        try await Task.sleep(for: .milliseconds(300))
        probe.selection = "b"
        tabs.selectedIndex = 0
        try await Self.waitUntil { probe.centredID == "b" }

        #expect(probe.selection == "b")
    }

    private static func host(_ probe: ProfileV3CarouselProbe) -> UIViewController {
        UIHostingController(rootView: ProfileV3CarouselProbeView(probe: probe))
    }

    private static func show(
        _ root: UIViewController,
        centring id: String,
        probe: ProfileV3CarouselProbe
    ) async throws -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = root
        window.makeKeyAndVisible()
        try await waitUntil { probe.centredID == "a" }
        probe.selection = id
        try await waitUntil { probe.centredID == id }
        return window
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 200 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition())
    }
}

@MainActor
@Observable
private final class ProfileV3CarouselProbe {
    static let ids = ["a", "b", "c"]

    var selection: String? = "a"
    var midX: [String: CGFloat] = [:]
    var width: CGFloat = 0

    var centredID: String? {
        Self.ids.first { abs((midX[$0] ?? .infinity) - width / 2) < 1 }
    }
}

private struct ProfileV3CarouselProbeView: View {
    let probe: ProfileV3CarouselProbe

    var body: some View {
        ProfileV3CentredCarousel(
            itemWidth: 200,
            height: 120,
            spacing: 12,
            selection: Binding(get: { probe.selection }, set: { probe.selection = $0 })
        ) {
            ForEach(ProfileV3CarouselProbe.ids, id: \.self) { id in
                Color.blue
                    .frame(width: 200, height: 120)
                    .onGeometryChange(for: CGFloat.self) { $0.frame(in: .global).midX } action: { probe.midX[id] = $0 }
            }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { probe.width = $0 }
    }
}
