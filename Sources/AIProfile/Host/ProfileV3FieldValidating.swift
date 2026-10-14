import Foundation

public protocol ProfileV3FieldValidating: Sendable {
    func isValidEmail(_ email: String) -> Bool
    func isValidPassportNumber(_ number: String, nationality: String?) -> Bool
}

enum ProfileV3FieldValidation {
    private static let lock = NSLock()
    #if DEBUG
    nonisolated(unsafe) private static var host: (any ProfileV3FieldValidating)? = ProfileV3PlaceholderFieldValidator()
    #else
    nonisolated(unsafe) private static var host: (any ProfileV3FieldValidating)?
    #endif

    static func install(_ validator: any ProfileV3FieldValidating) {
        lock.lock()
        host = validator
        lock.unlock()
    }

    static func isValidEmail(_ email: String) -> Bool {
        current?.isValidEmail(email) ?? false
    }

    static func isValidPassportNumber(_ number: String, nationality: String?) -> Bool {
        current?.isValidPassportNumber(number, nationality: nationality) ?? false
    }

    private static var current: (any ProfileV3FieldValidating)? {
        lock.lock()
        let validator = host
        lock.unlock()
        return validator
    }
}
