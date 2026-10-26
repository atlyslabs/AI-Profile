import CryptoKit
import Foundation
import Security

enum ProfileV3VaultCrypto {
    struct PublicKey: Equatable, Sendable {
        let id: String
        let pem: String
    }

    struct Envelope: Encodable {
        struct Sealed: Encodable {
            let keyID: String
            let encryptedKey: String
            let nonce: String
            let ciphertext: String

            enum CodingKeys: String, CodingKey {
                case keyID = "key_id"
                case encryptedKey = "encrypted_key"
                case nonce
                case ciphertext
            }
        }

        let encrypted: Sealed
    }

    struct RevealEnvelope: Decodable, Equatable {
        let ephemeralPublicKey: String
        let nonce: String
        let ciphertext: String
        let kdfInfo: String

        enum CodingKeys: String, CodingKey {
            case ephemeralPublicKey = "ephemeral_public_key"
            case nonce
            case ciphertext
            case kdfInfo = "kdf_info"
        }
    }

    static func seal(_ json: Data, uid: String, key: PublicKey) throws -> Data {
        let aesKey = SymmetricKey(size: .bits256)
        let nonce = AES.GCM.Nonce()
        let sealed = try AES.GCM.seal(json, using: aesKey, nonce: nonce, authenticating: Data(uid.utf8))
        let aesData = aesKey.withUnsafeBytes { Data($0) }
        let encryptedKey = try encryptKey(aesData, pem: key.pem)
        let envelope = Envelope(encrypted: Envelope.Sealed(
            keyID: key.id,
            encryptedKey: encryptedKey.base64EncodedString(),
            nonce: Data(nonce).base64EncodedString(),
            ciphertext: (sealed.ciphertext + sealed.tag).base64EncodedString()
        ))
        return try JSONEncoder().encode(envelope)
    }

    static func openReveal(_ envelope: RevealEnvelope, privateKey: SecKey, uid: String) throws -> Data {
        let secret = try sharedSecret(envelope.ephemeralPublicKey, privateKey: privateKey)
        let aesKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: secret),
            salt: Data(repeating: 0, count: 32),
            info: Data(envelope.kdfInfo.utf8),
            outputByteCount: 32
        )
        guard let nonceData = Data(base64Encoded: envelope.nonce),
              let combined = Data(base64Encoded: envelope.ciphertext),
              combined.count > 16 else {
            throw ProfileV3Error.invalidRequest(message: nil)
        }
        let cipher = combined.dropLast(16)
        let tag = combined.suffix(16)
        let box = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonceData), ciphertext: cipher, tag: tag)
        return try AES.GCM.open(box, using: aesKey, authenticating: Data(uid.utf8))
    }

    static func encryptKey(_ key: Data, pem: String) throws -> Data {
        let publicKey = try rsaPublicKey(pem: pem)
        var error: Unmanaged<CFError>?
        guard let encrypted = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionOAEPSHA256, key as CFData, &error) else {
            throw ProfileV3Error.invalidRequest(message: error?.takeRetainedValue().localizedDescription)
        }
        return encrypted as Data
    }

    static func rsaPublicKey(pem: String) throws -> SecKey {
        let body = pem
            .components(separatedBy: .newlines)
            .filter { !$0.hasPrefix("-----") }
            .joined()
            .filter { !$0.isWhitespace }
        guard let der = Data(base64Encoded: body) else {
            throw ProfileV3Error.invalidRequest(message: nil)
        }
        if let key = rsaPublicKey(data: der) { return key }
        if let key = rsaPublicKey(data: pkcs1RSAPublicKey(from: der)) { return key }
        throw ProfileV3Error.invalidRequest(message: nil)
    }

    private static func rsaPublicKey(data: Data) -> SecKey? {
        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
        ]
        return SecKeyCreateWithData(data as CFData, attributes as CFDictionary, nil)
    }

    /// `BEGIN PUBLIC KEY` is an SPKI wrapper. Secure Enclave import wants the PKCS#1 key inside it.
    private static func pkcs1RSAPublicKey(from der: Data) -> Data {
        let oid = Data([0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01])
        guard let oidRange = der.range(of: oid) else { return der }
        var index = oidRange.upperBound
        if index < der.endIndex, der[index] == 0x05 {
            index = der.index(index, offsetBy: 2, limitedBy: der.endIndex) ?? der.endIndex
        }
        guard index < der.endIndex, der[index] == 0x03 else { return der }
        index = der.index(after: index)
        let (length, content) = asn1Length(der, at: index)
        let keyStart = der.index(after: content)
        let keyEnd = der.index(keyStart, offsetBy: length - 1, limitedBy: der.endIndex) ?? der.endIndex
        return Data(der[keyStart ..< keyEnd])
    }

    private static func asn1Length(_ data: Data, at index: Data.Index) -> (Int, Data.Index) {
        let first = Int(data[index])
        if first < 0x80 { return (first, data.index(after: index)) }
        let count = first & 0x7F
        var length = 0
        var cursor = data.index(after: index)
        for _ in 0 ..< count {
            length = (length << 8) | Int(data[cursor])
            cursor = data.index(after: cursor)
        }
        return (length, cursor)
    }

    static func sharedSecret(_ ephemeralPublicKey: String, privateKey: SecKey) throws -> Data {
        guard let encoded = Data(base64Encoded: ephemeralPublicKey) else {
            throw ProfileV3Error.invalidRequest(message: nil)
        }
        let point = encoded.first == 0x04 && encoded.count == 65 ? encoded : Data(encoded.suffix(65))
        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
        ]
        var error: Unmanaged<CFError>?
        guard let publicKey = SecKeyCreateWithData(point as CFData, attributes as CFDictionary, &error) else {
            throw ProfileV3Error.invalidRequest(message: error?.takeRetainedValue().localizedDescription)
        }
        guard let secret = SecKeyCopyKeyExchangeResult(
            privateKey,
            .ecdhKeyExchangeStandard,
            publicKey,
            [:] as CFDictionary,
            &error
        ) else {
            throw ProfileV3Error.invalidRequest(message: error?.takeRetainedValue().localizedDescription)
        }
        return secret as Data
    }
}
