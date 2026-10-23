import ATUIKit
import SwiftUI

struct ProfileV3GloveBoxCabinet: View {
    let title: String
    var status: ProfileV3GloveBoxIntro.Status?
    var statusLabel = ""
    var scale: CGFloat = 1

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.profileV3PausesAnimations) private var isPaused

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette
    private typealias Motion = ProfileV3Theme.GloveBox.Motion

    var body: some View {
        ZStack(alignment: .topLeading) {
            box
                .offset(x: Layout.box.minX, y: Layout.box.minY)
            stand
        }
        .frame(width: Layout.cabinet.width, height: Layout.cabinet.height, alignment: .topLeading)
        .scaleEffect(scale, anchor: .topLeading)
        .frame(width: Layout.cabinet.width * scale, height: Layout.cabinet.height * scale, alignment: .topLeading)
        .allowsHitTesting(false)
        .accessibilityElement(children: .combine)
    }

    private var contentShift: CGFloat {
        status == nil ? 0 : Layout.introContentShift
    }

    private var box: some View {
        let shape = RoundedRectangle(cornerRadius: Layout.boxRadius, style: .continuous)
        return ZStack(alignment: .topLeading) {
            Canvas { context, _ in drawBoxBack(in: &context) }
                .accessibilityHidden(true)
            glow
            Canvas { context, _ in drawDials(in: &context) }
                .accessibilityHidden(true)
            label
            pill
        }
        .frame(width: Layout.box.width, height: Layout.box.height, alignment: .topLeading)
        .clipShape(shape)
        .overlay(shape.strokeBorder(Palette.boxBorder, lineWidth: Layout.boxBorder))
    }

    private var label: some View {
        Text(title)
            .typoGraphy(.T2InterBold12)
            .textCase(.uppercase)
            .foregroundStyle(Color(at: .pureBlack))
            .frame(width: Layout.box.width)
            .offset(y: Layout.labelTop + (status == nil ? 0 : Layout.introLabelShift))
    }

    @ViewBuilder
    private var pill: some View {
        if let status, !statusLabel.isEmpty {
            HStack(spacing: Layout.pillSpacing) {
                if status == .locked {
                    ProfileV3GloveBoxArt.bolt.image
                        .profileV3Icon(Layout.pillIcon)
                        .foregroundStyle(Palette.pillIcon)
                        .accessibilityHidden(true)
                }
                Text(statusLabel)
                    .typoGraphy(.T1InterBold11)
                    .textCase(.uppercase)
                    .foregroundStyle(Color(at: .pureWhite))
            }
            .padding(.leading, status == .locked ? Layout.pillIconLeading : Layout.pillInset)
            .padding(.trailing, Layout.pillInset)
            .frame(height: Layout.pillHeight)
            .background(Capsule().fill(ProfileV3Theme.GloveBox.pillGradient))
            .overlay(Capsule().strokeBorder(Color(at: .pureBlack), lineWidth: ProfileV3Theme.Stroke.hairline))
            .frame(width: Layout.box.width)
            .offset(y: Layout.pillTop)
        }
    }

    @ViewBuilder
    private var glow: some View {
        switch status {
        case .locked:
            glowShape(radius: Motion.glowRadius.start, color: Palette.lockedGlow)
        case .warmingUp:
            TimelineView(.profileV3Ambient(paused: reduceMotion || isPaused)) { timeline in
                glowShape(radius: glowRadius(at: timeline.date), color: Palette.warmingGlow)
            }
        case nil:
            EmptyView()
        }
    }

    private func glowRadius(at date: Date) -> Double {
        guard !reduceMotion else { return Motion.glowRadius.start }
        let phase = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: Motion.glowLoop)
        return Motion.glowRadius.value(at: phase)
    }

    private func glowShape(radius: Double, color: Color) -> some View {
        ProfileV3GloveBoxArt.glow.image
            .resizable()
            .frame(width: Layout.glow.width, height: Layout.glow.height)
            .foregroundStyle(color)
            .blur(radius: radius * Layout.glowBlurScale)
            .offset(x: Layout.glow.minX, y: Layout.glow.minY)
            .accessibilityHidden(true)
    }

    private var stand: some View {
        let fade = status == nil ? Layout.homeFade : Layout.introFade
        return ZStack(alignment: .topLeading) {
            Canvas { context, _ in drawStand(in: &context) }
            LinearGradient(
                stops: status == nil ? ProfileV3Theme.GloveBox.homeFadeStops : ProfileV3Theme.GloveBox.introFadeStops,
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: fade.width, height: fade.height)
            .offset(x: fade.minX, y: fade.minY)
        }
        .frame(width: Layout.cabinet.width, height: Layout.cabinet.height, alignment: .topLeading)
        .clipped()
        .accessibilityHidden(true)
    }

    private func drawBoxBack(in context: inout GraphicsContext) {
        let inner = CGRect(origin: .zero, size: Layout.box.size).insetBy(dx: Layout.boxBorder, dy: Layout.boxBorder)
        context.fill(Path(CGRect(origin: .zero, size: Layout.box.size)), with: .color(Color(at: .pureWhite)))

        let sheen = CGRect(
            x: inner.midX - Layout.boxSheen.width / 2,
            y: inner.minY,
            width: Layout.boxSheen.width,
            height: Layout.boxSheen.height
        )
        var sheenContext = context
        sheenContext.opacity = Palette.boxSheenOpacity
        sheenContext.fill(Path(sheen), with: verticalGradient([Palette.boxSheen, Color(at: .pureWhite)], in: sheen))

        var sideContext = context
        sideContext.opacity = Palette.boxSideOpacity
        for direction in [-1.0, 1.0] {
            let side = CGRect(
                x: inner.midX + direction * Layout.boxSideOffset - Layout.boxSide.width / 2,
                y: inner.minY,
                width: Layout.boxSide.width,
                height: Layout.boxSide.height
            )
            sideContext.fill(Path(side), with: verticalGradient([Palette.boxSide, Color(at: .pureWhite)], in: side))
        }

        let bevelLeft = inner.midX - Layout.bevel.width / 2
        var bevel = Path()
        bevel.move(to: CGPoint(x: bevelLeft, y: inner.minY))
        bevel.addLine(to: CGPoint(x: bevelLeft + Layout.bevel.width, y: inner.minY))
        bevel.addLine(to: CGPoint(x: bevelLeft + Layout.bevel.width - Layout.bevelInset, y: inner.minY + Layout.bevel.height))
        bevel.addLine(to: CGPoint(x: bevelLeft + Layout.bevelInset, y: inner.minY + Layout.bevel.height))
        bevel.closeSubpath()
        context.fill(bevel, with: .color(Palette.boxSide))

        let shine = CGRect(
            x: -Layout.shine.width / 2,
            y: -Layout.shine.height / 2,
            width: Layout.shine.width,
            height: Layout.shine.height
        )
        let slant = CGAffineTransform(a: 1, b: 0, c: tan(Layout.shineSkew.radians), d: 1, tx: 0, ty: 0)
            .concatenating(CGAffineTransform(scaleX: 1, y: Layout.shineScaleY))
            .concatenating(CGAffineTransform(rotationAngle: Layout.shineAngle.radians))
        for (centre, opacity) in zip(Layout.shineCentres, Palette.shineOpacities) {
            var shineContext = context
            shineContext.blendMode = .plusLighter
            shineContext.opacity = opacity
            shineContext.addFilter(.blur(radius: Layout.shineBlur))
            shineContext.translateBy(x: inner.minX + centre.x, y: inner.minY + centre.y)
            shineContext.concatenate(slant)
            shineContext.fill(Path(shine), with: .color(Color(at: .pureWhite)))
        }
    }

    private func drawDials(in context: inout GraphicsContext) {
        let ringCentre = CGPoint(x: Layout.box.width / 2, y: Layout.ringCentreY + contentShift)
        for ring in Layout.rings {
            let bounds = CGRect(
                x: ringCentre.x - ring.diameter / 2,
                y: ringCentre.y - ring.diameter / 2,
                width: ring.diameter,
                height: ring.diameter
            )
            var ringContext = context
            ringContext.opacity = ring.opacity
            ringContext.stroke(
                Path(ellipseIn: bounds.insetBy(dx: Layout.ringStroke / 2, dy: Layout.ringStroke / 2)),
                with: .linearGradient(
                    ProfileV3Theme.GloveBox.ringGradient,
                    startPoint: CGPoint(x: bounds.midX, y: bounds.minY),
                    endPoint: CGPoint(x: bounds.midX, y: bounds.maxY)
                ),
                lineWidth: Layout.ringStroke
            )
        }

        let icons = [ATIcon.SwiftUIImage.mail, ATIcon.SwiftUIImage.call, ATIcon.SwiftUIImage.creditCard]
        for (index, icon) in icons.enumerated() {
            let centre = CGPoint(
                x: Layout.box.width / 2 + CGFloat(index - 1) * (Layout.dial + Layout.dialSpacing),
                y: Layout.dialCentreY + contentShift
            )
            let disc = CGRect(x: centre.x - Layout.dial / 2, y: centre.y - Layout.dial / 2, width: Layout.dial, height: Layout.dial)
            let shadow = disc.offsetBy(dx: 0, dy: Layout.dialShadowDrop)
            context.fill(
                Path(ellipseIn: shadow),
                with: .linearGradient(
                    Gradient(colors: [Palette.dialLight, Palette.dialShadow]),
                    startPoint: CGPoint(x: shadow.minX, y: shadow.midY),
                    endPoint: CGPoint(x: shadow.maxX, y: shadow.midY)
                )
            )
            context.fill(Path(ellipseIn: disc), with: verticalGradient([Palette.dialLight, Palette.dialBase], in: disc))
            for step in 0..<Layout.dialDotCount {
                let angle = Double(step) / Double(Layout.dialDotCount) * 2 * .pi
                let dot = CGPoint(
                    x: centre.x + Layout.dialDotRadius * sin(angle),
                    y: centre.y - Layout.dialDotRadius * cos(angle)
                )
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: dot.x - Layout.dialDot / 2,
                        y: dot.y - Layout.dialDot / 2,
                        width: Layout.dialDot,
                        height: Layout.dialDot
                    )),
                    with: .color(Palette.dialDot)
                )
            }
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - Layout.dialFace / 2,
                    y: centre.y - Layout.dialFace / 2,
                    width: Layout.dialFace,
                    height: Layout.dialFace
                )),
                with: .color(Palette.dialFace)
            )
            var glyph = context.resolve(icon.renderingMode(.template))
            glyph.shading = .color(Palette.dialIcon)
            context.draw(glyph, in: CGRect(
                x: centre.x - Layout.dialIcon / 2,
                y: centre.y - Layout.dialIcon / 2,
                width: Layout.dialIcon,
                height: Layout.dialIcon
            ))
        }
    }

    private func drawStand(in context: inout GraphicsContext) {
        let shelf = Layout.shelf
        context.fill(
            Path(shelf),
            with: .linearGradient(
                ProfileV3Theme.GloveBox.shelfGradient,
                startPoint: Layout.shelfGradientStart,
                endPoint: Layout.shelfGradientEnd
            )
        )
        context.fill(Path(Layout.legs), with: verticalGradient([Palette.shelfTop, Color(at: .pureWhite)], in: Layout.legs))
        context.fill(
            Path(Layout.legsInner),
            with: verticalGradient([Palette.legsInner, Palette.legsInner.opacity(0)], in: Layout.legsInner)
        )
        context.fill(Path(Layout.shelfLip), with: .color(Color(at: .pureWhite)))
        context.fill(Path(Layout.shelfSeam), with: .color(Palette.shelfSeam))

        var shadowContext = context
        shadowContext.opacity = Palette.legShadowOpacity
        for shadow in Layout.legShadows {
            shadowContext.fill(Path(shadow), with: verticalGradient([Palette.legShadow, Palette.legShadowFade], in: shadow))
        }

        var highlightContext = context
        highlightContext.opacity = Palette.shelfHighlightOpacity
        for highlight in Layout.shelfHighlights {
            highlightContext.fill(Path(highlight), with: .color(Color(at: .pureWhite)))
        }

        var edgeContext = context
        edgeContext.opacity = Palette.legEdgeOpacity
        for edge in Layout.legEdges {
            edgeContext.fill(Path(edge), with: verticalGradient([Palette.legShadow, Palette.legShadowFade], in: edge))
        }
    }

    private func verticalGradient(_ colors: [Color], in rect: CGRect) -> GraphicsContext.Shading {
        .linearGradient(
            Gradient(colors: colors),
            startPoint: CGPoint(x: rect.midX, y: rect.minY),
            endPoint: CGPoint(x: rect.midX, y: rect.maxY)
        )
    }
}

#if DEBUG
#Preview("Glove box cabinet") {
    ScrollView {
        VStack(spacing: ProfileV3Theme.Space.s32) {
            ProfileV3GloveBoxCabinet(title: "Glove box", status: .locked, statusLabel: "Activate", scale: 0.9)
            ProfileV3GloveBoxCabinet(title: "Glove box", status: .warmingUp, statusLabel: "Warming up", scale: 0.9)
            ProfileV3GloveBoxCabinet(title: "Glove box", scale: 0.9)
        }
    }
    .background(Color(at: .pureWhite))
}
#endif
