import Combine
import Foundation
import SwiftUI

@MainActor
final class ProfileV3PastTripsViewModel: ObservableObject {
    enum Sheet: Equatable {
        case add
        case actions(String)
        case confirmDelete(String)
    }

    @Published private(set) var screen: ProfileV3PastTripsScreen?
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var sheet: Sheet?
    @Published private(set) var editor: ProfileV3AddPastTripViewModel?
    @Published private(set) var revealingTripID: String?
    @Published private(set) var isDeleting = false
    @Published private(set) var notice: String?
    @Published private(set) var completions = 0

    let pass: ProfileV3WorldPass

    private let repository: any ProfileV3PastTripsRepository
    private let onChange: () -> Void
    private let onClose: () -> Void
    private var startsAdding: Bool
    private var hasStarted = false
    private var isSheetDetached = false
    private var addScreen: ProfileV3AddTripScreen?
    private var loadTask: Task<Void, Never>?
    private var addScreenTask: Task<Void, Never>?
    private var addTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?

    init(
        pass: ProfileV3WorldPass,
        repository: any ProfileV3PastTripsRepository,
        startsAdding: Bool,
        onChange: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        self.pass = pass
        self.repository = repository
        self.startsAdding = startsAdding
        self.onChange = onChange
        self.onClose = onClose
    }

    var trips: [ProfileV3PastTrip] { screen?.trips ?? [] }

    var title: String { screen?.title ?? ProfileV3Strings.pastTripsTitle }

    var deleteConfirm: ProfileV3TripDeleteConfirm {
        screen?.deleteConfirm ?? ProfileV3TripDeleteConfirm(
            title: ProfileV3Strings.deletePastTripTitle,
            confirmLabel: ProfileV3Strings.proceedToDelete,
            cancelLabel: ProfileV3Strings.keepPastTrip
        )
    }

    var actionsTrip: ProfileV3PastTrip? {
        guard case .actions(let id) = sheet else { return nil }
        return trips.first { $0.id == id }
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        ProfileV3Analytics.screen(.pastTrips)
        load()
        preloadAddScreen()
        guard startsAdding else { return }
        startsAdding = false
        addTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.pastTripsAutoAddMilliseconds))
            guard !Task.isCancelled else { return }
            self?.tapAdd()
        }
    }

    func load() {
        reload(revealing: nil)
    }

    func tapAdd() {
        guard sheet == nil else { return }
        let editor = makeEditor(.add)
        editor.load()
        self.editor = editor
        present(.add)
    }

    func tapMore(_ trip: ProfileV3PastTrip) {
        guard sheet == nil, revealingTripID == nil, trip.edit != nil || trip.delete != nil else { return }
        present(.actions(trip.id))
    }

    func tapEdit() {
        guard let trip = actionsTrip, trip.edit != nil else { return }
        editor = makeEditor(.edit(trip))
        present(.add)
    }

    func tapDelete() {
        guard let trip = actionsTrip, trip.delete != nil else { return }
        present(.confirmDelete(trip.id))
    }

    func confirmDelete() {
        guard case .confirmDelete(let id) = sheet, !isDeleting,
              let submit = trips.first(where: { $0.id == id })?.delete?.submit else { return }
        isDeleting = true
        let repository = repository
        deleteTask = Task { [weak self] in
            do {
                try await repository.deletePastTrip(submit)
                guard let self else { return }
                isDeleting = false
                present(nil)
                withAnimation(ProfileV3Theme.Motion.pastTripsDelete) {
                    self.screen?.trips.removeAll { $0.id == id }
                }
                completions += 1
                onChange()
                reload(revealing: nil)
            } catch {
                guard let self else { return }
                isDeleting = false
                present(nil)
                notice = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.pastTripDeleteFailed)
            }
        }
    }

    func dismissSheet() {
        guard !isBusy else { return }
        present(nil)
    }

    func sheetDidDismiss(_ dismissed: Sheet) {
        guard sheet == dismissed else { return }
        guard !isBusy else {
            isSheetDetached = true
            return
        }
        present(nil)
    }

    func cancelDelete() {
        guard !isDeleting else { return }
        present(nil)
    }

    func clearNotice() {
        notice = nil
    }

    func didFinishReveal(_ id: String) {
        guard revealingTripID == id else { return }
        revealingTripID = nil
    }

    func close() {
        [loadTask, addScreenTask, addTask, deleteTask].forEach { $0?.cancel() }
        editor?.cancel()
        onClose()
    }

    private var isBusy: Bool {
        isDeleting || editor?.isSubmitting == true
    }

    private func reload(revealing draft: ProfileV3PastTripDraft?) {
        loadTask?.cancel()
        if screen == nil, phase == .failed {
            phase = .loading
        }
        let repository = repository
        let profileID = pass.id
        loadTask = Task { [weak self] in
            do {
                let screen = try await repository.loadPastTrips(profileID: profileID)
                guard let self, !Task.isCancelled else { return }
                let revealed = draft.flatMap { draft in screen.trips.first { $0.matches(draft) } }
                if let revealed {
                    revealingTripID = revealed.id
                    withAnimation(ProfileV3Theme.Motion.pastTripsEntrance) { self.screen = screen }
                } else {
                    self.screen = screen
                }
                phase = .loaded
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                if self.screen == nil {
                    phase = .failed
                } else {
                    notice = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.loadFailed)
                }
            }
        }
    }

    private func preloadAddScreen() {
        let repository = repository
        let profileID = pass.id
        addScreenTask = Task { [weak self] in
            let screen = try? await repository.loadAddTrip(profileID: profileID)
            guard let self, !Task.isCancelled, let screen else { return }
            addScreen = screen
        }
    }

    private func present(_ sheet: Sheet?) {
        isSheetDetached = false
        withAnimation(ProfileV3Theme.Motion.tripSheet) {
            self.sheet = sheet
        }
    }

    private func makeEditor(_ mode: ProfileV3AddPastTripViewModel.Mode) -> ProfileV3AddPastTripViewModel {
        ProfileV3AddPastTripViewModel(
            mode: mode,
            profileID: pass.id,
            existing: trips,
            repository: repository,
            screen: addScreen,
            editDuration: screen?.duration
        ) { [weak self] draft in
            self?.saved(draft)
        } onFailed: { [weak self] in
            self?.saveFailed()
        }
    }

    private func saveFailed() {
        guard isSheetDetached else { return }
        present(nil)
        notice = editor?.errorMessage ?? ProfileV3Strings.pastTripSaveFailed
    }

    private func saved(_ draft: ProfileV3PastTripDraft) {
        present(nil)
        completions += 1
        onChange()
        reload(revealing: draft)
    }
}
