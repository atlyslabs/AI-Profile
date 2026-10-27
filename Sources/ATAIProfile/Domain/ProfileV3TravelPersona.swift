import Foundation

struct ProfileV3BoardAction: Equatable {
    let fields: [String: ProfileV3ScalarDTO]

    var name: String? { fields["action"]?.stringValue }
}

struct ProfileV3TravelPersona: Equatable {
    struct Trait: Identifiable, Equatable {
        let id: String
        let name: String
        var score: Int
        var detail: ProfileV3Directive?
        var submit: ProfileV3BoardAction?
    }

    let title: String
    let iconURL: URL?
    let foundLabel: String
    let subtitle: String
    let range: ClosedRange<Int>
    var traits: [Trait]

    func clamped(_ score: Int) -> Int {
        min(max(score, range.lowerBound), range.upperBound)
    }
}

struct ProfileV3PersonaTrait: Equatable {
    struct Scale: Equatable {
        let range: ClosedRange<Int>
        let value: Int
        let labels: [String]

        var fraction: Double {
            let span = Double(range.upperBound - range.lowerBound)
            guard span > 0 else { return 0 }
            return min(max(Double(value - range.lowerBound) / span, 0), 1)
        }

        var activeLabelIndex: Int? {
            guard !labels.isEmpty else { return nil }
            return min(Int(fraction * Double(labels.count)), labels.count - 1)
        }
    }

    struct Action: Equatable {
        let label: String
        let submit: ProfileV3BoardAction
    }

    struct Row: Identifiable, Equatable {
        enum Kind: Equatable {
            case gmail
            case user
        }

        let id: String
        let kind: Kind
        let title: String
        let subtitle: String
        let delta: Int
        let deltaLabel: String
        let isIgnored: Bool
        var action: Action?
    }

    struct StartingPoint: Equatable {
        let title: String
        let subtitle: String
    }

    let trait: String
    let title: String
    let score: Int
    let subtitle: String
    let scale: Scale
    let calculationTitle: String
    var rows: [Row]
    var bulk: Action?
    var nextPage: ProfileV3Directive?
    var startingPoint: StartingPoint?
}
