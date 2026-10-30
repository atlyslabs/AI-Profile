import ATUIKit
import SwiftUI

struct ProfileV3DashedDivider: View {
    var body: some View {
        Color.clear
            .frame(height: ProfileV3Theme.Stroke.hairline)
            .atFormFieldBottomLine(isError: false, isFocused: false, style: .dashed, tintsOnFocus: false)
    }
}

struct ProfileV3Rule: Shape {
    var axis: Axis = .horizontal

    func path(in rect: CGRect) -> Path {
        Path { path in
            switch axis {
            case .horizontal:
                path.move(to: CGPoint(x: rect.minX, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            case .vertical:
                path.move(to: CGPoint(x: rect.midX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            }
        }
    }
}

struct ProfileV3DashedRule: View {
    let color: Color
    var dash = ProfileV3Theme.Stroke.dash
    var axis: Axis = .horizontal

    var body: some View {
        ProfileV3Rule(axis: axis)
            .stroke(color, style: StrokeStyle(lineWidth: ProfileV3Theme.Stroke.hairline, dash: dash))
            .frame(
                width: axis == .vertical ? ProfileV3Theme.Stroke.hairline : nil,
                height: axis == .horizontal ? ProfileV3Theme.Stroke.hairline : nil
            )
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Dashed divider") {
    ProfileV3DashedDivider()
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}
#endif
