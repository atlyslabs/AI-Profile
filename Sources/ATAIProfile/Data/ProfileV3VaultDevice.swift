import Foundation
import LocalAuthentication
import Security

enum ProfileV3VaultDevice {
    private static let keyTag = Data("com.atlys.profile.vault.reveal".utf8)
    private static let deviceService = "com.atlys.profile.vault.device"

    static func publicKeyPEM() throws -> String {
        let privateKey = try ensurePrivateKey()
        let publicKey = storedPublicKey() ?? SecKeyCopyPublicKey(privateKey)
        guard let publicKey else {
            throw ProfileV3Error.underlying(ProfileV3VaultStrings.revealNeedsPhone)
        }
        var error: Unmanaged<CFError>?
        guard let external = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            throw ProfileV3Error.underlying(ProfileV3VaultStrings.revealNeedsPhone)
        }
        return pem(spki: spki(uncompressedPoint: external))
    }

    static func sign(_ message: String, context: LAContext) throws -> String {
        let key = try privateKey(context: context)
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            key,
            .ecdsaSignatureMessageX962SHA256,
            Data(message.utf8) as CFData,
            &error
        ) else {
            throw ProfileV3Error.underlying(error?.takeRetainedValue().localizedDescription ?? ProfileV3VaultStrings.revealNeedsPhone)
        }
        return (signature as Data).base64EncodedString()
    }

    static func open(_ envelope: ProfileV3VaultCrypto.RevealEnvelope, uid: String, context: LAContext) throws -> Data {
        try ProfileV3VaultCrypto.openReveal(envelope, privateKey: privateKey(context: context), uid: uid)
    }

    static func deleteKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
        ]
        SecItemDelete(query as CFDictionary)
        clearDeviceID()
    }

    static func deviceID() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: deviceService,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let id = String(data: data, encoding: .utf8)?.nonEmpty else {
            return nil
        }
        return id
    }

    static func saveDeviceID(_ id: String) {
        clearDeviceID()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: deviceService,
            kSecValueData as String: Data(id.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    static func authenticate() async throws -> LAContext {
        let context = LAContext()
        context.localizedCancelTitle = ProfileV3Strings.close
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw ProfileV3Error.underlying(ProfileV3VaultStrings.revealNeedsPhone)
        }
        let success = try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: ProfileV3VaultStrings.showPassword
        )
        guard success else { throw ProfileV3Error.underlying(ProfileV3VaultStrings.revealNeedsPhone) }
        return context
    }

    static func unlockVault() async -> ProfileV3VaultUnlock {
        let context = LAContext()
        context.localizedCancelTitle = ProfileV3Strings.close
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { return .unlocked }
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: ProfileV3VaultStrings.unlockVault
            )
            return success ? .unlocked : .cancelled
        } catch {
            return .cancelled
        }
    }

    private static func clearDeviceID() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: deviceService,
        ]
        SecItemDelete(query as CFDictionary)
    }

    private static func ensurePrivateKey() throws -> SecKey {
        if let existing = try? privateKey(context: nil) { return existing }
        var error: Unmanaged<CFError>?
        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            [.privateKeyUsage, .biometryCurrentSet],
            &error
        ) else {
            throw ProfileV3Error.underlying(ProfileV3VaultStrings.revealNeedsPhone)
        }
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: keyTag,
                kSecAttrAccessControl as String: access,
            ],
        ]
        guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw ProfileV3Error.underlying(ProfileV3VaultStrings.revealNeedsPhone)
        }
        return key
    }

    private static func privateKey(context: LAContext?) throws -> SecKey {
        var query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true,
        ]
        if let context {
            query[kSecUseAuthenticationContext as String] = context
        }
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let key = copiedKey(item) else {
            throw ProfileV3Error.underlying(ProfileV3VaultStrings.revealNeedsPhone)
        }
        return key
    }

    private static func storedPublicKey() -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnRef as String: true,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess else { return nil }
        return copiedKey(item)
    }

    private static func copiedKey(_ item: CFTypeRef?) -> SecKey? {
        guard let item else { return nil }
        return unsafeDowncast(item, to: SecKey.self)
    }

    private static func spki(uncompressedPoint point: Data) -> Data {
        let header: [UInt8] = [
            0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01,
            0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00,
        ]
        return Data(header) + point
    }

    private static func pem(spki: Data) -> String {
        let encoded = spki.base64EncodedString()
        var lines: [String] = []
        var index = encoded.startIndex
        while index < encoded.endIndex {
            let end = encoded.index(index, offsetBy: 64, limitedBy: encoded.endIndex) ?? encoded.endIndex
            lines.append(String(encoded[index ..< end]))
            index = end
        }
        return "-----BEGIN PUBLIC KEY-----\n\(lines.joined(separator: "\n"))\n-----END PUBLIC KEY-----\n"
    }
}
