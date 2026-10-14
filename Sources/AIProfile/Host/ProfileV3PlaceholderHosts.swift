import SwiftUI
import UIKit

struct ProfileV3PlaceholderGlobeRenderer {
    private static let dotCount = 900
    private static let goldenAngle = 2.399963229728653

    nonisolated init() {}
}

extension ProfileV3PlaceholderGlobeRenderer: ProfileV3GlobeRendering {
    func prepare(_ appearance: ProfileV3Globe.Appearance) async {}

    func drawLand(
        _ appearance: ProfileV3Globe.Appearance,
        in context: GraphicsContext,
        projection: ProfileV3Globe.Projection
    ) {
        let dotRadius = projection.radius * appearance.dotScale
        var dots = Path()
        for index in 0 ..< Self.dotCount {
            let y = 1 - Double(index) / Double(Self.dotCount - 1) * 2
            let ring = (1 - y * y).squareRoot()
            let angle = Double(index) * Self.goldenAngle
            let (point, depth) = projection.project(x: cos(angle) * ring, y: y, z: sin(angle) * ring)
            guard depth > 0 else { continue }
            dots.addEllipse(in: CGRect(
                x: point.x - dotRadius,
                y: point.y - dotRadius,
                width: dotRadius * 2,
                height: dotRadius * 2
            ))
        }
        context.fill(dots, with: .color(appearance.interior.opacity(appearance.interiorOpacity)))
    }
}

#if DEBUG
@MainActor
final class ProfileV3PlaceholderKYCHost: ProfileV3KYCHost {
    func startOnboarding(
        on navigationController: UINavigationController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) {
        completion(.cancelled)
    }

    func presentMinimalCapture(
        from presenter: UIViewController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) {
        completion(.cancelled)
    }

    func gmailConnectView(
        _ screen: ProfileV3KYC.GmailConnectScreen,
        actions: ProfileV3KYC.GmailConnectActions
    ) -> AnyView {
        placeholder("Gmail connector", detail: screen.content.title)
    }

    func itrConnectView(_ screen: ProfileV3KYC.ITRConnectScreen, actions: ProfileV3KYC.ITRConnectActions) -> AnyView {
        placeholder("ITR connector", detail: screen.content.title)
    }

    func passportCaptureView(
        _ screen: ProfileV3KYC.PassportCaptureScreen,
        actions: ProfileV3KYC.PassportCaptureActions
    ) -> AnyView {
        placeholder("Passport capture", detail: screen.front?.title)
    }

    func selfieCaptureView(
        _ screen: ProfileV3KYC.SelfieCaptureScreen,
        actions: ProfileV3KYC.SelfieCaptureActions
    ) -> AnyView {
        placeholder("Selfie capture", detail: screen.copy?.title)
    }

    func authorizeGmail() async -> String? { nil }

    func track(_ event: ProfileV3KYC.Event) {}

    private func placeholder(_ name: String, detail: String?) -> AnyView {
        AnyView(
            VStack(spacing: 8) {
                Text(name).font(.headline)
                if let detail { Text(detail).font(.subheadline) }
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
}

final class ProfileV3PlaceholderAnalytics: ProfileV3AnalyticsReporting, @unchecked Sendable {
    func logEvent(_ name: String, asScreenView: Bool, parameters: [String: Any]) {}
}

final class ProfileV3PlaceholderFieldValidator: ProfileV3FieldValidating, @unchecked Sendable {
    func isValidEmail(_ email: String) -> Bool {
        email.range(
            of: #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"#,
            options: .regularExpression
        ) != nil
    }

    func isValidPassportNumber(_ number: String, nationality: String?) -> Bool {
        let pattern = nationality == "India" ? #"^[A-Z][A-Z0-9][0-9]{6}$"# : #"^[A-Z0-9]{6,10}$"#
        return number.uppercased().range(of: pattern, options: .regularExpression) != nil
    }
}

@MainActor
final class ProfileV3PlaceholderNavigationHost: ProfileV3NavigationHost {
    func restartApp() {}

    func isRestarting(_ navigationController: UINavigationController) -> Bool { false }
}
#endif
