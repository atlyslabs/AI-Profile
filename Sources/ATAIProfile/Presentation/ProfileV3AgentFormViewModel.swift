import Combine
import SwiftUI
import ATUIKit

@MainActor
final class ProfileV3AgentFormViewModel: ObservableObject {

    enum SaveState: Equatable {
        case idle
        case saving
        case saved
        case failed
    }

    @Published private(set) var form: ProfileV3AgentForm
    @Published private(set) var saveState: SaveState = .idle
    @Published var pickerSectionID: String?
    @Published private(set) var sources: ProfileV3PreferenceSourcesViewModel?
    @Published private(set) var pickerOptions: [ProfileV3ChipOption] = []
    @Published private(set) var previousPassports: ProfileV3PreviousPassports?
    @Published private(set) var previousPassportsPhase: ProfileV3LoadPhase = .loading
    @Published var showsPreviousPassports = false
    @Published private(set) var passportReason: ProfileV3PassportReasonViewModel?
    @Published var passportHowUsed: ProfileV3PassportHowUsedViewModel?
    @Published var airportPickup: ProfileV3AirportPickupViewModel?
    @Published var rideRegions: ProfileV3RideRegionsViewModel?
    @Published var householdApply: ProfileV3HouseholdApplySession?
    @Published private(set) var ridePicker: ProfileV3RidePicker?
    @Published private(set) var selectedTabs: [String: String] = [:]

    let avatarURL: URL?

    private let profileID: String?
    private let repository: any ProfileV3AgentRepository
    private let residenceCode: @MainActor () -> String?
    private let onSaved: () -> Void
    private let onFinish: () -> Void
    private let presentPassportScan: ((ProfileV3PassportScanRequest) -> Void)?
    private var saveTask: Task<Void, Never>?
    private var didFinish = false
    private var previousPassportsTask: Task<Void, Never>?
    private var previousPassportsProfileID: String?
    private var passportScanTask: Task<Void, Never>?
    private var ridePickerTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    private var pendingPassportScan: ProfileV3Directive?
    private var savedValues: ProfileV3AgentFormValues

    init(
        form: ProfileV3AgentForm,
        avatarURL: URL?,
        profileID: String? = nil,
        repository: any ProfileV3AgentRepository,
        residenceCode: @escaping @MainActor () -> String? = { nil },
        presentPassportScan: ((ProfileV3PassportScanRequest) -> Void)? = nil,
        onSaved: @escaping () -> Void = {},
        onFinish: @escaping () -> Void
    ) {
        self.form = form
        savedValues = ProfileV3AgentFormValues(form)
        self.avatarURL = avatarURL
        self.profileID = profileID
        self.repository = repository
        self.residenceCode = residenceCode
        self.presentPassportScan = presentPassportScan
        self.onSaved = onSaved
        self.onFinish = onFinish
        prefetchRidePicker()
    }

    private func prefetchRidePicker() {
        let detail = form.sections.lazy.compactMap { section -> ProfileV3Directive? in
            guard case .cars(let field) = section.control else { return nil }
            return field.detail
        }.first
        guard case .ridePicker(let agentType, let pickerProfileID)? = detail?.route(fallbackProfileID: profileID) else {
            return
        }
        let repository = repository
        ridePickerTask = Task { [weak self] in
            guard let picker = try? await repository.loadRidePicker(agentType: agentType, profileID: pickerProfileID),
                  let self, !Task.isCancelled else { return }
            ridePicker = picker
        }
    }

    var passportSection: ProfileV3FormSection? {
        form.sections.first { if case .passport = $0.control { return true } else { return false } }
    }

    var passportField: ProfileV3PassportField? {
        guard case .passport(let field) = passportSection?.control else { return nil }
        return field
    }

    func startPassportUpdate(_ directive: ProfileV3Directive? = nil) {
        guard passportScanTask == nil, presentPassportScan != nil else { return }
        ProfileV3Analytics.cta(
            directive ?? passportField?.rescan ?? ProfileV3Directive(go: ProfileV3PassportRoute.update),
            origin: .passport
        )
        let scanProfileID = directive?.profileID ?? passportField?.rescan?.profileID
        let repository = repository
        let avatarURL = avatarURL
        passportScanTask = Task { [weak self] in
            let scan = (try? await repository.loadPassportScan(profileID: scanProfileID)) ?? .fallback
            guard let self else { return }
            passportScanTask = nil
            guard !Task.isCancelled else { return }
            self.presentPassportScan?(
                ProfileV3PassportScanRequest(
                    scan: scan,
                    avatarURL: avatarURL,
                    upload: { side, data in
                        try await repository.uploadPassportScan(side, data: data, profileID: scanProfileID)
                    },
                    onFinish: { [weak self] field, completed in
                        self?.finishPassportScan(field, completed: completed, next: scan.next, profileID: scanProfileID)
                    }
                )
            )
        }
    }

