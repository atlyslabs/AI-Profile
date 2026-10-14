import SwiftUI
import UIKit

@MainActor
public protocol ProfileV3IdentityCaptureHost: AnyObject, Sendable {
    func presentCapture(
        _ request: ProfileV3IdentityCapture.Request,
        from presenter: UIViewController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    )

    func captureView(
        _ request: ProfileV3IdentityCapture.Request,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) -> AnyView
}

public enum ProfileV3IdentityCapture {
    public struct Request {
        public var pieces: [ProfileV3CaptureImage]
        public var flowTitle: String?
        public var analyticsContext: String
        public var copy: [ProfileV3CaptureImage: PieceCopy] = [:]
        public var progress: Progress = .hidden
        public var showsBack = true
        public var allowsUploadFromDevice = true
        public var headerAccessory: AnyView?
        public var verify: @MainActor (Capture) async -> Verdict

        public init(
            pieces: [ProfileV3CaptureImage],
            flowTitle: String?,
            analyticsContext: String,
            verify: @escaping @MainActor (Capture) async -> Verdict
        ) {
            self.pieces = pieces
            self.flowTitle = flowTitle
            self.analyticsContext = analyticsContext
            self.verify = verify
        }
    }

    public struct PieceCopy: Equatable, Sendable {
        public var title: String?
        public var subtitle: String?
        public var eyebrow: String?

        public init(title: String? = nil, subtitle: String? = nil, eyebrow: String? = nil) {
            self.title = title
            self.subtitle = subtitle
            self.eyebrow = eyebrow
        }
    }

    public enum Progress: Equatable, Sendable {
        case segments(count: Int, filled: Int)
        case fraction(Double)
        case hidden
    }

    public struct Capture: Sendable {
        public enum Source: Equatable, Sendable {
            case liveScan
            case gallery
        }

        public let piece: ProfileV3CaptureImage
        public let image: UIImage
        public let source: Source

        public init(piece: ProfileV3CaptureImage, image: UIImage, source: Source) {
            self.piece = piece
            self.image = image
            self.source = source
        }
    }

    public enum Verdict: Equatable, Sendable {
        case verified
        case rejected(reason: String)
        case failed(message: String)
    }
}
