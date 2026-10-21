import SwiftUI
import UIKit

@MainActor
final class ProfileV3GloveBoxViewModel: ObservableObject {
    @Published private(set) var gloveBox: ProfileV3GloveBox
    @Published private(set) var openEmail: ProfileV3GloveBoxEmail?
    @Published private(set) var isCopied = false
    @Published private(set) var copies = 0

    var onIntroAction: (ProfileV3GloveBoxIntro.Action) -> Void = { _ in }
    var onFollowUp: (ProfileV3GloveBoxEmail) -> Void = { _ in }

    private var copiedTask: Task<Void, Never>?

    init(gloveBox: ProfileV3GloveBox) {
        self.gloveBox = gloveBox
    }

    func show(_ stage: ProfileV3GloveBox.Stage) {
        withAnimation(ProfileV3Theme.GloveBox.Motion.stageSwitch) {
            gloveBox.stage = stage
        }
    }

    func tapIntroAction() {
        guard case .intro(let intro) = gloveBox.stage else { return }
        onIntroAction(intro.action)
    }

    func copyAddress() {
        guard case .inbox(let inbox) = gloveBox.stage else { return }
        UIPasteboard.general.string = inbox.address
        copies += 1
        withAnimation(ProfileV3Theme.Motion.selection) { isCopied = true }
        copiedTask?.cancel()
        copiedTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.copiedResetSeconds))
            guard !Task.isCancelled else { return }
            withAnimation(ProfileV3Theme.Motion.selection) { self?.isCopied = false }
        }
    }

    func open(_ email: ProfileV3GloveBoxEmail) {
        withAnimation(ProfileV3Theme.GloveBox.Motion.detail) { openEmail = email }
    }

    func closeEmail() {
        withAnimation(ProfileV3Theme.GloveBox.Motion.detail) { openEmail = nil }
    }

    func tapFollowUp() {
        guard let openEmail else { return }
        onFollowUp(openEmail)
    }
}
