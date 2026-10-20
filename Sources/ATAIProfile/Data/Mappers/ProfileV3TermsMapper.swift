import Foundation

enum ProfileV3TermsMapper: ProfileV3DTOReading {

    static func terms(_ dto: ProfileV3TermsScreenDTO) -> ProfileV3Terms? {
        let title = text(dto.title) ?? ""
        let nodes = dto.blocks.flatMap { $0.richText?.content ?? [] }
        let sections = sections(from: nodes, documentTitle: title)
        guard !sections.isEmpty else { return nil }
        return ProfileV3Terms(title: title, sections: sections)
    }

    private static func sections(
        from nodes: [ProfileV3TermsNodeDTO],
        documentTitle: String
    ) -> [ProfileV3TermsSection] {
        var sections: [ProfileV3TermsSection] = []
        var title = ""
        var paragraphs: [String] = []

        func flush() {
            guard !title.isEmpty || !paragraphs.isEmpty else { return }
            sections.append(
                ProfileV3TermsSection(
                    id: "section-\(sections.count)",
                    title: title,
                    blocks: paragraphs.isEmpty
                        ? []
                        : [ProfileV3TermsBlock(id: "block-\(sections.count)", paragraphs: paragraphs)]
                )
            )
            title = ""
            paragraphs = []
        }

        for node in nodes {
            guard let line = text(plain(node)) else { continue }
            if isHeading(node) {
                guard line.caseInsensitiveCompare(documentTitle) != .orderedSame else { continue }
                flush()
                title = line
            } else {
                paragraphs.append(line)
            }
        }
        flush()
        return sections
    }

    private static func isHeading(_ node: ProfileV3TermsNodeDTO) -> Bool {
        if node.type == "heading" { return true }
        let runs = (node.content ?? []).filter { text($0.text) != nil }
        guard !runs.isEmpty else { return false }
        return runs.allSatisfy { run in
            (run.marks ?? []).contains { $0.type == "bold" }
        }
    }

    private static func plain(_ node: ProfileV3TermsNodeDTO) -> String {
        let own = node.text ?? ""
        let nested = (node.content ?? []).map(plain).joined()
        return (own + nested)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

}
