import Foundation

enum ProfileV3LoyaltyMapper: ProfileV3DTOReading {
    private static func catalogue(_ dto: ProfileV3LoyaltyPickScreenDTO) -> [ProfileV3ProgrammeCatalogueItem] {
        dto.programs.compactMap { row -> ProfileV3ProgrammeCatalogueItem? in
            row.row.id.isEmpty ? nil : catalogueItem(row.row)
        }
    }

    static func picker(_ dto: ProfileV3LoyaltyPickScreenDTO) -> ProfileV3ProgrammePicker {
        ProfileV3ProgrammePicker(items: catalogue(dto), filters: filters(dto))
    }

    private static func filters(_ dto: ProfileV3LoyaltyPickScreenDTO) -> [ProfileV3ProgrammeFilter] {
        var seen = Set<String>()
        return dto.filters.compactMap { raw in
            let label = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !label.isEmpty, seen.insert(normalised(label)).inserted else { return nil }
            return ProfileV3ProgrammeFilter(label: label, category: category(for: label))
        }
    }

    static func overview(_ dto: ProfileV3ProgrammesPageScreenDTO, profileID: String) -> ProfileV3ProgrammeOverview {
        let holder = (dto.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let programmes = dto.programs.compactMap { row -> ProfileV3LoyaltyProgramme? in
            guard !row.row.id.isEmpty else { return nil }
            var mapped = programme(row.row)
            mapped.holderName = holder.isEmpty ? nil : holder
            mapped.insightDirective = row.next?.directive
            return mapped
        }
        return ProfileV3ProgrammeOverview(
            passID: profileID,
            holderName: holder,
            programmes: programmes,
            connectedCount: dto.count?.intValue ?? programmes.count,
            summary: dto.subtitle ?? "",
            pointsLabel: dto.stats?.pointsTotal?.stringValue ?? "",
            estimatedValueLabel: dto.stats?.estValue?.stringValue ?? "",
            reorderAction: text(dto.reorder?.action)
        )
    }

    static func entryForm(
        _ dto: ProfileV3LoyaltyEnterScreenDTO,
        programID: String,
        programName: String?,
        kind: String?
    ) -> ProfileV3LoyaltyEntryForm {
        ProfileV3LoyaltyEntryForm(
            programID: text(dto.programID) ?? programID,
            programName: text(dto.programName) ?? text(dto.submit?.programName) ?? programName,
            kind: text(dto.submit?.kind) ?? kind,
            title: text(dto.title),
            submitLabel: text(dto.submit?.label),
            fields: dto.fields.map { field in
                ProfileV3LoyaltyEntryForm.Field(
                    key: field.key,
                    label: text(field.label) ?? fallbackLabel(forKey: field.key),
                    isRequired: field.required ?? false
                )
            }
        )
    }

    private static func fallbackLabel(forKey key: String) -> String {
        switch key {
        case ProfileV3LoyaltyEntryForm.Field.membershipNumberKey: return ProfileV3Strings.membershipNumber
        case ProfileV3LoyaltyEntryForm.Field.pointsKey: return ProfileV3Strings.pointsMiles
        default: return ProfileV3Strings.fieldLabel(fromKey: key)
        }
    }

    static func insight(_ dto: ProfileV3ProgrammeInsightScreenDTO) -> ProfileV3ProgrammeInsight {
        let summary = (dto.insight ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let action = dto.continueCTA?.label ?? ""
        let showsSources = dto.sources?.show ?? true
        return ProfileV3ProgrammeInsight(
            summary: summary,
            actionTitle: action,
            detail: ProfileV3ProgrammeInsightDetail(
                body: summary.isEmpty ? [] : [ProfileV3TextSegment(text: summary)],
                sourceIcons: showsSources ? sourceIcons(dto.sources) : [],
                sourceCount: showsSources ? (dto.sources?.count?.intValue ?? 0) : 0,
                sources: showsSources ? dto.sources?.next?.directive : nil
            ),
            action: dto.action?.directive
        )
    }

    static func programme(_ row: ProfileV3ProgrammeRowDTO) -> ProfileV3LoyaltyProgramme {
        let local = catalogueMatch(id: row.id, name: row.name)
        return ProfileV3LoyaltyProgramme(
            id: row.id,
            name: row.name,
            maskedNumber: maskedNumber(row),
            points: row.points?.intValue ?? 0,
            logoURL: remoteURL(row.imageURL) ?? remoteURL(row.art) ?? local?.logoURL,
            artURL: remoteURL(row.art),
            isArtPlaceholder: row.artPlaceholder == true,
            textOverlay: row.textOverlay?.lowercased() == "dark" ? .dark : .light,
            membershipNumber: text(row.membershipNumber),
            expiryLabel: text(row.expiry),
            pointsLine: text(row.pointsLine)
        )
    }

    private static func catalogueItem(_ row: ProfileV3ProgrammeRowDTO) -> ProfileV3ProgrammeCatalogueItem {
        let local = catalogueMatch(id: row.id, name: row.name)
        return ProfileV3ProgrammeCatalogueItem(
            id: row.id,
            name: row.name,
            category: category(for: row.kind) ?? local?.category ?? .all,
            cardImageURL: remoteURL(row.art) ?? local?.cardImageURL,
            logoURL: remoteURL(row.imageURL) ?? local?.logoURL
        )
    }

    static func addProgrammeRequest(
        _ submission: ProfileV3ProgrammeSubmission,
        profileID: String,
        kind: String? = nil
    ) -> ProfileV3AddLoyaltyProgrammeRequest {
        let membership = submission.membershipNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        return ProfileV3AddLoyaltyProgrammeRequest(
            programID: submission.item.id,
            profileID: profileID,
            programName: submission.item.name,
            kind: kind ?? self.kind(for: submission.item.category),
            membershipNumber: membership.isEmpty ? nil : membership,
            points: submission.points.map(String.init)
        )
    }

    private static func category(for raw: String?) -> ProfileV3ProgrammeCategory? {
        guard let raw else { return nil }
        let key = normalised(raw)
        guard !key.isEmpty else { return nil }
        let match = ProfileV3ProgrammeCategory.allCases.first {
            normalised($0.rawValue) == key || normalised($0.title) == key
        }
        return match ?? categoryAliases[key]
    }

    static func kind(for category: ProfileV3ProgrammeCategory) -> String? {
        switch category {
        case .all: return nil
        case .creditCards: return "credit_cards"
        case .hotels: return "hotels"
        case .flights: return "flights"
        case .travelPasses: return "travel_passes"
        }
    }

    private static let categoryAliases: [String: ProfileV3ProgrammeCategory] = [
        "card": .creditCards,
        "cards": .creditCards,
        "creditcard": .creditCards,
        "hotel": .hotels,
        "stay": .hotels,
        "stays": .hotels,
        "flight": .flights,
        "airline": .flights,
        "airlines": .flights,
        "pass": .travelPasses,
        "passes": .travelPasses,
        "travelpass": .travelPasses
    ]

    private static func sourceIcons(_ dto: ProfileV3ProgrammeSourcesDTO?) -> [ProfileV3SourceIcon] {
        (dto?.icons ?? []).map(ProfileV3AgentMapper.sourceIcon)
    }

    private static func catalogueMatch(id: String, name: String) -> ProfileV3ProgrammeCatalogueItem? {
        ProfileV3ProgrammeCatalogue.all.first { $0.id == id }
            ?? ProfileV3ProgrammeCatalogue.all.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }
    }

    private static func maskedNumber(_ row: ProfileV3ProgrammeRowDTO) -> String {
        ProfileV3ProgrammeCatalogue.masked(row.last4 ?? row.membershipNumber ?? "")
    }

    private static func normalised(_ value: String) -> String {
        value.lowercased().filter { $0.isLetter || $0.isNumber }
    }
}
