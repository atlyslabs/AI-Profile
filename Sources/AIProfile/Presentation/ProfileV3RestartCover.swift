import ATUIKit
import SwiftUI
import UIKit

@MainActor
enum ProfileV3RestartCover {
    private static var window: UIWindow?
    private static var isSplashFinished = false

    static func show(app: any ProfileV3AppHost) async {
        guard window == nil, let scene = ProfileV3SheetWindow.keyWindow()?.windowScene else { return }
        isSplashFinished = false
        let cover = UIWindow(windowScene: scene)
        cover.windowLevel = .alert + 2
        let splash = app.restartSplash(onFinish: { isSplashFinished = true })
        let host = UIHostingController(rootView: ProfileV3RestartCoverView(splash: splash))
        host.view.backgroundColor = .clear
        cover.rootViewController = host
        cover.alpha = 0
        cover.isHidden = false
        window = cover
        await withCheckedContinuation { continuation in
            UIView.animate(
                withDuration: ProfileV3Theme.Motion.restartCoverFadeSeconds,
                animations: { cover.alpha = 1 },
                completion: { _ in continuation.resume() }
            )
        }
    }

    static func hide(afterRestartOf navCon: UINavigationController, navigation: any ProfileV3NavigationHost) {
        Task {
            let deadline = ContinuousClock.now + .seconds(ProfileV3Theme.Motion.restartCoverTimeoutSeconds)
            while isWaiting(on: navCon, navigation: navigation), ContinuousClock.now < deadline {
                try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.restartCoverPollMilliseconds))
            }
            guard let cover = window else { return }
            window = nil
            UIView.animate(
                withDuration: ProfileV3Theme.Motion.restartCoverFadeSeconds,
                animations: { cover.alpha = 0 },
                completion: { _ in cover.isHidden = true }
            )
        }
    }

    private static func isWaiting(
        on navCon: UINavigationController,
        navigation: any ProfileV3NavigationHost
    ) -> Bool {
        let isRestarting = navigation.isRestarting(navCon) && navCon.presentedViewController == nil
        return isRestarting || !isSplashFinished
    }
}

private struct ProfileV3RestartCoverView: View {
    let splash: AnyView

    var body: some View {
        splash
            .background(Color(at: .pureWhite).ignoresSafeArea())
    }
}
