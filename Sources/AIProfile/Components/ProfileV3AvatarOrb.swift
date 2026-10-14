import ATUIKit
import SwiftUI

struct ProfileV3AvatarOrb: View {
    enum State {
        case active
        case locked
        case invite
    }

    var imageURL: URL?
    var size: CGFloat = ProfileV3Theme.Sizes.Agent.orb
    var state: State = .active

    private var ring: AnyShapeStyle {
        switch state {
        case .active: AnyShapeStyle(Color(at: .accentEmerald500))
        case .locked: AnyShapeStyle(Color(at: .neutralGrey300))
        case .invite: AnyShapeStyle(ProfileV3Theme.plusRingGradient)
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(at: .neutralGrey200), lineWidth: ProfileV3Theme.Stroke.hairline)
            Circle()
                .trim(from: ProfileV3Theme.Sizes.orbArc.lowerBound, to: ProfileV3Theme.Sizes.orbArc.upperBound)
                .stroke(ring, style: StrokeStyle(lineWidth: ProfileV3Theme.Stroke.hairline, lineCap: .round))
                .rotationEffect(.degrees(ProfileV3Theme.Rotation.avatarArc))
            Circle()
                .fill(Color(at: .pureWhite))
                .frame(
                    width: size * ProfileV3Theme.Sizes.orbInnerScale,
                    height: size * ProfileV3Theme.Sizes.orbInnerScale
                )
                .shadow(
                    color: ProfileV3Theme.Palette.shadow,
                    radius: ProfileV3Theme.Shadow.orbRadius,
                    y: ProfileV3Theme.Sizes.orbShadowY
                )
            avatar
                .frame(
                    width: size * ProfileV3Theme.Sizes.orbImageScale,
                    height: size * ProfileV3Theme.Sizes.orbImageScale
                )
                .clipShape(Circle())
                .grayscale(state == .locked ? 1 : 0)
        }
        .frame(width: size, height: size)
        .overlay(alignment: .bottomLeading) {
            if state == .invite {
                badge
            }
        }
    }

    private var avatar: some View {
        ProfileV3RemoteImage(url: imageURL, placeholder: Color(at: .neutralGrey200))
    }

    private var badge: some View {
        ATIcon.SwiftUIImage.add
            .profileV3Icon(ProfileV3Theme.Icon.xs)
            .foregroundStyle(Color(at: .pureBlack))
            .frame(width: ProfileV3Theme.Icon.md, height: ProfileV3Theme.Icon.md)
            .background(Circle().fill(Color(at: .pureWhite)))
            .offset(x: -ProfileV3Theme.Space.s4, y: ProfileV3Theme.Space.s4)
    }
}

#if DEBUG
#Preview("Avatar orbs") {
    HStack(spacing: ProfileV3Theme.Space.s24) {
        ProfileV3AvatarOrb(imageURL: ProfileV3PlaceholderArt.agentFlight.url, state: .locked)
        ProfileV3AvatarOrb(imageURL: ProfileV3PlaceholderArt.agentStay.url, state: .invite)
        ProfileV3AvatarOrb(
            imageURL: ProfileV3PlaceholderArt.agentMedical.url,
            size: ProfileV3Theme.Sizes.Agent.orbLarge
        )
        ProfileV3AvatarOrb()
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
