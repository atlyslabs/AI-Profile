import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Benefit learn more")
struct ProfileV3BenefitLearnMoreTests {
    private static let prompt = "Tell me more about my WorldPass benefit: $500 baggage protection. How do I use it?"

    @Test func theDetailKeepsALearnMoreThatOpensChat() throws {
        let decoded = try Self.detail(
            #"{"id":"baggage","title":"$500 baggage protection","learn_more":{"label":"Learn more","#
                + #""next":{"go":"ai_chat","prompt":"\#(Self.prompt)"}}}"#
        )
        let benefit = try #require(decoded)
        let learnMore = try #require(benefit.learnMore)
        #expect(learnMore.label == "Learn more")
        #expect(learnMore.prompt == Self.prompt)
        #expect(learnMore.directive.go == "ai_chat")
        #expect(benefit.title == "$500 baggage protection")
    }

    @Test func aLearnMoreWithoutALabelOrAChatPromptIsDropped() throws {
        let payloads = [
            #"{"id":"a","learn_more":{"label":"  ","next":{"go":"ai_chat","prompt":"Hi"}}}"#,
            #"{"id":"a","learn_more":{"next":{"go":"ai_chat","prompt":"Hi"}}}"#,
            #"{"id":"a","learn_more":{"label":"Learn more","next":{"go":"ai_chat","prompt":"  "}}}"#,
            #"{"id":"a","learn_more":{"label":"Learn more","next":{"go":"benefits_sheet"}}}"#,
            #"{"id":"a","learn_more":"Learn more"}"#,
            #"{"id":"a","learn_more":null}"#,
            #"{"id":"a"}"#
        ]
        for payload in payloads {
            let decoded = try Self.detail(payload)
            let benefit = try #require(decoded, "\(payload)")
            #expect(benefit.learnMore == nil, "\(payload)")
        }
    }

    @Test func learnMoreClosesTheBenefitsAndThenOpensChat() throws {
        let recorder = LearnMoreRecorder()
        let router = ChatRouterSpy(opensChat: true)
        let viewModel = Self.viewModel(router: router)
        let benefit = ProfileV3Fixtures.learnMoreBenefit
        #expect(viewModel.opensChat)

        ProfileV3Analytics.$scopedReporter.withValue(recorder) {
            viewModel.showAllBenefits()
            viewModel.openLearnMore(benefit)
        }
        #expect(!viewModel.showsAllBenefits)
        #expect(router.prompts.isEmpty)

        viewModel.overlaysDidClose()
        #expect(router.prompts == [Self.prompt])
        viewModel.overlaysDidClose()
        #expect(router.prompts == [Self.prompt])

        let clicks = recorder.named("profile_cta_clicked")
        #expect(clicks.count == 1)
        #expect(clicks.first?["ctaAction"] as? String == "ai_chat")
        #expect(clicks.first?["origin"] as? String == "benefit_detail")
        #expect(clicks.first?["benefitId"] as? String == benefit.id)
    }

    @Test func learnMoreDoesNothingWhenTheHostCannotOpenChat() {
        let router = ChatRouterSpy(opensChat: false)
        let viewModel = Self.viewModel(router: router)
        #expect(!viewModel.opensChat)

        viewModel.openLearnMore(ProfileV3Fixtures.learnMoreBenefit)
        viewModel.overlaysDidClose()
        #expect(router.prompts.isEmpty)

        router.opensChat = true
        viewModel.openLearnMore(ProfileV3Fixtures.partiallyRedeemedBenefit)
        viewModel.overlaysDidClose()
        #expect(router.prompts.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func theMockDetailServesALearnMore() async throws {
        let repository = ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore())
        let id = try #require(ProfileV3BenefitCatalogue.all.first?.id)
        let loaded = try await repository.loadBenefit(id: id)
        let benefit = try #require(loaded)
        #expect(benefit.learnMore?.prompt == "Tell me more about my WorldPass benefit: \(benefit.title). How do I use it?")
    }

    private static func detail(_ json: String) throws -> ProfileV3Benefit? {
        ProfileV3BenefitsMapper.detail(try JSONDecoder().decode(ProfileV3BenefitDetailDTO.self, from: Data(json.utf8)))
    }

    private static func viewModel(router: ChatRouterSpy) -> ProfileV3HubViewModel {
        let viewModel = ProfileV3HubViewModel(
            repository: ProfileV3MockRepository(delay: .zero, session: ProfileV3SessionStore())
        )
        viewModel.router = router
        return viewModel
    }
}

@MainActor
private final class ChatRouterSpy: ProfileV3HubRouter {
    var opensChat: Bool
    private(set) var prompts: [String] = []

    init(opensChat: Bool) {
        self.opensChat = opensChat
    }

    func openChat(prompt: String) {
        prompts.append(prompt)
    }

    func goBack() {}
    func openSettings(profileID: String?) {}
    func openKnowMore(_ directive: ProfileV3Directive?) {}
    func openAgent(_ agent: ProfileV3Agent, requiresKYC: Bool, profileID: String?) {}
    func openAddProgramme(requiresKYC: Bool, profileID: String?) {}
    func openProgrammes(for pass: ProfileV3WorldPass, passes: [ProfileV3WorldPass]) {}
    func openKYC() {}
    func openBenefitKYC(_ benefit: ProfileV3Benefit) {}
    func openAddTraveller() {}
    func openTravelPersona(profileID: String?) {}
}

private final class LearnMoreRecorder: ProfileV3AnalyticsReporting, @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [(name: String, parameters: [String: Any])] = []

    func named(_ name: String) -> [[String: Any]] {
        lock.withLock { recorded.filter { $0.name == name }.map(\.parameters) }
    }

    func logEvent(_ name: String, asScreenView: Bool, parameters: [String: Any]) {
        lock.withLock { recorded.append((name, parameters)) }
    }
}
