import Combine
import Foundation

@MainActor
final class ProfileV3CityProfileViewModel: ObservableObject {
    struct ScrollRequest: Equatable {
        let sectionID: String
        let id = UUID()
    }

    static let addSlotID = "city_profile.add"

    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published private(set) var content: ProfileV3CityProfile?
    @Published var selection: String? {
        didSet {
            guard selection != oldValue else { return }
            selectedTab = nil
            syncForm()
        }
    }
    @Published private(set) var form: ProfileV3AgentFormViewModel?
    @Published private(set) var selectedTab: String?
    @Published private(set) var scrollRequest: ScrollRequest?
    @Published var search: ProfileV3CitySearchModel?
    @Published var editor: ProfileV3CityEditorModel?
    @Published private(set) var citySources: ProfileV3SourcesViewModel?

    var onClose: () -> Void

    private let profileID: String?
    private let repository: any ProfileV3CityPreferencesRepository
    private var forms: [String: ProfileV3AgentFormViewModel] = [:]
    private var pendingEditor: ProfileV3CityEditorModel?
    private var loadTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?

    init(
        profileID: String?,
        repository: any ProfileV3CityPreferencesRepository,
        onClose: @escaping () -> Void = {}
    ) {
        self.profileID = profileID
        self.repository = repository
        self.onClose = onClose
    }

    var selectedCity: ProfileV3City? { content?.city(id: selection) }

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

    func close() {
        cancel()
        onClose()
    }

    func cancel() {
        loadTask?.cancel()
        refreshTask?.cancel()
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
        scrollRequest = ScrollRequest(sectionID: sectionID)
    }

    func tagLabel(for city: ProfileV3City) -> String {
        content?.tagLabel(for: city) ?? ""
    }

    func tagIcon(for city: ProfileV3City) -> String? {
        guard city.tag.purpose?.nonEmpty == nil else { return Self.purposeIcon }
        return content?.tag(id: city.tag.id)?.icon
    }

    func openCitySources() {
        guard let city = selectedCity, let source = city.sources else { return }
        let sources = ProfileV3SourcesViewModel(
            source: source,
            profileID: profileID,
            repository: ProfileV3CityAgentRepository(cityID: city.id, base: repository)
        )
        sources.load()
        citySources = sources
    }

    func closeCitySources() {
        citySources?.cancel()
        citySources = nil
    }

    func startAdding() {
        guard let content, search == nil, editor == nil else { return }
        let search = ProfileV3CitySearchModel(
            profileID: profileID,
            repository: repository,
            addedIDs: Set(content.cities.map(\.id))
        )
        search.load()
        self.search = search
    }

    func choose(_ result: ProfileV3CitySearchResult) {
        guard let content else { return }
        if content.city(id: result.id) != nil {
            selection = result.id
        } else {
            pendingEditor = makeEditor(.add(result), in: content)
        }
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
        guard let content, let city = selectedCity, editor == nil else { return }
        editor = makeEditor(.edit(city), in: content)
    }

    func editorDidDismiss() {
        editor?.cancel()
        editor = nil
    }

    private func makeEditor(_ mode: ProfileV3CityEditorModel.Mode, in content: ProfileV3CityProfile) -> ProfileV3CityEditorModel {
        ProfileV3CityEditorModel(
            mode: mode,
            profile: content,
            profileID: profileID,
            repository: repository
        ) { [weak self] outcome in
            self?.finishEditing(outcome)
        }
    }

    private func finishEditing(_ outcome: ProfileV3CityEditorModel.Outcome) {
        switch outcome {
        case .saved(let profile, let cityID):
            apply(profile, selecting: cityID)
        case .deleted(let profile, let cityID):
            let index = content?.cities.firstIndex { $0.id == cityID } ?? 0
            let neighbour = profile.cities.indices.contains(index) ? profile.cities[index] : profile.cities.last
            apply(profile, selecting: neighbour?.id ?? Self.addSlotID)
        case .cancelled:
            break
        }
        editor = nil
    }

