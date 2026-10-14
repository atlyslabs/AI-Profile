import Foundation

enum ProfileV3CaptureStepKey {
    static let passport = "passport"
    static let selfie = "selfie"
    static let gmailConnect = "gmail_connect"
    static let itr = "itr"
    static let establishMainReason = "establish_main"
}

struct ProfileV3KYCCapture: Equatable {
    enum Route: Equatable {
        case session
        case coTraveller
    }

    let profileID: String
    let route: Route
    let steps: [String]
    var reason: String?
    var isConnector = false

    var isSatisfied: Bool { steps.isEmpty }
    var establishesMain: Bool { reason == ProfileV3CaptureStepKey.establishMainReason }

    var hasCapturableStep: Bool {
        switch route {
        case .session:
            return !steps.isEmpty
        case .coTraveller:
            return steps.contains(ProfileV3CaptureStepKey.passport) || steps.contains(ProfileV3CaptureStepKey.selfie)
        }
    }

    static func connector(_ step: String, profileID: String) -> ProfileV3KYCCapture {
        ProfileV3KYCCapture(profileID: profileID, route: .session, steps: [step], isConnector: true)
    }
}

extension ProfileV3ConnectorKey {
    var captureStep: String? {
        switch self {
        case .gmail: return ProfileV3CaptureStepKey.gmailConnect
        case .itr: return ProfileV3CaptureStepKey.itr
        }
    }
}

extension ProfileV3Connector {
    var captureStep: String? {
        guard status != .connected else { return nil }
        return ProfileV3ConnectorKey(rawValue: id)?.captureStep
    }
}

public struct ProfileV3CaptureCopy: Equatable, Sendable {
    public let title: String?
    public let subtitle: String?
}

public struct ProfileV3CaptureLookingFor: Equatable, Sendable {
    public let icon: String?
    public let title: String
    public let body: String?
}

public struct ProfileV3CaptureIcon: Equatable, Sendable {
    public let icon: String
    public let label: String?
}

public enum ProfileV3ConnectorState: String, Equatable, Sendable {
    case idle
    case processing
    case completed
    case failed
}

struct ProfileV3CaptureStep: Equatable, Sendable {
    typealias ConnectorState = ProfileV3ConnectorState

    let id: String
    let type: String
    var title: String?
    var subtitle: String?
    var passportFront: ProfileV3CaptureCopy?
    var passportBack: ProfileV3CaptureCopy?
    var connectorState: ConnectorState?
    var pollAfterMilliseconds: Int?
    var cardTitle: String?
    var cardSubtitle: String?
    var connectCTA: String?
    var lookingFor: [ProfileV3CaptureLookingFor] = []
    var userImageURL: URL?
    var icons: [ProfileV3CaptureIcon] = []
    var errorMessage: String?
    var skippable = false
    var skipCTA: String?
    var findings: ProfileV3CaptureFindings?
}

public struct ProfileV3CaptureStat: Equatable, Sendable {
    public let label: String
    public let value: String
}

public struct ProfileV3CaptureFindings: Equatable, Sendable {
    public let title: String?
    public let stats: [ProfileV3CaptureStat]
}

enum ProfileV3CaptureAnswer: Equatable, Sendable {
    case gmailAuthCode(String)
    case passportDone
    case itrCredentials(pan: String, password: String)
    case skipped
    case connectorAcknowledged
}

public enum ProfileV3CaptureImage: Hashable, Sendable {
    case passportFront
    case passportBack
    case selfie
}
