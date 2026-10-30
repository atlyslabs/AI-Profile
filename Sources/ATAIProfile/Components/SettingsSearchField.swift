import ATUIKit
import SwiftUI

struct SettingsSearchField: View {
    let placeholder: String
    @Binding var text: String
    var autocapitalization: TextInputAutocapitalization = .words

    var body: some View {
        HStack(spacing: ProfileV3Theme.Space.s8) {
            Image("search", bundle: .atUIKit)
                .resizable()
                .frame(width: ProfileV3Theme.Icon.lg, height: ProfileV3Theme.Icon.lg)
                .foregroundStyle(Color(at: .pureBlack))
            TextField(placeholder, text: $text)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureBlack))
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(true)
        }
        .padding(.horizontal, ProfileV3Theme.Space.s16)
        .frame(height: ProfileV3Theme.Control.tapTarget)
        .overlay(Capsule().stroke(Color(at: .border), lineWidth: ProfileV3Theme.Stroke.hairline))
    }
}

#if DEBUG
#Preview("Search field") {
    SettingsSearchField(placeholder: "Search", text: .constant(""))
        .padding()
}
#endif
