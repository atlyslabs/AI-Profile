import ATUIKit
import SwiftUI

struct ProfileV3InstagramPin {
    let origin: CGPoint
    let size: CGFloat
    let detail: CGFloat
    let isHighlighted: Bool
}

struct ProfileV3InstagramReel {
    struct Pose: Equatable {
        let position: CGPoint
        let rotation: Double
        let scale: Double
        let opacity: Double
    }

    let art: ProfileV3InstagramArt
    let center: CGPoint
    let size: CGSize
    let radius: CGFloat
    let tilt: Double
    let target: CGPoint
    private let scale: ProfileV3Keyframes
    private let travel: ProfileV3Keyframes
    private let opacity: ProfileV3Keyframes

    init(art: ProfileV3InstagramArt, center: CGPoint, size: CGSize, radius: CGFloat, tilt: Double, target: CGPoint, order: Int) {
        typealias Motion = ProfileV3Theme.Motion.InstagramIntro
        let start = Motion.reelStart + Motion.reelStagger * Double(order)
        let end = start + Motion.reelTravel
        self.art = art
        self.center = center
        self.size = size
        self.radius = radius
        self.tilt = tilt
        self.target = target
        scale = ProfileV3Keyframes(1)
            .hold(until: start)
            .to(Motion.reelShrinkScale, at: start + Motion.reelShrink, .easeOut)
            .to(Motion.reelEndScale, at: end, ProfileV3Theme.Motion.fastOutSlowIn)
        travel = ProfileV3Keyframes(0)
            .hold(until: start)
            .to(1, at: end, ProfileV3Theme.Motion.fastOutSlowIn)
        opacity = ProfileV3Keyframes(1)
            .hold(until: start + Motion.reelFade)
            .to(0, at: end, .easeOut)
    }

    var restingPose: Pose {
        Pose(position: center, rotation: tilt, scale: 1, opacity: 1)
    }

    func pose(at elapsed: TimeInterval) -> Pose {
        let progress = travel.value(at: elapsed)
        return Pose(
            position: CGPoint(
                x: center.x + (target.x - center.x) * progress,
                y: center.y + (target.y - center.y) * progress
            ),
            rotation: tilt * (1 - progress),
            scale: scale.value(at: elapsed),
            opacity: opacity.value(at: elapsed)
        )
    }
}

struct ProfileV3InstagramReelsScene: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()
    @State private var width = ProfileV3Theme.Canvas.width

    var body: some View {
        Group {
            if reduceMotion {
                ProfileV3InstagramReelsFrame(elapsed: nil)
            } else {
                TimelineView(.animation) { context in
                    ProfileV3InstagramReelsFrame(elapsed: context.date.timeIntervalSince(start))
                }
            }
        }
        .scaleEffect(ProfileV3Theme.Canvas.scale(for: width), anchor: .top)
        .frame(maxWidth: .infinity, alignment: .top)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct ProfileV3InstagramReelsFrame: View {
    let elapsed: TimeInterval?

    private typealias Layout = ProfileV3Theme.Sizes.InstagramConnect
    private typealias Motion = ProfileV3Theme.Motion.InstagramIntro

    var body: some View {
        ZStack(alignment: .topLeading) {
            map
                .opacity(elapsed.map(Motion.mapOpacity.value(at:)) ?? 1)
                .position(x: Layout.introMap.midX, y: Layout.introMap.midY)
            ForEach(Array(Layout.introReels.enumerated()), id: \.offset) { _, reel in
                let pose = elapsed.map(reel.pose(at:)) ?? reel.restingPose
                reel.art.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: reel.size.width, height: reel.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: reel.radius, style: .continuous))
                    .rotationEffect(.degrees(pose.rotation))
                    .scaleEffect(pose.scale)
                    .opacity(pose.opacity)
                    .position(pose.position)
            }
        }
        .frame(width: Layout.introScene.width, height: Layout.introScene.height, alignment: .topLeading)
    }

    private var map: some View {
        ZStack(alignment: .topLeading) {
            ProfileV3InstagramArt.map.image
                .resizable()
                .scaledToFill()
                .frame(width: Layout.introMap.width, height: Layout.introMap.height)
            ProfileV3InstagramPlaceCard(showsContent: false)
                .offset(x: Layout.introPlacePeekX, y: Layout.introPlace.y)
            ProfileV3InstagramPlaceCard()
                .scaleEffect(elapsed.map(Motion.placeScale.value(at:)) ?? 1)
                .opacity(elapsed.map(Motion.placeOpacity.value(at:)) ?? 1)
                .offset(x: Layout.introPlace.x, y: Layout.introPlace.y + (elapsed.map(Motion.placeRise.value(at:)) ?? 0))
            ForEach(Array(Layout.introPins.enumerated()), id: \.offset) { _, pin in
                ProfileV3InstagramPinView(pin: pin)
                    .offset(x: pin.origin.x, y: pin.origin.y)
            }
        }
        .frame(width: Layout.introMap.width, height: Layout.introMap.height, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: Layout.introMapRadius, style: .continuous))
    }
}

