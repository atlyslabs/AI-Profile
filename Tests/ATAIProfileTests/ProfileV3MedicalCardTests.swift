import ATUIKit
import CoreGraphics
import SwiftUI
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
@Suite("Medical card")
struct ProfileV3MedicalCardTests {
    private typealias Metrics = ProfileV3Theme.Sizes.MedicalCard

    private struct Line {
        let minX: CGFloat
        let maxX: CGFloat
    }

    @Test func aLongNameWrapsBetweenWordsShortOfTheEmblem() throws {
        ATUIKit.initialize()
        let width: CGFloat = 333
        let scale = 2
        let card = ProfileV3MedicalCard(
            holderName: "ANUJ MERUBHAI KHANDEKHA", countryCode: "", dateOfBirth: "30.01.2007",
            bloodGroup: "", emergencyContact: "", organDonor: "",
            showsOnLockScreen: false, rendersLockToggle: false
        )
        let renderer = ImageRenderer(
            content: ProfileV3MedicalCardView(card: card, showsOnLockScreen: .constant(false)).frame(width: width)
        )
        renderer.scale = CGFloat(scale)
        let image = try #require(renderer.cgImage)

        let name = Self.textLines(in: image, scale: scale).prefix { $0.minX < Metrics.valueLeading }
        try #require(name.count == 2)
        let reserve = width - Metrics.padding - Metrics.nameTrailing
        #expect(name.allSatisfy { $0.maxX <= reserve })
        #expect(abs(name[0].maxX - name[0].minX - Self.advance("ANUJ MERUBHAI")) < 3)
        #expect(abs(name[1].maxX - name[1].minX - Self.advance("KHANDEKHA")) < 3)
    }

    private static func advance(_ text: String) -> CGFloat {
        let style = TypographyStyle.H6InterMedium18
        return NSAttributedString(string: text, attributes: [.font: style.uiFont, .kern: style.trackingPoints])
            .size().width
    }

    private static func textLines(in image: CGImage, scale: Int) -> [Line] {
        let width = image.width
        let height = image.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return [] }
        var lines: [Line] = []
        var band: (min: Int, max: Int)?
        for row in 0 ..< height {
            let lit = (0 ..< width).filter { column in
                let i = (row * width + column) * 4
                return pixels[i] > 235 && pixels[i + 1] > 235 && pixels[i + 2] > 235
            }
            if let first = lit.first, let last = lit.last {
                band = (min(band?.min ?? first, first), max(band?.max ?? last, last))
            } else if let finished = band {
                lines.append(Line(
                    minX: CGFloat(finished.min) / CGFloat(scale),
                    maxX: CGFloat(finished.max + 1) / CGFloat(scale)
                ))
                band = nil
            }
        }
        return lines
    }
}