    func closePassportReason() {
        passportReason?.cancel()
        passportReason = nil
    }

    func openPassportHowUsed() {
        ProfileV3Analytics.cta(passportField?.howUsed, origin: .passport)
        let howUsed = ProfileV3PassportHowUsedViewModel(repository: repository)
        howUsed.load()
        passportHowUsed = howUsed
    }

    func scanFromPassportHowUsed(_ directive: ProfileV3Directive?) {
        pendingPassportScan = directive ?? ProfileV3Directive(go: ProfileV3PassportRoute.update)
        passportHowUsed = nil
    }

    func passportHowUsedDismissed() {
        guard let directive = pendingPassportScan else { return }
        pendingPassportScan = nil
        startPassportUpdate(directive)
    }

    private func finishPassportScan(
        _ field: ProfileV3PassportField?,
        completed: Bool,
        next: ProfileV3Directive?,
        profileID: String?
    ) {
        if let field {
            applyPassportField(field)
            ProfileV3Analytics.passportScanned(agentKey: agentKey, sectionId: passportSection?.id ?? "")
        }
        guard completed else { return }
        guard next?.route() == .passportReason else {
            refresh()
            return
        }
        openPassportReason(profileID: profileID)
    }

    private func applyPassportField(_ field: ProfileV3PassportField) {
        guard let section = passportSection, case .passport(let current) = section.control else { return }
        var merged = field
        merged.previous = field.previous ?? current.previous
        merged.rescan = field.rescan ?? current.rescan
        merged.howUsed = field.howUsed ?? current.howUsed
        if merged.countryName.isEmpty {
            merged.countryName = current.countryName
            merged.countryNativeName = current.countryNativeName
        }
        update(section.id) { $0.control = .passport(merged) }
    }

    private func openPassportReason(profileID: String?) {
        guard passportReason == nil else { return }
        let reason = ProfileV3PassportReasonViewModel(repository: repository, profileID: profileID) { [weak self] in
            self?.passportReason = nil
            self?.refresh()
        }
        reason.load()
        passportReason = reason
    }

    var previousPassportsTitle: String {
        previousPassports?.title.nonEmpty ?? passportField?.previous?.title ?? ""
    }

    func loadPreviousPassports() {
        previousPassportsTask?.cancel()
        previousPassportsPhase = previousPassports == nil ? .loading : .loaded
        let repository = repository
        let profileID = previousPassportsProfileID
        previousPassportsTask = Task { [weak self] in
            do {
                let screen = try await repository.loadPreviousPassports(profileID: profileID)
                guard let self, !Task.isCancelled else { return }
                previousPassports = screen
                previousPassportsPhase = .loaded
            } catch is CancellationError {
                return
            } catch {
                guard let self, !Task.isCancelled else { return }
                previousPassportsPhase = previousPassports == nil ? .failed : .loaded
            }
        }
    }

    func tapViewPreviousPassports() {
        guard let previous = passportField?.previous,
              case .passportPrevious(let profileID) = previous.next.route() else { return }
        ProfileV3Analytics.previousPassportsOpened(agentKey: agentKey)
        previousPassportsProfileID = profileID
        showsPreviousPassports = true
        loadPreviousPassports()
    }

    var pickerSection: ProfileV3FormSection? {
        pickerSectionID.flatMap { id in form.sections.first { $0.id == id } }
    }

    var savePhase: ProfileV3SavePhase {
        switch saveState {
        case .idle, .failed: return .idle
        case .saving: return .saving
        case .saved: return .saved
        }
    }

    var showsSaveError: Bool { saveState == .failed }

    var showsSaveBar: Bool {
        saveState != .idle || ProfileV3AgentFormValues(form) != savedValues
    }

