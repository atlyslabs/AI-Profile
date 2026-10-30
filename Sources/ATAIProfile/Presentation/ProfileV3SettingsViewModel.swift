import Foundation
import Observation

@MainActor
@Observable
final class ProfileV3SettingsViewModel: ProfileV3SettingsNavigating {
    var pagePath: [ProfileV3SettingsDestination] = []
    var sheetPath: [ProfileV3SettingsDestination] = []
    private(set) var sheetEntry: ProfileV3SettingsDestination?
    var isAccountExpanded = false {
        didSet {
            guard isAccountExpanded != oldValue else { return }
            ProfileV3Analytics.accountCenterTapped(isOpening: isAccountExpanded)
        }
    }
    private(set) var menu: ProfileV3SettingsMenu?
    private(set) var menuPhase: ProfileV3LoadPhase = .loading

    let fields: ProfileV3ProfileFieldsModel
    let connectors: ProfileV3ConnectorsSettingsModel
    let appAccess: ProfileV3AppAccessModel
    let credentialStore: ProfileV3CredentialStoreModel
    let travellers: ProfileV3TravellersSettingsModel
    let account: ProfileV3AccountSettingsModel
    let permissions: ProfileV3PermissionsSettingsModel
    private(set) var monogram: String?
    var isGloveBoxPresented = false
    private(set) var gloveBoxHasAddress: Bool?
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
    @ObservationIgnored let gloveBoxRepository: (any ProfileV3GloveBoxRepository)?
    @ObservationIgnored private let board: (any ProfileV3BoardRepository)?
    @ObservationIgnored private let profileName: String?
    @ObservationIgnored private var menuTask: Task<Void, Never>?
    @ObservationIgnored private var presentTask: Task<Void, Never>?
    @ObservationIgnored private var monogramTask: Task<Void, Never>?
    @ObservationIgnored private var gloveBoxTask: Task<Void, Never>?
    @ObservationIgnored private var startsKYCAfterGloveBox = false

    init(
        deps: ProfileV3SettingsDependencies,
        repository: any ProfileV3SettingsRepository,
        board: (any ProfileV3BoardRepository)? = nil,
        profileID: String? = nil,
        profileName: String? = nil,
        photoPlaces: ProfileV3PhotoPlacesSync? = nil
    ) {
        self.repository = repository
        gloveBoxRepository = repository as? any ProfileV3GloveBoxRepository
        self.board = board
        self.profileName = profileName
        monogram = Self.monogram(from: deps.currentFirstName())
            ?? Self.monogram(from: profileName)
            ?? Self.monogram(from: board?.cachedBoard()?.mainProfile?.name)
        let fields = ProfileV3ProfileFieldsModel(deps: deps, repository: repository, profileID: profileID)
        self.fields = fields
        let connectors = ProfileV3ConnectorsSettingsModel(repository: repository, travellerID: profileID, photoPlaces: photoPlaces)
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
        menu?.title ?? ProfileV3Strings.settings
    }

    var failedMenuRows: [ProfileV3SettingsRowItem] {
        [
            ProfileV3SettingsRowItem(
                key: "logout",
                label: ProfileV3Strings.logout,
                directive: ProfileV3Directive(go: "logout_confirm")
            ),
            ProfileV3SettingsRowItem(
                key: "delete_account",
                label: ProfileV3Strings.deleteAccount,
                directive: ProfileV3Directive(go: "delete_account"),
                isDestructive: true
            )
        ]
    }

    func loadMenuIfNeeded() {
        guard menu == nil else { return }
        loadMenu()
    }

    func loadMonogramIfNeeded() {
        guard monogram == nil, monogramTask == nil, let board else { return }
        monogramTask = Task { [weak self] in
            let name = try? await board.loadLatestBoard().mainProfile?.name
            guard let self, !Task.isCancelled else { return }
            monogramTask = nil
            if monogram == nil {
                monogram = Self.monogram(from: name)
            }
        }
    }

