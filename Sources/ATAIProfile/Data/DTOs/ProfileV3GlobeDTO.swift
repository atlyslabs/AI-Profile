import Foundation

struct ProfileV3GlobeStatDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let value: ProfileV3ScalarDTO?
    let unit: String?
}

struct ProfileV3GlobeCountryDTO: Decodable, Equatable {
    let code: String?
}

struct ProfileV3GlobeDTO: Decodable, Equatable {
    private let rawStats: [ProfileV3LossyDTO<ProfileV3GlobeStatDTO>]?
    private let rawCountries: [ProfileV3LossyDTO<ProfileV3GlobeCountryDTO>]?
    private let rawAddTrips: ProfileV3LossyDTO<ProfileV3TripNextDTO>?
    private let rawTripsPill: ProfileV3LossyDTO<ProfileV3TripsPillDTO>?

    var stats: [ProfileV3GlobeStatDTO] { rawStats?.compactMap(\.value) ?? [] }
    var addTrips: ProfileV3TripNextDTO? { rawAddTrips?.value }
    var tripsPill: ProfileV3TripsPillDTO? { rawTripsPill?.value }

    var countryCodes: [String] {
        (rawCountries?.compactMap(\.value) ?? []).compactMap { country in
            let code = (country.code ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return code.isEmpty ? nil : code.uppercased()
        }
    }

    enum CodingKeys: String, CodingKey {
        case rawStats = "stats"
        case rawCountries = "countries"
        case rawAddTrips = "add_trips"
        case rawTripsPill = "trips_pill"
    }
}