    func toggleOption(_ optionID: String, in sectionID: String) {
        update(sectionID) { section in
            switch section.control {
            case .chips(var field):
                Self.toggle(&field.selection, optionID, allowsMultiple: field.allowsMultiple)
                section.control = .chips(field)
            case .cards(var field):
                Self.toggle(&field.selection, optionID, allowsMultiple: field.allowsMultiple)
                section.control = .cards(field)
            case .slider, .text, .date, .passport, .cars, .baggage:
                break
            }
        }
        ProfileV3Analytics.agentOptionToggled(
            agentKey: agentKey,
            sectionId: sectionID,
            optionId: optionID,
            isSelected: isSelected(optionID, in: sectionID)
        )
    }

    private var agentKey: String { ProfileV3Analytics.agentKey(form.agentID) }

    private func isSelected(_ optionID: String, in sectionID: String) -> Bool {
        switch form.sections.first(where: { $0.id == sectionID })?.control {
        case .chips(let field): return field.selection.contains(optionID)
        case .cards(let field): return field.selection.contains(optionID)
        default: return false
        }
    }

    func selectCar(_ carID: String, in sectionID: String) {
        applyCar(carID, in: sectionID)
        presentAirportPickup(for: sectionID)
    }

    private func applyCar(_ carID: String, in sectionID: String) {
        update(sectionID) { section in
            guard case .cars(var field) = section.control, field.selection != carID else { return }
            field.selection = carID
            section.control = .cars(field)
        }
        ProfileV3Analytics.carSelected(carId: carID, agentKey: agentKey)
    }

    private func presentAirportPickup(for sectionID: String) {
        guard airportPickup == nil,
              case .cars(let field) = form.sections.first(where: { $0.id == sectionID })?.control else { return }
        ProfileV3Analytics.screen(.agentPickup, agentKey: agentKey)
        airportPickup = ProfileV3AirportPickupViewModel(
            cars: field,
            agentTag: form.agentTag,
            avatarURL: avatarURL,
            picker: ridePicker,
            region: residenceCode(),
            onConfirm: { [weak self] in self?.applyCar($0, in: sectionID) },
            onFinish: { [weak self] in self?.airportPickup = nil }
        )
    }

    func selectTab(_ tabID: String, in sectionID: String) {
        guard selectedTabs[sectionID] != tabID else { return }
        withAnimation(ProfileV3Theme.Motion.selection) {
            selectedTabs[sectionID] = tabID
        }
    }

    func toggleBaggage(_ itemID: String, in sectionID: String) {
        var isSelected = false
        updateBaggage(in: sectionID) { tab in
            isSelected = tab.quantity(of: itemID) == 0
            tab.setQuantity(isSelected ? 1 : 0, of: itemID)
        }
        ProfileV3Analytics.agentOptionToggled(
            agentKey: agentKey,
            sectionId: sectionID,
            optionId: itemID,
            isSelected: isSelected
        )
    }

    func stepBaggage(_ itemID: String, by delta: Int, in sectionID: String) {
        updateBaggage(in: sectionID) { tab in
            let next = min(max(tab.quantity(of: itemID) + delta, 0), ProfileV3Theme.Sizes.Baggage.maxCount)
            tab.setQuantity(next, of: itemID)
        }
    }

    private func updateBaggage(in sectionID: String, _ change: (inout ProfileV3BaggageTab) -> Void) {
        let tabID = selectedTabs[sectionID]
        update(sectionID) { section in
            guard case .baggage(var field) = section.control else { return }
            field.updateTab(id: tabID, change)
            section.control = .baggage(field)
        }
    }

    func setSliderValue(_ value: Double, in sectionID: String) {
        update(sectionID) { section in
            guard case .slider(var field) = section.control else { return }
            field.value = value
            section.control = .slider(field)
        }
    }

    func setOptOut(_ isOn: Bool, in sectionID: String) {
        update(sectionID) { section in
            guard case .slider(var field) = section.control, var optOut = field.optOut else { return }
            optOut.isOn = isOn
            field.optOut = optOut
            section.control = .slider(field)
        }
    }

    func setText(_ text: String, in sectionID: String) {
        update(sectionID) { section in
            guard case .text(var field) = section.control else { return }
            field.value = text
            section.control = .text(field)
        }
    }

    func setDate(_ date: Date, in sectionID: String) {
        update(sectionID) { section in
            guard case .date(var field) = section.control else { return }
            field.value = date
            section.control = .date(field)
        }
    }

