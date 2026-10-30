import ATUIKit
import SwiftUI

private struct ProfileV3ShapeChrome<ChromeShape: Shape>: ViewModifier {
    let shape: ChromeShape
    let fill: AnyShapeStyle
    let border: Color
    let lineWidth: CGFloat
    let shadowRadius: CGFloat
    let shadowY: CGFloat

    private var shadowColor: Color {
        shadowRadius > 0 || shadowY != 0 ? ProfileV3Theme.Palette.shadow : .clear
    }

    func body(content: Content) -> some View {
        content
            .background(shape.fill(fill))
            .overlay(shape.stroke(border, lineWidth: lineWidth))
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
            .contentShape(shape)
    }
}

extension View {
    func profileV3Chrome(
        _ shape: some Shape,
        fill: some ShapeStyle = Color(at: .pureWhite),
        border: Color = ProfileV3Theme.Palette.saveButtonBorder,
        lineWidth: CGFloat = ProfileV3Theme.Stroke.thin,
        shadowRadius: CGFloat = ProfileV3Theme.Shadow.softRadius,
        shadowY: CGFloat = ProfileV3Theme.Shadow.softY
    ) -> some View {
        modifier(
            ProfileV3ShapeChrome(
                shape: shape,
                fill: AnyShapeStyle(fill),
                border: border,
                lineWidth: lineWidth,
                shadowRadius: shadowRadius,
                shadowY: shadowY
            )
        )
    }

    func profileV3SoftShadow() -> some View {
        shadow(color: ProfileV3Theme.Palette.shadow, radius: ProfileV3Theme.Shadow.softRadius, y: ProfileV3Theme.Shadow.softY)
    }

    func profileV3Outlined(_ shape: some InsettableShape, border: Color) -> some View {
        overlay(shape.strokeBorder(border, lineWidth: ProfileV3Theme.Stroke.hairline))
    }

    func profileV3Outlined(_ shape: some InsettableShape, border: Color, fill: some ShapeStyle) -> some View {
        background(shape.fill(fill))
            .overlay(shape.strokeBorder(border, lineWidth: ProfileV3Theme.Stroke.hairline))
    }

    func profileV3TileChrome(_ shape: some InsettableShape, border: Color) -> some View {
        background {
            shape
                .fill(Color(at: .pureWhite))
                .shadow(
                    color: ProfileV3Theme.Palette.shadow,
                    radius: ProfileV3Theme.Shadow.chipRadius,
                    y: ProfileV3Theme.Shadow.chipY
                )
        }
        .overlay(shape.strokeBorder(border, lineWidth: ProfileV3Theme.Stroke.hairline))
        .contentShape(shape)
    }

    func profileV3CapsuleChrome(
        fill: some ShapeStyle = Color(at: .pureWhite),
        border: Color = ProfileV3Theme.Palette.saveButtonBorder,
        lineWidth: CGFloat = ProfileV3Theme.Stroke.thin,
        shadowRadius: CGFloat = ProfileV3Theme.Shadow.softRadius,
        shadowY: CGFloat = ProfileV3Theme.Shadow.softY
    ) -> some View {
        profileV3Chrome(
            Capsule(),
            fill: fill,
            border: border,
            lineWidth: lineWidth,
            shadowRadius: shadowRadius,
            shadowY: shadowY
        )
    }
}

struct ProfileV3FrostedBackdrop: View {
    var tint = ProfileV3Theme.Palette.frostedBackdrop

    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay(tint)
            .ignoresSafeArea()
    }
}

#if DEBUG
#Preview("Capsule chrome") {
    VStack(spacing: ProfileV3Theme.Space.s20) {
        Text(ProfileV3Strings.continueTitle)
            .typoGraphy(.B1InterSemibold14)
            .frame(maxWidth: .infinity)
            .frame(height: ProfileV3Theme.Sizes.Save.buttonHeight)
            .profileV3CapsuleChrome()
        Text(ProfileV3Strings.back)
            .typoGraphy(.B1InterSemibold14)
            .foregroundStyle(Color(at: .pureWhite))
            .frame(maxWidth: .infinity)
            .frame(height: ProfileV3Theme.Sizes.Save.buttonHeight)
            .profileV3CapsuleChrome(fill: Color(at: .pureBlack))
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
