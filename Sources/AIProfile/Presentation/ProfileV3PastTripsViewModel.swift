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

    @Published private(set) var trips: [ProfileV3PastTrip] = []
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var sheet: Sheet?
    @Published private(set) var editor: ProfileV3AddPastTripViewModel?
    @Published private(set) var revealingTripID: String?
    @Published private(set) var isDeleting = false
    @Published private(set) var notice: String?
    @Published private(set) var completions = 0

    let pass: ProfileV3WorldPass

    private let repository: any ProfileV3PastTripsRepository
    private let onChange: ([ProfileV3PastTrip]) -> Void
    private let onClose: () -> Void
    private var startsAdding: Bool
    private var hasStarted = false
    private var isSheetDetached = false
    private var loadTask: Task<Void, Never>?
    private var addTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?

    init(
        pass: ProfileV3WorldPass,
        repository: any ProfileV3PastTripsRepository,
        startsAdding: Bool,
        onChange: @escaping ([ProfileV3PastTrip]) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.pass = pass
        self.repository = repository
        self.startsAdding = startsAdding
        self.onChange = onChange
        self.onClose = onClose
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        ProfileV3Analytics.screen(.pastTrips)
        load()
        guard startsAdding else { return }
        startsAdding = false
        addTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.pastTripsAutoAddMilliseconds))
            guard !Task.isCancelled else { return }
            self?.tapAdd()
        }
    }

    func load() {
        loadTask?.cancel()
        if phase == .failed {
            phase = .loading
        }
        let repository = repository
        let profileID = pass.id
        loadTask = Task { [weak self] in
            do {
                let trips = try await repository.loadPastTrips(profileID: profileID)
                guard let self, !Task.isCancelled else { return }
                self.trips = trips.newestFirst
                phase = .loaded
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                phase = .failed
            }
        }
    }

    func tapAdd() {
        guard sheet == nil else { return }
        editor = makeEditor(.add)
        present(.add)
    }

    func tapMore(_ trip: ProfileV3PastTrip) {
        guard sheet == nil, revealingTripID == nil else { return }
        present(.actions(trip.id))
    }

    func tapEdit() {
        guard case .actions(let id) = sheet, let trip = trips.first(where: { $0.id == id }) else { return }
        editor = makeEditor(.edit(trip))
        present(.add)
    }

    func tapDelete() {
        guard case .actions(let id) = sheet else { return }
        present(.confirmDelete(id))
    }

    func confirmDelete() {
        guard case .confirmDelete(let id) = sheet, !isDeleting else { return }
        isDeleting = true
        let repository = repository
        let profileID = pass.id
        deleteTask = Task { [weak self] in
            do {
                try await repository.deletePastTrip(id: id, profileID: profileID)
                guard let self else { return }
                isDeleting = false
                present(nil)
                withAnimation(ProfileV3Theme.Motion.pastTripsDelete) {
                    self.trips.removeAll { $0.id == id }
                }
                completions += 1
                onChange(trips)
            } catch {
                guard let self else { return }
                isDeleting = false
                present(nil)
                notice = ProfileV3Strings.pastTripDeleteFailed
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
        [loadTask, addTask, deleteTask].forEach { $0?.cancel() }
        onClose()
    }

    private var isBusy: Bool {
        isDeleting || editor?.isSubmitting == true
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
            repository: repository
        ) { [weak self] trip in
            self?.saved(trip)
        } onFailed: { [weak self] in
            self?.saveFailed()
        }
    }

    private func saveFailed() {
        guard isSheetDetached else { return }
        present(nil)
        notice = ProfileV3Strings.pastTripSaveFailed
    }

    private func saved(_ trip: ProfileV3PastTrip) {
        present(nil)
        revealingTripID = trip.id
        withAnimation(ProfileV3Theme.Motion.pastTripsEntrance) {
            trips = (trips.filter { $0.id != trip.id } + [trip]).newestFirst
        }
        completions += 1
        onChange(trips)
    }
}
