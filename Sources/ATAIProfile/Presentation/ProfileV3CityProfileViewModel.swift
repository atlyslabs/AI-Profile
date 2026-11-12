import Combine
import Foundation

@MainActor
final class ProfileV3CityProfileViewModel: ObservableObject {
    struct ScrollRequest: Equatable {
        let sectionID: String
        let id = UUID()

        var anchorID: String { ProfileV3CityProfileViewModel.sectionAnchorID(sectionID) }
    }

    static let addSlotID = "city_profile.add"

    nonisolated static func sectionAnchorID(_ sectionID: String) -> String {
        "city_section." + sectionID
    }

    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var content: ProfileV3CityProfile?
    @Published var selection: String? {
        didSet {
            guard selection != oldValue else { return }
            selectedTab = nil
            reachedSectionIDs = []
            tabFollowResumes = nil
            syncCity()
        }
    }
    @Published private(set) var screens: [String: ProfileV3City] = [:]
    @Published private(set) var cityPhases: [String: ProfileV3LoadPhase] = [:]
    @Published private(set) var form: ProfileV3AgentFormViewModel?
    @Published private(set) var selectedTab: String?
    @Published private(set) var scrollRequest: ScrollRequest?
    @Published var search: ProfileV3CitySearchModel?
    @Published var editor: ProfileV3CityEditorModel?

    var onClose: () -> Void

    private let profileID: String?
    private let repository: any ProfileV3CityPreferencesRepository
    private let placeSearch: (any ProfileV3PlaceSearching)?
    private var forms: [String: ProfileV3AgentFormViewModel] = [:]
    private var pendingEditor: ProfileV3CityEditorModel?
    private var pendingSelection: String?
    private var loadTask: Task<Void, Never>?
    private var cityTasks: [String: Task<Void, Never>] = [:]
    private var reachedSectionIDs: Set<String> = []
    private var tabFollowResumes: ContinuousClock.Instant?

    init(
        profileID: String?,
        repository: any ProfileV3CityPreferencesRepository,
        placeSearch: (any ProfileV3PlaceSearching)? = nil,
        onClose: @escaping () -> Void = {}
    ) {
        self.profileID = profileID
        self.repository = repository
        self.placeSearch = placeSearch
        self.onClose = onClose
    }

    var selectedCity: ProfileV3City? { selection.flatMap { screens[$0] } }

    var selectedPorthole: ProfileV3CityPorthole? { content?.city(id: selection) }

    var selectedCityPhase: ProfileV3LoadPhase {
        selection.flatMap { cityPhases[$0] } ?? .loading
    }

    var isOnAddSlot: Bool { selection == Self.addSlotID }

    var slotIDs: [String] { (content?.cities.map(\.id) ?? []) + [Self.addSlotID] }

