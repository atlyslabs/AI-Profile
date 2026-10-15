import ATUIKit
import SwiftUI

struct ProfileV3StepIndicator: View {
    enum Style {
        case cumulative
        case currentOnly
    }

    let count: Int
    let current: Int
    var style: Style = .cumulative

    var body: some View {
        HStack(spacing: ProfileV3Theme.Space.s4) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(fill(at: index))
                    .frame(width: ProfileV3Theme.Sizes.stepBarWidth, height: ProfileV3Theme.Sizes.stepBarHeight)
            }
        }
        .animation(ProfileV3Theme.Motion.selection, value: current)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ProfileV3Strings.stepIndicator(current: current + 1, total: count))
    }

    private func fill(at index: Int) -> Color {
        switch style {
        case .cumulative:
            return index <= current ? Color(at: .pureBlack) : ProfileV3Theme.Palette.saveButtonBorder
        case .currentOnly:
            return index == current ? Color(at: .pureBlack) : ProfileV3Theme.Palette.stepInactive
        }
    }
}

#if DEBUG
#Preview("Step indicator") {
    VStack(spacing: ProfileV3Theme.Space.s20) {
        ProfileV3StepIndicator(count: 2, current: 0)
        ProfileV3StepIndicator(count: 2, current: 1)
    }
    .padding(ProfileV3Theme.Space.s32)
    .background(Color(at: .pureWhite))
}
#endif
