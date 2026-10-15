import SwiftUI

struct ProfileV3DurationWheel<Value: Hashable>: View {
    let values: [Value]
    @Binding var selection: Value?
    let pitch: CGFloat
    let accessibilityTitle: String
    let label: (Value) -> String

    private typealias Sizes = ProfileV3Theme.Sizes.TripSheet

    private var selectedIndex: Int? {
        selection.flatMap { values.firstIndex(of: $0) }
    }

    var body: some View {
        ProfileV3CentredCarousel(
            itemWidth: pitch,
            height: Sizes.wheelHeight,
            spacing: 0,
            selection: $selection
        ) {
            ForEach(Array(values.enumerated()), id: \.element) { index, value in
                item(value, distance: selectedIndex.map { abs($0 - index) } ?? 0)
                    .id(value)
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
        .accessibilityElement()
        .accessibilityLabel(accessibilityTitle)
        .accessibilityValue(selection.map(label) ?? "")
        .accessibilityAdjustableAction { direction in
            guard let index = selectedIndex else { return }
            switch direction {
            case .increment: step(to: index + 1)
            case .decrement: step(to: index - 1)
            @unknown default: break
            }
        }
    }

    private func item(_ value: Value, distance: Int) -> some View {
        Text(label(value))
            .font(
                distance == 0
                    ? Font.Inter.get(size: Sizes.selectedWheelSize, weight: .bold)
                    : Font.Inter.get(size: ProfileV3Theme.Typography.tripWheelSize, weight: .medium)
            )
            .foregroundStyle(Color(at: .pureBlack).opacity(opacity(distance)))
            .lineLimit(1)
            .frame(width: pitch, height: Sizes.wheelHeight)
            .contentShape(Rectangle())
            .onTapGesture { withAnimation(ProfileV3Theme.Motion.selection) { selection = value } }
            .animation(ProfileV3Theme.Motion.selection, value: distance)
    }

    private func opacity(_ distance: Int) -> Double {
        switch distance {
        case 0: return 1
        case 1: return ProfileV3Theme.Opacity.tripWheelNear
        default: return ProfileV3Theme.Opacity.tripWheelFar
        }
    }

    private func step(to index: Int) {
        guard values.indices.contains(index) else { return }
        withAnimation(ProfileV3Theme.Motion.selection) { selection = values[index] }
    }
}

struct ProfileV3NotchedDivider: Shape {
    func path(in rect: CGRect) -> Path {
        let notch = ProfileV3Theme.Sizes.TripSheet.notchWidth / 2
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + notch, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + ProfileV3Theme.Sizes.TripSheet.notchDepth))
        path.addLine(to: CGPoint(x: rect.midX - notch, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        return path
    }
}
