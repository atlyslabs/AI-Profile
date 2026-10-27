import Combine
import SwiftUI

struct ProfileV3HeroState: Equatable {
    var frame: CGRect
    var cornerRadius: CGFloat
    var backdropOpacity: Double = 0
    var progress: CGFloat = 0
}

@MainActor
final class ProfileV3HubStage: ObservableObject {

    enum EntryStage: Int, Comparable {
        case hidden
        case podium
        case cards
        case details
        case complete

        static func < (lhs: EntryStage, rhs: EntryStage) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    enum EntryDetail: Equatable {
        case kyc
        case giftCards
        case featuredBenefit
        case agentsHeader
        case agentGrid
    }

    @Published private(set) var entryStage: EntryStage = .hidden
    @Published private(set) var revealedDetailCount = 0
    @Published private(set) var expandedPass: ProfileV3WorldPass?
    @Published private(set) var passHero: ProfileV3HeroState?
    @Published private(set) var heroGlobe: ProfileV3HeroGlobeState?
    @Published private(set) var isDetailSettled = false
    @Published private(set) var isGlobePaused = false

    private(set) var heroSource: CGRect = .zero
    private var heroTask: Task<Void, Never>?
    private var isCollapsing = false
    private var flight = 0

    var showsChrome: Bool { entryStage >= .podium }
    var showsCards: Bool { entryStage >= .cards }
    var isEntryComplete: Bool { entryStage == .complete }

    func isRevealed(_ detail: EntryDetail, in home: ProfileV3Home?) -> Bool {
        switch entryStage {
        case .complete:
            return true
        case .details:
            guard let index = Self.details(for: home).firstIndex(of: detail) else { return true }
            return revealedDetailCount > index
        case .hidden, .podium, .cards:
            return false
        }
    }

    func enter(_ viewModel: ProfileV3HubViewModel, reducesMotion: Bool) async {
        isGlobePaused = false
        if reducesMotion {
            entryStage = .complete
        }
        guard entryStage < .complete else {
            await viewModel.loadIfNeeded()
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.frameDelayMilliseconds))
            guard !Task.isCancelled else { return }
            viewModel.armKYCGlow()
            return
        }
        let clock = ContinuousClock()
        let step = Duration.milliseconds(ProfileV3Theme.Motion.entryStepMilliseconds)
        advance(to: .podium)
        await viewModel.loadIfNeeded()
        guard !Task.isCancelled else { return }
        var nextStageAt = clock.now + step
        try? await clock.sleep(until: nextStageAt)
        guard !Task.isCancelled else { return }
        if advance(to: .cards), viewModel.home?.worldPasses.isEmpty == false {
            nextStageAt = clock.now + step
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.entryRevealMilliseconds))
            guard !Task.isCancelled else { return }
            viewModel.armKYCGlow()
        }
        try? await clock.sleep(until: nextStageAt)
        guard !Task.isCancelled else { return }
        advance(to: .details)
        while revealedDetailCount < Self.details(for: viewModel.home).count {
            withAnimation(ProfileV3Theme.Motion.entry) {
                revealedDetailCount += 1
            }
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.entryStaggerMilliseconds))
            guard !Task.isCancelled else { return }
        }
        advance(to: .complete)
    }

    func expand(
        _ pass: ProfileV3WorldPass,
        from source: CGRect,
        to target: CGRect,
        globe pose: ProfileV3GlobePose,
        renderer: any ProfileV3GlobeRendering
    ) {
        heroTask?.cancel()
        flight += 1
        let flight = flight
        isCollapsing = false
        isGlobePaused = false
        if ProfileV3FeatureFlags.isGlobeEnabled {
            Task { await ProfileV3InteractiveGlobe.prepare(using: renderer) }
        }
        heroSource = source
        heroGlobe = ProfileV3HeroGlobeState(
            pose: pose,
            handoff: .from(
                pose,
                fallbackLongitude: ProfileV3Theme.Globe.cardLongitude,
                velocity: pose.isRunning ? ProfileV3Theme.Globe.cardSpinSpeed : 0
            ),
            destinationPitch: ProfileV3Theme.Globe.restPitch
        )
        passHero = ProfileV3HeroState(frame: source, cornerRadius: ProfileV3Theme.Sizes.worldPassCornerRadius)
        expandedPass = pass
        heroTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.frameDelayMilliseconds))
            guard !Task.isCancelled, let self, self.flight == flight else { return }
            withAnimation(ProfileV3Theme.Motion.hero) {
                self.passHero = ProfileV3HeroState(
                    frame: target,
                    cornerRadius: ProfileV3Theme.Sizes.Detail.cornerRadius,
                    backdropOpacity: 1,
                    progress: 1
                )
            } completion: { [weak self] in
                Task { @MainActor in
                    guard let self, self.flight == flight, !self.isCollapsing else { return }
                    withAnimation(ProfileV3Theme.Motion.contentFade) {
                        self.isDetailSettled = true
                    }
                }
            }
        }
    }

    func collapse() {
        guard expandedPass != nil, !isCollapsing else { return }
        isCollapsing = true
        flight += 1
        heroTask?.cancel()
        if let pose = heroGlobe?.pose {
            heroGlobe = ProfileV3HeroGlobeState(
                pose: pose,
                handoff: .from(pose, fallbackLongitude: ProfileV3Theme.Globe.restLongitude, velocity: pose.velocity),
                destinationPitch: pose.pitch ?? ProfileV3Theme.Globe.restPitch
            )
        }
        isDetailSettled = false
        heroTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.contentFadeMilliseconds))
            guard !Task.isCancelled, let self else { return }
            withAnimation(ProfileV3Theme.Motion.hero) {
                self.passHero = ProfileV3HeroState(
                    frame: self.heroSource,
                    cornerRadius: ProfileV3Theme.Sizes.worldPassCornerRadius
                )
            }
            try? await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.heroSettleMilliseconds))
            guard !Task.isCancelled else { return }
            self.expandedPass = nil
            self.passHero = nil
            self.heroGlobe = nil
            self.isCollapsing = false
        }
    }

    func suspend() {
        guard expandedPass != nil else { return }
        guard isDetailSettled else {
            flight += 1
            heroTask?.cancel()
            isCollapsing = false
            expandedPass = nil
            passHero = nil
            heroGlobe = nil
            return
        }
        isGlobePaused = true
    }

    private static func details(for home: ProfileV3Home?) -> [EntryDetail] {
        guard let home else { return [] }
        var details: [EntryDetail] = []
        if !home.kycStatus.isComplete { details.append(.kyc) }
        if !home.giftCards.isEmpty { details.append(.giftCards) }
        if home.featuredBenefit != nil { details.append(.featuredBenefit) }
        details.append(contentsOf: [.agentsHeader, .agentGrid])
        return details
    }

    @discardableResult
    private func advance(to stage: EntryStage) -> Bool {
        guard stage > entryStage else { return false }
        withAnimation(ProfileV3Theme.Motion.entry) {
            entryStage = stage
        }
        return true
    }
}