    func load() {
        let repository = repository
        let profileID = profileID
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.content,
            fetch: { try await repository.loadCityProfile(profileID: profileID) },
            apply: { $0.apply($1) }
        )
    }

    func loadIfNeeded() {
        guard content == nil, loadTask == nil else { return }
        load()
    }

    func retryCity() {
        guard let selection, selection != Self.addSlotID else { return }
        loadCity(selection)
    }

    func close() {
        cancel()
        onClose()
    }

    func cancel() {
        loadTask?.cancel()
        cityTasks.values.forEach { $0.cancel() }
        cityTasks = [:]
        search?.cancel()
        editor?.cancel()
        forms.values.forEach { $0.cancelPendingWork() }
    }

    func select(_ slotID: String) {
        guard slotIDs.contains(slotID) else { return }
        selection = slotID
    }

    func selectTab(_ sectionID: String) {
        selectedTab = sectionID
        tabFollowResumes = .now + .seconds(ProfileV3Theme.Motion.cityTabFollowPauseSeconds)
        scrollRequest = ScrollRequest(sectionID: sectionID)
    }

    func sectionReached(_ sectionID: String, isReached: Bool) {
        if isReached {
            reachedSectionIDs.insert(sectionID)
        } else {
            reachedSectionIDs.remove(sectionID)
        }
        if let tabFollowResumes, ContinuousClock.now < tabFollowResumes { return }
        tabFollowResumes = nil
        guard let tabs = selectedCity?.tabs else { return }
        let reached = tabs.last { reachedSectionIDs.contains($0.sectionID) }?.sectionID
        if selectedTab != reached {
            selectedTab = reached
        }
    }

    func startAdding() {
        guard content != nil, search == nil, editor == nil else { return }
        let search = ProfileV3CitySearchModel(profileID: profileID, repository: repository)
        search.load()
        self.search = search
    }

    func choose(_ result: ProfileV3CitySearchResult) {
        pendingEditor = makeEditor(.add(result))
        search?.cancel()
        search = nil
    }

    func searchDidDismiss() {
        search?.cancel()
        search = nil
        guard let pendingEditor else { return }
        self.pendingEditor = nil
        editor = pendingEditor
    }

    func editSelectedCity() {
        guard let city = selectedCity, city.editsPurpose, editor == nil else { return }
        editor = makeEditor(.edit(cityID: city.id, code: city.code, name: city.name, imageURL: city.imageURL))
    }

    func editorDidDismiss() {
        editor?.cancel()
        editor = nil
    }

    private func makeEditor(_ mode: ProfileV3CityEditorModel.Mode) -> ProfileV3CityEditorModel {
        let editor = ProfileV3CityEditorModel(mode: mode, profileID: profileID, repository: repository) { [weak self] outcome in
            self?.finishEditing(outcome)
        }
        editor.load()
        return editor
    }

    private func finishEditing(_ outcome: ProfileV3CityEditorModel.Outcome) {
        switch outcome {
        case .saved(let cityID):
            pendingSelection = cityID
            loadCity(cityID)
            reloadIntro()
        case .deleted(let cityID):
            let index = content?.cities.firstIndex { $0.id == cityID } ?? 0
            forget(cityID)
            if var content {
                content.cities.removeAll { $0.id == cityID }
                self.content = content
                let neighbour = content.cities.indices.contains(index) ? content.cities[index] : content.cities.last
                selection = neighbour?.id ?? Self.addSlotID
            }
            reloadIntro()
        case .cancelled:
            break
        }
        editor = nil
    }

    private func apply(_ profile: ProfileV3CityProfile) {
        content = profile
        let ids = Set(profile.cities.map(\.id))
        for id in Array(screens.keys) where !ids.contains(id) {
            forget(id)
        }
        let target = pendingSelection ?? selection
        pendingSelection = nil
        let resolved = target.flatMap { $0 == Self.addSlotID || ids.contains($0) ? $0 : nil }
            ?? profile.cities.first?.id
            ?? Self.addSlotID
        if resolved == selection {
            syncCity()
        } else {
            selection = resolved
        }
    }

    private func reloadIntro() {
        let repository = repository
        let profileID = profileID
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let profile = try? await repository.loadCityProfile(profileID: profileID),
                  let self, !Task.isCancelled else { return }
            loadTask = nil
            apply(profile)
        }
    }

    private func syncCity() {
        guard let selection, selection != Self.addSlotID else {
            if form != nil { form = nil }
            return
        }
        guard let city = screens[selection] else {
            if form != nil { form = nil }
            if cityTasks[selection] == nil, cityPhases[selection] != .failed {
                loadCity(selection)
            }
            return
        }
        if let existing = forms[city.id] {
            if existing !== form { form = existing }
            return
        }
        let cityID = city.id
        let model = ProfileV3AgentFormViewModel(
            form: city.form,
            avatarURL: nil,
            profileID: profileID,
            repository: ProfileV3CityAgentRepository(cityID: cityID, save: city.save, base: repository),
            placeSearch: placeSearch,
            onSaved: { [weak self] in
                self?.loadCity(cityID)
                self?.reloadIntro()
            },
            onFinish: { [weak self] in self?.close() }
        )
        forms[cityID] = model
        form = model
    }

    private func loadCity(_ cityID: String) {
        let repository = repository
        let profileID = profileID
        cityTasks[cityID]?.cancel()
        if screens[cityID] == nil {
            cityPhases[cityID] = .loading
        }
        cityTasks[cityID] = Task { [weak self] in
            do {
                let city = try await repository.loadCity(cityID, profileID: profileID)
                guard let self, !Task.isCancelled else { return }
                cityTasks[cityID] = nil
                screens[cityID] = city
                cityPhases[cityID] = .loaded
                if selection == cityID { syncCity() }
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                cityTasks[cityID] = nil
                if screens[cityID] == nil {
                    cityPhases[cityID] = .failed
                }
            }
        }
    }

    private func forget(_ cityID: String) {
        cityTasks[cityID]?.cancel()
        cityTasks[cityID] = nil
        screens[cityID] = nil
        cityPhases[cityID] = nil
        forms[cityID]?.cancelPendingWork()
        forms[cityID] = nil
    }
}

