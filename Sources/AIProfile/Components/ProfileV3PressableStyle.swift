import SwiftUI

struct ProfileV3PressableStyle: PrimitiveButtonStyle {
    var feedback: SensoryFeedback = .impact(weight: .light)
    var dimsWhenDisabled = true

    func makeBody(configuration: Configuration) -> some View {
        ProfileV3PressableButton(configuration: configuration, feedback: feedback, dimsWhenDisabled: dimsWhenDisabled)
    }
}

private struct ProfileV3PressableButton: View {
    let configuration: PrimitiveButtonStyleConfiguration
    let feedback: SensoryFeedback
    let dimsWhenDisabled: Bool

    @State private var presses = 0

    var body: some View {
        let button = Button(role: configuration.role) {
            presses += 1
            configuration.trigger()
        } label: {
            configuration.label
        }
        Group {
            if dimsWhenDisabled {
                button.buttonStyle(.plain)
            } else {
                button.buttonStyle(ProfileV3UndimmedButtonStyle())
            }
        }
        .sensoryFeedback(feedback, trigger: presses)
    }
}

private struct ProfileV3UndimmedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? ProfileV3Theme.Motion.pressedScale : 1)
            .animation(ProfileV3Theme.Motion.selection, value: configuration.isPressed)
    }
}

extension PrimitiveButtonStyle where Self == ProfileV3PressableStyle {
    static var profileV3Pressable: ProfileV3PressableStyle { ProfileV3PressableStyle() }

    static func profileV3Pressable(
        _ feedback: SensoryFeedback,
        dimsWhenDisabled: Bool = true
    ) -> ProfileV3PressableStyle {
        ProfileV3PressableStyle(feedback: feedback, dimsWhenDisabled: dimsWhenDisabled)
    }
}
