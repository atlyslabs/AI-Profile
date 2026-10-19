import ATUIKit
import SwiftUI
import UIKit

struct ProfileV3AppCredentialsView: View {
    @ObservedObject var viewModel: ProfileV3AppCredentialsViewModel
    let onClose: () -> Void

    @State private var measured = Measured()

    private struct Measured: Equatable {
        var content: CGFloat = 0
        var bar: CGFloat = 0
        var bottomInset: CGFloat = 0
    }

    var body: some View {
        ProfileV3AppCredentialsSheet(
            viewModel: viewModel,
            onClose: onClose,
            onContentHeight: { measured.content = $0 },
            onBarHeight: { measured.bar = $0 }
        )
        .background {
            Color.clear
                .ignoresSafeArea(.keyboard)
                .onGeometryChange(for: CGFloat.self) { $0.safeAreaInsets.bottom } action: { measured.bottomInset = $0 }
        }
        .presentationDetents(detents)
        .presentationCornerRadius(ProfileV3Theme.Sizes.AppCredentials.cornerRadius)
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled(viewModel.phase == .submitting)
        .onDisappear(perform: viewModel.cancel)
    }

    private var detents: Set<PresentationDetent> {
        guard measured.content > 0, measured.bar > 0 else { return [.large] }
        return [.height(measured.content + measured.bar + measured.bottomInset)]
    }
}

struct ProfileV3AppCredentialsSheet: View {
    @ObservedObject var viewModel: ProfileV3AppCredentialsViewModel
    let onClose: () -> Void
    var scrolls = true
    var onContentHeight: (CGFloat) -> Void = { _ in }
    var onBarHeight: (CGFloat) -> Void = { _ in }

    @Environment(\.openURL) private var openURL

