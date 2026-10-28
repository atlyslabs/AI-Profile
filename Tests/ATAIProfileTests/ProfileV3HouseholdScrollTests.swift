import SwiftUI
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
@Suite("Household card scroll", .serialized)
struct ProfileV3HouseholdScrollTests {
    @Test(.timeLimit(.minutes(1)))
    func theHouseholdCardLocksThePageButNotTheCarousel() async throws {
        let viewModel = ProfileV3HubViewModel(
            repository: ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore())
        )
        let host = UIHostingController(rootView: ProfileV3HubView(viewModel: viewModel))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        try await Self.waitUntil { viewModel.home != nil && !Self.carousels(in: host.view).isEmpty }
        let page = try #require(Self.scrollViews(in: host.view).first)
        #expect(page.isScrollEnabled)

        viewModel.selectHousehold()
        try await Self.waitUntil { !page.isScrollEnabled }
        let carousels = Self.carousels(in: host.view)
        let carouselsScroll = carousels.allSatisfy { $0.isScrollEnabled }
        #expect(!carousels.isEmpty)
        #expect(carouselsScroll)

        let pass = try #require(viewModel.home?.worldPasses.first)
        viewModel.selectPass(id: pass.id)
        try await Self.waitUntil { page.isScrollEnabled }
        #expect(!viewModel.isHouseholdSelected)
    }

    private static func scrollViews(in view: UIView) -> [UIScrollView] {
        var found: [UIScrollView] = []
        if let scrollView = view as? UIScrollView { found.append(scrollView) }
        for subview in view.subviews { found += scrollViews(in: subview) }
        return found
    }

    private static func carousels(in view: UIView) -> [UIScrollView] {
        scrollViews(in: view).dropFirst().filter { $0.contentSize.width > $0.bounds.width + 1 }
    }

    private static func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0 ..< 200 where !condition() {
            try await Task.sleep(for: .milliseconds(50))
        }
        #expect(condition())
    }
}
