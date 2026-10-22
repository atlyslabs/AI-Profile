import SwiftUI
import UIKit

@MainActor
final class ProfileV3GloveBoxViewModel: ObservableObject {
    enum Section: Hashable {
        case emails
        case calls
        case transactions
    }

    enum Entry: Equatable {
        case email(ProfileV3GloveBoxEmail)
        case call(ProfileV3GloveBoxCall)
        case transaction(ProfileV3GloveBoxTransaction)
    }

    enum Sheet: Equatable {
        case list(Section)
        case detail(Entry)
    }

    enum CopyTarget: Hashable {
        case address
        case number
        case tripNumber
    }

    @Published private(set) var gloveBox: ProfileV3GloveBox
    @Published private(set) var sheets: [Sheet] = []
    @Published private(set) var copied: CopyTarget?
    @Published private(set) var copies = 0
    @Published private(set) var showsCardNotice = false

    var onIntroAction: (ProfileV3GloveBoxIntro.Action) -> Void = { _ in }
    var onFollowUp: (Entry) -> Void = { _ in }
    var onAddCard: () -> Void = {}

    private var copiedTask: Task<Void, Never>?

    init(gloveBox: ProfileV3GloveBox) {
        self.gloveBox = gloveBox
    }

    var home: ProfileV3GloveBoxHome? {
        guard case .home(let home) = gloveBox.stage else { return nil }
        return home
    }

    func show(_ stage: ProfileV3GloveBox.Stage) {
        withAnimation(ProfileV3Theme.GloveBox.Motion.stageSwitch) {
            gloveBox.stage = stage
            sheets = []
            showsCardNotice = false
        }
    }

    func tapIntroAction() {
        guard case .intro(let intro) = gloveBox.stage else { return }
        onIntroAction(intro.action)
    }

    func copy(_ target: CopyTarget) {
        guard let value = copyValue(for: target) else { return }
        UIPasteboard.general.string = value
        copies += 1
        withAnimation(ProfileV3Theme.Motion.selection) { copied = target }
        copiedTask?.cancel()
        copiedTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.copiedResetSeconds))
            guard !Task.isCancelled else { return }
            withAnimation(ProfileV3Theme.Motion.selection) { self?.copied = nil }
        }
    }

    func openList(_ section: Section) {
        guard home != nil else { return }
        withAnimation(ProfileV3Theme.GloveBox.Motion.sheetSwitch) { sheets = [.list(section)] }
    }

    func open(_ entry: Entry) {
        guard home != nil else { return }
        withAnimation(ProfileV3Theme.GloveBox.Motion.sheetSwitch) { sheets.append(.detail(entry)) }
    }

    func back() {
        guard !sheets.isEmpty else { return }
        withAnimation(ProfileV3Theme.GloveBox.Motion.sheetSwitch) { _ = sheets.removeLast() }
    }

    func dismissSheets() {
        withAnimation(ProfileV3Theme.GloveBox.Motion.sheetSwitch) { sheets = [] }
    }

    func sheetsDidClose() {
        sheets = []
    }

    func tapFollowUp() {
        guard case .detail(let entry) = sheets.last else { return }
        onFollowUp(entry)
    }

    func sampleLabel(for entry: Entry) -> String? {
        switch entry {
        case .email: return home?.email.sampleLabel
        case .call: return home?.phone.sampleLabel
        case .transaction: return nil
        }
    }

    func selectPayOption(_ id: String) {
        guard home?.card.selectedPayOptionID != id else { return }
        withAnimation(ProfileV3Theme.Motion.selection) {
            updateCard { $0.selectedPayOptionID = id }
        }
    }

    func tapAddCard() {
        onAddCard()
    }

    func linkCard(_ card: ProfileV3GloveBoxCardSection.LinkedCard) {
        withAnimation(ProfileV3Theme.GloveBox.Motion.notice) {
            updateCard { $0.linkedCard = card }
        }
    }

    func showCardNotice() {
        guard home != nil, !showsCardNotice else { return }
        withAnimation(ProfileV3Theme.GloveBox.Motion.notice) { showsCardNotice = true }
    }

    func hideCardNotice() {
        withAnimation(ProfileV3Theme.GloveBox.Motion.notice) { showsCardNotice = false }
    }

    private func copyValue(for target: CopyTarget) -> String? {
        guard let home else { return nil }
        switch target {
        case .address:
            return home.email.address
        case .number:
            return home.phone.number.isCopyable ? home.phone.number.value : nil
        case .tripNumber:
            guard let number = home.phone.trip?.number, number.isCopyable else { return nil }
            return number.value
        }
    }

    private func updateCard(_ update: (inout ProfileV3GloveBoxCardSection) -> Void) {
        guard case .home(var home) = gloveBox.stage else { return }
        update(&home.card)
        gloveBox.stage = .home(home)
    }
}

extension ProfileV3GloveBoxViewModel.Entry: Identifiable {
    var id: String {
        switch self {
        case .email(let email): return "email-\(email.id)"
        case .call(let call): return "call-\(call.id)"
        case .transaction(let transaction): return "transaction-\(transaction.id)"
        }
    }
}

extension ProfileV3GloveBoxViewModel.Sheet: Identifiable {
    var id: String {
        switch self {
        case .list(let section): return "list-\(section)"
        case .detail(let entry): return "detail-\(entry.id)"
        }
    }
}
