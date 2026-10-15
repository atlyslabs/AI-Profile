import SwiftUI
import UIKit

@MainActor
public protocol ProfileV3KYCHost: AnyObject, Sendable {
    func startOnboarding(
        on navigationController: UINavigationController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    )

    func presentMinimalCapture(
        from presenter: UIViewController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    )

    func gmailConnectView(
        _ screen: ProfileV3KYC.GmailConnectScreen,
        actions: ProfileV3KYC.GmailConnectActions
    ) -> AnyView

    func itrConnectView(
        _ screen: ProfileV3KYC.ITRConnectScreen,
        actions: ProfileV3KYC.ITRConnectActions
    ) -> AnyView

    func passportCaptureView(
        _ screen: ProfileV3KYC.PassportCaptureScreen,
        actions: ProfileV3KYC.PassportCaptureActions
    ) -> AnyView

    func selfieCaptureView(
        _ screen: ProfileV3KYC.SelfieCaptureScreen,
        actions: ProfileV3KYC.SelfieCaptureActions
    ) -> AnyView

    func authorizeGmail() async -> String?

    func track(_ event: ProfileV3KYC.Event)
}

public enum ProfileV3KYC {
    public struct ConnectorContent: Equatable, Sendable {
        public let state: ProfileV3ConnectorState
        public let pollAfterMilliseconds: Int?
        public let errorMessage: String?
        public let title: String?
        public let cardTitle: String?
        public let cardSubtitle: String?
        public let lookingFor: [ProfileV3CaptureLookingFor]
    }

    public struct GmailConnectScreen: Equatable, Sendable {
        public let content: ConnectorContent
        public let connectCTA: String?
        public let userImageURL: URL?
        public let brandIcons: [ProfileV3CaptureIcon]
        public let progress: Double
        public let isConnecting: Bool
        public let nextStepReady: Bool
    }

    public struct GmailConnectActions {
        public let connect: @MainActor () -> Void
        public let switchToManual: @MainActor () -> Void
        public let convergenceFinished: @MainActor () -> Void
        public let back: @MainActor () -> Void
    }

    public struct ITRConnectScreen: Equatable, Sendable {
        public let content: ConnectorContent
        public let skippable: Bool
        public let skipCTA: String?
        public let findings: ProfileV3CaptureFindings?
        public let progress: Double
        public let isBusy: Bool
    }

    public struct ITRConnectActions {
        public let uploadPDF: @MainActor (_ pdf: Data) -> Void
        public let connect: @MainActor (_ pan: String, _ password: String) -> Void
        public let skip: @MainActor () -> Void
        public let done: @MainActor () -> Void
        public let back: @MainActor () -> Void
    }

    public struct PassportCaptureScreen: Equatable, Sendable {
        public let stepID: String
        public let front: ProfileV3CaptureCopy?
        public let back: ProfileV3CaptureCopy?
        public let progress: Double
        public let travellerID: String?
    }

    public struct PassportCaptureActions {
        public let upload: @MainActor (
            _ side: ProfileV3PassportSide,
            _ jpeg: Data,
            _ residenceCountryCode: String?
        ) async -> PassportUploadResult
        public let completed: @MainActor () -> Void
        public let cancel: @MainActor () -> Void
    }

    public enum PassportUploadResult: Equatable, Sendable {
        case accepted
        case rejected(message: String)
        case failed(message: String)
    }

    public struct SelfieCaptureScreen: Equatable, Sendable {
        public let copy: ProfileV3CaptureCopy?
        public let progress: Double
        public let travellerID: String?
    }

    public struct SelfieCaptureActions {
        public let upload: @MainActor (_ photo: Data) async -> String?
        public let completed: @MainActor () -> Void
        public let cancel: @MainActor () -> Void
    }

    public enum ConnectorDecision: String, Equatable, Sendable {
        case continued
        case skipped
    }

    public enum Event: Equatable, Sendable {
        case captureStarted(actionSource: String)
        case captureEnded
        case itrConnectionDecision(ConnectorDecision)
        case itrConnectionResponse(decision: String, apiResponse: String?, itrAmount: String?, itr: String?)
    }
}