@MainActor
final class ProfileV3CitySearchModel: ObservableObject, Identifiable {
    @Published private(set) var picker: ProfileV3CityPicker?
    @Published private(set) var results: [ProfileV3CitySearchResult] = []
    @Published private(set) var isSearching = false
    @Published private(set) var hasFailed = false
    @Published private(set) var loadMoreFailed = false

    let id = UUID()

    private let profileID: String?
    private let repository: any ProfileV3CityProfileRepository
    private var searchTask: Task<Void, Never>?
    private var pageTask: Task<Void, Never>?
    private var query = ""

    init(profileID: String?, repository: any ProfileV3CityProfileRepository) {
        self.profileID = profileID
        self.repository = repository
    }

    var hasMore: Bool { picker?.nextOffset != nil }

    func load() {
        run("", debounced: false)
    }

    func retry() {
        run(query, debounced: false)
    }

    func setQuery(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed != query else { return }
        run(trimmed, debounced: true)
    }

    func loadMore() {
        guard pageTask == nil, searchTask == nil, let offset = picker?.nextOffset else { return }
        loadMoreFailed = false
        let repository = repository
        let profileID = profileID
        let query = query
        pageTask = Task { [weak self] in
            do {
                let page = try await repository.searchCities(query, offset: offset, profileID: profileID)
                guard let self, !Task.isCancelled else { return }
                pageTask = nil
                guard page.query == self.query else { return }
                let shown = Set(results.map(\.id))
                results += page.results.filter { !shown.contains($0.id) }
                picker = page
            } catch {
                guard let self, !Task.isCancelled else { return }
                pageTask = nil
                loadMoreFailed = true
            }
        }
    }

    func retryLoadMore() {
        loadMoreFailed = false
        loadMore()
    }

    func cancel() {
        searchTask?.cancel()
        searchTask = nil
        pageTask?.cancel()
        pageTask = nil
    }

    private func run(_ text: String, debounced: Bool) {
        query = text
        cancel()
        isSearching = true
        hasFailed = false
        loadMoreFailed = false
        let repository = repository
        let profileID = profileID
        searchTask = Task { [weak self] in
            if debounced {
                try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.citySearchDebounceMilliseconds))
            }
            guard !Task.isCancelled else { return }
            do {
                let page = try await repository.searchCities(text, offset: 0, profileID: profileID)
                guard let self, !Task.isCancelled else { return }
                searchTask = nil
                guard page.query == query else { return }
                picker = page
                results = page.results
                isSearching = false
            } catch {
                guard let self, !Task.isCancelled else { return }
                searchTask = nil
                isSearching = false
                hasFailed = true
            }
        }
    }
}

@MainActor
final class ProfileV3CityEditorModel: ObservableObject, Identifiable {
    enum Mode: Equatable {
        case add(ProfileV3CitySearchResult)
        case edit(cityID: String, code: String, name: String, imageURL: URL?)
    }

    enum Step: Equatable {
        case purpose
        case label
    }

    enum Outcome: Equatable {
        case saved(cityID: String)
        case deleted(cityID: String)
        case cancelled
    }

    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var sheet: ProfileV3CityPurposeSheet?
    @Published private(set) var step = Step.purpose
    @Published private(set) var purposeKey: String?
    @Published var label = "" {
        didSet {
            guard label != oldValue else { return }
            if let maxChars = labelInput?.maxChars, label.count > maxChars {
                label = String(label.prefix(maxChars))
                return
            }
            if errorMessage != nil { errorMessage = nil }
        }
    }
    @Published private(set) var savePhase = ProfileV3SavePhase.idle
    @Published private(set) var errorMessage: String?
    @Published var confirmsDelete = false
    @Published private(set) var isDeleting = false

    let id = UUID()
    let mode: Mode

    private let profileID: String?
    private let repository: any ProfileV3CityProfileRepository
    private let onFinish: (Outcome) -> Void
    private var loadTask: Task<Void, Never>?
    private var task: Task<Void, Never>?
    private var original: (key: String, label: String?)?

    init(
        mode: Mode,
        profileID: String?,
        repository: any ProfileV3CityProfileRepository,
        onFinish: @escaping (Outcome) -> Void
    ) {
        self.mode = mode
        self.profileID = profileID
        self.repository = repository
        self.onFinish = onFinish
    }

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var title: String {
        if let title = sheet?.title.nonEmpty { return title }
        switch mode {
        case .add(let result): return result.name.uppercased()
        case .edit(_, _, let name, _): return name.uppercased()
        }
    }

