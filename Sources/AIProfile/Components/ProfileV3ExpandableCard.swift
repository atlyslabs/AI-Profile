import ATUIKit
import SwiftUI

struct ProfileV3ExpandableCard<Content: View>: View {
    let icon: Image
    let title: String
    let subtitle: String
    var badgeURL: URL?
    @Binding var isExpanded: Bool
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: toggle) {
                ProfileV3SettingsCardHeader(icon: icon, title: title, subtitle: subtitle, badgeURL: badgeURL) {
                    ATIcon.SwiftUIImage.navigateNext
                        .profileV3Icon(ProfileV3Theme.Icon.lg)
                        .rotationEffect(.degrees(isExpanded ? -90 : 90))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.profileV3Pressable(.selection))
            .accessibilityLabel("\(title), \(subtitle)")
            .accessibilityValue(isExpanded ? ProfileV3Strings.expanded : ProfileV3Strings.collapsed)
            .accessibilityHint(isExpanded ? ProfileV3Strings.collapseHint : ProfileV3Strings.expandHint)

            if isExpanded {
                VStack(spacing: ProfileV3Theme.Sizes.Accounts.rowSpacing) {
                    content()
                }
                .padding(.horizontal, ProfileV3Theme.Sizes.Accounts.rowsInset)
                .padding(.bottom, ProfileV3Theme.Sizes.Accounts.rowsBottom)
                .transition(
                    .opacity.combined(with: .scale(scale: ProfileV3Theme.Motion.expandEnterScale, anchor: .top))
                )
            }
        }
        .profileV3SettingsCard()
    }

    private func toggle() {
        withAnimation(ProfileV3Theme.Motion.expand) {
            isExpanded.toggle()
        }
    }
}

struct ProfileV3SettingsCardHeader<Accessory: View>: View {
    let icon: Image
    var iconSize: CGFloat = ProfileV3Theme.Icon.xl
    let title: String
    let subtitle: String
    var badgeURL: URL?
    @ViewBuilder var accessory: () -> Accessory

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Accounts.titleSpacing) {
            HStack {
                icon
                    .profileV3Icon(iconSize)
                    .frame(width: ProfileV3Theme.Icon.xl, height: ProfileV3Theme.Icon.xl, alignment: .bottomLeading)
                if let badgeURL {
                    ProfileV3RemoteImage(url: badgeURL, contentMode: .fit, placeholder: .clear)
                        .frame(height: ProfileV3Theme.Sizes.Accounts.badgeHeight)
                        .fixedSize(horizontal: true, vertical: false)
                        .accessibilityHidden(true)
                }
                Spacer()
                accessory()
            }
            .foregroundStyle(Color(at: .pureBlack))
            VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.Accounts.subtitleSpacing) {
                Text(title)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(Color(at: .pureBlack))
                Text(subtitle)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey400))
            }
        }
        .multilineTextAlignment(.leading)
        .padding(.leading, ProfileV3Theme.Sizes.cardContentPadding)
        .padding(.trailing, ProfileV3Theme.Sizes.SettingsPage.cardHeaderTrailing)
        .padding(.top, ProfileV3Theme.Sizes.SettingsPage.cardHeaderTop)
        .padding(.bottom, ProfileV3Theme.Sizes.SettingsPage.cardHeaderBottom)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension ProfileV3SettingsCardHeader where Accessory == EmptyView {
    init(icon: Image, iconSize: CGFloat = ProfileV3Theme.Icon.xl, title: String, subtitle: String) {
        self.init(icon: icon, iconSize: iconSize, title: title, subtitle: subtitle) { EmptyView() }
    }
}

extension View {
    func profileV3SettingsCard(cornerRadius: CGFloat = ProfileV3Theme.Sizes.SettingsPage.cardRadius) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return background(shape.fill(ProfileV3Theme.Palette.background))
            .overlay(
                shape.strokeBorder(ProfileV3Theme.Palette.settingsCardBorder, lineWidth: ProfileV3Theme.Stroke.hairline)
            )
            .clipShape(shape)
    }
}

#if DEBUG
private struct ProfileV3ExpandableCardPreview: View {
    @State private var isExpanded = true

    var body: some View {
        ProfileV3ExpandableCard(
            icon: ATIcon.SwiftUIImage.person,
            title: ProfileV3Strings.accountsCenter,
            subtitle: ProfileV3Strings.accountsCenterSubtitle,
            isExpanded: $isExpanded
        ) {
            ProfileV3SettingsRow(
                icon: ATIcon.SwiftUIImage.flag,
                title: ProfileV3Strings.countryOfResidence,
                iconSize: ProfileV3Theme.Icon.md
            ) {}
            ProfileV3SettingsRow(
                icon: ATIcon.SwiftUIImage.language,
                title: ProfileV3Strings.citizenship,
                iconSize: ProfileV3Theme.Icon.md
            ) {}
        }
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
    }
}

#Preview("Expandable card") {
    ProfileV3ExpandableCardPreview()
}
#endif
