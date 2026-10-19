import ATAuthKit
import Foundation

final class ProfileV3VaultClient: @unchecked Sendable {
    private let client: ProfileV3NetworkClient
    private let session: any ProfileV3SessionProviding
    private let keys = KeyCache()
    private let decoder = JSONDecoder()

    init(client: ProfileV3NetworkClient, session: any ProfileV3SessionProviding) {
        self.client = client
        self.session = session
    }

    func credentials() async throws -> ProfileV3AppAccess {
        let rows: [CredentialDTO] = try await send(.vaultCredentials, action: "vault_credentials")
        return ProfileV3AppAccess(
            autoConnected: [],
            apps: [],
            vault: rows.map { $0.credential(includeUsername: false) },
            usesVault: true
        )
    }

    func sites() async throws -> [ProfileV3VaultSite] {
        let rows: [SiteDTO] = try await send(.vaultSites, action: "vault_sites")
        return rows.map { ProfileV3VaultSite(slug: $0.slug, displayName: $0.displayName, loginURL: $0.loginURL) }
    }

    func credential(id: String, includeUsername: Bool) async throws -> ProfileV3VaultCredential {
        let row: CredentialDTO = try await send(
            .vaultCredential(id: id, includeUsername: includeUsername),
            action: "vault_credential"
        )
        return row.credential(includeUsername: includeUsername)
    }

    func save(_ draft: ProfileV3VaultDraft) async throws -> ProfileV3VaultWriteResult {
        try await writing(action: "vault_save") {
            .vaultCreateCredential(body: try await self.sealed(draft))
        }
    }

    func update(id: String, draft: ProfileV3VaultDraft) async throws -> ProfileV3VaultWriteResult {
        try await writing(action: "vault_update") {
            .vaultUpdateCredential(id: id, body: try await self.sealed(draft))
        }
    }

    func retest(id: String) async throws -> ProfileV3VaultWriteResult {
        try await write(.vaultCredentialAction(id: id, action: "retest"), action: "vault_retest")
    }

    func pause(id: String) async throws -> ProfileV3VaultWriteResult {
        try await write(.vaultCredentialAction(id: id, action: "pause"), action: "vault_pause")
    }

    func resume(id: String) async throws -> ProfileV3VaultWriteResult {
        try await write(.vaultCredentialAction(id: id, action: "resume"), action: "vault_resume")
    }

    func delete(id: String) async throws {
        try await perform(.vaultDeleteCredential(id: id), action: "vault_delete")
    }

    func revealPassword(id: String, deviceName: String) async throws -> String {
        let context = try await ProfileV3VaultDevice.authenticate()
        let deviceID = try await enrolledDeviceID(name: deviceName)
        let challenge: ChallengeDTO = try await send(
            .vaultRevealChallenge(id: id, body: try JSONEncoder().encode(DeviceBody(deviceID: deviceID))),
            action: "vault_reveal_challenge"
        )
        let signature: String
        do {
            signature = try ProfileV3VaultDevice.sign(challenge.message, context: context)
        } catch {
            ProfileV3VaultDevice.deleteKey()
            throw error
        }
        let response: RevealDTO
        do {
            response = try await send(
                .vaultReveal(id: id, body: try JSONEncoder().encode(RevealBody(
                    deviceID: deviceID,
                    nonce: challenge.nonce,
                    signature: signature
                ))),
                action: "vault_reveal"
            )
        } catch {
            if Self.shouldEnrollAgain(error) {
                ProfileV3VaultDevice.deleteKey()
            }
            throw error
        }
        let uid = try uid()
        let plain = try ProfileV3VaultDevice.open(response.encrypted, uid: uid, context: context)
        let secret = try decoder.decode(SecretDTO.self, from: plain)
        return secret.password
    }

    private func enrolledDeviceID(name: String) async throws -> String {
        if let existing = ProfileV3VaultDevice.deviceID() { return existing }
        guard await Self.signedInRecently() else { throw ProfileV3Error.server(code: "reauth", message: ProfileV3VaultStrings.confirmItsYou) }
        let pem = try ProfileV3VaultDevice.publicKeyPEM()
        let body = try JSONEncoder().encode(RegisterDeviceBody(name: name, platform: "ios", publicKeyPEM: pem))
        let created: DeviceDTO = try await send(.vaultRegisterDevice(body: body), action: "vault_register_device")
        ProfileV3VaultDevice.saveDeviceID(created.id)
        return created.id
    }

    private func sealed(_ draft: ProfileV3VaultDraft) async throws -> Data {
        let uid = try uid()
        let key = try await publicKey()
        do {
            return try ProfileV3VaultCrypto.seal(try draft.encoded(), uid: uid, key: key)
        } catch {
            await keys.invalidate()
            let refreshed = try await publicKey()
            return try ProfileV3VaultCrypto.seal(try draft.encoded(), uid: uid, key: refreshed)
        }
    }

