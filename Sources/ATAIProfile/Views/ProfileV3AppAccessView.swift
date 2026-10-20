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
            if model.phase == .loaded {
                addNewBar
            }
        }
        .sheet(item: editor) { editor in
            ProfileV3AppCredentialsView(viewModel: editor, onClose: model.closeEditor)
        }
        .sensoryFeedback(.success, trigger: model.disconnectCompletions)
    }

    private var editor: Binding<ProfileV3AppCredentialsViewModel?> {
        Binding(get: { model.editor(from: .page) }, set: { if $0 == nil { model.closeEditor() } })
    }

    private var addNewBar: some View {
        ZStack(alignment: .bottom) {
            ProfileV3SaveBarFade()
            ProfileV3ContinueButton(title: ProfileV3Strings.appAccessAddNew, action: model.tapAddNew)
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.bottom, ProfileV3Theme.Sizes.Save.barBottom)
        }
    }
}

struct ProfileV3AppAccessContent: View {
    @ObservedObject var model: ProfileV3AppAccessModel
    let showsConnected: Bool
    let onBack: () -> Void
    var scrollsCarousel = true

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
            ProfileV3InformationAccessHero()
                .padding(.top, Access.heroTop)
            Text(ProfileV3Strings.appAccess)
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .frame(maxWidth: Access.titleWidth)
                .padding(.top, Access.titleTop)
                .accessibilityAddTraits(.isHeader)
            Text(ProfileV3Strings.informationAccessSubtitle)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.accessSubtitle))
                .frame(maxWidth: Access.titleWidth)
                .padding(.top, Access.subtitleTop)
            apps
                .padding(.top, model.autoConnected.isEmpty ? Access.cardsTop : Layout.contentTop)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.bottom, Layout.listBottom)
        .background(alignment: .top) {
            ProfileV3AccessGlow()
                .offset(y: Access.glowCentreY - Access.glow / 2)
        }
        .animation(ProfileV3Theme.Motion.selection, value: model.showsConnectedHint)
    }

    @ViewBuilder
    private var apps: some View {
        if model.phase == .loaded {
            VStack(spacing: 0) {
                if !model.autoConnected.isEmpty {
                    autoConnected
                    ProfileV3DashedDivider()
                        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                        .padding(.vertical, Layout.dividerGap)
                }
                VStack(spacing: Access.cardSpacing) {
                    ForEach(model.pendingApps) { app in
                        ProfileV3AppAccessRow(app: app) { model.tapAddCredentials(app) }
                    }
                }
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            }
        } else {
            ProfileV3LoadStateView(phase: model.phase, retry: model.load)
                .frame(height: Access.loadStateHeight)
        }
    }

    @ViewBuilder
    private var autoConnected: some View {
        if scrollsCarousel {
            ScrollView(.horizontal, showsIndicators: false) {
                autoConnectedCards
            }
            .contentMargins(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin, for: .scrollContent)
        } else {
            autoConnectedCards
                .padding(.leading, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipped()
        }
    }

    private var autoConnectedCards: some View {
        HStack(spacing: Layout.autoCardSpacing) {
            ForEach(model.autoConnected) { app in
                ProfileV3AutoConnectedCard(app: app)
            }
        }
    }
}

private struct ProfileV3AppAccessRow: View {
    let app: ProfileV3LinkedApp
    let onAdd: () -> Void

    private typealias Access = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        ProfileV3ConnectorCardTitle(
            icon: ATIcon.SwiftUIImage.globe,
            iconURL: app.iconURL,
            isIconRound: true,
            title: app.name
        ) {
            ProfileV3ConnectorAction(title: ProfileV3Strings.appAccessAddCredentials, action: onAdd)
        }
        .frame(height: Access.cardHeight, alignment: .top)
        .profileV3SettingsCard(cornerRadius: Access.cardRadius)
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: ProfileV3Strings.appAccessAddCredentials, onAdd)
    }
}

private struct ProfileV3AutoConnectedCard: View {
    let app: ProfileV3AutoConnectedApp

    private typealias Layout = ProfileV3Theme.Sizes.AppAccess

    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(app.name)
                .typoGraphy(.H7InterMedium16)
                .foregroundStyle(Color(at: .pureBlack))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .frame(width: Layout.autoCardNameWidth, alignment: .leading)
                .padding(.leading, Layout.autoCardLeading)
                .padding(.top, Layout.autoCardNameTop)
            Text(ProfileV3Strings.appAccessAutoConnected)
                .typoGraphy(.T1InterBold11)
                .textCase(.uppercase)
                .foregroundStyle(ProfileV3Theme.autoConnectedGradient)
                .opacity(ProfileV3Theme.Opacity.autoConnectedStatus)
                .padding(.leading, Layout.autoCardLeading)
                .padding(.top, Layout.autoCardStatusTop)
            ProfileV3AppLogo(url: app.iconURL, size: Layout.logo)
                .padding(.top, Layout.autoCardLogoTop)
                .padding(.trailing, Layout.autoCardLogoTrailing)
                .frame(maxWidth: .infinity, alignment: .topTrailing)
        }
        .frame(width: Layout.autoCard.width, height: Layout.autoCard.height, alignment: .topLeading)
        .profileV3SettingsCard(cornerRadius: ProfileV3Theme.Sizes.InformationAccess.cardRadius)
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
            Text(ProfileV3Strings.comingSoon)
                .typoGraphy(.H5InterMedium20)
                .foregroundStyle(Color(at: .pureBlack))
                .padding(.top, Layout.comingSoonTitleTop)
            Text(ProfileV3Strings.appAccessComingSoon)
                .typoGraphy(.B2InterMedium12)
                .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.accessSubtitle))
                .frame(maxWidth: Layout.comingSoonBodyWidth)
                .padding(.top, Layout.subtitleTop)
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
