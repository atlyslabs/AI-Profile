import ATCore
import Foundation
import Moya

enum ProfileV3API {
    case board
    case agent(type: ProfileV3AgentID, profileID: String?)
    case preferenceSources(agentType: String, fieldKey: String, profileID: String?)
    case ridePicker(agentType: String, profileID: String?)
    case rideRegions
    case travelPersona(profileID: String?)
    case personaTrait(trait: String, profileID: String?, page: Int)
    case pastTrips(profileID: String)
    case addTrip(profileID: String)
    case passportUpdate(profileID: String?)
    case passportReason
    case passportHowUsed
    case passportPrevious(profileID: String?)
    case passportScan(body: Data, contentType: String)
    case loyaltyCatalogue(query: String?, kind: String?, market: String?)
    case loyaltyEnter(programID: String, programName: String?, kind: String?)
    case loyaltyPage(profileID: String)
    case loyaltyInsight(programID: String, profileID: String?)
    case loyaltySources(programID: String, profileID: String?)
    case benefits(profileID: String?)
    case benefit(id: String)
    case coupons
    case coupon(id: String)
    case settings
    case editField(String, profileID: String?)
    case connectors
    case connectorControlPanel
    case aiConnector(connector: String)
    case aiConnectorConnect(connector: String)
    case disconnectConfirm(connector: ProfileV3ConnectorKey)
    case editTravellers
    case deleteAccount
    case deleteAccountConfirm
    case deleteTravellerConfirm(profileID: String)
    case addTraveller
    case terms(locale: String?)
    case submit(body: Data)
    case slackAlert(body: Data)
    case editProfile(body: Data)
    case captureStart(body: Data)
    case captureState
    case captureAnswer(body: Data, contentType: String)
    case coTraveller(body: Data, contentType: String)
    case vaultPublicKey
    case vaultSites
    case vaultCredentials
    case vaultCredential(id: String, includeUsername: Bool)
    case vaultCreateCredential(body: Data)
    case vaultUpdateCredential(id: String, body: Data)
    case vaultCredentialAction(id: String, action: String)
    case vaultDeleteCredential(id: String)
    case vaultRegisterDevice(body: Data)
    case vaultDeleteDevice(id: String)
    case vaultRevealChallenge(id: String, body: Data)
    case vaultReveal(id: String, body: Data)
    case gloveBoxMe
    case gloveBoxCreate
    case gloveBoxForwarding(body: Data)
    case gloveBoxForwardingAddress(body: Data)
    case gloveBoxMessages(limit: Int, cursor: String?)
    case gloveBoxMessage(id: String)
    case gloveBoxAttachment(messageID: String, index: Int)
    case permissions
    case updatePermission(key: String, body: Data)
    case instagramAccount(userID: String)
    case linkInstagram(body: Data)
}

extension ProfileV3API: ATCoreTargetType {
    private static let boardBasePath = "/api/gmail-connector/kyc/v2/board"
    private static let captureBasePath = "/api/gmail-connector/kyc/v1"
    private static let vaultBasePath = "/api/fort-knox/v1"
    private static let gloveBoxBasePath = "/gateway/jaqen/v1"
    private static let harnessBasePath = "/api/harness/v1"
    private static let snapmapBasePath = "/api/snapmap"

    var baseURL: URL {
        URL(string: "https://profile.atlys.invalid")!
    }

