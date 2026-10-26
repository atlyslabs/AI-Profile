import ATUIKit
import SwiftUI

struct ProfileV3PassportReasonView: View {
    @ObservedObject var viewModel: ProfileV3PassportReasonViewModel
    var avatarURL: URL?
    let onBack: () -> Void
    var onHowUsed: (() -> Void)?

    @State private var headerPin = ProfileV3HeaderPin()

    private var screen: ProfileV3PassportReasonScreen { viewModel.screen }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Text(screen.title ?? "")
                        .typoGraphy(.H5InterMedium20)
                        .foregroundStyle(ProfileV3Theme.Palette.countryText)
                        .multilineTextAlignment(.center)
                        .frame(width: ProfileV3Theme.Sizes.Passport.reasonTitleWidth)
                        .padding(.top, ProfileV3Theme.Sizes.Passport.reasonTitleTop)
                    if screen.howUsed != nil, let onHowUsed {
                        ProfileV3HowUsedPill(avatarURL: avatarURL, action: onHowUsed)
                            .padding(.top, ProfileV3Theme.Sizes.Passport.howUsedTop)
                    }
                    card
                        .padding(.top, ProfileV3Theme.Sizes.Passport.reasonCardTop)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.bottom, ProfileV3Theme.Sizes.Passport.listBottom)
                .profileV3HeaderFadeAnchor(headerPin)
            }
            .profileV3HeaderFade(headerPin, color: ProfileV3Theme.Palette.background)
            .scrollBounceBehavior(.basedOnSize)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ProfileV3Theme.passportScreenGradient.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { footer }
        .sensoryFeedback(.error, trigger: viewModel.submitFailed) { _, failed in failed }
    }

    private var header: some View {
        let steps = ProfileV3Theme.Counts.passportUpdateSteps
        return ProfileV3BackTagHeader(
            title: ProfileV3Strings.newPassport,
            step: (current: steps - 1, count: steps),
            onBack: onBack
        )
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProfileV3Vector.passport.image
                .profileV3Icon(ProfileV3Theme.Icon.xl)
                .foregroundStyle(Color(at: .pureBlack))
                .accessibilityHidden(true)
            Text(screen.subtitle ?? "")
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .frame(width: ProfileV3Theme.Sizes.Passport.reasonPromptWidth, alignment: .leading)
                .padding(.top, ProfileV3Theme.Sizes.Passport.reasonPromptTop)
            ProfileV3DashedDivider()
                .padding(.top, ProfileV3Theme.Sizes.Passport.reasonDividerTop)
            ForEach(screen.options) { option in
                row(option, isLast: option.id == screen.options.last?.id)
            }
        }
        .padding(ProfileV3Theme.Sizes.Passport.reasonCardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ProfileV3Theme.Radius.xl, style: .continuous)
                .fill(Color(at: .pureWhite))
                .shadow(
                    color: ProfileV3Theme.Palette.connectorCardShadow,
                    radius: ProfileV3Theme.Shadow.connectorCardRadius,
                    y: ProfileV3Theme.Shadow.connectorCardY
                )
        )
    }

    private func row(_ option: ProfileV3PassportReasonOption, isLast: Bool) -> some View {
        let isSelected = viewModel.selection == option.value
        return Button {
            viewModel.selection = option.value
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: ProfileV3Theme.Sizes.Passport.reasonRowSpacing) {
                    ProfileV3RadioMark(isSelected: isSelected, tint: Color(at: .pureBlack))
                    Text(option.label)
                        .typoGraphy(.B1InterMedium14)
                        .foregroundStyle(Color(at: .pureBlack))
                    Spacer(minLength: 0)
                }
                .frame(height: ProfileV3Theme.Control.tapTarget)
                if !isLast {
                    ProfileV3DashedDivider()
                        .padding(.leading, ProfileV3Theme.Sizes.Passport.reasonRowInset)
                }
            }
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var footer: some View {
        VStack(spacing: ProfileV3Theme.Space.s12) {
            if viewModel.submitFailed {
                Text(ProfileV3Strings.passportUpdateFailed)
                    .typoGraphy(.T1InterBold11)
                    .foregroundStyle(ProfileV3Theme.Palette.error)
                    .multilineTextAlignment(.center)
            }
            if let ctaTitle = screen.ctaTitle {
                ProfileV3GradientButton(title: ctaTitle, action: viewModel.submit)
                    .disabled(viewModel.selection == nil || viewModel.isSubmitting)
                    .opacity(viewModel.selection == nil ? ProfileV3Theme.Motion.disabledOpacity : 1)
            }
        }
        .animation(ProfileV3Theme.Motion.saveState, value: viewModel.submitFailed)
        .profileV3CTABar(top: ProfileV3Theme.Sizes.Disconnect.barTop)
    }
}

#if DEBUG
private struct ProfileV3PassportReasonPreview: View {
    @StateObject private var viewModel: ProfileV3PassportReasonViewModel

    init(selection: String? = ProfileV3PassportChangeReason.lost.rawValue) {
        let viewModel = ProfileV3PassportReasonViewModel(repository: ProfileV3MockRepository(), onSubmitted: {})
        viewModel.selection = selection
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ProfileV3PassportReasonView(
            viewModel: viewModel,
            avatarURL: ProfileV3PlaceholderArt.agentFlight.url,
            onBack: {},
            onHowUsed: {}
        )
        .task { viewModel.load() }
    }
}

#Preview("Passport reason") {
    ProfileV3PassportReasonPreview()
}

#Preview("Passport reason · no selection") {
    ProfileV3PassportReasonPreview(selection: nil)
}
#endif
