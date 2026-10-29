import Foundation
import SwiftUI
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
@Suite("Passport back page", .serialized)
struct ProfileV3PassportBackPageTests {
    private static let backURL = "https://storage.googleapis.com/vdcapp-54939.appspot.com/u/documents/"
        + "passportbackpage-769b.jpeg?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Expires=604795&X-Goog-Signature=4cdd"

    @Test func aScannedBackPageComesWithThePassport() throws {
        let field = try Self.field(#"""
        {"agent_type":"personal","passport":{
          "issue_date":"May 15, 2024","status":"active","expiry_date":"May 14, 2034",
          "rescan_label":"Upload new passport","front_url":"https://storage.googleapis.com/b/front.jpeg",
          "verified":true,"labels":{"number":"PASSPORT NUMBER","issue_date":"ISSUE DATE","expiry_date":"EXPIRY DATE"},
          "how_used":{"go":"passport_how_used"},"title":"भारत गणराज्य   REPUBLIC OF INDIA",
          "rescan":{"profile_id":"8372cf0a","go":"passport_update"},"number":"F9090906",
          "back_url":"\#(Self.backURL)","title_label":"PASSPORT DETAILS","name":"CHOTA BACHA"}}
        """#)
        #expect(field.backPageURL == URL(string: Self.backURL))
        #expect(field.passport?.number == "F9090906")
        #expect(field.holderName == "CHOTA BACHA")
        #expect(field.countryName == "REPUBLIC OF INDIA")
    }

    @Test func onlyAnAbsoluteWebAddressCountsAsABackPage() throws {
        for back in [#""back_url":null"#, #""back_url":"  ""#, #""back_url":"/documents/back.jpeg""#, #""back_url":42"#, ""] {
            let comma = back.isEmpty ? "" : ","
            let field = try Self.field(#"{"agent_type":"personal","passport":{"number":"F9090906"\#(comma)\#(back)}}"#)
            #expect(field.backPageURL == nil, "\(back)")
            #expect(field.passport?.number == "F9090906")
        }
    }

    @Test(arguments: [(width: CGFloat(440), card: CGFloat(380)), (width: 393, card: 333)])
    func frontAndBackSitSideBySideAndScrollSideways(width: CGFloat, card: CGFloat) async throws {
        let margin = ProfileV3Theme.Sizes.screenHorizontalMargin
        let host = UIHostingController(rootView:
            ProfileV3PassportPagesRow(backPageURL: try #require(URL(string: Self.backURL))) {
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
    func theBackPageStaysHiddenUntilTheClientConfigTurnsItOn() async throws {
        #expect(!ProfileV3FeatureFlags.isPassportBackPageEnabled)
        var field = ProfileV3PassportField(holderName: "CHOTA BACHA", countryName: "REPUBLIC OF INDIA")
        field.passport = ProfileV3Passport(
            id: "F9090906", holderName: "CHOTA BACHA", number: "F9090906", countryName: "REPUBLIC OF INDIA",
            issuedOn: "15/05/2024", expiresOn: "14/05/2034"
        )
        field.backPageURL = URL(string: Self.backURL)
        let section = ProfileV3FormSection(id: "passport", title: "PASSPORT DETAILS", status: .complete, control: .passport(field))

        for showsBackPage in [false, true] {
            var view = ProfileV3FormSectionView(
                section: section,
                onToggleOption: { _ in }, onSliderChange: { _ in }, onOptOut: { _ in }, onTextChange: { _ in }
            )
            if showsBackPage { view.showsPassportBackPage = true }
            let host = UIHostingController(rootView: view.padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin))
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
            window.rootViewController = host
            window.makeKeyAndVisible()
            defer { window.isHidden = true }

            try await Task.sleep(for: .milliseconds(300))
            host.view.layoutIfNeeded()
            #expect(Self.scrollViews(in: host.view).isEmpty == !showsBackPage, "showsBackPage \(showsBackPage)")
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func aWideScanFitsInsideTheCardInsteadOfWideningIt() async throws {
        let scan = UIGraphicsImageRenderer(size: CGSize(width: 1250, height: 880)).image { context in
            UIColor(red: 0, green: 1, blue: 0, alpha: 1).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1250, height: 880))
        }
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("pv3-wide-back-page.png")
        try #require(scan.pngData()).write(to: file)
        defer { try? FileManager.default.removeItem(at: file) }

        let host = UIHostingController(rootView:
            ProfileV3PassportBackPage(url: file, accessibilityTitle: "BACK").frame(width: 333)
        )
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 600))
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        try await Self.waitUntil { Self.greenSpan(acrossTheMiddleOf: host.view) > 0 }
        #expect(Self.greenSpan(acrossTheMiddleOf: host.view) == 333)
    }

    private static func greenSpan(acrossTheMiddleOf view: UIView) -> Int {
        view.layoutIfNeeded()
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.preferredRange = .standard
        let row = CGRect(x: 0, y: view.bounds.midY.rounded(), width: view.bounds.width, height: 1)
        let image = UIGraphicsImageRenderer(bounds: row, format: format).image { context in
            view.layer.render(in: context.cgContext)
        }
        guard let cgImage = image.cgImage, let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else { return 0 }
        let stride = cgImage.bitsPerPixel / 8
        return (0 ..< cgImage.width).filter { x in
            let pixel = bytes + x * stride
            return pixel[1] > 240 && max(pixel[0], pixel[2]) < 15
        }.count
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
