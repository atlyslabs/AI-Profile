import Foundation

@MainActor
final class ProfileV3PassportReasonViewModel: ObservableObject {
    @Published private(set) var screen: ProfileV3PassportReasonScreen = .fallback
    @Published var selection: String?
    @Published private(set) var isSubmitting = false
    @Published private(set) var submitFailed = false

    private let repository: any ProfileV3AgentRepository
    private let profileID: String?
    private let onSubmitted: () -> Void
    private var loadTask: Task<Void, Never>?
    private var submitTask: Task<Void, Never>?

    init(
        repository: any ProfileV3AgentRepository,
        profileID: String? = nil,
        onSubmitted: @escaping () -> Void
    ) {
        self.repository = repository
        self.profileID = profileID
        self.onSubmitted = onSubmitted
    }

    func load() {
        loadTask?.cancel()
        let repository = repository
        loadTask = Task { [weak self] in
            guard let screen = try? await repository.loadPassportReason(), let self, !Task.isCancelled else { return }
            self.screen = screen
            if let selection, !screen.options.contains(where: { $0.value == selection }) {
                self.selection = nil
            }
        }
    }

    func submit() {
        guard let reason = selection, !isSubmitting else { return }
        isSubmitting = true
        submitFailed = false
        let repository = repository
        let profileID = profileID
        submitTask = Task { [weak self] in
            do {
                try await repository.updatePassport(reason: reason, profileID: profileID)
                guard let self, !Task.isCancelled else { return }
                isSubmitting = false
                onSubmitted()
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                isSubmitting = false
                submitFailed = true
            }
        }
    }

    func cancel() {
        loadTask?.cancel()
        submitTask?.cancel()
    }
}
