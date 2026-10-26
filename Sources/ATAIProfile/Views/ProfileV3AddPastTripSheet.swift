import ATUIKit
import SwiftUI

struct ProfileV3AddPastTripSheet: View {
    @ObservedObject var viewModel: ProfileV3AddPastTripViewModel
    let onClose: () -> Void
    @Environment(\.atBottomSheetMaxHeight) private var maxHeight

    private typealias Sizes = ProfileV3Theme.Sizes.TripSheet

    var body: some View {
        ZStack(alignment: .top) {
            switch viewModel.step {
            case .country:
                countryStep
                    .transition(.opacity)
            case .duration:
                durationStep
                    .transition(.opacity)
            }
            header
        }
        .frame(height: min(viewModel.step == .country ? Sizes.countryHeight : Sizes.durationHeight, maxHeight))
        .overlay(alignment: .topTrailing) {
            ProfileV3CircleIconButton.close(size: Sizes.closeButton, action: onClose)
                .padding(.top, Sizes.closeTop)
                .padding(.trailing, Sizes.closeTrailing)
        }
        .disabled(viewModel.isSubmitting)
        .sensoryFeedback(.error, trigger: viewModel.errorMessage) { _, message in message != nil }
    }

    private var header: some View {
        VStack(spacing: Sizes.indicatorTop) {
            ProfileV3TagLabel(text: viewModel.title)
                .contentTransition(.opacity)
            Button(action: viewModel.backToCountry) {
                ProfileV3StepIndicator(count: viewModel.stepCount, current: viewModel.stepIndex, style: .currentOnly)
                    .padding(.vertical, ProfileV3Theme.Space.s8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.vertical, -ProfileV3Theme.Space.s8)
            .disabled(viewModel.step == .country)
            .accessibilityLabel(ProfileV3Strings.back)
            .accessibilityHidden(viewModel.step == .country)
        }
        .padding(.top, Sizes.titleTop)
    }

    @ViewBuilder
    private var countryList: some View {
        if viewModel.isLoadingScreen, viewModel.countries == nil {
            ProfileV3Spinner()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ProfileV3CountryList(
                query: $viewModel.query,
                selection: viewModel.selectedCountry,
                pinned: viewModel.pinnedCountry,
                countries: viewModel.countries,
                searchPlaceholder: viewModel.searchPlaceholder,
                focusesSearch: false,
                listBottomInset: Sizes.fadeHeight,
                onSelect: viewModel.select
            )
        }
    }

    private var countryStep: some View {
        countryList
            .padding(.top, Sizes.countryListTop)
            .overlay(alignment: .bottom) {
                ctaBar(title: viewModel.countryCTA, isEnabled: viewModel.canContinue, fades: true) {
                    viewModel.continueToDuration()
                }
            }
    }

    private var durationStep: some View {
        ZStack(alignment: .top) {
            wheelLabel(viewModel.duration.yearLabel)
                .padding(.top, Sizes.yearLabelTop)
            ProfileV3DurationWheel(
                values: viewModel.years,
                selection: $viewModel.selectedYear,
                pitch: Sizes.yearPitch,
                accessibilityTitle: viewModel.duration.yearLabel
            ) { String($0) }
            .padding(.top, Sizes.yearWheelTop)
            ProfileV3NotchedDivider()
                .stroke(
                    ProfileV3Theme.Palette.tripNotch.opacity(ProfileV3Theme.Opacity.tripNotch),
                    style: StrokeStyle(lineWidth: ProfileV3Theme.Stroke.hairline, lineCap: .round, lineJoin: .round)
                )
                .frame(height: Sizes.notchDepth + ProfileV3Theme.Stroke.hairline)
                .padding(.horizontal, Sizes.notchInset)
                .padding(.top, Sizes.notchTop)
                .accessibilityHidden(true)
            wheelLabel(viewModel.duration.monthLabel)
                .padding(.top, Sizes.monthLabelTop)
            ProfileV3DurationWheel(
                values: viewModel.months,
                selection: $viewModel.selectedMonth,
                pitch: Sizes.monthPitch,
                accessibilityTitle: viewModel.duration.monthLabel,
                label: viewModel.monthLabel
            )
            .padding(.top, Sizes.monthWheelTop)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .bottom) {
            ctaBar(title: viewModel.submitTitle, isEnabled: viewModel.canSubmit, fades: false) {
                viewModel.submit()
            }
        }
    }

    private func wheelLabel(_ text: String) -> some View {
        Text(text)
            .typoGraphy(.T1InterBold11)
            .textCase(.uppercase)
            .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.tripLabel))
            .accessibilityHidden(true)
    }

    private func ctaBar(
        title: String,
        isEnabled: Bool,
        fades: Bool,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: Sizes.errorBottom) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(ProfileV3Theme.Palette.error)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
            if !title.isEmpty {
                ProfileV3TripSheetButton(
                    title: title,
                    isEnabled: isEnabled,
                    isLoading: viewModel.isSubmitting,
                    action: action
                )
            }
        }
        .padding(.horizontal, Sizes.ctaInset)
        .padding(.bottom, Sizes.ctaBottom)
        .frame(maxWidth: .infinity)
        .background(alignment: .bottom) {
            if fades {
                ProfileV3Theme.clearToWhiteFade
                    .frame(height: Sizes.fadeHeight)
                    .allowsHitTesting(false)
            }
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
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(Color(at: .pureWhite))
                } else {
                    Text(title)
                        .typoGraphy(.B2InterSemibold12)
                        .foregroundStyle(Color(at: .pureWhite))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: ProfileV3Theme.Sizes.TripSheet.ctaHeight)
            .background(
                Capsule().fill(isEnabled || isLoading ? Color(at: .pureBlack) : ProfileV3Theme.Palette.disabledText)
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.profileV3Pressable(.impact(weight: .medium), dimsWhenDisabled: false))
        .disabled(!isEnabled || isLoading)
        .animation(ProfileV3Theme.Motion.selection, value: isEnabled)
        .accessibilityLabel(title)
    }
}

