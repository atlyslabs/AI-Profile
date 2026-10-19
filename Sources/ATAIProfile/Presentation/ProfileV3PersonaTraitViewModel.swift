import Foundation

@MainActor
final class ProfileV3PersonaTraitViewModel: ObservableObject {
    static let bulkID = "bulk"

    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var content: ProfileV3PersonaTrait?
    @Published private(set) var isLoadingMore = false
    @Published private(set) var busyActionIDs: Set<String> = []
    @Published private(set) var toast: String?

    let traitID: String
    let isEditable: Bool
    private let profileID: String?
    private let firstPage: Int
    private let repository: any ProfileV3PersonaRepository
    private let onChanged: () -> Void
    private var loadTask: Task<Void, Never>?
    private var moreTask: Task<Void, Never>?
    private var actionTasks: [String: Task<Void, Never>] = [:]
    private var toastTask: Task<Void, Never>?

    init(
        traitID: String,
        profileID: String?,
        page: Int = 1,
        repository: any ProfileV3PersonaRepository,
        isEditable: Bool = ProfileV3FeatureFlags.isPersonaEditingEnabled,
        onChanged: @escaping () -> Void = {}
    ) {
        self.traitID = traitID
        self.profileID = profileID
        firstPage = page
        self.repository = repository
        self.isEditable = isEditable
        self.onChanged = onChanged
    }

    func load() {
        moreTask?.cancel()
        isLoadingMore = false
        let repository = repository
        let traitID = traitID
        let profileID = profileID
        let page = firstPage
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.content,
            fetch: { try await repository.loadPersonaTrait(traitID, profileID: profileID, page: page) },
            apply: { $0.content = $1 }
        )
    }

    func loadMore() {
        guard !isLoadingMore,
              let next = content?.nextPage,
              case .personaTrait(let trait, let pageProfileID, let page) = next.route(fallbackProfileID: profileID) else {
            return
        }
        isLoadingMore = true
        moreTask = Task { [weak self, repository] in
            let result = try? await repository.loadPersonaTrait(trait, profileID: pageProfileID, page: page)
            guard let self, !Task.isCancelled else { return }
            isLoadingMore = false
            guard let result, var merged = content else { return }
            let known = Set(merged.rows.map(\.id))
            merged.rows += result.rows.filter { !known.contains($0.id) }
            merged.nextPage = result.nextPage
            merged.startingPoint = result.startingPoint ?? merged.startingPoint
            content = merged
        }
    }

    func perform(_ action: ProfileV3PersonaTrait.Action, id: String) {
        guard isEditable, !busyActionIDs.contains(id) else { return }
        busyActionIDs.insert(id)
        actionTasks[id] = Task { [weak self, repository] in
            do {
                try await repository.submitPersonaAction(action.submit, score: nil)
                guard let self, !Task.isCancelled else { return }
                busyActionIDs.remove(id)
                load()
                onChanged()
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                busyActionIDs.remove(id)
                showToast(ProfileV3Error.message(for: error))
            }
        }
    }

    func cancel() {
        loadTask?.cancel()
        moreTask?.cancel()
        actionTasks.values.forEach { $0.cancel() }
        toastTask?.cancel()
    }

    private func showToast(_ message: String) {
        toastTask?.cancel()
        toast = message
        toastTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.toastDismissMilliseconds))
            guard let self, !Task.isCancelled else { return }
            toast = nil
        }
    }
}
