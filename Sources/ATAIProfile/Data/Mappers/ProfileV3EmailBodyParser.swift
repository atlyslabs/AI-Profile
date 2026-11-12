import Foundation

enum ProfileV3EmailBodyParser {
    static func body(html: String?, text: String?) -> ProfileV3EmailBody? {
        if let html, let body = fromHTML(html) { return body }
        if let text, let body = fromText(text) { return body }
        return nil
    }

    static func fromHTML(_ html: String) -> ProfileV3EmailBody? {
        var reader = ProfileV3HTMLReader(bytes: Array(html.utf8))
        reader.read()
        return split(reader.output.runs)
    }

    static func fromText(_ text: String) -> ProfileV3EmailBody? {
        let normalized = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let lines = normalized.components(separatedBy: "\n")
        var quoteStart = lines.count
        var index = lines.count - 1
        while index >= 0 {
            let line = lines[index].trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                index -= 1
            } else if line.hasPrefix(">") {
                quoteStart = index
                index -= 1
            } else {
                break
            }
        }
        var messageEnd = quoteStart
        if quoteStart < lines.count, index >= 0 {
            messageEnd = attributionStart(lines, endingAt: index) ?? quoteStart
        }
        let message = clean([Piece(text: lines[..<messageEnd].joined(separator: "\n"))])
        let quoted = clean([Piece(text: lines[messageEnd...].map(unquoted).joined(separator: "\n"))])
        return body(message: message, quoted: quoted)
    }

    private static func attributionStart(_ lines: [String], endingAt last: Int) -> Int? {
        guard isAttribution(lines[last]) else { return nil }
        var first = last
        while first > 0, last - first < 2, !lines[first - 1].trimmingCharacters(in: .whitespaces).isEmpty {
            first -= 1
        }
        if let opener = (first ... last).first(where: { lines[$0].trimmingCharacters(in: .whitespaces).hasPrefix("On ") }) {
            return opener
        }
        let isolated = first == 0 || lines[first - 1].trimmingCharacters(in: .whitespaces).isEmpty
        return isolated ? first : last
    }

    private static func isAttribution(_ line: String) -> Bool {
        line.trimmingCharacters(in: .whitespaces).lowercased().hasSuffix("wrote:")
    }

    private static func unquoted(_ line: String) -> String {
        var rest = Substring(line)
        while let first = rest.first(where: { $0 != " " && $0 != "\t" }), first == ">" {
            rest = rest.drop(while: { $0 == " " || $0 == "\t" }).dropFirst()
            if rest.first == " " { rest = rest.dropFirst() }
        }
        return String(rest)
    }

    // MARK: Splitting

    fileprivate struct Piece: Equatable {
        var text: String
        var isBold = false
        var isItalic = false
        var isQuoted = false
        var isAttribution = false
        var link: URL?

        var isBlank: Bool { text.allSatisfy(\.isWhitespace) }

        func sameStyle(as other: Piece) -> Bool {
            isBold == other.isBold && isItalic == other.isItalic && isQuoted == other.isQuoted && link == other.link
        }
    }

    private static func split(_ pieces: [Piece]) -> ProfileV3EmailBody? {
        var quoteStart = pieces.count
        for index in pieces.indices.reversed() {
            if pieces[index].isQuoted {
                quoteStart = index
            } else if !pieces[index].isBlank {
                break
            }
        }
        var message = Array(pieces[..<quoteStart])
        var quoted = pieces[quoteStart...].map { piece in
            var piece = piece
            piece.isQuoted = false
            return piece
        }
        if !quoted.isEmpty {
            let moved = trailingAttribution(of: message)
            quoted.insert(contentsOf: message[moved...], at: 0)
            message.removeSubrange(moved...)
        }
        return body(message: clean(message), quoted: clean(quoted))
    }

    private static func trailingAttribution(of message: [Piece]) -> Int {
        var start = message.count
        while start > 0, message[start - 1].isBlank || message[start - 1].isAttribution {
            start -= 1
        }
        if start < message.count, message[start...].contains(where: { $0.isAttribution && !$0.isBlank }) {
            return start
        }
        let text = message.map(\.text).joined()
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isAttribution(trimmed) else { return message.count }
        let lineStart = trimmed.lastIndex(of: "\n").map { trimmed.distance(from: trimmed.startIndex, to: $0) + 1 } ?? 0
        let leading = text.prefix { $0.isWhitespace || $0.isNewline }.count
        return splitIndex(of: message, atCharacter: leading + lineStart)
    }

    private static func splitIndex(of message: [Piece], atCharacter offset: Int) -> Int {
        var counted = 0
        for (index, piece) in message.enumerated() {
            if counted >= offset { return index }
            counted += piece.text.count
        }
        return message.count
    }

    private static func body(message: [Piece], quoted: [Piece]) -> ProfileV3EmailBody? {
        let message = text(message)
        let quoted = text(quoted)
        switch (message, quoted) {
        case (nil, nil): return nil
        case (nil, let quoted?): return ProfileV3EmailBody(message: quoted, quoted: nil)
        case (let message?, let quoted): return ProfileV3EmailBody(message: message, quoted: quoted)
        }
    }

    private static func text(_ pieces: [Piece]) -> ProfileV3EmailText? {
        guard !pieces.isEmpty else { return nil }
        return ProfileV3EmailText(runs: pieces.map {
            ProfileV3EmailText.Run(text: $0.text, isBold: $0.isBold, isItalic: $0.isItalic, isQuoted: $0.isQuoted, link: $0.link)
        })
    }

    private static func clean(_ pieces: [Piece]) -> [Piece] {
        var merged: [Piece] = []
        var newlines = 0
        for piece in pieces {
            var kept = ""
            for character in piece.text {
                if character == "\n" {
                    newlines += 1
                    if newlines <= 2 { kept.append(character) }
                } else {
                    newlines = 0
                    kept.append(character)
                }
            }
            guard !kept.isEmpty else { continue }
            if let last = merged.last, last.sameStyle(as: piece) {
                merged[merged.count - 1].text += kept
            } else {
                var piece = piece
                piece.text = kept
                merged.append(piece)
            }
        }
        while let first = merged.first {
            let trimmed = String(first.text.drop { $0.isWhitespace || $0.isNewline })
            if trimmed.isEmpty { merged.removeFirst() } else { merged[0].text = trimmed; break }
        }
        while let last = merged.last {
            var trimmed = last.text
            while let end = trimmed.last, end.isWhitespace || end.isNewline { trimmed.removeLast() }
            if trimmed.isEmpty { merged.removeLast() } else { merged[merged.count - 1].text = trimmed; break }
        }
        return merged
    }
}

