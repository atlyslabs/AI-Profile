import Combine
import Foundation

@MainActor
final class ProfileV3PhotoPlacesSync: ObservableObject {
    typealias Upload = @Sendable (ProfileV3PhotoPlacesUpload) async throws -> Void
    typealias Locate = @Sendable () -> ProfileV3CountryLocator?

    enum ConnectResult: Equatable {
        case connected
        case denied
    }

    @Published private(set) var isConnected = false
    @Published private(set) var countryCodes: [String] = []

    private let library: any ProfileV3PhotoLibraryReading
    private let store: ProfileV3PhotoPlacesStore
    private let upload: Upload
    private let locate: Locate
    private var state = ProfileV3PhotoPlacesState()
    private var syncTask: Task<Void, Never>?
    private var generation = 0

    init(
        library: any ProfileV3PhotoLibraryReading,
        store: ProfileV3PhotoPlacesStore,
        upload: @escaping Upload,
        locate: @escaping Locate = { ProfileV3CountryLocator.bundled }
    ) {
        self.library = library
        self.store = store
        self.upload = upload
        self.locate = locate
        apply(store.load())
    }

    func connect() async -> ConnectResult {
        let access = await library.requestAccess()
        guard access.canRead else { return .denied }
        stopSync()
        save(ProfileV3PhotoPlacesState(isConnected: true, needsUpload: true))
        startSync(access: access)
        return .connected
    }

    func syncIfConnected() {
        guard syncTask == nil else { return }
        apply(store.load())
        guard state.isConnected else { return }
        let access = library.access
        guard access.canRead else {
            disconnect()
            return
        }
        startSync(access: access)
    }

    func disconnect() {
        stopSync()
        store.clear()
        apply(ProfileV3PhotoPlacesState())
    }

    func settle() async {
        await syncTask?.value
    }

    private func startSync(access: ProfileV3PhotoAccess) {
        generation += 1
        let generation = generation
        let previous = state
        let takenAfter = access == .full ? previous.scannedThrough : nil
        let library = library
        let locate = locate
        let upload = upload
        syncTask = Task { [weak self] in
            let scan = try? await Self.scan(library: library, takenAfter: takenAfter, locate: locate)
            guard let self, self.generation == generation else { return }
            var next = previous
            if let scan {
                next.countries = takenAfter == nil ? scan.countries : previous.countries.merging(scan.countries)
                next.scannedThrough = access == .full ? scan.latest ?? previous.scannedThrough : nil
                next.needsUpload = previous.needsUpload || next.countries != previous.countries
                save(next)
            }
            if next.needsUpload {
                let payload = ProfileV3PhotoPlacesUpload(
                    countries: next.countries,
                    scannedThrough: next.scannedThrough,
                    access: access
                )
                let uploaded = (try? await upload(payload)) != nil
                guard self.generation == generation else { return }
                if uploaded {
                    next.needsUpload = false
                    save(next)
                }
            }
            syncTask = nil
        }
    }

    private func stopSync() {
        generation += 1
        syncTask?.cancel()
        syncTask = nil
    }

    private func save(_ next: ProfileV3PhotoPlacesState) {
        store.save(next)
        apply(next)
    }

    private func apply(_ next: ProfileV3PhotoPlacesState) {
        state = next
        if isConnected != next.isConnected { isConnected = next.isConnected }
        let codes = next.countries.map(\.countryCode)
        if countryCodes != codes { countryCodes = codes }
    }

    @concurrent
    private nonisolated static func scan(
        library: any ProfileV3PhotoLibraryReading,
        takenAfter: Date?,
        locate: Locate
    ) async throws -> (countries: [ProfileV3PhotoCountry], latest: Date?) {
        let tally = try await library.tally(takenAfter: takenAfter)
        guard let locator = locate() else { throw ProfileV3RepositoryError.unavailable }
        return (tally.countries(using: locator), tally.latestTakenAt)
    }
}
