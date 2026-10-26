import Foundation

enum ProfileV3CountrySearch {
    static var catalogue: [(country: ProfileV3Country, searchKey: String)] {
        ProfileV3Countries.all.map { ($0, searchKey($0.name)) }
    }

    static func searchKey(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }

    static func countries(
        matching query: String,
        pinning pinned: ProfileV3Country?,
        searchText: ((ProfileV3Country) -> String?)? = nil,
        in source: [ProfileV3Country]? = nil
    ) -> [ProfileV3Country] {
        let needle = searchKey(query.trimmingCharacters(in: .whitespaces))
        let catalogue = source.map { $0.map { ($0, searchKey($0.name)) } } ?? catalogue
        guard needle.isEmpty else {
            return catalogue.compactMap { matches($0, needle: needle, searchText: searchText) ? $0.country : nil }
        }
        var countries = catalogue.map(\.country)
        guard let pinned, let index = countries.firstIndex(of: pinned) else { return countries }
        countries.insert(countries.remove(at: index), at: 0)
        return countries
    }

    private static func matches(
        _ entry: (country: ProfileV3Country, searchKey: String),
        needle: String,
        searchText: ((ProfileV3Country) -> String?)?
    ) -> Bool {
        if entry.searchKey.contains(needle) { return true }
        guard let text = searchText?(entry.country) else { return false }
        return searchKey(text).contains(needle)
    }
}
