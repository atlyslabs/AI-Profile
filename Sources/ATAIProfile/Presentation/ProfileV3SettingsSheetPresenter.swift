import ATUIKit
import SwiftUI
import UIKit

@MainActor
final class ProfileV3SettingsSheetPresenter {

    private unowned let navCon: UINavigationController
    private let onboarding: ProfileV3OnboardingPresentation
    private let repository: any ProfileV3SettingsRepository
    private let kyc: any ProfileV3KYCHost
    private let account: any ProfileV3AccountHost
    private let coupons: any ProfileV3CouponsHost
    private let app: any ProfileV3AppHost
    private let viewModel: ProfileV3SettingsViewModel
    private let onConnectConnector: ((String) -> Void)?
    private let onTravellersChanged: (() -> Void)?
    private let onConnectorsDisconnected: ((Set<ProfileV3ConnectorKey>) -> Void)?
    private let onOpenProgrammes: (() -> Void)?
    private let onFinish: (ProfileV3SettingsSheetPresenter) -> Void
    private var afterDismiss: (@MainActor () -> Void)?
    private var disconnectedConnectors: Set<ProfileV3ConnectorKey> = []
    private var isAwaitingOnboarding = false
    private var didReportFinish = false
    private weak var disconnectHost: UIViewController?
    private var isDisconnectProgressPresented = false
    private weak var pageHost: UIViewController?
    private let pageTransition = ProfileV3PushTransition()
    private var isPagePresented = false
    private var isSheetPresented = false
    private var isFinished = false

    init(
        navCon: UINavigationController,
        onboarding: ProfileV3OnboardingPresentation,
        repository: any ProfileV3SettingsRepository,
        board: (any ProfileV3BoardRepository)?,
        kyc: any ProfileV3KYCHost,
        account: any ProfileV3AccountHost,
        coupons: any ProfileV3CouponsHost,
        app: any ProfileV3AppHost,
        session: any ProfileV3SessionProviding,
        client: ProfileV3NetworkClient,
        profileID: String?,
        profileName: String?,
        onConnectConnector: ((String) -> Void)?,
        onTravellersChanged: (() -> Void)?,
        onConnectorsDisconnected: ((Set<ProfileV3ConnectorKey>) -> Void)?,
        onOpenProgrammes: (() -> Void)?,
        onFinish: @escaping (ProfileV3SettingsSheetPresenter) -> Void
    ) {
        self.navCon = navCon
        self.onboarding = onboarding
        self.repository = repository
        self.kyc = kyc
        self.account = account
        self.coupons = coupons
        self.app = app
        self.onConnectConnector = onConnectConnector
        self.onTravellersChanged = onTravellersChanged
        self.onConnectorsDisconnected = onConnectorsDisconnected
        self.onOpenProgrammes = onOpenProgrammes
        self.onFinish = onFinish
        viewModel = ProfileV3SettingsViewModel(
            deps: .live(account: account, session: session, client: client),
            repository: repository,
            board: board,
            profileID: profileID,
            profileName: profileName
        )
        viewModel.router = self
    }

    func present() {
        guard let top = Self.topPresented() else { return }
        ProfileV3Analytics.screen(.settings)
        let host = ProfileV3PageHostingController(rootView: ProfileV3SettingsView(viewModel: viewModel))
        host.modalPresentationStyle = .overFullScreen
        host.transitioningDelegate = pageTransition
        host.onDismissed = { [weak self] in self?.pageDidDismiss() }
        pageHost = host
        isPagePresented = true
        top.present(host, animated: true)
    }

    var isOpen: Bool { !isFinished }

    func presentAddTraveller() {
        viewModel.travellers.open()
        viewModel.travellers.tapAdd()
    }

    func close(then action: @escaping () -> Void) {
        afterDismiss = { @MainActor in action() }
        closeAll(animated: true)
    }

    private func closeAll(animated: Bool) {
        if isSheetPresented {
            closeSheet(animated: animated)
        }
        guard isPagePresented, let pageHost, pageHost.presentingViewController != nil else {
            isPagePresented = false
            if !isSheetPresented {
                finishDismiss()
            }
            return
        }
        pageHost.dismiss(animated: animated)
    }

    private func pageDidDismiss() {
        guard isPagePresented else { return }
        isPagePresented = false
        if !isSheetPresented {
            finishDismiss()
        }
    }

    private func sheetDidDismiss() {
        isSheetPresented = false
        viewModel.sheetDidDismiss()
        if !isPagePresented {
            finishDismiss()
        }
    }

    private func finishDismiss() {
        guard !isFinished else { return }
        isFinished = true
        viewModel.cancelReads()
        let completion = afterDismiss
        afterDismiss = nil
        withExtendedLifetime(self) {
            if completion == nil, !disconnectedConnectors.isEmpty {
                onConnectorsDisconnected?(disconnectedConnectors)
            }
            completion?()
            if !isAwaitingOnboarding {
                reportFinish()
            }
        }
    }

    private func closeSheet(animated: Bool) {
        guard let top = Self.topPresented(), top.presentingViewController != nil, !top.isBeingDismissed,
              top !== pageHost else {
            ATBottomSheetWindowPresenter.dismiss(animated: animated)
            return
        }
        top.dismiss(animated: false) {
            ATBottomSheetWindowPresenter.dismiss(animated: animated)
        }
    }