    func setShowsOnLockScreen(_ isOn: Bool) {
        guard var card = form.medicalCard else { return }
        card.showsOnLockScreen = isOn
        var next = form
        next.medicalCard = card
        form = next
        if saveState == .failed {
            saveState = .idle
        }
    }

    func openPicker(for sectionID: String) {
        guard case .chips(let field) = form.sections.first(where: { $0.id == sectionID })?.control else { return }
        pickerOptions = field.allOptions
        pickerSectionID = sectionID
    }

    func closePicker() {
        pickerSectionID = nil
    }

    func openSources(for sectionID: String) {
        guard let section = form.sections.first(where: { $0.id == sectionID }),
              let source = section.source(selectedTab: selectedTabs[sectionID]) else {
            return
        }
        let sources = ProfileV3PreferenceSourcesViewModel(
            section: section,
            source: source,
            profileID: profileID,
            repository: repository
        )
        sources.load()
        self.sources = sources
    }

    func closeSources() {
        sources?.cancel()
        sources = nil
    }

    func openNoteLink(_ directive: ProfileV3Directive) {
        guard rideRegions == nil, directive.route(fallbackProfileID: profileID) == .rideRegions else { return }
        let regions = ProfileV3RideRegionsViewModel(repository: repository) { [weak self] in
            self?.rideRegions = nil
        }
        regions.load()
        rideRegions = regions
    }

    func save() {
        guard saveState == .idle || saveState == .failed else { return }
        if let household = form.household, householdApply == nil {
            householdApply = ProfileV3HouseholdApplySession(prompt: household)
            return
        }
        submit(profileIDs: nil)
    }

    func toggleHouseholdTraveller(_ id: String) {
        guard var session = householdApply, session.phase == .choosing || session.phase == .failed else { return }
        if session.selection.contains(id) {
            session.selection.remove(id)
        } else {
            session.selection.insert(id)
        }
        session.phase = .choosing
        session.errorMessage = nil
        householdApply = session
    }

    func confirmHousehold() {
        guard let session = householdApply, session.phase == .choosing || session.phase == .failed else { return }
        let ids = session.prompt.travellers.map(\.id).filter { session.selection.contains($0) }
        guard !ids.isEmpty else { return }
        submit(profileIDs: ids)
    }

    func closeHousehold() {
        guard householdApply?.phase != .saving else { return }
        let finished = householdApply?.phase == .saved
        if finished { saveTask?.cancel() }
        householdApply = nil
        if finished || saveState == .failed {
            saveState = .idle
        }
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        onFinish()
    }

