import ATUIKit
import SwiftUI

struct ProfileV3CheckboxRow: View {
    let title: String
    let isOn: Bool
    let onToggle: () -> Void

    private var box: RoundedRectangle {
        RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.xxs, style: .continuous)
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: ProfileV3Theme.Space.s8) {
                box
                    .fill(isOn ? Color(at: .pureBlack) : Color.clear)
                    .overlay(box.stroke(Color(at: .pureBlack), lineWidth: ProfileV3Theme.Stroke.hairline))
                    .overlay {
                        if isOn {
                            ATIcon.SwiftUIImage.check
                                .profileV3Icon(ProfileV3Theme.Icon.sm)
                                .foregroundStyle(Color(at: .pureWhite))
                        }
                    }
                    .frame(width: ProfileV3Theme.Icon.md, height: ProfileV3Theme.Icon.md)
                Text(title)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey400))
            }
            .frame(minHeight: ProfileV3Theme.Control.tapTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(ProfileV3Theme.Motion.selection, value: isOn)
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }
}

struct ProfileV3ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    var titleColor: Color = Color(at: .pureBlack)
    var tint: Color = Color(at: .pureBlack)

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(titleColor)
        }
        .tint(tint)
    }
}

#if DEBUG
private struct ProfileV3FormControlsPreview: View {
    @State private var prefersNotToSay = false
    @State private var showsOnLockScreen = true

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s24) {
            ProfileV3CheckboxRow(title: ProfileV3Strings.ratherNotSay, isOn: prefersNotToSay) {
                prefersNotToSay.toggle()
            }
            ProfileV3ToggleRow(title: ProfileV3Strings.openMedicalCardWhenLocked, isOn: $showsOnLockScreen)
        }
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
    }
}

#Preview("Form controls") {
    ProfileV3FormControlsPreview()
}
#endif
