import ATUIKit
import SwiftUI

struct ProfileV3OptionPickerView: View {
    let title: String
    let options: [ProfileV3ChipOption]
    let selection: Set<String>
    let onBack: () -> Void
    let onToggle: (String) -> Void

    @State private var query = ""

    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var filtered: [ProfileV3ChipOption] {
        guard !trimmedQuery.isEmpty else { return options }
        return options.filter { $0.title.localizedCaseInsensitiveContains(trimmedQuery) }
    }

    var body: some View {
        let filtered = self.filtered
        VStack(spacing: 0) {
            ProfileV3AgentSheetHeader(tag: title, showsOrb: false, onBack: onBack)
            SettingsSearchField(placeholder: ProfileV3Strings.search, text: $query)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, ProfileV3Theme.Space.s40)
            if filtered.isEmpty {
                emptyState
            } else {
                list(filtered)
            }
        }
        .background(Color(at: .pureWhite))
    }

    private func list(_ filtered: [ProfileV3ChipOption]) -> some View {
        ProfileV3FadingScroll(bounceBehavior: .automatic) {
            LazyVStack(spacing: 0) {
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
