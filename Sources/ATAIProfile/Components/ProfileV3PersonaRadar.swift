import ATUIKit
import SwiftUI

struct ProfileV3PersonaRadar: View {
    let traits: [ProfileV3TravelPersona.Trait]
    let range: ClosedRange<Int>
    let score: (ProfileV3TravelPersona.Trait) -> Int
    var highlightedID: String?
    var coach: ProfileV3PersonaCoach?
    var canEdit: (ProfileV3TravelPersona.Trait) -> Bool = { _ in true }
    var onTap: (String) -> Void = { _ in }
    var onOpen: (String) -> Void = { _ in }
    var onDragStart: (String) -> Void = { _ in }
    var onDragEnd: (String, Int) -> Void = { _, _ in }
    var onAdjust: (String, Int) -> Void = { _, _ in }
    var onCoachTap: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasEntered = false
    @State private var drag: Drag?
    @GestureState private var isDragging = false

    private typealias Persona = ProfileV3Theme.Sizes.Persona
    private typealias Trait = ProfileV3TravelPersona.Trait
    private static let space = "profileV3.persona.radar"
    private static let accessibilityStep = 5

    private struct Drag: Equatable {
        let id: String
        let origin: CGFloat
        var radius: CGFloat
    }

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
                coachLayer(in: proxy.size, centre: centre)
                    .animation(ProfileV3Theme.Motion.hintAppear, value: visibleCoach)
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
        .onChange(of: isDragging) { _, isDragging in
            guard !isDragging, let drag else { return }
            self.drag = nil
            onDragEnd(drag.id, value(for: drag.radius))
        }
    }

    private var visibleCoach: ProfileV3PersonaCoach? {
        hasEntered && drag == nil ? coach : nil
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

    private func value(for radius: CGFloat) -> Int {
        let fraction = (radius - Persona.radarInnerRadius) / (Persona.radarRadius - Persona.radarInnerRadius)
        return range.lowerBound + Int((fraction * CGFloat(range.upperBound - range.lowerBound)).rounded())
    }

    private func displayRadius(_ trait: Trait) -> CGFloat {
        guard let drag, drag.id == trait.id else { return radius(for: score(trait)) }
        return drag.radius
    }

    private func displayScore(_ trait: Trait) -> Int {
        guard let drag, drag.id == trait.id else { return score(trait) }
        return value(for: drag.radius)
    }

    private func point(_ index: Int, radius: CGFloat, centre: CGPoint) -> CGPoint {
        let axis = axis(index)
        return CGPoint(x: centre.x + axis.dx * radius, y: centre.y + axis.dy * radius)
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
                let corner = point(index, radius: displayRadius(trait), centre: centre)
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

    private func label(_ trait: Trait, index: Int, centre: CGPoint) -> some View {
        let axis = axis(index)
        let horizontal: HorizontalAlignment = axis.dx > 0.2 ? .leading : (axis.dx < -0.2 ? .trailing : .center)
        let vertical: VerticalAlignment = axis.dy < -0.5 ? .bottom : (axis.dy > 0.5 ? .top : .center)
        let textAlignment: TextAlignment = horizontal == .leading ? .leading : (horizontal == .trailing ? .trailing : .center)
        return Color.clear
            .frame(width: 0, height: 0)
            .overlay(alignment: Alignment(horizontal: horizontal, vertical: vertical)) {
                VStack(alignment: horizontal, spacing: Persona.labelSpacing) {
                    Text(trait.name)
                        .typoGraphy(.B2InterMedium12)
                    Text("\(displayScore(trait))")
                        .typoGraphy(.B1InterMedium14)
                        .opacity(ProfileV3Theme.Opacity.personaScore)
                        .contentTransition(.numericText())
                }
                .foregroundStyle(ProfileV3Theme.Palette.personaLabel)
                .multilineTextAlignment(textAlignment)
                .frame(width: Persona.labelWidth, alignment: Alignment(horizontal: horizontal, vertical: .center))
                .fixedSize(horizontal: false, vertical: true)
                .contentShape(Rectangle())
                .onTapGesture { onTap(trait.id) }
                .opacity(hasEntered ? 1 : 0)
                .animation(labelEntrance(index), value: hasEntered)
                .accessibilityHidden(true)
            }
            .position(point(index, radius: Persona.radarRadius + Persona.labelGap, centre: centre))
    }

    private func handle(_ trait: Trait, index: Int, centre: CGPoint) -> some View {
        let isHighlighted = highlightedID == trait.id
        let isEditable = canEdit(trait)
        return ZStack {
            if isHighlighted {
                ProfileV3PersonaRipple()
                    .transition(.opacity)
            }
            knob(diameter: isHighlighted ? Persona.handleHighlighted : Persona.handle)
                .scaleEffect(hasEntered ? 1 : Persona.handleEntranceScale)
                .opacity(hasEntered ? 1 : 0)
        }
        .animation(ProfileV3Theme.Motion.personaKnob, value: isHighlighted)
        .frame(width: Persona.handleHitTarget, height: Persona.handleHitTarget)
        .contentShape(Circle())
        .gesture(handleGesture(trait, index: index, isEditable: isEditable))
        .accessibilityElement()
        .accessibilityLabel(trait.name)
        .accessibilityValue("\(displayScore(trait))")
        .accessibilityAddTraits(isHighlighted ? .isSelected : [])
        .modifier(ProfileV3PersonaAdjustable(isEnabled: isEditable) { direction in
            switch direction {
            case .increment: onAdjust(trait.id, Self.accessibilityStep)
            case .decrement: onAdjust(trait.id, -Self.accessibilityStep)
            @unknown default: break
            }
        })
        .accessibilityAction(.default) { onOpen(trait.id) }
        .position(point(index, radius: displayRadius(trait), centre: centre))
    }

    private func knob(diameter: CGFloat) -> some View {
        let rim = diameter + 2 * ProfileV3Theme.Stroke.hairline
        return ZStack {
            Circle()
                .fill(Color(at: .pureWhite))
                .frame(width: diameter, height: diameter)
            Circle()
                .strokeBorder(ProfileV3Theme.personaHandleRim, lineWidth: ProfileV3Theme.Stroke.hairline)
                .frame(width: rim, height: rim)
        }
        .shadow(
            color: ProfileV3Theme.Palette.personaHandleShadow,
            radius: ProfileV3Theme.Shadow.personaHandleRadius,
            y: ProfileV3Theme.Shadow.personaHandleY
        )
    }

    private func handleGesture(_ trait: Trait, index: Int, isEditable: Bool) -> AnyGesture<Void> {
        let tap = TapGesture().onEnded { onTap(trait.id) }
        guard isEditable else { return AnyGesture(tap) }
        let drag = DragGesture(minimumDistance: Persona.dragMinimumDistance, coordinateSpace: .named(Self.space))
            .updating($isDragging) { _, isDragging, _ in isDragging = true }
            .onChanged { value in move(trait, index: index, by: value.translation) }
        return AnyGesture(drag.exclusively(before: tap).map { _ in })
    }

    private func move(_ trait: Trait, index: Int, by translation: CGSize) {
        if let drag, drag.id != trait.id { return }
        let origin = drag?.origin ?? radius(for: score(trait))
        if drag == nil { onDragStart(trait.id) }
        let axis = axis(index)
        let along = origin + translation.width * axis.dx + translation.height * axis.dy
        drag = Drag(id: trait.id, origin: origin, radius: min(max(along, Persona.radarInnerRadius), Persona.radarRadius))
    }

    @ViewBuilder
    private func coachLayer(in size: CGSize, centre: CGPoint) -> some View {
        ZStack {
            if let coach = visibleCoach, let index = traits.firstIndex(where: { $0.id == coach.traitID }) {
                let knob = point(index, radius: displayRadius(traits[index]), centre: centre)
                let tip = CGPoint(x: knob.x, y: knob.y + Persona.Coach.tipGap)
                let edge = Persona.Coach.width / 2 + Persona.Coach.edgeInset
                let x = min(max(knob.x, edge), max(size.width - edge, edge))
                Color.clear
                    .frame(width: 0, height: 0)
                    .overlay(alignment: .top) {
                        ProfileV3PersonaCoachBubble(
                            text: coach.step == .drag ? ProfileV3Strings.personaCoachDrag : ProfileV3Strings.personaCoachTap,
                            step: coach.index,
                            steps: coach.steps.count,
                            pointerOffset: knob.x - x,
                            action: onCoachTap
                        )
                        .offset(x: x - knob.x)
                    }
                    .position(tip)
                    .transition(coachTransition(from: tip, in: size))
            }
        }
    }

    private func coachTransition(from tip: CGPoint, in size: CGSize) -> AnyTransition {
        guard !reduceMotion, size.width > 0, size.height > 0 else { return .opacity }
        let anchor = UnitPoint(x: tip.x / size.width, y: tip.y / size.height)
        return .scale(scale: Persona.Coach.enterScale, anchor: anchor).combined(with: .opacity)
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

#Preview("Persona radar · first-run tips") {
    let persona = ProfileV3PersonaFixtures.persona(ProfileV3PersonaStore(), profileID: nil)
    let coach = ProfileV3PersonaCoach(traits: persona.traits, isEditable: true)
    return ProfileV3PersonaRadar(
        traits: persona.traits,
        range: persona.range,
        score: \.score,
        highlightedID: coach?.traitID,
        coach: coach
    )
    .padding(ProfileV3Theme.Space.s30)
    .background(ProfileV3BoxGradientCard(gradient: ProfileV3Theme.personaCardGradient, cornerRadius: ProfileV3Theme.Sizes.Persona.cardRadius))
}
#endif
