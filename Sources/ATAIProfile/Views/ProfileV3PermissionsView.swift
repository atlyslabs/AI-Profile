import ATUIKit
import SwiftUI

struct ProfileV3PermissionsView: View {
    @ObservedObject var model: ProfileV3PermissionsSettingsModel
    let onClose: () -> Void


    var body: some View {
        VStack(spacing: 0) {
            ProfileV3SheetChrome(
                icon: ATIcon.SwiftUIImage.settings,
                title: ProfileV3Strings.permissions,
                onClose: onClose
            )
            if let permissions = model.permissions {
                ViewThatFits(in: .vertical) {
                    cards(permissions)
                    ProfileV3FadingScroll(bounceBehavior: .automatic) {
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
                ProfileV3PermissionSectionCard(section: section) { model.select($0, in: $1) }
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, ProfileV3Theme.Sizes.Permissions.cardsTop)
        .padding(.bottom, ProfileV3Theme.Sizes.Permissions.bottom)
    }
}

private struct ProfileV3PermissionSectionCard: View {
    let section: ProfileV3PermissionSection
    let onSelect: (String, String) -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.Permissions

    var body: some View {
        VStack(alignment: .leading, spacing: Sizes.cardContentSpacing) {
            if !section.title.isEmpty {
                ProfileV3PermissionTag(text: section.title)
            }
            ForEach(Array(section.rows.enumerated()), id: \.element.id) { index, row in
                if index > 0 {
                    ProfileV3HorizontalRule()
                        .stroke(
                            ProfileV3Theme.Palette.settingsCardBorder,
                            style: StrokeStyle(lineWidth: ProfileV3Theme.Stroke.hairline, dash: Sizes.dividerDash)
                        )
                        .frame(height: ProfileV3Theme.Stroke.hairline)
                        .padding(.vertical, -ProfileV3Theme.Stroke.hairline / 2)
                        .accessibilityHidden(true)
                }
                ProfileV3PermissionRowView(row: row) { onSelect($0, row.id) }
            }
        }
        .padding(Sizes.cardInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .profileV3AccessCard(cornerRadius: Sizes.cardRadius)
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

private struct ProfileV3PermissionRowView: View {
    let row: ProfileV3PermissionRow
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Permissions.questionGap) {
            if !row.title.isEmpty {
                Text(row.title)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(ProfileV3Theme.Palette.inkText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: ProfileV3Theme.Sizes.Permissions.questionLineHeight)
            }
            ProfileV3SegmentedControl(
                segments: row.options.map { ProfileV3SegmentedControl.Segment(id: $0.id, title: $0.title) },
                selectedID: row.selectedOptionID,
                onSelect: onSelect
            )
        }
    }
}

#if DEBUG
#Preview("Settings sheet · permissions") {
    let viewModel = ProfileV3SettingsViewModel.preview()
    viewModel.permissions.load()
    return ProfileV3SettingsSheetView(viewModel: viewModel, entry: .permissions)
}
#endif
