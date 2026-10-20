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
            title: text(dto.title) ?? "",
            cards: dto.cards.compactMap(card)
        )
    }

    private static func card(_ dto: ProfileV3ConnectorCardDTO) -> ProfileV3ConnectorCard? {
        guard let key = connectorKey(dto.key) else { return nil }
        return ProfileV3ConnectorCard(
            key: key,
            headline: text(dto.headline) ?? "",
            body: text(dto.body) ?? "",
            isConnected: dto.connected ?? false,
            disconnectHint: text(dto.disconnectHint) ?? "",
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
        return ProfileV3DisconnectConfirm(
            connector: connectorKey(dto.connector) ?? fallback,
            title: text(dto.title) ?? "",
            warning: text(dto.warning) ?? "",
            losses: dto.losses.compactMap { text($0.label) },
            detailIntro: text(dto.detailIntro) ?? "",
            detailLosses: dto.detailLosses.compactMap(text),
            detailParagraphs: dto.detailParagraphs.compactMap(text),
            consentLabel: text(dto.consent?.label) ?? "",
            isConsentRequired: dto.consent?.required ?? true,
            confirmTitle: text(confirm?.label) ?? "",
            cancelTitle: text(cancel?.label) ?? ""
        )
    }

    private static func connector(_ dto: ProfileV3ConnectorRowDTO) -> ProfileV3Connector? {
        guard let key = connectorKey(dto.key) else { return nil }
        return ProfileV3Connector(
            id: key.rawValue,
            name: text(dto.label) ?? "",
            icon: remoteURL(dto.imageURL).map { ProfileV3ConnectorIcon.remote($0) } ?? icon(for: key),
            status: (dto.connected ?? false) ? .connected : .needsAttention,
            accountEmail: text(dto.accountEmail)
        )
    }

    static func icon(for key: ProfileV3ConnectorKey) -> ProfileV3ConnectorIcon {
        switch key {
        case .gmail: return .remote(ProfileV3ConnectorArt.gmail.url)
        case .itr: return .contract
        }
    }

    private static func connectorKey(_ raw: String?) -> ProfileV3ConnectorKey? {
        guard let raw else { return nil }
        let normalised = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return ProfileV3ConnectorKey(rawValue: normalised)
    }
}
