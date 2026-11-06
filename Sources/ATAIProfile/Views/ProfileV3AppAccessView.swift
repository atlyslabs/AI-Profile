import ATUIKit
import SwiftUI

struct ProfileV3AppAccessView: View {
    @ObservedObject var model: ProfileV3AppAccessModel
    let onBack: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            ProfileV3AppAccessContent(model: model, showsConnected: model.canOpenConnected, onBack: onBack)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(at: .pureWhite))
        .overlay(alignment: .bottom) {
            if model.phase == .loaded, ProfileV3FeatureFlags.isAppAccessOtherAppsEnabled {
                addNewBar
            }
        }
        .sheet(item: editor) { editor in
            ProfileV3AppCredentialsView(viewModel: editor, onClose: model.closeEditor)
        }
        .sheet(item: $model.instagram) { instagram in
            ProfileV3InstagramConnectSheet(model: instagram)
        }
        .overlay {
            if model.isRedirectingToInstagram {
                ProfileV3InstagramRedirectOverlay()
                    .transition(.opacity)
            }
        }
        .animation(ProfileV3Theme.Motion.contentSwitch, value: model.isRedirectingToInstagram)
        .sensoryFeedback(.success, trigger: model.disconnectCompletions)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            model.refreshIfAwaitingMessage()
        }
    }

    private var editor: Binding<ProfileV3AppCredentialsViewModel?> {
        Binding(get: { model.editor(from: .page) }, set: { if $0 == nil { model.closeEditor() } })
    }

    private var addNewBar: some View {
        ProfileV3SaveBar {
            ProfileV3ContinueButton(title: ProfileV3Strings.appAccessAddNew, action: model.tapAddNew)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        }
    }
}

struct ProfileV3AppAccessContent: View {
    @ObservedObject var model: ProfileV3AppAccessModel
    let showsConnected: Bool
    let onBack: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.AppAccess
    private typealias Access = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3AccessPageHeader(
                showsConnected: showsConnected,
                onBack: onBack,
                onConnected: model.tapConnected
            ) {
                if model.showsConnectedHint {
                    ProfileV3ConnectedAppsHint(text: ProfileV3Strings.appAccessConnectedHint, onTap: model.dismissHint)
                        .padding(.top, Layout.hintTop)
                        .offset(x: ProfileV3Theme.Sizes.screenHorizontalMargin - Layout.hintTrailing)
                        .transition(.opacity)
                }
            }
            .zIndex(1)
            ProfileV3AccessHeading(
                title: ProfileV3Strings.appAccess,
                subtitle: ProfileV3Strings.informationAccessSubtitle
            )
            apps
                .padding(.top, Layout.listTop)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.bottom, Layout.listBottom)
        .profileV3AccessPageGlow()
        .animation(ProfileV3Theme.Motion.selection, value: model.showsConnectedHint)
    }

    @ViewBuilder
    private var apps: some View {
        if model.phase == .loaded {
            VStack(spacing: Access.cardSpacing) {
                ForEach(model.autoConnected) { app in
                    ProfileV3ConnectedAppRow(
                        iconURL: app.iconURL,
                        title: app.name,
                        status: ProfileV3Strings.appAccessAutoConnected
                    )
                }
                ForEach(model.listedConnectedApps) { app in
                    ProfileV3ConnectedAppRow(
                        iconURL: app.iconURL,
                        title: app.handle ?? app.name,
                        status: ProfileV3Strings.connectorConnected
                    )
                }
                ForEach(model.pendingApps) { app in
                    ProfileV3AppAccessRow(
                        app: app,
                        onAdd: { model.tapAddCredentials(app) },
                        onEdit: { model.tapEditHandle(app) }
                    )
                }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        } else {
            ProfileV3LoadStateView(phase: model.phase, retry: model.load)
                .frame(height: Access.loadStateHeight)
        }
    }
}

private struct ProfileV3AppAccessRow: View {
    let app: ProfileV3LinkedApp
    let onAdd: () -> Void
    let onEdit: () -> Void