    private func apply(_ profile: ProfileV3CityProfile, selecting slotID: String? = nil) {
        content = profile
        forms = forms.filter { id, model in
            guard let city = profile.city(id: id) else {
                model.cancelPendingWork()
                return false
            }
            return model.form == city.form || model.showsSaveBar
        }
        let target = slotID ?? selection
        let resolved = target.flatMap { $0 == Self.addSlotID || profile.city(id: $0) != nil ? $0 : nil }
            ?? profile.cities.first?.id
            ?? Self.addSlotID
        if resolved == selection {
            syncForm()
        } else {
            selection = resolved
        }
    }

    private func syncForm() {
        guard let city = selectedCity else {
            if form != nil { form = nil }
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
            repository: ProfileV3CityAgentRepository(cityID: cityID, base: repository),
            onSaved: { [weak self] in self?.refresh() },
            onFinish: { [weak self] in self?.close() }
        )
        forms[cityID] = model
        form = model
    }

    private func refresh() {
        let repository = repository
        let profileID = profileID
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            guard let profile = try? await repository.loadCityProfile(profileID: profileID),
                  let self, !Task.isCancelled else { return }
            apply(profile)
        }
    }

    private static let purposeIcon = "location_on"
}

@MainActor
final class ProfileV3CitySearchModel: ObservableObject, Identifiable {
    @Published private(set) var results: [ProfileV3CitySearchResult] = []
    @Published private(set) var isSearching = false

    let id = UUID()
    let addedIDs: Set<String>

    private let profileID: String?
    private let repository: any ProfileV3CityProfileRepository
    private var searchTask: Task<Void, Never>?
    private var query = ""

    init(profileID: String?, repository: any ProfileV3CityProfileRepository, addedIDs: Set<String>) {
        self.profileID = profileID
        self.repository = repository
        self.addedIDs = addedIDs
    }

    var options: [ProfileV3ChipOption] { results.map(\.option) }

    func result(id: String) -> ProfileV3CitySearchResult? {
        results.first { $0.id == id }
    }

    func load() {
        run("", debounced: false)
    }

    func setQuery(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed != query else { return }
        run(trimmed, debounced: true)
    }

    func cancel() {
        searchTask?.cancel()
        searchTask = nil
    }

    private func run(_ text: String, debounced: Bool) {
        query = text
        searchTask?.cancel()
        isSearching = true
        let repository = repository
        let profileID = profileID
        searchTask = Task { [weak self] in
            if debounced {
                try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.catalogueSearchDebounceMilliseconds))
            }
            guard !Task.isCancelled else { return }
            let found = try? await repository.searchCities(text, profileID: profileID)
            guard let self, !Task.isCancelled else { return }
            results = found ?? []
            isSearching = false
        }
    }
}

@MainActor
final class ProfileV3CityEditorModel: ObservableObject, Identifiable {
    enum Mode: Equatable {
        case add(ProfileV3CitySearchResult)
        case edit(ProfileV3City)
    }

    enum Step: Equatable {
        case tag
        case purpose
    }

    enum Outcome {
        case saved(ProfileV3CityProfile, cityID: String)
        case deleted(ProfileV3CityProfile, cityID: String)
        case cancelled
    }

    @Published private(set) var step = Step.tag
    @Published private(set) var tagID: String?
    @Published var purpose: String
    @Published private(set) var phase = ProfileV3SavePhase.idle
    @Published private(set) var errorMessage: String?
    @Published var confirmsDelete = false
    @Published private(set) var isDeleting = false

    let id = UUID()
    let mode: Mode
    let profile: ProfileV3CityProfile

    private let profileID: String?
    private let repository: any ProfileV3CityProfileRepository
    private let onFinish: (Outcome) -> Void
    private var task: Task<Void, Never>?

