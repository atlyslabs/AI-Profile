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

struct ProfileV3DeleteLoginSheet: View {
    @ObservedObject var viewModel: ProfileV3AppCredentialsViewModel

    @State private var measured = Measured()

    private struct Measured: Equatable {
        var content: CGFloat = 0
        var bottomInset: CGFloat = 0
    }

    var body: some View {
        ProfileV3ConfirmationView.deleteLogin(
            subject: viewModel.deleteSubject,
            isDeleting: viewModel.isDeleting,
            onBack: viewModel.cancelDelete,
            onDelete: viewModel.confirmDelete
        )
        .fixedSize(horizontal: false, vertical: true)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { measured.content = $0 }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .background {
            Color.clear
                .onGeometryChange(for: CGFloat.self) { $0.safeAreaInsets.bottom } action: { measured.bottomInset = $0 }
        }
        .presentationDetents(detents)
        .presentationCornerRadius(ProfileV3Theme.Sizes.AppCredentials.cornerRadius)
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled(viewModel.isDeleting)
    }

    private var detents: Set<PresentationDetent> {
        guard measured.content > 0 else { return [.medium] }
        return [.height(measured.content + measured.bottomInset)]
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
            viewModel.hidePassword()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIPasteboard.changedNotification)) { _ in
            viewModel.pasteboardChanged()
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

    @ViewBuilder
    private var content: some View {
        if viewModel.showsHeader {
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
        } else {
            VStack(spacing: 0) {
                fields
                ProfileV3DashedDivider()
                    .padding(.top, Layout.deleteDividerTop)
                ProfileV3SettingsRow(
                    icon: ATIcon.SwiftUIImage.deleteOutline,
                    title: ProfileV3Strings.credentialDelete,
                    iconSize: Layout.deleteIcon,
                    iconSlot: ProfileV3Theme.Sizes.settingsRowIcon,
                    tint: ProfileV3Theme.Palette.destructive,
                    action: viewModel.askToDelete
                )
                .disabled(viewModel.phase != .editing)
                .padding(.top, Layout.deleteRowTop)
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, Layout.editFieldsTop)
            .padding(.bottom, Layout.editBottom)
        }
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
            if viewModel.showsWebsite {
                ProfileV3CredentialField(
                    label: ProfileV3Strings.appCredentialsWebsite,
                    text: $viewModel.credentials.website,
                    keyboard: .URL,
                    contentType: .URL,
                    isEditable: viewModel.asksForWebsite
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
            VStack(alignment: .leading, spacing: ProfileV3Theme.Space.s8) {
                ProfileV3CredentialField(
                    label: ProfileV3Strings.appCredentialsPassword,
                    text: $viewModel.credentials.password,
                    isSecure: !viewModel.isPasswordRevealed,
                    contentType: .password,
                    prompt: viewModel.passwordPrompt
                ) {
                    if viewModel.isRevealingPassword {
                        ProfileV3Spinner(size: Layout.accessory, lineWidth: ProfileV3Theme.Stroke.regular)
                            .frame(minWidth: ProfileV3Theme.Control.tapTarget, minHeight: Layout.accessory)
                    } else {
                        ProfileV3CredentialAccessory(
                            icon: viewModel.isPasswordRevealed
                                ? ATIcon.SwiftUIImage.visibility
                                : ATIcon.SwiftUIImage.visibilityOff,
                            accessibilityLabel: viewModel.isPasswordRevealed
                                ? ProfileV3Strings.hidePassword
                                : ProfileV3Strings.showPassword,
                            action: viewModel.togglePasswordVisibility
                        )
                    }
                }
                if let error = viewModel.inlineError {
                    Text(error)
                        .typoGraphy(.B2InterMedium12)
                        .foregroundStyle(ProfileV3Theme.Palette.destructive)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
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
                .opacity(saveOpacity)
                .allowsHitTesting(viewModel.showsSaveButton)
                .accessibilityHidden(!viewModel.showsSaveButton)
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
        .animation(ProfileV3Theme.Motion.saveState, value: viewModel.showsSaveButton)
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, Layout.barTop)
        .padding(.bottom, ProfileV3Theme.Sizes.Save.barBottom)
    }

    private var saveOpacity: Double {
        guard viewModel.showsSaveButton else { return 0 }
        return viewModel.canSubmit || viewModel.phase != .editing ? 1 : ProfileV3Theme.Motion.disabledOpacity
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

#Preview("Add new password · vault") {
    ProfileV3AppCredentialsPreview(mode: .vaultNew(site: ProfileV3VaultFixtures.sites.first))
}

#Preview("Saved login") {
    ProfileV3AppCredentialsPreview(mode: .vaultEdit(ProfileV3VaultCredential(
        id: "fd2c2c21-abdf-4f43-ba4a-3a1b9a374af1",
        displayName: "Singapore Airlines KrisFlyer",
        url: "https://www.singaporeair.com/en_UK/ppsclub-krisflyer/",
        status: .live,
        username: "someone@gmail.com"
    )))
}
#endif
