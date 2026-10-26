import ATUIKit
import SwiftUI

struct ProfileV3CountryList: View {
    @Binding var query: String
    let selection: ProfileV3Country?
    var pinned: ProfileV3Country?
    var countries: [ProfileV3Country]?
    var searchPlaceholder = ProfileV3Strings.search
    var trailing: ((ProfileV3Country) -> String?)?
    var searchText: ((ProfileV3Country) -> String?)?
    var focusesSearch = true
    var listBottomInset = ProfileV3Theme.Space.s16
    let onSelect: (ProfileV3Country) -> Void

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        let items = ProfileV3CountrySearch.countries(
            matching: query,
            pinning: pinned,
            searchText: searchText,
            in: countries
        )
        VStack(spacing: 0) {
            SettingsSearchField(placeholder: searchPlaceholder, text: $query)
                .focused($isSearchFocused)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, ProfileV3Theme.Space.s24)
            if items.isEmpty {
                emptyState
            } else {
                list(items)
            }
        }
        .task {
            guard focusesSearch else { return }
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.searchFocusDelayMilliseconds))
            guard !Task.isCancelled else { return }
            isSearchFocused = true
        }
    }

    private func list(_ items: [ProfileV3Country]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items, id: \.self) { country in
                    ProfileV3CountryRow(
                        name: country.name,
                        isoCode: country.code,
                        trailing: trailing?(country),
                        isSelected: country == selection
                    ) {
                        onSelect(country)
                    }
                    ProfileV3DashedDivider()
                        .padding(.leading, ProfileV3Theme.Sizes.pickerDividerInset)
                }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Space.s16)
            .padding(.bottom, listBottomInset)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var emptyState: some View {
        ProfileV3EmptyState(icon: ATIcon.SwiftUIImage.search, title: ProfileV3Strings.countrySearchEmpty, iconGap: 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, ProfileV3Theme.Sizes.emptyStateTop)
            .accessibilityElement(children: .combine)
    }
}
