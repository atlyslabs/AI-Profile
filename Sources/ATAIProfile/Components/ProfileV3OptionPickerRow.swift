import ATUIKit
import SwiftUI

struct ProfileV3OptionPickerRow: View {
    let option: ProfileV3ChipOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                checkbox
                if let logoURL = option.logoURL {
                    logo(logoURL)
                        .padding(.leading, ProfileV3Theme.Space.s14)
                } else if let place = option.place {
                    ProfileV3PlaceThumbnail(place: place, size: ProfileV3Theme.Sizes.Picker.logo)
                        .padding(.leading, ProfileV3Theme.Space.s14)
                }
                label
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(ProfileV3Theme.Palette.countryText)
                    .opacity(isSelected ? 1 : ProfileV3Theme.Opacity.optionUnselected)
                    .padding(.leading, ProfileV3Theme.Space.s18)
                Spacer(minLength: 0)
            }
            .frame(height: ProfileV3Theme.Sizes.Picker.rowHeight)
            .overlay(alignment: .bottom) {
                ProfileV3DashedDivider()
                    .padding(.leading, ProfileV3Theme.Space.s32)
            }
            .contentShape(Rectangle())
            .animation(ProfileV3Theme.Motion.selection, value: isSelected)
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(option.title)
        .accessibilityValue(option.subtitle ?? "")
    }

    @ViewBuilder
    private var label: some View {
        if let subtitle = option.subtitle?.nonEmpty {
            ViewThatFits(in: .horizontal) {
                (Text(option.title) + Text(ProfileV3Strings.subtitleSeparator + subtitle).foregroundStyle(subtitleTint))
                    .lineLimit(1)
                VStack(alignment: .leading, spacing: 0) {
                    Text(option.title)
                        .lineLimit(1)
                    Text(subtitle)
                        .foregroundStyle(subtitleTint)
                        .lineLimit(1)
                }
            }
        } else {
            Text(option.title)
        }
    }

    private var subtitleTint: Color {
        ProfileV3Theme.Palette.countryText.opacity(ProfileV3Theme.Opacity.cardSubtitle)
    }

    private var checkbox: some View {
        (isSelected ? ATIcon.SwiftUIImage.checkBox : ATIcon.SwiftUIImage.checkBoxOutlineBlank)
            .profileV3Icon(isSelected ? ProfileV3Theme.Sizes.Picker.checkbox : ProfileV3Theme.Icon.lg)
            .foregroundStyle(isSelected ? Color(at: .pureBlack) : Color(at: .neutralGrey400))
            .frame(width: ProfileV3Theme.Sizes.Picker.checkbox, height: ProfileV3Theme.Sizes.Picker.checkbox)
    }

    private func logo(_ url: URL) -> some View {
        ProfileV3RemoteImage(url: url, contentMode: .fill, placeholder: Color(at: .neutralGrey100))
            .frame(width: ProfileV3Theme.Sizes.Picker.logo, height: ProfileV3Theme.Sizes.Picker.logo)
            .clipShape(Circle())
    }
}

#if DEBUG
#Preview("Picker rows") {
    VStack(spacing: 0) {
        ProfileV3OptionPickerRow(option: ProfileV3AgentFixtures.airlines[0], isSelected: true) {}
        ProfileV3OptionPickerRow(option: ProfileV3AgentFixtures.airlines[1], isSelected: false) {}
        ProfileV3OptionPickerRow(option: ProfileV3AgentFixtures.airlines[6], isSelected: false) {}
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
