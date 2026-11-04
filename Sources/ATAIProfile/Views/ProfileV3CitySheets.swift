import ATUIKit
import SwiftUI

struct ProfileV3CitySearchSheet: View {
    @ObservedObject var model: ProfileV3CitySearchModel
    let onBack: () -> Void
    let onChoose: (ProfileV3CitySearchResult) -> Void

    var body: some View {
        ProfileV3OptionPickerView(
            title: ProfileV3Strings.addCityProfile,
            options: model.options,
            selection: model.addedIDs,
            isSearching: model.isSearching,
            onQueryChange: model.setQuery,
            onBack: onBack,
            onToggle: { id in
                if let result = model.result(id: id) { onChoose(result) }
            }
        )
        .profileV3Sheet(.large, cornerRadius: ProfileV3Theme.Sizes.largeSheetCornerRadius)
    }
}

struct ProfileV3CityTagSheet: View {
    @ObservedObject var model: ProfileV3CityEditorModel

    @State private var height: CGFloat = 0

    private typealias Sizes = ProfileV3Theme.Sizes.City

    var body: some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height = $0 }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(at: .pureWhite).ignoresSafeArea())
            .profileV3TapToDismissKeyboard()
            .profileV3Sheet(
                .fitted(height > 0 ? height : nil),
                cornerRadius: ProfileV3Theme.Sizes.largeSheetCornerRadius,
                isDismissDisabled: model.isBusy
            )
            .sheet(isPresented: $model.confirmsDelete) {
                ProfileV3FittedConfirmationSheet(cornerRadius: ProfileV3Theme.Sizes.largeSheetCornerRadius, isBusy: model.isDeleting) {
                    ProfileV3ConfirmationView.deleteCity(
                        model.profile.deleteConfirm,
                        isDeleting: model.isDeleting,
                        onBack: model.cancelDelete,
                        onConfirm: model.confirmDelete
                    )
                }
            }
            .sensoryFeedback(.error, trigger: model.errorMessage) { _, message in message != nil }
    }

    private var content: some View {
        VStack(spacing: 0) {
            header
            ProfileV3CityWindow(content: model.window, isPhotoSharp: true)
                .padding(.top, Sizes.carouselTop)
            Group {
                switch model.step {
                case .tag: tagStep
                case .purpose: purposeStep
                }
            }
            .transition(.opacity)
        }
        .padding(.bottom, Sizes.tagSheetBottom)
        .animation(ProfileV3Theme.Motion.expand, value: model.step)
    }

    private var header: some View {
        ZStack(alignment: .top) {
            ProfileV3AgentSheetChrome(control: .back(model.back), isEnabled: !model.isBusy, title: {
                ProfileV3TagLabel(text: model.title)
            })
            if model.isEditing, model.step == .tag {
                HStack {
                    Spacer()
                    ProfileV3CityHeaderButton(
                        icon: ATIcon.SwiftUIImage.delete,
                        accessibilityLabel: ProfileV3Strings.deleteCity,
                        action: model.requestDelete
                    )
                    .disabled(model.isBusy)
                }
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, ProfileV3Theme.Sizes.Agent.backTop)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var tagStep: some View {
        VStack(spacing: 0) {
            ProfileV3CityOptionGrid(options: model.profile.tags) { option in
                ProfileV3CityOptionChip(
                    title: model.label(for: option),
                    isSelected: model.tagID == option.id,
                    style: .ink,
                    icon: ProfileV3CityIcon.image(option.icon)
                ) {
                    model.select(option)
                }
            }
            .frame(maxWidth: Sizes.optionGridWidth)
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, Sizes.tagSheetOptionsTop)
            if let error = model.errorMessage {
                ProfileV3ErrorText(text: error)
                    .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                    .padding(.top, ProfileV3Theme.Space.s16)
            }
            ProfileV3CityInkButton(
                title: model.profile.continueLabel,
                isLoading: model.phase == .saving,
                isEnabled: model.canContinue,
                action: model.commit
            )
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, Sizes.tagSheetButtonTop)
        }
    }

    private var purposeStep: some View {
        VStack(spacing: 0) {
            ProfileV3LabelledField(
                label: model.profile.purpose.label,
                placeholder: model.profile.purpose.placeholder,
                text: $model.purpose,
                error: model.errorMessage
            )
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, Sizes.purposeTop)
            ProfileV3CityInkButton(
                title: model.profile.purpose.saveLabel,
                isLoading: model.phase == .saving,
                isEnabled: model.canSavePurpose,
                action: model.commit
            )
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, Sizes.purposeButtonTop)
        }
    }
}

extension ProfileV3ConfirmationView {
    static func deleteCity(
        _ confirm: ProfileV3CityDeleteConfirm,
        isDeleting: Bool,
        onBack: @escaping () -> Void,
        onConfirm: @escaping () -> Void
    ) -> ProfileV3ConfirmationView {
        ProfileV3ConfirmationView(
            icon: ATIcon.SwiftUIImage.delete,
            style: .neutral,
            title: confirm.title,
            primaryTitle: confirm.confirmLabel,
            secondaryTitle: confirm.cancelLabel,
            isPrimaryLoading: isDeleting,
            onBack: onBack,
            onPrimary: onConfirm,
            onSecondary: onBack
        )
    }
}

#if DEBUG
#Preview("City tag sheet · add") {
    ProfileV3CityTagSheet(
        model: ProfileV3CityEditorModel(
            mode: .add(ProfileV3CityProfileFixtures.catalogue[3]),
            profile: ProfileV3CityProfileFixtures.profile,
            profileID: nil,
            repository: ProfileV3MockRepository(),
            onFinish: { _ in }
        )
    )
}

#Preview("City tag sheet · edit") {
    ProfileV3CityTagSheet(
        model: ProfileV3CityEditorModel(
            mode: .edit(ProfileV3CityProfileFixtures.profile.cities[0]),
            profile: ProfileV3CityProfileFixtures.profile,
            profileID: nil,
            repository: ProfileV3MockRepository(),
            onFinish: { _ in }
        )
    )
}

#Preview("Delete city confirmation") {
    ProfileV3ConfirmationView.deleteCity(
        ProfileV3CityProfileFixtures.profile.deleteConfirm,
        isDeleting: false,
        onBack: {},
        onConfirm: {}
    )
}
#endif