// MARK: HTML

private struct ProfileV3HTMLOutput {
    var runs: [ProfileV3EmailBodyParser.Piece] = []
    private var pendingSpace = false
    private var trailingNewlines = 0
    private var isEmpty = true

    private var atLineStart: Bool { isEmpty || trailingNewlines > 0 }

    mutating func text(_ raw: String, style: ProfileV3HTMLStyle) {
        guard !style.isHidden else { return }
        var out = ""
        for scalar in raw.unicodeScalars {
            if ProfileV3HTMLOutput.invisible.contains(scalar.value) { continue }
            if ProfileV3HTMLOutput.collapsible.contains(scalar.value) {
                pendingSpace = true
                continue
            }
            if pendingSpace {
                if !out.isEmpty {
                    out.append(" ")
                } else if !atLineStart {
                    var plain = style
                    plain.link = nil
                    plain.isBold = false
                    plain.isItalic = false
                    append(" ", style: plain)
                }
            }
            pendingSpace = false
            out.unicodeScalars.append(scalar)
        }
        append(out, style: style)
    }

    mutating func softBreak(style: ProfileV3HTMLStyle) {
        guard !style.isHidden else { return }
        pendingSpace = false
        if !atLineStart { append("\n", style: style) }
    }

    mutating func hardBreak(style: ProfileV3HTMLStyle) {
        guard !style.isHidden else { return }
        pendingSpace = false
        append("\n", style: style)
    }

    mutating func paragraphBreak(style: ProfileV3HTMLStyle) {
        guard !style.isHidden, !isEmpty else { return }
        pendingSpace = false
        while trailingNewlines < 2 { append("\n", style: style) }
    }

