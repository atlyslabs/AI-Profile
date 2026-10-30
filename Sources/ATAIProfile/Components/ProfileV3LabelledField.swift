import ATUIKit
import SwiftUI

struct ProfileV3LabelledField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var width: CGFloat?
    var error: String?
    var onFocusChange: ((Bool) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s12) {
            ProfileV3FieldLabel(text: label)
            ProfileV3UnderlinedField(
                placeholder: placeholder,
                accessibilityLabel: label,
                text: $text,
                keyboard: keyboard,
                autocapitalization: autocapitalization,
                width: nil,
                isError: error != nil,
                onFocusChange: onFocusChange
            )
            if let error {
                ProfileV3ErrorText(text: error)
            }
        }
        .frame(maxWidth: width ?? .infinity, alignment: .leading)
    }
}

#if DEBUG
private struct ProfileV3LabelledFieldPreview: View {
    @State private var first = "Alex"
    @State private var last = ""

    var body: some View {
        HStack(alignment: .top, spacing: ProfileV3Theme.Space.s32) {
            ProfileV3LabelledField(
                label: ProfileV3Strings.firstNameLabel,
                placeholder: ProfileV3Strings.firstNamePlaceholder,
                text: $first,
                width: ProfileV3Theme.Sizes.Traveller.fieldColumnWidth
            )
            ProfileV3LabelledField(
                label: ProfileV3Strings.lastNameLabel,
                placeholder: ProfileV3Strings.lastNamePlaceholder,
                text: $last,
                width: ProfileV3Theme.Sizes.Traveller.fieldColumnWidth
            )
        }
    }
}

#Preview("Labelled fields") {
    ProfileV3LabelledFieldPreview()
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}
#endif
