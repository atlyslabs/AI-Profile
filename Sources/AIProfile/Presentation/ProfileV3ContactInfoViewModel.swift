import ATUIKit
import Combine
import Foundation

@MainActor
final class ProfileV3ContactInfoViewModel: ObservableObject {

    @Published var details: ProfileV3ContactDetails {
        didSet { detailsChanged(from: oldValue) }
    }
    @Published var showsDialPicker = false
    @Published private(set) var isSaving = false
    @Published private(set) var serverEmailError: String?

    private let onBack: () -> Void
    private let onSave: (ProfileV3ContactDetails) async -> ContactUpdateOutcome

    init(
        details: ProfileV3ContactDetails,
        onBack: @escaping () -> Void,
        onSave: @escaping (ProfileV3ContactDetails) async -> ContactUpdateOutcome
    ) {
        self.details = details
        self.onBack = onBack
        self.onSave = onSave
    }

    var countryOption: LoginCountryOption { details.phoneOption }

    var trimmedEmail: String { details.email.trimmingCharacters(in: .whitespaces) }
    var isEmailValid: Bool { ProfileV3FieldValidation.isValidEmail(trimmedEmail) }
    var isPhoneValid: Bool { details.isPhoneValid }
    var canSave: Bool { isEmailValid && isPhoneValid }

    var emailError: String? {
        if let serverEmailError { return serverEmailError }
        guard !trimmedEmail.isEmpty else { return nil }
        return isEmailValid ? nil : ProfileV3Strings.emailInvalid
    }

    var phoneError: String? {
        guard !details.phoneDigits.isEmpty else { return nil }
        return isPhoneValid ? nil : ProfileV3Strings.phoneInvalid
    }

    func selectCountry(_ option: LoginCountryOption) {
        details.selectDial(option)
        showsDialPicker = false
    }

    func tapBack() {
        onBack()
    }

    func save() {
        guard !isSaving else { return }
        isSaving = true
        var payload = details
        payload.email = trimmedEmail
        let onSave = onSave
        Task { [weak self] in
            let outcome = await onSave(payload)
            guard let self else { return }
            isSaving = false
            if outcome == .duplicateEmail {
                serverEmailError = ProfileV3Strings.emailTaken
            }
        }
    }

    private func detailsChanged(from oldValue: ProfileV3ContactDetails) {
        guard details != oldValue else { return }
        if details.email != oldValue.email {
            serverEmailError = nil
        }
        details.sanitisePhoneDigits()
    }
}

#if DEBUG
extension ProfileV3ContactInfoViewModel {
    static func preview(
        _ details: ProfileV3ContactDetails,
        isSaving: Bool = false,
        serverEmailError: String? = nil
    ) -> ProfileV3ContactInfoViewModel {
        let viewModel = ProfileV3ContactInfoViewModel(details: details, onBack: {}, onSave: { _ in .success })
        viewModel.isSaving = isSaving
        viewModel.serverEmailError = serverEmailError
        return viewModel
    }
}
#endif