    private func publicKey() async throws -> ProfileV3VaultCrypto.PublicKey {
        try await keys.key {
            let dto: PublicKeyDTO = try await self.send(.vaultPublicKey, action: "vault_public_key")
            return ProfileV3VaultCrypto.PublicKey(id: dto.keyID, pem: dto.pem)
        }
    }

    private func writing(
        action: String,
        endpoint: () async throws -> ProfileV3API
    ) async throws -> ProfileV3VaultWriteResult {
        do {
            return try await write(try await endpoint(), action: action)
        } catch {
            if let saved = Self.alreadySaved(error) { throw saved }
            guard Self.envelopeRejected(error) else { throw error }
            await keys.invalidate()
            return try await write(try await endpoint(), action: action)
        }
    }

    private func write(_ endpoint: ProfileV3API, action: String) async throws -> ProfileV3VaultWriteResult {
        let dto: WriteDTO = try await send(endpoint, action: action)
        return ProfileV3VaultWriteResult(id: dto.id, status: ProfileV3VaultStatus(raw: dto.status))
    }

    private func uid() throws -> String {
        guard let uid = session.currentUserID?.nonEmpty else { throw ProfileV3Error.unauthorized }
        return uid
    }

    private func send<T: Decodable>(_ endpoint: ProfileV3API, action: String) async throws -> T {
        try await ProfileV3APIErrorMapper.withUnauthorizedRetry(action: action) {
            try await client.request(endpoint)
        }
    }

    private func perform(_ endpoint: ProfileV3API, action: String) async throws {
        try await ProfileV3APIErrorMapper.withUnauthorizedRetry(action: action) {
            try await client.perform(endpoint)
        }
    }

    @MainActor
    private static func signedInRecently() -> Bool {
        guard let date = ATAuthKit.currentUser?.metadata.lastSignInDate else { return false }
        return Date().timeIntervalSince(date) < 10 * 60
    }

    private static func alreadySaved(_ error: Error) -> ProfileV3VaultAlreadySaved? {
        guard case ProfileV3Error.conflict(_, let message) = error,
              let id = ProfileV3VaultParsing.existingID(in: message) else { return nil }
        return ProfileV3VaultAlreadySaved(id: id, message: message ?? ProfileV3Strings.somethingWentWrong)
    }

    private static func envelopeRejected(_ error: Error) -> Bool {
        guard case ProfileV3Error.invalidRequest(let message) = error else { return false }
        return message?.localizedCaseInsensitiveContains("could not be opened") == true
    }

    private static func shouldEnrollAgain(_ error: Error) -> Bool {
        guard case ProfileV3Error.server(_, let message) = error else { return false }
        let text = message?.localizedLowercase ?? ""
        return text.contains("not enrolled") || text.contains("signature rejected")
    }
}

private actor KeyCache {
    private var cached: (key: ProfileV3VaultCrypto.PublicKey, expiry: Date)?

    func key(_ load: () async throws -> ProfileV3VaultCrypto.PublicKey) async throws -> ProfileV3VaultCrypto.PublicKey {
        if let cached, cached.expiry > Date() { return cached.key }
        let key = try await load()
        cached = (key, Date().addingTimeInterval(5 * 60))
        return key
    }

    func invalidate() {
        cached = nil
    }
}

private struct PublicKeyDTO: Decodable {
    let keyID: String
    let pem: String

    enum CodingKeys: String, CodingKey {
        case keyID = "key_id"
        case pem
    }
}

private struct SiteDTO: Decodable {
    let slug: String
    let displayName: String
    let loginURL: String?

    enum CodingKeys: String, CodingKey {
        case slug
        case displayName = "display_name"
        case loginURL = "login_url"
    }
}

private struct CredentialDTO: Decodable {
    let id: String
    let displayName: String
    let url: String?
    let status: String?
    let attentionReason: String?
    let usernameHint: String?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case url
        case status
        case attentionReason = "attention_reason"
        case usernameHint = "username_hint"
        case username
    }

    func credential(includeUsername: Bool) -> ProfileV3VaultCredential {
        ProfileV3VaultCredential(
            id: id,
            displayName: displayName,
            url: url,
            status: ProfileV3VaultStatus(raw: status),
            attentionReason: attentionReason,
            usernameHint: usernameHint,
            username: includeUsername ? username : nil
        )
    }
}

private struct WriteDTO: Decodable {
    let id: String
    let status: String?
}

private struct DeviceDTO: Decodable {
    let id: String
}

private struct ChallengeDTO: Decodable {
    let nonce: String
    let message: String
}

private struct RevealDTO: Decodable {
    let encrypted: ProfileV3VaultCrypto.RevealEnvelope
}

private struct SecretDTO: Decodable {
    let password: String
}

private struct DeviceBody: Encodable {
    let deviceID: String

    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
    }
}

private struct RevealBody: Encodable {
    let deviceID: String
    let nonce: String
    let signature: String

    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case nonce
        case signature
    }
}

private struct RegisterDeviceBody: Encodable {
    let name: String
    let platform: String
    let publicKeyPEM: String

    enum CodingKeys: String, CodingKey {
        case name
        case platform
        case publicKeyPEM = "public_key_pem"
    }
}
