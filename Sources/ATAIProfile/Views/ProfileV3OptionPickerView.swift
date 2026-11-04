import ATUIKit
import SwiftUI

struct ProfileV3OptionPickerView: View {
    let title: String
    let options: [ProfileV3ChipOption]
    let selection: Set<String>
    var listLabel: String?
    var isSearching = false
    var onQueryChange: ((String) -> Void)?
    let onBack: () -> Void
    let onToggle: (String) -> Void

    @State private var query = ""

    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var filtered: [ProfileV3ChipOption] {
        guard !trimmedQuery.isEmpty, onQueryChange == nil else { return options }
        return options.filter {
            $0.title.localizedCaseInsensitiveContains(trimmedQuery)
                || $0.subtitle?.localizedCaseInsensitiveContains(trimmedQuery) == true
        }
    }

    var body: some View {
        let filtered = self.filtered
        VStack(spacing: 0) {
            ProfileV3AgentSheetHeader(tag: title, showsOrb: false, onBack: onBack)
            SettingsSearchField(placeholder: ProfileV3Strings.search, text: $query)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, ProfileV3Theme.Space.s40)
            if filtered.isEmpty, isSearching {
                ProfileV3Spinner(accessibilityLabel: ProfileV3Strings.loading)
                    .padding(.top, ProfileV3Theme.Sizes.emptyStateTop)
                    .frame(maxHeight: .infinity, alignment: .top)
            } else if filtered.isEmpty {
                emptyState
            } else {
                list(filtered)
            }
        }
        .background(Color(at: .pureWhite))
        .onChange(of: query) { _, query in onQueryChange?(query) }
    }

    private func list(_ filtered: [ProfileV3ChipOption]) -> some View {
        ProfileV3FadingScroll(bounceBehavior: .automatic) {
            LazyVStack(alignment: .leading, spacing: 0) {
                if let listLabel = listLabel?.nonEmpty, trimmedQuery.isEmpty {
                    ProfileV3TagLabel(text: listLabel, style: .solid(ProfileV3Theme.Palette.secondaryText))
                        .padding(.bottom, ProfileV3Theme.Sizes.Picker.listLabelBottom)
                }
                ForEach(filtered) { option in
                    ProfileV3OptionPickerRow(option: option, isSelected: selection.contains(option.id)) {
                        onToggle(option.id)
                    }
                }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Space.s40)
        }
    }

    private var emptyState: some View {
        ScrollView(showsIndicators: false) {
            ProfileV3EmptyState(
                icon: ATIcon.SwiftUIImage.search,
                title: ProfileV3Strings.searchEmptyTitle,
                subtitle: ProfileV3Strings.searchEmptySubtitle
            )
            .frame(width: ProfileV3Theme.Sizes.emptyStateTextWidth)
            .frame(maxWidth: .infinity)
            .padding(.top, ProfileV3Theme.Sizes.emptyStateTop)
        }
        .scrollDismissesKeyboard(.interactively)
        .frame(maxHeight: .infinity)
    }
}

#if DEBUG
#Preview("Option picker") {
    ProfileV3OptionPickerView(
        title: ProfileV3Strings.addPreferredAirlines,
        options: ProfileV3AgentFixtures.airlines,
        selection: ["singapore-airlines"],
        onBack: {},
        onToggle: { _ in }
    )
}

#Preview("Option picker · no results") {
    ProfileV3OptionPickerView(
        title: ProfileV3Strings.addPreferredAirlines,
        options: [],
        selection: [],
        onBack: {},
        onToggle: { _ in }
    )
}
#endif
