import ATUIKit
import SwiftUI

struct ProfileV3SettingsView: View {
    @Bindable var viewModel: ProfileV3SettingsViewModel
    @State private var headerPin = ProfileV3HeaderPin()

    private typealias Layout = ProfileV3Theme.Sizes.SettingsPage

    var body: some View {
        NavigationStack(path: $viewModel.pagePath) {
            root
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: ProfileV3SettingsDestination.self) { destination in
                    destinationView(destination)
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                }
        }
        .overlay {
            ProfileV3CitizenshipLockLayer(fields: viewModel.fields)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private var root: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ProfileV3SettingsAvatar(initial: viewModel.monogram)
                        .padding(.top, Layout.headerTop + ProfileV3Theme.Sizes.circleButton + Layout.avatarTop)
                    if let menu = viewModel.menu, viewModel.menuPhase == .loaded {
                        panel(menu)
                            .padding(.top, Layout.cardsTop)
                    } else if viewModel.menuPhase == .failed {
                        failedPanel
                            .padding(.top, ProfileV3Theme.Sizes.ErrorState.cardTop)
                            .transition(.opacity)
                    } else {
                        ProfileV3LoadStateView(phase: viewModel.menuPhase, retry: viewModel.loadMenu)
                            .frame(height: Layout.loadStateHeight)
                    }
                }
                .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
                .padding(.bottom, Layout.bottom)
                .profileV3ScrollOffsetAnchor(headerOffset)
            }
            .profileV3ScrollOffset(headerOffset)
            ProfileV3SettingsPageHeader(title: viewModel.title, pin: headerPin, onBack: viewModel.tapBack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(at: .pureWhite))
        .background(alignment: .top) {
            if viewModel.menu != nil {
                ProfileV3SettingsPremeasure(
                    viewModel: viewModel,
                    permissions: viewModel.permissions,
                    account: viewModel.account
                )
            }
        }
        .onAppear {
            viewModel.loadMenuIfNeeded()
            viewModel.loadMonogramIfNeeded()
            viewModel.loadGloveBoxStatusIfNeeded()
        }
        .profileV3CredentialStore(viewModel.credentialStore)
        .fullScreenCover(isPresented: $viewModel.isGloveBoxPresented, onDismiss: viewModel.gloveBoxDidClose) {
            if let repository = viewModel.gloveBoxRepository {
                ProfileV3GloveBoxLiveFlow(repository: repository) { viewModel.isGloveBoxPresented = false }
            }
        }
    }

    private var headerOffset: Binding<CGFloat> {
        Binding(get: { headerPin.offset }, set: { headerPin.offset = $0 })
    }

    private func panel(_ menu: ProfileV3SettingsMenu) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: Layout.cardSpacing) {
                if viewModel.hasGloveBox {
                    ProfileV3SettingsGloveBoxCard(
                        showsActivate: viewModel.showsGloveBoxActivate,
                        action: viewModel.tapGloveBox
                    )
                    .animation(ProfileV3Theme.Motion.contentSwitch, value: viewModel.showsGloveBoxActivate)
                }
                ProfileV3SettingsAccountsCard(
                    menu: menu,
                    fields: viewModel.fields,
                    isExpanded: $viewModel.isAccountExpanded,
                    onSelect: viewModel.tap
                )
                if let concierge = menu.concierge {
                    ProfileV3SettingsConciergeCard(concierge: concierge) { viewModel.tapConcierge(concierge) }
                }
                ProfileV3SettingsConnectorsCard(
                    onInformationAccess: viewModel.tapInformationAccess,
                    onAppAccess: viewModel.tapAppAccess
                )
                if ProfileV3FeatureFlags.isCredentialStoreEnabled {
                    ProfileV3CredentialStoreCard(action: viewModel.tapCredentialStore)
                        .padding(.top, ProfileV3Theme.Sizes.CredentialStore.cardTop)
                }
            }
            ProfileV3SettingsRowList(rows: menu.rows, account: viewModel.account, onSelect: viewModel.tap)
                .padding(.top, Layout.rowsTop)
            #if DEBUG
            ProfileV3SettingsDebugSection()
                .padding(.top, Layout.rowsTop)
            #endif
        }
    }

    private var failedPanel: some View {
        let shape = RoundedRectangle(cornerRadius: ProfileV3Theme.Sizes.ErrorState.cardRadius, style: .continuous)
        return VStack(alignment: .leading, spacing: 0) {
            ProfileV3ErrorState(action: viewModel.loadMenu)
                .padding(.top, ProfileV3Theme.Sizes.ErrorState.cardContentDrop)
                .frame(maxWidth: .infinity)
                .frame(height: ProfileV3Theme.Sizes.ErrorState.cardHeight)
                .background(shape.fill(Color(at: .backgroundLightTheme)))
                .overlay(
                    shape.strokeBorder(ProfileV3Theme.Palette.errorStateCardBorder, lineWidth: ProfileV3Theme.Stroke.hairline)
                )
                .profileV3FeedbackOnAppear(.error)
            ProfileV3SettingsRowList(rows: viewModel.failedMenuRows, account: viewModel.account, onSelect: viewModel.tap)
                .padding(.top, ProfileV3Theme.Sizes.ErrorState.rowsTop)
            #if DEBUG
            ProfileV3SettingsDebugSection()
                .padding(.top, Layout.rowsTop)
            #endif
        }
    }

    @ViewBuilder
    private func destinationView(_ destination: ProfileV3SettingsDestination) -> some View {
        switch destination {
        case .connectors:
            ProfileV3InformationAccessView(model: viewModel.connectors, onBack: viewModel.pop)
        case .appAccess:
            if ProfileV3FeatureFlags.isAppAccessEnabled {
                ProfileV3AppAccessView(model: viewModel.appAccess, connectors: viewModel.connectors, onBack: viewModel.pop)
            } else {
                ProfileV3AppAccessComingSoonView(onBack: viewModel.pop)
            }
        default:
            EmptyView()
        }
    }
}