    var window: ProfileV3CityWindow.Content {
        if let city = sheet?.city {
            return .city(code: city.code, name: city.name, imageURL: city.imageURL)
        }
        switch mode {
        case .add(let result): return .city(code: result.code, name: result.name, imageURL: nil)
        case .edit(_, let code, let name, let imageURL): return .city(code: code, name: name, imageURL: imageURL)
        }
    }

    var isBusy: Bool { savePhase == .saving || isDeleting }

    var labelInput: ProfileV3CityPurposeSheet.Option.Input? { sheet?.option(key: purposeKey)?.input }

    var trimmedLabel: String { label.trimmingCharacters(in: .whitespacesAndNewlines) }

    var isLabelTaken: Bool { labelInput != nil && sheet?.isLabelUsed(trimmedLabel) == true }

    var canContinue: Bool {
        guard let option = sheet?.option(key: purposeKey), !option.isDisabled || option.isSelected else { return false }
        guard option.input != nil else { return true }
        return !trimmedLabel.isEmpty && !isLabelTaken
    }

    func load() {
        let repository = repository
        let profileID = profileID
        let city: ProfileV3CitySearchResult
        let cityID: String?
        switch mode {
        case .add(let result):
            city = result
            cityID = nil
        case .edit(let id, let code, let name, _):
            city = ProfileV3CitySearchResult(code: code, name: name)
            cityID = id
        }
        phase = .loading
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            do {
                let sheet = try await repository.loadCityPurpose(city, cityID: cityID, profileID: profileID)
                guard let self, !Task.isCancelled else { return }
                apply(sheet)
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                phase = .failed
            }
        }
    }

    func select(_ option: ProfileV3CityPurposeSheet.Option) {
        guard !isBusy, !option.isDisabled || option.isSelected else { return }
        errorMessage = nil
        purposeKey = option.key
        if option.input != nil {
            if label.isEmpty, let value = option.input?.value { label = value }
            step = .label
        }
    }

    func back() {
        guard !isBusy else { return }
        switch step {
        case .label:
            errorMessage = nil
            step = .purpose
            if trimmedLabel.isEmpty {
                purposeKey = original?.key
            }
        case .purpose:
            onFinish(.cancelled)
        }
    }

    func commit() {
        guard let sheet, let purposeKey, canContinue, !isBusy else { return }
        let label = labelInput == nil ? nil : trimmedLabel
        if let original, original.key == purposeKey, label == original.label,
           case .edit(let cityID, _, _, _) = mode {
            onFinish(.saved(cityID: cityID))
            return
        }
        savePhase = .saving
        errorMessage = nil
        let repository = repository
        let action = sheet.submit
        let editedID: String? = {
            if case .edit(let cityID, _, _, _) = mode { return cityID }
            return nil
        }()
        task = Task { [weak self] in
            do {
                let cityID = try await repository.submitCityPurpose(action, purpose: purposeKey, label: label)
                guard let self, !Task.isCancelled else { return }
                savePhase = .idle
                guard let resolved = cityID ?? editedID else {
                    onFinish(.cancelled)
                    return
                }
                onFinish(.saved(cityID: resolved))
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                savePhase = .failed
                errorMessage = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed)
            }
        }
    }

    func requestDelete() {
        guard sheet?.delete != nil, !isBusy else { return }
        errorMessage = nil
        confirmsDelete = true
    }

    func cancelDelete() {
        guard !isDeleting else { return }
        confirmsDelete = false
    }

    func confirmDelete() {
        guard let delete = sheet?.delete, case .edit(let cityID, _, _, _) = mode, !isDeleting else { return }
        isDeleting = true
        let repository = repository
        task = Task { [weak self] in
            do {
                try await repository.deleteCity(delete.action)
                guard let self, !Task.isCancelled else { return }
                isDeleting = false
                confirmsDelete = false
                onFinish(.deleted(cityID: cityID))
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                isDeleting = false
                confirmsDelete = false
                errorMessage = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed)
            }
        }
    }

    func cancel() {
        loadTask?.cancel()
        task?.cancel()
        task = nil
    }

    private func apply(_ sheet: ProfileV3CityPurposeSheet) {
        self.sheet = sheet
        if let selected = sheet.options.first(where: \.isSelected) {
            purposeKey = selected.key
            original = (selected.key, selected.input?.value)
            if let value = selected.input?.value { label = value }
        }
        phase = .loaded
    }
}
