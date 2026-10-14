import ATUIKit
import SwiftUI

struct ProfileV3UnderlinedField: View {
    let placeholder: String
    var accessibilityLabel: String?
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var width: CGFloat? = ProfileV3Theme.Sizes.underlinedFieldWidth
    var isError = false
    var onFocusChange: ((Bool) -> Void)?

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder.lowercased(), text: $text)
            .typoGraphy(.B1InterMedium14)
            .foregroundStyle(Color(at: .pureBlack))
            .keyboardType(keyboard)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled()
            .focused($isFocused)
            .onChange(of: isFocused) { _, focused in onFocusChange?(focused) }
            .profileV3UnderlinedFieldStyle(isFocused: isFocused, width: width, isError: isError)
            .accessibilityLabel(accessibilityLabel ?? placeholder)
    }
}

extension View {
    func profileV3UnderlinedFieldStyle(isFocused: Bool, width: CGFloat?, isError: Bool = false) -> some View {
        padding(.bottom, ProfileV3Theme.Space.s8)
            .atFormFieldBottomLine(isError: isError, isFocused: isFocused, style: .dashed, tintsOnFocus: true)
            .frame(width: width)
    }
}

#if DEBUG
private struct ProfileV3UnderlinedFieldPreview: View {
    @State private var phone = "+91 9000000002"

    var body: some View {
        ProfileV3UnderlinedField(placeholder: "+91", text: $phone, keyboard: .phonePad)
            .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
            .background(Color(at: .pureWhite))
    }
}

#Preview("Underlined field") {
    ProfileV3UnderlinedFieldPreview()
}
#endif
