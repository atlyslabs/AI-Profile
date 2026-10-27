import CoreGraphics
import SwiftUI
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Credential store card")
struct ProfileV3CredentialStoreCardTests {
    private typealias Layout = ProfileV3Theme.Sizes.CredentialStore

    private static let designWidth: CGFloat = 380
    private static let shieldCentreX: CGFloat = 322
    private static let shieldTop: CGFloat = 27.75

    @Test func theShieldStartsWhereTheDesignPutsIt() throws {
        let scale = 4
        let renderer = ImageRenderer(content: ProfileV3CredentialStoreCard(action: {}).frame(width: Self.designWidth))
        renderer.scale = CGFloat(scale)
        let image = try #require(renderer.cgImage)
        #expect(image.height == Int(Layout.cardHeight) * scale)

        let column = Self.luma(of: image, column: Int(Self.shieldCentreX) * scale)
        let edge = try #require(column.indices.dropFirst().first { column[$0] - column[$0 - 1] > 20 })
        #expect(abs(CGFloat(edge) / CGFloat(scale) - Self.shieldTop) < 1)
    }

    private static func luma(of image: CGImage, column: Int) -> [Int] {
        var pixels = [UInt8](repeating: 0, count: image.height * 4)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: 1,
                height: image.height,
                bitsPerComponent: 8,
                bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.draw(image, in: CGRect(x: -CGFloat(column), y: 0, width: CGFloat(image.width), height: CGFloat(image.height)))
            return true
        }
        guard drawn else { return [] }
        return (0 ..< image.height).map { row in
            let i = row * 4
            return (Int(pixels[i]) * 299 + Int(pixels[i + 1]) * 587 + Int(pixels[i + 2]) * 114) / 1000
        }
    }
}
