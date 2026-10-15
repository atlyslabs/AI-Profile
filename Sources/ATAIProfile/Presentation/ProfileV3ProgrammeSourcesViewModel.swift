import Foundation

@MainActor
final class ProfileV3ProgrammeSourcesViewModel: ObservableObject {
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var content: ProfileV3PreferenceSources?

    let programme: ProfileV3LoyaltyProgramme
    private let programID: String
    private let profileID: String?
    private let repository: any ProfileV3LoyaltyRepository
    private var loadTask: Task<Void, Never>?

    init(
        programme: ProfileV3LoyaltyProgramme,
        programID: String,
        profileID: String?,
        repository: any ProfileV3LoyaltyRepository
    ) {
        self.programme = programme
        self.programID = programID
        self.profileID = profileID
        self.repository = repository
    }

    func load() {
        let programID = programID
        let profileID = profileID
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.content,
            fetch: { try await repository.loadProgrammeSources(programID: programID, profileID: profileID) },
            apply: { $0.content = $1 }
        )
    }

    func cancel() {
        loadTask?.cancel()
    }
}
