import ATMaterialIcons
import ATUIKit
import PhotosUI
import SwiftUI

struct ProfileV3SettingsUploadPill: View {
    let title: String
    let onPick: (Data) -> Void

    @State private var item: PhotosPickerItem?

    private typealias Layout = ProfileV3Theme.Sizes.SettingsPage

    var body: some View {
        PhotosPicker(selection: $item, matching: .images, photoLibrary: .shared()) {
            HStack(spacing: Layout.uploadSpacing) {
                ATIcon.SwiftUIImage.addPhotoAlternate
                    .profileV3Icon(Layout.uploadIcon)
                Text(title)
                    .font(.system(size: Layout.uploadTitleSize, weight: .semibold))
            }
            .foregroundStyle(Color(at: .pureBlack))
            .padding(.horizontal, Layout.uploadPadding)
            .frame(height: Layout.uploadHeight)
            .background(Capsule().fill(Color(at: .pureWhite)))
            .overlay(Capsule().strokeBorder(ProfileV3Theme.Palette.settingsUploadBorder, lineWidth: ProfileV3Theme.Stroke.hairline))
            .contentShape(Capsule())
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(title)
        .onChange(of: item) { _, picked in
            guard let picked else { return }
            Task {
                let data = try? await picked.loadTransferable(type: Data.self)
                item = nil
                if let data { onPick(data) }
            }
        }
    }
}

struct ProfileV3SettingsPartnersCard: View {
    let partners: ProfileV3Partners
    let action: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.SettingsPage

    var body: some View {
        Button(action: action) {
            ProfileV3SettingsCardHeader(
                icon: ATMS.handshake.image(),
                title: partners.title,
                subtitle: partners.subtitle,
                subtitleWidth: Layout.partnersSubtitleWidth
            )
            .frame(height: Layout.partnersCardHeight, alignment: .top)
            .overlay(alignment: .topTrailing) { logos }
            .profileV3SettingsSurface()
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(partners.title)
        .accessibilityHint(partners.subtitle)
    }

    private var logos: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(zip(partners.cardLogos, Layout.partnersLogoSlots).enumerated()), id: \.offset) { _, pair in
                ProfileV3RemoteImage(url: pair.0, contentMode: .fill, placeholder: .clear)
                    .frame(width: pair.1.size, height: pair.1.size)
                    .clipShape(Circle())
                    .offset(x: pair.1.origin.x, y: pair.1.origin.y)
            }
        }
        .frame(width: Layout.partnersLogos.width, height: Layout.partnersLogos.height, alignment: .topLeading)
        .padding(.top, Layout.partnersLogosTop)
        .padding(.trailing, Layout.partnersLogosTrailing)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct ProfileV3SettingsSwitchRow: View {
    let item: ProfileV3SettingsSwitch
    let onToggle: (Bool) -> Void

    private typealias Layout = ProfileV3Theme.Sizes.SettingsPage

    var body: some View {
        Toggle(isOn: Binding(get: { item.isOn }, set: onToggle)) {
            HStack(alignment: .top, spacing: ProfileV3Theme.Space.s12) {
                ATIcon.SwiftUIImage.notificationsNone
                    .profileV3Icon(ProfileV3Theme.Sizes.settingsRowIcon)
                    .frame(width: ProfileV3Theme.Sizes.settingsRowIcon, height: ProfileV3Theme.Sizes.settingsRowIcon)
                    .foregroundStyle(Color(at: .pureBlack))
                VStack(alignment: .leading, spacing: Layout.switchTextSpacing) {
                    Text(item.title)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(Color(at: .pureBlack))
                    if !item.subtitle.isEmpty {
                        Text(item.subtitle)
                            .typoGraphy(.B2InterMedium12)
                            .foregroundStyle(Color(at: .neutralGrey400))
                            .frame(maxWidth: Layout.switchSubtitleWidth, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .multilineTextAlignment(.leading)
            }
        }
        .toggleStyle(ProfileV3SettingsSwitchStyle())
        .padding(.horizontal, ProfileV3Theme.Space.s8)
    }
}

private struct ProfileV3SettingsSwitchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: ProfileV3Theme.Space.s8) {
            configuration.label
            Spacer(minLength: 0)
            (configuration.isOn ? ATIcon.SwiftUIImage.toggleOn : ATIcon.SwiftUIImage.toggleOff)
                .profileV3Icon(ProfileV3Theme.Sizes.SettingsPage.switchToggle)
                .foregroundStyle(ProfileV3Theme.Palette.settingsToggle)
        }
        .contentShape(Rectangle())
        .onTapGesture { configuration.isOn.toggle() }
        .sensoryFeedback(.selection, trigger: configuration.isOn)
    }
}
