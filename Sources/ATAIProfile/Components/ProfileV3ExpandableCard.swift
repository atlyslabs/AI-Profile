import ATUIKit
import SwiftUI

struct ProfileV3ExpandableCard<Content: View>: View {
    let icon: Image
    let title: String
    let subtitle: String
    var badgeURL: URL?
    var subtitleWidth: CGFloat?
    @Binding var isExpanded: Bool
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: toggle) {
                ProfileV3SettingsCardHeader(
                    icon: icon,
                    title: title,
                    subtitle: subtitle,
                    badgeURL: badgeURL,
                    subtitleWidth: subtitleWidth
                ) {
                    ATIcon.SwiftUIImage.navigateNext
                        .profileV3Icon(ProfileV3Theme.Icon.lg)
                        .rotationEffect(.degrees(isExpanded ? -90 : 90))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.profileV3Pressable(.selection))
            .accessibilityLabel([title, subtitle].filter { !$0.isEmpty }.joined(separator: ", "))
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
        .profileV3SettingsSurface()
    }

    private func toggle() {
        withAnimation(ProfileV3Theme.Motion.expand) {
            isExpanded.toggle()
        }
    }
}

struct ProfileV3SettingsCardHeader<Accessory: View>: View {
    let icon: Image
    var iconSize: CGFloat = ProfileV3Theme.Icon.lg
    let title: String
    let subtitle: String
    var badgeURL: URL?
    var subtitleWidth: CGFloat?
    var bottom: CGFloat = ProfileV3Theme.Sizes.SettingsPage.cardPadding
    @ViewBuilder var accessory: () -> Accessory

    private typealias Layout = ProfileV3Theme.Sizes.SettingsPage

    var body: some View {
        HStack(alignment: .top, spacing: Layout.cardIconSpacing) {
            icon
                .profileV3Icon(iconSize)
                .frame(width: ProfileV3Theme.Icon.lg, height: ProfileV3Theme.Icon.lg)
            VStack(alignment: .leading, spacing: Layout.cardTitleSpacing) {
                HStack(spacing: ProfileV3Theme.Space.s8) {
                    if !title.isEmpty {
                        Text(title)
                            .typoGraphy(.B1InterSemibold14)
                            .foregroundStyle(Color(at: .pureBlack))
                    }
                    if let badgeURL {
                        ProfileV3RemoteImage(url: badgeURL, contentMode: .fit, placeholder: .clear)
                            .frame(height: ProfileV3Theme.Sizes.Accounts.badgeHeight)
                            .fixedSize(horizontal: true, vertical: false)
                            .accessibilityHidden(true)
                    }
                }
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                        .frame(maxWidth: subtitleWidth, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            accessory()
        }
        .foregroundStyle(Color(at: .pureBlack))
        .multilineTextAlignment(.leading)
        .padding([.horizontal, .top], Layout.cardPadding)
        .padding(.bottom, bottom)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension ProfileV3SettingsCardHeader where Accessory == EmptyView {
    init(
        icon: Image,
        iconSize: CGFloat = ProfileV3Theme.Icon.lg,
        title: String,
        subtitle: String,
        subtitleWidth: CGFloat? = nil,
        bottom: CGFloat = ProfileV3Theme.Sizes.SettingsPage.cardPadding
    ) {
        self.init(
            icon: icon,
            iconSize: iconSize,
            title: title,
            subtitle: subtitle,
            subtitleWidth: subtitleWidth,
            bottom: bottom
        ) { EmptyView() }
    }
}

extension View {
    func profileV3SettingsSurface(
        cornerRadius: CGFloat = ProfileV3Theme.Sizes.SettingsPage.surfaceRadius
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return clipShape(shape)
            .background {
                shape
                    .fill(Color(at: .pureWhite))
                    .shadow(
                        color: ProfileV3Theme.Palette.settingsSurfaceShadow,
                        radius: ProfileV3Theme.Shadow.cardRadius,
                        y: ProfileV3Theme.Shadow.cardY
                    )
            }
            .overlay(shape.strokeBorder(ProfileV3Theme.Palette.settingsCardBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
            .contentShape(shape)
    }

    func profileV3SettingsCard(
        cornerRadius: CGFloat = ProfileV3Theme.Sizes.SettingsPage.cardRadius,
        fill: Color = ProfileV3Theme.Palette.background
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return profileV3Outlined(shape, border: ProfileV3Theme.Palette.settingsCardBorder, fill: fill)
            .clipShape(shape)
    }

    func profileV3AccessCard(cornerRadius: CGFloat = ProfileV3Theme.Sizes.InformationAccess.cardRadius) -> some View {
        profileV3SettingsCard(cornerRadius: cornerRadius, fill: Color(at: .pureWhite))
            .profileV3SoftShadow()
    }
}

#if DEBUG
private struct ProfileV3ExpandableCardPreview: View {
    @State private var isExpanded = true

    var body: some View {
        ProfileV3ExpandableCard(
            icon: ATIcon.SwiftUIImage.person,
            title: "Accounts center",
            subtitle: "Residence, Citizenship, Currency & Contact Info",
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
