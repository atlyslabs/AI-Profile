import Foundation

enum ProfileV3SavePhase: Equatable {
    case idle
    case saving
    case saved
}

enum ProfileV3LoadPhase: Equatable {
    case loading
    case loaded
    case failed
}

@MainActor
enum ProfileV3PhasedLoad {
    static func start<Owner: AnyObject, Value>(
        on owner: Owner,
        task: ReferenceWritableKeyPath<Owner, Task<Void, Never>?>,
        phase: ReferenceWritableKeyPath<Owner, ProfileV3LoadPhase>,
        content: KeyPath<Owner, Value?>,
        fetch: @escaping () async throws -> Value,
        apply: @escaping (Owner, Value) -> Void
    ) {
        owner[keyPath: task]?.cancel()
        set(phase, on: owner, to: owner[keyPath: content] == nil ? .loading : .loaded)
        owner[keyPath: task] = Task { [weak owner] in
            do {
                let value = try await fetch()
                guard let owner, !Task.isCancelled else { return }
                apply(owner, value)
                set(phase, on: owner, to: .loaded)
            } catch is CancellationError {
                return
            } catch {
                guard let owner, !Task.isCancelled else { return }
                set(phase, on: owner, to: owner[keyPath: content] == nil ? .failed : .loaded)
            }
        }
    }

    private static func set<Owner: AnyObject>(
        _ phase: ReferenceWritableKeyPath<Owner, ProfileV3LoadPhase>,
        on owner: Owner,
        to value: ProfileV3LoadPhase
    ) {
        guard owner[keyPath: phase] != value else { return }
        owner[keyPath: phase] = value
    }
}