    init(
        mode: Mode,
        profile: ProfileV3CityProfile,
        profileID: String?,
        repository: any ProfileV3CityProfileRepository,
        onFinish: @escaping (Outcome) -> Void
    ) {
        self.mode = mode
        self.profile = profile
        self.profileID = profileID
        self.repository = repository
        self.onFinish = onFinish
        if case .edit(let city) = mode {
            tagID = city.tag.id
            purpose = city.tag.purpose ?? ""
        } else {
            purpose = ""
        }
    }

    var cityID: String {
        switch mode {
        case .add(let result): return result.id
        case .edit(let city): return city.id
        }
    }

    var window: ProfileV3CityWindow.Content {
        switch mode {
        case .add(let result): return .city(code: result.code, name: result.name, imageURL: result.imageURL)
        case .edit(let city): return .city(code: city.code, name: city.name, imageURL: city.imageURL)
        }
    }

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var title: String {
        guard case .edit(let city) = mode else { return ProfileV3Strings.addCityProfile }
        return city.name
    }

    var isBusy: Bool { phase == .saving || isDeleting }

    var trimmedPurpose: String { purpose.trimmingCharacters(in: .whitespacesAndNewlines) }

    var canContinue: Bool {
        guard let option = profile.tag(id: tagID) else { return false }
        return !option.asksPurpose || !trimmedPurpose.isEmpty
    }

    var canSavePurpose: Bool { !trimmedPurpose.isEmpty }

    func label(for option: ProfileV3CityTagOption) -> String {
        if option.asksPurpose, tagID == option.id, !trimmedPurpose.isEmpty {
            return trimmedPurpose
        }
        let count = profile.taggedCount(option.id, excluding: cityID) + (tagID == option.id ? 1 : 0)
        return count > 1 ? ProfileV3Strings.cityTagCount(option.label, count) : option.label
    }

    func select(_ option: ProfileV3CityTagOption) {
        guard !isBusy else { return }
        errorMessage = nil
        tagID = option.id
        if option.asksPurpose {
            step = .purpose
        }
    }

    func back() {
        guard !isBusy else { return }
        switch step {
        case .purpose:
            errorMessage = nil
            step = .tag
            if trimmedPurpose.isEmpty, profile.tag(id: tagID)?.asksPurpose == true {
                tagID = originalTag?.id
            }
        case .tag:
            onFinish(.cancelled)
        }
    }

    func commit() {
        guard let tagID, canContinue, !isBusy else { return }
        let asksPurpose = profile.tag(id: tagID)?.asksPurpose == true
        let tag = ProfileV3CityTag(id: tagID, purpose: asksPurpose ? trimmedPurpose : nil)
        if tag == originalTag {
            onFinish(.saved(profile, cityID: cityID))
            return
        }
        phase = .saving
        errorMessage = nil
        let repository = repository
        let profileID = profileID
        let cityID = cityID
        let isEditing = isEditing
        task = Task { [weak self] in
            do {
                let updated = isEditing
                    ? try await repository.updateCityTag(cityID, tag: tag, profileID: profileID)
                    : try await repository.addCity(cityID, tag: tag, profileID: profileID)
                guard let self, !Task.isCancelled else { return }
                phase = .idle
                onFinish(.saved(updated, cityID: cityID))
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                phase = .failed
                errorMessage = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed)
            }
        }
    }

    func requestDelete() {
        guard isEditing, !isBusy else { return }
        errorMessage = nil
        confirmsDelete = true
    }

    func cancelDelete() {
        guard !isDeleting else { return }
        confirmsDelete = false
    }

    func confirmDelete() {
        guard isEditing, !isDeleting else { return }
        isDeleting = true
        let repository = repository
        let profileID = profileID
        let cityID = cityID
        task = Task { [weak self] in
            do {
                let updated = try await repository.deleteCity(cityID, profileID: profileID)
                guard let self, !Task.isCancelled else { return }
                isDeleting = false
                confirmsDelete = false
                onFinish(.deleted(updated, cityID: cityID))
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
        task?.cancel()
        task = nil
    }

    private var originalTag: ProfileV3CityTag? {
        guard case .edit(let city) = mode else { return nil }
        return city.tag
    }
}
