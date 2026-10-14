import ATUIKit
import SwiftUI

struct ProfileV3GlassOrb: View {
    let imageURL: URL?
    let size: CGFloat
    var isTilted = false

    private typealias Glass = ProfileV3Theme.Sizes.GlassOrb

    var body: some View {
        ProfileV3RemoteImage(url: imageURL, contentMode: .fill, placeholder: Color(at: .neutralGrey100))
            .frame(width: size, height: size)
            .overlay { innerShadow }
            .overlay { glint.rotationEffect(.degrees(isTilted ? Glass.tilt : 0)) }
            .clipShape(Circle())
            .shadow(
                color: ProfileV3Theme.Palette.glassOrbShadow,
                radius: ProfileV3Theme.Shadow.glassOrbRadius,
                y: ProfileV3Theme.Shadow.glassOrbY
            )
            .accessibilityHidden(true)
    }

    private var innerShadow: some View {
        Circle()
            .stroke(
                Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.glassInnerShadow),
                lineWidth: size * Glass.innerShadowWidth
            )
            .blur(radius: size * Glass.innerShadowBlur)
    }

    private var glint: some View {
        VStack(spacing: 0) {
            Ellipse()
                .fill(fade(from: .top))
                .frame(height: size * Glass.topGlintHeight)
            Spacer(minLength: 0)
            Ellipse()
                .fill(fade(from: .bottom))
                .frame(width: size * Glass.bottomGlintWidth, height: size * Glass.bottomGlintHeight)
        }
        .frame(
            width: size * Glass.glintWidth,
            height: size * (isTilted ? Glass.tiltedGlintHeight : Glass.glintHeight)
        )
        .opacity(isTilted ? ProfileV3Theme.Opacity.glassGlintTilted : ProfileV3Theme.Opacity.glassGlint)
        .blur(radius: size * Glass.glintBlur)
    }

    private func fade(from edge: VerticalEdge) -> LinearGradient {
        let start = edge == .top ? Glass.glintFadeStart : 1 - Glass.glintFadeStart
        let end = edge == .top ? Glass.glintFadeEnd : 1 - Glass.glintFadeEnd
        return LinearGradient(
            colors: [Color(at: .pureWhite), Color(at: .pureWhite).opacity(0)],
            startPoint: UnitPoint(x: 0.5, y: start),
            endPoint: UnitPoint(x: 0.5, y: end)
        )
    }
}

#if DEBUG
#Preview("Glass orbs") {
    HStack(spacing: ProfileV3Theme.Space.s20) {
        ProfileV3GlassOrb(imageURL: ProfileV3PlaceholderArt.agentPersonal.url, size: 50)
        ProfileV3GlassOrb(imageURL: ProfileV3PlaceholderArt.agentItinerary.url, size: 35, isTilted: true)
        ProfileV3GlassOrb(imageURL: ProfileV3AgentArt.howUsedOrb.url, size: 22, isTilted: true)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
