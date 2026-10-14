import Combine
import Foundation
import SwiftUI

@MainActor
protocol ProfileV3ProgrammesRouter: AnyObject {
    func goBack()
    func openInsight(for programme: ProfileV3LoyaltyProgramme)
    func openAddProgramme()
    func openInsightAction(_ directive: ProfileV3Directive)
    func programmesChanged()
    func passChanged(to pass: ProfileV3WorldPass)
}

@MainActor
final class ProfileV3ProgrammesViewModel: ObservableObject {

    enum Phase: Equatable {
        case loading
        case content(ProfileV3ProgrammeOverview)
        case failed
    }

    @Published private(set) var phase: Phase = .loading
    @Published private(set) var showsInsights = false
    @Published private(set) var loadingInsightID: String?
    @Published private(set) var isEditing = false
    @Published private(set) var removingIDs: Set<String> = []
    @Published private(set) var flippedID: String?
    @Published private(set) var actionError: String?
    @Published private(set) var actionFailures = 0
    @Published private(set) var pass: ProfileV3WorldPass
    @Published private(set) var listOrder: [String] = []
    @Published private(set) var showsReorderHint = false

    let passes: [ProfileV3WorldPass]
    weak var router: ProfileV3ProgrammesRouter?

    private let repository: any ProfileV3LoyaltyRepository
    private let hints: ProfileV3HubHints
    private var revealTask: Task<Void, Never>?
    private var reloadTask: Task<Void, Never>?
    private var retryTask: Task<Void, Never>?
    private var insightTask: Task<Void, Never>?
    private let impressions = ProfileV3ImpressionLog()
    private var switchTask: Task<Void, Never>?
    private var reorderHintTask: Task<Void, Never>?
    private let orderWrites = ProfileV3WriteQueue()
    private var persistedOrder: [String]?
    private var orderGeneration = 0

    init(
        pass: ProfileV3WorldPass,
        passes: [ProfileV3WorldPass],
        repository: any ProfileV3LoyaltyRepository,
        hints: ProfileV3HubHints = ProfileV3HubHints()
    ) {
        self.pass = pass
        self.passes = passes
        self.repository = repository
        self.hints = hints
    }

    var overview: ProfileV3ProgrammeOverview? {
        if case .content(let overview) = phase { return overview }
        return nil
    }

    var selectedPassIndex: Int {
        passes.firstIndex { $0.id == pass.id } ?? 0
    }

