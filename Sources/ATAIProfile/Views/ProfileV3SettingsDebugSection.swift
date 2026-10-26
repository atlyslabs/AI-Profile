#if DEBUG
import ATUIKit
import SwiftUI

struct ProfileV3SettingsDebugSection: View {
    @State private var scenario = ProfileV3DebugKYCScenario.current

    var body: some View {
        VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s16) {
            ProfileV3DashedDivider()
            ProfileV3TagLabel(text: "Debug · KYC state")
            card(ProfileV3DebugKYCScenario.allCases) { option in
                row(title: option.title, detail: option.detail, isSelected: option == scenario) {
                    guard option != scenario else { return }
                    scenario = option
                    ProfileV3DebugKYCScenario.current = option
                }
            }
            Text("Overrides the main traveler's KYC on the board. The hub reloads when you pick one.")
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .neutralGrey400))
        }
    }

    private func card<Option: Hashable, Row: View>(
        _ options: [Option],
        @ViewBuilder row: @escaping (Option) -> Row
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                if index > 0 {
                    Rectangle()
                        .fill(ProfileV3Theme.Palette.settingsCardBorder)
                        .frame(height: ProfileV3Theme.Stroke.hairline)
                }
                row(option)
            }
        }
        .profileV3SettingsCard()
    }

    private func row(title: String, detail: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: ProfileV3Theme.Space.s12) {
                VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s4) {
                    Text(title)
                        .typoGraphy(.H7InterMedium16)
                        .foregroundStyle(Color(at: .pureBlack))
                    Text(detail)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(Color(at: .neutralGrey400))
                }
                Spacer(minLength: 0)
                if isSelected {
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
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

struct ProfileV3GloveBoxDebugFlow: View {
    let onClose: () -> Void

    @StateObject private var viewModel: ProfileV3GloveBoxViewModel

    init(start: ProfileV3GloveBoxFixtures.Start, onClose: @escaping () -> Void) {
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: ProfileV3GloveBoxViewModel(gloveBox: start.gloveBox))
    }

    var body: some View {
        ProfileV3GloveBoxView(viewModel: viewModel, onBack: onClose)
            .onAppear(perform: wire)
    }

    private func wire() {
        let viewModel = viewModel
        viewModel.onIntroAction = { [weak viewModel] action in
            switch action {
            case .completeKYC: viewModel?.show(.intro(ProfileV3GloveBoxFixtures.warmingUp))
            case .activate: viewModel?.show(.home(ProfileV3GloveBoxFixtures.sampleHome))
            }
        }
        viewModel.onFollowUp = { [weak viewModel] _ in viewModel?.dismissSheets() }
        viewModel.onAddCard = { [weak viewModel] in viewModel?.linkCard(ProfileV3GloveBoxFixtures.hdfc) }
    }
}

#Preview("Settings debug section") {
    ScrollView {
        ProfileV3SettingsDebugSection()
            .padding(ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
    .background(Color(at: .pureWhite))
}

#Preview("Glove box · unlock") {
    ProfileV3GloveBoxDebugFlow(start: .unlock) {}
}

#Preview("Glove box · active") {
    ProfileV3GloveBoxDebugFlow(start: .home) {}
}

#Preview("Glove box · sample") {
    ProfileV3GloveBoxDebugFlow(start: .homeSample) {}
}
#endif