private struct ProfileV3SettingsPremeasure: View {
    let viewModel: ProfileV3SettingsViewModel
    @ObservedObject var permissions: ProfileV3PermissionsSettingsModel
    @ObservedObject var account: ProfileV3AccountSettingsModel
    @State private var measured: Set<ProfileV3SettingsDestination> = []

    private var pending: [ProfileV3SettingsDestination] {
        ProfileV3SettingsDestination.premeasured.filter { destination in
            guard !measured.contains(destination) else { return false }
            switch destination {
            case .permissions: return permissions.permissions != nil
            case .deleteAccountConfirm: return account.deleteConfirm != nil
            default: return true
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            ForEach(pending, id: \.self) { destination in
                ProfileV3SettingsDestinationView(destination: destination, viewModel: viewModel)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                        guard height > 0 else { return }
                        viewModel.sheetHeights[destination] = height
                        measured.insert(destination)
                    }
            }
        }
        .opacity(0)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct ProfileV3SettingsPageHeader: View {
    let title: String
    let pin: ProfileV3HeaderPin
    let onBack: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.SettingsPage

    var body: some View {
        let progress = pin.progress
        ProfileV3BackTagHeader(title: title, top: Layout.headerTop, onBack: onBack)
            .padding(.bottom, Layout.headerBarBottom)
            .background(alignment: .bottom) {
                ProfileV3Theme.whiteToClearFade
                    .frame(height: Layout.headerFade)
                    .offset(y: Layout.headerFade)
                    .opacity(progress)
                    .allowsHitTesting(false)
            }
            .background {
                Color(at: .pureWhite)
                    .opacity(progress)
                    .allowsHitTesting(progress > 0)
                    .ignoresSafeArea(edges: .top)
            }
    }
}

private struct ProfileV3SettingsAvatar: View {
    let initial: String?

    private typealias Layout = ProfileV3Theme.Sizes.SettingsPage

    var body: some View {
        ZStack {
            Circle()
                .fill(ProfileV3Theme.Palette.settingsAvatar)
            ProfileV3RemoteImage(url: ProfileV3SettingsArt.avatarGlobe.url, contentMode: .fit, placeholder: .clear)
            if let initial {
                Text(initial)
                    .typoGraphy(.D2InterRegular40)
                    .foregroundStyle(Color(at: .pureWhite))
                    .offset(y: Layout.avatarLetterOffsetY)
            }
        }
        .frame(width: Layout.avatar, height: Layout.avatar)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}

private struct ProfileV3SettingsAccountsCard: View {
    let menu: ProfileV3SettingsMenu
    @ObservedObject var fields: ProfileV3ProfileFieldsModel
    @Binding var isExpanded: Bool
    let onSelect: (ProfileV3SettingsRowItem) -> Void

    var body: some View {
        ProfileV3ExpandableCard(
            icon: ATIcon.SwiftUIImage.person,
            title: menu.accountsLabel,
            subtitle: menu.accountsSubtitle,
            badgeURL: menu.accountsBadgeURL,
            isExpanded: $isExpanded
        ) {
            ForEach(menu.accountRows) { row in
                ProfileV3SettingsRow(
                    icon: row.icon,
                    title: row.label,
                    iconSize: ProfileV3Theme.Icon.md,
                    flag: flag(for: row),
                    lockNote: lockNote(for: row)
                ) {
                    onSelect(row)
                }
            }
        }
    }

    private func flag(for row: ProfileV3SettingsRowItem) -> ATCountry? {
        guard row.key == ProfileV3ProfileField.citizenship.rawValue,
              let code = fields.citizenshipIconCode else { return nil }
        return ATCountry(isoCode: code)
    }

    private func lockNote(for row: ProfileV3SettingsRowItem) -> String? {
        guard row.key == ProfileV3ProfileField.citizenship.rawValue, fields.isCitizenshipLocked else { return nil }
        return ProfileV3Strings.citizenshipFromPassport
    }
}

private struct ProfileV3SettingsConnectorsCard: View {
    let onInformationAccess: () -> Void
    let onAppAccess: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.SettingsPage

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProfileV3SettingsCardHeader(
                icon: ATIcon.SwiftUIImage.plugConnect,
                iconSize: ProfileV3Theme.Icon.lg,
                title: ProfileV3Strings.connectors,
                subtitle: ProfileV3Strings.connectorsSubtitle
            )
            VStack(spacing: Layout.accessCardSpacing) {
                ProfileV3SettingsAccessCard(
                    title: ProfileV3Strings.informationAccess,
                    blurb: ProfileV3Strings.informationAccessBlurb,
                    art: ProfileV3ConnectorArt.informationAccess.url,
                    artSize: Layout.informationArtSize,
                    artTrailing: Layout.informationArtTrailing,
                    action: onInformationAccess
                )
                ProfileV3SettingsAccessCard(
                    title: ProfileV3Strings.appAccess,
                    blurb: ProfileV3Strings.appAccessBlurb,
                    art: ProfileV3ConnectorArt.appAccess.url,
                    artSize: Layout.appArtSize,
                    artTrailing: Layout.appArtTrailing,
                    action: onAppAccess
                )
            }
            .padding(.horizontal, Layout.accessCardInset)
            .padding(.bottom, Layout.accessCardInset)
        }
        .profileV3SettingsCard()
    }
}

private struct ProfileV3SettingsAccessCard: View {
    let title: String
    let blurb: String
    let art: URL?
    let artSize: CGSize
    let artTrailing: CGFloat
    let action: () -> Void

