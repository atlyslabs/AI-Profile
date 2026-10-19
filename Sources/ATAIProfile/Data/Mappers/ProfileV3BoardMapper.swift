import Foundation
import os

enum ProfileV3BoardMapper: ProfileV3DTOReading {

    static func board(_ dto: ProfileV3BoardDTO) -> ProfileV3Board {
        let switcher = dto.header?.travellerSwitcher ?? []
        let profiles = dto.profiles
        let passes = profiles.map { pass($0, switcher: switcher) }
        let gmailConnected = isGmailConnected(profiles)
        let boards = profiles.indices.map { index in
            ProfileV3ProfileBoard(
                profileID: profiles[index].profileID,
                isMain: isMain(profiles[index], switcher: switcher),
                name: passes[index].holderName,
                pass: passes[index],
                home: home(profiles[index], pass: passes[index], passes: passes, isGmailConnected: gmailConnected)
            )
        }
        return ProfileV3Board(profiles: boards, settings: dto.header?.settings?.next?.directive)
    }

    private static func pass(
        _ dto: ProfileV3ProfileBoardDTO,
        switcher: [ProfileV3TravellerSwitchDTO]
    ) -> ProfileV3WorldPass {
        let loyalty = dto.loyaltyCard
        let programmes = loyalty?.programs.map(ProfileV3LoyaltyMapper.programme) ?? []
        return ProfileV3WorldPass(
            id: dto.profileID,
            holderName: name(dto, switcher: switcher),
            memberNumber: dto.worldpassCard?.passNumber ?? "",
            kycStatus: kycStatus(dto),
            visitedCountryCodes: dto.worldpassCard?.countryCodes ?? [],
            stats: (dto.worldpassCard?.stats ?? []).compactMap(ProfileV3GlobeMapper.stat),
            tripsEntry: ProfileV3PastTripsMapper.entry(dto.worldpassCard?.globe),
            programmes: programmes,
            connectedProgrammeCount: loyalty?.count?.intValue ?? programmes.count,
            programmesUpdate: programmesUpdate(loyalty),
            programmesDirective: loyalty?.next?.directive,
            addProgrammeDirective: loyalty?.add?.next.directive,
            kycProgress: kycProgress(dto),
            kycCapture: kycCapture(dto),
            kycGlowTone: kycGlowTone(dto),
            kycLine: kycLine(dto)
        )
    }

    private static func home(
        _ dto: ProfileV3ProfileBoardDTO,
        pass: ProfileV3WorldPass,
        passes: [ProfileV3WorldPass],
        isGmailConnected: Bool?
    ) -> ProfileV3Home {
        let sections = dto.sections
        let benefits = sections.compactMap(\.asBenefits).first
        let coupons = sections.compactMap(\.asCoupons).first
        let grid = sections.compactMap(\.asAgentGrid).first
        let featured = benefits?.featured.map(ProfileV3BenefitsMapper.offer)
        let banner = sections.compactMap(\.asKYCBanner).first
        return ProfileV3Home(
            worldPasses: passes,
            kycStatus: pass.kycStatus,
            featuredBenefit: featured,
            benefits: featured.map { [$0] } ?? [],
            giftCards: [],
            viewAllBenefitsLabel: viewAllBenefitsLabel(benefits),
            agents: grid?.tiles.compactMap(agent) ?? [],
            isGmailConnected: isGmailConnected,
            agentsUpdatedAt: agentsUpdatedAt(grid?.updatedAt),
            agentsHeading: text(grid?.heading),
            agentsHeadingEmphasis: text(grid?.headingEmphasis),
            kycProgress: pass.kycProgress,
            featuredCoupon: coupons?.featured.flatMap(ProfileV3CouponsMapper.coupon),
            viewAllCouponsLabel: text(coupons?.viewAll?.label),
            kycActionLabel: text(banner?.cta?.label),
            kycStatusLabel: text(banner?.statusLabel),
            kycBannerTitle: text(banner?.title),
            needsKYCReconnect: banner?.isReconnect == true,
            kycLine: pass.kycLine
        )
    }

