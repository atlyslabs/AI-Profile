import CoreGraphics
import SwiftUI
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Header fade")
struct ProfileV3HeaderFadeTests {
    private typealias Sizes = ProfileV3Theme.Sizes

    @Test func theFadeFollowsTheScrollAcrossTheRevealDistance() {
        let pin = ProfileV3HeaderPin()
        #expect(pin.progress == 0)
        pin.offsetBinding.wrappedValue = Sizes.headerRevealDistance / 2
        #expect(pin.progress == 0.5)
        pin.offsetBinding.wrappedValue = Sizes.headerRevealDistance * 3
        #expect(pin.progress == 1)
        pin.offsetBinding.wrappedValue = -40
        #expect(pin.progress == 0)
        #expect(pin.offset == -40)
    }

    @Test func aScrolledFadeIsSolidThroughTheGapThenClears() throws {
        let scrolled = ProfileV3HeaderPin()
        scrolled.offset = Sizes.headerRevealDistance
        let gap = Sizes.headerFadeGap
        let image = try #require(Self.render(ProfileV3HeaderFade(pin: scrolled, gap: gap)))
        #expect(image.height == Int(gap + Sizes.SettingsPage.headerFade))
        #expect(Self.alpha(of: image, row: Int(gap / 2)) == 1)
        #expect(Self.alpha(of: image, row: image.height - 1) < 0.05)

        let resting = try #require(Self.render(ProfileV3HeaderFade(pin: ProfileV3HeaderPin(), gap: gap)))
        #expect(Self.alpha(of: resting, row: Int(gap / 2)) == 0)
    }

    private static func render(_ fade: ProfileV3HeaderFade) -> CGImage? {
        let renderer = ImageRenderer(content: fade.frame(width: 8))
        renderer.scale = 1
        return renderer.cgImage
    }

    private static func alpha(of image: CGImage, row: Int) -> CGFloat {
        var pixel = [UInt8](repeating: 0, count: 4)
        let drawn = pixel.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: 1,
                height: 1,
                bitsPerComponent: 8,
                bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            let height = CGFloat(image.height)
            context.draw(image, in: CGRect(x: 0, y: -(height - 1 - CGFloat(row)), width: CGFloat(image.width), height: height))
            return true
        }
        return drawn ? CGFloat(pixel[3]) / 255 : -1
    }
}
