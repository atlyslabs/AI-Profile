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
    func draggingOnlyDraftsAndTheSaveButtonSubmits() async throws {
        let repository = PersonaRepositoryStub()
        let viewModel = ProfileV3TravelPersonaViewModel(profileID: "main", repository: repository, isEditable: true)
        viewModel.load()
        while viewModel.content == nil { try await Task.sleep(for: .milliseconds(10)) }

        viewModel.preview("adventure", score: 130)
        #expect(viewModel.drafts["adventure"] == 100)
        viewModel.preview("adventure", score: 64)
        #expect(viewModel.showsSaveBar)
        #expect(repository.submitted.isEmpty)
        #expect(viewModel.score(of: try #require(viewModel.content?.traits.first)) == 64)

        viewModel.save()
        #expect(viewModel.savePhase == .saving)
        while viewModel.savePhase != .saved { try await Task.sleep(for: .milliseconds(10)) }

        #expect(repository.submitted.map(\.score) == [64])
        #expect(viewModel.content?.traits.first?.score == 64)
        #expect(viewModel.drafts.isEmpty)
        #expect(viewModel.saveError == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func aRefusedSaveKeepsTheDraftAndSaysWhy() async throws {
        let repository = PersonaRepositoryStub(submitError: ProfileV3Error.notImplemented(action: "set_persona_score"))
        let viewModel = ProfileV3TravelPersonaViewModel(profileID: "main", repository: repository, isEditable: true)
        viewModel.load()
        while viewModel.content == nil { try await Task.sleep(for: .milliseconds(10)) }

        viewModel.preview("adventure", score: 80)
        viewModel.save()
        while viewModel.saveError == nil { try await Task.sleep(for: .milliseconds(10)) }

        #expect(viewModel.savePhase == .idle)
        #expect(viewModel.saveError == ProfileV3Strings.actionUnavailable)
        #expect(viewModel.drafts["adventure"] == 80)
        #expect(viewModel.content?.traits.first?.score == 50)
        #expect(viewModel.showsSaveBar)
    }

    @Test func draggingBackToTheSavedScoreLeavesNothingToSave() async throws {
        let repository = PersonaRepositoryStub()
        let viewModel = ProfileV3TravelPersonaViewModel(profileID: "main", repository: repository, isEditable: true)
        viewModel.load()
        while viewModel.content == nil { try await Task.sleep(for: .milliseconds(10)) }

        viewModel.preview("adventure", score: 64)
        viewModel.preview("adventure", score: 50)
        #expect(viewModel.drafts.isEmpty)
        #expect(!viewModel.showsSaveBar)
        viewModel.save()
        #expect(viewModel.savePhase == .idle)
        #expect(repository.submitted.isEmpty)
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
        viewModel.save()
        #expect(viewModel.drafts.isEmpty)
        #expect(!viewModel.showsSaveBar)
        #expect(viewModel.savePhase == .idle)

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
}

private final class PersonaRepositoryStub: ProfileV3PersonaRepository, @unchecked Sendable {
    struct Submission {
        let action: ProfileV3BoardAction
        let score: Int?
    }

    private let lock = NSLock()
    private var scores = ["adventure": 50]
    private var _submitted: [Submission] = []
    private let submitError: Error?

    init(submitError: Error? = nil) {
        self.submitError = submitError
    }

    var submitted: [Submission] {
        lock.lock()
        defer { lock.unlock() }
        return _submitted
    }

    func loadTravelPersona(profileID: String?) async throws -> ProfileV3TravelPersona {
        let score = lock.withLock { scores["adventure"] ?? 50 }
        return ProfileV3TravelPersona(
            title: "Travel persona",
            iconURL: nil,
            foundLabel: "Found 0/1 traits",
            subtitle: "",
            profileTitle: "Traveler profile",
            range: 0 ... 100,
            traits: [
                ProfileV3TravelPersona.Trait(
                    id: "adventure",
                    name: "Adventure",
                    score: score,
                    detail: ProfileV3Directive(go: "persona_trait", profileID: profileID, trait: "adventure"),
                    submit: ProfileV3BoardAction(fields: [
                        "action": .string("set_persona_score"),
                        "trait": .string("adventure"),
                        "profile_id": .string(profileID ?? "")
                    ])
                )
            ]
        )
    }

    func loadPersonaTrait(_: String, profileID _: String?, page _: Int) async throws -> ProfileV3PersonaTrait {
        throw ProfileV3RepositoryError.unavailable
    }

    func submitPersonaAction(_ action: ProfileV3BoardAction, score: Int?) async throws {
        if let submitError { throw submitError }
        lock.withLock {
            _submitted.append(Submission(action: action, score: score))
            if let score { scores["adventure"] = score }
        }
    }
}
