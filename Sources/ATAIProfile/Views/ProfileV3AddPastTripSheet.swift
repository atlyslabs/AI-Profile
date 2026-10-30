import ATUIKit
import SwiftUI

struct ProfileV3AddPastTripSheet: View {
    @ObservedObject var viewModel: ProfileV3AddPastTripViewModel
    let onClose: () -> Void
    @Environment(\.atBottomSheetMaxHeight) private var maxHeight

    private typealias Sizes = ProfileV3Theme.Sizes.TripSheet

    var body: some View {
        ZStack(alignment: .top) {
            countryList
                .padding(.top, Sizes.countryListTop)
                .overlay(alignment: .bottom) { ctaBar }
            ProfileV3TagLabel(text: viewModel.title)
                .padding(.top, Sizes.titleTop)
        }
        .frame(height: min(Sizes.countryHeight, maxHeight))
        .overlay(alignment: .topTrailing) {
            ProfileV3CircleIconButton.close(size: Sizes.closeButton, action: onClose)
                .padding(.top, Sizes.closeTop)
                .padding(.trailing, Sizes.closeTrailing)
        }
        .disabled(viewModel.isSubmitting)
        .sensoryFeedback(.error, trigger: viewModel.errorMessage) { _, message in message != nil }
    }

    @ViewBuilder
    private var countryList: some View {
        if viewModel.isLoadingScreen, viewModel.countries == nil {
            ProfileV3Spinner()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ProfileV3CountryList(
                query: $viewModel.query,
                selection: nil,
                selections: viewModel.selectedCountries,
                countries: viewModel.countries,
                searchPlaceholder: viewModel.searchPlaceholder,
                focusesSearch: false,
                listBottomInset: Sizes.fadeHeight,
                onSelect: viewModel.select
            )
        }
    }

    private var ctaBar: some View {
        VStack(spacing: Sizes.errorBottom) {
            if let error = viewModel.errorMessage {
                ProfileV3ErrorText(text: error)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
            if !viewModel.countryCTA.isEmpty {
                ProfileV3TripSheetButton(
                    title: viewModel.countryCTA,
                    isEnabled: viewModel.canSubmit,
                    isLoading: viewModel.isSubmitting,
                    action: viewModel.submit
                )
            }
        }
        .padding(.horizontal, Sizes.ctaInset)
        .padding(.bottom, Sizes.ctaBottom)
        .frame(maxWidth: .infinity)
        .background(alignment: .bottom) {
            ProfileV3FadeBand(fade: Sizes.fadeHeight, edge: .bottom)
        }
    }
}

private struct ProfileV3TripSheetButton: View {
    let title: String
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ProfileV3InkPill(
                title: title,
                isLoading: isLoading,
                width: .full,
                typography: .B2InterSemibold12,
                fill: isEnabled || isLoading ? Color(at: .pureBlack) : ProfileV3Theme.Palette.disabledText
            )
        }
        .buttonStyle(.profileV3Pressable(.impact(weight: .medium), dimsWhenDisabled: false))
        .disabled(!isEnabled || isLoading)
        .animation(ProfileV3Theme.Motion.selection, value: isEnabled)
        .accessibilityLabel(title)
    }
}

struct ProfileV3PastTripActionsSheet: View {
    let deleteTitle: String
    let onDelete: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.TripSheet

    var body: some View {
        VStack(spacing: 0) {
            if !deleteTitle.isEmpty {
                Button(action: onDelete) {
                    HStack(spacing: Sizes.actionGap) {
                        ATIcon.SwiftUIImage.delete
                            .profileV3Icon(Sizes.actionIcon)
                            .foregroundStyle(ProfileV3Theme.Palette.silverGrey)
                            .accessibilityHidden(true)
                        Text(deleteTitle)
                            .typoGraphy(.H7InterMedium16)
                            .foregroundStyle(Color(at: .pureBlack))
                        Spacer(minLength: 0)
                    }
                    .frame(height: Sizes.actionRowHeight)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.profileV3Pressable(.selection))
                .accessibilityLabel(deleteTitle)
            }
        }
        .padding(.horizontal, Sizes.inset)
        .padding(.top, Sizes.actionsTop)
        .frame(height: Sizes.actionsHeight, alignment: .top)
    }
}
