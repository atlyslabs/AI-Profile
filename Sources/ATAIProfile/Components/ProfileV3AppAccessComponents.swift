import ATUIKit
import PostHog
import SwiftUI

struct ProfileV3AppLogo: View {
    let url: URL?
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(ProfileV3Theme.Palette.background)
            if let url {
                ProfileV3RemoteImage(url: url, contentMode: .fill, placeholder: .clear)
            } else {
                ATIcon.SwiftUIImage.globe
                    .profileV3Icon(size / 2)
                    .foregroundStyle(Color(at: .pureBlack))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}

struct ProfileV3CredentialField<Accessory: View>: View {
    let label: String
    @Binding var text: String
    var isSecure = false
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType?
    var prompt: String?
    var isEditable = true
    @ViewBuilder var accessory: () -> Accessory

    @FocusState private var isFocused: Bool

    private typealias Layout = ProfileV3Theme.Sizes.AppCredentials

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.fieldGap) {
            Text(label)
                .typoGraphy(.T2InterBold12)
                .textCase(.uppercase)
                .foregroundStyle(Color(at: .pureBlack))
                .accessibilityHidden(true)
            HStack(spacing: ProfileV3Theme.Space.s8) {
                input
                    .frame(maxWidth: .infinity, alignment: .leading)
                accessory()
            }
            .padding(.bottom, Layout.fieldGap)
            .atFormFieldBottomLine(isError: false, isFocused: isFocused, style: .dashed, tintsOnFocus: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var input: some View {
        Group {
            if !isEditable {
                Text(text)
                    .lineLimit(1)
                    .truncationMode(.middle)
            } else if isSecure {
                SecureField(label.lowercased(), text: $text, prompt: promptText)
            } else {
                TextField(label.lowercased(), text: $text, prompt: promptText)
            }
        }
        .typoGraphy(.B1InterMedium14)
        .foregroundStyle(Color(at: .pureBlack))
        .keyboardType(keyboard)
        .textContentType(contentType)
        // A password stays out of session replay, revealed or not.
        .postHogMask(isSecure || contentType == .password || contentType == .newPassword)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .focused($isFocused)
        .accessibilityLabel(label)
    }

    private var promptText: Text? {
        prompt.map { Text($0).foregroundStyle(Color(at: .pureBlack)) }
    }
}

extension ProfileV3CredentialField where Accessory == EmptyView {
    init(
        label: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil
    ) {
        self.init(label: label, text: text, keyboard: keyboard, contentType: contentType) { EmptyView() }
    }
}

struct ProfileV3CredentialAccessory: View {
    let icon: Image
    let accessibilityLabel: String
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            icon
                .profileV3Icon(ProfileV3Theme.Sizes.AppCredentials.accessory)
                .foregroundStyle(Color(at: .pureBlack))
                .frame(minWidth: ProfileV3Theme.Control.tapTarget, minHeight: ProfileV3Theme.Sizes.AppCredentials.accessory)
                .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable)
        .frame(width: ProfileV3Theme.Sizes.AppCredentials.accessory, height: ProfileV3Theme.Sizes.AppCredentials.accessory)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : ProfileV3Theme.Motion.disabledOpacity)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct ProfileV3ConnectedAppsHint: View {
    let text: String
    let onTap: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.AppAccess

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .pureWhite))
                .multilineTextAlignment(.center)
                .frame(width: Layout.hintTextWidth)
                .padding(.top, Layout.hintTextTop)
                .frame(width: Layout.hint.width, height: Layout.hint.height, alignment: .top)
                .background {
                    ProfileV3HintBubbleShape()
                        .fill(ProfileV3Theme.appHintGradient)
                        .shadow(
                            color: ProfileV3Theme.Palette.appHintShadow,
                            radius: Layout.hintShadowRadius,
                            y: Layout.hintShadowY
                        )
                }
                .contentShape(ProfileV3HintBubbleShape())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
    }
}

struct ProfileV3HintBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let size = ProfileV3Theme.Sizes.AppAccess.hint
        let sx = rect.width / size.width
        let sy = rect.height / size.height
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()
        path.move(to: point(133, 62.4884))
        path.addCurve(to: point(145, 50.4884), control1: point(139.627, 62.4884), control2: point(145, 57.1158))
        path.addLine(to: point(145, 18.4884))
        path.addCurve(to: point(133, 6.4884), control1: point(145, 11.861), control2: point(139.627, 6.4884))
        path.addLine(to: point(88.142, 6.4884))
        path.addCurve(to: point(84.6068, 5.0239), control1: point(86.8163, 6.4884), control2: point(85.5445, 5.9616))
        path.addLine(to: point(81.5355, 1.9526))
        path.addCurve(to: point(74.4645, 1.9526), control1: point(79.5829, 0), control2: point(76.4171, 0))
        path.addLine(to: point(71.3932, 5.0239))
        path.addCurve(to: point(67.8576, 6.4884), control1: point(70.4555, 5.9616), control2: point(69.1837, 6.4884))
        path.addLine(to: point(12, 6.4884))
        path.addCurve(to: point(0, 18.4884), control1: point(5.3726, 6.4884), control2: point(0, 11.861))
        path.addLine(to: point(0, 50.4884))
        path.addCurve(to: point(12, 62.4884), control1: point(0, 57.1158), control2: point(5.3726, 62.4884))
        path.closeSubpath()
        return path
    }
}

#if DEBUG
#Preview("Connected apps hint") {
    ProfileV3ConnectedAppsHint(text: ProfileV3Strings.appAccessConnectedHint, onTap: {})
        .padding(ProfileV3Theme.Space.s32)
        .background(Color(at: .pureWhite))
}
#endif
