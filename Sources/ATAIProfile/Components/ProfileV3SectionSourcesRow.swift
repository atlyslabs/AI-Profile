import ATUIKit
import SwiftUI

struct ProfileV3SectionSourcesRow: View {
    let source: ProfileV3SectionSource
    let action: () -> Void

    private typealias Row = ProfileV3Theme.Sizes.SectionSources

    private var caption: String? { Self.caption(for: source) }

    static func caption(for source: ProfileV3SectionSource) -> String? {
        source.count.map { ProfileV3Strings.sourcesCount($0, label: source.label) }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Row.chevronGap) {
                HStack(spacing: Row.captionGap) {
                    ProfileV3SourceIconStack(icons: source.icons, style: .logo)
                    if let caption {
                        ProfileV3SourcesCaption(text: caption)
                    }
                }
                ATIcon.SwiftUIImage.chevronRight
                    .profileV3Icon(Row.chevron)
                    .foregroundStyle(Color(at: .neutralGrey400))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(ProfileV3Strings.viewSources)
        .accessibilityValue(caption ?? "")
    }
}

#if DEBUG
#Preview("Section sources row") {
    VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s24) {
        ProfileV3SectionSourcesRow(source: ProfileV3AgentFixtures.flight.sections[0].source!) {}
        ProfileV3SectionSourcesRow(
            source: ProfileV3SectionSource(
                icons: [ProfileV3SourceIcon(url: ProfileV3AgentFixtures.gmailSourceIcon)],
                agentType: "flight",
                fieldKey: "airlines"
            )
        ) {}
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
