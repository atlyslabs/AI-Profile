import ATUIKit
import SwiftUI

struct ProfileV3PersonaRadar: View {
    let traits: [ProfileV3TravelPersona.Trait]
    let range: ClosedRange<Int>
    let score: (ProfileV3TravelPersona.Trait) -> Int
    var highlightedID: String?
    var isEditable = true
    var onTap: (String) -> Void = { _ in }
    var onDoubleTap: (String) -> Void = { _ in }
    var onDrag: (String, Int) -> Void = { _, _ in }
    var onAdjust: (String, Int) -> Void = { _, _ in }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasEntered = false

    private typealias Persona = ProfileV3Theme.Sizes.Persona
    private static let space = "profileV3.persona.radar"
    private static let accessibilityStep = 5

    var body: some View {
        GeometryReader { proxy in
            let centre = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            ZStack {
                grid(rings: Persona.ringsOverPolygon ..< Persona.ringCount, spokes: false, centre: centre)
                polygon(centre: centre)
                grid(rings: 0 ..< Persona.ringsOverPolygon, spokes: true, centre: centre)
                ForEach(Array(traits.enumerated()), id: \.element.id) { index, trait in
                    label(trait, index: index, centre: centre)
                }
                ForEach(Array(traits.enumerated()), id: \.element.id) { index, trait in
                    handle(trait, index: index, centre: centre)
                }
            }
            .coordinateSpace(.named(Self.space))
        }
        .frame(height: Persona.radarHeight)
        .onAppear {
            guard !hasEntered else { return }
            if reduceMotion {
                hasEntered = true
            } else {
                withAnimation(ProfileV3Theme.Motion.personaEntrance) { hasEntered = true }
            }
        }
    }

    private func axis(_ index: Int) -> CGVector {
        let angle = 2 * Double.pi * Double(index) / Double(max(traits.count, 1))
        return CGVector(dx: sin(angle), dy: -cos(angle))
    }

    private func radius(for value: Int) -> CGFloat {
        let span = CGFloat(range.upperBound - range.lowerBound)
        guard span > 0 else { return Persona.radarInnerRadius }
        let fraction = min(max(CGFloat(value - range.lowerBound) / span, 0), 1)
        return Persona.radarInnerRadius + (Persona.radarRadius - Persona.radarInnerRadius) * fraction
    }

    private func point(_ index: Int, radius: CGFloat, centre: CGPoint) -> CGPoint {
        let axis = axis(index)
        return CGPoint(x: centre.x + axis.dx * radius, y: centre.y + axis.dy * radius)
    }

    private func value(at location: CGPoint, index: Int, centre: CGPoint) -> Int {
        let axis = axis(index)
        let along = (location.x - centre.x) * axis.dx + (location.y - centre.y) * axis.dy
        let clamped = min(max(along, Persona.radarInnerRadius), Persona.radarRadius)
        let fraction = (clamped - Persona.radarInnerRadius) / (Persona.radarRadius - Persona.radarInnerRadius)
        return range.lowerBound + Int((fraction * CGFloat(range.upperBound - range.lowerBound)).rounded())
    }