    mutating func separate(style: ProfileV3HTMLStyle) {
        guard !style.isHidden, !atLineStart else { return }
        pendingSpace = true
    }

    private mutating func append(_ text: String, style: ProfileV3HTMLStyle) {
        guard !text.isEmpty else { return }
        let trailing = text.reversed().prefix { $0 == "\n" }.count
        trailingNewlines = trailing == text.count ? trailingNewlines + trailing : trailing
        isEmpty = false
        runs.append(ProfileV3EmailBodyParser.Piece(
            text: text,
            isBold: style.isBold,
            isItalic: style.isItalic,
            isQuoted: style.isQuoted,
            isAttribution: style.isAttribution,
            link: style.link
        ))
    }

    private static let collapsible: Set<UInt32> = [0x20, 0x09, 0x0A, 0x0C, 0x0D, 0xA0]
    private static let invisible: Set<UInt32> = [0xAD, 0x34F, 0x200B, 0x200C, 0x200D, 0x2060, 0xFEFF]
}

private struct ProfileV3HTMLStyle {
    var isBold = false
    var isItalic = false
    var isHidden = false
    var isQuoted = false
    var isAttribution = false
    var link: URL?
}

private struct ProfileV3HTMLFrame {
    let name: String
    let style: ProfileV3HTMLStyle
    var listCounter: Int?
}

private struct ProfileV3HTMLReader {
    let bytes: [UInt8]
    var output = ProfileV3HTMLOutput()
    private var stack: [ProfileV3HTMLFrame] = []
    private var position = 0

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    private var style: ProfileV3HTMLStyle { stack.last?.style ?? ProfileV3HTMLStyle() }

    mutating func read() {
        var textStart = 0
        while position < bytes.count {
            guard bytes[position] == UInt8(ascii: "<") else {
                position += 1
                continue
            }
            let tagStart = position
            guard let tag = readTag() else {
                position = tagStart + 1
                continue
            }
            flushText(from: textStart, to: tagStart)
            handle(tag)
            textStart = position
        }
        flushText(from: textStart, to: bytes.count)
    }

    private mutating func flushText(from start: Int, to end: Int) {
        guard start < end else { return }
        let raw = String(decoding: bytes[start ..< end], as: UTF8.self)
        output.text(ProfileV3HTMLEntities.decode(raw), style: style)
    }

    // MARK: Tags

    private enum Tag {
        case start(name: String, attributes: [String: String], selfClosing: Bool)
        case end(name: String)
        case other
    }

    private mutating func readTag() -> Tag? {
        let next = position + 1
        guard next < bytes.count else { return nil }
        if matches("!--", at: next) {
            position = index(of: "-->", from: next + 3).map { $0 + 3 } ?? bytes.count
            return .other
        }
        if bytes[next] == UInt8(ascii: "!") || bytes[next] == UInt8(ascii: "?") {
            position = index(of: ">", from: next).map { $0 + 1 } ?? bytes.count
            return .other
        }
        if bytes[next] == UInt8(ascii: "/") {
            let (name, afterName) = readName(at: next + 1)
            position = index(of: ">", from: afterName).map { $0 + 1 } ?? bytes.count
            return name.isEmpty ? .other : .end(name: name)
        }
        guard isLetter(bytes[next]) else { return nil }
        let (name, afterName) = readName(at: next)
        var attributes: [String: String] = [:]
        var cursor = afterName
        var selfClosing = false
        while cursor < bytes.count {
            let byte = bytes[cursor]
            if byte == UInt8(ascii: ">") {
                cursor += 1
                break
            }
            if byte == UInt8(ascii: "/") {
                selfClosing = true
                cursor += 1
                continue
            }
            if isSpace(byte) {
                cursor += 1
                continue
            }
            selfClosing = false
            var nameEnd = cursor
            while nameEnd < bytes.count, !isSpace(bytes[nameEnd]),
                  bytes[nameEnd] != UInt8(ascii: "="), bytes[nameEnd] != UInt8(ascii: ">"), bytes[nameEnd] != UInt8(ascii: "/") {
                nameEnd += 1
            }
            let attribute = String(decoding: bytes[cursor ..< nameEnd], as: UTF8.self).lowercased()
            cursor = nameEnd
            while cursor < bytes.count, isSpace(bytes[cursor]) { cursor += 1 }
            var value = ""
            if cursor < bytes.count, bytes[cursor] == UInt8(ascii: "=") {
                cursor += 1
                while cursor < bytes.count, isSpace(bytes[cursor]) { cursor += 1 }
                if cursor < bytes.count, bytes[cursor] == UInt8(ascii: "\"") || bytes[cursor] == UInt8(ascii: "'") {
                    let quote = bytes[cursor]
                    let valueStart = cursor + 1
                    var valueEnd = valueStart
                    while valueEnd < bytes.count, bytes[valueEnd] != quote { valueEnd += 1 }
                    value = String(decoding: bytes[valueStart ..< valueEnd], as: UTF8.self)
                    cursor = min(valueEnd + 1, bytes.count)
                } else {
                    let valueStart = cursor
                    while cursor < bytes.count, !isSpace(bytes[cursor]), bytes[cursor] != UInt8(ascii: ">") { cursor += 1 }
                    value = String(decoding: bytes[valueStart ..< cursor], as: UTF8.self)
                }
            }
            if !attribute.isEmpty, attributes[attribute] == nil {
                attributes[attribute] = ProfileV3HTMLEntities.decode(value)
            }
        }
        position = cursor
        return .start(name: name, attributes: attributes, selfClosing: selfClosing)
    }

