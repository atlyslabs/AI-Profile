import Foundation

#if DEBUG
final class ProfileV3VaultStore: @unchecked Sendable {
    struct Entry: Equatable {
        var credential: ProfileV3VaultCredential
        var password: String
    }

    private let lock = NSLock()
    private var entries: [Entry]
    private var nextID = 0

    init(entries: [Entry] = ProfileV3VaultFixtures.entries) {
        self.entries = entries
    }

    func list() -> [ProfileV3VaultCredential] {
        lock.lock()
        defer { lock.unlock() }
        return entries.map { entry in
            var row = entry.credential
            row.username = nil
            return row
        }
    }

    func credential(id: String, includeUsername: Bool) throws -> ProfileV3VaultCredential {
        lock.lock()
        defer { lock.unlock() }
        guard var row = entries.first(where: { $0.credential.id == id })?.credential else {
            throw ProfileV3Error.server(code: nil, message: nil)
        }
        if !includeUsername { row.username = nil }
        return row
    }

    func save(_ draft: ProfileV3VaultDraft) throws -> ProfileV3VaultWriteResult {
        lock.lock()
        defer { lock.unlock() }
        let site = draft.siteSlug.flatMap { slug in ProfileV3VaultFixtures.sites.first { $0.slug == slug } }
        let url = site?.loginURL ?? draft.url
        let host = url.flatMap(URL.init(string:)).flatMap(ProfileV3VaultSite.bareHost)
        if let existing = entries.first(where: { entry in
            entry.credential.url.flatMap(URL.init(string:)).flatMap(ProfileV3VaultSite.bareHost) == host
        }) {
            throw ProfileV3VaultAlreadySaved(
                id: existing.credential.id,
                message: "already saved for this service; edit or delete credential \(existing.credential.id)"
            )
        }
        nextID += 1
        let id = "fixture-vault-\(nextID)"
        entries.append(Entry(
            credential: ProfileV3VaultCredential(
                id: id,
                displayName: site?.displayName ?? draft.label ?? host ?? "",
                url: url,
                status: .added,
                username: draft.username
            ),
            password: draft.password ?? ""
        ))
        return ProfileV3VaultWriteResult(id: id, status: .added)
    }

    func update(id: String, draft: ProfileV3VaultDraft) throws -> ProfileV3VaultWriteResult {
        lock.lock()
        defer { lock.unlock() }
        guard let index = entries.firstIndex(where: { $0.credential.id == id }) else {
            throw ProfileV3Error.server(code: nil, message: nil)
        }
        if let username = draft.username { entries[index].credential.username = username }
        if let password = draft.password { entries[index].password = password }
        entries[index].credential.status = .added
        return ProfileV3VaultWriteResult(id: id, status: .added)
    }

    func delete(id: String) {
        lock.lock()
        defer { lock.unlock() }
        entries.removeAll { $0.credential.id == id }
    }

    func password(id: String) throws -> String {
        lock.lock()
        defer { lock.unlock() }
        guard let entry = entries.first(where: { $0.credential.id == id }) else {
            throw ProfileV3Error.server(code: nil, message: nil)
        }
        return entry.password
    }
}

enum ProfileV3VaultFixtures {
    static let sites = [
        ProfileV3VaultSite(
            slug: "singapore_airlines",
            displayName: "Singapore Airlines KrisFlyer",
            loginURL: "https://www.singaporeair.com/en_UK/ppsclub-krisflyer/"
        ),
    ]

    static let entries = [
        ProfileV3VaultStore.Entry(
            credential: ProfileV3VaultCredential(
                id: "fixture-vault-hdfc",
                displayName: "myhdfcbank.com",
                url: "https://hdfcbank.in/ways-to-bank/digital-banking",
                status: .live,
                usernameHint: "6F****H",
                username: "6FGH43H"
            ),
            password: "6FGH43H"
        ),
        ProfileV3VaultStore.Entry(
            credential: ProfileV3VaultCredential(
                id: "fixture-vault-abc",
                displayName: "abc.com",
                url: "https://abc.com",
                status: .live,
                usernameHint: "ra***@atlys.com",
                username: "rahul@atlys.com"
            ),
            password: "hunter2"
        ),
    ]
}
#endif
