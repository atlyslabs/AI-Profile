import ATAIProfile
import SwiftUI
import UIKit

@MainActor
final class VDCProfileV3IdentityCaptureHost: ProfileV3IdentityCaptureHost {
    func presentCapture(
        _ request: ProfileV3IdentityCapture.Request,
        from presenter: UIViewController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) {
        let navigation = UINavigationController()
        let finish: (ProfileV3FlowOutcome) -> Void = { [weak navigation] outcome in
            guard let navigation, navigation.presentingViewController != nil else { return completion(outcome) }
            navigation.dismiss(animated: true) { completion(outcome) }
        }
        let flow = IDCFactory.makeViewController(
            configuration: IDCConfiguration(request),
            verifier: VDCProfileV3CaptureVerifier(request.verify),
            callbacks: IDCCallbacks(onComplete: { _, _ in finish(.completed) }, onExit: { finish(.cancelled) })
        )
        navigation.setViewControllers([flow], animated: false)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.modalPresentationStyle = .overFullScreen
        navigation.modalTransitionStyle = .crossDissolve
        presenter.present(navigation, animated: true)
    }

    func captureView(
        _ request: ProfileV3IdentityCapture.Request,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) -> AnyView {
        AnyView(VDCProfileV3IdentityCaptureView(request: request, completion: completion))
    }
}

private struct VDCProfileV3IdentityCaptureView: View {
    @StateObject private var viewModel: IDCFlowViewModel

    init(
        request: ProfileV3IdentityCapture.Request,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: IDCFlowViewModel(
            configuration: IDCConfiguration(request),
            verifier: VDCProfileV3CaptureVerifier(request.verify),
            callbacks: IDCCallbacks(onComplete: { _, _ in completion(.completed) }, onExit: { completion(.cancelled) })
        ))
    }

    var body: some View {
        IDCFlowView(viewModel: viewModel)
    }
}

private final class VDCProfileV3CaptureVerifier: IDCVerifier {
    private let check: @MainActor (ProfileV3IdentityCapture.Capture) async -> ProfileV3IdentityCapture.Verdict

    init(_ check: @escaping @MainActor (ProfileV3IdentityCapture.Capture) async -> ProfileV3IdentityCapture.Verdict) {
        self.check = check
    }

    func verify(_ result: IDCCaptureResult) async -> IDCVerificationOutcome {
        let capture = ProfileV3IdentityCapture.Capture(
            piece: ProfileV3CaptureImage(result.piece),
            image: result.image,
            source: result.source == .liveScan ? .liveScan : .gallery
        )
        switch await check(capture) {
        case .verified: return .verified(payload: nil)
        case .rejected(let reason): return .rejected(reason: reason)
        case .failed(let message): return .failed(message: message)
        }
    }
}

private extension IDCConfiguration {
    init(_ request: ProfileV3IdentityCapture.Request) {
        self.init(
            pieces: request.pieces.map(IDCPiece.init),
            flowTitle: request.flowTitle,
            analyticsContext: request.analyticsContext
        )
        copy = Dictionary(uniqueKeysWithValues: request.copy.map { piece, text in
            (IDCPiece(piece), IDCCaptureCopy(title: text.title, subtitle: text.subtitle, eyebrow: text.eyebrow))
        })
        progress = IDCProgressStyle(request.progress)
        showsBack = request.showsBack
        allowUploadFromDevice = request.allowsUploadFromDevice
        headerAccessory = request.headerAccessory
    }
}

private extension IDCPiece {
    init(_ piece: ProfileV3CaptureImage) {
        switch piece {
        case .passportFront: self = .passportFront
        case .passportBack: self = .passportBack
        case .selfie: self = .selfie
        }
    }
}

private extension ProfileV3CaptureImage {
    init(_ piece: IDCPiece) {
        switch piece {
        case .passportFront: self = .passportFront
        case .passportBack: self = .passportBack
        case .selfie: self = .selfie
        }
    }
}

private extension IDCProgressStyle {
    init(_ progress: ProfileV3IdentityCapture.Progress) {
        switch progress {
        case .segments(let count, let filled): self = .segments(count: count, filled: filled)
        case .fraction(let value): self = .fraction(value)
        case .hidden: self = .hidden
        }
    }
}
