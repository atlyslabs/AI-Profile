import Combine
import Foundation

@MainActor
protocol ProfileV3AddProgrammeRouter: AnyObject {
    func redirectToKYC()
    func dismissAddProgramme()
    func showProgrammePicker()
}

extension ProfileV3AddProgrammeRouter {
    func showProgrammePicker() {}
}

@MainActor
final class ProfileV3AddProgrammeViewModel: ObservableObject {

    enum Stage: Equatable {
        case kycRequired
        case scanning(activity: String, foundCount: Int)
        case found(count: Int)
        case pick
        case details
        case failed

        var isSheet: Bool { self == .pick || self == .details }
        var isOverlay: Bool { self == .kycRequired }
    }

    @Published private(set) var stage: Stage
    @Published private(set) var catalogue: [ProfileV3ProgrammeCatalogueItem] = [] {
        didSet { indexCatalogue() }
    }
    @Published private(set) var selectedFilter: ProfileV3ProgrammeFilter? {
        didSet { refreshFilteredCatalogue() }
    }
    @Published private(set) var filteredCatalogue: [ProfileV3ProgrammeCatalogueItem] = []
    @Published private(set) var isLoadingCatalogue = false
    @Published private(set) var catalogueFailed = false
    @Published private(set) var filters: [ProfileV3ProgrammeFilter] = []
    @Published var query = "" {
        didSet {
            guard query != oldValue else { return }
            showCatalogueLoader()
            refreshFilteredCatalogue()
            reconcileSelection()
            scheduleCatalogueRefresh()
        }
    }
    @Published var selectedItemID: String? {
        didSet { rememberSelection() }
    }
    @Published var membershipNumber = ""
    @Published var points = ""
    @Published private(set) var isSaving = false
    @Published private(set) var didAdd = false
    @Published private(set) var entryForm: ProfileV3LoyaltyEntryForm?
    @Published private(set) var entryFormFailed = false
    @Published private(set) var saveError: String?

    weak var router: ProfileV3AddProgrammeRouter?

    private let requiresKYC: Bool
    private let profileID: String?
    private let repository: any ProfileV3LoyaltyRepository
    private let selections: ProfileV3ProgrammeSelectionMemory?
    private let onAdded: () -> Void
    private var scanTask: Task<Void, Never>?
    private var entryTask: Task<Void, Never>?
    private var submitTask: Task<Void, Never>?
    private var searchKeys: [String] = []
    private var catalogueTask: Task<Void, Never>?
    private var catalogueFilter: ProfileV3ProgrammeFilter?
    private var catalogueLoaderShownAt = ContinuousClock.now
    private var slideDepthReached = 0
    private var hasStarted = false
    private var didClose = false

    init(
        requiresKYC: Bool,
        profileID: String? = nil,
        repository: any ProfileV3LoyaltyRepository,
        selections: ProfileV3ProgrammeSelectionMemory? = nil,
        onAdded: @escaping () -> Void = {}
    ) {
        self.requiresKYC = requiresKYC
        self.profileID = profileID
        self.repository = repository
        self.selections = selections
        self.onAdded = onAdded
        if requiresKYC {
            stage = .kycRequired
        } else if ProfileV3FeatureFlags.isProgrammeScanLoaderEnabled {
            stage = .scanning(activity: ProfileV3Strings.goingThroughEmails, foundCount: 0)
        } else {
            stage = .pick
            isLoadingCatalogue = true
        }
        selectedItemID = profileID.flatMap { selections?.itemID(for: $0) }
    }

    var showsCloseButton: Bool {
        switch stage {
        case .kycRequired, .failed: return true
        case .scanning, .found, .pick, .details: return false
        }
    }

    var stepIndex: Int { stage == .details ? 1 : 0 }

    var selectedItem: ProfileV3ProgrammeCatalogueItem? {
        filteredCatalogue.first { $0.id == selectedItemID }
    }

    var canContinuePick: Bool { selectedItem != nil && !isLoadingCatalogue }

    var entryFields: [ProfileV3LoyaltyEntryForm.Field] {
        (entryForm?.fields ?? []).filter { $0.key == Field.membershipNumberKey || $0.key == Field.pointsKey }
    }

    var canSubmit: Bool {
        guard entryForm != nil, !isSaving else { return false }
        return entryFields.allSatisfy { !$0.isRequired || !value(for: $0.key).isEmpty }
    }

    private typealias Field = ProfileV3LoyaltyEntryForm.Field

