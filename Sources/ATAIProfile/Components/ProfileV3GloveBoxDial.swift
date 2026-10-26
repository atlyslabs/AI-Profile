import ATUIKit
import SwiftUI

enum ProfileV3GloveBoxDial {
    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    static func draw(_ icon: Image, centre: CGPoint, diameter: CGFloat = Layout.dial, in context: GraphicsContext) {
        let scale = diameter / Layout.dial
        let disc = square(centre: centre, side: diameter)
        let shadow = disc.offsetBy(dx: 0, dy: Layout.dialShadowDrop * scale)
        context.fill(
            Path(ellipseIn: shadow),
            with: .linearGradient(
                Gradient(colors: [Palette.dialLight, Palette.dialShadow]),
                startPoint: CGPoint(x: shadow.minX, y: shadow.midY),
                endPoint: CGPoint(x: shadow.maxX, y: shadow.midY)
            )
        )
        context.fill(
            Path(ellipseIn: disc),
            with: .linearGradient(
                Gradient(colors: [Palette.dialLight, Palette.dialBase]),
                startPoint: CGPoint(x: disc.midX, y: disc.minY),
                endPoint: CGPoint(x: disc.midX, y: disc.maxY)
            )
        )
        for step in 0..<Layout.dialDotCount {
            let angle = Double(step) / Double(Layout.dialDotCount) * 2 * .pi
            let dot = CGPoint(
                x: centre.x + Layout.dialDotRadius * scale * sin(angle),
                y: centre.y - Layout.dialDotRadius * scale * cos(angle)
            )
            context.fill(Path(ellipseIn: square(centre: dot, side: Layout.dialDot * scale)), with: .color(Palette.dialDot))
        }
        context.fill(Path(ellipseIn: square(centre: centre, side: Layout.dialFace * scale)), with: .color(Palette.dialFace))
        var glyph = context.resolve(icon.renderingMode(.template))
        glyph.shading = .color(Palette.dialIcon)
        context.draw(glyph, in: square(centre: centre, side: Layout.dialIcon * scale))
    }

    private static func square(centre: CGPoint, side: CGFloat) -> CGRect {
        CGRect(x: centre.x - side / 2, y: centre.y - side / 2, width: side, height: side)
    }
}

struct ProfileV3GloveBoxPill: View {
    enum Border {
        case ink
        case spectrum
    }

    let label: String
    var showsBolt = false
    var border = Border.ink

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    var body: some View {
        HStack(spacing: Layout.pillSpacing) {
            if showsBolt {
                ProfileV3GloveBoxArt.bolt.image
                    .profileV3Icon(Layout.pillIcon)
                    .foregroundStyle(Palette.pillIcon)
                    .accessibilityHidden(true)
            }
            Text(label)
                .typoGraphy(.T1InterBold11)
                .textCase(.uppercase)
                .foregroundStyle(Color(at: .pureWhite))
        }
        .padding(.leading, showsBolt ? Layout.pillIconLeading : Layout.pillInset)
        .padding(.trailing, Layout.pillInset)
        .frame(height: Layout.pillHeight)
        .background(Capsule().fill(ProfileV3Theme.GloveBox.pillGradient))
        .overlay { outline }
    }

    @ViewBuilder
    private var outline: some View {
        switch border {
        case .ink:
            Capsule().strokeBorder(Color(at: .pureBlack), lineWidth: ProfileV3Theme.Stroke.hairline)
        case .spectrum:
            Canvas { context, size in
                let box = CGRect(origin: .zero, size: size)
                let line = box.insetBy(dx: ProfileV3Theme.Stroke.hairline / 2, dy: ProfileV3Theme.Stroke.hairline / 2)
                context.stroke(
                    Path(roundedRect: line, cornerRadius: line.height / 2),
                    with: ProfileV3Theme.GloveBox.pillSpectrum.shading(in: box),
                    lineWidth: ProfileV3Theme.Stroke.hairline
                )
            }
            .accessibilityHidden(true)
        }
    }
}
