import ATCore
import Foundation
import Moya

enum ProfileV3API {
    case board
    case agent(type: ProfileV3AgentID, profileID: String?)
    case preferenceSources(agentType: String, fieldKey: String, profileID: String?)
    case ridePicker(agentType: String, profileID: String?)
    case passportUpdate(profileID: String?)
    case passportReason
    case passportHowUsed
    case passportScan(body: Data, contentType: String)
    case loyaltyCatalogue(query: String?, kind: String?)
    case loyaltyEnter(programID: String, programName: String?, kind: String?)
    case loyaltyPage(profileID: String)
    case loyaltyInsight(programID: String, profileID: String?)
    case loyaltySources(programID: String, profileID: String?)
    case benefits(profileID: String?)
    case benefit(id: String)
    case coupons
    case coupon(id: String)
    case settings
    case editField(String)
    case connectors
    case connectorControlPanel
    case disconnectConfirm(connector: ProfileV3ConnectorKey)
    case editTravellers
    case permissions
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
}

extension ProfileV3API: ATCoreTargetType {
    private static let boardBasePath = "/api/gmail-connector/kyc/v2/board"
    private static let captureBasePath = "/api/gmail-connector/kyc/v1"

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
        case .passportUpdate:
            return Self.boardBasePath + "/passport/update"
        case .passportReason:
            return Self.boardBasePath + "/passport/reason"
        case .passportHowUsed:
            return Self.boardBasePath + "/passport/how-used"
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
        case .editField(let field):
            return Self.boardBasePath + "/settings/edit/\(field)"
        case .connectors:
            return Self.boardBasePath + "/settings/connectors"
        case .connectorControlPanel:
            return Self.boardBasePath + "/settings/connectors/control-panel"
        case .disconnectConfirm(let connector):
            return Self.boardBasePath + "/settings/connectors/disconnect/\(connector.rawValue)"
        case .editTravellers:
            return Self.boardBasePath + "/edit-traveler"
        case .permissions:
            return Self.boardBasePath + "/permissions"
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
        }
    }

    var method: Moya.Method {
        switch self {
        case .passportScan, .submit, .slackAlert, .captureStart, .captureAnswer, .coTraveller:
            return .post
        case .editProfile:
            return .patch
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .agent(_, let profileID),
             .ridePicker(_, let profileID),
             .passportUpdate(let profileID),
             .loyaltyInsight(_, let profileID),
             .loyaltySources(_, let profileID),
             .benefits(let profileID),
             .preferenceSources(_, _, let profileID):
            return Self.query(("profile_id", profileID))
        case .loyaltyCatalogue(let query, let kind):
            return Self.query(("q", query?.nonEmpty), ("kind", kind?.nonEmpty))
        case .loyaltyEnter(_, let programName, let kind):
            return Self.query(("program_name", programName), ("kind", kind))
        case .terms(let locale):
            return Self.query(("locale", locale))
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