    private func readName(at start: Int) -> (String, Int) {
        var end = start
        while end < bytes.count, isLetter(bytes[end]) || (end > start && isDigit(bytes[end])) { end += 1 }
        return (String(decoding: bytes[start ..< end], as: UTF8.self).lowercased(), end)
    }

    // MARK: Elements

    private static let rawText: Set<String> = ["script", "style", "title", "textarea", "noscript", "template"]
    private static let void: Set<String> = [
        "area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"
    ]
    private static let paragraphs: Set<String> = ["p", "blockquote", "ul", "ol", "pre", "h1", "h2", "h3", "h4", "h5", "h6"]
    private static let blocks: Set<String> = [
        "address", "article", "aside", "caption", "center", "dd", "div", "dl", "dt", "fieldset", "figcaption",
        "figure", "footer", "form", "header", "li", "main", "nav", "section", "table", "tr"
    ]
    private static let closesParagraph: Set<String> = paragraphs.union(blocks).union(["hr"])
    private static let maxDepth = 512

    private mutating func handle(_ tag: Tag) {
        switch tag {
        case .other:
            break
        case .end(let name):
            if name == "br" {
                output.hardBreak(style: style)
            } else if name == "p", !stack.contains(where: { $0.name == "p" }) {
                output.paragraphBreak(style: style)
            } else {
                close(name)
            }
        case .start(let name, let attributes, let selfClosing):
            open(name, attributes: attributes, selfClosing: selfClosing)
        }
    }

    private mutating func open(_ name: String, attributes: [String: String], selfClosing: Bool) {
        if Self.rawText.contains(name) {
            if !selfClosing { skipRawText(name) }
            return
        }
        if name == "body" { close("head") }
        if Self.closesParagraph.contains(name), stack.last?.name == "p" { close("p") }
        switch name {
        case "li": closeOpen("li", within: ["ul", "ol"])
        case "td", "th": closeOpen(["td", "th"], within: ["tr", "table"])
        case "tr": closeOpen(["tr"], within: ["table"])
        default: break
        }

        let parent = style
        switch name {
        case "br": output.hardBreak(style: parent)
        case "hr": output.paragraphBreak(style: parent)
        case "td", "th": output.separate(style: parent)
        default:
            if Self.paragraphs.contains(name) {
                output.paragraphBreak(style: parent)
            } else if Self.blocks.contains(name) {
                output.softBreak(style: parent)
            }
        }
        guard !Self.void.contains(name) else { return }
        if selfClosing {
            closingBreak(name, style: parent)
            return
        }
        guard stack.count < Self.maxDepth else { return }

        let own = elementStyle(name, attributes: attributes, parent: parent)
        var frame = ProfileV3HTMLFrame(name: name, style: own)
        if name == "ol" { frame.listCounter = Int(attributes["start"] ?? "") ?? 1 }
        if name == "ul" { frame.listCounter = 0 }
        stack.append(frame)
        if name == "li" { output.text(listMarker(), style: ProfileV3HTMLStyle(isHidden: own.isHidden, isQuoted: own.isQuoted)) }
    }

