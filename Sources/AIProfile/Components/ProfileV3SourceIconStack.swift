import ATUIKit
import SwiftUI

struct ProfileV3SourceIconStack: View {
    let icons: [ProfileV3SourceIcon]
    var isOutlined = true

    private var visibleIcons: [ProfileV3SourceIcon] {
        Array(icons.prefix(ProfileV3Theme.Counts.sourcesMaxIcons))
    }

    var body: some View {
        HStack(spacing: ProfileV3Theme.Sizes.sourcesIconOverlap) {
            ForEach(Array(visibleIcons.enumerated()), id: \.offset) { _, icon in
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
        }
    }

    @ViewBuilder
    private func glyph(_ icon: ProfileV3SourceIcon) -> some View {
        if let url = icon.url {
            ProfileV3RemoteImage(url: url, contentMode: .fit, placeholder: .clear)
        }
    }
}
