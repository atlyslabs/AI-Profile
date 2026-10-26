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
    @Published var forwardingDraft = ""
    @Published private(set) var isUpdatingForwarding = false
    @Published private(set) var forwardingError: String?
    @Published private(set) var openingAttachmentID: String?
    @Published private(set) var isResolvingScreen = false

    var onIntroAction: (ProfileV3GloveBoxIntro.Action) -> Void = { _ in }
    var onFollowUp: (Entry) -> Void = { _ in }
    var onAddCard: () -> Void = {}

    private var copiedTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?
    private let repository: (any ProfileV3GloveBoxRepository)?
    private var account: ProfileV3GloveBoxAccount?
    private var nextCursor: String?
    private var isPaging = false

    init(gloveBox: ProfileV3GloveBox) {
        self.gloveBox = gloveBox
        repository = nil
    }

    init(repository: any ProfileV3GloveBoxRepository) {
        self.repository = repository
        isResolvingScreen = true
        gloveBox = ProfileV3GloveBox(
            title: ProfileV3GloveBoxCopy.title,
            stage: .intro(Self.intro(subtitle: ProfileV3GloveBoxCopy.activateSubtitle, button: ProfileV3GloveBoxCopy.activateButton))
        )
        load()
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
        guard repository != nil else {
            onIntroAction(intro.action)
            return
        }
        if account?.hasAddress == false {
            createAddress()
        } else {
            load()
        }
    }

    func load() {
        guard let repository else { return }
        isResolvingScreen = true
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            defer { if !Task.isCancelled { isResolvingScreen = false } }
            do {
                let account = try await repository.loadGloveBoxCard()
                guard !Task.isCancelled else { return }
                self.account = account
                guard account.hasAddress else {
                    showIntro()
                    return
                }
                let page = try await repository.loadGloveBoxMessages(cursor: nil)
                guard !Task.isCancelled else { return }
                showInbox(page, replacing: true)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                showIntro(error: error)
            }
        }
    }

    func createAddress() {
        guard let repository, account?.hasAddress != true else { return }
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let account = try await repository.createGloveBoxAddress()
                guard !Task.isCancelled else { return }
                self.account = account
                let page = try await repository.loadGloveBoxMessages(cursor: nil)
                guard !Task.isCancelled else { return }
                showInbox(page, replacing: true)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                showIntro(error: error)
            }
        }
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
        if section == .emails { loadMoreEmails() }
    }

    func open(_ entry: Entry) {
        guard home != nil else { return }
        withAnimation(ProfileV3Theme.GloveBox.Motion.sheetSwitch) { sheets.append(.detail(entry)) }
        if case .email(let email) = entry { loadEmail(email) }
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

    func toggleForwarding() {
        guard let repository, let account, account.forwardingEmail != nil, !isUpdatingForwarding else { return }
        let paused = !account.forwardingPaused
        isUpdatingForwarding = true
        forwardingError = nil
        loadTask = Task { [weak self] in
            guard let self else { return }
            defer { isUpdatingForwarding = false }
            do {
                let updated = try await repository.setGloveBoxForwardingPaused(paused)
                guard !Task.isCancelled else { return }
                self.account = updated
                refreshEmailSection()
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                forwardingError = ProfileV3GloveBoxMapper.message(for: error)
            }
        }
    }

    func sendForwardingAddress() {
        guard let repository, account?.forwardingEmail == nil, !isUpdatingForwarding else { return }
        let email = forwardingDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else { return }
        isUpdatingForwarding = true
        forwardingError = nil
        loadTask = Task { [weak self] in
            guard let self else { return }
            defer { isUpdatingForwarding = false }
            do {
                let updated = try await repository.addGloveBoxForwardingAddress(email)
                guard !Task.isCancelled else { return }
                self.account = updated
                forwardingDraft = ""
                refreshEmailSection()
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                forwardingError = ProfileV3GloveBoxMapper.message(for: error)
            }
        }
    }

    func openAttachment(_ attachment: ProfileV3GloveBoxAttachment, messageID: String) {
        guard let repository, openingAttachmentID == nil else { return }
        let token = "\(messageID)-\(attachment.index)"
        openingAttachmentID = token
        Task { [weak self] in
            guard let self else { return }
            defer { openingAttachmentID = nil }
            do {
                let data = try await repository.loadGloveBoxAttachment(messageID: messageID, index: attachment.index)
                let name = attachment.filename.replacingOccurrences(of: "/", with: "-")
                let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
                try data.write(to: url, options: .atomic)
                presentShare(url)
            } catch {
                forwardingError = nil
                replaceNoteError(ProfileV3GloveBoxMapper.message(for: error), messageID: messageID)
            }
        }
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

    private func showIntro(error: Error? = nil) {
        let subtitle = error.map(ProfileV3GloveBoxMapper.message) ?? ProfileV3GloveBoxCopy.activateSubtitle
        let button = error == nil ? ProfileV3GloveBoxCopy.activateButton : ProfileV3GloveBoxCopy.tryAgain
        show(.intro(Self.intro(subtitle: subtitle, button: button)))
    }

    private func showInbox(_ page: ProfileV3GloveBoxInboxPage, replacing: Bool) {
        guard let account, account.hasAddress else { return }
        nextCursor = page.nextCursor
        let emails = replacing ? page.emails : (home?.email.emails ?? []) + page.emails
        let section = ProfileV3GloveBoxMapper.section(
            account: account,
            emails: emails,
            hasMore: page.nextCursor != nil
        )
        show(.home(ProfileV3GloveBoxMapper.home(email: section)))
    }

    private func loadMoreEmails() {
        guard let repository, let cursor = nextCursor, !isPaging else { return }
        isPaging = true
        loadTask = Task { [weak self] in
            guard let self else { return }
            defer { isPaging = false }
            do {
                let page = try await repository.loadGloveBoxMessages(cursor: cursor)
                guard !Task.isCancelled else { return }
                append(page)
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }

    private func append(_ page: ProfileV3GloveBoxInboxPage) {
        guard let account, case .home(var home) = gloveBox.stage else { return }
        let known = Set(home.email.emails.map(\.id))
        nextCursor = page.nextCursor
        home.email = ProfileV3GloveBoxMapper.section(
            account: account,
            emails: home.email.emails + page.emails.filter { known.contains($0.id) == false },
            hasMore: page.nextCursor != nil
        )
        gloveBox.stage = .home(home)
    }

    private func loadEmail(_ email: ProfileV3GloveBoxEmail) {
        guard let repository else { return }
        loadTask = Task { [weak self] in
            guard let self else { return }
            guard let detailed = try? await repository.loadGloveBoxMessage(email) else { return }
            guard !Task.isCancelled else { return }
            replace(detailed)
        }
    }

    private func refreshEmailSection() {
        guard let account, case .home(var home) = gloveBox.stage else { return }
        home.email = ProfileV3GloveBoxMapper.section(
            account: account,
            emails: home.email.emails,
            hasMore: nextCursor != nil
        )
        gloveBox.stage = .home(home)
    }

    private func replaceNoteError(_ message: String, messageID: String) {
        guard case .home(var home) = gloveBox.stage,
              let index = home.email.emails.firstIndex(where: { $0.id == messageID }) else { return }
        home.email.emails[index].attention = ProfileV3GloveBoxEmail.Attention(title: message)
        let email = home.email.emails[index]
        gloveBox.stage = .home(home)
        sheets = sheets.map { sheet in
            guard case .detail(.email(let shown)) = sheet, shown.id == messageID else { return sheet }
            return .detail(.email(email))
        }
    }

    private func presentShare(_ url: URL) {
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
              let root = scene.windows.first(where: \.isKeyWindow)?.rootViewController else { return }
        var top = root
        while let presented = top.presentedViewController { top = presented }
        top.present(controller, animated: true)
    }

    private func replace(_ email: ProfileV3GloveBoxEmail) {
        guard case .home(var home) = gloveBox.stage else { return }
        if let index = home.email.emails.firstIndex(where: { $0.id == email.id }) {
            home.email.emails[index] = email
        }
        gloveBox.stage = .home(home)
        sheets = sheets.map { sheet in
            guard case .detail(.email(let shown)) = sheet, shown.id == email.id else { return sheet }
            return .detail(.email(email))
        }
    }

    private static func intro(subtitle: String, button: String) -> ProfileV3GloveBoxIntro {
        ProfileV3GloveBoxIntro(
            title: ProfileV3GloveBoxCopy.activateTitle,
            subtitle: subtitle,
            status: .warmingUp,
            statusLabel: ProfileV3GloveBoxCopy.activateButton,
            actionTitle: button,
            action: .activate
        )
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
