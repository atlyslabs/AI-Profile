import ATUIKit
import SwiftUI

struct ProfileV3InviteCodeView: View {
    @ObservedObject var model: ProfileV3InviteSettingsModel
    let onBack: () -> Void

    @State private var width = ProfileV3Theme.Canvas.width

    private typealias Sizes = ProfileV3Theme.Sizes.Invite

    private var cardWidth: CGFloat {
        Sizes.cardWidth * ProfileV3Theme.Canvas.scale(for: width)
    }

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetChrome(
                icon: ATIcon.SwiftUIImage.drafts,
                title: ProfileV3Strings.inviteCode,
                onBack: onBack
            )
            if let invite = model.invite {
                loaded(invite)
                    .transition(.opacity)
            } else {
                ProfileV3LoadStateView(phase: model.phase, retry: model.load)
                    .frame(height: Sizes.cardHeight)
                    .padding(.top, Sizes.cardTop)
                    .padding(.bottom, Sizes.ctaTop)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(at: .pureWhite))
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .onDisappear(perform: model.cancelReads)
    }

    private func loaded(_ invite: ProfileV3InviteCode) -> some View {
        VStack(spacing: 0) {
            Text(ProfileV3Strings.shareWithFriends(invite.maxUses))
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .neutralGrey400))
                .multilineTextAlignment(.center)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, Sizes.subtitleTop)
            ProfileV3InviteCodeCard(invite: invite, width: cardWidth)
                .padding(.top, Sizes.cardTop)
            shareButton(invite)
        }
    }

    private func shareButton(_ invite: ProfileV3InviteCode) -> some View {
        Button(action: model.share) {
            Text(ProfileV3Strings.shareInviteCodeLink)
                .typoGraphy(.B1InterSemibold14)
                .foregroundStyle(Color(at: .pureWhite))
                .frame(maxWidth: .infinity)
                .frame(height: ProfileV3Theme.Sizes.Save.buttonHeight)
                .profileV3CapsuleChrome(fill: Color(at: .pureBlack))
        }
        .buttonStyle(.profileV3Pressable(.impact(weight: .medium)))
        .disabled(invite.remainingUses == 0)
        .opacity(invite.remainingUses == 0 ? ProfileV3Theme.Opacity.disabled : 1)
        .profileV3CTABar(top: Sizes.ctaTop)
    }
}

#if DEBUG
#Preview("Invite code") {
    let model = ProfileV3InviteSettingsModel(host: ProfileV3PreviewInviteHost())
    return ProfileV3InviteCodeView(model: model, onBack: {})
        .background(Color(at: .pureWhite))
        .task { model.load() }
}
#endif
