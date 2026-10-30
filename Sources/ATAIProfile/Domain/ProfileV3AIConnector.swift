import Foundation

struct ProfileV3AIConnector: Equatable {
    struct Benefit: Identifiable, Equatable {
        let id: Int
        let title: String
        let body: String
    }

    struct Disclaimer: Identifiable, Equatable {
        struct Link: Equatable {
            let label: String
            let url: URL
        }

        let id: Int
        let text: String
        var links: [Link] = []
    }

    let connector: String
    let eyebrow: String
    let title: String
    var imageURL: URL?
    let subtitle: String
    let benefits: [Benefit]
    let disclaimers: [Disclaimer]
    let ctaLabel: String
    var next: ProfileV3Directive?
}

struct ProfileV3AIConnectorConnect: Equatable {
    struct Prompt: Equatable {
        let text: String
        let copyLabel: String
        let copiedLabel: String
    }

    struct Input: Equatable {
        let key: String
        let placeholder: String
    }

    struct Submit: Equatable {
        let label: String
        let action: String
        let connector: String
    }

    struct Step: Identifiable, Equatable {
        let id: Int
        let label: String
        let title: String
        var body = ""
        var prompt: Prompt?
        var input: Input?
        var submit: Submit?
    }

    let connector: String
    let eyebrow: String
    let title: String
    var imageURL: URL?
    let steps: [Step]

    var prompt: Prompt? { steps.lazy.compactMap(\.prompt).first }
    var submit: Submit? { steps.lazy.compactMap(\.submit).first }
}

struct ProfileV3ConnectAIConnectorRequest: Encodable, Equatable {
    let action: String
    let connector: String
    let text: String
}
