import Foundation
import Observation
import Testing
@testable import ATAIProfile

@MainActor
struct ProfileV3ReviewFixesTests {
    @Test(.timeLimit(.minutes(1)))
    func aFailedTraitPageWaitsForTryAgainThenKeepsPaging() async throws {
        let repository = TraitPagesStub()
        let viewModel = ProfileV3PersonaTraitViewModel(traitID: "adventure", profileID: nil, repository: repository)
        viewModel.load()
        while viewModel.content == nil { try await Task.sleep(for: .milliseconds(10)) }

        viewModel.loadMore()
        while !viewModel.loadMoreFailed { try await Task.sleep(for: .milliseconds(10)) }
        #expect(viewModel.content?.rows.map(\.id) == ["r1"])

        viewModel.loadMore()
        try await Task.sleep(for: .milliseconds(50))
        #expect(repository.requests(for: 2) == 1)

        viewModel.retryLoadMore()
        while viewModel.content?.rows.count != 2 { try await Task.sleep(for: .milliseconds(10)) }
        #expect(!viewModel.loadMoreFailed)
        #expect(viewModel.content?.nextPage?.page == 3)

        viewModel.loadMore()
        while viewModel.content?.rows.count != 3 { try await Task.sleep(for: .milliseconds(10)) }
        #expect(viewModel.content?.rows.map(\.id) == ["r1", "r2", "r3"])
        #expect(viewModel.content?.nextPage == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func aFailedInboxPageOffersTryAgainAndThenAppends() async throws {
        let repository = InboxPagesStub()
        let viewModel = ProfileV3GloveBoxViewModel(repository: repository)
        while viewModel.home == nil { try await Task.sleep(for: .milliseconds(10)) }
        #expect(viewModel.hasMoreEmails)
        #expect(viewModel.home?.email.emails.map(\.id) == ["e1", "e2"])

        viewModel.openList(.emails)
        while !viewModel.emailPagingFailed { try await Task.sleep(for: .milliseconds(10)) }
        #expect(viewModel.home?.email.emails.count == 2)

        viewModel.loadMoreEmails()
        try await Task.sleep(for: .milliseconds(50))
        #expect(repository.secondPageRequests == 1)

        viewModel.retryLoadMoreEmails()
        while viewModel.home?.email.emails.count != 3 { try await Task.sleep(for: .milliseconds(10)) }
        #expect(!viewModel.emailPagingFailed)
        #expect(!viewModel.hasMoreEmails)
    }

