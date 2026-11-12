import Foundation

enum ProfileV3PhotoAccess: Equatable, Sendable {
    case full
    case limited
    case denied
    case notDetermined

    var canRead: Bool { self == .full || self == .limited }
}

protocol ProfileV3PhotoLibraryReading: Sendable {
    var access: ProfileV3PhotoAccess { get }
    func requestAccess() async -> ProfileV3PhotoAccess
    func tally(takenAfter date: Date?) async throws -> ProfileV3PhotoPlaceTally
}

struct ProfileV3PhotoCountry: Codable, Equatable, Sendable {
    let countryCode: String
    var photoCount: Int
    var firstSeen: Date?
    var lastSeen: Date?

    mutating func absorb(photoCount: Int, firstSeen: Date?, lastSeen: Date?) {
        self.photoCount += photoCount
        self.firstSeen = earlier(self.firstSeen, firstSeen)
        self.lastSeen = later(self.lastSeen, lastSeen)
    }
}

struct ProfileV3PhotoPlacesUpload: Equatable, Sendable {
    let countries: [ProfileV3PhotoCountry]
    let scannedThrough: Date?
    let access: ProfileV3PhotoAccess
}

struct ProfileV3PhotoPlaceTally: Equatable, Sendable {
    static let cellsPerDegree = 100.0

    struct Cell: Hashable, Sendable {
        let latitude: Int
        let longitude: Int
    }

    struct Spot: Equatable, Sendable {
        let latitude: Double
        let longitude: Double
        var photoCount: Int
        var firstSeen: Date?
        var lastSeen: Date?
    }

    private(set) var spots: [Cell: Spot] = [:]
    private(set) var latestTakenAt: Date?

    mutating func record(latitude: Double, longitude: Double, takenAt: Date?) {
        guard (-90...90).contains(latitude), (-180...180).contains(longitude),
              latitude != 0 || longitude != 0 else { return }
        let cell = Cell(
            latitude: Int((latitude * Self.cellsPerDegree).rounded()),
            longitude: Int((longitude * Self.cellsPerDegree).rounded())
        )
        if var spot = spots[cell] {
            spot.photoCount += 1
            spot.firstSeen = earlier(spot.firstSeen, takenAt)
            spot.lastSeen = later(spot.lastSeen, takenAt)
            spots[cell] = spot
        } else {
            spots[cell] = Spot(latitude: latitude, longitude: longitude, photoCount: 1, firstSeen: takenAt, lastSeen: takenAt)
        }
    }

    mutating func noteScanned(takenAt: Date?) {
        latestTakenAt = later(latestTakenAt, takenAt)
    }

    func countries(using locator: ProfileV3CountryLocator) -> [ProfileV3PhotoCountry] {
        var byCode: [String: ProfileV3PhotoCountry] = [:]
        for spot in spots.values {
            guard let code = locator.countryCode(latitude: spot.latitude, longitude: spot.longitude) else { continue }
            byCode[code, default: ProfileV3PhotoCountry(countryCode: code, photoCount: 0)]
                .absorb(photoCount: spot.photoCount, firstSeen: spot.firstSeen, lastSeen: spot.lastSeen)
        }
        return Array(byCode.values).newestFirst
    }
}

private func earlier(_ lhs: Date?, _ rhs: Date?) -> Date? {
    guard let lhs, let rhs else { return lhs ?? rhs }
    return min(lhs, rhs)
}

private func later(_ lhs: Date?, _ rhs: Date?) -> Date? {
    guard let lhs, let rhs else { return lhs ?? rhs }
    return max(lhs, rhs)
}

extension Array where Element == ProfileV3PhotoCountry {
    var newestFirst: [ProfileV3PhotoCountry] {
        sorted {
            let lhs = $0.lastSeen ?? .distantPast, rhs = $1.lastSeen ?? .distantPast
            return lhs == rhs ? $0.countryCode < $1.countryCode : lhs > rhs
        }
    }

    func merging(_ other: [ProfileV3PhotoCountry]) -> [ProfileV3PhotoCountry] {
        var byCode = Dictionary(map { ($0.countryCode, $0) }, uniquingKeysWith: { first, _ in first })
        for country in other {
            byCode[country.countryCode, default: ProfileV3PhotoCountry(countryCode: country.countryCode, photoCount: 0)]
                .absorb(photoCount: country.photoCount, firstSeen: country.firstSeen, lastSeen: country.lastSeen)
        }
        return Array(byCode.values).newestFirst
    }
}
