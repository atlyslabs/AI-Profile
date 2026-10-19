import ATUIKit
import SwiftUI

struct ProfileV3InformationAccessView: View {
    @ObservedObject var model: ProfileV3ConnectorsSettingsModel
    let onBack: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ProfileV3AccessPageHeader(
                    showsConnected: model.canOpenControlPanel,
                    onBack: onBack,
                    onConnected: model.openControlPanel
                )
                ProfileV3InformationAccessHero()
                    .padding(.top, Layout.heroTop)
                Text(ProfileV3Strings.informationAccess)
                    .typoGraphy(.H5InterMedium20)
                    .foregroundStyle(Color(at: .pureBlack))
                    .frame(maxWidth: Layout.titleWidth)
                    .padding(.top, Layout.titleTop)
                Text(ProfileV3Strings.informationAccessSubtitle)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .pureBlack).opacity(ProfileV3Theme.Opacity.accessSubtitle))
                    .frame(maxWidth: Layout.titleWidth)
                    .padding(.top, Layout.subtitleTop)
                cards
                    .padding(.top, Layout.cardsTop)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.bottom, Layout.bottom)
            .background(alignment: .top) {
                ProfileV3AccessGlow()
                    .offset(y: Layout.glowCentreY - Layout.glow / 2)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(at: .pureWhite))
        .sensoryFeedback(.success, trigger: model.disconnectCompletions)
    }

    @ViewBuilder
    private var cards: some View {
        if model.phase == .loaded {
            VStack(spacing: Layout.cardSpacing) {
                ForEach(model.connectors) { connector in
                    if connector.id == ProfileV3ConnectorKey.gmail.rawValue {
                        ProfileV3EmailConnectorCard(
                            connector: connector,
                            onAdd: addAction,
                            onConnect: { model.tapConnect(connector) }
                        )
                    } else {
                        ProfileV3ConnectorCardRow(connector: connector, onConnect: { model.tapConnect(connector) })
                    }
                }
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        } else {
            ProfileV3LoadStateView(phase: model.phase, retry: model.load)
                .frame(height: Layout.loadStateHeight)
        }
    }

    private var addAction: (() -> Void)? {
        guard ProfileV3FeatureFlags.isConnectOtherEmailsEnabled else { return nil }
        return model.tapConnectEmails
    }
}

struct ProfileV3AccessPageHeader<Hint: View>: View {
    let showsConnected: Bool
    let onBack: () -> Void
    let onConnected: () -> Void
    @ViewBuilder var hint: () -> Hint

    var body: some View {
        HStack {
            ProfileV3CircleIconButton.back(action: onBack)
            Spacer()
            if showsConnected {
                Button(action: onConnected) {
                    HStack(spacing: ProfileV3Theme.Space.s8) {
                        ProfileV3TagLabel(text: ProfileV3Strings.connectorConnected)
                        ATIcon.SwiftUIImage.chevronRight
                            .profileV3Icon(ProfileV3Theme.Icon.xl)
                            .foregroundStyle(Color(at: .pureBlack))
                    }
                    .frame(minHeight: ProfileV3Theme.Control.tapTarget)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.profileV3Pressable)
                .accessibilityLabel(ProfileV3Strings.connectorConnected)
            }
        }
        .overlay(alignment: .topTrailing) {
            if showsConnected {
                hint()
            }
        }
        .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
        .padding(.top, ProfileV3Theme.Sizes.SettingsPage.headerTop)
    }
}

extension ProfileV3AccessPageHeader where Hint == EmptyView {
    init(showsConnected: Bool, onBack: @escaping () -> Void, onConnected: @escaping () -> Void) {
        self.init(showsConnected: showsConnected, onBack: onBack, onConnected: onConnected) { EmptyView() }
    }
}

private struct ProfileV3EmailConnectorCard: View {
    let connector: ProfileV3Connector
    var onAdd: (() -> Void)?
    let onConnect: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.InformationAccess

    private var isConnected: Bool { connector.status == .connected }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProfileV3ConnectorCardTitle(icon: ATIcon.SwiftUIImage.mail, title: ProfileV3Strings.emailConnector) {
                if isConnected {
                    if let onAdd {
                        ProfileV3ConnectorAction(title: ProfileV3Strings.addEmail, action: onAdd)
                    }
                } else {
                    ProfileV3ConnectorAction(
                        title: ProfileV3Strings.connectConnector,
                        action: connector.captureStep == nil ? nil : onConnect
                    )
                }
            }
            if isConnected {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Layout.chipSpacing) {
                        ProfileV3ConnectedEmailChip(address: connector.accountEmail ?? connector.name)
                    }
                }
                .contentMargins(.horizontal, Layout.cardLeading, for: .scrollContent)
                .padding(.top, Layout.chipsTop)
                .padding(.bottom, Layout.chipsBottom)
            }
        }
        .frame(minHeight: Layout.cardHeight, alignment: .top)
        .profileV3SettingsCard(cornerRadius: Layout.cardRadius)
        .accessibilityElement(children: .contain)
        .accessibilityValue(connector.status.accessibilityValue)
    }
}

