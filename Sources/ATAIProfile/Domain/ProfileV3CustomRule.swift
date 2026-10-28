import Foundation

struct ProfileV3CustomRule: Identifiable, Equatable, Codable, Sendable {
    let id: String
    var text: String
    let createdAt: Date

    init(id: String = UUID().uuidString, text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

protocol ProfileV3CustomRulesRepository: Sendable {
    func loadCustomRules(agentID: String, profileID: String?) async throws -> [ProfileV3CustomRule]
    func saveCustomRule(_ rule: ProfileV3CustomRule, agentID: String, profileID: String?) async throws
    func deleteCustomRule(id: String, agentID: String, profileID: String?) async throws
}

final class ProfileV3CustomRulesStore: @unchecked Sendable {
    private let defaults: UserDefaults?
    private let lock = NSLock()
    private var memory: [String: [ProfileV3CustomRule]] = [:]

    init(defaults: UserDefaults? = nil) {
        self.defaults = defaults
    }

    func rules(owner: String, agentID: String, profileID: String?) -> [ProfileV3CustomRule] {
        lock.withLock { read(key(owner, agentID, profileID)) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func save(_ rule: ProfileV3CustomRule, owner: String, agentID: String, profileID: String?) {
        let key = key(owner, agentID, profileID)
        lock.withLock {
            var rules = read(key)
            if let index = rules.firstIndex(where: { $0.id == rule.id }) {
                rules[index] = rule
            } else {
                rules.append(rule)
            }
            write(rules, key)
        }
    }

    func delete(id: String, owner: String, agentID: String, profileID: String?) {
        let key = key(owner, agentID, profileID)
        lock.withLock {
            write(read(key).filter { $0.id != id }, key)
        }
    }

    private func key(_ owner: String, _ agentID: String, _ profileID: String?) -> String {
        "profileV3.customRules.\(owner).\(profileID ?? "main").\(agentID)"
    }

    private func read(_ key: String) -> [ProfileV3CustomRule] {
        guard let defaults else { return memory[key] ?? [] }
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([ProfileV3CustomRule].self, from: data)) ?? []
    }

    private func write(_ rules: [ProfileV3CustomRule], _ key: String) {
        guard let defaults else {
            memory[key] = rules
            return
        }
        if rules.isEmpty {
            defaults.removeObject(forKey: key)
        } else if let data = try? JSONEncoder().encode(rules) {
            defaults.set(data, forKey: key)
        }
    }
}
