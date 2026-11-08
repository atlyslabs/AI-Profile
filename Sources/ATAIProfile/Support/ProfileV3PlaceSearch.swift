import Foundation
import GooglePlaces

struct ProfileV3PlaceSuggestion: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    var detail: String?
}

struct ProfileV3PlacePage: Equatable, Sendable {
    var places: [ProfileV3PlaceSuggestion]
    var nextPageToken: String?
}

struct ProfileV3PlaceSearchScope: Equatable, Sendable {
    let city: String
    var countryCode: String?

    func query(for text: String) -> String {
        let trimmed = text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        guard !trimmed.isEmpty, !city.isEmpty, !trimmed.localizedCaseInsensitiveContains(city) else { return trimmed }
        return "\(trimmed) \(city)"
    }

    func area(in address: String?) -> String? {
        guard !city.isEmpty, let address else { return nil }
        let parts = address.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        guard let cityIndex = parts.lastIndex(where: { $0.localizedCaseInsensitiveContains(city) }), cityIndex > 0 else { return nil }
        return parts[cityIndex - 1]
    }
}

@MainActor
protocol ProfileV3PlaceSearching: AnyObject {
    func lodging(matching text: String, in scope: ProfileV3PlaceSearchScope) async -> [ProfileV3PlaceSuggestion]
    func popularLodging(in scope: ProfileV3PlaceSearchScope, pageToken: String?) async -> ProfileV3PlacePage
}

@MainActor
final class ProfileV3GooglePlaceSearch: ProfileV3PlaceSearching {
    private static var hasProvidedKey = false
    private static let lodgingType = "lodging"
    private static let limit = 8
    private static let textSearchURL = "https://maps.googleapis.com/maps/api/place/textsearch/json"
    private static let popularQueryPrefix = "hotels in "
    private static let bundleHeader = "X-Ios-Bundle-Identifier"
    private static let pageTokenDelay = Duration.seconds(2)
    private static let tokenNotReady = "INVALID_REQUEST"

    private let apiKey: String
    private var lastPageAt: ContinuousClock.Instant?

    init?(apiKey: String?) {
        guard let key = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines), !key.isEmpty else { return nil }
        self.apiKey = key
    }

    private var client: GMSPlacesClient {
        if !Self.hasProvidedKey {
            Self.hasProvidedKey = GMSPlacesClient.provideAPIKey(apiKey)
        }
        return GMSPlacesClient.shared()
    }

    func popularLodging(in scope: ProfileV3PlaceSearchScope, pageToken: String?) async -> ProfileV3PlacePage {
        guard !scope.city.isEmpty else { return ProfileV3PlacePage(places: []) }
        if pageToken != nil, let lastPageAt {
            let wait = Self.pageTokenDelay - (ContinuousClock.now - lastPageAt)
            if wait > .zero { try? await Task.sleep(for: wait) }
        }
        var response = await textSearch(scope, pageToken: pageToken)
        if pageToken != nil, response?.status == Self.tokenNotReady {
            try? await Task.sleep(for: Self.pageTokenDelay)
            response = await textSearch(scope, pageToken: pageToken)
        }
        lastPageAt = .now
        guard let response else { return ProfileV3PlacePage(places: []) }
        let places = (response.results ?? []).compactMap { result -> ProfileV3PlaceSuggestion? in
            guard let id = result.placeID, let name = result.name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
                return nil
            }
            return ProfileV3PlaceSuggestion(id: id, name: name, detail: scope.area(in: result.formattedAddress))
        }
        return ProfileV3PlacePage(places: places, nextPageToken: response.nextPageToken?.nonEmpty)
    }

    private func textSearch(_ scope: ProfileV3PlaceSearchScope, pageToken: String?) async -> ProfileV3TextSearchResponse? {
        guard var components = URLComponents(string: Self.textSearchURL) else { return nil }
        var items = [URLQueryItem(name: "key", value: apiKey)]
        if let pageToken {
            items.append(URLQueryItem(name: "pagetoken", value: pageToken))
        } else {
            items.append(URLQueryItem(name: "query", value: Self.popularQueryPrefix + scope.city))
            items.append(URLQueryItem(name: "type", value: Self.lodgingType))
            if let countryCode = scope.countryCode?.nonEmpty {
                items.append(URLQueryItem(name: "region", value: countryCode.lowercased()))
            }
        }
        components.queryItems = items
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        if let bundleID = Bundle.main.bundleIdentifier {
            request.setValue(bundleID, forHTTPHeaderField: Self.bundleHeader)
        }
        guard let loaded = try? await URLSession.shared.data(for: request) else { return nil }
        return try? JSONDecoder().decode(ProfileV3TextSearchResponse.self, from: loaded.0)
    }

    func lodging(matching text: String, in scope: ProfileV3PlaceSearchScope) async -> [ProfileV3PlaceSuggestion] {
        let query = scope.query(for: text)
        guard !query.isEmpty else { return [] }
        let filter = GMSAutocompleteFilter()
        filter.types = [Self.lodgingType]
        if let countryCode = scope.countryCode?.nonEmpty {
            filter.countries = [countryCode]
        }
        let limit = Self.limit
        let client = client
        return await withCheckedContinuation { continuation in
            client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { @Sendable results, _ in
                let suggestions = (results ?? []).prefix(limit).map { prediction in
                    ProfileV3PlaceSuggestion(
                        id: prediction.placeID,
                        name: prediction.attributedPrimaryText.string,
                        detail: prediction.attributedSecondaryText?.string
                    )
                }
                continuation.resume(returning: Array(suggestions))
            }
        }
    }
}

struct ProfileV3TextSearchResponse: Decodable, Equatable {
    struct Result: Decodable, Equatable {
        let placeID: String?
        let name: String?
        let formattedAddress: String?

        enum CodingKeys: String, CodingKey {
            case placeID = "place_id"
            case name
            case formattedAddress = "formatted_address"
        }
    }

    let results: [Result]?
    let nextPageToken: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case results
        case nextPageToken = "next_page_token"
        case status
    }
}
