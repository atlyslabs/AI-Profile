#if DEBUG
import ATUIKit
import SwiftUI

struct ProfileV3SettingsDebugSection: View {
    @State private var scenario = ProfileV3DebugKYCScenario.current

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s16) {
            ProfileV3DashedDivider()
            ProfileV3TagLabel(text: "Debug · KYC state")
            VStack(spacing: 0) {
                ForEach(Array(ProfileV3DebugKYCScenario.allCases.enumerated()), id: \.element) { index, option in
                    if index > 0 {
                        Rectangle()
                            .fill(ProfileV3Theme.Palette.settingsCardBorder)
                            .frame(height: ProfileV3Theme.Stroke.hairline)
                    }
                    row(option)
                }
            }
            .profileV3SettingsCard()
            Text("Overrides the main traveler's KYC on the board. The hub reloads when you pick one.")
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .neutralGrey400))
        }
    }

    private func row(_ option: ProfileV3DebugKYCScenario) -> some View {
        Button {
            guard option != scenario else { return }
            scenario = option
            ProfileV3DebugKYCScenario.current = option
        } label: {
            HStack(spacing: ProfileV3Theme.Space.s12) {
                VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s4) {
                    Text(option.title)
                        .typoGraphy(.H7InterMedium16)
                        .foregroundStyle(Color(at: .pureBlack))
                    Text(option.detail)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                }
                Spacer(minLength: 0)
                if option == scenario {
                    ATIcon.SwiftUIImage.check
                        .profileV3Icon(ProfileV3Theme.Icon.md)
                        .foregroundStyle(Color(at: .pureBlack))
                }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.cardContentPadding)
            .padding(.vertical, ProfileV3Theme.Space.s14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityAddTraits(option == scenario ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview("Settings debug section") {
    ProfileV3SettingsDebugSection()
        .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
        .background(Color(at: .pureWhite))
}
#endif
