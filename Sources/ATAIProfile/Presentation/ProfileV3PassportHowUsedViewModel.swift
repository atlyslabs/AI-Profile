import Foundation

@MainActor
final class ProfileV3PassportHowUsedViewModel: ObservableObject, Identifiable {
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var content: ProfileV3PassportHowUsed?

    let id = UUID()
    private let repository: any ProfileV3AgentRepository
    private var loadTask: Task<Void, Never>?

    init(repository: any ProfileV3AgentRepository) {
        self.repository = repository
    }

    func load() {
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.content,
            fetch: { try await repository.loadPassportHowUsed() },
            apply: { $0.content = $1 }
        )
    }

    func cancel() {
        loadTask?.cancel()
    }
}