struct ProfileV3PastTripActionsSheet: View {
    let editTitle: String
    let deleteTitle: String
    let onEdit: () -> Void
    let onDelete: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.TripSheet

    var body: some View {
        VStack(spacing: 0) {
            if !editTitle.isEmpty {
                row(icon: ATIcon.SwiftUIImage.edit, title: editTitle, action: onEdit)
            }
            if !editTitle.isEmpty, !deleteTitle.isEmpty {
                Line()
                    .stroke(
                        Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.tripDivider),
                        style: StrokeStyle(
                            lineWidth: ProfileV3Theme.Stroke.hairline,
                            lineCap: .round,
                            dash: Sizes.dividerDash
                        )
                    )
                    .frame(height: ProfileV3Theme.Stroke.hairline)
                    .padding(.top, Sizes.actionsDividerGap)
                    .accessibilityHidden(true)
            }
            if !deleteTitle.isEmpty {
                row(icon: ATIcon.SwiftUIImage.delete, title: deleteTitle, action: onDelete)
                    .padding(.top, editTitle.isEmpty ? 0 : Sizes.actionsSecondGap)
            }
        }
        .padding(.horizontal, Sizes.inset)
        .padding(.top, Sizes.actionsTop)
        .frame(height: Sizes.actionsHeight, alignment: .top)
    }

    private func row(icon: Image, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Sizes.actionGap) {
                icon
                    .profileV3Icon(Sizes.actionIcon)
                    .foregroundStyle(ProfileV3Theme.Palette.tripActionIcon)
                    .accessibilityHidden(true)
                Text(title)
                    .typoGraphy(.H7InterMedium16)
                    .foregroundStyle(Color(at: .pureBlack))
                Spacer(minLength: 0)
            }
            .frame(height: Sizes.actionRowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityLabel(title)
    }
}

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