    private func grid(rings: Range<Int>, spokes: Bool, centre: CGPoint) -> some View {
        Canvas { context, _ in
            guard traits.count > 2 else { return }
            for ring in rings {
                let fraction = CGFloat(ring) / CGFloat(Persona.ringCount - 1)
                let radius = Persona.radarInnerRadius + (Persona.radarRadius - Persona.radarInnerRadius) * fraction
                var path = Path()
                for index in traits.indices {
                    let corner = point(index, radius: radius, centre: centre)
                    index == 0 ? path.move(to: corner) : path.addLine(to: corner)
                }
                path.closeSubpath()
                context.stroke(
                    path,
                    with: .color(ProfileV3Theme.Palette.personaGrid.opacity(ProfileV3Theme.Opacity.personaRing)),
                    lineWidth: Persona.ringLineWidth
                )
            }
            guard spokes else { return }
            var lines = Path()
            for index in traits.indices {
                lines.move(to: centre)
                lines.addLine(to: point(index, radius: Persona.radarRadius, centre: centre))
            }
            context.stroke(
                lines,
                with: .color(ProfileV3Theme.Palette.personaGrid.opacity(ProfileV3Theme.Opacity.personaSpoke)),
                lineWidth: Persona.spokeLineWidth
            )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func polygon(centre: CGPoint) -> some View {
        Canvas { context, _ in
            guard traits.count > 2 else { return }
            var path = Path()
            for (index, trait) in traits.enumerated() {
                let corner = point(index, radius: radius(for: score(trait)), centre: centre)
                index == 0 ? path.move(to: corner) : path.addLine(to: corner)
            }
            path.closeSubpath()
            context.opacity = ProfileV3Theme.Opacity.personaRadarLayer * ProfileV3Theme.Opacity.personaRadarFill
            context.fill(path, with: ProfileV3Theme.personaRadarFill.shading(in: path.boundingRect))
        }
        .opacity(hasEntered ? 1 : 0)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func label(_ trait: ProfileV3TravelPersona.Trait, index: Int, centre: CGPoint) -> some View {
        let axis = axis(index)
        let horizontal: HorizontalAlignment = axis.dx > 0.2 ? .leading : (axis.dx < -0.2 ? .trailing : .center)
        let vertical: VerticalAlignment = axis.dy < -0.5 ? .bottom : (axis.dy > 0.5 ? .top : .center)
        let textAlignment: TextAlignment = horizontal == .leading ? .leading : (horizontal == .trailing ? .trailing : .center)
        let isHighlighted = highlightedID == trait.id
        return Color.clear
            .frame(width: 0, height: 0)
            .overlay(alignment: Alignment(horizontal: horizontal, vertical: vertical)) {
                VStack(alignment: horizontal, spacing: Persona.labelSpacing) {
                    Text(trait.name)
                        .typoGraphy(.B2InterMedium12)
                    Text("\(score(trait))")
                        .typoGraphy(.B1InterMedium14)
                        .opacity(isHighlighted ? 1 : ProfileV3Theme.Opacity.personaScore)
                        .contentTransition(.numericText())
                }
                .foregroundStyle(ProfileV3Theme.Palette.personaLabel)
                .multilineTextAlignment(textAlignment)
                .frame(width: Persona.labelWidth, alignment: Alignment(horizontal: horizontal, vertical: .center))
                .fixedSize(horizontal: false, vertical: true)
                .contentShape(Rectangle())
                .onTapGesture(count: 2) { onDoubleTap(trait.id) }
                .onTapGesture { onTap(trait.id) }
                .opacity(hasEntered ? 1 : 0)
                .animation(labelEntrance(index), value: hasEntered)
                .accessibilityHidden(true)
            }
            .position(point(index, radius: Persona.radarRadius + Persona.labelGap, centre: centre))
    }

    private func handle(_ trait: ProfileV3TravelPersona.Trait, index: Int, centre: CGPoint) -> some View {
        let isHighlighted = highlightedID == trait.id
        let value = score(trait)
        return ZStack {
            Circle()
                .fill(Color(at: .pureWhite))
                .frame(width: Persona.handle, height: Persona.handle)
            Circle()
                .strokeBorder(
                    isHighlighted ? AnyShapeStyle(Color(at: .neutralGrey800)) : AnyShapeStyle(ProfileV3Theme.personaHandleRim),
                    lineWidth: ProfileV3Theme.Stroke.hairline
                )
                .frame(width: Persona.handleWithRim, height: Persona.handleWithRim)
        }
        .shadow(
            color: ProfileV3Theme.Palette.personaHandleShadow,
            radius: ProfileV3Theme.Shadow.personaHandleRadius,
            y: ProfileV3Theme.Shadow.personaHandleY
        )
        .scaleEffect(isHighlighted ? Persona.handleHighlightScale : 1)
        .scaleEffect(hasEntered ? 1 : Persona.handleEntranceScale)
        .opacity(hasEntered ? 1 : 0)
        .animation(ProfileV3Theme.Motion.selection, value: isHighlighted)
        .frame(width: Persona.handleHitTarget, height: Persona.handleHitTarget)
        .contentShape(Circle())
        .gesture(handleGesture(trait, index: index, centre: centre))
        .accessibilityElement()
        .accessibilityLabel(trait.name)
        .accessibilityValue("\(value)")
        .accessibilityAddTraits(isHighlighted ? .isSelected : [])
        .modifier(ProfileV3PersonaAdjustable(isEnabled: isEditable) { direction in
            switch direction {
            case .increment: onAdjust(trait.id, Self.accessibilityStep)
            case .decrement: onAdjust(trait.id, -Self.accessibilityStep)
            @unknown default: break
            }
        })
        .accessibilityAction(.default) { onDoubleTap(trait.id) }
        .position(point(index, radius: radius(for: value), centre: centre))
    }

    private func handleGesture(_ trait: ProfileV3TravelPersona.Trait, index: Int, centre: CGPoint) -> AnyGesture<Void> {
        let taps = TapGesture(count: 2).onEnded { onDoubleTap(trait.id) }
            .exclusively(before: TapGesture().onEnded { onTap(trait.id) })
        guard isEditable else { return AnyGesture(taps.map { _ in }) }
        let drag = DragGesture(minimumDistance: Persona.dragMinimumDistance, coordinateSpace: .named(Self.space))
            .onChanged { drag in onDrag(trait.id, value(at: drag.location, index: index, centre: centre)) }
        return AnyGesture(drag.exclusively(before: taps).map { _ in })
    }

    private func labelEntrance(_ index: Int) -> Animation? {
        guard !reduceMotion else { return nil }
        return ProfileV3Theme.Motion.personaLabelEntrance
            .delay(ProfileV3Theme.Motion.personaLabelDelay + ProfileV3Theme.Motion.personaLabelStagger * Double(index))
    }
}

private struct ProfileV3PersonaAdjustable: ViewModifier {
    let isEnabled: Bool
    let adjust: (AccessibilityAdjustmentDirection) -> Void

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEnabled {
            content.accessibilityAdjustableAction(adjust)
        } else {
            content
        }
    }
}

#if DEBUG
#Preview("Persona radar") {
    let persona = ProfileV3PersonaFixtures.persona(ProfileV3PersonaStore(), profileID: nil)
    return ProfileV3PersonaRadar(traits: persona.traits, range: persona.range, score: \.score, highlightedID: "planning")
        .padding(ProfileV3Theme.Space.s30)
        .background(ProfileV3BoxGradientCard(gradient: ProfileV3Theme.personaCardGradient, cornerRadius: ProfileV3Theme.Sizes.Persona.cardRadius))
}
#endif