    private mutating func listMarker() -> String {
        guard let listIndex = stack.lastIndex(where: { $0.name == "ul" || $0.name == "ol" }) else { return "• " }
        guard stack[listIndex].name == "ol", let number = stack[listIndex].listCounter else { return "• " }
        stack[listIndex].listCounter = number + 1
        return "\(number). "
    }

    private func elementStyle(_ name: String, attributes: [String: String], parent: ProfileV3HTMLStyle) -> ProfileV3HTMLStyle {
        var style = parent
        let css = (attributes["style"] ?? "").lowercased().filter { !$0.isWhitespace }
        let classes = (attributes["class"] ?? "").lowercased().split(separator: " ").map(String.init)
        if ["b", "strong", "h1", "h2", "h3", "h4", "h5", "h6", "th"].contains(name)
            || css.contains("font-weight:bold") || css.contains("font-weight:600") || css.contains("font-weight:700")
            || css.contains("font-weight:800") || css.contains("font-weight:900") {
            style.isBold = true
        }
        if ["i", "em"].contains(name) || css.contains("font-style:italic") {
            style.isItalic = true
        }
        if name == "head" || attributes["hidden"] != nil || css.contains("display:none")
            || css.contains("mso-hide:all") || css.contains("visibility:hidden") {
            style.isHidden = true
        }
        if name == "blockquote" || classes.contains("yahoo_quoted") {
            style.isQuoted = true
        }
        if classes.contains("gmail_attr") || classes.contains("moz-cite-prefix") {
            style.isAttribution = true
        }
        if name == "a", let link = Self.link(attributes["href"]) {
            style.link = link
        }
        return style
    }

    private static func link(_ href: String?) -> URL? {
        guard let href = href?.trimmingCharacters(in: .whitespacesAndNewlines), !href.isEmpty,
              let url = URL(string: href), let scheme = url.scheme?.lowercased(),
              ["http", "https", "mailto", "tel"].contains(scheme) else { return nil }
        return url
    }

    private mutating func close(_ name: String) {
        guard let index = stack.lastIndex(where: { $0.name == name }) else { return }
        while stack.count > index {
            let frame = stack.removeLast()
            closingBreak(frame.name, style: style)
        }
    }

    private mutating func closingBreak(_ name: String, style: ProfileV3HTMLStyle) {
        if Self.paragraphs.contains(name) {
            output.paragraphBreak(style: style)
        } else if Self.blocks.contains(name) {
            output.softBreak(style: style)
        }
    }

    private mutating func closeOpen(_ name: String, within scopes: Set<String>) {
        closeOpen([name], within: scopes)
    }

    private mutating func closeOpen(_ names: Set<String>, within scopes: Set<String>) {
        for frame in stack.reversed() {
            if scopes.contains(frame.name) { return }
            if names.contains(frame.name) {
                close(frame.name)
                return
            }
        }
    }

    private mutating func skipRawText(_ name: String) {
        let closing = Array("</\(name)".utf8)
        var cursor = position
        while cursor + closing.count <= bytes.count {
            if bytes[cursor] == UInt8(ascii: "<"), matchesIgnoringCase(closing, at: cursor) {
                position = index(of: ">", from: cursor).map { $0 + 1 } ?? bytes.count
                return
            }
            cursor += 1
        }
    }

    // MARK: Bytes

    private func matches(_ literal: String, at start: Int) -> Bool {
        let literal = Array(literal.utf8)
        guard start + literal.count <= bytes.count else { return false }
        return bytes[start ..< start + literal.count].elementsEqual(literal)
    }

    private func matchesIgnoringCase(_ literal: [UInt8], at start: Int) -> Bool {
        guard start + literal.count <= bytes.count else { return false }
        for offset in literal.indices where lowered(bytes[start + offset]) != lowered(literal[offset]) {
            return false
        }
        return true
    }

