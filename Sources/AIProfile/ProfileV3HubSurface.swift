import SwiftUI
import UIKit

struct ProfileV3HubSurface: View {
    let navCon: UINavigationController
    let repository: any ProfileV3Repository
    let onClose: () -> Void

    var body: some View {
        ProfileV3HubContainer(navCon: navCon, repository: repository, onClose: onClose)
            .ignoresSafeArea()
    }
}

private struct ProfileV3HubContainer: UIViewControllerRepresentable {
    let navCon: UINavigationController
    let repository: any ProfileV3Repository
    let onClose: () -> Void

    func makeUIViewController(context: Context) -> ProfileV3HubHostingController {
        ProfileV3HubHostingController(
            navCon: navCon,
            repository: repository,
            environment: ProfileV3EntryPoint.environment,
            userFirstName: ProfileV3EntryPoint.environment.account.snapshot().firstName,
            entrySource: .chat,
            onBack: onClose
        )
    }

    func updateUIViewController(_ controller: ProfileV3HubHostingController, context: Context) {}
}
