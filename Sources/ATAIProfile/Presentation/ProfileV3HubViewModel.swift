import Combine
import Foundation
import SwiftUI

@MainActor
protocol ProfileV3HubRouter: AnyObject {
    func goBack()
    func openSettings(profileID: String?)
    func openKnowMore(_ directive: ProfileV3Directive?)
    func openAgent(_ agent: ProfileV3Agent, requiresKYC: Bool, profileID: String?)
    func openAddProgramme(requiresKYC: Bool, profileID: String?)
    func openProgrammes(for pass: ProfileV3WorldPass, passes: [ProfileV3WorldPass])
    func openKYC()
    func openBenefitKYC(_ benefit: ProfileV3Benefit)
    func openAddTraveller()
    func openTravelPersona(profileID: String?)
}

@MainActor
@Observable
final class ProfileV3HubViewModel {

    struct KYCGlowCue: Equatable {
        let tone: ProfileV3KYCGlowTone
        let sequence: Int
    }

    enum KYCResumption: Equatable {
        case none
        case addProgramme
        case agent(ProfileV3Agent)
        case benefit(ProfileV3Benefit)
    }

    enum KYCFlow {
        case capture(ProfileV3KYCCapture)
        case refreshBoard
        case minimal
        case onboarding
        case alreadyComplete
    }

    enum Phase: Equatable {
        case loading
        case content(ProfileV3Home)
        case failed

        var loadPhase: ProfileV3LoadPhase {
            switch self {
            case .loading: return .loading
            case .failed: return .failed
            case .content: return .loaded
            }
        }
    }

    private(set) var phase: Phase = .loading {
        didSet { refreshStackBenefits() }
    }

    private(set) var stackBenefits: [ProfileV3Benefit] = []
    private(set) var kycGlowPlays: [String: Int] = [:]
    private(set) var kycGlowCue: KYCGlowCue?
    private(set) var kycAnnouncedPassIDs: Set<String> = []
    private(set) var selectedPassID: String?
    private(set) var isHouseholdSelected = false
    private(set) var contentVersion = 0
    private(set) var showsHoldHint: Bool
    private(set) var playsFlipDemo: Bool
    private(set) var redeemError: String?
    private(set) var benefitRedemption: ProfileV3BenefitRedemption?
    private(set) var showsAllBenefits = false
    private(set) var benefitsSheet = ProfileV3BenefitsSheet.empty {
        didSet { refreshStackBenefits() }
    }
    private(set) var allBenefitsPhase: ProfileV3LoadPhase = .loading
    private(set) var isFetchingBenefits = false
    private(set) var showsAllCoupons = false
    private(set) var pastTrips: ProfileV3PastTripsViewModel?
    private(set) var photoCountryCodes: [String] = []
    private(set) var couponsSheet = ProfileV3CouponsSheet.empty
    private(set) var allCouponsPhase: ProfileV3LoadPhase = .loading
    private(set) var isFetchingCoupons = false
    private(set) var notice: String?
    private(set) var pendingBenefit: ProfileV3Benefit?
    private(set) var isSyncingKYC = false
    private(set) var kycStepCompletions = 0

    @ObservationIgnored weak var router: ProfileV3HubRouter?

    let placeholderName: String?

    private let repository: any ProfileV3HubRepository
    private let hints: ProfileV3HubHints
    private let addsTripsWithoutDate: Bool
    private var board: ProfileV3Board?
    private var loadedPassID: String?
    private var isLoadingBoard = false
    private var needsRevalidation = false
    private var pendingResumption: KYCResumption = .none
    private var benefitsSheetProfileID: String?
    @ObservationIgnored private var afterOverlaysClose: (() -> Void)?
    @ObservationIgnored private var awaitsBenefitsScreenView = false
    private let impressions = ProfileV3ImpressionLog()
    private var isKYCGlowArmed = false
    private var hasCountedHoldHint = false
    private var pendingKYCGlowPassIDs: Set<String> = []
    @ObservationIgnored private var kycAnnounceTasks: [String: Task<Void, Never>] = [:]
    private var kycSyncGeneration = 0
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var refreshTask: Task<Void, Never>?
    @ObservationIgnored private var kycSyncTask: Task<Void, Never>?
    @ObservationIgnored private var revalidateTask: Task<Void, Never>?
    @ObservationIgnored private var benefitsTask: Task<Void, Never>?
    @ObservationIgnored private var couponsTask: Task<Void, Never>?
    @ObservationIgnored private var redeemTask: Task<Void, Never>?
    @ObservationIgnored private var photoCodesSubscription: AnyCancellable?

