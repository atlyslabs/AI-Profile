import ATAIProfile
import Foundation

final class VDCProfileV3FieldValidator: ProfileV3FieldValidating, @unchecked Sendable {
    func isValidEmail(_ email: String) -> Bool {
        InputValidator.isValidEmail(email)
    }

    func isValidPassportNumber(_ number: String, nationality: String?) -> Bool {
        PassportDataHandler.getPassportNumberValidator(forNationality: nationality).validatorFunc(number)
    }
}
