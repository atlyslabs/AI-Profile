import Foundation

@MainActor
final class ProfileV3TravelPersonaViewModel: ObservableObject {
    enum Notice: Equatable {
        case saved
        case failed(String)

        var message: String {
            switch self {
            case .saved: return ProfileV3Strings.personaUpdated
            case .failed(let message): return message
            }
        }

        var isError: Bool {
            if case .failed = self { return true }
            return false
        }
    }

    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var content: ProfileV3TravelPersona?
    @Published private(set) var highlightedTraitID: String?
    @Published private(set) var drafts: [String: Int] = [:]
    @Published private(set) var notice: Notice?
    @Published private(set) var draggingTraitID: String?
    @Published private(set) var coach: ProfileV3PersonaCoach?
    @Published private(set) var isDecoding = false
    @Published var trait: ProfileV3PersonaTraitViewModel?

    let isEditable: Bool
    var onClose: () -> Void

    private let profileID: String?
    private let repository: any ProfileV3PersonaRepository
    private let hints: ProfileV3HubHints
    private var loadTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?
    private var adjustTask: Task<Void, Never>?
    private var noticeTask: Task<Void, Never>?
    private var savesAgain = false

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

    var isDragging: Bool { draggingTraitID != nil }

    func canEdit(_ trait: ProfileV3TravelPersona.Trait) -> Bool {
        isEditable && trait.submit != nil
    }

    func load() {
        if content == nil { isDecoding = true }
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

    func finishDecodingLoop() {
        guard isDecoding, phase != .loading else { return }
        isDecoding = false
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
        saveDrafts()
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
        guard isEditable, let content,
              let trait = content.traits.first(where: { $0.id == traitID }), trait.submit != nil else { return }
        highlightedTraitID = traitID
        let value = content.clamped(score)
        drafts[traitID] = value == trait.score ? nil : value
    }

    func adjust(_ traitID: String, by step: Int) {
        guard isEditable, let trait = content?.traits.first(where: { $0.id == traitID }) else { return }
        preview(traitID, score: score(of: trait) + step)
        adjustTask?.cancel()
        adjustTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.personaAdjustSaveMilliseconds))
            guard let self, !Task.isCancelled else { return }
            saveDrafts()
        }
    }

    private func saveDrafts() {
        guard isEditable else { return }
        guard saveTask == nil else {
            savesAgain = true
            return
        }
        saveTask = Task { [weak self] in
            await self?.runSaves()
        }
    }

    private func runSaves() async {
        repeat {
            savesAgain = false
            guard let content else { break }
            let changes: [(id: String, submit: ProfileV3BoardAction, score: Int)] = content.traits.compactMap { trait in
                guard let score = drafts[trait.id], score != trait.score, let submit = trait.submit else { return nil }
                return (trait.id, submit, score)
            }
            guard !changes.isEmpty else { break }
            var failure: (any Error)?
            do {
                for change in changes {
                    try await repository.submitPersonaAction(change.submit, score: change.score)
                }
            } catch {
                failure = error
            }
            let refreshed = try? await repository.loadTravelPersona(profileID: profileID)
            guard !Task.isCancelled else { return }
            if let refreshed {
                self.content = refreshed
            } else if failure == nil {
                for change in changes {
                    guard let index = self.content?.traits.firstIndex(where: { $0.id == change.id }) else { continue }
                    self.content?.traits[index].score = change.score
                }
            }
            for change in changes where drafts[change.id] == change.score {
                drafts[change.id] = nil
            }
            if let failure {
                show(.failed(ProfileV3Error.message(for: failure, fallback: ProfileV3Strings.saveFailed)))
            } else {
                show(.saved)
            }
        } while savesAgain
        saveTask = nil
    }

    private func show(_ notice: Notice) {
        noticeTask?.cancel()
        self.notice = notice
        let milliseconds = notice.isError
            ? ProfileV3Theme.Motion.toastDismissMilliseconds
            : ProfileV3Theme.Motion.savedDismissMilliseconds
        noticeTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(milliseconds))
            guard let self, !Task.isCancelled else { return }
            self.notice = nil
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
        saveTask = nil
        adjustTask?.cancel()
        noticeTask?.cancel()
        trait?.cancel()
    }
}
