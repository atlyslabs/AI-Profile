import Foundation
import Testing
@testable import ATAIProfile

@MainActor
@Suite("Travel persona")
struct ProfileV3TravelPersonaTests {
    @Test func personaScreenKeepsTheServerOrderScoresAndActions() throws {
        let dto = try JSONDecoder().decode(ProfileV3PersonaScreenDTO.self, from: Data(#"""
        {"type":"travel_persona","title":"Travel persona","icon":"orb_personal",
         "found":{"count":1,"total":10},"found_label":"Found 1/10 traits",
         "subtitle":"Build a travel personality that gets more personal with every trip.",
         "profile":{"title":"Traveler profile","min":0,"max":100,"traits":[
           {"trait":"adventure","name":"Adventure","score":72,
            "next":{"go":"persona_trait","trait":"adventure","profile_id":"main"},
            "submit":{"action":"set_persona_score","trait":"adventure","profile_id":"main"}},
           {"trait":"new_places","name":"New Places","score":140},
           {"name":"No key"}
         ]}}
        """#.utf8))
        let persona = ProfileV3PersonaMapper.persona(dto)
        #expect(persona.title == "Travel persona")
        #expect(persona.foundLabel == "Found 1/10 traits")
        #expect(persona.profileTitle == "Traveler profile")
        #expect(persona.iconURL == ProfileV3PlaceholderArt.agentPersonal.url)
        #expect(persona.traits.map(\.id) == ["adventure", "new_places"])
        #expect(persona.traits.map(\.score) == [72, 100])
        #expect(persona.traits[0].detail?.route() == .personaTrait(trait: "adventure", profileID: "main", page: 1))
        #expect(persona.traits[0].submit?.name == "set_persona_score")
        #expect(persona.traits[1].submit == nil)
    }

    @Test func traitScreenMapsTheScaleRowsActionsAndPaging() throws {
        let dto = try JSONDecoder().decode(ProfileV3PersonaTraitScreenDTO.self, from: Data(#"""
        {"type":"persona_trait","trait":"adventure","page":1,"title":"Adventure","score":72,
         "subtitle":"Open to going beyond the obvious.",
         "scale":{"min":0,"max":100,"value":72,"labels":["Keep it safe","Balanced","Chase the rush"]},
         "calculation":{"title":"See how your score was calculated",
           "items":[
             {"id":"src-1","kind":"gmail","title":"Open water Dive course, 4 days","subtitle":"Signed up",
              "delta":12,"delta_label":"+12","ignored":false,
              "button":{"label":"Ignore","action":"ignore_persona_source","trait":"adventure","source_id":17}},
             {"id":"src-2","kind":"user","title":"Lowered to 60","subtitle":"Changes made by you",
              "delta":-3,"delta_label":"-3","ignored":true,
              "button":{"label":"Undo","action":"unignore_persona_source","trait":"adventure","source_id":"18"}}
           ],
           "bulk":{"label":"Ignore all","action":"ignore_all_persona_sources","trait":"adventure"},
           "next_page":{"go":"persona_trait","trait":"adventure","page":2}}}
        """#.utf8))
        let trait = ProfileV3PersonaMapper.trait(dto, trait: "adventure")
        #expect(trait.title == "Adventure")
        #expect(trait.score == 72)
        #expect(trait.scale.labels == ["Keep it safe", "Balanced", "Chase the rush"])
        #expect(trait.scale.activeLabelIndex == 2)
        #expect(trait.rows.map(\.kind) == [.gmail, .user])
        #expect(trait.rows.map(\.deltaLabel) == ["+12", "-3"])
        #expect(trait.rows.map(\.isIgnored) == [false, true])
        #expect(trait.rows.map { $0.action?.label } == ["Ignore", "Undo"])
        #expect(trait.rows[0].action?.submit.fields["source_id"] == .int(17))
        #expect(trait.bulk?.label == "Ignore all")
        #expect(trait.nextPage?.route() == .personaTrait(trait: "adventure", profileID: nil, page: 2))
        #expect(trait.startingPoint == nil)
    }

    @Test func scaleHighlightsTheThirdTheValueFallsIn() {
        func active(_ value: Int) -> Int? {
            ProfileV3PersonaTrait.Scale(range: 0 ... 100, value: value, labels: ["a", "b", "c"]).activeLabelIndex
        }
        #expect([0, 33, 34, 66, 67, 100].map(active) == [0, 0, 1, 1, 2, 2])
    }

    @Test func submitEchoesTheServerActionWithItsTypesAndTheScore() throws {
        let action = ProfileV3BoardAction(fields: [
            "action": .string("set_persona_score"),
            "trait": .string("adventure"),
            "source_id": .int(17)
        ])
        let body = try JSONEncoder().encode(ProfileV3PersonaSubmitRequest(action: action, score: 64))
        let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
        #expect(json["action"] as? String == "set_persona_score")
        #expect(json["trait"] as? String == "adventure")
        #expect(json["source_id"] as? Int == 17)
        #expect(json["score"] as? Int == 64)
    }

    @Test(.timeLimit(.minutes(1)))
    func releasingADragSavesThatTraitAtOnce() async throws {
        let repository = PersonaRepositoryStub()
        let viewModel = ProfileV3TravelPersonaViewModel(profileID: "main", repository: repository, isEditable: true)
        try await loaded(viewModel)

        viewModel.preview("adventure", score: 64)
        #expect(viewModel.drafts["adventure"] == 64)
        #expect(repository.submitted.isEmpty)

        viewModel.beginDrag("adventure")
        viewModel.endDrag("adventure", score: 130)
        #expect(viewModel.drafts["adventure"] == 100)
        #expect(viewModel.score(of: try #require(viewModel.content?.traits.first)) == 100)
        while viewModel.notice == nil { try await Task.sleep(for: .milliseconds(10)) }

        #expect(viewModel.notice == .saved)
        #expect(viewModel.notice?.message == ProfileV3Strings.personaUpdated)
        #expect(repository.submitted.map(\.score) == [100])
        #expect(viewModel.content?.traits.first?.score == 100)
        #expect(viewModel.drafts.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func aRefusedSaveSnapsBackAndSaysWhy() async throws {
        let repository = PersonaRepositoryStub(submitError: ProfileV3Error.notImplemented(action: "set_persona_score"))
        let viewModel = ProfileV3TravelPersonaViewModel(profileID: "main", repository: repository, isEditable: true)
        try await loaded(viewModel)

        viewModel.beginDrag("adventure")
        viewModel.endDrag("adventure", score: 80)
        while viewModel.notice == nil { try await Task.sleep(for: .milliseconds(10)) }

        #expect(viewModel.notice == .failed(ProfileV3Strings.actionUnavailable))
        #expect(viewModel.notice?.isError == true)
        #expect(viewModel.drafts.isEmpty)
        #expect(viewModel.content?.traits.first?.score == 50)
    }

    @Test(.timeLimit(.minutes(1)))
    func aDragReleasedDuringASaveIsSavedNext() async throws {
        let repository = PersonaRepositoryStub(scores: Self.board, submitDelay: .milliseconds(200))
        let viewModel = ProfileV3TravelPersonaViewModel(profileID: "main", repository: repository, isEditable: true)
        try await loaded(viewModel)

        viewModel.beginDrag("adventure")
        viewModel.endDrag("adventure", score: 70)
        try await Task.sleep(for: .milliseconds(50))
        #expect(viewModel.canEdit(try #require(viewModel.content?.traits.first(where: { $0.id == "planning" }))))
        viewModel.beginDrag("planning")
        viewModel.endDrag("planning", score: 40)
        while repository.submitted.count < 2 || !viewModel.drafts.isEmpty {
            try await Task.sleep(for: .milliseconds(10))
        }

        #expect(repository.submitted.map(\.score) == [70, 40])
        #expect(viewModel.content?.traits.first(where: { $0.id == "adventure" })?.score == 70)
        #expect(viewModel.content?.traits.first(where: { $0.id == "planning" })?.score == 40)
    }

    @Test(.timeLimit(.minutes(1)))
    func voiceOverStepsSaveOnceTheyStop() async throws {
        let repository = PersonaRepositoryStub()
        let viewModel = ProfileV3TravelPersonaViewModel(profileID: "main", repository: repository, isEditable: true)
        try await loaded(viewModel)

        viewModel.adjust("adventure", by: 5)
        viewModel.adjust("adventure", by: 5)
        #expect(viewModel.drafts["adventure"] == 60)
        try await Task.sleep(for: .milliseconds(200))
        #expect(repository.submitted.isEmpty)
        while viewModel.notice == nil { try await Task.sleep(for: .milliseconds(10)) }

        #expect(repository.submitted.map(\.score) == [60])
    }

    @Test(.timeLimit(.minutes(1)))
    func draggingBackToTheSavedScoreSavesNothing() async throws {
        let repository = PersonaRepositoryStub()
        let viewModel = ProfileV3TravelPersonaViewModel(profileID: "main", repository: repository, isEditable: true)
        try await loaded(viewModel)

        viewModel.preview("adventure", score: 64)
        viewModel.beginDrag("adventure")
        viewModel.endDrag("adventure", score: 50)
        #expect(viewModel.drafts.isEmpty)
        try await Task.sleep(for: .milliseconds(100))

        #expect(repository.submitted.isEmpty)
        #expect(viewModel.notice == nil)
    }

    @Test func theClientConfigBlocksEveryEdit() async throws {
        let repository = PersonaRepositoryStub()
        #expect(
            ProfileV3TravelPersonaViewModel(profileID: "main", repository: repository).isEditable
                == ProfileV3FeatureFlags.isPersonaEditingEnabled
        )
        let viewModel = ProfileV3TravelPersonaViewModel(profileID: "main", repository: repository, isEditable: false)
        viewModel.load()
        while viewModel.content == nil { try await Task.sleep(for: .milliseconds(10)) }

        viewModel.preview("adventure", score: 80)
        viewModel.adjust("adventure", by: 5)
        viewModel.beginDrag("adventure")
        viewModel.endDrag("adventure", score: 80)
        #expect(viewModel.drafts.isEmpty)
        #expect(!viewModel.isDragging)
        #expect(viewModel.notice == nil)

        viewModel.open("adventure")
        let trait = try #require(viewModel.trait)
        #expect(!trait.isEditable)
        trait.perform(
            ProfileV3PersonaTrait.Action(label: "Ignore", submit: ProfileV3BoardAction(fields: [:])),
            id: "src-1"
        )
        #expect(trait.busyActionIDs.isEmpty)
        #expect(repository.submitted.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func theFirstRunTipsPlayOnceOnTheHighestTraitInTheTopHalf() async throws {
        let hints = try freshHints()
        let repository = PersonaRepositoryStub(scores: Self.board)
        let viewModel = ProfileV3TravelPersonaViewModel(profileID: "main", repository: repository, isEditable: true, hints: hints)
        try await loaded(viewModel)

        viewModel.startCoach()
        #expect(viewModel.coach?.traitID == "planning")
        #expect(viewModel.coach?.steps == [.drag, .tap])
        #expect(viewModel.highlightedTraitID == "planning")
        #expect(hints.hasSeenPersonaCoach)

        viewModel.advanceCoach()
        #expect(viewModel.coach?.step == .tap)
        viewModel.advanceCoach()
        #expect(viewModel.coach == nil)

        let again = ProfileV3TravelPersonaViewModel(profileID: "main", repository: repository, isEditable: true, hints: hints)
        try await loaded(again)
        again.startCoach()
        #expect(again.coach == nil)
        #expect(again.highlightedTraitID == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func draggingTheTippedKnobMovesToTheTapTipAndATapOpensIt() async throws {
        let repository = PersonaRepositoryStub(scores: Self.board)
        let viewModel = ProfileV3TravelPersonaViewModel(
            profileID: "main",
            repository: repository,
            isEditable: true,
            hints: try freshHints()
        )
        try await loaded(viewModel)
        viewModel.startCoach()

        viewModel.beginDrag("planning")
        #expect(viewModel.isDragging)
        #expect(viewModel.coach?.step == .drag)
        #expect(viewModel.drafts.isEmpty)

        viewModel.endDrag("planning", score: 70)
        #expect(!viewModel.isDragging)
        #expect(viewModel.drafts["planning"] == 70)
        #expect(viewModel.coach?.step == .tap)

        viewModel.tap("planning")
        #expect(viewModel.trait != nil)
        #expect(viewModel.coach == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func touchingAnotherKnobEndsTheTips() async throws {
        let viewModel = ProfileV3TravelPersonaViewModel(
            profileID: "main",
            repository: PersonaRepositoryStub(scores: Self.board),
            isEditable: true,
            hints: try freshHints()
        )
        try await loaded(viewModel)
        viewModel.startCoach()
        viewModel.tap("adventure")
        #expect(viewModel.coach == nil)
        #expect(viewModel.highlightedTraitID == "adventure")
        #expect(viewModel.trait == nil)

        viewModel.tap("adventure")
        #expect(viewModel.trait != nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func aKnobTouchedBeforeTheTipsKeepsItsSelectionAndTheTipsWait() async throws {
        let hints = try freshHints()
        let viewModel = ProfileV3TravelPersonaViewModel(
            profileID: "main",
            repository: PersonaRepositoryStub(scores: Self.board),
            isEditable: true,
            hints: hints
        )
        try await loaded(viewModel)
        viewModel.tap("adventure")
        viewModel.startCoach()
        #expect(viewModel.coach == nil)
        #expect(viewModel.highlightedTraitID == "adventure")
        #expect(!hints.hasSeenPersonaCoach)
    }

    @Test(.timeLimit(.minutes(1)))
    func withEditingOffTheTipsOnlyTeachTheTapAndKnobsDoNotDrag() async throws {
        let viewModel = ProfileV3TravelPersonaViewModel(
            profileID: "main",
            repository: PersonaRepositoryStub(scores: Self.board),
            isEditable: false,
            hints: try freshHints()
        )
        try await loaded(viewModel)
        viewModel.startCoach()
        #expect(viewModel.coach?.steps == [.tap])

        viewModel.beginDrag("planning")
        #expect(!viewModel.isDragging)
        viewModel.endDrag("planning", score: 70)
        #expect(viewModel.drafts.isEmpty)
        #expect(viewModel.coach?.step == .tap)
    }

    @Test func theRippleRestsOnTheDesignRingsAndLoops() {
        typealias Persona = ProfileV3Theme.Sizes.Persona
        let still = (0 ..< Persona.rippleRings).map { ProfileV3PersonaRipple.ring($0, at: nil) }
        #expect(still == [
            ProfileV3PersonaRipple.Ring(diameter: 35, opacity: 0.1),
            ProfileV3PersonaRipple.Ring(diameter: 53, opacity: 0.05)
        ])

        let period = ProfileV3Theme.Motion.personaRippleSeconds
        #expect(ProfileV3PersonaRipple.ring(0, at: 0).diameter == Persona.handleHighlighted)
        #expect(ProfileV3PersonaRipple.ring(0, at: 0).opacity == 0)
        #expect(ProfileV3PersonaRipple.ring(1, at: period / 4).opacity == 0)

        let innerProgress = Double((Persona.rippleInner - Persona.rippleStart) / (Persona.rippleEnd - Persona.rippleStart))
        let atRest = period * (1 + innerProgress)
        let inner = ProfileV3PersonaRipple.ring(0, at: atRest)
        let outer = ProfileV3PersonaRipple.ring(1, at: atRest)
        #expect(abs(inner.diameter - 35) < 0.001)
        #expect(abs(inner.opacity - 0.1) < 0.001)
        #expect(abs(outer.diameter - 53) < 0.001)
        #expect(abs(outer.opacity - 0.05) < 0.001)
        #expect(ProfileV3PersonaRipple.ring(0, at: period * 0.999).opacity < 0.01)
    }

    @Test(.timeLimit(.minutes(1)))
    func theLoaderHoldsTheResponseUntilALoopEnds() async throws {
        let viewModel = ProfileV3TravelPersonaViewModel(profileID: "main", repository: PersonaRepositoryStub(), isEditable: true)
        viewModel.load()
        #expect(viewModel.isDecoding)
        viewModel.finishDecodingLoop()
        #expect(viewModel.isDecoding)

        while viewModel.content == nil { try await Task.sleep(for: .milliseconds(10)) }
        #expect(viewModel.isDecoding)
        viewModel.finishDecodingLoop()
        #expect(!viewModel.isDecoding)

        viewModel.load()
        #expect(!viewModel.isDecoding)
    }

    @Test(.timeLimit(.minutes(1)))
    func aFailedLoadWaitsForTheLoopAndARetryDecodesAgain() async throws {
        let viewModel = ProfileV3TravelPersonaViewModel(
            profileID: "main",
            repository: PersonaRepositoryStub(loadError: ProfileV3RepositoryError.unavailable),
            isEditable: true
        )
        viewModel.load()
        while viewModel.phase != .failed { try await Task.sleep(for: .milliseconds(10)) }
        #expect(viewModel.isDecoding)
        viewModel.finishDecodingLoop()
        #expect(!viewModel.isDecoding)

        viewModel.load()
        #expect(viewModel.isDecoding)
    }

    private static let board = [
        ("adventure", 56), ("new_places", 85), ("outdoors", 47), ("social", 56), ("nightlife", 60),
        ("pace", 50), ("local", 32), ("culture", 95), ("comfort", 50), ("planning", 90)
    ]

    private func freshHints() throws -> ProfileV3HubHints {
        let suite = "profileV3.tests.persona.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return ProfileV3HubHints(defaults: defaults)
    }

    private func loaded(_ viewModel: ProfileV3TravelPersonaViewModel) async throws {
        viewModel.load()
        while viewModel.content == nil { try await Task.sleep(for: .milliseconds(10)) }
    }
}

private final class PersonaRepositoryStub: ProfileV3PersonaRepository, @unchecked Sendable {
    struct Submission {
        let action: ProfileV3BoardAction
        let score: Int?
    }

    private let lock = NSLock()
    private let order: [String]
    private var scores: [String: Int]
    private var _submitted: [Submission] = []
    private let submitError: Error?
    private let loadError: Error?
    private let submitDelay: Duration

    init(
        submitError: Error? = nil,
        scores: [(String, Int)] = [("adventure", 50)],
        loadError: Error? = nil,
        submitDelay: Duration = .zero
    ) {
        self.submitError = submitError
        self.loadError = loadError
        self.submitDelay = submitDelay
        order = scores.map(\.0)
        self.scores = Dictionary(uniqueKeysWithValues: scores)
    }

    var submitted: [Submission] {
        lock.lock()
        defer { lock.unlock() }
        return _submitted
    }

    func loadTravelPersona(profileID: String?) async throws -> ProfileV3TravelPersona {
        if let loadError { throw loadError }
        let scores = lock.withLock { self.scores }
        return ProfileV3TravelPersona(
            title: "Travel persona",
            iconURL: nil,
            foundLabel: "Found 0/\(order.count) traits",
            subtitle: "",
            profileTitle: "Traveler profile",
            range: 0 ... 100,
            traits: order.map { id in
                ProfileV3TravelPersona.Trait(
                    id: id,
                    name: id.capitalized,
                    score: scores[id] ?? 50,
                    detail: ProfileV3Directive(go: "persona_trait", profileID: profileID, trait: id),
                    submit: ProfileV3BoardAction(fields: [
                        "action": .string("set_persona_score"),
                        "trait": .string(id),
                        "profile_id": .string(profileID ?? "")
                    ])
                )
            }
        )
    }

    func loadPersonaTrait(_: String, profileID _: String?, page _: Int) async throws -> ProfileV3PersonaTrait {
        throw ProfileV3RepositoryError.unavailable
    }

    func submitPersonaAction(_ action: ProfileV3BoardAction, score: Int?) async throws {
        if submitDelay > .zero { try await Task.sleep(for: submitDelay) }
        if let submitError { throw submitError }
        lock.withLock {
            _submitted.append(Submission(action: action, score: score))
            if let score, case .string(let id)? = action.fields["trait"] { scores[id] = score }
        }
    }
}