    var path: String {
        switch self {
        case .board:
            return Self.boardBasePath
        case .agent(let type, _):
            return Self.boardBasePath + "/agent/\(type.apiValue)"
        case .preferenceSources(let agentType, let fieldKey, _):
            return Self.boardBasePath + "/agent/\(agentType)/sources/\(fieldKey)"
        case .ridePicker(let agentType, _):
            return Self.boardBasePath + "/agent/\(agentType)/ride"
        case .rideRegions:
            return Self.boardBasePath + "/agent/\(ProfileV3AgentID.airportLogistics.apiValue)/ride/regions"
        case .travelPersona:
            return Self.boardBasePath + "/travel_persona"
        case .personaTrait(let trait, _, _):
            return Self.boardBasePath + "/travel_persona/\(trait)"
        case .pastTrips:
            return Self.boardBasePath + "/past_trips"
        case .addTrip:
            return Self.boardBasePath + "/past_trips/add"
        case .passportUpdate:
            return Self.boardBasePath + "/passport/update"
        case .passportReason:
            return Self.boardBasePath + "/passport/reason"
        case .passportHowUsed:
            return Self.boardBasePath + "/passport/how-used"
        case .passportPrevious:
            return Self.boardBasePath + "/passport/previous"
        case .passportScan:
            return Self.boardBasePath + "/passport/scan"
        case .loyaltyCatalogue:
            return Self.boardBasePath + "/loyalty/catalogue"
        case .loyaltyEnter(let programID, _, _):
            return Self.boardBasePath + "/loyalty/enter/\(programID)"
        case .loyaltyPage(let profileID):
            return Self.boardBasePath + "/loyalty/page/\(profileID)"
        case .loyaltyInsight(let programID, _):
            return Self.boardBasePath + "/loyalty/insight/\(programID)"
        case .loyaltySources(let programID, _):
            return Self.boardBasePath + "/loyalty/insight/\(programID)/sources"
        case .benefits:
            return Self.boardBasePath + "/benefits"
        case .benefit(let id):
            return Self.boardBasePath + "/benefits/\(id)"
        case .coupons:
            return Self.boardBasePath + "/coupons"
        case .coupon(let id):
            return Self.boardBasePath + "/coupons/\(id)"
        case .settings:
            return Self.boardBasePath + "/settings"
        case .editField(let field, _):
            return Self.boardBasePath + "/settings/edit/\(field)"
        case .connectors:
            return Self.boardBasePath + "/settings/connectors"
        case .connectorControlPanel:
            return Self.boardBasePath + "/settings/connectors/control-panel"
        case .aiConnector(let connector):
            return Self.boardBasePath + "/settings/connectors/ai/\(connector)"
        case .aiConnectorConnect(let connector):
            return Self.boardBasePath + "/settings/connectors/ai/\(connector)/connect"
        case .disconnectConfirm(let connector):
            return Self.boardBasePath + "/settings/connectors/disconnect/\(connector.rawValue)"
        case .editTravellers:
            return Self.boardBasePath + "/edit-traveler"
        case .deleteAccount:
            return Self.boardBasePath + "/settings/delete-account"
        case .deleteAccountConfirm:
            return Self.boardBasePath + "/settings/delete-account/confirm"
        case .deleteTravellerConfirm(let profileID):
            return Self.boardBasePath + "/edit-traveler/delete/\(profileID)"
        case .addTraveller:
            return Self.boardBasePath + "/add-traveler"
        case .terms:
            return Self.boardBasePath + "/terms"
        case .submit:
            return Self.boardBasePath + "/submit"
        case .slackAlert:
            return "/api/v1/utils/send-slack-alert"
        case .editProfile:
            return "/api/pensieve/v1/profile/edit"
        case .captureStart:
            return Self.captureBasePath + "/capture/start"
        case .captureState:
            return Self.captureBasePath + "/state"
        case .captureAnswer:
            return Self.captureBasePath + "/answer"
        case .coTraveller:
            return Self.captureBasePath + "/co-traveler"
        case .vaultPublicKey:
            return Self.vaultBasePath + "/public-key"
        case .vaultSites:
            return Self.vaultBasePath + "/sites"
        case .vaultCredentials, .vaultCreateCredential:
            return Self.vaultBasePath + "/credentials"
        case .vaultCredential(let id, _), .vaultUpdateCredential(let id, _), .vaultDeleteCredential(let id):
            return Self.vaultBasePath + "/credentials/\(id)"
        case .vaultCredentialAction(let id, let action):
            return Self.vaultBasePath + "/credentials/\(id)/\(action)"
        case .vaultRegisterDevice:
            return Self.vaultBasePath + "/devices"
        case .vaultDeleteDevice(let id):
            return Self.vaultBasePath + "/devices/\(id)"
        case .vaultRevealChallenge(let id, _):
            return Self.vaultBasePath + "/credentials/\(id)/reveal/challenge"
        case .vaultReveal(let id, _):
            return Self.vaultBasePath + "/credentials/\(id)/reveal"
        case .gloveBoxMe, .gloveBoxCreate:
            return Self.gloveBoxBasePath + "/me"
        case .gloveBoxForwarding:
            return Self.gloveBoxBasePath + "/forwarding"
        case .gloveBoxForwardingAddress:
            return Self.gloveBoxBasePath + "/forwarding-address"
        case .gloveBoxMessages:
            return Self.gloveBoxBasePath + "/messages"
        case .gloveBoxMessage(let id):
            return Self.gloveBoxBasePath + "/messages/\(id)"
        case .gloveBoxAttachment(let messageID, let index):
            return Self.gloveBoxBasePath + "/messages/\(messageID)/attachments/\(index)"
        case .permissions:
            return Self.harnessBasePath + "/permissions"
        case .updatePermission(let key, _):
            return Self.harnessBasePath + "/permissions/\(key)"
        case .instagramAccount, .linkInstagram:
            return Self.snapmapBasePath + "/instagram/accounts"
        }
    }