    private typealias Layout = ProfileV3Theme.Sizes.SettingsPage

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Layout.accessCardRadius, style: .continuous)
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Layout.accessCardSubtitleTop) {
                Text(title)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(Color(at: .pureBlack))
                Text(blurb)
                    .typoGraphy(.B2InterMedium12)
                    .foregroundStyle(Color(at: .neutralGrey400))
                    .frame(width: Layout.accessCardTextWidth, alignment: .leading)
            }
            .multilineTextAlignment(.leading)
            .padding(.leading, Layout.accessCardTextLeading)
            .padding(.top, Layout.accessCardTitleTop)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .frame(height: Layout.accessCardHeight, alignment: .top)
            .overlay(alignment: .topTrailing) {
                ProfileV3RemoteImage(url: art, contentMode: .fit, placeholder: .clear)
                    .frame(width: artSize.width, height: artSize.height)
                    .padding(.top, Layout.accessArtTop)
                    .padding(.trailing, artTrailing)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .background(
                shape
                    .fill(Color(at: .pureWhite))
                    .shadow(
                        color: ProfileV3Theme.Palette.shadow,
                        radius: Layout.accessCardShadowRadius,
                        y: Layout.accessCardShadowY
                    )
            )
            .contentShape(shape)
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(title)
        .accessibilityHint(blurb)
    }
}

