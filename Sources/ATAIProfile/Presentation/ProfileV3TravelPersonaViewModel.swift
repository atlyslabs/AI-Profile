import Foundation

@MainActor
final class ProfileV3TravelPersonaViewModel: ObservableObject {
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var content: ProfileV3TravelPersona?
    @Published private(set) var highlightedTraitID: String?
    @Published private(set) var drafts: [String: Int] = [:]
    @Published private(set) var savePhase: ProfileV3SavePhase = .idle
    @Published private(set) var saveError: String?
    @Published private(set) var draggingTraitID: String?
    @Published private(set) var coach: ProfileV3PersonaCoach?
    @Published var trait: ProfileV3PersonaTraitViewModel?

    let isEditable: Bool
    var onClose: () -> Void

    private let profileID: String?
    private let repository: any ProfileV3PersonaRepository
    private let hints: ProfileV3HubHints
    private var loadTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?

    init(
        profileID: String?,
        repository: any ProfileV3PersonaRepository,
        isEditable: Bool = ProfileV3FeatureFlags.isPersonaEditingEnabled,
        hints: ProfileV3HubHints = ProfileV3HubHints(),
        onClose: @escaping () -> Void = {}
    ) {
        self.profileID = profileID
        self.repository = repository
        self.isEditable = isEditable
        self.hints = hints
        self.onClose = onClose
    }

    var hasChanges: Bool { !drafts.isEmpty }

    var isDragging: Bool { draggingTraitID != nil }

    var showsSaveBar: Bool {
        isEditable && (hasChanges || savePhase != .idle)
    }

    func canEdit(_ trait: ProfileV3TravelPersona.Trait) -> Bool {
        isEditable && savePhase == .idle && trait.submit != nil
    }

    func load() {
        let repository = repository
        let profileID = profileID
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.content,
            fetch: { try await repository.loadTravelPersona(profileID: profileID) },
            apply: { $0.content = $1 }
        )
    }

    func score(of trait: ProfileV3TravelPersona.Trait) -> Int {
        drafts[trait.id] ?? trait.score
    }

    func tap(_ traitID: String) {
        guard highlightedTraitID == traitID else {
            highlightedTraitID = traitID
            if coach?.traitID != traitID { coach = nil }
            return
        }
        open(traitID)
    }

    func beginDrag(_ traitID: String) {
        guard let trait = content?.traits.first(where: { $0.id == traitID }), canEdit(trait) else { return }
        draggingTraitID = traitID
        if highlightedTraitID != traitID { highlightedTraitID = traitID }
        if coach?.traitID != traitID { coach = nil }
    }

    func endDrag(_ traitID: String, score: Int) {
        guard draggingTraitID == traitID else { return }
        draggingTraitID = nil
        preview(traitID, score: score)
        if coach?.traitID == traitID, coach?.step == .drag { advanceCoach() }
    }

    func startCoach() {
        guard coach == nil, trait == nil, highlightedTraitID == nil, !isDragging, !hints.hasSeenPersonaCoach, let content,
              let coach = ProfileV3PersonaCoach(traits: content.traits, isEditable: isEditable) else { return }
        hints.hasSeenPersonaCoach = true
        highlightedTraitID = coach.traitID
        self.coach = coach
    }

    func advanceCoach() {
        coach = coach?.advanced()
    }

    func preview(_ traitID: String, score: Int) {
        guard isEditable, savePhase == .idle, let content,
              let trait = content.traits.first(where: { $0.id == traitID }), trait.submit != nil else { return }
        highlightedTraitID = traitID
        saveError = nil
        let value = content.clamped(score)
        drafts[traitID] = value == trait.score ? nil : value
    }

    func adjust(_ traitID: String, by step: Int) {
        guard let trait = content?.traits.first(where: { $0.id == traitID }) else { return }
        preview(traitID, score: score(of: trait) + step)
    }

    func save() {
        guard isEditable, savePhase == .idle, let content else { return }
        let changes: [(ProfileV3BoardAction, Int)] = content.traits.compactMap { trait in
            guard let score = drafts[trait.id], score != trait.score, let submit = trait.submit else { return nil }
            return (submit, score)
        }
        guard !changes.isEmpty else {
            drafts = [:]
            return
        }
        savePhase = .saving
        saveError = nil
        let profileID = profileID
        saveTask = Task { [weak self, repository] in
            do {
                for (submit, score) in changes {
                    try await repository.submitPersonaAction(submit, score: score)
                }
                let refreshed = try? await repository.loadTravelPersona(profileID: profileID)
                guard let self, !Task.isCancelled else { return }
                if let refreshed { self.content = refreshed }
                drafts = [:]
                savePhase = .saved
                try await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.savedDismissMilliseconds))
                guard !Task.isCancelled else { return }
                savePhase = .idle
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                savePhase = .idle
                saveError = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed)
            }
        }
    }

    func open(_ traitID: String) {
        guard trait == nil,
              let detail = content?.traits.first(where: { $0.id == traitID })?.detail,
              case .personaTrait(let id, let traitProfileID, let page) = detail.route(fallbackProfileID: profileID) else {
            return
        }
        highlightedTraitID = traitID
        let viewModel = ProfileV3PersonaTraitViewModel(
            traitID: id,
            profileID: traitProfileID,
            page: page,
            repository: repository,
            isEditable: isEditable,
            onChanged: { [weak self] in self?.load() }
        )
        viewModel.load()
        coach = nil
        trait = viewModel
    }

    func closeTrait() {
        trait?.cancel()
        trait = nil
    }

    func close() {
        cancel()
        onClose()
    }

    func cancel() {
        loadTask?.cancel()
        saveTask?.cancel()
        trait?.cancel()
    }
}
