import Foundation

struct ProfileV3TravelStat: Identifiable, Equatable {
    enum Key: String, Equatable {
        case flights
        case distance
        case countries
        case airports
        case airlines
    }

    let key: Key
    let label: String
    let value: Int

    var id: String { key.rawValue }
}

enum ProfileV3TextOverlay: Equatable {
    case light
    case dark
}

struct ProfileV3LoyaltyProgramme: Identifiable, Equatable {
    let id: String
    let name: String
    let maskedNumber: String
    let points: Int
    let logoURL: URL?
    var artURL: URL?
    var isArtPlaceholder = false
    var textOverlay: ProfileV3TextOverlay = .light
    var membershipNumber: String?
    var needsAttention = false
    var holderName: String? = nil
    var expiryLabel: String? = nil
    var insight: ProfileV3ProgrammeInsight? = nil
    var insightDirective: ProfileV3Directive? = nil
    var pointsLine: String? = nil
    var tier: String? = nil
    var updatedLine: String? = nil
}

struct ProfileV3ProgrammeInsight: Equatable {
    let summary: String
    let actionTitle: String
    let detail: ProfileV3ProgrammeInsightDetail
    var action: ProfileV3Directive?
}

struct ProfileV3ProgrammeInsightDetail: Equatable {
    let body: [ProfileV3TextSegment]
    let sourceIcons: [ProfileV3SourceIcon]
    let sourceCount: Int
    var sources: ProfileV3Directive?
}

struct ProfileV3TextSegment: Equatable {
    let text: String
    var isEmphasised = false
}

enum ProfileV3ConnectorIcon: Equatable {
    case remote(URL?)
    case contract
}

struct ProfileV3Connector: Identifiable, Equatable {
    enum Status: Equatable {
        case connected
        case needsAttention
    }

    let id: String
    let name: String
    let icon: ProfileV3ConnectorIcon
    let status: Status
    var accountEmail: String?
}

struct ProfileV3ProgrammeOverview: Equatable {
    let passID: String
    let holderName: String
    let programmes: [ProfileV3LoyaltyProgramme]
    let connectedCount: Int
    let summary: String
    let pointsLabel: String
    let estimatedValueLabel: String
    var reorderAction: String?

    var featured: [ProfileV3LoyaltyProgramme] { programmes.filter { $0.insight != nil } }
    var others: [ProfileV3LoyaltyProgramme] { programmes.filter { $0.insight == nil } }

    func removing(programmeID: String) -> ProfileV3ProgrammeOverview {
        let remaining = programmes.filter { $0.id != programmeID }
        return ProfileV3ProgrammeOverview(
            passID: passID,
            holderName: holderName,
            programmes: remaining,
            connectedCount: remaining.count < programmes.count ? max(0, connectedCount - 1) : connectedCount,
            summary: summary,
            pointsLabel: pointsLabel,
            estimatedValueLabel: estimatedValueLabel,
            reorderAction: reorderAction
        )
    }
}

enum ProfileV3UpdateStamp: Equatable {
    case date(Date)
    case label(String)
}

struct ProfileV3WorldPass: Identifiable, Equatable {
    let id: String
    let holderName: String
    let memberNumber: String
    var kycStatus: ProfileV3KYCStatus
    var visitedCountryCodes: [String]
    let stats: [ProfileV3TravelStat]
    var programmes: [ProfileV3LoyaltyProgramme] = []
    var connectedProgrammeCount = 0
    var programmesUpdate: ProfileV3UpdateStamp?
    var programmesDirective: ProfileV3Directive?
    var addProgrammeDirective: ProfileV3Directive?
    var kycProgress: ProfileV3KYCProgress?
    var kycCapture: ProfileV3KYCCapture?
    var kycGlowTone: ProfileV3KYCGlowTone?
    var kycLine: ProfileV3KYCLine?

    var resolvedKYCGlowTone: ProfileV3KYCGlowTone { kycGlowTone ?? ProfileV3KYCGlowTone(status: kycStatus) }

    var uniqueVisitedCountryCodes: [String] {
        var seen = Set<String>()
        return visitedCountryCodes.filter { seen.insert($0).inserted }
    }
}

enum ProfileV3KYCStatus: Equatable {
    case notStarted
    case expired(on: String)
    case complete(validTill: String)

    var isComplete: Bool {
        if case .complete = self { return true }
        return false
    }
}

enum ProfileV3KYCGlowTone: Equatable {
    case positive
    case negative
    case hidden

    init(status: ProfileV3KYCStatus) {
        switch status {
        case .complete: self = .positive
        case .expired: self = .negative
        case .notStarted: self = .hidden
        }
    }
}

struct ProfileV3KYCLine: Equatable {
    let title: String
    let subtitle: String?
}

struct ProfileV3KYCProgress: Equatable {
    let done: Int
    let total: Int

    var fraction: Double {
        guard total > 0 else { return 0 }
        return min(max(Double(done) / Double(total), 0), 1)
    }
}

struct ProfileV3Benefit: Identifiable, Equatable {
    enum Status: Equatable {
        case locked
        case active(validTill: String)
        case partiallyRedeemed(usage: String, validTill: String, progress: Double)
        case redeemed(on: String)
    }

    let id: String
    let title: String
    let subtitle: String
    var imageURL: URL?
    var status: Status
    var terms: String?
    var iconState: String?

    var isDepleted: Bool {
        guard case .partiallyRedeemed(_, _, let progress) = status else { return false }
        return progress >= 1
    }

    var requiresKYC: Bool {
        if case .locked = status { return true }
        return false
    }