    init(
        repository: any ProfileV3HubRepository,
        hints: ProfileV3HubHints = ProfileV3HubHints(),
        userFirstName: String? = nil,
        addsTripsWithoutDate: Bool = false,
        photoPlaces: ProfileV3PhotoPlacesSync? = nil
    ) {
        self.repository = repository
        self.hints = hints
        self.addsTripsWithoutDate = addsTripsWithoutDate
        placeholderName = userFirstName?.nonEmpty?.lowercased()
        showsHoldHint = hints.isHoldHintDue
        playsFlipDemo = hints.isFlipDemoDue
        if let cached = repository.cachedBoard(), let profile = cached.mainProfile {
            board = cached
            selectedPassID = profile.pass.id
            loadedPassID = profile.pass.id
            phase = .content(profile.home)
            needsRevalidation = true
            refreshStackBenefits()
        }
        photoCodesSubscription = photoPlaces?.$countryCodes.sink { [weak self] codes in
            self?.photoCountryCodes = codes
        }
    }

    var home: ProfileV3Home? {
        if case .content(let home) = phase { return home }
        return nil
    }

    var selectedPass: ProfileV3WorldPass? {
        guard let home else { return nil }
        return home.worldPasses.first { $0.id == selectedPassID } ?? home.worldPass
    }

    var mainProfileID: String? {
        board?.mainProfile?.profileID
    }

    var mainProfileName: String? {
        board?.mainProfile?.name
    }

    var flipDemoPassID: String? {
        playsFlipDemo ? mainProfileID : nil
    }

    var allBenefits: [ProfileV3Benefit] {
        benefitsSheet.offers.isEmpty ? home?.benefits ?? [] : benefitsSheet.offers
    }

    var allCoupons: [ProfileV3Coupon] {
        couponsSheet.coupons.isEmpty ? [home?.featuredCoupon].compactMap { $0 } : couponsSheet.coupons
    }

    var facingKYCCapture: ProfileV3KYCCapture? {
        selectedPass?.kycCapture
    }

    var gateKYCCapture: ProfileV3KYCCapture? {
        facingKYCCapture ?? board?.mainProfile?.pass.kycCapture
    }

    var gateKYCStatus: String? {
        guard facingKYCCapture == nil,
              let main = board?.mainProfile,
              main.pass.kycCapture != nil,
              main.pass.id != selectedPass?.id else { return nil }
        return ProfileV3Strings.completeHolderKYCFirst(main.name.nonEmpty ?? main.pass.holderName)
    }

    private var isGateUnresolvable: Bool {
        gateKYCCapture == nil && home?.kycStatus.isComplete == true
    }

    private var flightAgent: ProfileV3Agent? {
        home?.agents.first { $0.agentID == .flight } ?? home?.agents.first
    }

    // MARK: - Loading

    func loadIfNeeded() async {
        guard home == nil else {
            revalidateIfNeeded()
            prefetchOffers(onlyMissing: true)
            return
        }
        guard phase != .failed else { return }
        await load()
    }

    func retryLoad() {
        loadTask = Task { [weak self] in await self?.load() }
    }