    private func submit(profileIDs: [String]?) {
        guard saveState == .idle || saveState == .failed else { return }
        saveState = .saving
        if var session = householdApply {
            session.phase = .saving
            session.errorMessage = nil
            householdApply = session
        }
        saveTask = Task { [weak self] in
            guard let self else { return }
            let snapshot = form
            let changedSections = ProfileV3AgentFormValues(snapshot).changedKeys(from: savedValues)
            do {
                let doneLabel = try await repository.saveAgentForm(
                    snapshot,
                    profileID: profileID,
                    profileIDs: profileIDs
                )
                ProfileV3Analytics.agentFormSaved(agentKey: agentKey, changedSections: changedSections)
                onSaved()
                guard !Task.isCancelled else { return }
                savedValues = ProfileV3AgentFormValues(snapshot)
                if var session = householdApply {
                    session.phase = .saved
                    session.doneLabel = doneLabel?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    householdApply = session
                }
                self.saveState = .saved
                refresh()
                try await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.savedDismissMilliseconds))
                guard !Task.isCancelled else { return }
                householdApply = nil
                self.saveState = .idle
            } catch is CancellationError {
                return
            } catch {
                ProfileV3Analytics.agentFormSaveFailed(agentKey: agentKey, error: error)
                guard !Task.isCancelled else { return }
                if householdApply != nil {
                    recordHouseholdFailure(error)
                    self.saveState = .idle
                } else {
                    self.saveState = .failed
                }
            }
        }
    }

    private func recordHouseholdFailure(_ error: Error) {
        guard var session = householdApply else { return }
        session.phase = .failed
        session.errorMessage = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed)
        if case ProfileV3Error.partialSave(_, let failed, let saved) = error {
            if !failed.isEmpty {
                session.selection = Set(failed)
            } else if !saved.isEmpty {
                session.selection.subtract(saved)
            }
        }
        householdApply = session
    }

    func tapBack() {
        saveTask?.cancel()
        finish()
    }

    private func refresh() {
        refreshTask?.cancel()
        let repository = repository
        let agentID = form.agentID
        let profileID = profileID
        refreshTask = Task { [weak self] in
            guard case .preferences(let fresh)? = try? await repository.loadAgentFlow(agentID: agentID, profileID: profileID),
                  let self, !Task.isCancelled, ProfileV3AgentFormValues(form) == savedValues else { return }
            form = fresh
            savedValues = ProfileV3AgentFormValues(fresh)
        }
    }

    func cancelPendingWork() {
        saveTask?.cancel()
        refreshTask?.cancel()
        passportScanTask?.cancel()
        passportScanTask = nil
        previousPassportsTask?.cancel()
        ridePickerTask?.cancel()
        airportPickup?.cancelPendingWork()
        rideRegions?.cancel()
    }

    private func update(_ sectionID: String, _ mutate: (inout ProfileV3FormSection) -> Void) {
        var next = form
        guard let index = next.sections.firstIndex(where: { $0.id == sectionID }) else { return }
        mutate(&next.sections[index])
        Self.refreshStatus(&next.sections[index])
        form = next
        if saveState == .failed {
            saveState = .idle
        }
    }

    private static func refreshStatus(_ section: inout ProfileV3FormSection) {
        guard section.status != nil else { return }
        switch section.control {
        case .chips(let field):
            section.status = field.selection.isEmpty ? .pending : .complete
        case .cards(let field):
            section.status = field.selection.isEmpty ? .pending : .complete
        case .slider:
            section.status = .complete
        case .passport(let field):
            section.status = field.passport == nil ? .pending : .complete
        case .text(let field):
            let trimmed = field.value.trimmingCharacters(in: .whitespacesAndNewlines)
            section.status = trimmed.isEmpty ? .pending : .complete
        case .date(let field):
            section.status = field.value == nil ? .pending : .complete
        case .cars(let field):
            section.status = field.selection == nil ? .pending : .complete
        case .baggage(let field):
            section.status = field.hasSelection ? .complete : .pending
        }
    }

    private static func toggle(_ selection: inout Set<String>, _ id: String, allowsMultiple: Bool) {
        if selection.contains(id) {
            selection.remove(id)
        } else if allowsMultiple {
            selection.insert(id)
        } else {
            selection = [id]
        }
    }
}

struct ProfileV3HouseholdApplySession: Identifiable, Equatable {
    enum Phase: Equatable {
        case choosing
        case saving
        case saved
        case failed
    }

    let id = UUID()
    var prompt: ProfileV3HouseholdPrompt
    var selection: Set<String>
    var phase: Phase
    var doneLabel = ""
    var errorMessage: String?

    init(prompt: ProfileV3HouseholdPrompt) {
        self.prompt = prompt
        selection = Set(prompt.travellers.filter(\.isSelected).map(\.id))
        phase = .choosing
    }

    var canConfirm: Bool {
        !selection.isEmpty && (phase == .choosing || phase == .failed)
    }
}

private struct ProfileV3AgentFormValues: Equatable {
    let controls: [String: ProfileV3FormControl]
    let showsOnLockScreen: Bool?

    init(_ form: ProfileV3AgentForm) {
        var controls: [String: ProfileV3FormControl] = [:]
        for section in form.sections {
            if case .passport = section.control { continue }
            controls[section.id] = section.control
        }
        self.controls = controls
        showsOnLockScreen = form.medicalCard?.showsOnLockScreen
    }

    func changedKeys(from saved: ProfileV3AgentFormValues) -> [String] {
        let sectionKeys = Set(controls.keys).union(saved.controls.keys).filter { controls[$0] != saved.controls[$0] }
        let lockScreen = showsOnLockScreen != saved.showsOnLockScreen ? ["lock_screen"] : []
        return sectionKeys.sorted() + lockScreen
    }
}

#if DEBUG
extension ProfileV3AgentFormViewModel {
    static func preview(
        _ form: ProfileV3AgentForm,
        avatarURL: URL?,
        saveState: SaveState
    ) -> ProfileV3AgentFormViewModel {
        let viewModel = ProfileV3AgentFormViewModel(
            form: form,
            avatarURL: avatarURL,
            repository: ProfileV3MockRepository(),
            onFinish: {}
        )
        viewModel.saveState = saveState
        return viewModel
    }
}
#endif
