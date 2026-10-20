import Foundation
import Testing
import UIKit
@testable import ATAIProfile

@MainActor
@Suite("Passport re-scan")
struct ProfileV3PassportScanTests {
    @Test func aFrontScanSaysWhetherTheBackIsNeeded() throws {
        let indian = try Self.response(#"{"ok":true,"side":"front","back_required":true,"nationality":"IN"}"#)
        #expect(indian.backRequired == true)
        #expect(indian.nationality == "IN")
        let other = try Self.response(#"{"ok":true,"side":"front","back_required":false,"nationality":"US"}"#)
        #expect(other.backRequired == false)
        let unread = try Self.response(#"{"ok":true,"side":"front","nationality":null}"#)
        #expect(unread.backRequired == nil)
        #expect(unread.nationality == nil)
    }

    @Test func onlyAnExplicitFalseSkipsTheBack() {
        #expect(ProfileV3PassportScanResult(backRequired: true).needsBack)
        #expect(ProfileV3PassportScanResult(backRequired: nil).needsBack)
        #expect(!ProfileV3PassportScanResult(backRequired: false).needsBack)
    }

    @Test func aFrontThatNeedsNoBackEndsTheScan() async {
        let skipped = await Self.backSkips(after: .passportFront, backRequired: false)
        #expect(skipped)
    }

    @Test func aFrontThatNeedsTheBackKeepsGoing() async {
        let required = await Self.backSkips(after: .passportFront, backRequired: true)
        let unknown = await Self.backSkips(after: .passportFront, backRequired: nil)
        let back = await Self.backSkips(after: .passportBack, backRequired: false)
        #expect(!required)
        #expect(!unknown)
        #expect(!back)
    }

    private static func backSkips(after piece: ProfileV3CaptureImage, backRequired: Bool?) async -> Bool {
        var skipped = false
        let verifier = ProfileV3PassportScanVerifier { _, _ in
            ProfileV3PassportScanResult(field: nil, backRequired: backRequired)
        }
        verifier.onBackNotNeeded = { skipped = true }
        let verdict = await verifier.verify(ProfileV3IdentityCapture.Capture(
            piece: piece,
            image: UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { _ in },
            source: .liveScan
        ))
        #expect(verdict == .verified)
        return skipped
    }

    private static func response(_ json: String) throws -> ProfileV3PassportScanResponseDTO {
        try JSONDecoder().decode(ProfileV3PassportScanResponseDTO.self, from: Data(json.utf8))
    }
}
