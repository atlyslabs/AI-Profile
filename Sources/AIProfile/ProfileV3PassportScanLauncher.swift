import SwiftUI
import UIKit

struct ProfileV3PassportScanRequest {
    let scan: ProfileV3PassportScan
    let avatarURL: URL?
    let upload: (ProfileV3PassportSide, Data) async throws -> ProfileV3PassportField?
    let onFinish: (_ field: ProfileV3PassportField?, _ completed: Bool) -> Void
}

@MainActor
final class ProfileV3PassportScanVerifier {
    private static let jpegQuality: CGFloat = 0.85

    private let upload: (ProfileV3PassportSide, Data) async throws -> ProfileV3PassportField?
    private(set) var latestField: ProfileV3PassportField?

    init(upload: @escaping (ProfileV3PassportSide, Data) async throws -> ProfileV3PassportField?) {
        self.upload = upload
    }

    func verify(_ capture: ProfileV3IdentityCapture.Capture) async -> ProfileV3IdentityCapture.Verdict {
        guard let side = ProfileV3PassportSide(piece: capture.piece) else { return .verified }
        guard let data = capture.image.jpegData(compressionQuality: Self.jpegQuality) else {
            return .failed(message: ProfileV3Strings.passportUploadFailed)
        }
        do {
            let field = try await upload(side, data)
            if let field { latestField = field }
            return .verified
        } catch ProfileV3Error.invalidRequest(let message) {
            return .rejected(reason: message ?? ProfileV3Strings.passportUnreadable)
        } catch {
            return .failed(message: ProfileV3Error.message(for: error, fallback: ProfileV3Strings.passportUploadFailed))
        }
    }
}

extension ProfileV3PassportSide {
    init?(piece: ProfileV3CaptureImage) {
        switch piece {
        case .passportFront: self = .front
        case .passportBack: self = .back
        case .selfie: return nil
        }
    }
}

@MainActor
enum ProfileV3PassportScanLauncher {
    private static let analyticsContext = "profile_v3_passport_update"

    static func present(
        using identityCapture: any ProfileV3IdentityCaptureHost,
        from host: UIViewController,
        request: ProfileV3PassportScanRequest,
        onHowUsed: @escaping () -> Void
    ) {
        let verifier = ProfileV3PassportScanVerifier(upload: request.upload)
        var capture = ProfileV3IdentityCapture.Request(
            pieces: [.passportFront, .passportBack],
            flowTitle: ProfileV3Strings.newPassport,
            analyticsContext: analyticsContext,
            verify: { await verifier.verify($0) }
        )
        capture.copy = [
            .passportFront: copy(request.scan.front, title: request.scan.title),
            .passportBack: copy(request.scan.back, title: request.scan.title)
        ]
        capture.progress = .segments(count: 2, filled: 1)
        capture.allowsUploadFromDevice = true
        if request.scan.howUsed != nil {
            capture.headerAccessory = AnyView(ProfileV3HowUsedPill(avatarURL: request.avatarURL, action: onHowUsed))
        }
        identityCapture.presentCapture(capture, from: host) { outcome in
            request.onFinish(verifier.latestField, outcome == .completed)
        }
    }

    private static func copy(_ page: ProfileV3PassportScanPage, title: String?) -> ProfileV3IdentityCapture.PieceCopy {
        ProfileV3IdentityCapture.PieceCopy(title: title, subtitle: page.subtitle, eyebrow: page.title)
    }
}

final class ProfileV3PassportHowUsedHostingController: UIHostingController<ProfileV3PassportHowUsedView> {
    private static let fittedDetent = UISheetPresentationController.Detent.Identifier("profileV3.howUsed.fitted")

    private let viewModel: ProfileV3PassportHowUsedViewModel
    private var fittedHeight: CGFloat?

    init(viewModel: ProfileV3PassportHowUsedViewModel) {
        self.viewModel = viewModel
        super.init(rootView: ProfileV3PassportHowUsedView(viewModel: viewModel, onScan: { _ in }))
        rootView = ProfileV3PassportHowUsedView(
            viewModel: viewModel,
            onScan: { [weak self] _ in self?.dismiss(animated: true) },
            onHeightChange: { [weak self] in self?.fit(height: $0) }
        )
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [
                .custom(identifier: Self.fittedDetent) { [weak self] context in
                    min(self?.fittedHeight ?? context.maximumDetentValue / 2, context.maximumDetentValue)
                }
            ]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = ProfileV3Theme.Sizes.Agent.sheetCornerRadius
        }
    }

    private func fit(height: CGFloat) {
        guard let sheet = sheetPresentationController, height.rounded() != fittedHeight?.rounded() else { return }
        fittedHeight = height
        sheet.animateChanges { sheet.invalidateDetents() }
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(Color(at: .pureWhite))
        viewModel.load()
    }
}
