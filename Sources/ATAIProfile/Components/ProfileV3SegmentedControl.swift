import ATUIKit
import SwiftUI

struct ProfileV3SegmentedControl: View {
    struct Segment: Identifiable, Equatable {
        let id: String
        let title: String
    }

    let segments: [Segment]
    let selectedID: String?
    let onSelect: (String) -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.SegmentedControl

    @Namespace private var pill

    var body: some View {
        HStack(spacing: 0) {
            ForEach(segments) { segment in
                let isSelected = segment.id == selectedID
                Button { onSelect(segment.id) } label: {
                    label(segment.title, isSelected: isSelected)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background {
                            if isSelected {
                                selectedPill
                                    .matchedGeometryEffect(id: Self.pillID, in: pill)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.profileV3Pressable(.selection))
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(Sizes.inset)
        .frame(height: Sizes.height)
        .background(Capsule().fill(ProfileV3Theme.Palette.background))
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(ProfileV3Theme.Palette.settingsCardBorder, lineWidth: ProfileV3Theme.Stroke.hairline)
        )
    }

    private static let pillID = "pill"

    private var selectedPill: some View {
        Capsule()
            .fill(Color(at: .pureWhite))
            .overlay(
                Capsule().strokeBorder(ProfileV3Theme.Palette.segmentSelectedBorder, lineWidth: ProfileV3Theme.Stroke.hairline)
            )
            .shadow(color: ProfileV3Theme.Palette.accessCardShadow, radius: Sizes.shadowRadius, y: Sizes.shadowY)
    }

    private func label(_ title: String, isSelected: Bool) -> some View {
        Text(title)
            .typoGraphy(isSelected ? TypographyStyle.B2InterSemibold12 : .B2InterMedium12)
            .foregroundStyle(Color(at: .pureBlack).opacity(isSelected ? 1 : ProfileV3Theme.Opacity.segmentIdle))
            .lineLimit(1)
            .minimumScaleFactor(Sizes.minimumScale)
            .padding(.horizontal, Sizes.segmentPadding)
    }
}

#if DEBUG
private struct ProfileV3SegmentedControlPreview: View {
    @State private var selectedID: String? = "on"

    var body: some View {
        ProfileV3SegmentedControl(
            segments: [.init(id: "on", title: "Yes"), .init(id: "ask", title: "Always ask")],
            selectedID: selectedID
        ) { id in
            withAnimation(ProfileV3Theme.Motion.selection) { selectedID = id }
        }
    }
}

#Preview("Segmented control") {
    ProfileV3SegmentedControlPreview()
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}
#endif
