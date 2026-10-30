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

struct ProfileV3PhoneField: View {
    let label: String
    let regionISO: String
    let dialCode: String
    @Binding var digits: String
    var isFocused: FocusState<Bool>.Binding
    var isValid = true
    let onDialTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s12) {
            ProfileV3FieldLabel(text: label)
            ProfileV3PhoneInput(
                regionISO: regionISO,
                dialCode: dialCode,
                digits: $digits,
                isFocused: isFocused,
                isError: !isValid,
                onDialTap: onDialTap
            )
            if !isValid {
                ProfileV3ErrorText(text: ProfileV3Strings.phoneInvalid)
            }
        }
    }
}

struct ProfileV3PickerField: View {
    let label: String
    let value: String?
    var flagCode: String?
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s12) {
            ProfileV3FieldLabel(text: label)
            Button(action: action) {
                HStack(spacing: ProfileV3Theme.Space.s12) {
                    ProfileV3CountryFlag(isoCode: flagCode, size: ProfileV3Theme.Sizes.Contact.dialFlag)
                    Text(value ?? ProfileV3Strings.selectPlaceholder)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(value == nil ? Color(at: .neutralGrey200) : Color(at: .pureBlack))
                    Spacer(minLength: 0)
                    ATIcon.SwiftUIImage.expandMore
                        .profileV3Icon(ProfileV3Theme.Icon.md)
                        .foregroundStyle(Color(at: .neutralGrey400))
                }
                .padding(.bottom, ProfileV3Theme.Space.s8)
                .atFormFieldBottomLine(isError: false, isFocused: false, style: .dashed, tintsOnFocus: false)
                .contentShape(Rectangle())
            }
            .buttonStyle(.profileV3Pressable)
            .accessibilityLabel(label)
            .accessibilityValue(value ?? "")
        }
    }
}

extension View {
    func profileV3DialCodePicker(
        isPresented: Binding<Bool>,
        selected: LoginCountryOption,
        onSelect: @escaping (LoginCountryOption) -> Void
    ) -> some View {
        sheet(isPresented: isPresented) {
            LoginCountryPickerSheet(
                countries: LoginCountryOption.profileV3Options,
                selected: selected,
                onSelect: { option in
                    onSelect(option)
                    isPresented.wrappedValue = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
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
