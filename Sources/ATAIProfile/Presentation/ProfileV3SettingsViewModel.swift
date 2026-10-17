import Combine
import Foundation

@MainActor
final class ProfileV3SettingsViewModel: ObservableObject, ProfileV3SettingsNavigating {
    @Published var pagePath: [ProfileV3SettingsDestination] = []
    @Published var sheetPath: [ProfileV3SettingsDestination] = []
    @Published private(set) var sheetEntry: ProfileV3SettingsDestination?
    @Published var isAccountExpanded = false
    @Published private(set) var menu: ProfileV3SettingsMenu?
    @Published private(set) var menuPhase: ProfileV3LoadPhase = .loading

    let fields: ProfileV3ProfileFieldsModel
    let connectors: ProfileV3ConnectorsSettingsModel
    let travellers: ProfileV3TravellersSettingsModel
    let account: ProfileV3AccountSettingsModel
    let permissions: ProfileV3PermissionsSettingsModel
    let monogram: String?
    var sheetHeights: [ProfileV3SettingsDestination: CGFloat] = [:]

    weak var router: (any ProfileV3SettingsRouter)? {
        didSet {
            fields.router = router
            connectors.router = router
            travellers.router = router
            account.router = router
        }
    }

    private let repository: any ProfileV3SettingsRepository
    private var menuTask: Task<Void, Never>?
    private var presentTask: Task<Void, Never>?

    init(
        deps: ProfileV3SettingsDependencies,
        repository: any ProfileV3SettingsRepository,
        profileID: String? = nil,
        photoPlaces: ProfileV3PhotoPlacesSync? = nil
    ) {
        self.repository = repository
        monogram = deps.currentFirstName()?.trimmingCharacters(in: .whitespaces).first.map { String($0).lowercased() }
        let fields = ProfileV3ProfileFieldsModel(deps: deps, repository: repository, profileID: profileID)
        self.fields = fields
        connectors = ProfileV3ConnectorsSettingsModel(repository: repository, photoPlaces: photoPlaces)
        travellers = ProfileV3TravellersSettingsModel(
            deps: deps,
            repository: repository,
            currentContact: { [weak fields] in fields?.contactDetails ?? deps.currentContact() }
        )
        account = ProfileV3AccountSettingsModel(deps: deps, repository: repository)
        permissions = ProfileV3PermissionsSettingsModel(repository: repository)
        fields.navigator = self
        connectors.navigator = self
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
        push(.appAccess)
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
