import ATUIKit
import SwiftUI

struct ProfileV3AppAccessView: View {
    @ObservedObject var model: ProfileV3AppAccessModel
    @ObservedObject var connectors: ProfileV3ConnectorsSettingsModel
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
                    ProfileV3AutoConnectedRow(app: app)
                }
                ForEach(model.pendingApps) { app in
                    ProfileV3AppAccessRow(app: app) { model.tapAddCredentials(app) }
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

    private typealias Access = ProfileV3Theme.Sizes.InformationAccess
    private typealias Layout = ProfileV3Theme.Sizes.AppAccess

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProfileV3ConnectorCardTitle(
                icon: ATIcon.SwiftUIImage.globe,
                iconURL: app.iconURL,
                isIconRound: true,
                title: title
            ) {
                ProfileV3ConnectorAction(
                    title: actionTitle,
                    action: onAdd,
                    style: app.isAwaitingMessage ? .B1InterSemibold14 : .H7InterSemibold16
                )
            }
            if app.isAwaitingMessage {
                messagePrompt
            }
        }
        .frame(minHeight: Access.cardHeight, alignment: .top)
        .fixedSize(horizontal: false, vertical: true)
        .profileV3AccessCard(cornerRadius: Access.cardRadius)
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: actionTitle, onAdd)
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
        guard app.isAwaitingMessage, let username = app.username else { return app.name }
        return "@" + username
    }

    private var actionTitle: String {
        if app.isAwaitingMessage { return ProfileV3Strings.instagramSendMessage }
        return app.asksForUsernameOnly ? ProfileV3Strings.appAccessAddUsername : ProfileV3Strings.appAccessAddCredentials
    }
}

private struct ProfileV3AutoConnectedRow: View {
    let app: ProfileV3AutoConnectedApp

    private typealias Access = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        ProfileV3ConnectorCardTitle(
            icon: ATIcon.SwiftUIImage.globe,
            iconURL: app.iconURL,
            isIconRound: true,
            title: app.name
        ) {
            Text(ProfileV3Strings.appAccessAutoConnected)
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
    @StateObject private var connectors: ProfileV3ConnectorsSettingsModel
    @StateObject private var model: ProfileV3AppAccessModel

    init() {
        let repository = ProfileV3MockRepository()
        let connectors = ProfileV3ConnectorsSettingsModel(repository: repository)
        _connectors = StateObject(wrappedValue: connectors)
        _model = StateObject(wrappedValue: ProfileV3AppAccessModel(repository: repository, connectors: connectors))
    }

    var body: some View {
        ProfileV3AppAccessView(model: model, connectors: connectors, onBack: {})
            .task {
                model.load()
                connectors.load()
            }
    }
}

#Preview("App access") {
    ProfileV3AppAccessPreview()
}

#Preview("App access · coming soon") {
    ProfileV3AppAccessComingSoonView(onBack: {})
}
#endif
