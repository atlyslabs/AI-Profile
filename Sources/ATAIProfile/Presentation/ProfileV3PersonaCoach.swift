import Foundation

struct ProfileV3PersonaCoach: Equatable {
    enum Step: Equatable {
        case drag
        case tap
    }

    let traitID: String
    let steps: [Step]
    private(set) var index = 0

    var step: Step { steps[index] }

    init?(traits: [ProfileV3TravelPersona.Trait], isEditable: Bool) {
        let candidates = traits.indices.compactMap { index -> (index: Int, steps: [Step])? in
            let steps = Self.steps(for: traits[index], isEditable: isEditable)
            return steps.isEmpty ? nil : (index, steps)
        }
        let upper = candidates.filter { Self.rise(of: $0.index, count: traits.count) >= Self.targetMinimumRise }
        guard let target = (upper.isEmpty ? candidates : upper)
            .max(by: { traits[$0.index].score < traits[$1.index].score }) else { return nil }
        traitID = traits[target.index].id
        steps = target.steps
    }

    func advanced() -> ProfileV3PersonaCoach? {
        guard index + 1 < steps.count else { return nil }
        var next = self
        next.index += 1
        return next
    }

    private static let targetMinimumRise = ProfileV3Theme.Sizes.Persona.Coach.targetMinimumRise

    private static func steps(for trait: ProfileV3TravelPersona.Trait, isEditable: Bool) -> [Step] {
        var steps: [Step] = []
        if isEditable, trait.submit != nil { steps.append(.drag) }
        if trait.detail != nil { steps.append(.tap) }
        return steps
    }

    private static func rise(of index: Int, count: Int) -> Double {
        cos(2 * Double.pi * Double(index) / Double(max(count, 1)))
    }
}
