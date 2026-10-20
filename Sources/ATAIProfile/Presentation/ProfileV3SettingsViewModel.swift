import Foundation
import Observation

@MainActor
@Observable
final class ProfileV3SettingsViewModel: ProfileV3SettingsNavigating {
    var pagePath: [ProfileV3SettingsDestination] = []
    var sheetPath: [ProfileV3SettingsDestination] = []
    private(set) var sheetEntry: ProfileV3SettingsDestination?
    var isAccountExpanded = false
    private(set) var menu: ProfileV3SettingsMenu?
    private(set) var menuPhase: ProfileV3LoadPhase = .loading

    let fields: ProfileV3ProfileFieldsModel
    let connectors: ProfileV3ConnectorsSettingsModel
    let appAccess: ProfileV3AppAccessModel
    let credentialStore: ProfileV3CredentialStoreModel
    let travellers: ProfileV3TravellersSettingsModel
    let account: ProfileV3AccountSettingsModel
    let permissions: ProfileV3PermissionsSettingsModel
    let monogram: String?
    @ObservationIgnored var sheetHeights: [ProfileV3SettingsDestination: CGFloat] = [:]

    @ObservationIgnored weak var router: (any ProfileV3SettingsRouter)? {
        didSet {
            fields.router = router
            connectors.router = router
            appAccess.router = router
            travellers.router = router
            account.router = router
        }
    }

    @ObservationIgnored private let repository: any ProfileV3SettingsRepository
    @ObservationIgnored private var menuTask: Task<Void, Never>?
    @ObservationIgnored private var presentTask: Task<Void, Never>?

    init(
        deps: ProfileV3SettingsDependencies,
        repository: any ProfileV3SettingsRepository,
        profileID: String? = nil
    ) {
        self.repository = repository
        monogram = deps.currentFirstName()?.trimmingCharacters(in: .whitespaces).first.map { String($0).lowercased() }
        let fields = ProfileV3ProfileFieldsModel(deps: deps, repository: repository, profileID: profileID)
        self.fields = fields
        let connectors = ProfileV3ConnectorsSettingsModel(repository: repository)
        self.connectors = connectors
        appAccess = ProfileV3AppAccessModel(repository: repository, connectors: connectors)
        credentialStore = ProfileV3CredentialStoreModel(repository: repository)
        travellers = ProfileV3TravellersSettingsModel(
            deps: deps,
            repository: repository,
            currentContact: { [weak fields] in fields?.contactDetails ?? deps.currentContact() }
        )
        account = ProfileV3AccountSettingsModel(deps: deps, repository: repository)
        permissions = ProfileV3PermissionsSettingsModel(repository: repository)
        fields.navigator = self
        connectors.navigator = self
        appAccess.navigator = self
        travellers.navigator = self
        account.navigator = self
        permissions.navigator = self
    }

    var path: [ProfileV3SettingsDestination] {
        get { pagePath + (sheetEntry.map { [$0] + sheetPath } ?? []) }
        set { route(to: newValue) }
    }

    var title: String {
        menu?.title.nonEmpty ?? ProfileV3Strings.settings
    }

    func loadMenuIfNeeded() {
        guard menu == nil else { return }
        loadMenu()
    }

    func loadMenu() {
        let repository = repository
        ProfileV3PhasedLoad.start(
            on: self,
            task: \.menuTask,
            phase: \.menuPhase,
            content: \.menu,
            fetch: { try await repository.loadSettings() },
            apply: { model, menu in
                model.menu = menu
                if menu.rows.contains(where: { $0.route == .permissions }) {
                    model.permissions.preload()
                }
                if menu.accountsRows.contains(where: {
                    $0.route == .editField(ProfileV3ProfileField.citizenship.rawValue)
                }) {
                    model.fields.preloadCitizenshipIcon()
                }
            }
        )
    }

    func tap(_ row: ProfileV3SettingsRowItem) {
        ProfileV3Analytics.settingsRowClicked(rowKey: row.key)
        ProfileV3Analytics.cta(row.directive, origin: .settings)
        switch row.route {
        case .editField(let key):
            if let field = ProfileV3ProfileField(rawValue: key) {
                fields.open(field)
            }
        case .connectors:
            connectors.open()
        case .editTraveler:
            travellers.open()
        case .permissions:
            permissions.open()
        case .coupons:
            router?.presentCoupons()
        case .loyaltyAdd:
            router?.presentLoyaltyProgrammes()
        case .termsOfService:
            router?.presentTermsOfService()
        case .logout:
            account.tapLogout()
        case .deleteAccount:
            account.tapDeleteAccount()
        default:
            break
        }
    }

    func tapInformationAccess() {
        ProfileV3Analytics.settingsRowClicked(rowKey: "information_access")
        connectors.open()
    }

    func tapAppAccess() {
        ProfileV3Analytics.settingsRowClicked(rowKey: "app_access")
        guard ProfileV3FeatureFlags.isAppAccessEnabled else {
            push(.appAccess)
            return
        }
        appAccess.open()
    }

    func tapCredentialStore() {
        ProfileV3Analytics.settingsRowClicked(rowKey: "credential_store")
        credentialStore.open()
    }

    func tapConcierge(_ concierge: ProfileV3Concierge) {
        ProfileV3Analytics.settingsRowClicked(rowKey: "concierge")
        router?.openExternalURL(concierge.openURL)
    }

    func tapBack() { router?.dismissSettings() }
    func tapClose() { path = pagePath }

    func sheetDidDismiss() {
        presentTask?.cancel()
        sheetEntry = nil
        sheetPath = []
    }

    func cancelReads() {
        menuTask?.cancel()
        presentTask?.cancel()
        fields.cancelReads()
        connectors.cancelReads()
        appAccess.cancelReads()
        credentialStore.cancelReads()
        travellers.cancelReads()
        permissions.cancelReads()
    }

    private func route(to newPath: [ProfileV3SettingsDestination]) {
        let page = Array(newPath.prefix { $0.isPage })
        let sheet = Array(newPath.dropFirst(page.count))
        if page != pagePath {
            pagePath = page
        }
        guard let entry = sheet.first else {
            guard sheetEntry != nil else { return }
            sheetDidDismiss()
            router?.dismissSheet()
            return
        }
        let stack = Array(sheet.dropFirst())
        if sheetPath != stack {
            sheetPath = stack
        }
        guard sheetEntry != entry else { return }
        let isPresented = sheetEntry != nil
        sheetEntry = entry
        guard !isPresented else { return }
        presentTask?.cancel()
        presentTask = Task { [weak self] in
            guard let self, !Task.isCancelled, sheetEntry != nil else { return }
            router?.presentSheet()
        }
    }
}

#if DEBUG
extension ProfileV3SettingsViewModel {
    static func preview(
        deps: ProfileV3SettingsDependencies = .preview(),
        repository: any ProfileV3SettingsRepository = ProfileV3MockRepository(),
        pagePath: [ProfileV3SettingsDestination] = []
    ) -> ProfileV3SettingsViewModel {
        let viewModel = ProfileV3SettingsViewModel(deps: deps, repository: repository)
        viewModel.pagePath = pagePath
        return viewModel
    }
}
#endif
