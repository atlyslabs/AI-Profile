import Foundation

enum ProfileV3SettingsDestination: Hashable {
    case residence
    case citizenship
    case currency
    case contactInfo
    case connectors
    case appAccess
    case controlPanel
    case logout
    case deleteAccount
    case deleteAccountConfirm
    case editTravellers
    case editTraveller(String)
    case travellerRelationship(String)
    case deleteTravellerConfirm(String)
    case addTraveller
    case addTravellerCitizenship
    case permissions
    case inviteCode

    var isPage: Bool {
        switch self {
        case .connectors, .appAccess: return true
        default: return false
        }
    }

    var isFullHeight: Bool {
        switch self {
        case .residence, .citizenship, .currency, .contactInfo, .connectors, .appAccess,
             .controlPanel, .deleteAccount, .editTraveller, .travellerRelationship, .addTraveller,
             .addTravellerCitizenship:
            return true
        case .logout, .deleteAccountConfirm, .editTravellers, .deleteTravellerConfirm, .permissions,
             .inviteCode:
            return false
        }
    }

    static let premeasured: [ProfileV3SettingsDestination] = [
        .logout, .deleteAccountConfirm, .permissions, .inviteCode
    ]
}

@MainActor
protocol ProfileV3SettingsNavigating: AnyObject {
    var path: [ProfileV3SettingsDestination] { get set }
}

extension ProfileV3SettingsNavigating {
    func push(_ destination: ProfileV3SettingsDestination) { path.append(destination) }
    func pop() { _ = path.popLast() }
    func popToRoot() { path.removeAll() }
}

@MainActor
protocol ProfileV3SettingsSheetRouting: AnyObject {
    func presentSheet()
    func dismissSheet()
    func dismissSettings()
    func dismissSettingsThenRestart(after pendingWrites: Task<Void, Never>?)
    func restartAfterSaving(_ pendingWrites: Task<Void, Never>?)
    func presentCoupons()
    func presentInviteShare(_ invite: ProfileV3InviteCode)
    func presentLoyaltyProgrammes()
    func presentTermsOfService()
    func openExternalURL(_ url: URL)
}

@MainActor
protocol ProfileV3SettingsFeedbackRouting: AnyObject {
    func showFlash(_ text: String, isSuccess: Bool)
}

@MainActor
protocol ProfileV3ConnectorsRouting: AnyObject {
    func presentConnectorOnboarding()
    func startConnectorCapture(_ step: String)
    func presentDisconnectEmail()
    func dismissDisconnectEmail()
    func presentDisconnectProgress()
    func dismissDisconnectProgress()
    func connectorDidDisconnect(_ connector: ProfileV3ConnectorKey)
}

@MainActor
protocol ProfileV3TravellersRouting: AnyObject {
    func travellerDidChange()
    func travellersDidChange()
}

@MainActor
protocol ProfileV3SessionRouting: AnyObject {
    func performLogout()
}

typealias ProfileV3SettingsRouter = ProfileV3SettingsSheetRouting
    & ProfileV3SettingsFeedbackRouting
    & ProfileV3ConnectorsRouting
    & ProfileV3TravellersRouting
    & ProfileV3SessionRouting
