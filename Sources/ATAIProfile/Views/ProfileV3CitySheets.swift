import ATUIKit
import SwiftUI

struct ProfileV3CitySearchSheet: View {
    @ObservedObject var model: ProfileV3CitySearchModel
    let onBack: () -> Void
    let onChoose: (ProfileV3CitySearchResult) -> Void

    @State private var query = ""
    @State private var chosenID: String?

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3AgentSheetHeader(
                tag: model.picker?.title.nonEmpty ?? ProfileV3Strings.addCityProfile,
                showsOrb: false,
                onBack: onBack
            )
            SettingsSearchField(placeholder: model.picker?.searchPlaceholder.nonEmpty ?? ProfileV3Strings.search, text: $query)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, ProfileV3Theme.Space.s40)
            results
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite))
        .onChange(of: query) { _, query in model.setQuery(query) }
        .profileV3Sheet(.large, cornerRadius: ProfileV3Theme.Sizes.largeSheetCornerRadius)
    }

    @ViewBuilder
    private var results: some View {
        if model.results.isEmpty, model.isSearching {
            ProfileV3Spinner(accessibilityLabel: ProfileV3Strings.loading)
                .padding(.top, ProfileV3Theme.Sizes.emptyStateTop)
                .frame(maxHeight: .infinity, alignment: .top)
        } else if model.results.isEmpty, model.hasFailed {
            ProfileV3LoadStateView(phase: .failed, retry: model.retry)
                .frame(maxHeight: .infinity, alignment: .top)
        } else if model.results.isEmpty {
            ScrollView(showsIndicators: false) {
                ProfileV3EmptyState(
                    icon: ATIcon.SwiftUIImage.search,
                    title: model.picker?.emptyTitle.nonEmpty ?? ProfileV3Strings.searchEmptyTitle,
                    subtitle: model.picker?.emptySubtitle.nonEmpty ?? ProfileV3Strings.searchEmptySubtitle
                )
                .frame(width: ProfileV3Theme.Sizes.emptyStateTextWidth)
                .frame(maxWidth: .infinity)
                .padding(.top, ProfileV3Theme.Sizes.emptyStateTop)
            }
            .scrollDismissesKeyboard(.interactively)
            .frame(maxHeight: .infinity)
        } else {
            ProfileV3FadingScroll(bounceBehavior: .automatic) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if let heading = model.picker?.heading.nonEmpty {
                        ProfileV3TagLabel(text: heading, style: .solid(ProfileV3Theme.Palette.secondaryText))
                            .padding(.bottom, ProfileV3Theme.Sizes.Picker.listLabelBottom)
                    }
                    ForEach(model.results) { result in
                        ProfileV3CityPickerRow(result: result, isChosen: chosenID == result.id) {
                            chosenID = result.id
                            onChoose(result)
                        }
                    }
                    if model.hasMore {
                        ProfileV3PagingFooter(
                            hasFailed: model.loadMoreFailed,
                            page: model.results.count,
                            loadMore: model.loadMore,
                            retry: model.retryLoadMore
                        )
                        .padding(.vertical, ProfileV3Theme.Space.s16)
                    }
                }
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, ProfileV3Theme.Space.s40)
            }
        }
    }
}

private struct ProfileV3CityPickerRow: View {
    let result: ProfileV3CitySearchResult
    let isChosen: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                ProfileV3RadioMark(isSelected: isChosen)
                ProfileV3CountryFlag(isoCode: result.countryCode, size: ProfileV3Theme.Sizes.Picker.logo, placeholder: .globe)
                    .padding(.leading, ProfileV3Theme.Space.s14)
                label
                    .typoGraphy(.B1InterSemibold14)
                    .foregroundStyle(ProfileV3Theme.Palette.countryText)
                    .lineLimit(1)
                    .padding(.leading, ProfileV3Theme.Space.s18)
                Spacer(minLength: 0)
            }
            .frame(height: ProfileV3Theme.Sizes.Picker.rowHeight)
            .overlay(alignment: .bottom) {
                ProfileV3DashedDivider()
                    .padding(.leading, ProfileV3Theme.Space.s32)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityAddTraits(isChosen ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(result.title)
        .accessibilityValue(result.country ?? "")
    }

    private var label: Text {
        guard let country = result.country?.nonEmpty else { return Text(result.title) }
        return Text(result.title)
            + Text(ProfileV3Strings.subtitleSeparator + country)
                .foregroundStyle(ProfileV3Theme.Palette.countryText.opacity(ProfileV3Theme.Opacity.cardSubtitle))
    }
}

