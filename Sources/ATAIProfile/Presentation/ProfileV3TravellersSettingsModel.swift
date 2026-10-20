import Combine
import Foundation

@MainActor
final class ProfileV3TravellersSettingsModel: ObservableObject {
    private static let passportInUseCode = "passport_in_use"

    @Published private(set) var screen: ProfileV3EditTravellersScreen?
    @Published private(set) var phase: ProfileV3LoadPhase = .loading
    @Published var editingTraveller = ProfileV3Traveller.empty
    @Published private(set) var isSavingTraveller = false
    @Published private(set) var deleteConfirm: ProfileV3DeleteTravellerConfirm?
    @Published private(set) var isDeletingTraveller = false
    @Published private(set) var addScreen: ProfileV3AddTravellerScreen?
    @Published private(set) var addPhase: ProfileV3LoadPhase = .loading
    @Published private(set) var isAddingTraveller = false
    @Published var newTraveller = ProfileV3AddTravellerSubmission()
    @Published private(set) var rejectedPassport: String?
    @Published private(set) var toast: String?
    @Published private(set) var relationshipField: ProfileV3EditField?
    @Published private(set) var relationshipPhase: ProfileV3LoadPhase = .loading
    @Published private(set) var relationshipSelection: String?
    @Published private(set) var isSavingRelationship = false

    weak var navigator: ProfileV3SettingsNavigating?
    weak var router: (any ProfileV3TravellersRouting & ProfileV3SettingsFeedbackRouting)?

    private let deps: ProfileV3SettingsDependencies
    private let repository: any ProfileV3SettingsRepository
    private let currentContact: () -> ProfileV3ContactDetails
    private var loadTask: Task<Void, Never>?
    private var confirmTask: Task<Void, Never>?
    private var addScreenTask: Task<Void, Never>?
    private var mutationTask: Task<Void, Never>?
    private var relationshipTask: Task<Void, Never>?
    private var relationshipLoadTask: Task<Void, Never>?
    private var relationshipTitles: [String: String] = [:]
    private var editingStoredMobile = ""
    private var editingStoredPassport = ""
    private var toastTask: Task<Void, Never>?

    init(
        deps: ProfileV3SettingsDependencies,
        repository: any ProfileV3SettingsRepository,
        currentContact: @escaping () -> ProfileV3ContactDetails
    ) {
        self.deps = deps
        self.repository = repository
        self.currentContact = currentContact
    }

    var rows: [ProfileV3TravellerRow] { screen?.travellers ?? [] }

    var editingRelationshipEntry: ProfileV3RelationshipEntry? {
        rows.first { $0.id == editingTraveller.id }?.relationshipEntry
    }

    var editingRelationshipTitle: String? {
        guard let value = rows.first(where: { $0.id == editingTraveller.id })?.relationship else { return nil }
        return relationshipTitles[value]
    }

    var canSaveRelationship: Bool {
        guard let relationshipSelection, !isSavingRelationship else { return false }
        return relationshipSelection != relationshipField?.selectedValue
    }

    var isEditedPhoneValid: Bool {
        editingTraveller.mobileNumber == editingStoredMobile || editingTraveller.isPhoneValid
    }

    var editedPassportError: String? {
        let number = editingTraveller.passportNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard number != editingStoredPassport.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        let citizenship = rows.first { $0.id == editingTraveller.id }?.citizenship
            ?? deps.storedTraveller(editingTraveller.id)?.citizenshipCode.flatMap { ProfileV3Country(code: $0) }
        return ProfileV3PassportNumber.error(for: number, citizenship: citizenship)
    }

    var newTravellerPassportError: String? {
        if let rejectedPassport, newTraveller.passportNumberValue == rejectedPassport {
            return ProfileV3Strings.passportInUse
        }
        return newTraveller.passportError
    }

    var canSubmitNewTraveller: Bool {
        newTraveller.canSubmit(fields: addScreen?.fields ?? []) && newTraveller.isPhoneValid
            && newTravellerPassportError == nil
    }

    func open() {
        ProfileV3Analytics.screen(.travellers)
        toastTask?.cancel()
        toast = nil
        navigator?.push(.editTravellers)
        load()
    }

