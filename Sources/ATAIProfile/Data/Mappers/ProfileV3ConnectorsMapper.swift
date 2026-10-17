import Foundation

enum ProfileV3ConnectorsMapper: ProfileV3DTOReading {
    static func screen(_ dto: ProfileV3ConnectorsScreenDTO) -> ProfileV3ConnectorsScreen {
        ProfileV3ConnectorsScreen(
            title: dto.title ?? "",
            blurb: dto.blurb ?? "",
            connectors: dto.connectors.compactMap(connector),
            controlPanel: dto.controlPanel?.next.directive
        )
    }

    static func controlPanel(_ dto: ProfileV3ConnectorControlPanelScreenDTO) -> ProfileV3ConnectorControlPanel {
        ProfileV3ConnectorControlPanel(
            title: text(dto.title) ?? ProfileV3Strings.connectors,
            cards: dto.cards.compactMap(card)
        )
    }

    private static func card(_ dto: ProfileV3ConnectorCardDTO) -> ProfileV3ConnectorCard? {
        guard let key = connectorKey(dto.key) else { return nil }
        return ProfileV3ConnectorCard(
            key: key,
            headline: text(dto.headline) ?? ProfileV3Strings.connectorDeckTitle(displayName(for: key)),
            body: text(dto.body) ?? "",
            isConnected: dto.connected ?? false,
            disconnectHint: text(dto.disconnectHint) ?? ProfileV3Strings.connectorDeckHint,
            connectLabel: text(dto.connect?.label),
            accountEmail: text(dto.accountEmail),
            iconURL: remoteURL(dto.imageURL)
        )
    }

    static func disconnectConfirm(
        _ dto: ProfileV3DisconnectConfirmScreenDTO,
        fallback: ProfileV3ConnectorKey
    ) -> ProfileV3DisconnectConfirm {
        let actions = dto.actions
        let confirm = actions.first { $0.action == "disconnect_connector" }
            ?? actions.first { $0.style == "danger" }
        let cancel = actions.first { $0.next?.directive.go == "back" }
            ?? actions.first { $0.key != confirm?.key }
        let losses = dto.losses.compactMap { text($0.label) }
        let detailLosses = dto.detailLosses.compactMap(text)
        let detailParagraphs = dto.detailParagraphs.compactMap(text)
        return ProfileV3DisconnectConfirm(
            connector: connectorKey(dto.connector) ?? fallback,
            title: text(dto.title) ?? ProfileV3Strings.disconnectConfirmTitle,
            warning: text(dto.warning) ?? ProfileV3Strings.disconnectConfirmBody,
            losses: losses.isEmpty ? ProfileV3Strings.disconnectLosses : losses,
            detailIntro: text(dto.detailIntro) ?? ProfileV3Strings.disconnectTermsIntro,
            detailLosses: detailLosses.isEmpty ? ProfileV3Strings.disconnectTermsItems : detailLosses,
            detailParagraphs: detailParagraphs.isEmpty
                ? ProfileV3Strings.disconnectTermsClosing
                : detailParagraphs,
            consentLabel: text(dto.consent?.label) ?? ProfileV3Strings.disconnectConsent,
            isConsentRequired: dto.consent?.required ?? true,
            confirmTitle: text(confirm?.label) ?? ProfileV3Strings.disconnectEmail,
            cancelTitle: text(cancel?.label) ?? ProfileV3Strings.dontDisconnect
        )
    }

    private static func connector(_ dto: ProfileV3ConnectorRowDTO) -> ProfileV3Connector? {
        guard let key = connectorKey(dto.key) else { return nil }
        return ProfileV3Connector(
            id: key.rawValue,
            name: name(text(dto.label), for: key),
            icon: remoteURL(dto.imageURL).map { ProfileV3ConnectorIcon.remote($0) } ?? icon(for: key),
            status: (dto.connected ?? false) ? .connected : .needsAttention,
            accountEmail: text(dto.accountEmail)
        )
    }

    private static func name(_ label: String?, for key: ProfileV3ConnectorKey) -> String {
        let canonical = displayName(for: key)
        guard let label, label.caseInsensitiveCompare(canonical) != .orderedSame else { return canonical }
        return label
    }

    static func displayName(for key: ProfileV3ConnectorKey) -> String {
        switch key {
        case .gmail: return ProfileV3Strings.gmailConnector
        case .itr: return ProfileV3Strings.itrConnector
        case .photos: return ProfileV3Strings.photosConnector
        }
    }

    static func icon(for key: ProfileV3ConnectorKey) -> ProfileV3ConnectorIcon {
        switch key {
        case .gmail: return .remote(ProfileV3ConnectorArt.gmail.url)
        case .itr: return .contract
        case .photos: return .remote(nil)
        }
    }

    private static func connectorKey(_ raw: String?) -> ProfileV3ConnectorKey? {
        guard let raw else { return nil }
        let normalised = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return ProfileV3ConnectorKey(rawValue: normalised)
    }
}
