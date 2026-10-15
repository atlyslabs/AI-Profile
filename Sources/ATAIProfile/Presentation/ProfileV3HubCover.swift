import Combine
import SwiftUI

@MainActor
final class ProfileV3HubCover: ObservableObject {
    @Published var isPresented = false
    @Published private(set) var isMounted = false

    private var pendingAction: (() -> Void)?
    private var lowerTask: Task<Void, Never>?

    func present(then action: @escaping () -> Void) {
        guard isPresented, isMounted else {
            pendingAction = action
            raise()
            return
        }
        lowerTask?.cancel()
        action()
    }

    func update(isCovering: Bool) {
        if isCovering {
            raise()
        } else {
            lower()
        }
    }

    func didAppear(isCovering: () -> Bool) {
        withAnimation(ProfileV3Theme.Motion.entry) { isMounted = true }
        let action = pendingAction
        pendingAction = nil
        action?()
        if !isCovering() {
            lower()
        }
    }

    func didDismiss() {
        isMounted = false
    }

    private func raise() {
        lowerTask?.cancel()
        guard !isPresented else { return }
        Self.withoutAnimation { isPresented = true }
    }

    private func lower() {
        lowerTask?.cancel()
        guard isPresented else { return }
        lowerTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.contentFadeMilliseconds))
            guard let self, !Task.isCancelled else { return }
            Self.withoutAnimation { self.isPresented = false }
        }
    }

    private static func withoutAnimation(_ body: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction, body)
    }
}
