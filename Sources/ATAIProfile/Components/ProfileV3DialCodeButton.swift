import ATUIKit
import SwiftUI

struct ProfileV3DialCodeButton: View {
    let regionISO: String
    let dialCode: String
    var isInteractive = true
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfileV3Theme.Sizes.Contact.dialSpacing) {
                ProfileV3CountryFlag(isoCode: regionISO, size: ProfileV3Theme.Sizes.Contact.dialFlag)
                Text(ProfileV3Strings.dialCodeDisplay(dialCode))
                    .typoGraphy(.B1InterMedium14)
                if isInteractive {
                    ATIcon.SwiftUIImage.expandMore
                        .profileV3Icon(ProfileV3Theme.Icon.md)
                }
            }
            .foregroundStyle(Color(at: .pureBlack))
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable)
        .disabled(!isInteractive)
        .accessibilityLabel(ProfileV3Strings.dialCode(dialCode, region: regionISO))
    }
}

#if DEBUG
#Preview("Dial code") {
    VStack(spacing: ProfileV3Theme.Space.s20) {
        ProfileV3DialCodeButton(regionISO: "IN", dialCode: "91")
        ProfileV3DialCodeButton(regionISO: "AE", dialCode: "971", isInteractive: false)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
