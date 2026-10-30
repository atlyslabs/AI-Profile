import Foundation

enum ProfileV3AIConnectorMapper: ProfileV3DTOReading {
    static let datePlaceholder = "{date}"

    static func detail(_ dto: ProfileV3AIConnectorScreenDTO, fallback connector: String) -> ProfileV3AIConnector {
        let benefits = dto.benefits.compactMap { benefit -> (String, String)? in
            guard let title = text(benefit.title) else { return nil }
            return (title, text(benefit.body) ?? "")
        }
        let disclaimers = dto.disclaimers.compactMap { disclaimer -> (String, [ProfileV3AIConnector.Disclaimer.Link])? in
            guard let body = text(disclaimer.text) else { return nil }
            let links = disclaimer.links.compactMap { link -> ProfileV3AIConnector.Disclaimer.Link? in
                guard let label = text(link.label), body.contains(label), let url = remoteURL(link.url) else { return nil }
                return ProfileV3AIConnector.Disclaimer.Link(label: label, url: url)
            }
            return (body, links)
        }
        return ProfileV3AIConnector(
            connector: text(dto.connector) ?? connector,
            eyebrow: text(dto.eyebrow) ?? "",
            title: text(dto.title) ?? "",
            imageURL: remoteURL(dto.imageURL),
            subtitle: text(dto.subtitle) ?? "",
            benefits: benefits.enumerated().map { .init(id: $0.offset, title: $0.element.0, body: $0.element.1) },
            disclaimers: disclaimers.enumerated().map {
                .init(id: $0.offset, text: $0.element.0, links: $0.element.1)
            },
            ctaLabel: text(dto.cta?.label) ?? "",
            next: dto.cta?.next?.directive
        )
    }

    static func connect(_ dto: ProfileV3AIConnectorConnectScreenDTO, fallback connector: String) -> ProfileV3AIConnectorConnect {
        let key = text(dto.connector) ?? connector
        let steps = dto.steps.enumerated().compactMap { index, step -> ProfileV3AIConnectorConnect.Step? in
            let prompt = step.prompt.flatMap { prompt -> ProfileV3AIConnectorConnect.Prompt? in
                guard let body = text(prompt.text) else { return nil }
                return ProfileV3AIConnectorConnect.Prompt(
                    text: body,
                    copyLabel: text(prompt.copyLabel) ?? "",
                    copiedLabel: text(prompt.copiedLabel) ?? ""
                )
            }
            let input = step.input.map {
                ProfileV3AIConnectorConnect.Input(key: text($0.key) ?? "text", placeholder: text($0.placeholder) ?? "")
            }
            let submit = step.submit.flatMap { submit -> ProfileV3AIConnectorConnect.Submit? in
                guard let action = text(submit.action) else { return nil }
                return ProfileV3AIConnectorConnect.Submit(
                    label: text(submit.label) ?? "",
                    action: action,
                    connector: text(submit.connector) ?? key
                )
            }
            let title = text(step.title) ?? ""
            guard !title.isEmpty || prompt != nil || input != nil || submit != nil else { return nil }
            return ProfileV3AIConnectorConnect.Step(
                id: index,
                label: text(step.label) ?? "",
                title: title,
                body: text(step.body) ?? "",
                prompt: prompt,
                input: input,
                submit: submit
            )
        }
        return ProfileV3AIConnectorConnect(
            connector: key,
            eyebrow: text(dto.eyebrow) ?? "",
            title: text(dto.title) ?? "",
            imageURL: remoteURL(dto.imageURL),
            steps: steps
        )
    }

    static func syncedAt(_ raw: String?) -> Date? {
        text(raw).flatMap(ProfileV3ISODate.parse)
    }

    static func statusLabel(_ template: String?, syncedAt: Date?, timeZone: TimeZone = .autoupdatingCurrent) -> String? {
        guard let template = text(template) else { return nil }
        guard template.contains(datePlaceholder) else { return template }
        guard let syncedAt else { return nil }
        return template.replacingOccurrences(of: datePlaceholder, with: syncedText(syncedAt, timeZone: timeZone))
    }

    static func syncedText(_ date: Date, timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.dateFormat = "d MMM, h:mm a"
        return formatter.string(from: date)
    }
}
