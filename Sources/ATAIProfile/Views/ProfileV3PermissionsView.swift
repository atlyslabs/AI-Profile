import ATUIKit
import SwiftUI

struct ProfileV3PermissionsView: View {
    @ObservedObject var model: ProfileV3PermissionsSettingsModel
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetChrome(
                icon: ATIcon.SwiftUIImage.settings,
                title: model.permissions?.title ?? ProfileV3Strings.permissions,
                onClose: onClose
            )
            if let permissions = model.permissions {
                ViewThatFits(in: .vertical) {
                    cards(permissions)
                    ScrollView(showsIndicators: false) {
                        cards(permissions)
                    }
                }
                .transition(.opacity)
            } else {
                ProfileV3LoadStateView(phase: model.phase, retry: model.load)
                    .frame(height: ProfileV3Theme.Sizes.Permissions.loadStateHeight)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(at: .pureWhite))
    }

    private func cards(_ permissions: ProfileV3Permissions) -> some View {
        VStack(spacing: ProfileV3Theme.Sizes.Permissions.cardSpacing) {
            ForEach(permissions.sections) { section in
                ProfileV3PermissionSectionCard(section: section) { model.select($0, in: section.id) }
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, ProfileV3Theme.Sizes.Permissions.cardsTop)
        .padding(.bottom, ProfileV3Theme.Sizes.Permissions.bottom)
    }
}

private struct ProfileV3PermissionSectionCard: View {
    let section: ProfileV3PermissionSection
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProfileV3PermissionTag(text: section.title)
            VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Permissions.optionSpacing) {
                ForEach(Array(section.options.enumerated()), id: \.element.id) { index, option in
                    if index > 0 {
                        Rectangle()
                            .fill(ProfileV3Theme.Palette.settingsCardBorder)
                            .frame(height: ProfileV3Theme.Stroke.hairline)
                    }
                    ProfileV3PermissionOptionRow(option: option, isSelected: section.selectedOptionID == option.id) {
                        onSelect(option.id)
                    }
                }
            }
            .padding(.top, ProfileV3Theme.Sizes.Permissions.optionsTop)
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.Permissions.cardInset)
        .padding(.top, ProfileV3Theme.Sizes.Permissions.cardTop)
        .padding(.bottom, ProfileV3Theme.Sizes.Permissions.cardBottom)
        .frame(maxWidth: .infinity, alignment: .leading)
        .profileV3SettingsCard()
    }
}

private struct ProfileV3PermissionTag: View {
    let text: String

    var body: some View {
        ProfileV3TagLabel(text: text)
            .frame(height: ProfileV3Theme.Sizes.Permissions.tagHeight)
            .opacity(ProfileV3Theme.Opacity.sectionTag)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct ProfileV3PermissionOptionRow: View {
    let option: ProfileV3PermissionOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: ProfileV3Theme.Space.s8) {
                VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Permissions.subtitleTop) {
                    Text(option.title)
                        .typoGraphy(.H7InterMedium16)
                        .foregroundStyle(ProfileV3Theme.Palette.inkText)
                    if let subtitle = option.subtitle {
                        Text(subtitle)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(
                                ProfileV3Theme.Palette.inkText.opacity(ProfileV3Theme.Opacity.cardSubtitle)
                            )
                            .frame(width: ProfileV3Theme.Sizes.Permissions.subtitleWidth, alignment: .leading)
                    }
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                ProfileV3RadioMark(isSelected: isSelected)
            }
            .contentShape(Rectangle())
            .animation(ProfileV3Theme.Motion.selection, value: isSelected)
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#if DEBUG
#Preview("Settings sheet · permissions") {
    let viewModel = ProfileV3SettingsViewModel.preview()
    viewModel.permissions.load()
    return ProfileV3SettingsSheetView(viewModel: viewModel, entry: .permissions)
}
#endif
