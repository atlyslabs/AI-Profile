import SwiftUI
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
@Suite("Continue button")
struct ProfileV3ContinueButtonTests {
    @Test func aDisabledButtonKeepsAnOpaqueFillOverTheContentBehindIt() throws {
        let size = CGSize(width: 393, height: 120)
        let content = ZStack {
            Color.black
            ProfileV3ContinueButton(title: "Add traveler", isEnabled: false) {}
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        }
        .frame(width: size.width, height: size.height)
        let image = try Self.render(content, size: size)
        let inset = ProfileV3Theme.Sizes.screenHorizontalMargin
        let fill = try #require(Self.brightness(in: image, at: CGPoint(x: inset + 20, y: size.height / 2)))
        let backdrop = try #require(Self.brightness(in: image, at: CGPoint(x: inset / 3, y: size.height / 2)))
        #expect(fill > 0.95, "fill \(fill)")
        #expect(backdrop < 0.05, "backdrop \(backdrop)")
    }

    @Test func theAddTravellerFormScrollsItsEndAboveTheButton() async throws {
        let host = UIHostingController(rootView: ProfileV3AddTravellerView(
            screen: Self.screenWithRelationships,
            submission: .constant(ProfileV3AddTravellerSubmission(regionISO: "IN", dialCode: "91")),
            canSubmit: false,
            onBack: {},
            onClose: {},
            onConfirm: {}
        ))
        host.safeAreaRegions = []
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 620))
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.layoutIfNeeded()
        try await Task.sleep(for: .milliseconds(200))
        host.view.layoutIfNeeded()

        let scroll = try #require(Self.scrollViews(in: window).first)
        let frame = scroll.convert(scroll.bounds, to: window)
        let visibleBottom = frame.minY + scroll.frame.height - scroll.adjustedContentInset.bottom
        let bar = ProfileV3Theme.Sizes.pickerConfirmTop + ProfileV3Theme.Sizes.Save.buttonHeight + ProfileV3Theme.Sizes.ctaBarBottom
        let buttonTop = window.bounds.height - ProfileV3Theme.Sizes.ctaBarBottom - ProfileV3Theme.Sizes.Save.buttonHeight
        #expect(scroll.contentSize.height > frame.height, "the form should be taller than the sheet")
        #expect(visibleBottom <= buttonTop + 1, "visible bottom \(visibleBottom), button top \(buttonTop), bar \(bar)")
        window.isHidden = true
    }

    private static let screenWithRelationships: ProfileV3AddTravellerScreen = {
        let relations = [
            "Spouse", "Partner", "Son", "Daughter", "Father", "Mother", "Brother", "Sister", "Grandfather",
            "Grandmother", "Grandson", "Granddaughter", "Father-in-law", "Mother-in-law", "Brother-in-law",
            "Sister-in-law", "Son-in-law", "Daughter-in-law", "Uncle", "Aunt", "Nephew", "Niece", "Cousin", "Other"
        ]
        let relationship = ProfileV3AddTravellerField(
            key: ProfileV3AddTravellerField.relationshipKey,
            label: "Relationship",
            input: .singleSelect,
            isRequired: true,
            options: relations.map { ProfileV3AddTravellerOption(value: $0.lowercased(), title: $0) }
        )
        return ProfileV3AddTravellerScreen(
            title: "Add a traveler",
            subtitle: "",
            fields: ProfileV3Fixtures.addTraveller.fields + [relationship],
            submitLabel: "Add traveler"
        )
    }()

    private static func render(_ view: some View, size: CGSize) throws -> CGImage {
        let host = UIHostingController(rootView: view)
        host.safeAreaRegions = []
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.layoutIfNeeded()
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            window.layer.render(in: context.cgContext)
        }
        window.isHidden = true
        return try #require(image.cgImage)
    }

    private static func brightness(in image: CGImage, at point: CGPoint) -> CGFloat? {
        let x = Int(point.x), y = Int(point.y)
        guard x >= 0, y >= 0, x < image.width, y < image.height else { return nil }
        var pixel = [UInt8](repeating: 0, count: 4)
        guard let context = CGContext(
            data: &pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        context.draw(image, in: CGRect(x: -x, y: y - image.height + 1, width: image.width, height: image.height))
        return (CGFloat(pixel[0]) + CGFloat(pixel[1]) + CGFloat(pixel[2])) / (3 * 255)
    }

    private static func scrollViews(in view: UIView) -> [UIScrollView] {
        ((view as? UIScrollView).map { [$0] } ?? []) + view.subviews.flatMap { scrollViews(in: $0) }
    }
}
