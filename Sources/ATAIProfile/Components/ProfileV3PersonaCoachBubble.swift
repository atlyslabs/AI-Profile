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
                ProfileV3PointerBubbleShape(pointerOffset: pointerOffset)
                    .fill(ProfileV3Theme.personaCoachGradient)
                    .shadow(
                        color: ProfileV3Theme.Palette.appHintShadow,
                        radius: ProfileV3Theme.Sizes.AppAccess.hintShadowRadius,
                        y: ProfileV3Theme.Sizes.AppAccess.hintShadowY
                    )
            }
            .contentShape(ProfileV3PointerBubbleShape(pointerOffset: pointerOffset))
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

struct ProfileV3PointerBubbleShape: Shape {
    var pointer: CGFloat = ProfileV3Theme.Sizes.Persona.Coach.pointer
    var tipRun: CGFloat = ProfileV3Theme.Sizes.Persona.Coach.tipRun
    var pointerOffset: CGFloat = 0
    var radius: CGFloat = ProfileV3Theme.Sizes.Persona.Coach.radius

    private static let shoulder = CGSize(width: 3.5355, height: 1.4645)
    private static let tipControl = CGSize(width: 1.5829, height: 1.9526)

    func path(in rect: CGRect) -> Path {
        let top = rect.minY + pointer
        let shoulder = Self.shoulder
        let notch = shoulder.width * 2 + tipRun
        let tipY = -shoulder.height - tipRun
        let limit = max(rect.width / 2 - radius - notch, 0)
        let x = rect.midX + min(max(pointerOffset, -limit), limit)
        func point(_ dx: CGFloat, _ dy: CGFloat) -> CGPoint {
            CGPoint(x: x + dx, y: top + dy)
        }
        var path = Path()
        path.move(to: point(-notch, 0))
        path.addCurve(
            to: point(-notch + shoulder.width, -shoulder.height),
            control1: point(-notch + 1.326, 0),
            control2: point(-notch + 2.5978, -0.5268)
        )
        path.addLine(to: point(-shoulder.width, tipY))
        path.addCurve(
            to: point(shoulder.width, tipY),
            control1: point(-Self.tipControl.width, tipY - Self.tipControl.height),
            control2: point(Self.tipControl.width, tipY - Self.tipControl.height)
        )
        path.addLine(to: point(notch - shoulder.width, -shoulder.height))
        path.addCurve(to: point(notch, 0), control1: point(notch - 2.5978, -0.5268), control2: point(notch - 1.326, 0))
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: top),
            tangent2End: CGPoint(x: rect.maxX, y: rect.maxY),
            radius: radius
        )
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
            tangent2End: CGPoint(x: rect.minX, y: rect.maxY),
            radius: radius
        )
        path.addArc(
            tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
            tangent2End: CGPoint(x: rect.minX, y: top),
            radius: radius
        )
        path.addArc(
            tangent1End: CGPoint(x: rect.minX, y: top),
            tangent2End: CGPoint(x: rect.maxX, y: top),
            radius: radius
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