    func load() {
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.loadTask,
            phase: \.phase,
            content: \.screen,
            fetch: { try await repository.loadEditTravellers() },
            apply: { $0.screen = $1 }
        )
    }

    func select(_ row: ProfileV3TravellerRow) {
        ProfileV3Analytics.travellerClicked(travellerId: row.id)
        editingTraveller = seeded(row)
        editingStoredMobile = editingTraveller.mobileNumber
        editingStoredPassport = editingTraveller.passportNumber
        navigator?.push(.editTraveller(row.id))
    }

    func canDelete(id: String) -> Bool {
        rows.first { $0.id == id }?.isDeletable ?? false
    }

    func tapRelationship() {
        guard let entry = editingRelationshipEntry, !isSavingRelationship else { return }
        relationshipField = nil
        relationshipSelection = nil
        navigator?.push(.travellerRelationship(entry.profileID))
        loadRelationship()
    }

    func loadRelationship() {
        guard let profileID = editingRelationshipEntry?.profileID else { return }
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.relationshipLoadTask,
            phase: \.relationshipPhase,
            content: \.relationshipField,
            fetch: { try await repository.loadTravellerRelationship(profileID: profileID) },
            apply: { $0.applyRelationshipField($1) }
        )
    }

    func selectRelationship(_ value: String) {
        guard !isSavingRelationship else { return }
        relationshipSelection = value
    }

    func confirmRelationship() {
        guard canSaveRelationship, let value = relationshipSelection, let entry = editingRelationshipEntry else {
            return
        }
        let profileID = relationshipField?.submitProfileID ?? entry.profileID
        let rowID = editingTraveller.id
        isSavingRelationship = true
        let repository = repository
        relationshipTask = Task { [weak self] in
            do {
                try await repository.saveTravellerRelationship(value, profileID: profileID)
                let refreshed = try? await repository.loadEditTravellers()
                guard let self else { return }
                isSavingRelationship = false
                if let refreshed {
                    loadTask?.cancel()
                    screen = refreshed
                    phase = .loaded
                } else {
                    screen?.setRelationship(value, for: rowID)
                    load()
                }
                router?.travellersDidChange()
                navigator?.pop()
            } catch {
                guard let self else { return }
                isSavingRelationship = false
                router?.showFlash(ProfileV3Strings.saveFailed, isSuccess: false)
            }
        }
    }

    private func applyRelationshipField(_ field: ProfileV3EditField) {
        relationshipField = field
        relationshipSelection = field.selectedValue
        for option in field.options {
            relationshipTitles[option.value] = option.title
        }
    }

    func tapRemove() {
        let profileID = editingTraveller.id
        navigator?.push(.deleteTravellerConfirm(profileID))
        deleteConfirm = nil
        confirmTask?.cancel()
        let repository = repository
        confirmTask = Task { [weak self] in
            let screen = try? await repository.loadDeleteTravellerConfirm(profileID: profileID)
            guard let self, !Task.isCancelled, let screen else { return }
            deleteConfirm = screen
        }
    }

    func confirmEdit() {
        guard editingTraveller.canSave, isEditedPhoneValid, editedPassportError == nil, !isSavingTraveller else {
            return
        }
        var traveller = editingTraveller
        traveller.firstName = traveller.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        traveller.lastName = traveller.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        traveller.passportNumber = traveller.passportNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let stored = rows.first { $0.id == traveller.id }.map(seeded)
        let namesChanged = traveller.firstName != stored?.firstName || traveller.lastName != stored?.lastName
        let passportNumber = traveller.passportNumber == stored?.passportNumber ? nil : traveller.passportNumber
        let detailsChanged = namesChanged || passportNumber != nil
        let phoneChanged = !traveller.phoneDigits.isEmpty && traveller.mobileNumber != stored?.mobileNumber
        guard detailsChanged || phoneChanged else {
            navigator?.pop()
            return
        }
        let email = traveller.isMain ? currentContact().email.nonEmpty : deps.storedTraveller(traveller.id)?.email
        isSavingTraveller = true
        let repository = repository
        mutationTask = Task { [weak self] in
            do {
                if detailsChanged {
                    try await repository.saveTravellerDetails(
                        profileID: traveller.id,
                        firstName: namesChanged ? traveller.firstName : nil,
                        lastName: namesChanged ? traveller.lastName : nil,
                        passportNumber: passportNumber
                    )
                }
                if phoneChanged {
                    try await repository.saveProfileField(
                        .contact,
                        value: .contact(email: email, mobileNumber: traveller.mobileNumber),
                        profileID: traveller.id
                    )
                }
                ProfileV3Analytics.travellerSaved(travellerId: traveller.id, passportChanged: passportNumber != nil)
                guard let self else { return }
                isSavingTraveller = false
                router?.travellerDidChange()
                travellersChanged()
                navigator?.pop()
            } catch {
                ProfileV3Analytics.travellerSaveFailed(travellerId: traveller.id, error: error)
                guard let self else { return }
                isSavingTraveller = false
                if detailsChanged { travellersChanged() }
                router?.showFlash(ProfileV3Strings.saveFailed, isSuccess: false)
            }
        }
    }

    func confirmDelete() {
        guard !isDeletingTraveller else { return }
        let removed = editingTraveller
        let profileID = deleteConfirm?.profileID ?? removed.id
        isDeletingTraveller = true
        let repository = repository
        mutationTask = Task { [weak self] in
            do {
                try await repository.deleteTraveller(profileID: profileID)
                ProfileV3Analytics.travellerRemoved(travellerId: profileID)
                let refreshed = try? await repository.loadEditTravellers()
                guard let self else { return }
                isDeletingTraveller = false
                returnToTravellers(refreshed, toast: ProfileV3Strings.travellerDeleted(removed.shortName))
            } catch {
                ProfileV3Analytics.travellerRemoveFailed(travellerId: profileID, error: error)
                guard let self else { return }
                isDeletingTraveller = false
                router?.showFlash(ProfileV3Strings.travellerDeleteFailed, isSuccess: false)
            }
        }
    }

    func tapAdd() {
        let contact = currentContact()
        newTraveller = ProfileV3AddTravellerSubmission(regionISO: contact.regionISO, dialCode: contact.dialCode)
        rejectedPassport = nil
        navigator?.push(.addTraveller)
        loadAddScreen()
    }

    func loadAddScreen() {
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.addScreenTask,
            phase: \.addPhase,
            content: \.addScreen,
            fetch: { try await repository.loadAddTraveller() },
            apply: { $0.addScreen = $1 }
        )
    }

    func tapAddCitizenship() {
        navigator?.push(.addTravellerCitizenship)
    }

    func selectAddCitizenship(_ country: ProfileV3Country) {
        newTraveller.citizenship = country
        navigator?.pop()
    }

    func confirmAdd() {
        guard canSubmitNewTraveller, !isAddingTraveller else { return }
        isAddingTraveller = true
        let submission = newTraveller
        let repository = repository
        mutationTask = Task { [weak self] in
            do {
                let profileID = try await repository.addTraveller(submission)
                ProfileV3Analytics.travellerAdded(travellerId: profileID)
                let refreshed = try? await repository.loadEditTravellers()
                guard let self else { return }
                isAddingTraveller = false
                returnToTravellers(refreshed, toast: ProfileV3Strings.travellerAdded(submission.shortName))
            } catch {
                ProfileV3Analytics.travellerAddFailed(error: error)
                guard let self else { return }
                isAddingTraveller = false
                if case ProfileV3Error.conflict(let code, _) = error, code == Self.passportInUseCode {
                    rejectedPassport = submission.passportNumberValue
                } else {
                    router?.showFlash(ProfileV3Strings.travellerAddFailed, isSuccess: false)
                }
            }
        }
    }

    func cancelReads() {
        loadTask?.cancel()
        confirmTask?.cancel()
        addScreenTask?.cancel()
        relationshipLoadTask?.cancel()
    }

    private func showToast(_ message: String) {
        toastTask?.cancel()
        toast = message
        toastTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.toastDismissMilliseconds))
            guard let self, !Task.isCancelled else { return }
            toast = nil
        }
    }

    private func travellersChanged() {
        load()
        router?.travellersDidChange()
    }

    private func returnToTravellers(_ refreshed: ProfileV3EditTravellersScreen?, toast message: String) {
        if let refreshed {
            loadTask?.cancel()
            screen = refreshed
            phase = .loaded
        }
        showToast(message)
        navigator?.path = [.editTravellers]
        if refreshed == nil {
            load()
        }
        router?.travellersDidChange()
    }

    private func seeded(_ row: ProfileV3TravellerRow) -> ProfileV3Traveller {
        var traveller = ProfileV3Traveller(row: row)
        guard let stored = deps.storedTraveller(row.id), stored.matches(row.name) else { return traveller }
        traveller.firstName = stored.firstName
        traveller.lastName = stored.lastName
        return traveller
    }
}
