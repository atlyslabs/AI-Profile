import ATUIKit
import SwiftUI

struct ProfileV3ConnectorDeckView: View {
    let entries: [ProfileV3ConnectorDeckEntry]
    let confirm: ProfileV3DisconnectConfirm?
    let onBack: () -> Void
    let onEngage: ((ProfileV3ConnectorDeckEntry) -> Void)?
    let onDisconnect: ((ProfileV3ConnectorDeckEntry) -> Void)?
    let onEdit: ((ProfileV3ConnectorDeckEntry) -> Void)?

    @State private var armedEntry: ProfileV3ConnectorDeckEntry?
    @State private var width: CGFloat = 0

    init(
        entries: [ProfileV3ConnectorDeckEntry],
        confirm: ProfileV3DisconnectConfirm? = nil,
        initialArmedEntry: ProfileV3ConnectorDeckEntry? = nil,
        onBack: @escaping () -> Void,
        onEngage: ((ProfileV3ConnectorDeckEntry) -> Void)? = nil,
        onDisconnect: ((ProfileV3ConnectorDeckEntry) -> Void)? = nil,
        onEdit: ((ProfileV3ConnectorDeckEntry) -> Void)? = nil
    ) {
        self.entries = entries
        self.confirm = confirm
        self.onBack = onBack
        self.onEngage = onEngage
        self.onDisconnect = onDisconnect
        self.onEdit = onEdit
        _armedEntry = State(initialValue: initialArmedEntry)
    }

    private typealias Deck = ProfileV3Theme.Sizes.ConnectorDeck

    private var canvasScale: CGFloat { ProfileV3Theme.Canvas.scale(for: width) }

    private var deckInset: CGFloat {
        max(
            (width - Deck.cardWidth * canvasScale) / 2,
            ProfileV3Theme.Sizes.screenHorizontalMargin * canvasScale
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Deck.cardSpacing * canvasScale) {
                    ForEach(entries) { entry in
                        ProfileV3ConnectorDeckCard(
                            entry: entry,
                            confirm: entry.isApp ? nil : confirm,
                            initiallyArmed: entry == armedEntry,
                            onEngaged: { onEngage?(entry) },
                            onArmed: { armedEntry = entry },
                            onEdit: entry.isApp ? onEdit.map { edit in { edit(entry) } } : nil
                        )
                        .scaleEffect(canvasScale)
                        .frame(
                            width: Deck.cardWidth * canvasScale,
                            height: Deck.cardHeight * canvasScale
                        )
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, deckInset, for: .scrollContent)
            .padding(.top, (Deck.deckTop - Deck.headerTitleTop - ProfileV3Theme.Space.s16) * canvasScale)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .background(Color(at: .pureWhite).ignoresSafeArea())
        .overlay(alignment: .bottom) {
            ProfileV3Theme.clearToWhiteFade
                .frame(height: Deck.bottomFade)
                .allowsHitTesting(false)
                .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .bottom) {
            if let armedEntry, let title = disconnectTitle(for: armedEntry) {
                ProfileV3ContinueButton(
                    title: title,
                    icon: ATIcon.SwiftUIImage.callSplit,
                    iconSize: ProfileV3Theme.Icon.lg,
                    tint: ProfileV3Theme.Palette.destructive
                ) { onDisconnect?(armedEntry) }
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.bottom, Deck.disconnectBottom)
                .transition(.opacity)
            }
        }
        .animation(ProfileV3Theme.Motion.connectorDeckDim, value: armedEntry)
    }

    private func disconnectTitle(for entry: ProfileV3ConnectorDeckEntry) -> String? {
        entry.isApp ? ProfileV3Strings.disconnectApp : confirm?.confirmTitle.nonEmpty
    }

    private var header: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ATIcon.SwiftUIImage.database
                    .profileV3Icon(ProfileV3Theme.Icon.xl)
                    .foregroundStyle(Color(at: .pureBlack))
                Text(ProfileV3Strings.connectors)
                    .typoGraphy(.T1InterBold11)
                    .textCase(.uppercase)
                    .foregroundStyle(Color(at: .pureBlack))
                    .padding(.top, ProfileV3Theme.Space.s16)
            }
            .padding(.top, Deck.headerIconTop)
            HStack {
                ProfileV3CircleIconButton.back(action: onBack)
                Spacer()
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.top, ProfileV3Theme.Sizes.screenHorizontalMargin)
        }
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
extension ProfileV3ConnectorDeckEntry {
    static let previews: [ProfileV3ConnectorDeckEntry] = [
        ProfileV3ConnectorDeckEntry(
            id: "gmail",
            headline: "Atlys x Gmail",
            account: "ru***g@gmail.com",
            blurb: "Your travel details, bookings and updates are already there. Connecting email "
                + "helps the agent understand and act on them without asking you to find or share "
                + "everything manually.",
            hint: ProfileV3Strings.connectorDeckHint,
            icon: .remote(ProfileV3ConnectorArt.gmail.url)
        ),
        ProfileV3ConnectorDeckEntry(
            id: "itr",
            headline: "Atlys x ITR",
            account: "AAAPZ***1C",
            blurb: "Your filings confirm income and travel history, so the agent can prefill "
                + "applications without asking you to dig up documents.",
            hint: ProfileV3Strings.connectorDeckHint,
            icon: .contract
        )
    ]
}

#Preview("Connector deck") {
    ProfileV3ConnectorDeckView(entries: ProfileV3ConnectorDeckEntry.previews, onBack: {})
}

#Preview("Connector deck · armed") {
    ProfileV3ConnectorDeckView(
        entries: ProfileV3ConnectorDeckEntry.previews,
        confirm: ProfileV3Fixtures.disconnectConfirm(.gmail),
        initialArmedEntry: ProfileV3ConnectorDeckEntry.previews.first,
        onBack: {}
    )
}
#endif
