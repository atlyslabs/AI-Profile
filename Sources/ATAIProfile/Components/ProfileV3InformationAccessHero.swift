import ATUIKit
import SwiftUI

struct ProfileV3InformationAccessHero: View {
    enum Glyph {
        case check
        case wordmark
    }

    var glyph: Glyph = .check

    private typealias Hero = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        ZStack(alignment: .topLeading) {
            branches
            branches.scaleEffect(x: -1, y: 1, anchor: .center)
            shield
                .frame(width: Hero.heroWidth, height: Hero.shield.height)
        }
        .frame(width: Hero.heroWidth, height: Hero.shield.height, alignment: .topLeading)
        .accessibilityHidden(true)
    }

    private var branches: some View {
        ZStack(alignment: .topLeading) {
            branch
                .offset(x: Hero.branchLeading, y: Hero.branchTop)
            branch
                .scaleEffect(x: 1, y: -1, anchor: .center)
                .offset(x: Hero.branchLeading, y: Hero.stemY)
            ProfileV3AccessStemShape()
                .stroke(ProfileV3Theme.accessStemGradient, lineWidth: Hero.lineWidth)
                .frame(width: Hero.stemWidth, height: Hero.lineWidth)
                .offset(x: Hero.stemLeading, y: Hero.stemY - Hero.lineWidth / 2)
        }
        .frame(width: Hero.heroWidth, height: Hero.shield.height, alignment: .topLeading)
    }

    private var branch: some View {
        ProfileV3AccessBranchShape()
            .stroke(ProfileV3Theme.accessBranchGradient, lineWidth: Hero.lineWidth)
            .frame(width: Hero.branch.width, height: Hero.branch.height)
    }

    private var shield: some View {
        ZStack {
            shieldShadow
            ProfileV3ShieldShape()
                .fill(Color(at: .pureWhite).opacity(ProfileV3Theme.Opacity.shieldFill))
            ProfileV3ShieldShape()
                .stroke(Color(at: .pureWhite), lineWidth: Hero.shieldRim)
                .blur(radius: Hero.shieldRimBlur)
                .clipShape(ProfileV3ShieldShape())
            glyphImage
                .frame(width: Hero.shield.width, height: Hero.shield.height, alignment: .topLeading)
        }
        .frame(width: Hero.shield.width, height: Hero.shield.height)
    }

    @ViewBuilder
    private var glyphImage: some View {
        switch glyph {
        case .check:
            ProfileV3ConnectorGlyph.shieldCheck.image
                .resizable()
                .scaledToFit()
                .frame(width: Hero.check.width, height: Hero.check.height)
                .offset(x: Hero.checkOrigin.x, y: Hero.checkOrigin.y)
        case .wordmark:
            ProfileV3ConnectorGlyph.atlysWordmark.image
                .resizable()
                .frame(width: Hero.wordmark.width, height: Hero.wordmark.height)
                .offset(x: Hero.wordmarkOrigin.x, y: Hero.wordmarkOrigin.y)
        }
    }

    private var shieldShadow: some View {
        ProfileV3ShieldShape()
            .fill(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.shieldShadow))
            .frame(width: Hero.shield.width, height: Hero.shield.height)
            .offset(y: Hero.shieldShadowY)
            .blur(radius: Hero.shieldShadowRadius)
            .padding(Hero.shieldShadowPadding)
            .mask {
                ZStack {
                    Rectangle()
                    ProfileV3ShieldShape()
                        .frame(width: Hero.shield.width, height: Hero.shield.height)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
            }
            .padding(-Hero.shieldShadowPadding)
            .allowsHitTesting(false)
    }
}

struct ProfileV3AccessGlow: View {
    var body: some View {
        Circle()
            .fill(ProfileV3Theme.accessGlowGradient)
            .opacity(ProfileV3Theme.Opacity.accessGlowFill)
            .frame(
                width: ProfileV3Theme.Sizes.InformationAccess.glow,
                height: ProfileV3Theme.Sizes.InformationAccess.glow
            )
            .blur(radius: ProfileV3Theme.Sizes.InformationAccess.glowBlur)
            .opacity(ProfileV3Theme.Opacity.accessGlow)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

struct ProfileV3ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 84
        let sy = rect.height / 105
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()
        path.move(to: point(42, 105))
        path.addCurve(to: point(11.878, 84.066), control1: point(29.837, 101.938), control2: point(19.797, 94.959))
        path.addCurve(to: point(0, 47.775), control1: point(3.959, 73.172), control2: point(0, 61.075))
        path.addLine(to: point(0, 15.75))
        path.addLine(to: point(42, 0))
        path.addLine(to: point(84, 15.75))
        path.addLine(to: point(84, 47.775))
        path.addCurve(to: point(72.122, 84.066), control1: point(84, 61.075), control2: point(80.041, 73.172))
        path.addCurve(to: point(42, 105), control1: point(64.203, 94.959), control2: point(54.162, 101.938))
        path.closeSubpath()
        return path
    }
}

struct ProfileV3AccessBranchShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 101
        let sy = rect.height / 26.5
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()
        path.move(to: point(101, 26.5))
        path.addLine(to: point(97.069, 26.5))
        path.addCurve(to: point(68.784, 14.784), control1: point(86.46, 26.5), control2: point(76.286, 22.286))
        path.addLine(to: point(65.716, 11.716))
        path.addCurve(to: point(37.432, 0), control1: point(58.214, 4.214), control2: point(48.04, 0))
        path.addLine(to: point(0, 0))
        return path
    }
}

struct ProfileV3AccessStemShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

#if DEBUG
#Preview("Information access hero") {
    ZStack {
        ProfileV3AccessGlow()
        ProfileV3InformationAccessHero()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(at: .pureWhite))
}
#endif
