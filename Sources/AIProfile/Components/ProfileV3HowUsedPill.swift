import ATUIKit
import SwiftUI

struct ProfileV3HowUsedPill: View {
    var avatarURL: URL?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfileV3Theme.Space.s4) {
                ProfileV3RemoteImage(url: avatarURL, placeholder: Color(at: .neutralGrey200))
                    .frame(width: ProfileV3Theme.Icon.md, height: ProfileV3Theme.Icon.md)
                    .clipShape(Circle())
                ProfileV3TwoToneTitle(
                    lead: ProfileV3Strings.howThisIsUsedLead,
                    emphasis: ProfileV3Strings.howThisIsUsedEmphasis,
                    style: .B2InterMedium12
                )
                ATIcon.SwiftUIImage.chevronRight
                    .profileV3Icon(ProfileV3Theme.Icon.md)
                    .foregroundStyle(Color(at: .pureBlack))
            }
            .padding(.leading, ProfileV3Theme.Space.s6)
            .padding(.trailing, ProfileV3Theme.Space.s4)
            .frame(height: ProfileV3Theme.Control.compact)
            .profileV3CapsuleChrome(
                border: .clear,
                lineWidth: 0,
                shadowRadius: ProfileV3Theme.Shadow.pillRadius,
                shadowY: ProfileV3Theme.Shadow.pillY
            )
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(ProfileV3Strings.howThisIsUsedLead + ProfileV3Strings.howThisIsUsedEmphasis)
    }
}

#if DEBUG
#Preview("How this is used pill") {
    ProfileV3HowUsedPill(avatarURL: ProfileV3PlaceholderArt.agentFlight.url) {}
        .padding(ProfileV3Theme.Space.s32)
        .background(Color(at: .pureWhite))
}
#endif
