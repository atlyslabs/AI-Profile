import Foundation

@MainActor
final class ProfileV3PreferenceSourcesViewModel: ObservableObject {
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var content: ProfileV3PreferenceSources?

    let section: ProfileV3FormSection
    private let source: ProfileV3SectionSource
    private let profileID: String?
    private let repository: any ProfileV3AgentRepository
    private var loadTask: Task<Void, Never>?

    init(
        section: ProfileV3FormSection,
        source: ProfileV3SectionSource,
        profileID: String?,
        repository: any ProfileV3AgentRepository
    ) {
        self.section = section
        self.source = source
        self.profileID = profileID
        self.repository = repository
    }

    func load() {
        let source = source
        let profileID = profileID
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.content,
            fetch: { try await repository.loadPreferenceSources(source, profileID: profileID) },
            apply: { $0.content = $1 }
        )
    }

    func cancel() {
        loadTask?.cancel()
    }
}