private struct ProfileV3ConnectorCardRow: View {
    let connector: ProfileV3Connector
    let onConnect: () -> Void

    var body: some View {
        ProfileV3ConnectorCardTitle(icon: icon, iconURL: iconURL, title: connector.name) {
            if connector.status == .connected {
                Text(ProfileV3Strings.connectorConnected)
                    .typoGraphy(.H7InterSemibold16)
                    .foregroundStyle(ProfileV3Theme.Palette.accessChipText)
            } else {
                ProfileV3ConnectorAction(
                    title: ProfileV3Strings.connectConnector,
                    action: connector.captureStep == nil ? nil : onConnect
                )
            }
        }
        .frame(height: ProfileV3Theme.Sizes.InformationAccess.cardHeight, alignment: .top)
        .profileV3SettingsCard(cornerRadius: ProfileV3Theme.Sizes.InformationAccess.cardRadius)
        .accessibilityElement(children: .combine)
        .accessibilityValue(connector.status.accessibilityValue)
    }

    private var icon: Image {
        switch connector.icon {
        case .contract: return ATIcon.SwiftUIImage.description
        case .remote: return ATIcon.SwiftUIImage.plugConnect
        }
    }

    private var iconURL: URL? {
        guard case .remote(let url) = connector.icon else { return nil }
        return url
    }
}

struct ProfileV3ConnectorCardTitle<Accessory: View>: View {
    let icon: Image
    var iconURL: URL?
    var isIconRound = false
    let title: String
    @ViewBuilder var accessory: () -> Accessory

    private typealias Layout = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        HStack(spacing: ProfileV3Theme.Space.s12) {
            if let iconURL, isIconRound {
                ProfileV3RemoteImage(url: iconURL, contentMode: .fill, placeholder: .clear)
                    .frame(width: Layout.cardIcon, height: Layout.cardIcon)
                    .clipShape(Circle())
            } else if let iconURL {
                ProfileV3RemoteImage(url: iconURL, contentMode: .fit, placeholder: .clear)
                    .frame(width: Layout.cardIcon, height: Layout.cardIcon)
            } else {
                icon
                    .profileV3Icon(Layout.cardIcon)
                    .foregroundStyle(Color(at: .pureBlack))
            }
            Text(title)
                .typoGraphy(.H7InterMedium16)
                .foregroundStyle(Color(at: .pureBlack))
                .lineLimit(1)
            Spacer(minLength: ProfileV3Theme.Space.s8)
            accessory()
        }
        .padding(.leading, Layout.cardLeading)
        .padding(.trailing, Layout.cardTrailing)
        .padding(.top, Layout.cardTop)
    }
}

struct ProfileV3ConnectorAction: View {
    let title: String
    let action: (() -> Void)?

    var body: some View {
        Button(action: { action?() }) {
            Text(title)
                .typoGraphy(.H7InterSemibold16)
                .foregroundStyle(ProfileV3Theme.Palette.accessAction)
                .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable)
        .disabled(action == nil)
        .opacity(action == nil ? ProfileV3Theme.Motion.disabledOpacity : 1)
        .accessibilityLabel(title)
    }
}

private struct ProfileV3ConnectedEmailChip: View {
    let address: String

    private typealias Layout = ProfileV3Theme.Sizes.InformationAccess

    var body: some View {
        HStack(spacing: Layout.chipGap) {
            ProfileV3RemoteImage(url: ProfileV3ConnectorArt.gmail.url, contentMode: .fit, placeholder: .clear)
                .frame(width: Layout.chipLogo, height: Layout.chipLogo)
                .clipShape(Circle())
            Text(address)
                .typoGraphy(.B1InterSemibold14)
                .foregroundStyle(ProfileV3Theme.Palette.accessChipText)
                .lineLimit(1)
        }
        .padding(.leading, Layout.chipPadding)
        .padding(.trailing, Layout.chipTrailing)
        .padding(.vertical, Layout.chipPadding)
        .background(Capsule().fill(Color(at: .pureWhite)))
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
private struct ProfileV3InformationAccessPreview: View {
    @StateObject private var model = ProfileV3ConnectorsSettingsModel(repository: ProfileV3MockRepository())

    var body: some View {
        ProfileV3InformationAccessView(model: model, onBack: {})
            .task { model.load() }
    }
}

#Preview("Information access") {
    ProfileV3InformationAccessPreview()
}
#endif
