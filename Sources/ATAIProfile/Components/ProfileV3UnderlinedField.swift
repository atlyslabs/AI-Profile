import ATUIKit
import SwiftUI

struct ProfileV3UnderlinedField: View {
    let placeholder: String
    var accessibilityLabel: String?
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var width: CGFloat? = ProfileV3Theme.Sizes.underlinedFieldWidth
    var growsWithContent = false
    var isError = false
    var onFocusChange: ((Bool) -> Void)?

    @FocusState private var isFocused: Bool

    var body: some View {
        if growsWithContent {
            ProfileV3ContentWidthLayout(minWidth: width ?? 0) {
                field(width: nil)
            }
        } else {
            field(width: width)
        }
    }

    private func field(width: CGFloat?) -> some View {
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

private struct ProfileV3ContentWidthLayout: Layout {
    let minWidth: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let field = subviews.first else { return .zero }
        return field.sizeThatFits(ProposedViewSize(width: width(of: field, in: proposal), height: proposal.height))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first?.place(at: bounds.origin, proposal: ProposedViewSize(bounds.size))
    }

    private func width(of field: LayoutSubview, in proposal: ProposedViewSize) -> CGFloat {
        let content = field.sizeThatFits(.unspecified).width + ProfileV3Theme.Sizes.underlinedFieldCaretAllowance
        let wanted = max(content, minWidth)
        guard let available = proposal.width else { return wanted }
        return min(wanted, available)
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
    @State private var address = "Flat 4B, Sea View Apartments, Carter Road, Bandra West"

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s32) {
            ProfileV3UnderlinedField(placeholder: "+91", text: $phone, keyboard: .phonePad)
            ProfileV3UnderlinedField(placeholder: "Address", text: $address, growsWithContent: true)
        }
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
    }
}

#Preview("Underlined field") {
    ProfileV3UnderlinedFieldPreview()
}
#endif
