import SwiftUI

struct ProfileV3FlowLayout: Layout {
    var horizontalSpacing: CGFloat = ProfileV3Theme.Space.s12
    var verticalSpacing: CGFloat = ProfileV3Theme.Space.s16

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = measure(subviews, maxWidth: proposal.width)
        let rows = arrange(maxWidth: proposal.width ?? .infinity, sizes: sizes)
        let width = proposal.width ?? rows.map(\.width).max() ?? 0
        let rowsHeight = rows.reduce(0) { $0 + $1.height }
        let gaps = CGFloat(max(rows.count - 1, 0)) * verticalSpacing
        return CGSize(width: width, height: rowsHeight + gaps)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = measure(subviews, maxWidth: bounds.width)
        var y = bounds.minY
        for row in arrange(maxWidth: bounds.width, sizes: sizes) {
            var x = bounds.minX
            for index in row.indices {
                let size = sizes[index]
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + horizontalSpacing
            }
            y += row.height + verticalSpacing
        }
    }

    private func measure(_ subviews: Subviews, maxWidth: CGFloat?) -> [CGSize] {
        subviews.map { subview in
            let size = subview.sizeThatFits(.unspecified)
            guard let maxWidth, size.width > maxWidth else { return size }
            return subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
        }
    }

    private func arrange(maxWidth: CGFloat, sizes: [CGSize]) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for (index, size) in sizes.enumerated() {
            let widthIfAppended = current.indices.isEmpty ? size.width : current.width + horizontalSpacing + size.width
            if widthIfAppended > maxWidth, !current.indices.isEmpty {
                rows.append(current)
                current = Row()
            }
            current.width = current.indices.isEmpty ? size.width : current.width + horizontalSpacing + size.width
            current.height = max(current.height, size.height)
            current.indices.append(index)
        }
        if !current.indices.isEmpty {
            rows.append(current)
        }
        return rows
    }
}
