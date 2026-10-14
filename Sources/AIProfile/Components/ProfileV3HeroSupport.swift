import ATUIKit
import SwiftUI

enum ProfileV3HeroSpace {
    static let name = "ProfileV3Hub"
}

final class ProfileV3FrameBox {
    var rect: CGRect = .zero
}

extension View {
    func profileV3HeroFrame(_ box: ProfileV3FrameBox) -> some View {
        onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .named(ProfileV3HeroSpace.name))
        } action: { box.rect = $0 }
    }
}

struct ProfileV3HeroClip: Shape {
    var frame: CGRect
    var cornerRadius: CGFloat

    var animatableData: AnimatablePair<CGRect.AnimatableData, CGFloat> {
        get { AnimatablePair(frame.animatableData, cornerRadius) }
        set {
            frame.animatableData = newValue.first
            cornerRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        Path(roundedRect: frame, cornerRadius: cornerRadius, style: .continuous)
    }
}

struct ProfileV3HeroRect: View {
    let state: ProfileV3HeroState
    var fill: Color = Color(at: .pureWhite)
    var showsBorder = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: state.cornerRadius, style: .continuous)
        shape
            .fill(fill)
            .overlay(
                shape.stroke(
                    ProfileV3Theme.Palette.cardBorder,
                    lineWidth: showsBorder ? ProfileV3Theme.Stroke.hairline : 0
                )
            )
            .frame(width: state.frame.width, height: state.frame.height)
            .position(x: state.frame.midX, y: state.frame.midY)
    }
}