private struct ProfileV3SettingsRowList: View {
    let rows: [ProfileV3SettingsRowItem]
    @ObservedObject var account: ProfileV3AccountSettingsModel
    let onSelect: (ProfileV3SettingsRowItem) -> Void

    var body: some View {
        let dangerRows = rows.filter(\.isDanger)
        VStack(alignment: .leading, spacing: ProfileV3Theme.Sizes.SettingsPage.rowSpacing) {
            ForEach(rows.filter { !$0.isDanger }) { row in
                ProfileV3SettingsRow(icon: row.icon, title: row.label) { onSelect(row) }
            }
            if !dangerRows.isEmpty {
                ProfileV3DashedDivider()
                ForEach(dangerRows) { row in
                    dangerRow(row)
                }
            }
        }
    }

    private func dangerRow(_ row: ProfileV3SettingsRowItem) -> some View {
        let isLocked = account.isAccountDeletionRequested && row.route == .deleteAccount
        return ProfileV3SettingsRow(
            icon: row.icon,
            title: isLocked ? ProfileV3Strings.accountDeletionInRequest : row.label,
            iconSize: ProfileV3Theme.Sizes.SettingsPage.dangerIcon,
            tint: isLocked ? ProfileV3Theme.Palette.disabledText : ProfileV3Theme.Palette.destructive,
            showsChevron: !isLocked
        ) {
            onSelect(row)
        }
        .disabled(isLocked)
    }
}

private struct ProfileV3SettingsConciergeCard: View {
    let concierge: ProfileV3Concierge
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfileV3Theme.Space.s12) {
                ProfileV3ConnectorGlyph.reserveGlyph.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: ProfileV3Theme.Icon.lg, height: ProfileV3Theme.Icon.lg)
                Text(concierge.label)
                    .typoGraphy(.B1InterMedium14)
                    .foregroundStyle(Color(at: .pureBlack))
                Spacer(minLength: 0)
                ProfileV3Vector.whatsApp.image
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: ProfileV3Theme.Icon.lg, height: ProfileV3Theme.Icon.lg)
                ATIcon.SwiftUIImage.navigateNext
                    .profileV3Icon(ProfileV3Theme.Icon.lg)
                    .foregroundStyle(Color(at: .neutralGrey400))
            }
            .padding(.horizontal, ProfileV3Theme.Sizes.cardContentPadding)
            .frame(height: ProfileV3Theme.Sizes.Accounts.conciergeHeight)
            .frame(maxWidth: .infinity)
            .profileV3SettingsCard(cornerRadius: ProfileV3Theme.Radius.xl)
            .contentShape(Rectangle())
        }
        .buttonStyle(.profileV3Pressable)
        .accessibilityLabel(concierge.label)
    }
}

private struct ProfileV3CitizenshipLockLayer: View {
    @ObservedObject var fields: ProfileV3ProfileFieldsModel

    var body: some View {
        if let country = fields.passportCitizenship {
            ProfileV3CitizenshipLockOverlay(country: country, trigger: fields.citizenshipLockTrigger)
        }
    }
}

#if DEBUG
#Preview("Settings") {
    ProfileV3SettingsView(viewModel: .preview())
}

#Preview("Settings · loading") {
    ProfileV3SettingsView(viewModel: .preview(repository: ProfileV3MockRepository(delay: .seconds(60))))
}

#Preview("Settings · failed") {
    ProfileV3SettingsView(viewModel: .preview(repository: ProfileV3FailingRepository()))
}

#Preview("Settings · citizenship locked") {
    ProfileV3SettingsView(viewModel: .preview(repository: ProfileV3MockRepository(settingsCitizenship: "IN")))
}

#Preview("Settings · deletion requested") {
    ProfileV3SettingsView(viewModel: .preview(deps: .preview(isAccountDeletionRequested: true)))
}

#Preview("Settings · information access") {
    ProfileV3SettingsView(viewModel: .preview(pagePath: [.connectors]))
}

#Preview("Settings · app access") {
    let viewModel = ProfileV3SettingsViewModel.preview()
    viewModel.appAccess.open()
    return ProfileV3SettingsView(viewModel: viewModel)
}

#Preview("Settings · credential store") {
    let viewModel = ProfileV3SettingsViewModel.preview()
    viewModel.credentialStore.open()
    return ProfileV3SettingsView(viewModel: viewModel)
}
#endif
