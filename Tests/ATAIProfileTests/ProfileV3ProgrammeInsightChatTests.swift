import Foundation
import Testing
@testable import ATAIProfile

@Suite("Programme insight chat and card aspect")
struct ProfileV3ProgrammeInsightChatTests {
    @Test func continueCarriesTheChatPrompt() throws {
        let insight = try Self.insight(#"""
        {"type":"program_insight",
         "insight":"Add your IndiGo BluChip points to see what they're worth.",
         "continue":{"label":"Continue","next":{"go":"ai_chat",
           "prompt":" recommend me best deals in under 8,000 points on IndiGo BluChip membership "}}}
        """#)
        #expect(insight.actionTitle == "Continue")
        #expect(insight.continueDirective?.go == "ai_chat")
        #expect(insight.chatPrompt == "recommend me best deals in under 8,000 points on IndiGo BluChip membership")
    }

    @Test func aChatContinueWithoutAPromptOpensNothing() throws {
        let blank = try Self.insight(#"{"continue":{"label":"Continue","next":{"go":"ai_chat","prompt":"  "}}}"#)
        #expect(blank.chatPrompt == nil)
        let other = try Self.insight(#"{"continue":{"label":"Continue","next":{"go":"programs_page"}}}"#)
        #expect(other.chatPrompt == nil)
        let missing = try Self.insight(#"{"insight":"No continue here"}"#)
        #expect(missing.actionTitle.isEmpty)
        #expect(missing.continueDirective == nil)
    }

    @Test func aProgrammeRowKeepsTheServersArtAspect() throws {
        #expect(try Self.programme(#"{"id":"indigo","name":"IndiGo","art_aspect":1.583}"#).artAspect == 1.583)
        #expect(try Self.programme(#"{"id":"indigo","name":"IndiGo","art_aspect":"1.6"}"#).artAspect == 1.6)
        #expect(try Self.programme(#"{"id":"indigo","name":"IndiGo","art_aspect":0}"#).artAspect == nil)
        #expect(try Self.programme(#"{"id":"indigo","name":"IndiGo"}"#).artAspect == nil)
    }

    private static func insight(_ json: String) throws -> ProfileV3ProgrammeInsight {
        ProfileV3LoyaltyMapper.insight(
            try JSONDecoder().decode(ProfileV3ProgrammeInsightScreenDTO.self, from: Data(json.utf8))
        )
    }

    private static func programme(_ json: String) throws -> ProfileV3LoyaltyProgramme {
        ProfileV3LoyaltyMapper.programme(try JSONDecoder().decode(ProfileV3ProgrammeRowDTO.self, from: Data(json.utf8)))
    }
}