    private func index(of literal: String, from start: Int) -> Int? {
        let literal = Array(literal.utf8)
        guard let first = literal.first else { return nil }
        var cursor = start
        while cursor + literal.count <= bytes.count {
            if bytes[cursor] == first, bytes[cursor ..< cursor + literal.count].elementsEqual(literal) { return cursor }
            cursor += 1
        }
        return nil
    }

    private func lowered(_ byte: UInt8) -> UInt8 {
        byte >= UInt8(ascii: "A") && byte <= UInt8(ascii: "Z") ? byte + 32 : byte
    }

    private func isLetter(_ byte: UInt8) -> Bool {
        (byte >= UInt8(ascii: "a") && byte <= UInt8(ascii: "z")) || (byte >= UInt8(ascii: "A") && byte <= UInt8(ascii: "Z"))
    }

    private func isDigit(_ byte: UInt8) -> Bool {
        byte >= UInt8(ascii: "0") && byte <= UInt8(ascii: "9")
    }

    private func isSpace(_ byte: UInt8) -> Bool {
        byte == 0x20 || byte == 0x09 || byte == 0x0A || byte == 0x0C || byte == 0x0D
    }
}

private enum ProfileV3HTMLEntities {
    static func decode(_ text: String) -> String {
        guard text.contains("&") else { return text }
        var result = ""
        var rest = Substring(text)
        while let amp = rest.firstIndex(of: "&") {
            result += rest[..<amp]
            let afterAmp = rest.index(after: amp)
            let limit = rest.index(afterAmp, offsetBy: 32, limitedBy: rest.endIndex) ?? rest.endIndex
            guard let semicolon = rest[afterAmp ..< limit].firstIndex(of: ";"),
                  let decoded = entity(String(rest[afterAmp ..< semicolon])) else {
                result.append("&")
                rest = rest[afterAmp...]
                continue
            }
            result += decoded
            rest = rest[rest.index(after: semicolon)...]
        }
        result += rest
        return result
    }

    private static func entity(_ name: String) -> String? {
        if name.hasPrefix("#") {
            let digits = name.dropFirst()
            let value = digits.first == "x" || digits.first == "X"
                ? UInt32(digits.dropFirst(), radix: 16)
                : UInt32(digits, radix: 10)
            guard let value, value != 0, let scalar = Unicode.Scalar(value) else { return nil }
            return String(Character(scalar))
        }
        return named[name]
    }

    private static let named: [String: String] = [
        "amp": "&", "lt": "<", "gt": ">", "quot": "\"", "apos": "'", "nbsp": "\u{A0}",
        "ensp": "\u{2002}", "emsp": "\u{2003}", "thinsp": "\u{2009}", "zwnj": "\u{200C}", "zwj": "\u{200D}",
        "shy": "\u{AD}", "ndash": "–", "mdash": "—", "lsquo": "‘", "rsquo": "’", "sbquo": "‚",
        "ldquo": "“", "rdquo": "”", "bdquo": "„", "hellip": "…", "bull": "•", "middot": "·",
        "copy": "©", "reg": "®", "trade": "™", "euro": "€", "pound": "£", "yen": "¥", "cent": "¢",
        "deg": "°", "times": "×", "divide": "÷", "plusmn": "±", "laquo": "«", "raquo": "»",
        "rarr": "→", "larr": "←", "uarr": "↑", "darr": "↓", "sect": "§", "para": "¶",
        "frac12": "½", "frac14": "¼", "frac34": "¾", "iexcl": "¡", "iquest": "¿", "rupee": "₹",
        "aacute": "á", "agrave": "à", "acirc": "â", "auml": "ä", "atilde": "ã", "aring": "å",
        "eacute": "é", "egrave": "è", "ecirc": "ê", "euml": "ë", "iacute": "í", "igrave": "ì",
        "icirc": "î", "iuml": "ï", "oacute": "ó", "ograve": "ò", "ocirc": "ô", "ouml": "ö",
        "otilde": "õ", "oslash": "ø", "uacute": "ú", "ugrave": "ù", "ucirc": "û", "uuml": "ü",
        "ccedil": "ç", "ntilde": "ñ", "szlig": "ß", "Eacute": "É", "Auml": "Ä", "Ouml": "Ö", "Uuml": "Ü"
    ]
}
