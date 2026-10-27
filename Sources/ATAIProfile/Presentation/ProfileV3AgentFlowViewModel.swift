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
    private let kyc: (any ProfileV3KYCHost)?
    private let isCoTraveller: Bool
    private let residenceCode: @MainActor () -> String?
    private let onSaved: () -> Void
    private var retryTask: Task<Void, Never>?

    init(
        agent: ProfileV3Agent,
        profileID: String? = nil,
        repository: any ProfileV3AgentRepository,
        kyc: (any ProfileV3KYCHost)? = nil,
        isCoTraveller: Bool = false,
        residenceCode: @escaping @MainActor () -> String? = { nil },
        onSaved: @escaping () -> Void = {}
    ) {
        self.agent = agent
        self.profileID = profileID
        self.repository = repository
        self.kyc = kyc
        self.isCoTraveller = isCoTraveller
        self.residenceCode = residenceCode
        self.onSaved = onSaved
    }

    var avatarURL: URL? { agent.avatarURL ?? ProfileV3PlaceholderArt.agent(id: agent.id)?.url }
    var sheetTag: String { agent.sheetTag }

    func trackScreen() {
        ProfileV3Analytics.agentScreen(agentID: agent.id, travellerId: profileID)
    }

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
                content = .form(
                    ProfileV3AgentFormViewModel(
                        form: form,
                        avatarURL: avatarURL,
                        profileID: profileID,
                        repository: repository,
                        residenceCode: residenceCode,
                        presentPassportScan: { [weak self] in self?.router?.presentPassportScan($0) },
                        onPassportUploaded: { [weak self] in self?.trackPassportUpload($0, profileID: $1) },
                        onSaved: onSaved,
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

    private func trackPassportUpload(_ side: ProfileV3PassportSide, profileID scanProfileID: String?) {
        kyc?.track(.photoUploaded(ProfileV3KYC.PhotoUpload(
            photo: side == .front ? .passportFront : .passportBack,
            travellerID: scanProfileID ?? profileID,
            isCoTraveller: isCoTraveller,
            flow: .passportUpdate,
            actionSource: ProfileV3Analytics.profileSource
        )))
    }
}