struct ProfileV3CityPurposeSheetView: View {
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
                if let delete = model.sheet?.delete {
                    ProfileV3FittedConfirmationSheet(cornerRadius: ProfileV3Theme.Sizes.largeSheetCornerRadius, isBusy: model.isDeleting) {
                        ProfileV3ConfirmationView.deleteCity(
                            delete.confirm,
                            isDeleting: model.isDeleting,
                            onBack: model.cancelDelete,
                            onConfirm: model.confirmDelete
                        )
                    }
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
                if let sheet = model.sheet {
                    switch model.step {
                    case .purpose: purposeStep(sheet)
                    case .label: labelStep(sheet)
                    }
                } else {
                    ProfileV3LoadStateView(phase: model.phase, retry: model.load)
                        .frame(height: Sizes.purposeLoadHeight)
                }
            }
            .transition(.opacity)
        }
        .animation(ProfileV3Theme.Motion.expand, value: model.step)
        .animation(ProfileV3Theme.Motion.contentFade, value: model.phase)
    }

    private var header: some View {
        ZStack(alignment: .top) {
            ProfileV3AgentSheetChrome(control: .back(model.back), isEnabled: !model.isBusy, title: {
                ProfileV3TagLabel(text: model.title)
            })
            if let delete = model.sheet?.delete, model.step == .purpose {
                HStack {
                    Spacer()
                    ProfileV3CityHeaderButton(
                        icon: ATIcon.SwiftUIImage.delete,
                        accessibilityLabel: delete.label,
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

    private func purposeStep(_ sheet: ProfileV3CityPurposeSheet) -> some View {
        VStack(spacing: 0) {
            ProfileV3CityOptionGrid(options: sheet.options) { option in
                ProfileV3CityOptionChip(
                    title: label(for: option),
                    isSelected: model.purposeKey == option.key,
                    style: .ink,
                    iconURL: option.iconURL,
                    isEnabled: !option.isDisabled || option.isSelected
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
                title: sheet.submitLabel,
                isLoading: model.savePhase == .saving,
                isEnabled: model.canContinue,
                action: model.commit
            )
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, Sizes.tagSheetButtonTop)
        }
    }

    @ViewBuilder
    private func labelStep(_ sheet: ProfileV3CityPurposeSheet) -> some View {
        if let input = model.labelInput {
            VStack(spacing: 0) {
                ProfileV3LabelledField(
                    label: ProfileV3Strings.requiredLabel(input.label),
                    placeholder: input.placeholder,
                    text: $model.label,
                    error: model.isLabelTaken ? sheet.labelTaken.nonEmpty : model.errorMessage
                )
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, Sizes.purposeTop)
                ProfileV3CityInkButton(
                    title: sheet.submitLabel,
                    isLoading: model.savePhase == .saving,
                    isEnabled: model.canContinue,
                    action: model.commit
                )
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.top, Sizes.purposeButtonTop)
                .padding(.bottom, Sizes.tagSheetBottom)
            }
        }
    }

    private func label(for option: ProfileV3CityPurposeSheet.Option) -> String {
        guard option.input != nil, model.purposeKey == option.key, !model.trimmedLabel.isEmpty else { return option.label }
        return model.trimmedLabel
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
            message: confirm.message,
            primaryTitle: confirm.confirmLabel,
            secondaryTitle: confirm.cancelLabel,
            isPrimaryLoading: isDeleting,
            metrics: .rule,
            onBack: onBack,
            onPrimary: onConfirm,
            onSecondary: onBack
        )
    }
}

#if DEBUG
#Preview("City picker") {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            ProfileV3CitySearchSheet(
                model: {
                    let model = ProfileV3CitySearchModel(profileID: nil, repository: ProfileV3MockRepository())
                    model.load()
                    return model
                }(),
                onBack: {},
                onChoose: { _ in }
            )
        }
}

#Preview("City purpose sheet · add") {
    ProfileV3CityPurposeSheetView(
        model: {
            let model = ProfileV3CityEditorModel(
                mode: .add(ProfileV3CityProfileFixtures.catalogue[3]),
                profileID: nil,
                repository: ProfileV3MockRepository(),
                onFinish: { _ in }
            )
            model.load()
            return model
        }()
    )
}

#Preview("City purpose sheet · edit") {
    ProfileV3CityPurposeSheetView(
        model: {
            let model = ProfileV3CityEditorModel(
                mode: .edit(cityID: "c1", code: "BOM", name: "Mumbai", imageURL: nil),
                profileID: nil,
                repository: ProfileV3MockRepository(),
                onFinish: { _ in }
            )
            model.load()
            return model
        }()
    )
}
#endif
