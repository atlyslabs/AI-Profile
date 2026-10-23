import ATUIKit
import SwiftUI

struct ProfileV3PersonaRipple: View {
    struct Ring: Equatable {
        let diameter: CGFloat
        let opacity: Double
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()

    private typealias Persona = ProfileV3Theme.Sizes.Persona

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let elapsed = reduceMotion ? nil : context.date.timeIntervalSince(start)
            ZStack {
                ForEach(0 ..< Persona.rippleRings, id: \.self) { index in
                    let ring = Self.ring(index, at: elapsed)
                    Circle()
                        .strokeBorder(Color(at: .pureBlack), lineWidth: ProfileV3Theme.Stroke.hairline)
                        .frame(width: ring.diameter, height: ring.diameter)
                        .opacity(ring.opacity)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    static let keyframes = [
        Ring(diameter: Persona.rippleStart, opacity: 0),
        Ring(diameter: Persona.rippleInner, opacity: ProfileV3Theme.Opacity.personaRippleInner),
        Ring(diameter: Persona.rippleOuter, opacity: ProfileV3Theme.Opacity.personaRippleOuter),
        Ring(diameter: Persona.rippleEnd, opacity: 0)
    ]

    static func ring(_ index: Int, at elapsed: TimeInterval?) -> Ring {
        guard let elapsed else { return keyframes[min(index + 1, keyframes.count - 2)] }
        let period = ProfileV3Theme.Motion.personaRippleSeconds
        let local = elapsed - period * Double(index) / Double(Persona.rippleRings)
        guard local >= 0 else { return Ring(diameter: Persona.rippleStart, opacity: 0) }
        let progress = CGFloat(local.truncatingRemainder(dividingBy: period) / period)
        let diameter = Persona.rippleStart + (Persona.rippleEnd - Persona.rippleStart) * progress
        return Ring(diameter: diameter, opacity: opacity(at: diameter))
    }

    private static func opacity(at diameter: CGFloat) -> Double {
        guard let upper = keyframes.firstIndex(where: { $0.diameter >= diameter }), upper > 0 else {
            return keyframes[0].opacity
        }
        let from = keyframes[upper - 1]
        let to = keyframes[upper]
        let fraction = Double((diameter - from.diameter) / (to.diameter - from.diameter))
        return from.opacity + (to.opacity - from.opacity) * fraction
    }
}

#if DEBUG
#Preview("Persona ripple") {
    ZStack {
        ProfileV3PersonaRipple()
        Circle()
            .fill(Color(at: .pureWhite))
            .frame(width: ProfileV3Theme.Sizes.Persona.handleHighlighted, height: ProfileV3Theme.Sizes.Persona.handleHighlighted)
    }
    .padding(ProfileV3Theme.Space.s40)
    .background(Color(at: .neutralGrey100))
}
#endif
