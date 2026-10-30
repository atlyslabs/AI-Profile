import ATUIKit
import SwiftUI

protocol ProfileV3SegmentItem: Identifiable where ID == String {
    var title: String { get }
}

struct ProfileV3SegmentTrack<Item: ProfileV3SegmentItem, Title: View, Pill: View>: View {
    let items: [Item]
    let selectedID: String?
    var spacing: CGFloat = 0
    let onSelect: (String) -> Void
    @ViewBuilder let title: (Item, Bool) -> Title
    @ViewBuilder let pill: () -> Pill

    @Namespace private var namespace

    private static var pillID: String { "pill" }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(items) { item in
                let isSelected = item.id == selectedID
                Button { onSelect(item.id) } label: {
                    title(item, isSelected)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background {
                            if isSelected {
                                pill()
                                    .matchedGeometryEffect(id: Self.pillID, in: namespace)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.profileV3Pressable(.selection))
                .accessibilityLabel(item.title)
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
    }
}

struct ProfileV3SegmentedControl: View {
    struct Segment: ProfileV3SegmentItem, Equatable {
        let id: String
        let title: String
    }

    let segments: [Segment]
    let selectedID: String?
    let onSelect: (String) -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.SegmentedControl

    var body: some View {
        ProfileV3SegmentTrack(items: segments, selectedID: selectedID, onSelect: onSelect) { segment, isSelected in
            label(segment.title, isSelected: isSelected)
        } pill: {
            selectedPill
        }
        .padding(Sizes.inset)
        .frame(height: Sizes.height)
        .background(Capsule().fill(ProfileV3Theme.Palette.background))
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(ProfileV3Theme.Palette.settingsCardBorder, lineWidth: ProfileV3Theme.Stroke.hairline)
        )
    }

    private var selectedPill: some View {
        Capsule()
            .fill(Color(at: .pureWhite))
            .profileV3Outlined(Capsule(), border: ProfileV3Theme.Palette.paleGrey)
            .profileV3SoftShadow()
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
