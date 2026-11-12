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
        case market
        case details
        case failed

        var isSheet: Bool { self == .pick || self == .market || self == .details }
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
    @Published private(set) var market: ProfileV3ProgrammeMarket?
    @Published private(set) var selectedMarket: String?
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
    @Published var tier = ""
    @Published var tierValidUntil = ""
    @Published private(set) var isSaving = false
    @Published private(set) var didSave = false
    @Published private(set) var entryForm: ProfileV3LoyaltyEntryForm?
    @Published private(set) var entryFormFailed = false
    @Published private(set) var saveError: String?

    weak var router: ProfileV3AddProgrammeRouter?

    private let requiresKYC: Bool
    private let profileID: String?
    private let repository: any ProfileV3LoyaltyRepository
    private let selections: ProfileV3ProgrammeSelectionMemory?
    private let editing: ProfileV3LoyaltyProgramme?
    private let onSaved: () -> Void
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
        editing = nil
        onSaved = onAdded
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

    init(
        editing programme: ProfileV3LoyaltyProgramme,
        profileID: String,
        repository: any ProfileV3LoyaltyRepository,
        onSaved: @escaping () -> Void = {}
    ) {
        requiresKYC = false
        self.profileID = profileID
        self.repository = repository
        selections = nil
        editing = programme
        self.onSaved = onSaved
        stage = .details
    }

    var isEditingProgramme: Bool { editing != nil }

    var showsCloseButton: Bool {
        switch stage {
        case .kycRequired, .failed: return true
        case .scanning, .found, .pick, .market, .details: return false
        }
    }

    var stepIndex: Int { stage == .details ? 1 : 0 }

    var selectedItem: ProfileV3ProgrammeCatalogueItem? {
        filteredCatalogue.first { $0.id == selectedItemID }
    }

    var canContinuePick: Bool { selectedItem != nil && !isLoadingCatalogue }

    var showsMarketToggle: Bool {
        guard let market else { return false }
        let chip = selectedFilter ?? filters.first(where: \.isAll)
        return market.appliesTo(chip: chip?.label ?? ProfileV3ProgrammeCategory.all.title)
    }

    var selectedMarketOption: ProfileV3ProgrammeMarket.Option? {
        market?.option(selectedMarket) ?? market?.option(market?.selected)
    }

    var entryFields: [ProfileV3LoyaltyEntryForm.Field] {
        let fields = entryForm?.fields ?? []
        let offersTier = fields.contains { $0.key == Field.tierKey && !$0.options.isEmpty }
        return fields.filter { field in
            switch field.key {
            case Field.membershipNumberKey, Field.pointsKey: return true
            case Field.tierKey, Field.tierValidUntilKey: return offersTier
            default: return false
            }
        }
    }

    var tierValidUntilError: String? {
        guard let validUntil = tierSubmission.validUntil, ProfileV3MonthYear.isComplete(validUntil),
              !ProfileV3MonthYear.isCurrentOrLater(validUntil) else { return nil }
        return ProfileV3Strings.tierValidUntilInvalid
    }

    var detailsName: String {
        editing?.name ?? selectedItem?.name ?? ""
    }

    var submitTitle: String {
        guard editing != nil else { return ProfileV3Strings.continueTitle }
        return entryForm?.submitLabel ?? ProfileV3Strings.saveChanges
    }

    var canSubmit: Bool {
        guard entryForm != nil, !isSaving else { return false }
        guard entryFields.allSatisfy({ !$0.isRequired || !value(for: $0.key).isEmpty }) else { return false }
        guard tierSubmission.validUntil.map({ ProfileV3MonthYear.isCurrentOrLater($0) }) ?? true else { return false }
        return editing == nil || pendingEdit?.hasChanges == true
    }

    private typealias Field = ProfileV3LoyaltyEntryForm.Field

    private func value(for key: String) -> String {
        let raw: String
        switch key {
        case Field.pointsKey: raw = points
        case Field.tierKey: raw = tier
        case Field.tierValidUntilKey: raw = ProfileV3MonthYear.formatted(tierValidUntil)
        default: raw = membershipNumber
        }
        return raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var tierSubmission: (tier: String?, validUntil: String?) {
        guard entryFields.contains(where: { $0.key == Field.tierKey }) else { return (nil, nil) }
        let picked = value(for: Field.tierKey)
        let validUntil = value(for: Field.tierValidUntilKey)
        let picksTier = !picked.isEmpty && picked != Field.unknownTier
        if editing != nil, let form = entryForm {
            let savedTier = form.field(Field.tierKey)?.value ?? ""
            let savedValidUntil = form.field(Field.tierValidUntilKey)?.value ?? ""
            guard picked != savedTier || validUntil != savedValidUntil else { return (nil, nil) }
            guard picksTier else { return (picked != savedTier ? picked.nonEmpty : nil, nil) }
        } else if !picksTier {
            return (picked.nonEmpty, nil)
        }
        return (picked, validUntil.nonEmpty)
    }

    private var pendingEdit: ProfileV3ProgrammeEdit? {
        guard let editing, let form = entryForm else { return nil }
        let tierFields = tierSubmission
        return ProfileV3ProgrammeEdit(
            programID: form.programID,
            programName: form.programName ?? editing.name,
            kind: form.kind ?? editing.category.flatMap(ProfileV3LoyaltyMapper.kind(for:)),
            membershipNumber: change(for: Field.membershipNumberKey, in: form),
            points: change(for: Field.pointsKey, in: form),
            tier: tierFields.tier,
            tierValidUntil: tierFields.validUntil
        )
    }

    private func change(for key: String, in form: ProfileV3LoyaltyEntryForm) -> ProfileV3ProgrammeEdit.Change? {
        guard entryFields.contains(where: { $0.key == key }) else { return nil }
        let current = value(for: key)
        let saved = (form.field(key)?.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard current != saved else { return nil }
        guard key == Field.pointsKey else { return current.isEmpty ? .clear : .set(current) }
        let digits = current.filter(\.isNumber)
        guard !digits.isEmpty else { return .clear }
        return Int(digits).map { .set(String($0)) }
    }

    func start() async {
        guard !hasStarted else { return }
        hasStarted = true
        if let editing {
            loadEditForm(for: editing)
            return
        }
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
            let picker = try await repository.loadProgrammeCatalogue(query: nil, kind: nil, market: selectedMarket)
            catalogueFilter = nil
            applyPicker(picker)
            reconcileSelection()
            try await Task.sleep(until: loaderDeadline, clock: .continuous)
            let foundCount = scannedCount ?? picker.items.count
            if foundCount > 0 {
                setStage(.found(count: foundCount))
                try await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.savedDismissMilliseconds))
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

    func openMarketPicker() {
        guard stage == .pick, showsMarketToggle else { return }
        setStage(.market)
    }

    func closeMarketPicker() {
        guard stage == .market else { return }
        setStage(.pick)
    }

    func chooseMarket(_ country: ProfileV3Country) {
        closeMarketPicker()
        if let option = market?.option(country: country) {
            selectMarket(option.value)
        }
    }

    func selectMarket(_ value: String) {
        guard value != selectedMarket, market?.option(value) != nil else { return }
        showCatalogueLoader()
        selectedMarket = value
        slideDepthReached = 0
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
        let (programID, programName) = (item.id, item.name)
        let kind = ProfileV3LoyaltyMapper.kind(for: item.category)
        loadForm { try await $0.loadLoyaltyEntry(programID: programID, programName: programName, kind: kind) }
    }

    private func loadEditForm(for programme: ProfileV3LoyaltyProgramme) {
        let (programID, profileID) = (programme.id, profileID)
        loadForm { try await $0.loadProgrammeEdit(programID: programID, profileID: profileID) }
    }

    private func loadForm(
        _ fetch: @escaping @Sendable (any ProfileV3LoyaltyRepository) async throws -> ProfileV3LoyaltyEntryForm
    ) {
        entryTask?.cancel()
        entryForm = nil
        entryFormFailed = false
        membershipNumber = ""
        points = ""
        tier = ""
        tierValidUntil = ""
        entryTask = Task { [weak self] in
            guard let self else { return }
            do {
                let form = try await fetch(repository)
                guard !Task.isCancelled else { return }
                membershipNumber = form.field(Field.membershipNumberKey)?.value ?? ""
                points = form.field(Field.pointsKey)?.value ?? ""
                tier = form.field(Field.tierKey)?.value ?? ""
                tierValidUntil = ProfileV3MonthYear.formatted(form.field(Field.tierValidUntilKey)?.value ?? "")
                entryForm = form
            } catch {
                guard !Task.isCancelled else { return }
                entryFormFailed = true
            }
        }
    }

    func retryEntryForm() {
        if let editing {
            loadEditForm(for: editing)
            return
        }
        guard let item = selectedItem else { return }
        loadEntryForm(for: item)
    }

    func backToPick() {
        saveError = nil
        setStage(.pick)
    }

    func submit() {
        guard editing == nil else {
            saveEdit()
            return
        }
        guard let item = selectedItem, canSubmit, submitTask == nil else { return }
        isSaving = true
        saveError = nil
        let keys = Set(entryFields.map(\.key))
        let tierFields = tierSubmission
        let submission = ProfileV3ProgrammeSubmission(
            item: item,
            membershipNumber: keys.contains(Field.membershipNumberKey) ? value(for: Field.membershipNumberKey) : nil,
            points: keys.contains(Field.pointsKey) ? Int(points.filter(\.isNumber)) : nil,
            tier: tierFields.tier,
            tierValidUntil: tierFields.validUntil
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
                didSave = true
                onSaved()
                router?.dismissAddProgramme()
            } catch is CancellationError {
                return
            } catch {
                ProfileV3Analytics.programmeAddFailed(itemId: item.id, error: error)
                saveError = ProfileV3Strings.addProgrammeFailed
            }
        }
    }

    private func saveEdit() {
        guard let edit = pendingEdit, canSubmit, submitTask == nil else { return }
        isSaving = true
        saveError = nil
        submitTask = Task { [weak self] in
            guard let self else { return }
            defer {
                isSaving = false
                submitTask = nil
            }
            do {
                try await repository.editProgramme(edit, profileID: profileID)
                didSave = true
                onSaved()
                router?.dismissAddProgramme()
            } catch is CancellationError {
                return
            } catch {
                saveError = ProfileV3Strings.saveFailed
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
        let market = selectedMarket
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
                kind: filter?.label,
                market: market
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
        if let pickerMarket = picker.market {
            market = pickerMarket
            if selectedMarket == nil { selectedMarket = pickerMarket.selected }
        }
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
        viewModel.market = ProfileV3ProgrammeCatalogue.mockMarket(selected: nil)
        viewModel.selectedMarket = viewModel.market?.selected
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
