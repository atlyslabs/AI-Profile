import Foundation
import GooglePlaces

struct ProfileV3PlaceSuggestion: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    var detail: String?
}

struct ProfileV3PlaceSearchScope: Equatable, Sendable {
    let city: String
    var countryCode: String?

    func query(for text: String) -> String {
        let trimmed = text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        guard !trimmed.isEmpty, !city.isEmpty, !trimmed.localizedCaseInsensitiveContains(city) else { return trimmed }
        return "\(trimmed) \(city)"
    }
}

@MainActor
protocol ProfileV3PlaceSearching: AnyObject {
    func lodging(matching text: String, in scope: ProfileV3PlaceSearchScope) async -> [ProfileV3PlaceSuggestion]
}

@MainActor
final class ProfileV3GooglePlaceSearch: ProfileV3PlaceSearching {
    private static var hasProvidedKey = false
    private static let lodgingType = "lodging"
    private static let limit = 8

    private let apiKey: String

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
