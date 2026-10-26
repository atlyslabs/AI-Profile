import Foundation

@MainActor
final class ProfileV3RideRegionsViewModel: ObservableObject, Identifiable {
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var content: ProfileV3RideRegions?

    let id = UUID()
    private let repository: any ProfileV3AgentRepository
    private let onClose: () -> Void
    private var loadTask: Task<Void, Never>?

    init(repository: any ProfileV3AgentRepository, onClose: @escaping () -> Void) {
        self.repository = repository
        self.onClose = onClose
    }

    func load() {
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.content,
            fetch: { try await repository.loadRideRegions() },
            apply: { $0.content = $1 }
        )
    }

    func close() {
        cancel()
        onClose()
    }

    func cancel() {
        loadTask?.cancel()
    }
}
