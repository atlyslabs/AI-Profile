import ATUIKit
import SwiftUI

private struct ProfileV3SurfaceCardModifier<CardShape: Shape>: ViewModifier {
    let shape: CardShape
    let fill: Color

    func body(content: Content) -> some View {
        content
            .background(shape.fill(fill))
            .clipShape(shape)
            .overlay(shape.stroke(ProfileV3Theme.Palette.cardBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
            .shadow(
                color: ProfileV3Theme.Palette.shadow,
                radius: ProfileV3Theme.Shadow.cardRadius,
                y: ProfileV3Theme.Shadow.cardY
            )
    }
}

extension View {
    func profileV3Card(
        cornerRadius: CGFloat = ProfileV3Theme.Sizes.cardCornerRadius,
        fill: Color = Color(at: .pureWhite)
    ) -> some View {
        profileV3Card(shape: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous), fill: fill)
    }

    func profileV3Card(shape: some Shape, fill: Color = Color(at: .pureWhite)) -> some View {
        modifier(ProfileV3SurfaceCardModifier(shape: shape, fill: fill))
    }
}

#if DEBUG
#Preview("Surface card") {
    VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s8) {
        Text("Flat 5% back on flights")
            .typoGraphy(.H7InterMedium16)
            .foregroundStyle(Color(at: .pureBlack))
        Text("Book flights in the app and get a flat 5% back in Atlys credits.")
            .typoGraphy(.B2InterMedium12)
            .foregroundStyle(Color(at: .neutralGrey400))
    }
    .padding(ProfileV3Theme.Sizes.cardContentPadding)
    .frame(maxWidth: .infinity, alignment: .leading)
    .profileV3Card()
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(ProfileV3Theme.Palette.background)
}
#endif