private struct ProfileV3InstagramPlaceCard: View {
    var showsContent = true

    private typealias Layout = ProfileV3Theme.Sizes.InstagramConnect

    var body: some View {
        HStack(spacing: Layout.introPlaceSpacing) {
            ProfileV3InstagramArt.dining.image
                .resizable()
                .scaledToFill()
                .frame(width: Layout.introPlaceThumb, height: Layout.introPlaceThumb)
                .clipShape(RoundedRectangle(cornerRadius: Layout.introPlaceThumbRadius, style: .continuous))
                .offset(x: Layout.introPlaceThumbNudge)
                .frame(width: Layout.introPlaceThumbSlot.width, height: Layout.introPlaceThumbSlot.height)
            VStack(alignment: .leading, spacing: Layout.introPlaceTextSpacing) {
                Text(ProfileV3Strings.instagramSamplePlace)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .pureBlack))
                Text(ProfileV3Strings.instagramSamplePlaceDetail)
                    .typoGraphy(.T1InterMedium11)
                    .foregroundStyle(ProfileV3Theme.Palette.instagramPlaceDetail)
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .opacity(showsContent ? 1 : 0)
        .padding(.leading, Layout.introPlaceLeading)
        .padding(.trailing, Layout.introPlaceTrailing)
        .padding(.vertical, Layout.introPlaceVertical)
        .background(Capsule().fill(Color(at: .pureWhite)))
        .overlay(Capsule().strokeBorder(ProfileV3Theme.Palette.instagramPlaceBorder, lineWidth: Layout.introPlaceBorder))
        .shadow(
            color: Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.instagramPlaceShadow),
            radius: ProfileV3Theme.Shadow.instagramPlaceRadius,
            y: ProfileV3Theme.Shadow.instagramPlaceY
        )
        .padding(Layout.introPlaceRing)
        .background(Capsule().fill(Color(at: .pureWhite).opacity(ProfileV3Theme.Opacity.instagramPlaceRing)))
        .frame(width: Layout.introPlaceWidth)
    }
}

private struct ProfileV3InstagramPinView: View {
    let pin: ProfileV3InstagramPin

    private typealias Layout = ProfileV3Theme.Sizes.InstagramConnect

    var body: some View {
        ProfileV3InstagramArt.pin.image
            .resizable()
            .frame(width: Layout.introPinGlyph * pin.detail, height: Layout.introPinGlyph * pin.detail)
            .frame(width: pin.size, height: pin.size)
            .background(Circle().fill(pin.isHighlighted ? ProfileV3Theme.instagramPinGradient : ProfileV3Theme.instagramPinMutedGradient))
            .overlay(Circle().strokeBorder(Color(at: .pureWhite), lineWidth: Layout.introPinBorder * pin.detail))
            .shadow(
                color: ProfileV3Theme.Palette.instagramPinShadow,
                radius: ProfileV3Theme.Shadow.instagramPinRadius * pin.detail,
                y: ProfileV3Theme.Shadow.instagramPinY * pin.detail
            )
    }
}

#if DEBUG
#Preview("Instagram reels") {
    ProfileV3InstagramReelsScene()
}
#endif
