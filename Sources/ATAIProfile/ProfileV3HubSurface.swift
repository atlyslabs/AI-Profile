import SwiftUI
import UIKit

struct ProfileV3HubSurface: View {
    let onClose: () -> Void

    var body: some View {
        ProfileV3HubContainer(onClose: onClose)
            .ignoresSafeArea()
    }
}

private struct ProfileV3HubContainer: UIViewControllerRepresentable {
    let onClose: () -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        let hub = ProfileV3HubHostingController(
            navCon: navigationController,
            repository: ProfileV3EntryPoint.makeRepository(),
            environment: ProfileV3EntryPoint.environment,
            userFirstName: ProfileV3EntryPoint.environment.account.snapshot().firstName,
            entrySource: .chat,
            onBack: onClose
        )
        navigationController.setViewControllers([hub], animated: false)
        return navigationController
    }

    func updateUIViewController(_ navigationController: UINavigationController, context: Context) {}
}
