import ATUIKit
import Observation
import SwiftUI

private enum ProfileV3ScrollSpace {
    static let name = "ProfileV3Scroll"
}

private struct ProfileV3ScrollOffsetReader: ViewModifier {
    @Binding var offset: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y + geometry.contentInsets.top
                } action: { _, value in
                    offset = value
                }
        } else {
            content
                .coordinateSpace(.named(ProfileV3ScrollSpace.name))
        }
    }
}

private struct ProfileV3ScrollOffsetAnchor: ViewModifier {
    @Binding var offset: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
        } else {
            content
                .background(alignment: .top) {
                    Color.clear
                        .frame(height: 0)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            -proxy.frame(in: .named(ProfileV3ScrollSpace.name)).minY
                        } action: { value in
                            offset = value
                        }
                }
        }
    }
}

extension View {
    func profileV3ScrollOffset(_ offset: Binding<CGFloat>) -> some View {
        modifier(ProfileV3ScrollOffsetReader(offset: offset))
    }

    func profileV3ScrollOffsetAnchor(_ offset: Binding<CGFloat>) -> some View {
        modifier(ProfileV3ScrollOffsetAnchor(offset: offset))
    }

    func profileV3HeaderFade(
        _ pin: ProfileV3HeaderPin,
        gap: CGFloat = ProfileV3Theme.Sizes.headerFadeGap,
        color: Color = Color(at: .pureWhite)
    ) -> some View {
        profileV3ScrollOffset(pin.offsetBinding)
            .overlay(alignment: .top) { ProfileV3HeaderFade(pin: pin, gap: gap, color: color) }
    }

    func profileV3HeaderFadeAnchor(_ pin: ProfileV3HeaderPin) -> some View {
        profileV3ScrollOffsetAnchor(pin.offsetBinding)
    }
}

struct ProfileV3HeaderFade: View {
    let pin: ProfileV3HeaderPin
    var gap: CGFloat = 0
    var color = Color(at: .pureWhite)

    var body: some View {
        ProfileV3FadeBand(solid: gap, color: color)
            .opacity(pin.progress)
    }
}

struct ProfileV3FadeBand: View {
    var solid: CGFloat = 0
    var fade: CGFloat = ProfileV3Theme.Sizes.SettingsPage.headerFade
    var edge: VerticalEdge = .top
    var color = Color(at: .pureWhite)
    var blocksTouches = false

    var body: some View {
        VStack(spacing: 0) {
            if edge == .top {
                solidBand
            }
            LinearGradient(
                colors: edge == .top ? [color, color.opacity(0)] : [color.opacity(0), color],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: fade)
            .allowsHitTesting(false)
            if edge == .bottom {
                solidBand
            }
        }
    }

    private var solidBand: some View {
        color
            .frame(height: solid)
            .allowsHitTesting(blocksTouches)
    }
}

@MainActor
@Observable
final class ProfileV3HeaderPin {
    @ObservationIgnored var offset: CGFloat = 0 {
        didSet { update() }
    }

    private(set) var progress: CGFloat = 0

    var offsetBinding: Binding<CGFloat> {
        Binding(get: { self.offset }, set: { self.offset = $0 })
    }

    private func update() {
        let progress = min(max(offset / ProfileV3Theme.Sizes.headerRevealDistance, 0), 1)
        if progress != self.progress {
            self.progress = progress
        }
    }
}
