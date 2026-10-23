import ATUIKit
import SwiftUI

struct ProfileV3PersonaCoachBubble: View {
    let text: String
    let step: Int
    let steps: Int
    var pointerOffset: CGFloat = 0
    let action: () -> Void

    private typealias Coach = ProfileV3Theme.Sizes.Persona.Coach

    var body: some View {
        Button(action: action) {
            VStack(spacing: Coach.dotsTop) {
                ZStack {
                    Text(text)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .pureWhite))
                        .multilineTextAlignment(.center)
                        .frame(width: Coach.textWidth)
                        .fixedSize(horizontal: false, vertical: true)
                        .id(text)
                        .transition(.opacity)
                }
                if steps > 1 {
                    dots
                }
            }
            .padding(.top, Coach.pointer + Coach.textTop)
            .padding(.bottom, steps > 1 ? Coach.bottom : Coach.textTop)
            .frame(width: Coach.width)
            .background {
                ProfileV3PersonaCoachShape(pointerOffset: pointerOffset)
                    .fill(ProfileV3Theme.personaCoachGradient)
                    .shadow(
                        color: ProfileV3Theme.Palette.appHintShadow,
                        radius: ProfileV3Theme.Sizes.AppAccess.hintShadowRadius,
                        y: ProfileV3Theme.Sizes.AppAccess.hintShadowY
                    )
            }
            .contentShape(ProfileV3PersonaCoachShape(pointerOffset: pointerOffset))
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(text)
    }

    private var dots: some View {
        HStack(spacing: Coach.dotSpacing) {
            ForEach(0 ..< steps, id: \.self) { index in
                Capsule()
                    .fill(Color(at: .pureWhite))
                    .frame(width: Coach.dot.width, height: Coach.dot.height)
                    .opacity(index == step ? 1 : ProfileV3Theme.Opacity.personaCoachDot)
            }
        }
        .accessibilityHidden(true)
    }
}

struct ProfileV3PersonaCoachShape: Shape {
    var pointerOffset: CGFloat = 0

    private typealias Coach = ProfileV3Theme.Sizes.Persona.Coach

    func path(in rect: CGRect) -> Path {
        let top = rect.minY + Coach.pointer
        let limit = max(rect.width / 2 - Coach.radius - Coach.notch, 0)
        let x = rect.midX + min(max(pointerOffset, -limit), limit)
        func point(_ dx: CGFloat, _ dy: CGFloat) -> CGPoint {
            CGPoint(x: x + dx, y: top + dy)
        }
        var path = Path()
        path.move(to: point(-Coach.notch, 0))
        path.addCurve(to: point(-5.5199, -1.4645), control1: point(-7.7294, 0), control2: point(-6.4576, -0.5268))
        path.addLine(to: point(-3.5355, -3.4489))
        path.addCurve(to: point(3.5355, -3.4489), control1: point(-1.5829, -5.4015), control2: point(1.5829, -5.4015))
        path.addLine(to: point(5.5199, -1.4645))
        path.addCurve(to: point(Coach.notch, 0), control1: point(6.4576, -0.5268), control2: point(7.7294, 0))
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: top),
            tangent2End: CGPoint(x: rect.maxX, y: rect.maxY),
            radius: Coach.radius
        )
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
            tangent2End: CGPoint(x: rect.minX, y: rect.maxY),
            radius: Coach.radius
        )
        path.addArc(
            tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
            tangent2End: CGPoint(x: rect.minX, y: top),
            radius: Coach.radius
        )
        path.addArc(
            tangent1End: CGPoint(x: rect.minX, y: top),
            tangent2End: CGPoint(x: rect.maxX, y: top),
            radius: Coach.radius
        )
        path.closeSubpath()
        return path
    }
}

#if DEBUG
#Preview("Persona coach") {
    VStack(spacing: ProfileV3Theme.Space.s24) {
        ProfileV3PersonaCoachBubble(text: ProfileV3Strings.personaCoachDrag, step: 0, steps: 2) {}
        ProfileV3PersonaCoachBubble(text: ProfileV3Strings.personaCoachTap, step: 1, steps: 2, pointerOffset: -30) {}
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
