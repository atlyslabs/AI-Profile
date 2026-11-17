import ATUIKit
import SwiftUI

enum ProfileV3EmailQuoteNode: Equatable {
    case text(ProfileV3EmailText)
    case quote([ProfileV3EmailQuoteNode])

    private struct Line {
        var runs: [ProfileV3EmailText.Run] = []
        var depth: Int?
    }

    private struct Block {
        let depth: Int
        var lines: [[ProfileV3EmailText.Run]]
    }

    static func nodes(_ text: ProfileV3EmailText, maxDepth: Int) -> [ProfileV3EmailQuoteNode] {
        var lines = [Line()]
        for run in text.runs {
            for (index, part) in run.text.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
                if index > 0 { lines.append(Line()) }
                guard !part.isEmpty else { continue }
                var piece = run
                piece.text = String(part)
                lines[lines.count - 1].runs.append(piece)
                if lines[lines.count - 1].depth == nil, !piece.text.allSatisfy(\.isWhitespace) {
                    lines[lines.count - 1].depth = min(max(run.quoteDepth, 0), maxDepth)
                }
            }
        }

        var depths = lines.map(\.depth)
        var following: Int?
        for index in depths.indices.reversed() {
            if let depth = depths[index] { following = depth } else { depths[index] = following }
        }
        var preceding = 0
        for index in depths.indices {
            if let depth = depths[index] { preceding = depth } else { depths[index] = preceding }
        }

        var blocks: [Block] = []
        for (line, depth) in zip(lines, depths) {
            let depth = depth ?? 0
            if blocks.last?.depth == depth {
                blocks[blocks.count - 1].lines.append(line.runs)
            } else {
                blocks.append(Block(depth: depth, lines: [line.runs]))
            }
        }
        let trimmed: [(depth: Int, text: ProfileV3EmailText)] = blocks.compactMap { block in
            var lines = block.lines
            while let first = lines.first, isBlank(first) { lines.removeFirst() }
            while let last = lines.last, isBlank(last) { lines.removeLast() }
            guard !lines.isEmpty else { return nil }
            var runs: [ProfileV3EmailText.Run] = []
            for (index, line) in lines.enumerated() {
                if index > 0 { runs.append(ProfileV3EmailText.Run(text: "\n")) }
                runs += line
            }
            return (block.depth, ProfileV3EmailText(runs: runs))
        }
        return build(trimmed[...], level: 0)
    }

    private static func isBlank(_ line: [ProfileV3EmailText.Run]) -> Bool {
        line.allSatisfy { $0.text.allSatisfy(\.isWhitespace) }
    }

    private static func build(
        _ blocks: ArraySlice<(depth: Int, text: ProfileV3EmailText)>,
        level: Int
    ) -> [ProfileV3EmailQuoteNode] {
        var nodes: [ProfileV3EmailQuoteNode] = []
        var index = blocks.startIndex
        while index < blocks.endIndex {
            if blocks[index].depth <= level {
                nodes.append(.text(blocks[index].text))
                index += 1
            } else {
                let end = blocks[index...].firstIndex { $0.depth <= level } ?? blocks.endIndex
                nodes.append(.quote(build(blocks[index ..< end], level: level + 1)))
                index = end
            }
        }
        return nodes
    }
}

struct ProfileV3EmailQuoteView: View {
    let nodes: [ProfileV3EmailQuoteNode]

    private typealias Layout = ProfileV3Theme.GloveBox.Layout
    private typealias Palette = ProfileV3Theme.GloveBox.Palette

    init(_ text: ProfileV3EmailText) {
        nodes = ProfileV3EmailQuoteNode.nodes(text, maxDepth: Layout.emailQuoteMaxDepth)
    }

    init(nodes: [ProfileV3EmailQuoteNode]) {
        self.nodes = nodes
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.emailQuoteSpacing) {
            ForEach(nodes.indices, id: \.self) { index in
                switch nodes[index] {
                case .text(let text):
                    ProfileV3FlowingText(
                        text: text.plain,
                        attributed: ProfileV3EmailBodyText.attributed(text, quoted: true, color: UIColor(Color(at: .pureBlack)))
                    )
                case .quote(let children):
                    ProfileV3EmailQuoteView(nodes: children)
                        .padding(.leading, Layout.emailQuoteBar + Layout.emailQuoteBarGap)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(Palette.quoteBar)
                                .frame(width: Layout.emailQuoteBar)
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