    private static func isGmailConnected(_ profiles: [ProfileV3ProfileBoardDTO]) -> Bool? {
        let gmail = ProfileV3CaptureStepKey.gmailConnect
        guard let kyc = profiles.lazy.compactMap(\.profileKYC).first(where: { $0.required?.contains(gmail) == true })
        else { return nil }
        if let missing = kyc.missing { return !missing.contains(gmail) }
        return kyc.complete == true ? true : nil
    }

    private static func kycProgress(_ dto: ProfileV3ProfileBoardDTO) -> ProfileV3KYCProgress? {
        if dto.sections.compactMap(\.asKYCBanner).first?.isReconnect == true { return nil }
        if let required = dto.profileKYC?.required, !required.isEmpty {
            let total = required.count
            let done = max(total - (dto.profileKYC?.missing?.count ?? 0), 0)
            guard done > 0, done < total else { return nil }
            return ProfileV3KYCProgress(done: done, total: total)
        }
        let progress = dto.sections.compactMap(\.asKYCBanner).first?.progress
        guard let done = progress?.done?.intValue, let total = progress?.total?.intValue,
              total > 0, done < total else { return nil }
        return ProfileV3KYCProgress(done: done, total: total)
    }

    private enum KYCState: String {
        case active
        case expired
        case notDone = "not_done"
    }

    private static func kycState(_ dto: ProfileV3ProfileBoardDTO) -> KYCState? {
        text(dto.worldpassCard?.kycState?.state).flatMap { KYCState(rawValue: $0.lowercased()) }
    }

    private static func kycLine(_ dto: ProfileV3ProfileBoardDTO) -> ProfileV3KYCLine? {
        guard kycState(dto) != nil, let title = text(dto.worldpassCard?.kycState?.statusLabel) else { return nil }
        return ProfileV3KYCLine(title: title, subtitle: text(dto.worldpassCard?.kycState?.subline))
    }

    private static func kycStatus(_ dto: ProfileV3ProfileBoardDTO) -> ProfileV3KYCStatus {
        switch kycState(dto) {
        case .active: return .complete(validTill: "")
        case .expired: return .expired(on: "")
        case .notDone: return .notStarted
        case nil: break
        }
        let banner = dto.sections.compactMap(\.asKYCBanner).first
        let label = banner?.expiryLabel ?? ""
        let isExpired = banner?.status == "expired" || dto.worldpassCard?.glow == "expired"
        if let complete = dto.worldpassCard?.kycComplete ?? dto.profileKYC?.complete {
            if complete { return .complete(validTill: label) }
            return isExpired ? .expired(on: label) : .notStarted
        }
        if banner?.isReconnect == true { return .complete(validTill: label) }
        switch dto.worldpassCard?.glow {
        case "green":
            return .complete(validTill: label)
        case "none", "red":
            return .notStarted
        case "expired":
            return .expired(on: label)
        default:
            break
        }
        return banner?.status == "expired" ? .expired(on: label) : .notStarted
    }

    private static func kycGlowTone(_ dto: ProfileV3ProfileBoardDTO) -> ProfileV3KYCGlowTone? {
        switch dto.worldpassCard?.glow {
        case "green": return .positive
        case "red", "expired": return .negative
        case "none": return .hidden
        default: break
        }
        switch kycState(dto) {
        case .active: return .positive
        case .expired: return .negative
        case .notDone: return .hidden
        case nil: return nil
        }
    }