    func requestRefresh() {
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            guard let self else { return }
            await refreshHome()
            guard !Task.isCancelled else { return }
            resumePendingFlow()
        }
    }

    func refreshAfterCapture(profileID: String, completedSteps: [String]) {
        let cueBeforeCapture = kycGlowCue?.sequence
        syncKYC(startsImmediately: false) { [weak self] board in
            guard Self.reflects(board, completedSteps: completedSteps, profileID: profileID) else { return false }
            if let self, kycGlowCue?.sequence == cueBeforeCapture {
                kycStepCompletions += 1
            }
            return true
        }
    }

    func refreshAfterDisconnecting(_ connectors: Set<ProfileV3ConnectorKey>) {
        syncKYC(startsImmediately: true) { Self.reflects($0, disconnected: connectors) }
    }

    private func syncKYC(startsImmediately: Bool, until isSettled: @escaping (ProfileV3Board) -> Bool) {
        kycSyncTask?.cancel()
        kycSyncGeneration += 1
        let generation = kycSyncGeneration
        isSyncingKYC = true
        kycSyncTask = Task { [weak self] in
            guard let self else { return }
            defer {
                if kycSyncGeneration == generation { isSyncingKYC = false }
            }
            await ProfileV3Backoff.poll(startsImmediately: startsImmediately) {
                guard let board = try? await self.repository.loadBoard(), !Task.isCancelled else { return false }
                self.apply(board)
                return isSettled(board)
            }
            guard !Task.isCancelled else { return }
            prefetchOffers()
        }
    }

    func kycCompleted(resuming: KYCResumption) {
        pendingResumption = resuming
        requestRefresh()
    }

    func cancelPendingWork() {
        loadTask?.cancel()
        benefitsTask?.cancel()
        couponsTask?.cancel()
        kycSyncTask?.cancel()
        revalidateTask?.cancel()
        isFetchingBenefits = false
        isFetchingCoupons = false
        finishKYCAnnouncements()
    }

    private func load() async {
        guard !isLoadingBoard else { return }
        isLoadingBoard = true
        defer { isLoadingBoard = false }
        withAnimation(ProfileV3Theme.Motion.entry) {
            phase = .loading
        }
        do {
            let board = try await repository.loadLatestBoard()
            guard !Task.isCancelled else { return }
            guard let profile = board.mainProfile else {
                withAnimation(ProfileV3Theme.Motion.entry) { phase = .failed }
                return
            }
            self.board = board
            selectedPassID = profile.pass.id
            loadedPassID = selectedPassID
            withAnimation(ProfileV3Theme.Motion.entry) {
                phase = .content(profile.home)
            }
            prefetchOffers()
        } catch is CancellationError {
            return
        } catch {
            withAnimation(ProfileV3Theme.Motion.entry) {
                phase = .failed
            }
        }
    }

    private func refreshHome() async {
        do {
            let board = try await repository.loadBoard()
            guard !Task.isCancelled else { return }
            apply(board)
            prefetchOffers()
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            notice = ProfileV3Strings.refreshFailed
        }
    }

    private func revalidateIfNeeded() {
        guard needsRevalidation else { return }
        needsRevalidation = false
        revalidateTask = Task { [weak self] in
            guard let self, let latest = try? await repository.loadLatestBoard(), !Task.isCancelled else { return }
            let changed = latest != board
            apply(latest)
            if changed {
                prefetchOffers()
            }
        }
    }

    private func resumePendingFlow() {
        let resuming = pendingResumption
        pendingResumption = .none
        switch resuming {
        case .none:
            break
        case .addProgramme:
            router?.openAddProgramme(requiresKYC: false, profileID: selectedPassID)
        case .agent(let agent):
            router?.openAgent(agent, requiresKYC: false, profileID: selectedPassID)
        case .benefit(let benefit):
            pendingBenefit = home?.benefits.first { $0.id == benefit.id } ?? benefit
        }
    }

    private func apply(_ board: ProfileV3Board) {
        guard let profile = board.profile(id: loadedPassID) else { return }
        let glowPassIDs = Self.passIDsNeedingKYCGlow(from: self.board, to: board)
        let knownPassIDs = Set(self.board?.profiles.map(\.pass.id) ?? [])
        self.board = board
        if profile.pass.id != loadedPassID {
            loadedPassID = profile.pass.id
            selectedPassID = profile.pass.id
        }
        phase = .content(profile.home)
        queueKYCGlow(for: glowPassIDs)
        if isHouseholdSelected, !knownPassIDs.isEmpty,
           let added = board.profiles.first(where: { !knownPassIDs.contains($0.pass.id) }) {
            withAnimation(ProfileV3Theme.Motion.selection) { selectPass(id: added.pass.id) }
        }
    }

    // MARK: - Pass selection

    func selectHousehold() {
        guard !isHouseholdSelected, home != nil else { return }
        withAnimation(ProfileV3Theme.Motion.contentSwitch) { isHouseholdSelected = true }
    }

    func selectPass(id passID: String) {
        if isHouseholdSelected {
            withAnimation(ProfileV3Theme.Motion.contentSwitch) { isHouseholdSelected = false }
        }
        guard passID != selectedPassID, home != nil else { return }
        guard let profile = board?.profiles.first(where: { $0.pass.id == passID }) else {
            notice = ProfileV3Strings.passSwitchFailed
            return
        }
        let passIDs = home?.worldPasses.map(\.id) ?? []
        if let from = passIDs.firstIndex(where: { $0 == selectedPassID }), let to = passIDs.firstIndex(of: passID) {
            ProfileV3Analytics.passSwitched(travellerId: passID, direction: to > from ? .next : .previous)
        }
        selectedPassID = passID
        guard passID != loadedPassID else { return }
        loadedPassID = passID
        withAnimation(ProfileV3Theme.Motion.contentSwitch) {
            contentVersion += 1
            phase = .content(profile.home)
        }
        prefetchOffers(onlyMissing: true)
        playPendingKYCGlow(for: passID)
    }

    @discardableResult
    func selectPass(offsetBy delta: Int) -> Bool {
        guard let home, home.worldPasses.count > 1 else { return false }
        let ids = home.worldPasses.map(\.id)
        guard let current = ids.firstIndex(of: selectedPassID ?? "") else { return false }
        let next = min(max(current + delta, 0), ids.count - 1)
        guard next != current else { return false }
        withAnimation(ProfileV3Theme.Motion.selection) { selectPass(id: ids[next]) }
        return selectedPassID == ids[next]
    }

    // MARK: - Analytics

    func isCoTraveller(_ profileID: String?) -> Bool {
        guard let profileID, let mainProfileID else { return false }
        return profileID != mainProfileID
    }

    func tapWorldPass(_ pass: ProfileV3WorldPass, showingBenefits: Bool) {
        ProfileV3Analytics.worldPassTapped(
            travellerId: pass.id,
            travellerName: pass.holderName,
            tapOn: showingBenefits ? .benefits : .profile
        )
    }

    func trackBenefitClick(_ benefit: ProfileV3Benefit, origin: ProfileV3Analytics.BenefitOrigin, routedToGate: Bool) {
        ProfileV3Analytics.benefitClicked(benefit, travellerId: selectedPassID, origin: origin, routedToGate: routedToGate)
    }

    func trackBenefitScreen(_ benefit: ProfileV3Benefit) {
        ProfileV3Analytics.benefitScreen(benefitId: benefit.id, travellerId: selectedPassID)
    }

    func trackKYCNudge(_ home: ProfileV3Home) {
        guard let passID = selectedPassID else { return }
        impressions.once("kyc:\(passID)") {
            ProfileV3Analytics.kycNudgeShown(
                passId: passID,
                kycStatus: home.kycStatus.analyticsValue,
                kycDone: home.kycProgress?.done,
                kycTotal: home.kycProgress?.total
            )
        }
    }

    // MARK: - Hints

    func markHoldHintSeen() {
        hints.hasSeenHoldHint = true
        guard showsHoldHint else { return }
        showsHoldHint = false
    }

    func holdHintDidAppear() {
        guard showsHoldHint, !hasCountedHoldHint else { return }
        hasCountedHoldHint = true
        hints.holdHintShows += 1
    }

    func markFlipSeen() {
        guard playsFlipDemo else { return }
        playsFlipDemo = false
        hints.flipDemoShows += 1
    }

    // MARK: - Navigation

    func tapBack() { router?.goBack() }
    func tapSettings() { router?.openSettings(profileID: mainProfileID) }
    func tapKnowMore() {
        ProfileV3Analytics.cta(benefitsSheet.learnMore, origin: .knowMore)
        router?.openKnowMore(benefitsSheet.learnMore)
    }

    func tapCompleteKYC() {
        ProfileV3Analytics.completeKYCClicked()
        router?.openKYC()
    }

    func tapAddTraveller() { router?.openAddTraveller() }

    func tapAgent(_ agent: ProfileV3Agent) {
        guard let home else { return }
        let requiresKYC = gatesKYC(agent.next, fallback: !home.kycStatus.isComplete)
        let route = agent.next?.route(fallbackProfileID: selectedPassID)
        let opensPersona = if case .travelPersona = route { true } else { false }
        ProfileV3Analytics.agentClicked(
            agentId: agent.id,
            agentIndex: home.agents.firstIndex { $0.id == agent.id },
            agentName: opensPersona ? ProfileV3Analytics.travelPersonaAgentName : ProfileV3Analytics.agentName(agent.id),
            travellerId: selectedPassID,
            isActive: agent.isActive,
            requiresKYC: requiresKYC
        )
        ProfileV3Analytics.cta(agent.next, origin: .agentCard)
        switch route {
        case .agent(_, let profileID):
            router?.openAgent(agent, requiresKYC: false, profileID: profileID ?? selectedPassID)
        case .travelPersona(let profileID):
            router?.openTravelPersona(profileID: profileID)
        default:
            guard agent.agentID != nil else { return }
            router?.openAgent(agent, requiresKYC: false, profileID: selectedPassID)
        }
    }

    func useInsight() {
        guard let flightAgent else { return }
        tapAgent(flightAgent)
    }

    func tapAddProgramme() {
        guard home != nil else { return }
        ProfileV3Analytics.cardConnectClicked(travellerId: selectedPassID, actionSource: .card)
        ProfileV3Analytics.cta(selectedPass?.addProgrammeDirective, origin: .addProgramme)
        router?.openAddProgramme(requiresKYC: addProgrammeRequiresKYC(for: selectedPass), profileID: selectedPassID)
    }

    func tapAddedCards(_ pass: ProfileV3WorldPass) {
        ProfileV3Analytics.addedCardClicked(travellerId: pass.id, cardsName: pass.programmes.map(\.name))
        tapOpenProgrammes(pass)
    }

    func tapOpenProgrammes(_ pass: ProfileV3WorldPass) {
        if case .unsupported = pass.programmesDirective?.route() { return }
        ProfileV3Analytics.cta(pass.programmesDirective, origin: .programmes)
        guard gatesKYC(pass.programmesDirective, fallback: false) else {
            router?.openProgrammes(for: pass, passes: home?.worldPasses ?? [pass])
            return
        }
        guard !isGateUnresolvable else { return }
        router?.openAddProgramme(requiresKYC: true, profileID: pass.id)
    }

    func tapMainProgrammes() {
        guard let pass = board?.mainProfile?.pass else { return }
        withAnimation(ProfileV3Theme.Motion.selection) { selectPass(id: pass.id) }
        tapOpenProgrammes(pass)
    }

    func open(_ destination: ProfileV3Destination) {
        switch destination {
        case .addTraveller:
            router?.openAddTraveller()
        case .addLoyaltyProgramme:
            guard let pass = board?.mainProfile?.pass else { return }
            withAnimation(ProfileV3Theme.Motion.selection) { selectPass(id: pass.id) }
            router?.openAddProgramme(requiresKYC: addProgrammeRequiresKYC(for: pass), profileID: pass.id)
        }
    }

    func addProgrammeRequiresKYC(for pass: ProfileV3WorldPass?) -> Bool {
        gatesKYC(pass?.addProgrammeDirective, fallback: home?.kycStatus.isComplete == false)
    }

    func kycFlow(resuming: KYCResumption) -> KYCFlow {
        let capture: ProfileV3KYCCapture?
        if case .none = resuming {
            capture = facingKYCCapture
        } else {
            capture = gateKYCCapture
        }
        if let capture, !capture.establishesMain {
            return capture.hasCapturableStep ? .capture(capture) : .refreshBoard
        }
        switch home?.kycStatus {
        case .expired: return .minimal
        case .complete: return .alreadyComplete
        case .notStarted, .none: return .onboarding
        }
    }

    private func gatesKYC(_ directive: ProfileV3Directive?, fallback: Bool) -> Bool {
        switch directive?.route() {
        case .kycGate, .kycCapture, .coTravellerCapture: return true
        case .agent, .loyaltyAdd: return false
        default: return fallback
        }
    }

    // MARK: - Offers

    func tapViewAllBenefits() {
        ProfileV3Analytics.viewBenefitsClicked(travellerId: selectedPassID)
        showAllBenefits()
    }

    func showAllBenefits() {
        if benefitsSheetProfileID != loadedPassID {
            benefitsSheet = .empty
            benefitsSheetProfileID = nil
        }
        awaitsBenefitsScreenView = true
        withAnimation(ProfileV3Theme.Motion.entry) { showsAllBenefits = true }
        retryAllBenefits()
    }

    func retryAllBenefits() {
        benefitsTask?.cancel()
        benefitsTask = Task { [weak self] in await self?.loadAllBenefits() }
    }

    // MARK: - Past trips

    var latestPasses: [String: ProfileV3WorldPass] {
        let mainID = photoCountryCodes.isEmpty ? nil : mainProfileID
        return Dictionary(
            (home?.worldPasses ?? []).map { pass in
                guard pass.id == mainID else { return (pass.id, pass) }
                var merged = pass
                merged.visitedCountryCodes += photoCountryCodes
                return (pass.id, merged)
            },
            uniquingKeysWith: { first, _ in first }
        )
    }

    func openTrips(_ pass: ProfileV3WorldPass, directive: ProfileV3Directive) {
        switch directive.route(fallbackProfileID: pass.id) {
        case .pastTrips:
            openPastTrips(pass, startsAdding: false)
        case .addTrip:
            openPastTrips(pass, startsAdding: true)
        default:
            break
        }
    }

    func openPastTrips(_ pass: ProfileV3WorldPass, startsAdding: Bool) {
        guard pastTrips == nil else { return }
        let model = ProfileV3PastTripsViewModel(
            pass: pass,
            repository: repository,
            startsAdding: startsAdding,
            addsTripsWithoutDate: addsTripsWithoutDate,
            onChange: { [weak self] in self?.refreshAfterTripChange() },
            onClose: { [weak self] in self?.dismissPastTrips() }
        )
        withAnimation(ProfileV3Theme.Motion.entry) { pastTrips = model }
    }

    func dismissPastTrips() {
        withAnimation(ProfileV3Theme.Motion.contentFade) { pastTrips = nil }
    }

    private func refreshAfterTripChange() {
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            await self?.refreshHome()
        }
    }

    func dismissAllBenefits() {
        awaitsBenefitsScreenView = false
        withAnimation(ProfileV3Theme.Motion.contentFade) { showsAllBenefits = false }
    }

    func benefitDetail(_ benefit: ProfileV3Benefit) async throws -> ProfileV3Benefit? {
        try await repository.loadBenefit(id: benefit.id)
    }

    func activateLockedBenefit(_ benefit: ProfileV3Benefit) {
        guard !isGateUnresolvable else { return }
        guard showsAllBenefits else {
            router?.openBenefitKYC(benefit)
            return
        }
        afterOverlaysClose = { [weak self] in self?.router?.openBenefitKYC(benefit) }
        dismissAllBenefits()
    }

    func overlaysDidClose() {
        let action = afterOverlaysClose
        afterOverlaysClose = nil
        action?()
    }

    func clearPendingBenefit() {
        pendingBenefit = nil
    }

    func redeem(_ benefit: ProfileV3Benefit) {
        guard redeemTask == nil else { return }
        redeemError = nil
        redeemTask = Task { [weak self] in
            guard let self else { return }
            defer { redeemTask = nil }
            do {
                try await repository.redeemBenefit(id: benefit.id)
                let updated = benefit.withStatus(.redeemed(on: ProfileV3Strings.redeemedJustNow))
                if let home {
                    phase = .content(home.replacingBenefit(updated))
                }
                benefitRedemption = ProfileV3BenefitRedemption(
                    benefitID: benefit.id,
                    sequence: (benefitRedemption?.sequence ?? 0) + 1
                )
                ProfileV3Analytics.benefitRedeemed(benefitId: benefit.id, travellerId: loadedPassID)
            } catch {
                redeemError = ProfileV3Strings.redeemFailed
                ProfileV3Analytics.benefitRedeemFailed(benefitId: benefit.id, travellerId: loadedPassID, error: error)
            }
        }
    }

    func clearRedeemError() {
        redeemError = nil
    }

    func tapViewAllCoupons() {
        withAnimation(ProfileV3Theme.Motion.entry) { showsAllCoupons = true }
        retryAllCoupons()
    }

    func retryAllCoupons() {
        couponsTask?.cancel()
        couponsTask = Task { [weak self] in await self?.loadAllCoupons() }
    }

    func dismissAllCoupons() {
        withAnimation(ProfileV3Theme.Motion.contentFade) { showsAllCoupons = false }
    }

    func couponDetail(_ coupon: ProfileV3Coupon) async throws -> ProfileV3CouponDetail? {
        try await repository.loadCoupon(id: coupon.id)
    }

    func clearNotice() {
        notice = nil
    }

    private func prefetchOffers(onlyMissing: Bool = false) {
        guard let home else { return }
        if home.featuredBenefit != nil, !onlyMissing || benefitsSheetProfileID != loadedPassID {
            retryAllBenefits()
        }
        if home.featuredCoupon != nil, !onlyMissing || couponsSheet.coupons.isEmpty {
            retryAllCoupons()
        }
    }

    private func loadAllBenefits() async {
        let profileID = loadedPassID
        await loadSheet(
            phase: \.allBenefitsPhase,
            isFetching: \.isFetchingBenefits,
            isEmpty: \.allBenefits.isEmpty,
            fetch: { try await repository.loadBenefits(profileID: profileID) },
            apply: { sheet in
                benefitsSheetProfileID = profileID
                benefitsSheet = sheet
            }
        )
        guard !Task.isCancelled, awaitsBenefitsScreenView, showsAllBenefits, allBenefitsPhase == .loaded else { return }
        awaitsBenefitsScreenView = false
        ProfileV3Analytics.benefitsScreenViewed(travellerId: profileID, benefitList: allBenefits.map(\.title))
    }

    private func loadAllCoupons() async {
        await loadSheet(
            phase: \.allCouponsPhase,
            isFetching: \.isFetchingCoupons,
            isEmpty: \.allCoupons.isEmpty,
            fetch: { try await repository.loadCoupons() },
            apply: { couponsSheet = $0 }
        )
    }

    private func loadSheet<Sheet>(
        phase: ReferenceWritableKeyPath<ProfileV3HubViewModel, ProfileV3LoadPhase>,
        isFetching: ReferenceWritableKeyPath<ProfileV3HubViewModel, Bool>,
        isEmpty: KeyPath<ProfileV3HubViewModel, Bool>,
        fetch: () async throws -> Sheet,
        apply: (Sheet) -> Void
    ) async {
        let initial: ProfileV3LoadPhase = self[keyPath: isEmpty] ? .loading : .loaded
        withAnimation(ProfileV3Theme.Motion.contentFade) { self[keyPath: phase] = initial }
        self[keyPath: isFetching] = true
        do {
            let sheet = try await fetch()
            guard !Task.isCancelled else { return }
            withAnimation(ProfileV3Theme.Motion.contentFade) {
                apply(sheet)
                self[keyPath: phase] = .loaded
                self[keyPath: isFetching] = false
            }
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            let fallback: ProfileV3LoadPhase = self[keyPath: isEmpty] ? .failed : .loaded
            withAnimation(ProfileV3Theme.Motion.contentFade) {
                self[keyPath: phase] = fallback
                self[keyPath: isFetching] = false
            }
        }
    }

    private func refreshStackBenefits() {
        guard let home, let featured = home.featuredBenefit else {
            stackBenefits = []
            return
        }
        let offers = benefitsSheetProfileID == loadedPassID ? benefitsSheet.offers : []
        let pool = offers.isEmpty ? home.benefits : offers
        stackBenefits = [featured] + pool.filter { $0.id != featured.id }
    }

    // MARK: - KYC glow

    func armKYCGlow() {
        guard !isKYCGlowArmed else { return }
        isKYCGlowArmed = true
        pendingKYCGlowPassIDs.formUnion(home?.worldPasses.map(\.id) ?? [])
        playPendingKYCGlow(for: selectedPassID)
    }

    private func queueKYCGlow(for passIDs: Set<String>) {
        guard isKYCGlowArmed, !passIDs.isEmpty else { return }
        pendingKYCGlowPassIDs.formUnion(passIDs)
        playPendingKYCGlow(for: selectedPassID)
    }

    private func playPendingKYCGlow(for passID: String?) {
        guard isKYCGlowArmed, let passID, pendingKYCGlowPassIDs.remove(passID) != nil else { return }
        kycGlowPlays[passID, default: 0] += 1
        cueKYCGlow(for: passID)
        announceKYC(for: passID)
    }

    private func cueKYCGlow(for passID: String) {
        let tone = home?.worldPasses.first { $0.id == passID }?.resolvedKYCGlowTone ?? .hidden
        guard tone != .hidden else { return }
        kycGlowCue = KYCGlowCue(tone: tone, sequence: (kycGlowCue?.sequence ?? 0) + 1)
    }

    private func announceKYC(for passID: String) {
        kycAnnounceTasks.removeValue(forKey: passID)?.cancel()
        guard home?.worldPasses.first(where: { $0.id == passID })?.resolvedKYCGlowTone != .hidden else {
            kycAnnouncedPassIDs.insert(passID)
            return
        }
        withAnimation(ProfileV3Theme.Motion.selection) {
            _ = kycAnnouncedPassIDs.remove(passID)
        }
        kycAnnounceTasks[passID] = Task { [weak self] in
            try? await Task.sleep(for: .seconds(ProfileV3Theme.Motion.kycGlowSeconds))
            guard !Task.isCancelled, let self else { return }
            self.kycAnnounceTasks[passID] = nil
            withAnimation(ProfileV3Theme.Motion.selection) {
                _ = self.kycAnnouncedPassIDs.insert(passID)
            }
        }
    }

    private func finishKYCAnnouncements() {
        guard !kycAnnounceTasks.isEmpty else { return }
        kycAnnounceTasks.values.forEach { $0.cancel() }
        kycAnnouncedPassIDs.formUnion(kycAnnounceTasks.keys)
        kycAnnounceTasks.removeAll()
    }

    private static func passIDsNeedingKYCGlow(from old: ProfileV3Board?, to new: ProfileV3Board) -> Set<String> {
        guard let old else { return [] }
        let previous = Dictionary(old.profiles.map { ($0.pass.id, $0.pass) }, uniquingKeysWith: { first, _ in first })
        return Set(new.profiles.compactMap { profile -> String? in
            let pass = profile.pass
            guard let before = previous[pass.id] else { return pass.id }
            let completed = !before.kycStatus.isComplete && pass.kycStatus.isComplete
            let turnedNegative = before.resolvedKYCGlowTone != .negative && pass.resolvedKYCGlowTone == .negative
            return completed || turnedNegative ? pass.id : nil
        })
    }

    private static func reflects(_ board: ProfileV3Board, completedSteps: [String], profileID: String) -> Bool {
        let profile = board.profiles.first { $0.profileID == profileID }
        guard let outstanding = profile?.pass.kycCapture?.steps else { return true }
        return !completedSteps.contains(where: outstanding.contains)
    }

    private static func reflects(_ board: ProfileV3Board, disconnected connectors: Set<ProfileV3ConnectorKey>) -> Bool {
        !connectors.contains(.gmail) || board.mainProfile?.home.isGmailConnected != true
    }
}
