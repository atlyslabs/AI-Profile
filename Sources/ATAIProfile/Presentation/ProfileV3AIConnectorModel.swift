import Combine
import Foundation
import UIKit

@MainActor
final class ProfileV3AIConnectorModel: ObservableObject, Identifiable {
    enum Step: Equatable {
        case detail
        case connect
    }

    @Published private(set) var step: Step = .detail
    @Published private(set) var detail: ProfileV3AIConnector?
    @Published private(set) var detailPhase: ProfileV3LoadPhase = .loading
    @Published private(set) var connect: ProfileV3AIConnectorConnect?
    @Published private(set) var connectPhase: ProfileV3LoadPhase = .loading
    @Published var answer = "" {
        didSet {
            guard answer != oldValue, errorMessage != nil else { return }
            errorMessage = nil
        }
    }
    @Published private(set) var isCopied = false
    @Published private(set) var copies = 0
    @Published private(set) var isSaving = false
    @Published private(set) var errorMessage: String?

    let id: String

    private let repository: any ProfileV3AIConnectorRepository
    private let copyText: @MainActor (String) -> Void
    private let onConnected: () -> Void
    private let onClose: () -> Void
    private var detailTask: Task<Void, Never>?
    private var connectTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?
    private var copiedTask: Task<Void, Never>?

    init(
        connector: String,
        repository: any ProfileV3AIConnectorRepository,
        copyText: @escaping @MainActor (String) -> Void = { UIPasteboard.general.string = $0 },
        onConnected: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        id = connector
        self.repository = repository
        self.copyText = copyText
        self.onConnected = onConnected
        self.onClose = onClose
    }

    var canSave: Bool {
        connect?.submit != nil && !isSaving && !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var copyTitle: String {
        guard let prompt = connect?.prompt else { return "" }
        return isCopied && !prompt.copiedLabel.isEmpty ? prompt.copiedLabel : prompt.copyLabel
    }

    func start() {
        guard detail == nil, detailTask == nil else { return }
        loadDetail()
    }

    func loadDetail() {
        detailTask?.cancel()
        detailPhase = .loading
        let repository = repository
        let connector = id
        detailTask = Task { [weak self] in
            do {
                let screen = try await repository.loadAIConnector(connector)
                guard let self, !Task.isCancelled else { return }
                detail = screen
                detailPhase = .loaded
            } catch {
                guard let self, !Task.isCancelled else { return }
                detailPhase = .failed
            }
        }
    }

    func getStarted() {
        guard step == .detail else { return }
        step = .connect
        if connect == nil { loadConnect() }
    }

    func loadConnect() {
        connectTask?.cancel()
        connectPhase = .loading
        let repository = repository
        let connector = connectorForConnect
        connectTask = Task { [weak self] in
            do {
                let screen = try await repository.loadAIConnectorConnect(connector)
                guard let self, !Task.isCancelled else { return }
                connect = screen
                connectPhase = .loaded
            } catch {
                guard let self, !Task.isCancelled else { return }
                connectPhase = .failed
            }
        }
    }

    func copyPrompt() {
        guard let prompt = connect?.prompt else { return }
        copyText(prompt.text)
        copies += 1
        isCopied = true
        copiedTask?.cancel()
        copiedTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.aiConnectorCopiedSeconds))
            guard let self, !Task.isCancelled else { return }
            isCopied = false
        }
    }

    func save() {
        guard canSave, let submit = connect?.submit else { return }
        isSaving = true
        errorMessage = nil
        let text = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        let repository = repository
        saveTask = Task { [weak self] in
            do {
                try await repository.connectAIConnector(submit, text: text)
                guard let self else { return }
                isSaving = false
                onConnected()
                close()
            } catch is CancellationError {
                self?.isSaving = false
            } catch {
                guard let self else { return }
                isSaving = false
                errorMessage = ProfileV3Error.message(for: error, fallback: ProfileV3Strings.saveFailed)
            }
        }
    }

    func close() {
        cancel()
        onClose()
    }

    func cancel() {
        detailTask?.cancel()
        connectTask?.cancel()
        copiedTask?.cancel()
    }

    private var connectorForConnect: String {
        if case .aiConnectorConnect(let connector)? = detail?.next?.route() { return connector }
        return id
    }
}