    private func value(for key: String) -> String {
        let raw = key == Field.pointsKey ? points : membershipNumber
        return raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func start() async {
        guard !hasStarted else { return }
        hasStarted = true
        ProfileV3Analytics.screen(.addProgramme)
        if requiresKYC {
            setStage(.kycRequired)
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.kycRedirectMilliseconds))
            guard !Task.isCancelled, !didClose else { return }
            router?.redirectToKYC()
            return
        }
        guard ProfileV3FeatureFlags.isProgrammeScanLoaderEnabled else {
            scheduleCatalogueRefresh(debounced: false)
            return
        }
        await scan()
    }

    func scan() async {
        ProfileV3Analytics.programmeScanStarted()
        setStage(.scanning(activity: ProfileV3Strings.goingThroughEmails, foundCount: 0))
        let loaderDeadline = ContinuousClock.now + .milliseconds(ProfileV3Theme.Motion.scanMinimumMilliseconds)
        do {
            let scannedCount = try await runScan()
            if let scannedCount {
                ProfileV3Analytics.programmeScanFinished(foundCount: scannedCount)
            }
            let picker = try await repository.loadProgrammeCatalogue(query: nil, kind: nil)
            catalogueFilter = nil
            applyPicker(picker)
            reconcileSelection()
            try await Task.sleep(until: loaderDeadline, clock: .continuous)
            let foundCount = scannedCount ?? picker.items.count
            if foundCount > 0 {
                setStage(.found(count: foundCount))
                try await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.foundHoldMilliseconds))
                guard !Task.isCancelled else { return }
            }
            setStage(.pick)
            router?.showProgrammePicker()
        } catch is CancellationError {
            return
        } catch {
            try? await Task.sleep(until: loaderDeadline, clock: .continuous)
            guard !Task.isCancelled else { return }
            setStage(.failed)
        }
    }

    private func runScan() async throws -> Int? {
        do {
            var foundCount: Int?
            for try await event in repository.scanProgrammes() {
                switch event {
                case .searching(let activity, let count):
                    setStage(.scanning(activity: activity, foundCount: count))
                case .finished(let count):
                    foundCount = count
                    setStage(.found(count: count))
                }
            }
            return foundCount
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return nil
        }
    }

    func retry() {
        guard ProfileV3FeatureFlags.isProgrammeScanLoaderEnabled else {
            scheduleCatalogueRefresh(debounced: false)
            return
        }
        scanTask?.cancel()
        scanTask = Task { [weak self] in
            guard let self else { return }
            await scan()
        }
    }

    func isSelected(_ filter: ProfileV3ProgrammeFilter) -> Bool {
        filter.isAll ? selectedFilter == nil : selectedFilter == filter
    }

    func selectFilter(_ filter: ProfileV3ProgrammeFilter) {
        let next = filter.isAll ? nil : filter
        guard next != selectedFilter else { return }
        showCatalogueLoader()
        selectedFilter = next
        slideDepthReached = 0
        ProfileV3Analytics.cardTypeSelected(travellerId: profileID, connectorType: connectorType)
        reconcileSelection()
        scheduleCatalogueRefresh(debounced: false)
    }

    @discardableResult
    func selectItem(_ id: String) -> Bool {
        guard selectedItemID != id else { return false }
        selectedItemID = id
        trackSlideDepth(to: id)
        return true
    }

    private var connectorType: String {
        selectedFilter.map(Self.connectorType) ?? ProfileV3Analytics.connectorType(.all)
    }

    private static func connectorType(_ filter: ProfileV3ProgrammeFilter) -> String {
        filter.category.map(ProfileV3Analytics.connectorType)
            ?? filter.label.lowercased().split(whereSeparator: \.isWhitespace).joined(separator: "_")
    }

    private func trackSlideDepth(to id: String) {
        let items = filteredCatalogue
        guard let index = items.firstIndex(where: { $0.id == id }), index > 0 else { return }
        let step = Self.slideDepthStep
        let bucket = items.count * step
        let depth = ((index + 1) * 100 + bucket - 1) / bucket * step
        guard depth > slideDepthReached else { return }
        slideDepthReached = depth
        ProfileV3Analytics.programCardScrolled(
            travellerId: profileID,
            slideDepthPercentage: depth,
            connectorType: connectorType
        )
    }

    private static let slideDepthStep = 25

    private func rememberSelection() {
        guard let profileID else { return }
        selections?.remember(selectedItemID, for: profileID)
    }

    private func reconcileSelection() {
        let visible = filteredCatalogue
        if let selectedItemID, visible.contains(where: { $0.id == selectedItemID }) { return }
        selectedItemID = visible.first?.id
    }

    func continueFromPick() {
        guard canContinuePick, let item = selectedItem else { return }
        ProfileV3Analytics.loyaltyCardClicked(travellerId: profileID, cardName: item.name, connectorType: connectorType)
        saveError = nil
        setStage(.details)
        ProfileV3Analytics.cardDetailScreenViewed(travellerId: profileID, item: item)
        loadEntryForm(for: item)
    }

    private func loadEntryForm(for item: ProfileV3ProgrammeCatalogueItem) {
        entryTask?.cancel()
        entryForm = nil
        entryFormFailed = false
        membershipNumber = ""
        points = ""
        entryTask = Task { [weak self] in
            guard let self else { return }
            do {
                let form = try await repository.loadLoyaltyEntry(
                    programID: item.id,
                    programName: item.name,
                    kind: ProfileV3LoyaltyMapper.kind(for: item.category)
                )
                guard !Task.isCancelled else { return }
                entryForm = form
            } catch {
                guard !Task.isCancelled else { return }
                entryFormFailed = true
            }
        }
    }

    func retryEntryForm() {
        guard let item = selectedItem else { return }
        loadEntryForm(for: item)
    }

    func backToPick() {
        saveError = nil
        setStage(.pick)
    }

    func submit() {
        guard let item = selectedItem, canSubmit, submitTask == nil else { return }
        isSaving = true
        saveError = nil
        let keys = Set(entryFields.map(\.key))
        let submission = ProfileV3ProgrammeSubmission(
            item: item,
            membershipNumber: keys.contains(Field.membershipNumberKey) ? value(for: Field.membershipNumberKey) : nil,
            points: keys.contains(Field.pointsKey) ? Int(points.filter(\.isNumber)) : nil
        )
        ProfileV3Analytics.cardDetailsEntered(travellerId: profileID, submission: submission)
        submitTask = Task { [weak self] in
            guard let self else { return }
            defer {
                isSaving = false
                submitTask = nil
            }
            do {
                try await repository.addProgramme(submission, profileID: profileID)
                if let profileID { selections?.remember(nil, for: profileID) }
                didAdd = true
                onAdded()
                router?.dismissAddProgramme()
            } catch is CancellationError {
                return
            } catch {
                ProfileV3Analytics.programmeAddFailed(itemId: item.id, error: error)
                saveError = ProfileV3Strings.addProgrammeFailed
            }
        }
    }

    func close() {
        didClose = true
        scanTask?.cancel()
        entryTask?.cancel()
        catalogueTask?.cancel()
        router?.dismissAddProgramme()
    }

    private func indexCatalogue() {
        searchKeys = catalogue.map { $0.name.lowercased() }
        refreshFilteredCatalogue()
    }

    private func scheduleCatalogueRefresh(debounced: Bool = true) {
        guard stage == .pick else { return }
        let search = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let filter = selectedFilter
        catalogueTask?.cancel()
        showCatalogueLoader()
        let loaderMinimum = Duration.milliseconds(ProfileV3Theme.Motion.catalogueLoaderMinimumMilliseconds)
        let loaderUntil = catalogueLoaderShownAt + loaderMinimum
        catalogueTask = Task { [weak self] in
            guard let self else { return }
            if debounced {
                try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.catalogueSearchDebounceMilliseconds))
                guard !Task.isCancelled else { return }
            }
            let picker = try? await repository.loadProgrammeCatalogue(
                query: search.isEmpty ? nil : search,
                kind: filter?.label
            )
            guard !Task.isCancelled else { return }
            try? await Task.sleep(until: loaderUntil, clock: .continuous)
            guard !Task.isCancelled else { return }
            if let picker {
                catalogueFilter = filter
                applyPicker(picker)
                reconcileSelection()
                catalogueFailed = false
            } else {
                restoreCatalogueFilter()
                catalogueFailed = catalogue.isEmpty
            }
            isLoadingCatalogue = false
        }
    }

    private func restoreCatalogueFilter() {
        let filtersLocally = catalogueFilter == nil && selectedFilter?.category != nil
        guard selectedFilter != catalogueFilter, !filtersLocally else { return }
        selectedFilter = catalogueFilter
        reconcileSelection()
    }

    private func showCatalogueLoader() {
        guard stage == .pick, !isLoadingCatalogue else { return }
        catalogueLoaderShownAt = .now
        isLoadingCatalogue = true
    }

    private func applyPicker(_ picker: ProfileV3ProgrammePicker) {
        if !picker.filters.isEmpty { filters = picker.filters }
        catalogue = picker.items
    }

    private func refreshFilteredCatalogue() {
        let key = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let category = selectedFilter?.category
        filteredCatalogue = zip(catalogue, searchKeys).compactMap { item, searchKey in
            guard category == nil || category == .all || item.category == category else { return nil }
            guard key.isEmpty || searchKey.contains(key) else { return nil }
            return item
        }
    }

    private func setStage(_ stage: Stage) {
        self.stage = stage
    }
}

#if DEBUG
extension ProfileV3AddProgrammeViewModel {
    static func preview(
        _ stage: Stage,
        query: String = "",
        isLoadingCatalogue: Bool = false,
        membershipNumber: String = "",
        saveError: String? = nil
    ) -> ProfileV3AddProgrammeViewModel {
        let viewModel = ProfileV3AddProgrammeViewModel(requiresKYC: false, repository: ProfileV3MockRepository())
        viewModel.hasStarted = true
        viewModel.filters = ProfileV3ProgrammeCategory.allCases.map {
            ProfileV3ProgrammeFilter(label: $0.title, category: $0)
        }
        viewModel.catalogue = ProfileV3ProgrammeCatalogue.all
        viewModel.query = query
        viewModel.reconcileSelection()
        if stage == .details, let item = viewModel.selectedItem {
            viewModel.entryForm = .mock(
                programID: item.id,
                programName: item.name,
                kind: ProfileV3LoyaltyMapper.kind(for: item.category)
            )
        }
        viewModel.membershipNumber = membershipNumber
        viewModel.stage = stage
        viewModel.isLoadingCatalogue = isLoadingCatalogue
        viewModel.saveError = saveError
        return viewModel
    }
}
#endif
