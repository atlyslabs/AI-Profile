import Foundation

@MainActor
final class ProfileV3ScreenLoader<Content>: ObservableObject, Identifiable {
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var content: Content?

    let id = UUID()
    private let fetch: () async throws -> Content
    private let onClose: () -> Void
    private var loadTask: Task<Void, Never>?

    init(fetch: @escaping () async throws -> Content, onClose: @escaping () -> Void = {}) {
        self.fetch = fetch
        self.onClose = onClose
    }

    func load() {
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.content,
            fetch: fetch,
            apply: { $0.content = $1 }
        )
    }

    func loadIfNeeded() {
        guard content == nil else { return }
        load()
    }

    func close() {
        cancel()
        onClose()
    }

    func cancel() {
        loadTask?.cancel()
    }
}

typealias ProfileV3RideRegionsViewModel = ProfileV3ScreenLoader<ProfileV3RideRegions>
typealias ProfileV3PassportHowUsedViewModel = ProfileV3ScreenLoader<ProfileV3PassportHowUsed>
typealias ProfileV3SourcesViewModel = ProfileV3ScreenLoader<ProfileV3PreferenceSources>
typealias ProfileV3TermsViewModel = ProfileV3ScreenLoader<ProfileV3Terms>

extension ProfileV3ScreenLoader where Content == ProfileV3RideRegions {
    convenience init(repository: any ProfileV3AgentRepository, onClose: @escaping () -> Void) {
        self.init(fetch: { try await repository.loadRideRegions() }, onClose: onClose)
    }
}

extension ProfileV3ScreenLoader where Content == ProfileV3PassportHowUsed {
    convenience init(repository: any ProfileV3AgentRepository) {
        self.init(fetch: { try await repository.loadPassportHowUsed() })
    }
}

extension ProfileV3ScreenLoader where Content == ProfileV3PreferenceSources {
    convenience init(source: ProfileV3SectionSource, profileID: String?, repository: any ProfileV3AgentRepository) {
        self.init(fetch: { try await repository.loadPreferenceSources(source, profileID: profileID) })
    }

    convenience init(programID: String, profileID: String?, repository: any ProfileV3LoyaltyRepository) {
        self.init(fetch: { try await repository.loadProgrammeSources(programID: programID, profileID: profileID) })
    }
}

extension ProfileV3ScreenLoader where Content == ProfileV3Terms {
    convenience init(loadTerms: @escaping () async throws -> ProfileV3Terms?) {
        self.init(fetch: {
            guard let terms = try await loadTerms() else { throw ProfileV3RepositoryError.unavailable }
            return terms
        })
    }
}
