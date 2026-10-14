import ATUIKit
import SwiftUI

struct ProfileV3CountryPickerView: View {
    let title: String
    let icon: Image
    let selected: ProfileV3Country?
    let trailing: ((ProfileV3Country) -> String?)?
    let searchText: ((ProfileV3Country) -> String?)?
    let confirmTitle: String?
    let onBack: () -> Void
    let onSelect: (ProfileV3Country) -> Void

    @State private var query: String
    @State private var pending: ProfileV3Country?

    init(
        title: String,
        icon: Image,
        selected: ProfileV3Country?,
        trailing: ((ProfileV3Country) -> String?)? = nil,
        searchText: ((ProfileV3Country) -> String?)? = nil,
        confirmTitle: String? = nil,
        initialQuery: String = "",
        onBack: @escaping () -> Void,
        onSelect: @escaping (ProfileV3Country) -> Void
    ) {
        self.title = title
        self.icon = icon
        self.selected = selected
        self.trailing = trailing
        self.searchText = searchText
        self.confirmTitle = confirmTitle
        self.onBack = onBack
        self.onSelect = onSelect
        _query = State(initialValue: initialQuery)
    }

    private var current: ProfileV3Country? { pending ?? selected }

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetChrome(icon: icon, title: title, onBack: onBack)
            ProfileV3CountryList(
                query: $query,
                selection: current,
                pinned: selected,
                trailing: trailing,
                searchText: searchText,
                onSelect: choose
            )
        }
        .background(Color(at: .pureWhite))
        .safeAreaInset(edge: .bottom) {
            if let confirmTitle {
                confirmBar(confirmTitle)
            }
        }
    }

    private func confirmBar(_ title: String) -> some View {
        ProfileV3ContinueButton(title: title, isEnabled: current != nil) {
            if let current {
                onSelect(current)
            }
        }
        .profileV3CTABar()
    }

    private func choose(_ country: ProfileV3Country) {
        guard confirmTitle != nil else {
            onSelect(country)
            return
        }
        withAnimation(ProfileV3Theme.Motion.selection) {
            pending = country
        }
    }
}

#if DEBUG
#Preview("Country picker") {
    ProfileV3CountryPickerView(
        title: ProfileV3Strings.countryOfResidence,
        icon: ATIcon.SwiftUIImage.flag,
        selected: .india,
        onBack: {},
        onSelect: { _ in }
    )
}

#Preview("Currency picker") {
    ProfileV3CountryPickerView(
        title: ProfileV3Strings.currency,
        icon: ATIcon.SwiftUIImage.storage,
        selected: .india,
        trailing: ProfileV3CurrencyCodes.code(for:),
        searchText: ProfileV3CurrencyCodes.searchText(for:),
        confirmTitle: ProfileV3Strings.confirmEdit,
        onBack: {},
        onSelect: { _ in }
    )
}

#Preview("Country picker · no results") {
    ProfileV3CountryPickerView(
        title: ProfileV3Strings.countryOfResidence,
        icon: ATIcon.SwiftUIImage.flag,
        selected: .india,
        initialQuery: "Atlantis",
        onBack: {},
        onSelect: { _ in }
    )
}
#endif