    private typealias Access = ProfileV3Theme.Sizes.InformationAccess
    private typealias Layout = ProfileV3Theme.Sizes.AppAccess

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProfileV3ConnectorCardTitle(
                icon: ATIcon.SwiftUIImage.globe,
                iconURL: app.iconURL,
                isIconRound: true,
                title: title,
                accessory: {
                    ProfileV3ConnectorAction(
                        title: actionTitle,
                        action: onAdd,
                        style: app.isAwaitingMessage ? .B1InterSemibold14 : .H7InterSemibold16
                    )
                },
                onEdit: app.isAwaitingMessage ? onEdit : nil
            )
            if app.isAwaitingMessage {
                messagePrompt
            }
        }
        .frame(minHeight: Access.cardHeight, alignment: .top)
        .fixedSize(horizontal: false, vertical: true)
        .profileV3AccessCard(cornerRadius: Access.cardRadius)
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: actionTitle, onAdd)
        .accessibilityActions {
            if app.isAwaitingMessage {
                Button(ProfileV3Strings.editConnector, action: onEdit)
            }
        }
    }

    private var messagePrompt: some View {
        VStack(alignment: .leading, spacing: Layout.messagePromptSpacing) {
            Text(ProfileV3Strings.instagramGetToKnow)
                .typoGraphy(.B1InterSemibold14)
                .foregroundStyle(Color(at: .pureBlack))
                .padding(.vertical, TypographyStyle.B1InterSemibold14.lineSpacingAdjustment / 2)
            Text(ProfileV3Strings.instagramGetToKnowDetail)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.accessSubtitle))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, TypographyStyle.B2InterMedium12.lineSpacingAdjustment / 2)
                .frame(maxWidth: Layout.messagePromptBodyWidth, alignment: .leading)
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, Access.cardLeading)
        .padding(.trailing, Access.cardTrailing)
        .padding(.top, Layout.messagePromptTop)
        .padding(.bottom, Layout.messagePromptBottom)
    }

    private var title: String {
        app.isAwaitingMessage ? app.handle ?? app.name : app.name
    }

    private var actionTitle: String {
        if app.isAwaitingMessage { return ProfileV3Strings.instagramSendMessage }
        return app.asksForUsernameOnly ? ProfileV3Strings.appAccessAddUsername : ProfileV3Strings.appAccessAddCredentials
    }
}

private struct ProfileV3ConnectedAppRow: View {
    let iconURL: URL?
    let title: String
    let status: String

    private typealias Access = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        ProfileV3ConnectorCardTitle(
            icon: ATIcon.SwiftUIImage.globe,
            iconURL: iconURL,
            isIconRound: true,
            title: title
        ) {
            Text(status)
                .typoGraphy(.H7InterSemibold16)
                .textCase(.lowercase)
                .foregroundStyle(Color(at: .accentEmerald600))
        }
        .frame(height: Access.cardHeight, alignment: .top)
        .profileV3AccessCard(cornerRadius: Access.cardRadius)
        .accessibilityElement(children: .combine)
    }
}

struct ProfileV3AppAccessComingSoonView: View {
    let onBack: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        VStack(spacing: 0) {
            ProfileV3BackTagHeader(
                title: ProfileV3Strings.appAccess,
                top: ProfileV3Theme.Sizes.SettingsPage.headerTop,
                onBack: onBack
            )
            ProfileV3RemoteImage(url: ProfileV3ConnectorArt.appAccess.url, contentMode: .fit, placeholder: .clear)
                .frame(
                    width: ProfileV3Theme.Sizes.SettingsPage.appArtSize.width,
                    height: ProfileV3Theme.Sizes.SettingsPage.appArtSize.height
                )
                .background { ProfileV3AccessGlow() }
                .padding(.top, Layout.comingSoonArtTop)
                .accessibilityHidden(true)
            ProfileV3ComingSoonCopy(message: ProfileV3Strings.appAccessComingSoon)
                .padding(.top, Layout.comingSoonTitleTop)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite))
    }
}

#if DEBUG
private struct ProfileV3AppAccessPreview: View {
    @StateObject private var model = ProfileV3AppAccessModel(repository: ProfileV3MockRepository())

    var body: some View {
        ProfileV3AppAccessView(model: model, onBack: {})
            .task { model.load() }
    }
}

#Preview("App access") {
    ProfileV3AppAccessPreview()
}

#Preview("App access · coming soon") {
    ProfileV3AppAccessComingSoonView(onBack: {})
}
#endif
