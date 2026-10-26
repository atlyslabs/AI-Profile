import ATUIKit
import SwiftUI

struct ProfileV3SourceIconStack: View {
    enum Style {
        case badge
        case logo
    }

    let icons: [ProfileV3SourceIcon]
    var isOutlined = true
    var style: Style = .badge

    private typealias Logo = ProfileV3Theme.Sizes.SectionSources

    private var visibleIcons: [ProfileV3SourceIcon] {
        Array(icons.prefix(ProfileV3Theme.Counts.sourcesMaxIcons))
    }

    var body: some View {
        HStack(spacing: style == .logo ? Logo.logoOverlap : ProfileV3Theme.Sizes.sourcesIconOverlap) {
            ForEach(Array(visibleIcons.enumerated()), id: \.offset) { _, icon in
                switch style {
                case .badge: badge(icon)
                case .logo: logo(icon)
                }
            }
        }
    }

    private func badge(_ icon: ProfileV3SourceIcon) -> some View {
        glyph(icon)
            .frame(
                width: ProfileV3Theme.Sizes.sourcesGlyph.width,
                height: ProfileV3Theme.Sizes.sourcesGlyph.height
            )
            .frame(width: ProfileV3Theme.Icon.lg, height: ProfileV3Theme.Icon.lg)
            .background(Circle().fill(Color(at: .pureWhite)))
            .overlay(
                Circle().stroke(
                    isOutlined ? ProfileV3Theme.Palette.cardBorder : .clear,
                    lineWidth: ProfileV3Theme.Stroke.hairline
                )
            )
    }

    private func logo(_ icon: ProfileV3SourceIcon) -> some View {
        glyph(icon)
            .frame(width: Logo.logo, height: Logo.logo)
            .background(Color(at: .pureWhite))
            .clipShape(Circle())
    }

    @ViewBuilder
    private func glyph(_ icon: ProfileV3SourceIcon) -> some View {
        if let url = icon.url {
            ProfileV3RemoteImage(url: url, contentMode: .fit, placeholder: .clear)
        }
    }
}
