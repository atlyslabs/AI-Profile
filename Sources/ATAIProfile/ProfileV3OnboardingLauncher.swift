import UIKit

enum ProfileV3OnboardingPresentation {
    case push
    case fullScreen
}

@MainActor
enum ProfileV3OnboardingLauncher {
    static func start(
        _ presentation: ProfileV3OnboardingPresentation,
        using kyc: any ProfileV3KYCHost,
        on navCon: UINavigationController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) {
        switch presentation {
        case .push:
            kyc.startOnboarding(on: navCon, completion: completion)
        case .fullScreen:
            startFullScreen(using: kyc, over: navCon, completion: completion)
        }
    }

    private static func startFullScreen(
        using kyc: any ProfileV3KYCHost,
        over navCon: UINavigationController,
        completion: @escaping @MainActor (ProfileV3FlowOutcome) -> Void
    ) {
        let container = UINavigationController()
        container.setNavigationBarHidden(true, animated: false)
        container.modalPresentationStyle = .fullScreen
        var hasFinished = false
        kyc.startOnboarding(on: container) { [weak container] outcome in
            hasFinished = true
            guard let container, container.presentingViewController != nil, !container.isBeingDismissed else {
                completion(outcome)
                return
            }
            let dismiss = { container.dismiss(animated: true) { completion(outcome) } }
            if container.isBeingPresented,
               let coordinator = container.transitionCoordinator,
               coordinator.animate(alongsideTransition: nil, completion: { _ in dismiss() }) {
                return
            }
            dismiss()
        }
        guard !hasFinished else { return }
        topPresented(from: navCon).present(container, animated: true)
    }

    private static func topPresented(from root: UIViewController) -> UIViewController {
        var top = root
        while let next = top.presentedViewController, !next.isBeingDismissed {
            top = next
        }
        return top
    }
}
