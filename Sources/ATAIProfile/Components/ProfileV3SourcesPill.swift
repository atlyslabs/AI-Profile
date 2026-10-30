import ATUIKit
import SwiftUI

struct ProfileV3SourcesPill: View {
    let icons: [ProfileV3SourceIcon]
    let count: Int
    var label: String?
    var action: (() -> Void)?

    private var caption: String { ProfileV3Strings.sourcesCount(count, label: label) }

    var body: some View {
        if let action {
            Button(action: action) { pill }
                .buttonStyle(.profileV3Pressable)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(caption)
                .accessibilityAddTraits(.isButton)
        } else {
            pill
                .accessibilityElement(children: .combine)
                .accessibilityLabel(caption)
        }
    }

    private var pill: some View {
        HStack(spacing: ProfileV3Theme.Space.s8) {
            ProfileV3SourceIconStack(icons: icons, isOutlined: false)
            HStack(spacing: ProfileV3Theme.Sizes.sourcesPillChevronGap) {
                ProfileV3SourcesCaption(text: caption)
                if action != nil {
                    ATIcon.SwiftUIImage.chevronRight
                        .profileV3Icon(ProfileV3Theme.Sizes.sourcesPillChevron)
                        .foregroundStyle(Color(at: .neutralGrey500))
                }
            }
        }
        .padding(.leading, ProfileV3Theme.Space.s6)
        .padding(.trailing, action == nil ? ProfileV3Theme.Space.s10 : ProfileV3Theme.Sizes.sourcesPillChevronGap)
        .frame(height: ProfileV3Theme.Sizes.sourcesPillHeight)
        .profileV3CapsuleChrome(border: .clear, lineWidth: 0)
    }
}

struct ProfileV3SourcesCaption: View {
    let text: String

    var body: some View {
        Text(text)
            .typoGraphy(.B2InterSemibold12)
            .foregroundStyle(Color(at: .neutralGrey400))
    }
}

#if DEBUG
#Preview("Sources pill") {
    ProfileV3SourcesPill(icons: ProfileV3AgentFixtures.sources.icons, count: 3)
        .padding(ProfileV3Theme.Space.s32)
        .background(Color(at: .pureWhite))
}
#endif