    private typealias Layout = ProfileV3Theme.Sizes.AppCredentials

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if scrolls {
                    ScrollView(showsIndicators: false) {
                        measuredContent
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollDismissesKeyboard(.interactively)
                } else {
                    VStack(spacing: 0) {
                        measuredContent
                        Spacer(minLength: 0)
                    }
                }
            }
            .overlay(alignment: .top) { header }
            bar
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { onBarHeight($0) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .sensoryFeedback(.success, trigger: viewModel.phase == .succeeded)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            viewModel.hideStoredPassword()
        }
    }

    private var measuredContent: some View {
        content
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { onContentHeight($0) }
    }

    private var header: some View {
        ZStack(alignment: .top) {
            ProfileV3SheetGrabber(
                width: ProfileV3Theme.Sizes.Agent.sheetGrabberWidth,
                color: Color(at: .neutralGrey200),
                top: ProfileV3Theme.Space.s10
            )
            HStack {
                Spacer()
                ProfileV3CircleIconButton.close(action: onClose)
                    .disabled(viewModel.phase == .submitting)
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Sizes.Agent.backTop)
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            shield
            Text(viewModel.title)
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .multilineTextAlignment(.center)
                .frame(width: Layout.titleWidth)
                .padding(.top, Layout.titleTop)
                .accessibilityAddTraits(.isHeader)
            fields
                .padding(.top, Layout.fieldsTop)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            Text(ProfileV3Strings.appCredentialsNote)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.appCredentialsNote))
                .multilineTextAlignment(.center)
                .frame(width: Layout.noteWidth)
                .padding(.top, viewModel.asksForWebsite ? Layout.passwordNoteTop : Layout.noteTop)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, ProfileV3Theme.Sizes.Agent.backTop + Layout.shieldTop)
    }

    private var shield: some View {
        ZStack(alignment: .top) {
            ProfileV3ShieldShape()
                .stroke(
                    Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.appShieldStroke),
                    lineWidth: Layout.shieldStroke
                )
                .clipShape(ProfileV3ShieldShape())
            glyph
                .frame(width: Layout.glyph, height: Layout.glyph)
                .padding(.top, Layout.glyphTop)
        }
        .frame(width: Layout.shield.width, height: Layout.shield.height)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var glyph: some View {
        if let app = viewModel.app {
            ProfileV3AppLogo(url: app.iconURL, size: Layout.glyph)
        } else {
            ProfileV3ConnectorGlyph.addCircle.image
                .resizable()
                .scaledToFit()
        }
    }

    private var fields: some View {
        VStack(spacing: Layout.fieldSpacing) {
            if viewModel.asksForLabel {
                ProfileV3CredentialField(label: ProfileV3VaultStrings.siteName, text: $viewModel.label)
            }
            if viewModel.asksForWebsite {
                ProfileV3CredentialField(
                    label: ProfileV3Strings.appCredentialsWebsite,
                    text: $viewModel.credentials.website,
                    keyboard: .URL,
                    contentType: .URL
                ) {
                    ProfileV3CredentialAccessory(
                        icon: ATIcon.SwiftUIImage.callMade,
                        accessibilityLabel: ProfileV3Strings.openWebsite,
                        isEnabled: viewModel.credentials.websiteURL != nil
                    ) {
                        if let url = viewModel.credentials.websiteURL { openURL(url) }
                    }
                }
            }
            ProfileV3CredentialField(
                label: ProfileV3Strings.appCredentialsUsername,
                text: $viewModel.credentials.username,
                keyboard: .emailAddress,
                contentType: .username
            )
            ProfileV3CredentialField(
                label: ProfileV3Strings.appCredentialsPassword,
                text: $viewModel.credentials.password,
                isSecure: !viewModel.isPasswordRevealed,
                contentType: .password
            ) {
                ProfileV3CredentialAccessory(
                    icon: viewModel.isPasswordRevealed
                        ? ATIcon.SwiftUIImage.visibility
                        : ATIcon.SwiftUIImage.visibilityOff,
                    accessibilityLabel: viewModel.isPasswordRevealed
                        ? ProfileV3Strings.hidePassword
                        : ProfileV3Strings.showPassword,
                    isEnabled: !viewModel.isRevealingPassword,
                    action: viewModel.togglePasswordVisibility
                )
            }
        }
        .disabled(viewModel.phase != .editing)
    }

    private var bar: some View {
        ZStack {
            if viewModel.isEditing {
                ProfileV3SaveButton(
                    phase: viewModel.savePhase,
                    title: viewModel.submitTitle,
                    savedTitle: viewModel.successMessage,
                    action: viewModel.submit
                )
                .disabled(!viewModel.canSubmit && viewModel.phase == .editing)
                .opacity(viewModel.canSubmit || viewModel.phase != .editing ? 1 : ProfileV3Theme.Motion.disabledOpacity)
            } else {
                switch viewModel.phase {
                case .editing:
                    ProfileV3ContinueButton(
                        title: viewModel.submitTitle,
                        disabledTint: Color(at: .neutralGrey400),
                        isEnabled: viewModel.canSubmit,
                        action: viewModel.submit
                    )
                    .transition(.opacity)
                case .submitting:
                    ProfileV3Spinner(size: ProfileV3Theme.Icon.xl, lineWidth: ProfileV3Theme.Stroke.regular)
                        .frame(maxWidth: .infinity)
                        .frame(height: ProfileV3Theme.Sizes.Save.buttonHeight)
                        .profileV3CapsuleChrome()
                        .transition(.opacity)
                case .succeeded:
                    ProfileV3Toast(message: viewModel.successMessage)
                        .transition(.opacity)
                }
            }
        }
        .animation(ProfileV3Theme.Motion.saveState, value: viewModel.phase)
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, Layout.barTop)
        .padding(.bottom, ProfileV3Theme.Sizes.Save.barBottom)
    }
}

#if DEBUG
private struct ProfileV3AppCredentialsPreview: View {
    let mode: ProfileV3AppCredentialsViewModel.Mode
    @State private var isPresented = true

    var body: some View {
        Color(at: .neutralGrey600)
            .ignoresSafeArea()
            .sheet(isPresented: $isPresented) {
                ProfileV3AppCredentialsView(
                    viewModel: ProfileV3AppCredentialsViewModel(
                        mode: mode,
                        origin: .page,
                        repository: ProfileV3MockRepository()
                    ),
                    onClose: { isPresented = false }
                )
            }
    }
}

#Preview("Add credentials") {
    ProfileV3AppCredentialsPreview(mode: .add(ProfileV3AppAccessFixtures.content.apps[0]))
}

#Preview("Add new password") {
    ProfileV3AppCredentialsPreview(mode: .newPassword)
}
#endif
