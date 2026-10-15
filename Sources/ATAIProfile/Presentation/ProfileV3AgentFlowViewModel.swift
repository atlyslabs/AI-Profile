import Combine
import SwiftUI

@MainActor
protocol ProfileV3AgentFlowRouter: AnyObject {
    func dismissAgentFlow()
    func presentPassportScan(_ request: ProfileV3PassportScanRequest)
}

@MainActor
final class ProfileV3AgentFlowViewModel: ObservableObject {

    enum Content {
        case loading
        case form(ProfileV3AgentFormViewModel)
        case failed
    }

    @Published private(set) var content: Content = .loading

    let agent: ProfileV3Agent
    weak var router: ProfileV3AgentFlowRouter?

    private let profileID: String?
    private let repository: any ProfileV3AgentRepository
    private let residenceCode: @MainActor () -> String?
    private var retryTask: Task<Void, Never>?

    init(
        agent: ProfileV3Agent,
        profileID: String? = nil,
        repository: any ProfileV3AgentRepository,
        residenceCode: @escaping @MainActor () -> String? = { nil }
    ) {
        self.agent = agent
        self.profileID = profileID
        self.repository = repository
        self.residenceCode = residenceCode
    }

    var avatarURL: URL? { agent.avatarURL ?? ProfileV3PlaceholderArt.agent(id: agent.id)?.url }
    var sheetTag: String { agent.sheetTag }

    func load() async {
        switch content {
        case .form: return
        case .loading, .failed: break
        }
        content = .loading
        do {
            let finish: () -> Void = { [weak self] in self?.finish() }
            let flow = try await repository.loadAgentFlow(agentID: agent.id, profileID: profileID)
            guard !Task.isCancelled else { return }
            switch flow {
            case .preferences(let form):
                ProfileV3Analytics.screen(.agentForm, agentKey: ProfileV3Analytics.agentKey(agent.id))
                content = .form(
                    ProfileV3AgentFormViewModel(
                        form: form,
                        avatarURL: avatarURL,
                        profileID: profileID,
                        repository: repository,
                        residenceCode: residenceCode,
                        presentPassportScan: { [weak self] in self?.router?.presentPassportScan($0) },
                        onFinish: finish
                    )
                )
            }
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            content = .failed
        }
    }

    func retry() {
        guard case .failed = content else { return }
        retryTask?.cancel()
        retryTask = Task { [weak self] in await self?.load() }
    }

    func finish() {
        router?.dismissAgentFlow()
    }
}
