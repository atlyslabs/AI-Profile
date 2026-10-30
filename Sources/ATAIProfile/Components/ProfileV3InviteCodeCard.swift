import ATUIKit
import SwiftUI

struct ProfileV3InviteCodeCard: View {
    let invite: ProfileV3InviteCode
    var width = ProfileV3Theme.Sizes.Invite.cardWidth

    private typealias Sizes = ProfileV3Theme.Sizes.Invite

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Sizes.cardRadius, style: .continuous)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(invite.spacedCode)
                .font(Font.Inter.get(size: Sizes.codeSize, weight: .semibold))
                .tracking(Sizes.codeTracking)
                .foregroundStyle(Color(at: .pureBlack))
                .lineLimit(1)
                .minimumScaleFactor(Sizes.codeMinScale)
                .accessibilityLabel(invite.code)
                .padding(.top, Sizes.codeTop)
            Text(ProfileV3Strings.yourInviteCode)
                .typoGraphy(.B2InterSemibold12)
                .foregroundStyle(ProfileV3Theme.Palette.inviteCaption)
                .padding(.top, Sizes.codeCaptionSpacing)
            Spacer(minLength: 0)
            footer
        }
        .frame(width: width, height: Sizes.cardHeight)
        .background(foil)
        .contentShape(shape)
    }

    private var footer: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(invite.remainingLabel)
                    .typoGraphy(.H7InterSemibold16)
                Text(ProfileV3Strings.invitesLeft)
                    .typoGraphy(.B2InterMedium12)
            }
            .foregroundStyle(Color(at: .pureBlack))
            .padding(.leading, Sizes.countLeading)
            .accessibilityElement(children: .combine)
            Spacer(minLength: 0)
            pips
                .padding(.trailing, Sizes.pipTrailing)
        }
        .padding(.bottom, Sizes.countBottom)
    }

    private var pips: some View {
        HStack(spacing: Sizes.pipSpacing) {
            ForEach(0 ..< invite.maxUses, id: \.self) { index in
                ProfileV3InvitePip(isUsed: index < invite.usedCount)
                    .accessibilityLabel(
                        index < invite.usedCount
                            ? ProfileV3Strings.inviteUsed(index + 1)
                            : ProfileV3Strings.inviteUnused(index + 1)
                    )
            }
        }
    }

    /// The supplied art is the whole card - rounded corners and drop shadow baked in - so the
    /// card draws no shape, border or shadow of its own. Its body measures 1320x788 inside a
    /// 1416x884 canvas, which is the margin the frame below restores at the design's size.
    private var foil: some View {
        ProfileV3InviteArt.codeCard.image
            .resizable()
            .frame(
                width: width * Sizes.cardArtWidthRatio,
                height: Sizes.cardHeight * Sizes.cardArtHeightRatio
            )
            .offset(
                x: -width * Sizes.cardArtInsetRatio.width,
                y: -Sizes.cardHeight * Sizes.cardArtInsetRatio.height
            )
            .frame(width: width, height: Sizes.cardHeight, alignment: .topLeading)
            .accessibilityHidden(true)
    }
}

private struct ProfileV3InvitePip: View {
    let isUsed: Bool

    private typealias Sizes = ProfileV3Theme.Sizes.Invite

    var body: some View {
        ZStack {
            if isUsed {
                Circle()
                    .fill(Color(at: .pureBlack))
                    .overlay(
                        Circle().strokeBorder(ProfileV3Theme.Palette.invitePipRing, lineWidth: Sizes.pipStroke)
                    )
                ATIcon.SwiftUIImage.check
                    .profileV3Icon(Sizes.pipCheck)
                    .foregroundStyle(Color(at: .pureWhite))
            } else {
                Circle().strokeBorder(
                    ProfileV3Theme.Palette.invitePipRing,
                    style: StrokeStyle(lineWidth: Sizes.pipStroke, dash: Sizes.pipDash)
                )
            }
        }
        .frame(width: Sizes.pip, height: Sizes.pip)
    }
}

#if DEBUG
#Preview("Invite code card") {
    VStack(spacing: ProfileV3Theme.Space.s20) {
        ProfileV3InviteCodeCard(invite: ProfileV3InviteCode(code: "047814", maxUses: 3, usedCount: 1))
        ProfileV3InviteCodeCard(invite: ProfileV3InviteCode(code: "047814", maxUses: 3, usedCount: 3))
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
