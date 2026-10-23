import ATUIKit
import PostHog
import SwiftUI

struct ProfileV3FieldLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .typoGraphy(.T2InterBold12)
            .textCase(.uppercase)
            .foregroundStyle(Color(at: .pureBlack))
            .accessibilityHidden(true)
    }
}

struct ProfileV3PhoneInput: View {
    let regionISO: String
    let dialCode: String
    @Binding var digits: String
    var isFocused: FocusState<Bool>.Binding
    var placeholder = ProfileV3Strings.typeHere
    var isError = false
    var tintsOnFocus = true
    var onDialTap: (() -> Void)?

    var body: some View {
        HStack(spacing: ProfileV3Theme.Space.s12) {
            ProfileV3DialCodeButton(
                regionISO: regionISO,
                dialCode: dialCode,
                isInteractive: onDialTap != nil,
                action: onDialTap ?? {}
            )
            TextField(placeholder.lowercased(), text: $digits)
                .typoGraphy(.B1InterMedium14)
                .foregroundStyle(Color(at: .pureBlack))
                .keyboardType(.numberPad)
                .textContentType(.telephoneNumber)
                // Session replay masks phone fields by type; a phone number is fine to show.
                .postHogNoMask()
                .focused(isFocused)
        }
        .padding(.bottom, ProfileV3Theme.Space.s8)
        .atFormFieldBottomLine(
            isError: isError,
            isFocused: isFocused.wrappedValue,
            style: .dashed,
            tintsOnFocus: tintsOnFocus
        )
    }
}

#if DEBUG
private struct ProfileV3PhoneInputPreview: View {
    @State private var digits = "9000000002"
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s12) {
            ProfileV3FieldLabel(text: ProfileV3Strings.numberLabel)
            ProfileV3PhoneInput(regionISO: "IN", dialCode: "91", digits: $digits, isFocused: $isFocused, onDialTap: {})
        }
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
    }
}

#Preview("Phone input") {
    ProfileV3PhoneInputPreview()
}
#endif
