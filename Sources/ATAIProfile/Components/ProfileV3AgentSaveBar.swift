import ATUIKit
import SwiftUI

struct ProfileV3AgentSaveBar: View {
    @ObservedObject var viewModel: ProfileV3AgentFormViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            if let customRules = viewModel.customRules, customRules.canAdd {
                bar {
                    HStack(spacing: ProfileV3Theme.Space.s12) {
                        customRuleButton(customRules)
                        Spacer(minLength: 0)
                        if viewModel.showsSaveBar {
                            saveButton
                        }
                    }
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                }
                .transition(.opacity)
            } else if viewModel.showsSaveBar {
                bar { saveButton }
                    .transition(.opacity)
            }
        }
        .animation(ProfileV3Theme.Motion.saveState, value: viewModel.showsSaveBar)
    }

    private func bar(@ViewBuilder content: () -> some View) -> some View {
        ProfileV3SaveBar(
            error: viewModel.showsSaveBar && viewModel.showsSaveError ? ProfileV3Strings.saveFailed : nil,
            content: content
        )
        .animation(ProfileV3Theme.Motion.saveState, value: viewModel.showsSaveError)
    }

    private var saveButton: some View {
        ProfileV3SaveButton(
            phase: viewModel.saveState,
            title: ProfileV3Strings.saveChanges,
            savedTitle: ProfileV3Strings.agentPreferencesUpdated,
            action: viewModel.save
        )
        .profileV3SaveEntrance()
        .transition(.asymmetric(insertion: .identity, removal: .opacity))
    }

    private func customRuleButton(_ customRules: ProfileV3CustomRulesModel) -> some View {
        ProfileV3IconPillButton(
            icon: ATIcon.SwiftUIImage.add,
            title: customRules.field.addLabel,
            accessibilityLabel: customRules.field.editor.addTitle,
            action: customRules.startAdding
        )
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