    @Test func fractionalNumbersKeepTheirFraction() throws {
        let scalars = try JSONDecoder().decode([ProfileV3ScalarDTO].self, from: Data(#"[3.5, 72, 72.0, "72.5"]"#.utf8))
        #expect(scalars.map(\.stringValue) == ["3.5", "72", "72", "72.5"])

        let values = try JSONDecoder().decode([ProfileV3AgentValueDTO].self, from: Data(#"[72.5, 180, "1,200", true]"#.utf8))
        #expect(values.map(\.doubleValue) == [72.5, 180, 1200, nil])
    }

    @Test func inboxDatesParseWithAndWithoutFractionalSeconds() throws {
        let page = try JSONDecoder().decode(
            ProfileV3GloveBoxMessagesDTO.self,
            from: Data(#"""
            {"items":[
              {"id":"a","from_name":"IndiGo","subject":"One","received_at":"2026-10-16T08:30:00.250Z","status":"forwarded"},
              {"id":"b","from_name":"IndiGo","subject":"Two","received_at":"2026-06-05T23:59:00Z","status":"forwarded"}
            ],"next_cursor":null}
            """#.utf8)
        )
        #expect(ProfileV3GloveBoxMapper.page(page).emails.map { $0.meta?.dateLabel } == ["16 Oct, 2026", "5 Jun, 2026"])
    }

    @Test func aViewReadingOnlyTheHubPhaseIsNotToldAboutOtherChanges() {
        let viewModel = ProfileV3HubViewModel(repository: ProfileV3MockRepository(delay: .zero))
        let phase = ChangeCounter()
        let benefits = ChangeCounter()
        withObservationTracking { _ = viewModel.phase } onChange: { phase.hit() }
        withObservationTracking { _ = viewModel.showsAllBenefits } onChange: { benefits.hit() }

        viewModel.tapViewAllBenefits()

        #expect(benefits.count == 1)
        #expect(phase.count == 0)
    }
}

private final class ChangeCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var hits = 0

    var count: Int { lock.withLock { hits } }

    func hit() { lock.withLock { hits += 1 } }
}

private final class TraitPagesStub: ProfileV3PersonaRepository, @unchecked Sendable {
    private let lock = NSLock()
    private var counts: [Int: Int] = [:]

    func requests(for page: Int) -> Int { lock.withLock { counts[page, default: 0] } }

    func loadTravelPersona(profileID _: String?) async throws -> ProfileV3TravelPersona {
        throw ProfileV3Error.notImplemented(action: "travel_persona")
    }

    func loadPersonaTrait(_ trait: String, profileID _: String?, page: Int) async throws -> ProfileV3PersonaTrait {
        let attempt = lock.withLock {
            counts[page, default: 0] += 1
            return counts[page, default: 0]
        }
        if page == 2, attempt == 1 { throw ProfileV3Error.transient(message: nil) }
        let next = page < 3 ? ProfileV3Directive(go: "persona_trait", trait: trait, page: page + 1) : nil
        return ProfileV3PersonaTrait(
            trait: trait,
            title: "Adventure",
            score: 50,
            subtitle: "",
            scale: ProfileV3PersonaTrait.Scale(range: 0 ... 100, value: 50, labels: []),
            calculationTitle: "",
            rows: [ProfileV3PersonaTrait.Row(
                id: "r\(page)",
                kind: .gmail,
                title: "Row \(page)",
                subtitle: "",
                delta: 1,
                deltaLabel: "+1",
                isIgnored: false
            )],
            nextPage: next
        )
    }

    func submitPersonaAction(_: ProfileV3BoardAction, score _: Int?) async throws {}
}

private final class InboxPagesStub: ProfileV3GloveBoxRepository, @unchecked Sendable {
    private let lock = NSLock()
    private var secondPageAttempts = 0
    private let account = ProfileV3GloveBoxAccount(
        address: "priya@trips.atlys.com",
        forwardingEmail: "priya@gmail.com",
        eligible: true
    )

    var secondPageRequests: Int { lock.withLock { secondPageAttempts } }

    func loadGloveBoxCard() async throws -> ProfileV3GloveBoxAccount { account }

    func createGloveBoxAddress() async throws -> ProfileV3GloveBoxAccount { account }

    func setGloveBoxForwardingPaused(_: Bool) async throws -> ProfileV3GloveBoxAccount { account }

    func addGloveBoxForwardingAddress(_: String) async throws -> ProfileV3GloveBoxAccount { account }

    func loadGloveBoxMessages(cursor: String?) async throws -> ProfileV3GloveBoxInboxPage {
        guard cursor == "page-2" else {
            return ProfileV3GloveBoxInboxPage(emails: [Self.email("e1"), Self.email("e2")], nextCursor: "page-2")
        }
        let attempt = lock.withLock {
            secondPageAttempts += 1
            return secondPageAttempts
        }
        if attempt == 1 { throw ProfileV3Error.transient(message: nil) }
        return ProfileV3GloveBoxInboxPage(emails: [Self.email("e3")], nextCursor: nil)
    }

    func loadGloveBoxMessage(_ listed: ProfileV3GloveBoxEmail) async throws -> ProfileV3GloveBoxEmail { listed }

    func loadGloveBoxAttachment(messageID _: String, index _: Int) async throws -> Data { Data() }

    private static func email(_ id: String) -> ProfileV3GloveBoxEmail {
        ProfileV3GloveBoxEmail(id: id, sender: "Sender \(id)", summary: "Summary \(id)")
    }
}
