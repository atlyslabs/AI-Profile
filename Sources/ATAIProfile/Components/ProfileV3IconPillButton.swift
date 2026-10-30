import ATUIKit
import SwiftUI

struct ProfileV3IconPillButton: View {
    let icon: Image
    var title = ""
    var iconOnlyWidth: CGFloat?
    var feedback: SensoryFeedback? = .impact(weight: .medium)
    var accessibilityLabel = ""
    let action: () -> Void

    private typealias Save = ProfileV3Theme.Sizes.Save

    private var hasTitle: Bool { !title.isEmpty }

    var body: some View {
        if let feedback {
            button.buttonStyle(.profileV3Pressable(feedback))
        } else {
            button.buttonStyle(.plain)
        }
    }

    private var button: some View {
        Button(action: action) {
            HStack(spacing: Save.buttonSpacing) {
                icon
                    .profileV3Icon(Save.buttonIcon)
                if hasTitle {
                    Text(title)
                        .typoGraphy(.B1InterSemibold14)
                }
            }
            .foregroundStyle(Color(at: .pureBlack))
            .padding(.leading, iconOnlyWidth == nil || hasTitle ? Save.buttonLeading : 0)
            .padding(.trailing, trailingPadding)
            .frame(width: hasTitle ? nil : iconOnlyWidth)
            .frame(height: Save.buttonHeight)
            .profileV3CapsuleChrome()
        }
        .accessibilityLabel(accessibilityLabel.isEmpty ? title : accessibilityLabel)
    }

    private var trailingPadding: CGFloat {
        if hasTitle { return Save.buttonTrailing }
        return iconOnlyWidth == nil ? Save.buttonLeading : 0
    }
}

#if DEBUG
#Preview("Icon pill button") {
    VStack(spacing: ProfileV3Theme.Space.s24) {
        ProfileV3IconPillButton(icon: ATIcon.SwiftUIImage.add, title: "Custom") {}
        ProfileV3IconPillButton(icon: ATIcon.SwiftUIImage.add) {}
        ProfileV3IconPillButton(
            icon: ATIcon.SwiftUIImage.edit,
            iconOnlyWidth: ProfileV3Theme.Sizes.Programmes.editButtonWidth,
            feedback: nil
        ) {}
    }
    .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    .background(Color(at: .pureWhite))
}
#endif
