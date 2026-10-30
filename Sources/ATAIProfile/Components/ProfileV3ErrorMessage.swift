import ATUIKit
import SwiftUI

struct ProfileV3ErrorText: View {
    enum Style {
        case field
        case bar
    }

    let text: String
    var style: Style = .field

    var body: some View {
        Text(text)
            .typoGraphy(style == .field ? .B2InterMedium12 : .T1InterBold11)
            .foregroundStyle(ProfileV3Theme.Palette.destructive)
    }
}

extension View {
    func profileV3ErrorAlert(
        _ title: String,
        message: String? = nil,
        isPresented: Bool,
        retry: (@MainActor () -> Void)? = nil,
        onDismiss: @escaping @MainActor () -> Void
    ) -> some View {
        alert(
            title,
            isPresented: Binding(get: { isPresented }, set: { if !$0 { onDismiss() } })
        ) {
            if let retry {
                Button(ProfileV3Strings.retry, action: retry)
            }
            Button(ProfileV3Strings.close, role: .cancel, action: onDismiss)
        } message: {
            if let message {
                Text(message)
            }
        }
    }
}