    var method: Moya.Method {
        switch self {
        case .passportScan, .submit, .slackAlert, .captureStart, .captureAnswer, .coTraveller,
             .vaultCreateCredential, .vaultCredentialAction, .vaultRegisterDevice, .vaultRevealChallenge, .vaultReveal,
             .gloveBoxCreate, .gloveBoxForwardingAddress, .linkInstagram:
            return .post
        case .gloveBoxForwarding, .updatePermission:
            return .put
        case .editProfile, .vaultUpdateCredential:
            return .patch
        case .vaultDeleteCredential, .vaultDeleteDevice:
            return .delete
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .agent(_, let profileID),
             .ridePicker(_, let profileID),
             .passportUpdate(let profileID),
             .passportPrevious(let profileID),
             .loyaltyInsight(_, let profileID),
             .loyaltySources(_, let profileID),
             .benefits(let profileID),
             .preferenceSources(_, _, let profileID),
             .editField(_, let profileID),
             .travelPersona(let profileID):
            return Self.query(("profile_id", profileID))
        case .personaTrait(_, let profileID, let page):
            return Self.query(("profile_id", profileID), ("page", String(page)))
        case .pastTrips(let profileID), .addTrip(let profileID):
            return Self.query(("profile_id", profileID))
        case .loyaltyCatalogue(let query, let kind, let market):
            return Self.query(("q", query?.nonEmpty), ("kind", kind?.nonEmpty), ("market", market?.nonEmpty))
        case .loyaltyEnter(_, let programName, let kind):
            return Self.query(("program_name", programName), ("kind", kind))
        case .terms(let locale):
            return Self.query(("locale", locale))
        case .vaultCredential(_, let includeUsername):
            return includeUsername ? Self.query(("include_username", "true")) : .requestPlain
        case .gloveBoxMessages(let limit, let cursor):
            return Self.query(("limit", String(limit)), ("cursor", cursor))
        case .instagramAccount(let userID):
            return Self.query(("user_id", userID))
        case .gloveBoxForwarding(let body),
             .gloveBoxForwardingAddress(let body),
             .updatePermission(_, let body),
             .linkInstagram(let body):
            return .requestData(body)
        case .vaultCreateCredential(let body),
             .vaultUpdateCredential(_, let body),
             .vaultRegisterDevice(let body),
             .vaultRevealChallenge(_, let body),
             .vaultReveal(_, let body):
            return .requestData(body)
        case .passportScan(let body, _),
             .submit(let body),
             .slackAlert(let body),
             .editProfile(let body),
             .captureStart(let body),
             .captureAnswer(let body, _),
             .coTraveller(let body, _):
            return .requestData(body)
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers = [
            "accept": "application/json",
            "Content-Type": "application/json",
        ]
        switch self {
        case .passportScan(_, let contentType), .captureAnswer(_, let contentType), .coTraveller(_, let contentType):
            headers["Content-Type"] = contentType
        default:
            break
        }
        return headers
    }

    var requiresAuth: Bool { true }

    var allowsRetryForNonIdempotentRequests: Bool { false }

    private static func query(_ pairs: (name: String, value: String?)...) -> Moya.Task {
        var parameters: [String: Any] = [:]
        for pair in pairs {
            if let value = pair.value { parameters[pair.name] = value }
        }
        return parameters.isEmpty
            ? .requestPlain
            : .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }
}
