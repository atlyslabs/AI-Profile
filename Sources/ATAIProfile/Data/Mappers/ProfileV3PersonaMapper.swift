import Foundation

enum ProfileV3PersonaMapper: ProfileV3DTOReading {
    private static let defaultRange = 0 ... 100

    static func persona(_ dto: ProfileV3PersonaScreenDTO) -> ProfileV3TravelPersona {
        let range = range(min: dto.profile?.min, max: dto.profile?.max)
        return ProfileV3TravelPersona(
            title: text(dto.title) ?? "",
            iconURL: ProfileV3BoardMapper.iconURL(dto.icon),
            foundLabel: text(dto.foundLabel) ?? "",
            subtitle: text(dto.subtitle) ?? "",
            range: range,
            traits: (dto.profile?.traits ?? []).compactMap { point in
                guard let id = text(point.trait) else { return nil }
                let score = point.score?.intValue ?? midpoint(of: range)
                return ProfileV3TravelPersona.Trait(
                    id: id,
                    name: text(point.name) ?? id,
                    score: min(max(score, range.lowerBound), range.upperBound),
                    detail: point.next?.directive,
                    submit: point.submit.map(action)
                )
            }
        )
    }

    static func trait(_ dto: ProfileV3PersonaTraitScreenDTO, trait: String) -> ProfileV3PersonaTrait {
        let range = range(min: dto.scale?.min, max: dto.scale?.max)
        let score = dto.score?.intValue ?? dto.scale?.value?.intValue ?? midpoint(of: range)
        let calculation = dto.calculation
        return ProfileV3PersonaTrait(
            trait: text(dto.trait) ?? trait,
            title: text(dto.title) ?? "",
            score: score,
            subtitle: text(dto.subtitle) ?? "",
            scale: ProfileV3PersonaTrait.Scale(
                range: range,
                value: dto.scale?.value?.intValue ?? score,
                labels: dto.scale?.labels.compactMap(text) ?? []
            ),
            calculationTitle: text(calculation?.title) ?? "",
            rows: (calculation?.items ?? []).enumerated().compactMap { index, item in row(item, index: index) },
            bulk: calculation?.bulk.flatMap(personaAction),
            nextPage: calculation?.nextPage?.directive,
            startingPoint: calculation?.startingPoint.flatMap { point in
                guard let title = text(point.title) else { return nil }
                return ProfileV3PersonaTrait.StartingPoint(title: title, subtitle: text(point.subtitle) ?? "")
            }
        )
    }

    static func action(_ dto: ProfileV3BoardActionDTO) -> ProfileV3BoardAction {
        ProfileV3BoardAction(fields: dto.fields)
    }

    private static func row(_ dto: ProfileV3PersonaRowDTO, index: Int) -> ProfileV3PersonaTrait.Row? {
        guard let title = text(dto.title) else { return nil }
        let delta = dto.delta?.intValue ?? 0
        return ProfileV3PersonaTrait.Row(
            id: dto.id?.stringValue ?? "row-\(index)",
            kind: dto.kind?.lowercased() == "gmail" ? .gmail : .user,
            title: title,
            subtitle: text(dto.subtitle) ?? "",
            delta: delta,
            deltaLabel: text(dto.deltaLabel) ?? (delta > 0 ? "+\(delta)" : "\(delta)"),
            isIgnored: dto.ignored == true,
            action: dto.button.flatMap(personaAction)
        )
    }

    private static func personaAction(_ dto: ProfileV3PersonaActionDTO) -> ProfileV3PersonaTrait.Action? {
        guard let label = text(dto.label), dto.submit.fields["action"] != nil else { return nil }
        return ProfileV3PersonaTrait.Action(label: label, submit: action(dto.submit))
    }

    private static func range(min: ProfileV3ScalarDTO?, max: ProfileV3ScalarDTO?) -> ClosedRange<Int> {
        guard let lower = min?.intValue, let upper = max?.intValue, lower < upper else { return defaultRange }
        return lower ... upper
    }

    private static func midpoint(of range: ClosedRange<Int>) -> Int {
        (range.lowerBound + range.upperBound) / 2
    }
}
