import ATUIKit
import SwiftUI

struct LoginCountryPickerSheet: View {
    let countries: [LoginCountryOption]
    let selected: LoginCountryOption
    let onSelect: (LoginCountryOption) -> Void

    @State private var orderedCountries: [LoginCountryOption]

    init(
        countries: [LoginCountryOption],
        selected: LoginCountryOption,
        onSelect: @escaping (LoginCountryOption) -> Void
    ) {
        self.countries = countries
        self.selected = selected
        self.onSelect = onSelect
        _orderedCountries = State(initialValue: Self.reorder(countries: countries, selected: selected))
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: ProfileV3Theme.Space.s10) {
                ForEach(orderedCountries) { option in
                    row(for: option)
                }
            }
            .padding(.horizontal, ProfileV3Theme.Space.s20)
            .padding(.vertical, ProfileV3Theme.Space.s24)
        }
        .background(Color(at: .pureWhite))
        .onChange(of: selected) { _, newValue in
            orderedCountries = Self.reorder(countries: countries, selected: newValue)
        }
    }

    private static func reorder(
        countries: [LoginCountryOption],
        selected: LoginCountryOption
    ) -> [LoginCountryOption] {
        guard let index = countries.firstIndex(of: selected) else { return countries }
        var copy = countries
        copy.insert(copy.remove(at: index), at: 0)
        return copy
    }

    private func row(for option: LoginCountryOption) -> some View {
        Button {
            HapticsManager.shared.selection()
            onSelect(option)
        } label: {
            HStack(spacing: ProfileV3Theme.Space.s16) {
                ProfileV3CountryFlag(country: option.country, size: Self.flagDiameter)

                Text(option.name)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(Color(at: .pureBlack))

                Circle()
                    .fill(Color(at: .neutralGrey100))
                    .frame(width: ProfileV3Theme.Sizes.separatorDot, height: ProfileV3Theme.Sizes.separatorDot)

                Text(option.dialCode)
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(Color(at: .neutralGrey500))

                Spacer()
            }
            .padding(.horizontal, ProfileV3Theme.Space.s8)
            .padding(.vertical, ProfileV3Theme.Space.s8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: ProfileV3Theme.Control.regular)
            .background(
                RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.sm, style: .continuous)
                    .fill(option == selected ? Color(at: .neutralGrey100).opacity(0.5) : .clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private static let flagDiameter: CGFloat = 18
}

#if DEBUG
#Preview("Dial code picker") {
    LoginCountryPickerSheet(
        countries: LoginCountryOption.profileV3Options,
        selected: .india,
        onSelect: { _ in }
    )
}
#endif
