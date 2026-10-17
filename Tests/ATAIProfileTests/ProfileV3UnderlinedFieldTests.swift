import SwiftUI
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
@Suite("Underlined field width")
struct ProfileV3UnderlinedFieldTests {
    private static let rowWidth: CGFloat = 345

    @Test func growingFieldFitsItsTextBetweenTheBaseWidthAndTheRow() {
        let base = ProfileV3Theme.Sizes.underlinedFieldWidth
        #expect(Self.width(of: "") == base)
        #expect(Self.width(of: "+91 98") == base)

        let medium = Self.width(of: "Flat 4B, Sea View Apartments")
        #expect(medium > base)
        #expect(medium < Self.rowWidth)
        #expect(Self.width(of: "Flat 4B, Sea View Apartments, Bandra") > medium)

        #expect(Self.width(of: String(repeating: "Sea View Apartments ", count: 5)) == Self.rowWidth)
    }

    private static func width(of text: String) -> CGFloat {
        let field = ProfileV3UnderlinedField(placeholder: "type here", text: .constant(text), growsWithContent: true)
        let proposal = CGSize(width: rowWidth, height: .greatestFiniteMagnitude)
        return UIHostingController(rootView: field).sizeThatFits(in: proposal).width
    }
}
