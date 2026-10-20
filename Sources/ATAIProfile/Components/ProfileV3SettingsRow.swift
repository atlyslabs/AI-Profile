import ATUIKit
import SwiftUI

struct ProfileV3SettingsRow: View {
    let icon: Image
    let title: String
    var iconSize: CGFloat = ProfileV3Theme.Sizes.settingsRowIcon
    var iconSlot: CGFloat?
    var tint: Color = Color(at: .pureBlack)
    var showsChevron = true
    var flag: ATCountry?
    var lockNote: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfileV3Theme.Space.s12) {
                leadingIcon
                    .frame(width: iconSlot ?? min(iconSize, ProfileV3Theme.Sizes.settingsRowIcon))
                    .frame(height: ProfileV3Theme.Sizes.settingsRowIcon)
                Text(title)
                    .typoGraphy(.B1InterMedium14)
                Spacer(minLength: ProfileV3Theme.Space.s8)
                if lockNote != nil {
                    ATIcon.SwiftUIImage.lock
                        .profileV3Icon(ProfileV3Theme.Sizes.CitizenshipLock.lockIcon)
                        .foregroundStyle(ProfileV3Theme.Palette.citizenshipLockIcon)
                        .frame(width: ProfileV3Theme.Icon.xl, height: ProfileV3Theme.Icon.xl)
                } else if showsChevron {
                    ATIcon.SwiftUIImage.chevronRight
                        .profileV3Icon(ProfileV3Theme.Icon.xl)
                }
            }
            .foregroundStyle(tint)
            .padding(.horizontal, ProfileV3Theme.Space.s8)
            .frame(height: ProfileV3Theme.Sizes.settingsRowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(title)
        .accessibilityValue(lockNote ?? "")
    }

    @ViewBuilder
    private var leadingIcon: some View {
        if let flag {
            ATCountryFlagView(country: flag)
                .frame(width: iconSize, height: iconSize)
                .clipShape(Circle())
        } else {
            icon.profileV3Icon(iconSize)
        }
    }
}

extension ProfileV3SettingsRowItem {
    var icon: Image {
        switch key {
        case ProfileV3ProfileField.residence.rawValue: return ATIcon.SwiftUIImage.flag
        case ProfileV3ProfileField.citizenship.rawValue: return ATIcon.SwiftUIImage.globe
        case ProfileV3ProfileField.contact.rawValue: return ATIcon.SwiftUIImage.phone
        case ProfileV3ProfileField.currency.rawValue: return ATIcon.SwiftUIImage.database
        case "connectors": return ATIcon.SwiftUIImage.plugConnect
        case "edit_traveler": return ATIcon.SwiftUIImage.edit
        case "coupons": return ATIcon.SwiftUIImage.add
        case "loyalty_programs": return ATIcon.SwiftUIImage.cardGiftcard
        case "terms": return ATIcon.SwiftUIImage.infoOutline
        case ProfileV3PermissionDefaults.rowKey: return ProfileV3Vector.mobileCheck.image
        case "logout": return ATIcon.SwiftUIImage.logout
        case "delete_account": return ATIcon.SwiftUIImage.deleteOutline
        default: return ATIcon.SwiftUIImage.moreVert
        }
    }
}

#if DEBUG
#Preview("Settings rows") {
    VStack(spacing: ProfileV3Theme.Space.s14) {
        ForEach(ProfileV3Fixtures.settingsMenu.listRows) { row in
            ProfileV3SettingsRow(icon: row.icon, title: row.label) {}
        }
        ProfileV3DashedDivider()
        ForEach(ProfileV3Fixtures.settingsMenu.dangerRows) { row in
            ProfileV3SettingsRow(icon: row.icon, title: row.label, tint: ProfileV3Theme.Palette.destructive) {}
        }
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
