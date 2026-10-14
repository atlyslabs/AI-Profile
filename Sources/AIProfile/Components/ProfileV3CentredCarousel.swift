import SwiftUI

struct ProfileV3CentredCarousel<SelectionID: Hashable, Content: View>: View {
    let itemWidth: CGFloat
    let height: CGFloat
    let spacing: CGFloat
    @Binding var selection: SelectionID?
    var isScrollDisabled = false
    var revealOffset: CGFloat = 0
    @ViewBuilder var content: () -> Content

    @State private var width: CGFloat = 0
    @State private var isPositioned = false
    @State private var restoreTarget: SelectionID?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    content()
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selection, anchor: .center)
            .contentMargins(.horizontal, max((width - itemWidth) / 2, 0), for: .scrollContent)
            .scrollClipDisabled()
            .scrollDisabled(isScrollDisabled)
            .frame(height: height)
            .opacity(isPositioned ? 1 : 0)
            .offset(y: isPositioned ? 0 : revealOffset)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { newWidth in
                let isFirstLayout = width == 0 && newWidth > 0
                width = newWidth
                guard isFirstLayout else { return }
                if let selection {
                    restoreTarget = selection
                } else {
                    reveal()
                }
            }
            .task(id: restoreTarget) {
                guard let restoreTarget else { return }
                proxy.scrollTo(restoreTarget, anchor: .center)
                reveal()
            }
        }
    }

    private func reveal() {
        withAnimation(revealOffset > 0 ? ProfileV3Theme.Motion.entry : nil) {
            isPositioned = true
        }
    }
}
