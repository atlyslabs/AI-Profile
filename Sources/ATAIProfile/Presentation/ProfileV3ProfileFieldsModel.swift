import Combine
import Foundation

@MainActor
final class ProfileV3ProfileFieldsModel: ObservableObject {
    @Published private(set) var residence: ProfileV3Country?
    @Published private(set) var citizenship: ProfileV3Country?
    @Published private(set) var passportCitizenship: ProfileV3Country?
    @Published private(set) var citizenshipIconCode: String?
    @Published private(set) var citizenshipLockTrigger = 0
    @Published private(set) var currencyCountry: ProfileV3Country?
    @Published private(set) var contactDetails: ProfileV3ContactDetails
    @Published private(set) var editField: ProfileV3EditField?
    @Published private(set) var editFieldPhase: ProfileV3LoadPhase = .loading

    weak var navigator: ProfileV3SettingsNavigating?
    weak var router: (any ProfileV3SettingsSheetRouting & ProfileV3SettingsFeedbackRouting)?

    private let deps: ProfileV3SettingsDependencies
    private let repository: any ProfileV3SettingsRepository
    private let profileID: String?
    private let writes = ProfileV3WriteQueue()
    private var editFieldTask: Task<Void, Never>?
    private var requestedField: ProfileV3ProfileField?

    init(deps: ProfileV3SettingsDependencies, repository: any ProfileV3SettingsRepository, profileID: String?) {
        self.deps = deps
        self.repository = repository
        self.profileID = profileID
        contactDetails = deps.currentContact()
        residence = deps.currentResidence()
        citizenship = deps.currentCitizenship()
        currencyCountry = deps.currentCurrencyCountry()
    }

    var isCitizenshipLocked: Bool { passportCitizenship != nil }

    func open(_ field: ProfileV3ProfileField) {
        switch field {
        case .residence:
            navigator?.push(.residence)
        case .citizenship:
            guard !isCitizenshipLocked else {
                citizenshipLockTrigger += 1
                return
            }
            navigator?.push(.citizenship)
        case .contact:
            contactDetails = deps.currentContact()
            navigator?.push(.contactInfo)
        case .currency:
            navigator?.push(.currency)
        }
        loadEditField(field)
    }

    func retryEditField() {
        guard let requestedField else { return }
        loadEditField(requestedField)
    }

    func applyCitizenship(code: String?) {
        passportCitizenship = code.map { ProfileV3Country(code: $0) ?? ProfileV3Country(code: $0, name: $0) }
        citizenshipIconCode = code
    }

    func selectResidence(_ country: ProfileV3Country) {
        let previous = residence?.code
        guard deps.saveResidence(country) else { return }
        residence = country
        let code = country.code
        let pushLegacy = deps.pushResidenceToServer
        let pending = write(.residence, .code(code), replacing: previous, alongside: { @Sendable in
            await pushLegacy(code)
        })
        router?.restartAfterSaving(pending)
    }

    func selectCitizenship(_ country: ProfileV3Country) {
        guard country != citizenship else {
            navigator?.popToRoot()
            return
        }
        let previous = citizenship?.code
        guard deps.saveCitizenship(country) else { return }
        citizenship = country
        citizenshipIconCode = country.code
        let pending = write(.citizenship, .code(country.code), replacing: previous)
        router?.restartAfterSaving(pending)
    }

    func selectCurrency(_ country: ProfileV3Country) {
        let previous = currencyCountry.flatMap(ProfileV3CurrencyCodes.code(for:))
        deps.saveCurrencyCountry(country)
        currencyCountry = country
        if let currency = ProfileV3CurrencyCodes.code(for: country) {
            write(.currency, .code(currency), replacing: previous)
        }
        navigator?.popToRoot()
    }

    func saveContact(_ details: ProfileV3ContactDetails) async -> ContactUpdateOutcome {
        let changedFields = [
            details.email != contactDetails.email ? "email" : nil,
            details.mobileNumber != contactDetails.mobileNumber ? "phone" : nil
        ].compactMap { $0 }
        let previous = contactDetails
        let outcome = await deps.saveContact(details)
        switch outcome {
        case .success:
            ProfileV3Analytics.contactUpdated(to: details, from: previous)
            contactDetails = details
            write(.contact, .contact(email: details.email, mobileNumber: details.mobileNumber))
            router?.showFlash(ProfileV3Strings.contactSaved, isSuccess: true)
            if navigator?.path.last == .contactInfo {
                navigator?.popToRoot()
            }
        case .failure:
            ProfileV3Analytics.contactSaveFailed(errorKind: "save_failed", changedFields: changedFields)
            router?.showFlash(ProfileV3Strings.contactSaveFailed, isSuccess: false)
        case .duplicateEmail:
            ProfileV3Analytics.contactSaveFailed(errorKind: "duplicate_email", changedFields: changedFields)
        }
        return outcome
    }

    func cancelReads() {
        editFieldTask?.cancel()
    }

    private func loadEditField(_ field: ProfileV3ProfileField) {
        requestedField = field
        editField = nil
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.editFieldTask,
            phase: \.editFieldPhase,
            content: \.editField,
            fetch: { try await repository.loadEditField(field) },
            apply: { $0.editField = $1 }
        )
    }

    @discardableResult
    private func write(
        _ field: ProfileV3ProfileField,
        _ value: ProfileV3ProfileFieldValue,
        replacing previous: String? = nil,
        alongside legacy: (@Sendable () async -> Void)? = nil
    ) -> Task<Void, Never> {
        let repository = repository
        let profileID = profileID
        let tracked = ProfileV3Analytics.ProfileField(rawValue: field.rawValue)
        return writes.enqueue { [weak self] in
            async let legacyPush: Void? = legacy?()
            do {
                try await repository.saveProfileField(field, value: value, profileID: profileID)
                if let tracked, case .code(let code) = value {
                    ProfileV3Analytics.fieldUpdated(tracked, to: code, from: previous)
                }
            } catch {
                if let tracked { ProfileV3Analytics.fieldSaveFailed(tracked, error: error) }
                self?.router?.showFlash(ProfileV3Strings.saveFailed, isSuccess: false)
            }
            _ = await legacyPush
        }
    }
}
