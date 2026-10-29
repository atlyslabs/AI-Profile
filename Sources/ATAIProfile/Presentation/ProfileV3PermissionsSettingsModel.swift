import Combine
import Foundation
import SwiftUI

@MainActor
final class ProfileV3PermissionsSettingsModel: ObservableObject {
    @Published private(set) var permissions: ProfileV3Permissions?
    @Published private(set) var phase: ProfileV3LoadPhase = .loading

    weak var navigator: ProfileV3SettingsNavigating?

    private let repository: any ProfileV3PermissionsRepository
    private var loadTask: Task<Void, Never>?
    private var saveGenerations: [String: Int] = [:]

    init(repository: any ProfileV3PermissionsRepository) {
        self.repository = repository
    }

    func open() {
        ProfileV3Analytics.screen(.permissions)
        navigator?.push(.permissions)
        load()
    }

    func preload() {
        guard permissions == nil else { return }
        load()
    }

    func load() {
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.permissions,
            fetch: { try await repository.loadPermissions() },
            apply: { $0.permissions = $1 }
        )
    }

    func select(_ optionID: String, in rowID: String) {
        guard let permissions else { return }
        let previous = permissions.selectedOptionID(in: rowID)
        guard previous != optionID else { return }
        show(permissions.selecting(optionID, in: rowID))
        let generation = (saveGenerations[rowID] ?? 0) + 1
        saveGenerations[rowID] = generation
        let repository = repository
        Task { [weak self] in
            do {
                try await repository.savePermission(optionID, for: rowID)
                ProfileV3Analytics.permissionChanged(key: rowID, to: optionID, from: previous)
            } catch {
                guard let self, self.saveGenerations[rowID] == generation,
                      let current = self.permissions,
                      current.selectedOptionID(in: rowID) == optionID else { return }
                self.show(current.selecting(previous, in: rowID))
            }
        }
    }

    func cancelReads() {
        loadTask?.cancel()
    }

    private func show(_ permissions: ProfileV3Permissions) {
        withAnimation(ProfileV3Theme.Motion.selection) {
            self.permissions = permissions
        }
    }
}