    func withStatus(_ status: Status) -> ProfileV3Benefit {
        var copy = self
        copy.status = status
        return copy
    }
}

enum ProfileV3AgentID: String, Hashable {
    case flight
    case stay
    case airportLogistics = "airport-logistics"
    case food
    case medical
    case itinerary
    case personal
}

struct ProfileV3Agent: Identifiable, Equatable {
    let id: String
    let name: String
    let summary: String
    let avatarURL: URL?
    let isActive: Bool
    var hasData = true
    let foundCount: Int
    let totalCount: Int
    var next: ProfileV3Directive?
    var activate: ProfileV3Directive?

    var agentID: ProfileV3AgentID? { ProfileV3AgentID(rawValue: id) }

    var displayName: String { name.capitalized }
}

struct ProfileV3Home: Equatable {
    var worldPasses: [ProfileV3WorldPass]
    var kycStatus: ProfileV3KYCStatus
    var featuredBenefit: ProfileV3Benefit?
    var benefits: [ProfileV3Benefit]
    var giftCards: [ProfileV3Benefit]
    let viewAllBenefitsLabel: String
    let agents: [ProfileV3Agent]
    let agentsUpdatedAt: String
    var agentsHeading: String?
    var agentsHeadingEmphasis: String?
    var kycProgress: ProfileV3KYCProgress?
    var featuredCoupon: ProfileV3Coupon?
    var viewAllCouponsLabel: String?
    var kycActionLabel: String?
    var kycStatusLabel: String?
    var kycBannerTitle: String?
    var needsKYCReconnect = false
    var kycLine: ProfileV3KYCLine?

    var worldPass: ProfileV3WorldPass? { worldPasses.first }

    func replacingBenefit(_ benefit: ProfileV3Benefit) -> ProfileV3Home {
        mappingBenefits { $0.id == benefit.id ? benefit : $0 }
    }

    fileprivate func mappingBenefits(_ transform: (ProfileV3Benefit) -> ProfileV3Benefit) -> ProfileV3Home {
        var home = self
        home.featuredBenefit = featuredBenefit.map(transform)
        home.benefits = benefits.map(transform)
        home.giftCards = giftCards.map(transform)
        return home
    }
}

enum ProfileV3ProgrammeCategory: String, CaseIterable, Identifiable {
    case all
    case creditCards
    case hotels
    case flights
    case travelPasses

    var id: String { rawValue }
}

struct ProfileV3ProgrammeFilter: Identifiable, Equatable {
    let label: String
    let category: ProfileV3ProgrammeCategory?

    var id: String { label }
    var isAll: Bool { category == .all }
}

struct ProfileV3ProgrammePicker: Equatable {
    let items: [ProfileV3ProgrammeCatalogueItem]
    let filters: [ProfileV3ProgrammeFilter]
}

struct ProfileV3ProgrammeCatalogueItem: Identifiable, Equatable {
    let id: String
    let name: String
    let category: ProfileV3ProgrammeCategory
    var cardImageURL: URL? = nil
    var logoURL: URL? = nil
}

enum ProfileV3ProgrammeScanEvent: Equatable {
    case searching(activity: String, foundCount: Int)
    case finished(foundCount: Int)
}

struct ProfileV3ProgrammeSubmission: Equatable {
    let item: ProfileV3ProgrammeCatalogueItem
    let membershipNumber: String
    let points: Int?
}

#if DEBUG
extension ProfileV3WorldPass {
    func adding(_ programme: ProfileV3LoyaltyProgramme) -> ProfileV3WorldPass {
        var pass = self
        pass.programmes.append(programme)
        pass.connectedProgrammeCount += 1
        return pass
    }

    func removing(programmeID: String) -> ProfileV3WorldPass {
        var pass = self
        let before = pass.programmes.count
        pass.programmes.removeAll { $0.id == programmeID }
        if pass.programmes.count < before {
            pass.connectedProgrammeCount = max(0, pass.connectedProgrammeCount - 1)
        }
        return pass
    }

    func withKYCStatus(_ status: ProfileV3KYCStatus) -> ProfileV3WorldPass {
        var pass = self
        pass.kycStatus = status
        return pass
    }
}

extension ProfileV3Home {
    func markingBenefitRedeemed(id: String, on label: String) -> ProfileV3Home {
        mappingBenefits { $0.id == id ? $0.withStatus(.redeemed(on: label)) : $0 }
    }

    func addingProgramme(_ programme: ProfileV3LoyaltyProgramme, toPassID passID: String) -> ProfileV3Home {
        replacing(worldPasses: worldPasses.map { $0.id == passID ? $0.adding(programme) : $0 })
    }

    func removingProgramme(id programmeID: String, fromPassID passID: String) -> ProfileV3Home {
        replacing(worldPasses: worldPasses.map { $0.id == passID ? $0.removing(programmeID: programmeID) : $0 })
    }

    func withKYCStatus(_ status: ProfileV3KYCStatus, forPassID passID: String, appliesToHome: Bool) -> ProfileV3Home {
        replacing(
            worldPasses: worldPasses.map { $0.id == passID ? $0.withKYCStatus(status) : $0 },
            kycStatus: appliesToHome ? status : nil
        )
    }

    private func replacing(worldPasses: [ProfileV3WorldPass], kycStatus: ProfileV3KYCStatus? = nil) -> ProfileV3Home {
        var home = self
        home.worldPasses = worldPasses
        home.kycStatus = kycStatus ?? self.kycStatus
        return home
    }
}
#endif
