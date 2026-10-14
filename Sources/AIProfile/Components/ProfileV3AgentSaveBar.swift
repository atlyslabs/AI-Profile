import ATUIKit
import SwiftUI

struct ProfileV3AgentSaveBar: View {
    @ObservedObject var viewModel: ProfileV3AgentFormViewModel

    var body: some View {
        if viewModel.showsSaveBar {
            controls
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private var controls: some View {
        ZStack(alignment: .bottom) {
            ProfileV3SaveBarFade()
            VStack(spacing: ProfileV3Theme.Space.s12) {
                if viewModel.showsSaveError {
                    Text(ProfileV3Strings.saveFailed)
                        .typoGraphy(.T1InterBold11)
                        .foregroundStyle(ProfileV3Theme.Palette.error)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel(ProfileV3Strings.saveFailed)
                }
                ProfileV3SaveButton(
                    phase: viewModel.savePhase,
                    title: ProfileV3Strings.saveChanges,
                    savedTitle: ProfileV3Strings.agentPreferencesUpdated,
                    action: viewModel.save
                )
            }
            .animation(ProfileV3Theme.Motion.saveState, value: viewModel.showsSaveError)
            .padding(.bottom, ProfileV3Theme.Sizes.Save.barBottom)
        }
    }
}

struct ProfileV3AgentOptionPicker: View {
    @ObservedObject var viewModel: ProfileV3AgentFormViewModel

    var body: some View {
        if let section = viewModel.pickerSection, case .chips(let field) = section.control, let picker = field.picker {
            ProfileV3OptionPickerView(
                title: picker.title,
                options: viewModel.pickerOptions,
                selection: field.selection,
                onBack: viewModel.closePicker,
                onToggle: { viewModel.toggleOption($0, in: section.id) }
            )
        }
    }
}

extension View {
    func profileV3AgentSaveBar(_ viewModel: ProfileV3AgentFormViewModel) -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) { ProfileV3AgentSaveBar(viewModel: viewModel) }
            .animation(ProfileV3Theme.Motion.saveState, value: viewModel.showsSaveBar)
    }
}
