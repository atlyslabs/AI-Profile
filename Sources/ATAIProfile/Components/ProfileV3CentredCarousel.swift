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
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
            .task(id: width > 0) {
                guard width > 0 else { return }
                if let selection {
                    proxy.scrollTo(selection, anchor: .center)
                }
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
