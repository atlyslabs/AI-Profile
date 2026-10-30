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

struct ProfileV3OutlinedShield<Glyph: View>: View {
    @ViewBuilder let glyph: Glyph

    private typealias Layout = ProfileV3Theme.Sizes.AppCredentials

    var body: some View {
        ZStack(alignment: .top) {
            ProfileV3ShieldShape()
                .stroke(
                    Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.appShieldStroke),
                    lineWidth: Layout.shieldStroke
                )
                .clipShape(ProfileV3ShieldShape())
            glyph
                .frame(width: Layout.glyph, height: Layout.glyph)
                .padding(.top, Layout.glyphTop)
        }
        .frame(width: Layout.shield.width, height: Layout.shield.height)
        .accessibilityHidden(true)
    }
}

struct ProfileV3ShieldHeading<Shield: View>: View {
    let title: String
    @ViewBuilder let shield: Shield

    private typealias Layout = ProfileV3Theme.Sizes.AppCredentials

    var body: some View {
        VStack(spacing: 0) {
            shield
            Text(title)
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .multilineTextAlignment(.center)
                .frame(width: Layout.titleWidth)
                .padding(.top, Layout.titleTop)
                .accessibilityAddTraits(.isHeader)
        }
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
            ProfileV3FieldLabel(text: label)
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
        .opacity(isEnabled ? 1 : ProfileV3Theme.Opacity.disabled)
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
                    shape
                        .fill(ProfileV3Theme.appHintGradient)
                        .shadow(
                            color: ProfileV3Theme.Palette.appHintShadow,
                            radius: Layout.hintShadowRadius,
                            y: Layout.hintShadowY
                        )
                }
                .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
    }

    private var shape: ProfileV3PointerBubbleShape {
        ProfileV3PointerBubbleShape(
            pointer: Layout.hintPointer,
            tipRun: Layout.hintTipRun,
            pointerOffset: Layout.hintPointerOffset
        )
    }
}

#if DEBUG
#Preview("Connected apps hint") {
    ProfileV3ConnectedAppsHint(text: ProfileV3Strings.appAccessConnectedHint, onTap: {})
        .padding(ProfileV3Theme.Space.s32)
        .background(Color(at: .pureWhite))
}
#endif
