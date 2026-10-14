import Foundation

@MainActor
final class ProfileV3WriteQueue {
    private(set) var pending: Task<Void, Never>?

    @discardableResult
    func enqueue(_ work: @escaping () async -> Void) -> Task<Void, Never> {
        let previous = pending
        let task = Task {
            await previous?.value
            await work()
        }
        pending = task
        return task
    }

    static func wait(for task: Task<Void, Never>?, timeout: Duration) async {
        guard let task else { return }
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await task.value }
            group.addTask { try? await Task.sleep(for: timeout) }
            await group.next()
            group.cancelAll()
        }
    }
}
