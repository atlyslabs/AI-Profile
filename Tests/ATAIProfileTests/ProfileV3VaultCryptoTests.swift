import CryptoKit
import Foundation
import Security
import Testing
@testable import ATAIProfile

private struct VaultCryptoTestError: Error {}

@Suite("Vault crypto")
struct ProfileV3VaultCryptoTests {
    @Test func sealedBodyOpensOnlyForTheTokenUid() throws {
        let privateKey = try rsaKey()
        guard let publicKey = SecKeyCopyPublicKey(privateKey),
              let pkcs1 = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            throw VaultCryptoTestError()
        }
        let pem = pemBlock(spki(pkcs1: pkcs1))
        let json = Data(#"{"password":"hunter2"}"#.utf8)

        let body = try ProfileV3VaultCrypto.seal(json, uid: "user-1", key: .init(id: "key-1", pem: pem))
        let opened = try openSealed(body, privateKey: privateKey, uid: "user-1")
        #expect(opened == json)
        #expect(throws: (any Error).self) {
            try openSealed(body, privateKey: privateKey, uid: "someone-else")
        }
    }

    @Test func revealOpensWithThePhoneKey() throws {
        let phone = try ecKey()
        let ephemeral = try ecKey()
        let secret = try ProfileV3VaultCrypto.sharedSecret(spkiPoint(ephemeral), privateKey: phone)
        let info = Data("fort-knox-reveal-v1".utf8)
        let aesKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: secret),
            salt: Data(repeating: 0, count: 32),
            info: info,
            outputByteCount: 32
        )
        let plain = Data(#"{"username":"a@b.c","password":"hunter2"}"#.utf8)
        let sealed = try AES.GCM.seal(plain, using: aesKey, authenticating: Data("user-1".utf8))
        let envelope = ProfileV3VaultCrypto.RevealEnvelope(
            ephemeralPublicKey: spkiPoint(ephemeral),
            nonce: Data(sealed.nonce).base64EncodedString(),
            ciphertext: (sealed.ciphertext + sealed.tag).base64EncodedString(),
            kdfInfo: "fort-knox-reveal-v1"
        )

        let opened = try ProfileV3VaultCrypto.openReveal(envelope, privateKey: phone, uid: "user-1")
        #expect(opened == plain)
    }

    @Test func conflictMessageKeepsTheExistingCredentialID() {
        let message = "already saved for this service; edit or delete credential fd2c2c21-abdf-4f43-ba4a-3a1b9a374af1"
        #expect(ProfileV3VaultParsing.existingID(in: message) == "fd2c2c21-abdf-4f43-ba4a-3a1b9a374af1")
        #expect(ProfileV3VaultParsing.existingID(in: "no id here") == nil)
    }

    private func openSealed(_ body: Data, privateKey: SecKey, uid: String) throws -> Data {
        guard let object = try JSONSerialization.jsonObject(with: body) as? [String: Any],
              let encrypted = object["encrypted"] as? [String: Any],
              let encryptedKeyText = encrypted["encrypted_key"] as? String,
              let nonceText = encrypted["nonce"] as? String,
              let ciphertextText = encrypted["ciphertext"] as? String,
              let encryptedKey = Data(base64Encoded: encryptedKeyText),
              let nonce = Data(base64Encoded: nonceText),
              let ciphertext = Data(base64Encoded: ciphertextText) else {
            throw VaultCryptoTestError()
        }
        var error: Unmanaged<CFError>?
        guard let aes = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionOAEPSHA256, encryptedKey as CFData, &error) as Data? else {
            throw VaultCryptoTestError()
        }
        let box = try AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: nonce),
            ciphertext: ciphertext.dropLast(16),
            tag: ciphertext.suffix(16)
        )
        return try AES.GCM.open(box, using: SymmetricKey(data: aes), authenticating: Data(uid.utf8))
    }

    private func rsaKey() throws -> SecKey {
        var error: Unmanaged<CFError>?
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
        ]
        guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else { throw VaultCryptoTestError() }
        return key
    }

    private func ecKey() throws -> SecKey {
        var error: Unmanaged<CFError>?
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
        ]
        guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else { throw VaultCryptoTestError() }
        return key
    }

    private func spkiPoint(_ privateKey: SecKey) -> String {
        let publicKey = SecKeyCopyPublicKey(privateKey)!
        let point = SecKeyCopyExternalRepresentation(publicKey, nil)! as Data
        let header = Data([
            0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01,
            0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00,
        ])
        return (header + point).base64EncodedString()
    }

    private func spki(pkcs1: Data) -> Data {
        let header = Data([
            0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00,
        ])
        let bitString = asn1(0x03, Data([0x00]) + pkcs1)
        return asn1(0x30, header + bitString)
    }

    private func asn1(_ tag: UInt8, _ content: Data) -> Data {
        var encoded = Data([tag])
        if content.count < 128 {
            encoded.append(UInt8(content.count))
        } else {
            let length = content.count
            let bytes = [UInt8((length >> 8) & 0xFF), UInt8(length & 0xFF)]
            encoded.append(0x82)
            encoded.append(contentsOf: bytes)
        }
        encoded.append(content)
        return encoded
    }

    private func pemBlock(_ der: Data) -> String {
        "-----BEGIN PUBLIC KEY-----\n\(der.base64EncodedString())\n-----END PUBLIC KEY-----\n"
    }
}
