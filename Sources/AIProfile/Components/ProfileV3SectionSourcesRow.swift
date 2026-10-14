import ATUIKit
import SwiftUI

struct ProfileV3SectionSourcesRow: View {
    let iconURL: URL?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfileV3Theme.Space.s8) {
                ProfileV3SourceIconStack(icons: [ProfileV3SourceIcon(url: iconURL)])
                ATIcon.SwiftUIImage.chevronRight
                    .profileV3Icon(ProfileV3Theme.Icon.xl)
                    .foregroundStyle(Color(at: .pureBlack))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(ProfileV3Strings.viewSources)
    }
}

#if DEBUG
#Preview("Section sources row") {
    ProfileV3SectionSourcesRow(iconURL: ProfileV3AgentFixtures.gmailSourceIcon) {}
        .padding(ProfileV3Theme.Space.s32)
        .background(Color(at: .pureWhite))
}
#endif
