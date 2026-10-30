import ATUIKit
import SwiftUI

struct ProfileV3InkPill: View {
    enum Width {
        case fixed(CGFloat)
        case hugging(minimum: CGFloat)
        case full
    }

    let title: String
    var isLoading = false
    var width = Width.hugging(minimum: ProfileV3Theme.Sizes.InkPill.width)
    var typography: TypographyStyle = .B1InterSemibold14
    var fill = ProfileV3Theme.Palette.ink
    var shadowRadius: CGFloat?

    var body: some View {
        sized(label)
            .frame(height: ProfileV3Theme.Sizes.InkPill.height)
            .background(Capsule().fill(fill))
            .modifier(ProfileV3InkPillShadow(radius: shadowRadius))
            .contentShape(Capsule())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title)
    }

    private var label: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .tint(Color(at: .pureWhite))
            } else {
                Text(title)
                    .typoGraphy(typography)
                    .foregroundStyle(Color(at: .pureWhite))
            }
        }
    }

    @ViewBuilder
    private func sized(_ label: some View) -> some View {
        switch width {
        case .fixed(let width):
            label.frame(width: width)
        case .hugging(let minimum):
            label
                .padding(.horizontal, ProfileV3Theme.Sizes.InkPill.padding)
                .frame(minWidth: minimum)
        case .full:
            label.frame(maxWidth: .infinity)
        }
    }
}

private struct ProfileV3InkPillShadow: ViewModifier {
    let radius: CGFloat?

    func body(content: Content) -> some View {
        if let radius {
            content.shadow(color: ProfileV3Theme.Palette.shadow, radius: radius, y: ProfileV3Theme.Shadow.softY)
        } else {
            content
        }
    }
}

#if DEBUG
#Preview("Ink pill") {
    VStack(spacing: ProfileV3Theme.Space.s24) {
        ProfileV3InkPill(title: "Save", shadowRadius: ProfileV3Theme.Sizes.CustomRules.pillShadowRadius)
        ProfileV3InkPill(title: "Save", isLoading: true)
        ProfileV3InkPill(title: "Done", width: .full, typography: .B2InterSemibold12, fill: Color(at: .pureBlack))
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
