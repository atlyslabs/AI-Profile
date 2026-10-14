import Foundation

struct ProfileV3GlobeStatDTO: Decodable, Equatable {
    let key: String?
    let label: String?
    let value: ProfileV3ScalarDTO?
}

struct ProfileV3GlobeCountryDTO: Decodable, Equatable {
    let code: String?
}

struct ProfileV3GlobeDTO: Decodable, Equatable {
    private let rawStats: [ProfileV3LossyDTO<ProfileV3GlobeStatDTO>]?
    private let rawCountries: [ProfileV3LossyDTO<ProfileV3GlobeCountryDTO>]?

    var stats: [ProfileV3GlobeStatDTO] { rawStats?.compactMap(\.value) ?? [] }

    var countryCodes: [String] {
        (rawCountries?.compactMap(\.value) ?? []).compactMap { country in
            let code = (country.code ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return code.isEmpty ? nil : code.uppercased()
        }
    }

    enum CodingKeys: String, CodingKey {
        case rawStats = "stats"
        case rawCountries = "countries"
    }
}