    var orderedOthers: [ProfileV3LoyaltyProgramme] {
        guard let others = overview?.others else { return [] }
        let byID = Dictionary(others.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let known = Set(listOrder)
        return listOrder.compactMap { byID[$0] } + others.filter { !known.contains($0.id) }
    }

    func load(reducesMotion: Bool) async {
        if overview == nil {
            phase = .loading
        }
        guard await fetchOverview(showsFailure: true) else { return }
        scheduleInsightReveal(reducesMotion: reducesMotion)
        scheduleReorderHint()
    }

    func reload() async {
        await fetchOverview(showsFailure: false)
    }

    func retry(reducesMotion: Bool) {
        retryTask?.cancel()
        retryTask = Task { [weak self] in await self?.load(reducesMotion: reducesMotion) }
    }

    @discardableResult
    func selectPass(offsetBy delta: Int, reducesMotion: Bool) -> Bool {
        let current = selectedPassIndex
        let next = min(max(current + delta, 0), passes.count - 1)
        guard next != current else { return false }
        [switchTask, reloadTask, retryTask, insightTask, reorderHintTask].forEach { $0?.cancel() }
        loadingInsightID = nil
        actionError = nil
        withAnimation(ProfileV3Theme.Motion.selection) {
            pass = passes[next]
            isEditing = false
            flippedID = nil
            phase = .loading
            listOrder = []
            showsReorderHint = false
        }
        persistedOrder = nil
        router?.passChanged(to: pass)
        switchTask = Task { [weak self] in await self?.load(reducesMotion: reducesMotion) }
        return true
    }

    @discardableResult
    private func fetchOverview(showsFailure: Bool) async -> Bool {
        let passID = pass.id
        do {
            let overview = try await repository.loadProgrammes(passID: passID)
            guard !Task.isCancelled, passID == pass.id else { return false }
            withAnimation(ProfileV3Theme.Motion.contentSwitch) {
                phase = .content(overview)
            }
            persistedOrder = nil
            actionError = nil
            return true
        } catch is CancellationError {
            return false
        } catch {
            guard !Task.isCancelled, passID == pass.id else { return false }
            if showsFailure, overview == nil {
                phase = .failed
            } else {
                failAction(ProfileV3Strings.loadFailed)
            }
            return false
        }
    }

    func clearActionError() {
        actionError = nil
    }

    private func failAction(_ message: String) {
        actionError = message
        actionFailures += 1
    }

    func tapBack() { router?.goBack() }

    func tapConnectMore() { router?.openAddProgramme() }

    func tapEdit() {
        if showsReorderHint {
            dismissReorderHint()
        }
        withAnimation(ProfileV3Theme.Motion.selection) {
            isEditing.toggle()
            flippedID = nil
        }
        ProfileV3Analytics.programmeEditToggled(toState: isEditing ? .editing : .done)
    }

    func moveProgramme(_ id: String, to targetID: String) {
        var ids = orderedOthers.map(\.id)
        guard id != targetID, let from = ids.firstIndex(of: id), let to = ids.firstIndex(of: targetID) else { return }
        ids.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        withAnimation(ProfileV3Theme.Motion.selection) {
            listOrder = ids
        }
    }

    func commitOrder() {
        guard let overview, let action = overview.reorderAction else { return }
        let featuredIDs: [String] = overview.featured.map(\.id)
        let order: [String] = featuredIDs + orderedOthers.map(\.id)
        let loadedOrder: [String] = featuredIDs + overview.others.map(\.id)
        let baseline: [String] = persistedOrder ?? loadedOrder
        guard order != baseline else { return }
        persistedOrder = order
        orderGeneration += 1
        let generation = orderGeneration
        let profileID = pass.id
        let repository = repository
        orderWrites.enqueue { [weak self] in
            do {
                try await repository.reorderProgrammes(order, profileID: profileID, action: action)
                self?.router?.programmesChanged()
            } catch {
                guard let self, generation == orderGeneration, profileID == pass.id else { return }
                persistedOrder = baseline
                withAnimation(ProfileV3Theme.Motion.selection) {
                    self.listOrder = baseline
                }
                failAction(ProfileV3Strings.reorderProgrammesFailed)
            }
        }
    }

    func dismissReorderHint() {
        reorderHintTask?.cancel()
        hints.hasSeenProgrammeReorderHint = true
        withAnimation(ProfileV3Theme.Motion.reorderHint) {
            showsReorderHint = false
        }
    }

    private func scheduleReorderHint() {
        reorderHintTask?.cancel()
        guard !hints.hasSeenProgrammeReorderHint, !showsReorderHint, orderedOthers.count > 1 else { return }
        reorderHintTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.reorderHintDelayMilliseconds))
            guard let self, !Task.isCancelled, !isEditing, orderedOthers.count > 1 else { return }
            withAnimation(ProfileV3Theme.Motion.reorderHint) {
                self.flippedID = nil
                self.showsReorderHint = true
            }
        }
    }

    @discardableResult
    func tapTile(_ programme: ProfileV3LoyaltyProgramme) -> Bool {
        guard !isEditing else { return false }
        withAnimation(ProfileV3Theme.Motion.flip) {
            flippedID = flippedID == programme.id ? nil : programme.id
        }
        return true
    }

    func trackProgramme(_ programme: ProfileV3LoyaltyProgramme, index: Int) {
        impressions.once("\(pass.id):\(programme.id)") {
            ProfileV3Analytics.programmeViewed(programmeId: programme.id, programmeIndex: index)
        }
    }

    func tapInsight(_ programme: ProfileV3LoyaltyProgramme) {
        guard loadingInsightID == nil else { return }
        ProfileV3Analytics.programmeInsightOpened(programmeId: programme.id)
        if programme.insight != nil {
            router?.openInsight(for: programme)
            return
        }
        loadingInsightID = programme.id
        insightTask?.cancel()
        insightTask = Task { [weak self] in
            guard let self else { return }
            defer { loadingInsightID = nil }
            do {
                let insight = try await repository.loadProgrammeInsight(
                    programID: programme.id,
                    profileID: pass.id
                )
                guard !Task.isCancelled else { return }
                var resolved = programme
                resolved.insight = insight
                router?.openInsight(for: resolved)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                failAction(ProfileV3Strings.insightFailed)
            }
        }
    }

    func remove(_ programme: ProfileV3LoyaltyProgramme) {
        guard !removingIDs.contains(programme.id) else { return }
        removingIDs.insert(programme.id)
        let profileID = pass.id
        Task { [weak self] in
            await self?.performRemove(programme, profileID: profileID)
        }
    }

    private func performRemove(_ programme: ProfileV3LoyaltyProgramme, profileID: String) async {
        defer { removingIDs.remove(programme.id) }
        do {
            try await repository.removeProgramme(
                id: programme.id,
                name: programme.name,
                profileID: profileID
            )
            ProfileV3Analytics.programmeRemoved(programmeId: programme.id)
            guard profileID == pass.id else {
                router?.programmesChanged()
                return
            }
            if let overview {
                withAnimation(ProfileV3Theme.Motion.programmeRemove) {
                    phase = .content(overview.removing(programmeID: programme.id))
                }
            }
            actionError = nil
            router?.programmesChanged()
            await reload()
        } catch {
            ProfileV3Analytics.programmeRemoveFailed(programmeId: programme.id, error: error)
            guard profileID == pass.id else { return }
            failAction(ProfileV3Strings.removeProgrammeFailed)
        }
    }

    func programmesDidChange() {
        router?.programmesChanged()
        reloadTask?.cancel()
        reloadTask = Task { [weak self] in
            await self?.reload()
        }
    }

    private func scheduleInsightReveal(reducesMotion: Bool) {
        revealTask?.cancel()
        guard !showsInsights else { return }
        if reducesMotion {
            showsInsights = true
            return
        }
        revealTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.insightRevealMilliseconds))
            guard !Task.isCancelled else { return }
            withAnimation(ProfileV3Theme.Motion.insightReveal) {
                self?.showsInsights = true
            }
        }
    }
}

#if DEBUG
extension ProfileV3ProgrammesViewModel {
    static func preview(
        repository: any ProfileV3LoyaltyRepository = ProfileV3MockRepository(delay: .milliseconds(200)),
        isEditing: Bool = false,
        showsReorderHint: Bool = false
    ) -> ProfileV3ProgrammesViewModel {
        let pass = ProfileV3Fixtures.worldPass
        let viewModel = ProfileV3ProgrammesViewModel(
            pass: pass,
            passes: ProfileV3Fixtures.worldPasses,
            repository: repository
        )
        viewModel.phase = .content(ProfileV3ProgrammeFixtures.overview(for: pass))
        viewModel.isEditing = isEditing
        viewModel.showsReorderHint = showsReorderHint
        return viewModel
    }
}
#endif
