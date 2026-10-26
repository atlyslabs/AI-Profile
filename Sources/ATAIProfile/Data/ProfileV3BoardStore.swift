import Foundation

@MainActor
final class ProfileV3BoardStore {
    private struct Snapshot {
        let ownerID: String
        let board: ProfileV3Board
        let sequence: Int
        let fetchedAt: Date
    }

    private struct PendingFetch {
        let ownerID: String
        let sequence: Int
        let task: Task<ProfileV3Board, Error>
    }

    private nonisolated static let diskMaxAge: TimeInterval = 7 * 24 * 60 * 60
    private static let prefetchFreshness: TimeInterval = 5 * 60

    private let client: ProfileV3NetworkClient
    private let cache: ProfileV3DiskCache
    private let session: any ProfileV3SessionProviding
    private var snapshot: Snapshot?
    private var pending: PendingFetch?
    private var lastSequence = 0

    init(
        client: ProfileV3NetworkClient,
        session: any ProfileV3SessionProviding,
        cache: ProfileV3DiskCache = ProfileV3DiskCache()
    ) {
        self.client = client
        self.session = session
        self.cache = cache
    }

    func cachedBoard() -> ProfileV3Board? {
        guard let ownerID, let snapshot, snapshot.ownerID == ownerID else { return nil }
        return snapshot.board
    }

    func prefetch() {
        guard let ownerID, !session.isGuestSession else { return }
        Task {
            if snapshot?.ownerID != ownerID {
                await restore(ownerID)
            }
            if let snapshot, snapshot.ownerID == ownerID,
               Date().timeIntervalSince(snapshot.fetchedAt) < Self.prefetchFreshness {
                return
            }
            _ = try? await board(reusingPending: true)
        }
    }

    func board(reusingPending: Bool) async throws -> ProfileV3Board {
        guard let ownerID else { throw ProfileV3Error.unauthorized }
        if reusingPending, let pending, pending.ownerID == ownerID {
            let board = try await pending.task.value
            return newest(board, ownerID: ownerID, sequence: pending.sequence)
        }
        lastSequence += 1
        let sequence = lastSequence
        let cacheKey = Self.cacheKey(for: ownerID)
        let client = client
        let cache = cache
        let fetch = PendingFetch(
            ownerID: ownerID,
            sequence: sequence,
            task: Task { [weak self] in
                let board = try await Self.fetch(cacheKey: cacheKey, client: client, cache: cache)
                self?.keep(board, ownerID: ownerID, sequence: sequence)
                return board
            }
        )
        pending = fetch
        defer {
            if pending?.sequence == sequence { pending = nil }
        }
        let board = try await fetch.task.value
        return newest(board, ownerID: ownerID, sequence: sequence)
    }

    func invalidate() {
        pending?.task.cancel()
        pending = nil
        snapshot = nil
        lastSequence += 1
    }

    private func newest(_ board: ProfileV3Board, ownerID: String, sequence: Int) -> ProfileV3Board {
        guard let snapshot, snapshot.ownerID == ownerID, snapshot.sequence > sequence else { return board }
        return snapshot.board
    }

    private func keep(_ board: ProfileV3Board, ownerID: String, sequence: Int) {
        guard sequence >= lastSequence else { return }
        if let snapshot, snapshot.ownerID == ownerID, snapshot.sequence > sequence { return }
        snapshot = Snapshot(ownerID: ownerID, board: board, sequence: sequence, fetchedAt: Date())
    }

    private func restore(_ ownerID: String) async {
        let cacheKey = Self.cacheKey(for: ownerID)
        guard let board = await Self.restore(cacheKey: cacheKey, cache: cache),
              self.ownerID == ownerID,
              snapshot?.ownerID != ownerID else { return }
        snapshot = Snapshot(ownerID: ownerID, board: board, sequence: 0, fetchedAt: .distantPast)
    }

    private var ownerID: String? {
        session.currentUserID?.nonEmpty
    }

    private static func cacheKey(for ownerID: String) -> String {
        "profile_v3_board_\(ownerID)"
    }

    private nonisolated static func fetch(
        cacheKey: String,
        client: ProfileV3NetworkClient,
        cache: ProfileV3DiskCache
    ) async throws -> ProfileV3Board {
        let data = try await ProfileV3APIErrorMapper.withUnauthorizedRetry(action: "board") {
            try await client.requestData(.board)
        }
        let board = try decode(data)
        cache.save(data, forKey: cacheKey, maxAge: diskMaxAge)
        return board
    }

    private nonisolated static func restore(cacheKey: String, cache: ProfileV3DiskCache) async -> ProfileV3Board? {
        guard let data = cache.data(forKey: cacheKey) else { return nil }
        return try? decode(data)
    }

    private nonisolated static func decode(_ data: Data) throws -> ProfileV3Board {
        let board = ProfileV3BoardMapper.board(try JSONDecoder().decode(ProfileV3BoardDTO.self, from: data))
        #if DEBUG
        return board.applying(.current)
        #else
        return board
        #endif
    }
}