    var hasGloveBox: Bool { gloveBoxRepository != nil }
    var showsGloveBoxActivate: Bool { gloveBoxHasAddress == false }

    func loadGloveBoxStatusIfNeeded() {
        guard gloveBoxHasAddress == nil, gloveBoxTask == nil else { return }
        loadGloveBoxStatus()
    }

    func tapGloveBox() {
        ProfileV3Analytics.gloveBoxOpened()
        isGloveBoxPresented = true
    }

    func gloveBoxDidClose() {
        guard startsKYCAfterGloveBox else {
            loadGloveBoxStatus()
            return
        }
        startsKYCAfterGloveBox = false
        router?.presentConnectorOnboarding()
    }

    func completeKYCFromGloveBox() {
        startsKYCAfterGloveBox = true
        isGloveBoxPresented = false
    }

    func isMainTravellerKYCComplete() async -> Bool {
        guard let board else { return true }
        if let main = board.cachedBoard()?.mainProfile {
            return main.home.kycStatus.isComplete
        }
        return (try? await board.loadLatestBoard().mainProfile?.home.kycStatus.isComplete) ?? true
    }

    func mainTravellerName() async -> String? {
        if let profileName, !profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return profileName }
        guard let board else { return nil }
        if let main = board.cachedBoard()?.mainProfile { return main.name }
        return try? await board.loadLatestBoard().mainProfile?.name
    }

    private func loadGloveBoxStatus() {
        guard let gloveBoxRepository else { return }
        gloveBoxTask?.cancel()
        gloveBoxTask = Task { [weak self] in
            let account = try? await gloveBoxRepository.loadGloveBoxCard()
            guard let self, !Task.isCancelled else { return }
            gloveBoxTask = nil
            if let account {
                gloveBoxHasAddress = account.hasAddress
            }
        }
    }

    static func monogram(from name: String?) -> String? {
        name?.trimmingCharacters(in: .whitespacesAndNewlines).first.map { String($0).lowercased() }
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
                model.fields.applyCitizenship(code: menu.citizenshipCode)
            }
        )
    }

    func tap(_ row: ProfileV3SettingsRowItem) {
        ProfileV3Analytics.cta(row.directive, origin: .settings)
        switch row.route {
        case .editField(let key):
            if let field = ProfileV3ProfileField(rawValue: key) {
                ProfileV3Analytics.settingsFieldClicked(field)
                fields.open(field)
            }
        case .connectors:
            ProfileV3Analytics.settingsConnectorClicked(.information)
            connectors.open()
        case .editTraveler:
            travellers.open()
        case .permissions:
            ProfileV3Analytics.permissionClicked()
            permissions.open()
        case .coupons:
            ProfileV3Analytics.couponsClicked()
            router?.presentCoupons()
        case .loyaltyAdd:
            router?.presentLoyaltyProgrammes()
        case .termsOfService:
            ProfileV3Analytics.termsClicked()
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
        ProfileV3Analytics.settingsConnectorClicked(.information)
        connectors.open()
    }

    func tapAppAccess() {
        ProfileV3Analytics.settingsConnectorClicked(.app)
        guard ProfileV3FeatureFlags.isAppAccessEnabled else {
            push(.appAccess)
            return
        }
        appAccess.open()
    }

    func tapCredentialStore() {
        ProfileV3Analytics.passVaultClicked()
        credentialStore.open()
    }

    func tapConcierge(_ concierge: ProfileV3Concierge) {
        router?.openExternalURL(concierge.openURL)
    }

    func tapBack() {
        ProfileV3Analytics.settingsBackClicked()
        router?.dismissSettings()
    }
    func tapClose() { path = pagePath }

    func sheetDidDismiss() {
        presentTask?.cancel()
        sheetEntry = nil
        sheetPath = []
    }

    func cancelReads() {
        menuTask?.cancel()
        presentTask?.cancel()
        monogramTask?.cancel()
        monogramTask = nil
        gloveBoxTask?.cancel()
        gloveBoxTask = nil
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
