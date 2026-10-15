import ATCore
import Foundation

struct ProfileV3DiskCache: Sendable {
    private struct Key: ATCoreDeterministicCacheKeyProvider {
        let deterministicCacheKey: String
    }

    private let service: ATCoreCacheService

    init(service: ATCoreCacheService = .persistent) {
        self.service = service
    }

    func data(forKey key: String) -> Data? {
        service.getData(forKey: Key(deterministicCacheKey: key))
    }

    func save(_ data: Data, forKey key: String, maxAge: TimeInterval) {
        try? service.save(data, forKey: Key(deterministicCacheKey: key), expirationInterval: maxAge)
    }

    func remove(forKey key: String) {
        service.remove(forKey: Key(deterministicCacheKey: key))
    }
}
