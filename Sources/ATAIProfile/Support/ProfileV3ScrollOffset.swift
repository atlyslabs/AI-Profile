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
}

@Observable
final class ProfileV3HeaderPin {
    @ObservationIgnored var offset: CGFloat = 0 {
        didSet { update() }
    }

    private(set) var progress: CGFloat = 0

    private func update() {
        let progress = min(max(offset / ProfileV3Theme.Sizes.headerRevealDistance, 0), 1)
        if progress != self.progress {
            self.progress = progress
        }
    }
}