    private static func kycCapture(_ dto: ProfileV3ProfileBoardDTO) -> ProfileV3KYCCapture? {
        let next = dto.sections.compactMap(\.asKYCBanner).first?.cta?.next
        let profileID = text(next?.profileID) ?? dto.profileID
        switch next?.go {
        case "kyc_capture":
            return ProfileV3KYCCapture(
                profileID: profileID,
                route: .session,
                steps: next?.steps ?? [],
                reason: next?.reason
            )
        case "co_traveler_capture":
            return ProfileV3KYCCapture(profileID: profileID, route: .coTraveller, steps: next?.steps ?? [])
        default:
            guard let kyc = dto.profileKYC, let missing = kyc.missing, !missing.isEmpty else { return nil }
            let establishesMain = kyc.anyMainExists == false
            return ProfileV3KYCCapture(
                profileID: dto.profileID,
                route: kyc.isMain == true || establishesMain ? .session : .coTraveller,
                steps: missing,
                reason: establishesMain ? ProfileV3CaptureStepKey.establishMainReason : nil
            )
        }
    }

    private static func agent(_ tile: ProfileV3AgentTileDTO) -> ProfileV3Agent? {
        guard let type = text(tile.agentType) else { return nil }
        let hasData = text(tile.updatedLabel) != nil
        let known = ProfileV3AgentID(apiValue: type)
        return ProfileV3Agent(
            id: known?.rawValue ?? type,
            name: text(tile.name) ?? text(tile.title) ?? "",
            summary: tile.blurb ?? "",
            avatarURL: iconURL(tile.icon),
            isActive: tile.activate == nil && hasData,
            hasData: hasData,
            foundCount: 0,
            totalCount: 0,
            next: tile.next?.directive,
            activate: tile.activate?.next.directive
        )
    }

    static func iconURL(_ token: String?) -> URL? {
        if let url = remoteURL(token) { return url }
        switch text(token) {
        case "orb_personal": return ProfileV3PlaceholderArt.agentPersonal.url
        default: return nil
        }
    }

    private static func programmesUpdate(_ loyalty: ProfileV3LoyaltyCardDTO?) -> ProfileV3UpdateStamp? {
        if let latest = loyalty?.programs.compactMap({ timestamp($0.lastUpdatedAt) }).max() {
            return .date(latest)
        }
        return text(loyalty?.updatedLabel).map(ProfileV3UpdateStamp.label)
    }

    private static func timestamp(_ value: String?) -> Date? {
        guard let value = text(value) else { return nil }
        if let date = fractionalTimestampParser.withLock({ $0.date(from: value) }) {
            return date
        }
        return timestampParser.withLock { $0.date(from: value) }
    }

    private static func agentsUpdatedAt(_ raw: String?) -> String {
        guard let date = timestamp(raw) else { return "" }
        return agentsUpdatedAtFormatter.string(from: date)
            .replacingOccurrences(of: "AM", with: "am")
            .replacingOccurrences(of: "PM", with: "pm")
    }

    private static let fractionalTimestampParser: OSAllocatedUnfairLock<ISO8601DateFormatter> = {
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return OSAllocatedUnfairLock(uncheckedState: parser)
    }()

    private static let timestampParser = OSAllocatedUnfairLock(uncheckedState: ISO8601DateFormatter())

    private static let agentsUpdatedAtFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mma, d MMM"
        return formatter
    }()

    private static func viewAllBenefitsLabel(_ section: ProfileV3BenefitsSectionDTO?) -> String {
        text(section?.viewAll?.label) ?? ProfileV3Strings.viewAllBenefits
    }

    private static func name(_ dto: ProfileV3ProfileBoardDTO, switcher: [ProfileV3TravellerSwitchDTO]) -> String {
        text(dto.name) ?? text(entry(for: dto, in: switcher)?.name) ?? ""
    }

    private static func isMain(_ dto: ProfileV3ProfileBoardDTO, switcher: [ProfileV3TravellerSwitchDTO]) -> Bool {
        dto.isMain ?? entry(for: dto, in: switcher)?.isMain ?? false
    }

    private static func entry(
        for dto: ProfileV3ProfileBoardDTO,
        in switcher: [ProfileV3TravellerSwitchDTO]
    ) -> ProfileV3TravellerSwitchDTO? {
        switcher.first { $0.profileID == dto.profileID }
    }

}
