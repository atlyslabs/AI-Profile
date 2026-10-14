import Combine
import Foundation

@MainActor
final class ProfileV3TermsViewModel: ObservableObject {
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var terms: ProfileV3Terms?

    private let loadTerms: () async throws -> ProfileV3Terms?
    private var loadTask: Task<Void, Never>?

    init(loadTerms: @escaping () async throws -> ProfileV3Terms?) {
        self.loadTerms = loadTerms
    }

    func load() {
        guard terms == nil, loadTask == nil else { return }
        phase = .loading
        loadTask = Task { [weak self, loadTerms] in
            let loaded: ProfileV3Terms?
            do {
                loaded = try await loadTerms()
            } catch {
                loaded = nil
            }
            guard let self else { return }
            loadTask = nil
            terms = loaded
            phase = loaded == nil ? .failed : .loaded
        }
    }
}