    private static func topPresented() -> UIViewController? {
        guard let root = ProfileV3SheetWindow.keyWindow()?.rootViewController else { return nil }
        var current = root
        while let presented = current.presentedViewController {
            current = presented
        }
        return current
    }
}

extension ProfileV3SettingsSheetPresenter: ProfileV3SettingsSheetRouting {

    func presentSheet() {
        guard !isSheetPresented, let entry = viewModel.sheetEntry else { return }
        isSheetPresented = true
        let viewModel = viewModel
        ProfileV3SheetWindow.present(
            dismissOnBackdropTap: false,
            onDismiss: { [weak self] in self?.sheetDidDismiss() }
        ) { maxHeight, bottomInset in
            ProfileV3SettingsSheetView(
                viewModel: viewModel,
                entry: entry,
                maxHeight: maxHeight,
                bottomInset: bottomInset
            )
        }
    }

    func dismissSheet() {
        guard isSheetPresented else { return }
        closeSheet(animated: true)
    }

    func dismissSettings() {
        closeAll(animated: true)
    }

    func restartAfterSaving(_ pendingWrites: Task<Void, Never>?) {
        let app = app
        Task {
            await ProfileV3WriteQueue.wait(
                for: pendingWrites,
                timeout: .seconds(ProfileV3Theme.Motion.settingsWriteTimeoutSeconds)
            )
            afterDismiss = { app.restartApp() }
            closeAll(animated: false)
        }
    }

    func dismissSettingsThenRestart(after pendingWrites: Task<Void, Never>?) {
        let app = app
        afterDismiss = {
            Task { @MainActor in
                await ProfileV3WriteQueue.wait(
                    for: pendingWrites,
                    timeout: .seconds(ProfileV3Theme.Motion.settingsWriteTimeoutSeconds)
                )
                app.restartApp()
            }
        }
        dismissSettings()
    }

    func openExternalURL(_ url: URL) {
        ProfileV3Analytics.deepLinkOpened(urlPath: (url.host ?? "") + url.path)
        UIApplication.shared.open(url)
    }

    func presentCoupons() {
        guard let presenter = Self.topPresented() else { return }
        coupons.presentCoupons(from: presenter)
    }

}

extension ProfileV3SettingsSheetPresenter: ProfileV3TravellersRouting {
    func travellerDidChange() {
        account.travellerProfileDidChange()
    }

    func travellersDidChange() {
        onTravellersChanged?()
    }
}

extension ProfileV3SettingsSheetPresenter: ProfileV3ConnectorsRouting {
    func presentConnectorOnboarding() {
        afterDismiss = { [weak self] in self?.startConnectorOnboarding() }
        dismissSettings()
    }

    private func startConnectorOnboarding() {
        let navCon = navCon
        let origin = navCon.topViewController
        isAwaitingOnboarding = true
        ProfileV3OnboardingLauncher.start(onboarding, using: kyc, on: navCon) { [weak self] _ in
            guard let self else { return }
            isAwaitingOnboarding = false
            reportFinish()
            guard let origin, navCon.topViewController !== origin else { return }
            _ = navCon.popToViewController(origin, animated: true)
        }
    }

    private func reportFinish() {
        guard !didReportFinish else { return }
        didReportFinish = true
        onFinish(self)
    }

    func startConnectorCapture(_ step: String) {
        guard let onConnectConnector else { return }
        afterDismiss = { onConnectConnector(step) }
        dismissSettings()
    }

    func presentDisconnectEmail() {
        let host = ProfileV3SubFlowHostingController(
            rootView: ProfileV3DisconnectEmailHost(
                model: viewModel.connectors,
                onClose: { [weak self] in self?.dismissDisconnectEmail() }
            )
        )
        disconnectHost = host
        host.modalPresentationStyle = .fullScreen
        Self.topPresented()?.present(host, animated: true)
    }

    func dismissDisconnectEmail() {
        disconnectHost?.dismiss(animated: true)
        disconnectHost = nil
    }

    func presentDisconnectProgress() {
        guard !isDisconnectProgressPresented else { return }
        isDisconnectProgressPresented = true
        let connectors = viewModel.connectors
        ProfileV3SheetWindow.present(
            dismissOnBackdropTap: false,
            onDismiss: {}
        ) { _, bottomInset in
            ProfileV3DisconnectProgressSheet(bottomInset: bottomInset, onStop: connectors.stopDisconnecting)
        }
    }

    func dismissDisconnectProgress() {
        guard isDisconnectProgressPresented else { return }
        isDisconnectProgressPresented = false
        ProfileV3SheetWindow.dismiss()
    }

    func connectorDidDisconnect(_ connector: ProfileV3ConnectorKey) {
        disconnectedConnectors.insert(connector)
    }
}

extension ProfileV3SettingsSheetPresenter {
    func presentLoyaltyProgrammes() {
        onOpenProgrammes?()
    }

    func presentTermsOfService() {
        Self.topPresented()?.present(ProfileV3EntryPoint.makeTerms(repository: repository), animated: true)
    }

}

extension ProfileV3SettingsSheetPresenter: ProfileV3SessionRouting, ProfileV3SettingsFeedbackRouting {
    func performLogout() {
        app.logOut()
        dismissSettingsThenRestart(after: nil)
    }

    func showFlash(_ text: String, isSuccess: Bool) {
        HapticFeedbackGenerator.generateHapticFeedback(type: isSuccess ? .success : .error)
        app.showStatusMessage(text, isSuccess: isSuccess)
    }
}
