import ATUIKit
import SwiftUI

struct ProfileV3GlobeOrbits: View {
    private struct Mark {
        let ratio: CGFloat
        let degrees: Double
        let length: CGFloat
        let opacity: Double
    }

    private static let arcRatio: CGFloat = 1.55
    private static let arcs: [ClosedRange<Double>] = [172 ... 190, -10 ... 8]
    private static let arcOpacity = 0.18
    private static let markThickness: CGFloat = 0.6
    private static let marks: [Mark] = [
        Mark(ratio: 1.16, degrees: 12, length: 3, opacity: 0.3),
        Mark(ratio: 1.44, degrees: 6, length: 3, opacity: 0.2),
        Mark(ratio: 1.38, degrees: 186, length: 2, opacity: 0.28),
        Mark(ratio: 1.54, degrees: 198, length: 3, opacity: 0.3),
        Mark(ratio: 1.24, degrees: 353, length: 1, opacity: 0.18),
        Mark(ratio: 1.8, degrees: 352, length: 2, opacity: 0.22),
        Mark(ratio: 1.95, degrees: 176, length: 2, opacity: 0.18),
        Mark(ratio: 1.55, degrees: 24, length: 1, opacity: 0.1),
        Mark(ratio: 1.55, degrees: 156, length: 1, opacity: 0.1),
        Mark(ratio: 1.83, degrees: 15, length: 1, opacity: 0.1),
        Mark(ratio: 1.83, degrees: 165, length: 1, opacity: 0.1),
        Mark(ratio: 1.86, degrees: 198, length: 1, opacity: 0.12),
        Mark(ratio: 1.86, degrees: 342, length: 1, opacity: 0.12),
        Mark(ratio: 1.59, degrees: 207, length: 1, opacity: 0.12),
        Mark(ratio: 1.59, degrees: 333, length: 1, opacity: 0.12),
        Mark(ratio: 1.13, degrees: 344, length: 1, opacity: 0.12),
        Mark(ratio: 1.21, degrees: 343, length: 1, opacity: 0.12),
        Mark(ratio: 1.15, degrees: 214, length: 1, opacity: 0.12)
    ]

    var body: some View {
        Canvas { context, size in
            let centre = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 4
            func point(_ degrees: Double, _ ratio: CGFloat) -> CGPoint {
                let angle = degrees * .pi / 180
                return CGPoint(
                    x: centre.x + CGFloat(cos(angle)) * radius * ratio,
                    y: centre.y - CGFloat(sin(angle)) * radius * ratio
                )
            }
            for arc in Self.arcs {
                var path = Path()
                path.move(to: point(arc.lowerBound, Self.arcRatio))
                for degrees in stride(from: arc.lowerBound + 1, through: arc.upperBound, by: 1) {
                    path.addLine(to: point(degrees, Self.arcRatio))
                }
                context.stroke(
                    path,
                    with: .color(ProfileV3Theme.Palette.globeOrbit.opacity(Self.arcOpacity)),
                    lineWidth: ProfileV3Theme.Stroke.fine
                )
            }
            for mark in Self.marks {
                let centrePoint = point(mark.degrees, mark.ratio)
                let rect = CGRect(
                    x: centrePoint.x - mark.length / 2,
                    y: centrePoint.y - Self.markThickness / 2,
                    width: mark.length,
                    height: Self.markThickness
                )
                context.fill(
                    Path(roundedRect: rect, cornerRadius: Self.markThickness / 2),
                    with: .color(ProfileV3Theme.Palette.globeOrbit.opacity(mark.opacity))
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
